import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'learn_record_constants.dart';

class LearnRecordModel {
  int? id;
  String sessionId;
  String? type;
  int durationSec;
  List<Map<String, dynamic>> contentList;
  String reportStatus;
  int createdAt;

  LearnRecordModel({
    this.id,
    String? sessionId,
    this.type,
    this.durationSec = 0,
    List<Map<String, dynamic>>? contentList,
    this.reportStatus = LearnRecordConstants.statusPending,
    int? createdAt,
  })  : sessionId = sessionId ?? const Uuid().v4(),
        contentList = contentList ?? <Map<String, dynamic>>[],
        createdAt = createdAt ?? DateTime.now().toUtc().millisecondsSinceEpoch;

  factory LearnRecordModel.fromMap(Map<String, dynamic> map) {
    final rawContentList = (map['content_list_json'] as String?) ?? '[]';
    final decoded = jsonDecode(rawContentList);
    final contentList = <Map<String, dynamic>>[];
    if (decoded is List) {
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          contentList.add(item);
        } else if (item is Map) {
          contentList.add(item.cast<String, dynamic>());
        }
      }
    }
    return LearnRecordModel(
      id: map['id'] as int?,
      sessionId: map['session_id'] as String,
      type: map['type'] as String?,
      durationSec: map['duration_sec'] as int? ?? 0,
      contentList: contentList,
      reportStatus: map['report_status'] as String? ?? LearnRecordConstants.statusPending,
      createdAt: map['created_at'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'session_id': sessionId,
      'type': type,
      'duration_sec': durationSec,
      'content_list_json': jsonEncode(contentList),
      'report_status': reportStatus,
      'created_at': createdAt,
    };
  }

  Map<String, dynamic> toReportMap() {
    return {
      if (type != null && type!.isNotEmpty) 'type': type,
      'durationSec': '$durationSec',
      if (contentList.isNotEmpty) 'contentList': contentList,
    };
  }

  LearnRecordModel copyWith({
    int? id,
    String? sessionId,
    Object? type = _sentinel,
    int? durationSec,
    List<Map<String, dynamic>>? contentList,
    String? reportStatus,
    int? createdAt,
  }) {
    return LearnRecordModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      type: identical(type, _sentinel) ? this.type : type as String?,
      durationSec: durationSec ?? this.durationSec,
      contentList: contentList ?? this.contentList,
      reportStatus: reportStatus ?? this.reportStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get needsReport =>
      reportStatus == LearnRecordConstants.statusPending ||
      reportStatus == LearnRecordConstants.statusFailed;

  bool get isExpired {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    const expirationMs = LearnRecordConstants.maxRetentionDays * 24 * 60 * 60 * 1000;
    return now - createdAt > expirationMs;
  }
}

const Object _sentinel = Object();
