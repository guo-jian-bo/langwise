import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../common/entities/entities.dart';
import '../../common/https/https.dart';
import 'learn_record_constants.dart';
import 'learn_record_database.dart';
import 'learn_record_model.dart';

class LearnRecordManager with WidgetsBindingObserver {
  LearnRecordManager._internal();
  static final LearnRecordManager _instance = LearnRecordManager._internal();
  static LearnRecordManager get instance => _instance;

  LearnRecordModel? _currentRecord;
  int? _currentRecordId;
  String? _currentSource;
  bool _isTracking = false;
  bool _isObserverAttached = false;
  bool _isDatabaseInitialized = false;
  DateTime? _segmentStartedAt;
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
    _resumeTracking();
    _attachObserver();
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

    await _pauseTracking();
    _detachObserver();

    final record = _currentRecord;
    final recordId = _currentRecordId;
    _resetCurrentState();

    if (record == null || recordId == null) {
      return;
    }
    if (record.durationSec < LearnRecordConstants.minValidLearnSeconds || record.contentList.isEmpty) {
      await LearnRecordDatabase.instance.delete(recordId);
      return;
    }
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
      if (record.isExpired ||
          record.durationSec < LearnRecordConstants.minValidLearnSeconds ||
          record.contentList.isEmpty) {
        if (record.id != null) {
          await LearnRecordDatabase.instance.delete(record.id!);
        }
        continue;
      }
      final success = await MissionRequest.reportContentLearn(record.toReportMap());
      if (record.id == null) continue;
      await LearnRecordDatabase.instance.updateStatus(
        record.id!,
        success ? LearnRecordConstants.statusSuccess : LearnRecordConstants.statusFailed,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isTracking) return;
    if (state == AppLifecycleState.resumed) {
      _resumeTracking();
      return;
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_pauseTracking());
    }
  }

  void _resumeTracking() {
    if (!_isTracking || _segmentStartedAt != null) return;
    _segmentStartedAt = DateTime.now();
  }

  Future<void> _pauseTracking() async {
    if (!_isTracking) return;
    final startedAt = _segmentStartedAt;
    if (startedAt != null) {
      final seconds = DateTime.now().difference(startedAt).inSeconds;
      if (seconds > 0 && _currentRecord != null) {
        _currentRecord = _currentRecord!.copyWith(
          durationSec: _currentRecord!.durationSec + seconds,
        );
      }
      _segmentStartedAt = null;
    }
    await _persistSnapshot();
  }

  Future<void> _persistSnapshot() async {
    final record = _currentRecord;
    final recordId = _currentRecordId;
    if (record == null || recordId == null) return;
    final snapshot = record.copyWith(contentList: _trackedContents.values.toList());
    _currentRecord = snapshot;
    await LearnRecordDatabase.instance.updateSnapshot(recordId, snapshot);
  }

  void _attachObserver() {
    if (_isObserverAttached) return;
    WidgetsBinding.instance.addObserver(this);
    _isObserverAttached = true;
  }

  void _detachObserver() {
    if (!_isObserverAttached) return;
    WidgetsBinding.instance.removeObserver(this);
    _isObserverAttached = false;
  }

  void _resetCurrentState() {
    _segmentStartedAt = null;
    _currentRecord = null;
    _currentRecordId = null;
    _currentSource = null;
    _trackedContents.clear();
    _isTracking = false;
  }
}
