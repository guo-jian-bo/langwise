/// 交互时长模块常量定义
class InteractionRecordConstants {
  InteractionRecordConstants._();

  /// 交互记录表名
  static const String tableName = 'interaction_sessions';

  /// 默认 idle 缓冲秒数
  static const int defaultIdleGraceSeconds = 30;

  /// 默认高频指针事件节流毫秒数
  static const int defaultPointerThrottleMs = 1000;

  /// 默认待清理数据保留天数
  static const int maxRetentionDays = 7;

  /// 默认最大记录条数
  static const int maxRecordCount = 1000;
}

/// 交互记录上报状态枚举
enum InteractionRecordReportStatus {
  /// 待上报
  pending('pending'),

  /// 上报失败
  failed('failed'),

  /// 上报成功
  success('success');

  /// 状态值
  final String value;

  /// 创建状态枚举
  const InteractionRecordReportStatus(this.value);

  /// 根据状态值获取枚举
  static InteractionRecordReportStatus fromValue(String? value) {
    return InteractionRecordReportStatus.values.firstWhere(
      (InteractionRecordReportStatus item) => item.value == value,
      orElse: () => InteractionRecordReportStatus.pending,
    );
  }
}

/// 交互会话状态枚举
enum InteractionSessionState {
  /// 未开始或已结束
  inactive,

  /// 正在累计活跃时长
  active,

  /// 已进入 idle 缓冲阶段
  idleGrace,

  /// 已被页面失活或系统状态挂起
  suspended,
}

/// 交互信号类型枚举
enum InteractionSignal {
  /// 泛化用户交互
  user,

  /// 鼠标移动
  mouseMove,

  /// 单击
  tap,

  /// 双击
  doubleTap,

  /// 长按
  longPress,

  /// 拖动
  drag,

  /// 滚动
  scroll,

  /// 触摸
  touch,

  /// 播放持续活跃
  playbackActive,

  /// 播放暂停
  playbackPaused,

  /// 播放完成
  playbackCompleted,

  /// 自动切歌或自动行为
  autoSwitch,

  /// 播放器弹层显示
  popupVisible,
}
