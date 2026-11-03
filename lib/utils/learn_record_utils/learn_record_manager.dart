import 'dart:async';

import '../../common/entities/entities.dart';
import '../../common/https/https.dart';
import '../utils.dart';
import 'learn_record_constants.dart';
import 'learn_record_database.dart';
import 'learn_record_model.dart';

class LearnRecordManager {
  LearnRecordManager._internal();
  static final LearnRecordManager _instance = LearnRecordManager._internal();
  static LearnRecordManager get instance => _instance;

  LearnRecordModel? _currentRecord;
  int? _currentRecordId;
  String? _currentSource;
  bool _isTracking = false;
  bool _isDatabaseInitialized = false;
  DateTime? _trackingStartedAt;
  final Map<String, Map<String, dynamic>> _trackedContents = <String, Map<String, dynamic>>{};

  Future<void> _ensureDatabaseInitialized() async {
    if (_isDatabaseInitialized) return;
    await LearnRecordDatabase.instance.initialize();
    _isDatabaseInitialized = true;
  }

  Future<void> startTracking({
    required String source,
    String? type,
  }) async {
    if (_isTracking && _currentSource == source) return;
    if (_isTracking) {
      await stopTracking(source: _currentSource);
    }

    await _ensureDatabaseInitialized();
    _currentRecord = LearnRecordModel(type: type);
    _currentRecordId = await LearnRecordDatabase.instance.insert(_currentRecord!);
    _currentSource = source;
    _isTracking = true;
    _trackedContents.clear();
    _trackingStartedAt = DateTime.now();
  }

  Future<void> markContentViewed(UnitKnowledgePointsEntityKnowledgeList? item) async {
    if (!_isTracking || item == null) return;
    final contentId = item.contentId;
    final semanticId = item.semanticId;
    final contentType = item.contentType;
    if (contentId == null || semanticId == null || contentType == null || contentType.isEmpty) {
      return;
    }
    final key = '${contentId}_${semanticId}_$contentType';
    if (_trackedContents.containsKey(key)) return;
    _trackedContents[key] = {
      'uid': contentId,
      'semanticId': semanticId,
      'type': contentType,
    };
    await _persistSnapshot();
  }

  Future<void> stopTracking({String? source}) async {
    if (!_isTracking) return;
    if (source != null && source != _currentSource) return;

    await _persistSnapshot();

    final record = _currentRecord;
    final recordId = _currentRecordId;
    _resetCurrentState();

    if (record == null || recordId == null) {
      return;
    }
    if (record.contentList.isEmpty) {
      await LearnRecordDatabase.instance.delete(recordId);
      return;
    }
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberContentLearnUpload)) return;
    final success = await MissionRequest.reportContentLearn(record.toReportMap());
    if (success) {
      await LearnRecordDatabase.instance.updateStatus(recordId, LearnRecordConstants.statusSuccess);
    } else {
      await LearnRecordDatabase.instance.updateStatus(recordId, LearnRecordConstants.statusFailed);
    }
  }

  Future<void> reportPendingRecords() async {
    await _ensureDatabaseInitialized();
    final records = await LearnRecordDatabase.instance.getPendingRecords();
    for (final record in records) {
      if (record.isExpired || record.contentList.isEmpty) {
        if (record.id != null) {
          await LearnRecordDatabase.instance.delete(record.id!);
        }
        continue;
      }
      if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberContentLearnUpload)) return;
      final success = await MissionRequest.reportContentLearn(record.toReportMap());
      if (record.id == null) continue;
      await LearnRecordDatabase.instance.updateStatus(
        record.id!,
        success ? LearnRecordConstants.statusSuccess : LearnRecordConstants.statusFailed,
      );
    }
  }

  int _resolveCurrentDurationSec() {
    final record = _currentRecord;
    if (record == null) return 0;
    final startedAt = _trackingStartedAt;
    if (startedAt == null) return record.durationSec;
    final elapsed = DateTime.now().difference(startedAt).inSeconds;
    if (elapsed <= 0) return record.durationSec;
    return elapsed;
  }

  Future<void> _persistSnapshot() async {
    final record = _currentRecord;
    final recordId = _currentRecordId;
    if (record == null || recordId == null) return;
    final snapshot = record.copyWith(
      durationSec: _resolveCurrentDurationSec(),
      contentList: _trackedContents.values.toList(),
    );
    _currentRecord = snapshot;
    await LearnRecordDatabase.instance.updateSnapshot(recordId, snapshot);
  }

  void _resetCurrentState() {
    _trackingStartedAt = null;
    _currentRecord = null;
    _currentRecordId = null;
    _currentSource = null;
    _trackedContents.clear();
    _isTracking = false;
  }
}
