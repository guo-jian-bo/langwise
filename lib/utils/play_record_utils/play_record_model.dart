import 'package:uuid/uuid.dart';

import 'play_record_constants.dart';

/// 播放记录数据模型
class PlayRecordModel {
  /// 数据库主键ID
  int? id;

  /// 会话ID - 一曲开始时生成的UUID
  String sessionId;

  /// 类型: unit, favorite, collection, none
  String? type;

  /// 关联ID
  int? typeId;

  /// 语种风格ID
  int? styleId;

  /// 方言
  String? dialect;

  /// 学习类型（listen/read/watch/perform/practice）
  String? learnType;

  /// 内容类型 (如 EN_SONG, EN_ARTICLE 等)
  String contentType;

  /// 内容ID
  int contentId;

  /// 已播放时长（秒）
  double played;

  /// 总时长（秒）
  double duration;

  /// 触发类型
  String triggerType;

  /// 上报状态
  String reportStatus;

  /// 创建时间戳（毫秒）
  int createdAt;

  /// 扩展字段（JSON字符串，预留扩展）
  String? extra;

  PlayRecordModel({
    this.id,
    String? sessionId,
    this.type,
    this.typeId,
    this.styleId,
    this.dialect,
    this.learnType,
    required this.contentType,
    required this.contentId,
    required this.played,
    required this.duration,
    this.triggerType = '',
    this.reportStatus = 'pending',
    int? createdAt,
    this.extra,
  })  : sessionId = sessionId ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().toUtc().millisecondsSinceEpoch;

  /// 从数据库 Map 创建实例
  factory PlayRecordModel.fromMap(Map<String, dynamic> map) {
    return PlayRecordModel(
      id: map['id'] as int?,
      sessionId: map['session_id'] as String,
      type: map['type'] as String?,
      typeId: map['type_id'] as int?,
      styleId: map['style_id'] as int?,
      dialect: map['dialect'] as String?,
      learnType: map['learn_type'] as String?,
      contentType: map['content_type'] as String,
      contentId: map['content_id'] as int,
      played: (map['played'] as num).toDouble(),
      duration: (map['duration'] as num).toDouble(),
      triggerType: map['trigger_type'] as String? ?? '',
      reportStatus: map['report_status'] as String? ?? 'pending',
      createdAt: map['created_at'] as int,
      extra: map['extra'] as String?,
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'session_id': sessionId,
      'type': type,
      'type_id': typeId,
      'style_id': styleId,
      'dialect': dialect,
      'learn_type': learnType,
      'content_type': contentType,
      'content_id': contentId,
      'played': played,
      'duration': duration,
      'trigger_type': triggerType,
      'report_status': reportStatus,
      'created_at': createdAt,
      'extra': extra,
    };
  }

  /// 转换为上报 API 的 Map
  Map<String, dynamic> toReportMap() {
    return {
      'sessionId': sessionId,
      'type': type,
      'typeId': typeId,
      'styleId': styleId,
      'dialect': dialect,
      'learnType': learnType,
      'contentType': contentType,
      'contentId': contentId,
      'played': played,
      'duration': duration,
      'triggerType': triggerType,
      'timestamp': createdAt,
      if (extra != null) 'extra': extra,
    };
  }

  /// 复制并修改
  PlayRecordModel copyWith({
    int? id,
    String? sessionId,
    String? type,
    int? typeId,
    int? styleId,
    String? dialect,
    String? learnType,
    String? contentType,
    int? contentId,
    double? played,
    double? duration,
    String? triggerType,
    String? reportStatus,
    int? createdAt,
    String? extra,
  }) {
    return PlayRecordModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      type: type ?? this.type,
      typeId: typeId ?? this.typeId,
      styleId: styleId ?? this.styleId,
      dialect: dialect ?? this.dialect,
      learnType: learnType ?? this.learnType,
      contentType: contentType ?? this.contentType,
      contentId: contentId ?? this.contentId,
      played: played ?? this.played,
      duration: duration ?? this.duration,
      triggerType: triggerType ?? this.triggerType,
      reportStatus: reportStatus ?? this.reportStatus,
      createdAt: createdAt ?? this.createdAt,
      extra: extra ?? this.extra,
    );
  }

  /// 检查记录是否过期
  bool isExpired() {
    final now = DateTime.now().millisecondsSinceEpoch;
    const expirationMs = PlayRecordConstants.maxRetentionDays * 24 * 60 * 60 * 1000;
    return (now - createdAt) > expirationMs;
  }

  /// 获取上报状态枚举
  PlayRecordReportStatus get reportStatusEnum =>
      PlayRecordReportStatus.fromValue(reportStatus);

  /// 设置上报状态
  void setReportStatus(PlayRecordReportStatus status) {
    reportStatus = status.value;
  }

  /// 是否需要上报（pending 或 failed 状态）
  bool get needsReport =>
      reportStatus == PlayRecordReportStatus.pending.value ||
      reportStatus == PlayRecordReportStatus.failed.value;

  @override
  String toString() {
    return 'PlayRecordModel(id: $id, sessionId: $sessionId, type: $type, typeId: $typeId, styleId: $styleId, '
        'dialect: $dialect, learnType: $learnType, '
        'contentType: $contentType, contentId: $contentId, played: $played, duration: $duration, '
        'triggerType: $triggerType, reportStatus: $reportStatus)';
  }
}
