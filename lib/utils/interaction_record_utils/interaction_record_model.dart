import 'interaction_record_constants.dart';

/// 交互记录数据模型
class InteractionRecordModel {
  /// 用于 `copyWith` 的空值占位，支持显式将可空字段置空
  static const Object _nullSentinel = Object();

  /// 数据库主键 ID
  int? id;

  /// 交互会话 ID
  String sessionId;

  /// 来源标识
  String? source;

  /// 页面类型
  String? type;

  /// 页面类型 ID
  int? typeId;

  /// 风格 ID
  int? styleId;

  /// 方言
  String? dialect;

  /// 学习类型
  String? learnType;

  /// 内容类型
  String contentType;

  /// 内容 ID
  int contentId;

  /// 资源总时长
  double duration;

  /// 会话开始时间戳
  int startedAt;

  /// 最近活跃时间戳
  int? lastActiveAt;

  /// idle 开始时间戳
  int? idleStartedAt;

  /// 会话结束时间戳
  int? endedAt;

  /// 已累计的活跃毫秒数
  int accumulatedActiveMs;

  /// 上报状态值
  String reportStatus;

  /// 创建时间戳
  int createdAt;

  /// 更新时间戳
  int updatedAt;

  /// 扩展字段
  String? extra;

  /// 创建交互记录模型
  InteractionRecordModel({
    this.id,
    required this.sessionId,
    this.source,
    this.type,
    this.typeId,
    this.styleId,
    this.dialect,
    this.learnType,
    required this.contentType,
    required this.contentId,
    required this.duration,
    required this.startedAt,
    this.lastActiveAt,
    this.idleStartedAt,
    this.endedAt,
    this.accumulatedActiveMs = 0,
    this.reportStatus = 'pending',
    int? createdAt,
    int? updatedAt,
    this.extra,
  })  : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch,
        updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch;

  /// 从数据库映射创建模型
  factory InteractionRecordModel.fromMap(Map<String, dynamic> map) {
    return InteractionRecordModel(
      id: map['id'] as int?,
      sessionId: map['session_id'] as String,
      source: map['source'] as String?,
      type: map['type'] as String?,
      typeId: map['type_id'] as int?,
      styleId: map['style_id'] as int?,
      dialect: map['dialect'] as String?,
      learnType: map['learn_type'] as String?,
      contentType: map['content_type'] as String,
      contentId: map['content_id'] as int,
      duration: (map['duration'] as num).toDouble(),
      startedAt: map['started_at'] as int,
      lastActiveAt: map['last_active_at'] as int?,
      idleStartedAt: map['idle_started_at'] as int?,
      endedAt: map['ended_at'] as int?,
      accumulatedActiveMs: map['accumulated_active_ms'] as int? ?? 0,
      reportStatus: map['report_status'] as String? ??
          InteractionRecordReportStatus.pending.value,
      createdAt: map['created_at'] as int?,
      updatedAt: map['updated_at'] as int?,
      extra: map['extra'] as String?,
    );
  }

  /// 转换为数据库映射
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (id != null) 'id': id,
      'session_id': sessionId,
      'source': source,
      'type': type,
      'type_id': typeId,
      'style_id': styleId,
      'dialect': dialect,
      'learn_type': learnType,
      'content_type': contentType,
      'content_id': contentId,
      'duration': duration,
      'started_at': startedAt,
      'last_active_at': lastActiveAt,
      'idle_started_at': idleStartedAt,
      'ended_at': endedAt,
      'accumulated_active_ms': accumulatedActiveMs,
      'report_status': reportStatus,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'extra': extra,
    };
  }

  /// 转换为上报映射
  Map<String, dynamic> toReportMap() {
    return <String, dynamic>{
      'sessionId': sessionId,
      'source': source,
      'type': type,
      'typeId': typeId,
      'styleId': styleId,
      'dialect': dialect,
      'learnType': learnType,
      'contentType': contentType,
      'contentId': contentId,
      'duration': duration,
      'startedAt': startedAt,
      'lastActiveAt': lastActiveAt,
      'endedAt': endedAt,
      'engagementSeconds': engagementSeconds,
      if (extra != null) 'extra': extra,
    };
  }

  /// 复制当前模型并覆盖指定字段
  InteractionRecordModel copyWith({
    int? id,
    String? sessionId,
    String? source,
    String? type,
    int? typeId,
    int? styleId,
    String? dialect,
    String? learnType,
    String? contentType,
    int? contentId,
    double? duration,
    int? startedAt,
    Object? lastActiveAt = _nullSentinel,
    Object? idleStartedAt = _nullSentinel,
    Object? endedAt = _nullSentinel,
    int? accumulatedActiveMs,
    String? reportStatus,
    int? createdAt,
    int? updatedAt,
    Object? extra = _nullSentinel,
  }) {
    return InteractionRecordModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      source: source ?? this.source,
      type: type ?? this.type,
      typeId: typeId ?? this.typeId,
      styleId: styleId ?? this.styleId,
      dialect: dialect ?? this.dialect,
      learnType: learnType ?? this.learnType,
      contentType: contentType ?? this.contentType,
      contentId: contentId ?? this.contentId,
      duration: duration ?? this.duration,
      startedAt: startedAt ?? this.startedAt,
      lastActiveAt: identical(lastActiveAt, _nullSentinel) ? this.lastActiveAt : lastActiveAt as int?,
      idleStartedAt: identical(idleStartedAt, _nullSentinel) ? this.idleStartedAt : idleStartedAt as int?,
      endedAt: identical(endedAt, _nullSentinel) ? this.endedAt : endedAt as int?,
      accumulatedActiveMs: accumulatedActiveMs ?? this.accumulatedActiveMs,
      reportStatus: reportStatus ?? this.reportStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      extra: identical(extra, _nullSentinel) ? this.extra : extra as String?,
    );
  }

  /// 获取交互时长秒数
  double get engagementSeconds {
    return accumulatedActiveMs / 1000.0;
  }

  /// 获取上报状态枚举
  InteractionRecordReportStatus get reportStatusEnum {
    return InteractionRecordReportStatus.fromValue(reportStatus);
  }

  /// 设置上报状态
  void setReportStatus(InteractionRecordReportStatus status) {
    reportStatus = status.value;
  }

  /// 判断是否需要上报
  bool get needsReport {
    return reportStatus == InteractionRecordReportStatus.pending.value ||
        reportStatus == InteractionRecordReportStatus.failed.value;
  }

  @override
  String toString() {
    return 'InteractionRecordModel('
        'id: $id, '
        'sessionId: $sessionId, '
        'source: $source, '
        'contentType: $contentType, '
        'contentId: $contentId, '
        'accumulatedActiveMs: $accumulatedActiveMs, '
        'reportStatus: $reportStatus'
        ')';
  }
}
