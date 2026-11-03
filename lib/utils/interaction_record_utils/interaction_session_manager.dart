import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../log_utils/error_log_utils.dart';
import 'interaction_player_adapter.dart';
import 'interaction_record_constants.dart';
import 'interaction_record_database.dart';
import 'interaction_record_model.dart';

/// 交互会话配置
class InteractionSessionConfig {
  /// 是否允许后台继续累计
  final bool allowBackgroundActive;

  /// 是否允许锁屏继续累计
  final bool allowLockScreenActive;

  /// 路由完全覆盖时是否立即失活
  final bool routeCoveredAsInactive;

  /// 是否将持续播放视为活跃
  final bool countContinuousPlaybackAsActive;

  /// idle 缓冲秒数
  final int idleGraceSeconds;

  /// 指针事件节流毫秒数
  final int pointerThrottleMs;

  /// 创建交互会话配置
  const InteractionSessionConfig({
    this.allowBackgroundActive = false,
    this.allowLockScreenActive = false,
    this.routeCoveredAsInactive = true,
    this.countContinuousPlaybackAsActive = true,
    this.idleGraceSeconds = InteractionRecordConstants.defaultIdleGraceSeconds,
    this.pointerThrottleMs = InteractionRecordConstants.defaultPointerThrottleMs,
  });
}

/// 交互会话开始参数
class InteractionSessionStartParams {
  /// 页面宿主对象
  final Object? owner;

  /// 播放器适配器
  final InteractionPlayerAdapter? playerAdapter;

  /// 会话 ID
  final String sessionId;

  /// 来源标识
  final String? source;

  /// 页面类型
  final String? type;

  /// 页面类型 ID
  final int? typeId;

  /// 风格 ID
  final int? styleId;

  /// 方言
  final String? dialect;

  /// 学习类型
  final String? learnType;

  /// 内容类型
  final String contentType;

  /// 内容 ID
  final int contentId;

  /// 资源总时长
  final double duration;

  /// 会话配置
  final InteractionSessionConfig config;

  /// 创建交互会话开始参数
  const InteractionSessionStartParams({
    this.owner,
    this.playerAdapter,
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
    this.config = const InteractionSessionConfig(),
  });
}

/// 当前交互会话快照
class InteractionSessionSnapshot {
  /// 会话 ID
  final String sessionId;

  /// 当前会话状态
  final InteractionSessionState state;

  /// 当前是否持续播放中
  final bool isPlaybackActive;

  /// 当前是否允许后台继续累计
  final bool isBackgroundAllowed;

  /// 当前累计活跃毫秒数
  final int accumulatedActiveMs;

  /// 最近活跃时间戳
  final int? lastActiveAt;

  /// idle 开始时间戳
  final int? idleStartedAt;

  /// 创建交互会话快照
  const InteractionSessionSnapshot({
    required this.sessionId,
    required this.state,
    required this.isPlaybackActive,
    required this.isBackgroundAllowed,
    required this.accumulatedActiveMs,
    this.lastActiveAt,
    this.idleStartedAt,
  });

  /// 获取当前快照的交互时长秒数
  double get engagementSeconds {
    return accumulatedActiveMs / 1000;
  }
}

/// 交互会话管理器
class InteractionSessionManager {
  /// 上报时长对齐允许的最大误差秒数。
  /// 仅用于消除播放器元数据时长与实时计时之间的小数级尾差，
  /// 避免正常播放结束时 `learned` 比 `played` 少几百毫秒。
  static const double _reportAlignmentToleranceSeconds = 1.0;

  /// 异常上报时长日志阈值，超过 30 分钟时记录一次聚合日志。
  static const double _abnormalReportLogThresholdSeconds = 1800.0;

  /// 创建单例交互会话管理器
  InteractionSessionManager._internal();

  /// 单例交互会话管理器实例
  static final InteractionSessionManager _instance =
      InteractionSessionManager._internal();

  /// 获取交互会话管理器实例
  static InteractionSessionManager get instance => _instance;

  /// 详细调试日志默认关闭，避免高频事件刷屏。
  void _log(String _) {}

  /// 输出关键交互会话日志，仅保留排查问题所需的核心状态。
  void _logKeyEvent(String event, [String? details]) {
    final String detailText =
        details == null || details.isEmpty ? '' : ' | $details';
    debugPrint('[InteractionSessionManager][$event]$detailText');
  }

  /// 创建新的交互会话 ID，供交互记录与播放记录共享。
  String createSessionId() {
    return const Uuid().v4();
  }

  /// 判断当前交互信号是否属于高频信号。
  bool _isHighFrequencySignal(InteractionSignal signal) {
    return signal == InteractionSignal.user ||
        signal == InteractionSignal.drag ||
        signal == InteractionSignal.scroll ||
        signal == InteractionSignal.touch;
  }

  /// 获取当前宿主对象
  Object? get currentOwner => _currentOwner;

  /// 当前数据库记录 ID
  int? _currentRecordId;

  /// 当前会话 ID
  String? _currentSessionId;

  /// 当前来源标识
  String? _currentSource;

  /// 当前宿主对象
  Object? _currentOwner;

  /// 当前交互记录
  InteractionRecordModel? _currentRecord;

  /// 当前会话状态
  InteractionSessionState _state = InteractionSessionState.inactive;

  /// 当前是否处于持续播放状态
  bool _isPlaybackActive = false;

  /// 当前配置
  InteractionSessionConfig _config = const InteractionSessionConfig();

  /// 当前播放器适配器
  InteractionPlayerAdapter? _playerAdapter;

  /// 播放状态订阅
  StreamSubscription<bool>? _playingSub;

  /// 播放进度订阅
  StreamSubscription<Duration>? _positionSub;

  /// active 段开始时间
  int? _activeSegmentStartedAt;

  /// 最近一次高频指针信号时间
  int? _lastPointerSignalAt;

  /// 最近一次用于播放活跃兜底的心跳时间
  int? _lastPlaybackHeartbeatAt;

  /// 最近一次观察到的播放进度
  Duration? _lastObservedPlaybackPosition;

  /// 用户交互停止探测计时器
  Timer? _interactionSettleTimer;

  /// idle 冻结计时器
  Timer? _idleFreezeTimer;

  /// 最近一次取消交互沉淀计时器的原因
  String? _pendingInteractionSettleCancelReason;

  /// 最近一次取消 idle 30 秒等待的原因
  String? _pendingIdleFreezeCancelReason;

  /// 数据库是否已初始化
  bool _isDatabaseInitialized = false;

  /// 已记录过异常上报日志的会话 ID，避免重复刷日志。
  final Set<String> _abnormalReportLoggedSessionIds = <String>{};

  /// 最近一次会话内的关键操作轨迹，用于定位异常放大的触发链路。
  final List<String> _recentOperationTraces = <String>[];

  /// 启动交互会话
  Future<void> startSession(InteractionSessionStartParams params) async {
    if (_currentSessionId == params.sessionId &&
        _state != InteractionSessionState.inactive) {
      _log(
        '跳过启动会话，当前相同会话已在运行：'
        'sessionId=${params.sessionId}',
      );
      return;
    }

    if (_currentSessionId != null) {
      _log(
        '启动会话时检测到已有活动会话，先停止当前会话：'
        'sessionId=$_currentSessionId',
      );
      await stopSession(finalizeIdleGrace: true);
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    _config = params.config;
    _currentOwner = params.owner;
    _currentSessionId = params.sessionId;
    _currentSource = params.source;
    _isPlaybackActive = params.config.countContinuousPlaybackAsActive;
    _state = InteractionSessionState.active;
    _activeSegmentStartedAt = now;
    _lastPointerSignalAt = null;
    _recentOperationTraces.clear();
    _rememberOperation(
      'startSession(source=${params.source}, type=${params.type}, '
      'typeId=${params.typeId}, styleId=${params.styleId}, '
      'dialect=${params.dialect}, learnType=${params.learnType}, '
      'contentType=${params.contentType}, contentId=${params.contentId}, '
      'duration=${params.duration})',
      now: now,
    );

    _currentRecord = InteractionRecordModel(
      sessionId: params.sessionId,
      source: params.source,
      type: params.type,
      typeId: params.typeId,
      styleId: params.styleId,
      dialect: params.dialect,
      learnType: params.learnType,
      contentType: params.contentType,
      contentId: params.contentId,
      duration: params.duration,
      startedAt: now,
      lastActiveAt: now,
      accumulatedActiveMs: 0,
      reportStatus: InteractionRecordReportStatus.pending.value,
    );

    await _ensureDatabaseInitialized();
    _currentRecordId = await InteractionRecordDatabase.instance.insert(
      _currentRecord!,
    );

    _bindPlayerAdapter(params.playerAdapter);

    _logKeyEvent(
      '开始追踪',
      'sessionId=$_currentSessionId, '
      'dbId=$_currentRecordId, '
      'source=$_currentSource, '
      'contentType=${params.contentType}, '
      'contentId=${params.contentId}',
    );
  }

  /// 停止交互会话
  Future<void> stopSession({
    String? source,
    String? sessionId,
    bool finalizeIdleGrace = true,
  }) async {
    if (_currentRecord == null) {
      _log('跳过停止会话，当前没有活动中的交互记录');
      return;
    }

    if (source != null && _currentSource != source) {
      _log(
        '跳过停止会话，来源不匹配：source=$source, current=$_currentSource',
      );
      return;
    }
    if (sessionId != null && _currentSessionId != sessionId) {
      _log(
        '跳过停止会话，会话 ID 不匹配：sessionId=$sessionId, current=$_currentSessionId',
      );
      return;
    }

    _log(
      '开始停止会话，sessionId=$_currentSessionId, '
      'state=$_state, finalizeIdleGrace=$finalizeIdleGrace',
    );

    final int now = DateTime.now().millisecondsSinceEpoch;

    _cancelAllTimers();
    _flushActiveSegment(now);

    int finalActiveMs = _currentRecord!.accumulatedActiveMs;
    if (_state == InteractionSessionState.idleGrace && finalizeIdleGrace) {
      finalActiveMs += _computeIdleGraceMs(now);
    }

    _currentRecord = _currentRecord!.copyWith(
      accumulatedActiveMs: finalActiveMs,
      endedAt: now,
      updatedAt: now,
    );

    if (_currentRecordId != null) {
      await _ensureDatabaseInitialized();
      await InteractionRecordDatabase.instance.updateRecord(
        _currentRecordId!,
        lastActiveAt: _currentRecord!.lastActiveAt,
        idleStartedAt: _currentRecord!.idleStartedAt,
        endedAt: _currentRecord!.endedAt,
        accumulatedActiveMs: _currentRecord!.accumulatedActiveMs,
        reportStatus: _currentRecord!.reportStatus,
        extra: _currentRecord!.extra,
        updatedAt: _currentRecord!.updatedAt,
      );
    }

    _log(
      '会话已停止，'
      'sessionId=$_currentSessionId, '
      'engagement=${_currentRecord!.engagementSeconds}, '
      'state=$_state',
    );

    _resetRuntimeState();
  }

  /// 切换到下一个交互会话
  Future<void> switchSession({
    required InteractionSessionStartParams next,
    bool finalizeCurrent = true,
  }) async {
    _log(
      '开始切换会话，currentSessionId=$_currentSessionId, nextSessionId=${next.sessionId}',
    );
    await stopSession(finalizeIdleGrace: finalizeCurrent);
    await startSession(next);
  }

  /// 通知用户交互
  void notifyUserInteraction([
    InteractionSignal signal = InteractionSignal.user,
  ]) {
    if (_currentRecord == null) {
      _log('跳过用户交互通知，当前没有活动中的交互记录');
      return;
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    final bool isHighFrequencySignal = _isHighFrequencySignal(signal);
    if (_shouldThrottleSignal(signal, now)) return;
    _rememberOperation('userInteraction(signal=$signal, state=$_state)', now: now);

    if (!isHighFrequencySignal) {
      _log(
        '收到用户交互信号：'
        'signal=$signal, sessionId=$_currentSessionId, state=$_state',
      );
    }

    if (_idleFreezeTimer != null) {
      _pendingIdleFreezeCancelReason =
          'userInteraction(signal=$signal, state=$_state)';
      _logKeyEvent(
        '取消30s等待',
        'sessionId=$_currentSessionId, '
        'reason=$_pendingIdleFreezeCancelReason, '
        'engagement=${getCurrentEngagementSeconds().toStringAsFixed(3)}',
      );
    }
    _cancelIdleFreezeTimer();

    if (_state != InteractionSessionState.active) {
      _enterActive(now);
    } else {
      _updateLastActive(now);
    }

    if (!_isPlaybackActive) {
      _restartInteractionSettleTimer();
    }
  }

  /// 通知播放器进入持续播放
  void notifyPlaybackActive() {
    if (_currentRecord == null) {
      _log('跳过播放中通知，当前没有活动中的交互记录');
      return;
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    final InteractionSessionState previousState = _state;
    final bool wasPlaybackActive = _isPlaybackActive;
    _rememberOperation('playbackActive(previousState=$_state)', now: now);
    _isPlaybackActive = true;
    if (_interactionSettleTimer != null) {
      _pendingInteractionSettleCancelReason =
          'playbackActive(previousState=$previousState)';
    }
    if (_idleFreezeTimer != null) {
      _pendingIdleFreezeCancelReason =
          'playbackActive(previousState=$previousState)';
      _logKeyEvent(
        '取消30s等待',
        'sessionId=$_currentSessionId, '
        'reason=$_pendingIdleFreezeCancelReason, '
        'engagement=${getCurrentEngagementSeconds().toStringAsFixed(3)}',
      );
    }
    _cancelInteractionSettleTimer();
    _cancelIdleFreezeTimer();

    if (!wasPlaybackActive || previousState != InteractionSessionState.active) {
      _logKeyEvent(
        '恢复',
        'sessionId=$_currentSessionId, '
        'previousState=$previousState, '
        'engagement=${getCurrentEngagementSeconds().toStringAsFixed(3)}',
      );
    }

    if (_state != InteractionSessionState.active) {
      _enterActive(now);
      return;
    }

    _updateLastActive(now);
  }

  /// 通知播放器暂停
  void notifyPlaybackPaused() {
    if (_currentRecord == null) {
      _log('跳过播放暂停通知，当前没有活动中的交互记录');
      return;
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    _rememberOperation('playbackPaused(previousState=$_state)', now: now);
    _logKeyEvent(
      '暂停',
      'sessionId=$_currentSessionId, '
      'previousState=$_state, '
      'engagement=${getCurrentEngagementSeconds().toStringAsFixed(3)}',
    );
    _isPlaybackActive = false;
    _updateLastActive(now);
    _restartInteractionSettleTimer();
  }

  /// 通知播放器自然播放完成
  void notifyPlaybackCompleted() {
    if (_currentRecord == null) {
      _log('跳过播放完成通知，当前没有活动中的交互记录');
      return;
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    _rememberOperation('playbackCompleted(previousState=$_state)', now: now);
    _log(
      '收到播放完成通知，sessionId=$_currentSessionId, previousState=$_state',
    );
    _isPlaybackActive = false;
    _updateLastActive(now);
    _restartInteractionSettleTimer();
  }

  /// 通知播放器弹层可见性变化
  void notifyPopupVisibilityChanged(bool visible) {
    _log(
      '收到弹层显隐变化：visible=$visible, sessionId=$_currentSessionId',
    );
    if (!visible) return;
    notifyUserInteraction(InteractionSignal.popupVisible);
  }

  /// 通知路由被完整覆盖
  void notifyRouteCovered() {
    if (_currentRecord == null) {
      _log('跳过路由覆盖通知，当前没有活动中的交互记录');
      return;
    }
    if (!_config.routeCoveredAsInactive) {
      _log(
        '忽略路由覆盖通知，当前配置要求保持会话活跃：sessionId=$_currentSessionId',
      );
      return;
    }
    _rememberOperation('routeCovered(state=$_state)');
    if (_idleFreezeTimer != null) {
      _pendingIdleFreezeCancelReason = 'routeCovered(state=$_state)';
    }
    if (_interactionSettleTimer != null) {
      _pendingInteractionSettleCancelReason = 'routeCovered(state=$_state)';
    }
    _enterSuspended();
  }

  /// 通知应用进入后台
  void notifyAppBackground() {
    if (_currentRecord == null) {
      _log('跳过应用后台通知，当前没有活动中的交互记录');
      return;
    }
    if (_config.allowBackgroundActive && (_isPlaybackActive || _state == InteractionSessionState.idleGrace)) {
      
      _log(
        '根据配置在后台保持会话活跃：sessionId=$_currentSessionId',
      );
      return;
    }
    _rememberOperation('appBackground(state=$_state, playback=$_isPlaybackActive)');
    if (_idleFreezeTimer != null) {
      _pendingIdleFreezeCancelReason =
          'appBackground(state=$_state, playback=$_isPlaybackActive)';
    }
    if (_interactionSettleTimer != null) {
      _pendingInteractionSettleCancelReason =
          'appBackground(state=$_state, playback=$_isPlaybackActive)';
    }
    _enterSuspended();
  }

  /// 通知应用回到前台
  void notifyAppForeground() {
    if (_currentRecord == null) {
      _log('跳过应用前台通知，当前没有活动中的交互记录');
      return;
    }
    if (_state != InteractionSessionState.suspended) {
      _log(
        '忽略应用前台通知，当前会话并非挂起状态：'
        'sessionId=$_currentSessionId, state=$_state',
      );
      return;
    }
    _logKeyEvent(
      '恢复挂起',
      'sessionId=$_currentSessionId, '
      'isPlaybackActive=$_isPlaybackActive, '
      'engagement=${getCurrentEngagementSeconds().toStringAsFixed(3)}',
    );
    _rememberOperation('appForeground(state=$_state, playback=$_isPlaybackActive)');
    if (_isPlaybackActive) {
      _enterActive(DateTime.now().millisecondsSinceEpoch);
    }
  }

  /// 获取当前交互时长秒数
  double getCurrentEngagementSeconds({
    String? sessionId,
    bool includeIdleGrace = true,
  }) {
    if (_currentRecord == null) return 0;
    if (sessionId != null && _currentSessionId != sessionId) return 0;

    final int now = DateTime.now().millisecondsSinceEpoch;
    int totalMs = _currentRecord!.accumulatedActiveMs;

    if (_state == InteractionSessionState.active &&
        _activeSegmentStartedAt != null) {
      totalMs += max(0, now - _activeSegmentStartedAt!);
    }

    if (_state == InteractionSessionState.idleGrace && includeIdleGrace) {
      totalMs += _computeIdleGraceMs(now);
    }

    return totalMs / 1000.0;
  }

  /// 获取当前会话快照
  InteractionSessionSnapshot? getCurrentSnapshot() {
    if (_currentRecord == null || _currentSessionId == null) return null;

    return InteractionSessionSnapshot(
      sessionId: _currentSessionId!,
      state: _state,
      isPlaybackActive: _isPlaybackActive,
      isBackgroundAllowed: _config.allowBackgroundActive,
      accumulatedActiveMs: (getCurrentEngagementSeconds() * 1000).round(),
      lastActiveAt: _currentRecord!.lastActiveAt,
      idleStartedAt: _currentRecord!.idleStartedAt,
    );
  }

  /// 根据会话 ID 查询交互记录
  Future<InteractionRecordModel?> getRecordBySessionId(String sessionId) async {
    if (_currentSessionId == sessionId && _currentRecord != null) {
      return _currentRecord!.copyWith(
        accumulatedActiveMs: (getCurrentEngagementSeconds(sessionId: sessionId) * 1000).round(),
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
    }

    await _ensureDatabaseInitialized();
    return InteractionRecordDatabase.instance.getBySessionId(sessionId);
  }

  /// 根据会话 ID 获取上报字段
  Future<Map<String, dynamic>?> getReportPayloadBySessionId(
    String sessionId, {
    double? minimumEngagementSeconds,
  }) async {
    final InteractionRecordModel? record = await getRecordBySessionId(sessionId);
    if (record == null) return null;

    // 上报时长对齐允许的最大误差秒数。
    double engagementSeconds = record.engagementSeconds;
    if (minimumEngagementSeconds != null) {
      final double gapSeconds = minimumEngagementSeconds - engagementSeconds;
      final bool shouldAlignToMinimum = gapSeconds > 0 && gapSeconds <= _reportAlignmentToleranceSeconds && _currentSessionId == sessionId;
      if (shouldAlignToMinimum) {
        _log(
          '上报前对齐交互时长：'
          'sessionId=$sessionId, engagementSeconds=$engagementSeconds, '
          'minimumEngagementSeconds=$minimumEngagementSeconds, gapSeconds=$gapSeconds',
        );
        engagementSeconds = minimumEngagementSeconds;
      }
    }
    await _logAbnormalReportPayloadIfNeeded(
      sessionId: sessionId,
      record: record,
      engagementSeconds: engagementSeconds,
      minimumEngagementSeconds: minimumEngagementSeconds,
    );
    _logKeyEvent(
      '上报',
      'sessionId=$sessionId, '
      'engagementSeconds=${engagementSeconds.toStringAsFixed(3)}, '
      'minimumEngagementSeconds=${minimumEngagementSeconds?.toStringAsFixed(3)}, '
      'state=${_currentSessionId == sessionId ? _state : InteractionSessionState.inactive}',
    );

    return <String, dynamic>{
      'engagementSeconds': engagementSeconds,
    };
  }

  /// 根据会话 ID 标记交互记录上报成功
  Future<void> markReportedSuccessBySessionId(String sessionId) async {
    await _markReportedBySessionId(
      sessionId,
      InteractionRecordReportStatus.success,
    );
  }

  /// 根据会话 ID 标记交互记录上报失败
  Future<void> markReportedFailedBySessionId(String sessionId) async {
    await _markReportedBySessionId(
      sessionId,
      InteractionRecordReportStatus.failed,
    );
  }

  /// 预处理待上报交互记录
  Future<void> retryPendingRecords() async {
    await _ensureDatabaseInitialized();
    await InteractionRecordDatabase.instance.performCleanup();
    final List<InteractionRecordModel> records =
        await InteractionRecordDatabase.instance.getPendingRecords();
    _log(
      '清理后待上报交互记录数量：${records.length}',
    );
  }

  /// 释放管理器资源
  void dispose() {
    _log('释放交互会话管理器资源');
    _cancelAllTimers();
    _playingSub?.cancel();
    _playerAdapter?.dispose();
    _resetRuntimeState();
  }

  /// 确保数据库已初始化
  Future<void> _ensureDatabaseInitialized() async {
    if (_isDatabaseInitialized) return;
    await InteractionRecordDatabase.instance.initialize();
    _isDatabaseInitialized = true;
    _log('交互数据库初始化完成');
  }

  /// 绑定播放器适配器并监听播放状态
  void _bindPlayerAdapter(InteractionPlayerAdapter? adapter) {
    _log(
      '绑定播放器适配器，hasAdapter=${adapter != null}, sessionId=$_currentSessionId',
    );
    _playingSub?.cancel();
    _positionSub?.cancel();
    _playerAdapter?.dispose();
    _playerAdapter = adapter;
    _lastPlaybackHeartbeatAt = null;
    _lastObservedPlaybackPosition = null;
    if (adapter == null) return;

    _playingSub = adapter.playingStream.distinct().listen((bool isPlaying) {
      _log(
        '播放器适配器发出播放状态：isPlaying=$isPlaying, sessionId=$_currentSessionId',
      );
      if (isPlaying) {
        notifyPlaybackActive();
      } else {
        notifyPlaybackPaused();
      }
    });

    final Stream<Duration>? positionStream = adapter.positionStream;
    if (positionStream == null) return;
    _positionSub = positionStream.listen(_handlePlaybackProgress);
  }

  /// 使用播放器进度推进作为“持续播放中”的统一兜底信号。
  /// 只要进度持续向前，每秒最多触发一次活跃心跳，避免某些播放器页面
  /// 漏发 `playing=true` 时交互时长只能累计到最后一次手动操作附近。
  void _handlePlaybackProgress(Duration position) {
    if (_currentRecord == null) return;
    if (position <= Duration.zero) return;

    final Duration? previousPosition = _lastObservedPlaybackPosition;
    _lastObservedPlaybackPosition = position;
    if (previousPosition != null && position <= previousPosition) {
      return;
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    if (_lastPlaybackHeartbeatAt != null &&
        now - _lastPlaybackHeartbeatAt! < 1000) {
      return;
    }
    _lastPlaybackHeartbeatAt = now;

    if (!_isPlaybackActive &&
        _state != InteractionSessionState.suspended &&
        _state != InteractionSessionState.inactive) {
      return;
    }

    final InteractionSessionState previousState = _state;
    final bool wasPlaybackActive = _isPlaybackActive;

    _isPlaybackActive = true;
    _cancelInteractionSettleTimer();
    _cancelIdleFreezeTimer();
    if (!wasPlaybackActive || previousState != InteractionSessionState.active) {
      _logKeyEvent(
        '恢复',
        'sessionId=$_currentSessionId, '
        'positionMs=${position.inMilliseconds}, '
        'previousState=$previousState, '
        'engagement=${getCurrentEngagementSeconds().toStringAsFixed(3)}',
      );
    }
    if (_state != InteractionSessionState.active) {
      _enterActive(now);
      return;
    }
    _updateLastActive(now);
  }

  /// 判断当前交互信号是否需要节流
  bool _shouldThrottleSignal(InteractionSignal signal, int now) {
    final bool isHighFrequencySignal = _isHighFrequencySignal(signal);

    if (!isHighFrequencySignal) return false;

    if (_lastPointerSignalAt != null &&
        now - _lastPointerSignalAt! < _config.pointerThrottleMs) {
      return true;
    }

    _lastPointerSignalAt = now;
    return false;
  }

  /// 进入 active 状态
  void _enterActive(int now) {
    if (_currentRecord == null) return;

    _cancelInteractionSettleTimer();
    _cancelIdleFreezeTimer();

    final InteractionSessionState previousState = _state;
    _state = InteractionSessionState.active;
    _activeSegmentStartedAt = now;
    _currentRecord = _currentRecord!.copyWith(
      lastActiveAt: now,
      idleStartedAt: null,
      updatedAt: now,
    );
    _rememberOperation('enterActive(previousState=$previousState)', now: now);

    _log(
      '进入 active 状态：previousState=$previousState, sessionId=$_currentSessionId',
    );
    unawaited(_persistCurrentRecord());
  }

  /// 进入 idle 缓冲状态
  void _enterIdleGrace(int now) {
    if (_currentRecord == null) return;
    if (_isPlaybackActive) {
      _log(
        '跳过进入 idleGrace，播放仍处于活跃中：sessionId=$_currentSessionId',
      );
      return;
    }
    if (_state != InteractionSessionState.active) {
      _log(
        '跳过进入 idleGrace，当前状态不是 active：'
        'sessionId=$_currentSessionId, state=$_state',
      );
      return;
    }

    _flushActiveSegment(now);
    final InteractionSessionState previousState = _state;
    _state = InteractionSessionState.idleGrace;
    _currentRecord = _currentRecord!.copyWith(
      idleStartedAt: now,
      updatedAt: now,
    );
    _rememberOperation('enterIdleGrace(previousState=$previousState)', now: now);
    _logKeyEvent(
      '进入idleGrace',
      'sessionId=$_currentSessionId, '
      'previousState=$previousState, '
      'idleGraceSeconds=${_config.idleGraceSeconds}, '
      'engagement=${(_currentRecord!.accumulatedActiveMs / 1000.0).toStringAsFixed(3)}',
    );
    _restartIdleFreezeTimer();
    unawaited(_persistCurrentRecord());
  }

  /// 进入 suspended 状态
  void _enterSuspended() {
    if (_currentRecord == null) return;

    final int now = DateTime.now().millisecondsSinceEpoch;
    final String? idleFreezeCancelReason = _pendingIdleFreezeCancelReason;
    final String? interactionSettleCancelReason =
        _pendingInteractionSettleCancelReason;
    _cancelAllTimers();
    _flushActiveSegment(now);

    final InteractionSessionState previousState = _state;
    _state = InteractionSessionState.suspended;
    _currentRecord = _currentRecord!.copyWith(
      updatedAt: now,
    );
    _rememberOperation('enterSuspended(previousState=$previousState)', now: now);
    _logKeyEvent(
      '进入挂起',
      'sessionId=$_currentSessionId, '
      'previousState=$previousState, '
      'idleCancelReason=${idleFreezeCancelReason ?? '-'}, '
      'settleCancelReason=${interactionSettleCancelReason ?? '-'}, '
      'engagement=${getCurrentEngagementSeconds(includeIdleGrace: false).toStringAsFixed(3)}',
    );
    unawaited(_persistCurrentRecord());
  }

  /// 刷新最近活跃时间
  void _updateLastActive(int now) {
    if (_currentRecord == null) return;

    _currentRecord = _currentRecord!.copyWith(
      lastActiveAt: now,
      updatedAt: now,
    );
  }

  /// 将当前 active 时段落入累计值
  void _flushActiveSegment(int now) {
    if (_currentRecord == null) return;
    if (_state != InteractionSessionState.active) return;
    if (_activeSegmentStartedAt == null) return;

    final int deltaMs = max(0, now - _activeSegmentStartedAt!);
    _log(
      '结算 active 时段：deltaMs=$deltaMs, sessionId=$_currentSessionId',
    );
    _currentRecord = _currentRecord!.copyWith(
      accumulatedActiveMs: _currentRecord!.accumulatedActiveMs + deltaMs,
      updatedAt: now,
    );
    _activeSegmentStartedAt = null;
  }

  /// 计算当前 idle 可补偿的毫秒数
  int _computeIdleGraceMs(int now) {
    final int? idleStartedAt = _currentRecord?.idleStartedAt;
    if (idleStartedAt == null) return 0;

    final int graceMs = _config.idleGraceSeconds * 1000;
    return min(max(0, now - idleStartedAt), graceMs);
  }

  /// 启动用户交互停止探测计时器
  void _restartInteractionSettleTimer() {
    _cancelInteractionSettleTimer();
    if (_isPlaybackActive) {
      _log(
        '跳过启动交互沉淀计时器，播放处于活跃中：sessionId=$_currentSessionId',
      );
      return;
    }

    final DateTime now = DateTime.now();
    final DateTime expectedAt = now.add(
      Duration(milliseconds: _config.pointerThrottleMs),
    );
    _log(
      '启动交互沉淀计时器：'
      'pointerThrottleMs=${_config.pointerThrottleMs}, '
      'sessionId=$_currentSessionId, '
      'startAt=$now, expectedFireAt=$expectedAt',
    );
    _interactionSettleTimer = Timer(
      Duration(milliseconds: _config.pointerThrottleMs),
      () {
        _log('交互沉淀计时器触发，sessionId=$_currentSessionId');
        _enterIdleGrace(DateTime.now().millisecondsSinceEpoch);
      },
    );
  }

  /// 启动 idle 冻结计时器
  void _restartIdleFreezeTimer() {
    _cancelIdleFreezeTimer();

    final DateTime now = DateTime.now();
    final DateTime expectedAt = now.add(
      Duration(seconds: _config.idleGraceSeconds),
    );
    _log(
      '启动 idle 冻结计时器：'
      'idleGraceSeconds=${_config.idleGraceSeconds}, '
      'sessionId=$_currentSessionId, '
      'startAt=$now, expectedFireAt=$expectedAt',
    );
    _idleFreezeTimer = Timer(
      Duration(seconds: _config.idleGraceSeconds),
      () {
        _log('idle 冻结计时器触发，sessionId=$_currentSessionId');
        _freezeIdleGrace();
      },
    );
  }

  /// 在 idle 缓冲期结束后固化补偿时长
  void _freezeIdleGrace() {
    if (_currentRecord == null) return;
    if (_state != InteractionSessionState.idleGrace) {
      _log(
        '跳过冻结 idleGrace，当前状态不是 idleGrace：'
        'sessionId=$_currentSessionId, state=$_state',
      );
      return;
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    final int idleGraceMs = _computeIdleGraceMs(now);
    final InteractionSessionState previousState = _state;

    _activeSegmentStartedAt = null;
    _state = InteractionSessionState.suspended;
    _currentRecord = _currentRecord!.copyWith(
      accumulatedActiveMs: _currentRecord!.accumulatedActiveMs + idleGraceMs,
      idleStartedAt: null,
      updatedAt: now,
    );
    _rememberOperation(
      'freezeIdleGrace(previousState=$previousState, idleGraceMs=$idleGraceMs)',
      now: now,
    );
    _logKeyEvent(
      '达到挂起上限30s',
      'sessionId=$_currentSessionId, '
      'idleGraceMs=$idleGraceMs, '
      'engagement=${(_currentRecord!.accumulatedActiveMs / 1000.0).toStringAsFixed(3)}',
    );
    unawaited(_persistCurrentRecord());
  }

  /// 持久化当前交互记录
  Future<void> _persistCurrentRecord() async {
    if (_currentRecord == null || _currentRecordId == null) return;

    await _ensureDatabaseInitialized();
    _log(
      '持久化当前记录：sessionId=$_currentSessionId, '
      'dbId=$_currentRecordId, '
      'activeMs=${_currentRecord!.accumulatedActiveMs}, '
      'state=$_state',
    );
    await InteractionRecordDatabase.instance.updateRecord(
      _currentRecordId!,
      lastActiveAt: _currentRecord!.lastActiveAt,
      idleStartedAt: _currentRecord!.idleStartedAt,
      endedAt: _currentRecord!.endedAt,
      accumulatedActiveMs: _currentRecord!.accumulatedActiveMs,
      reportStatus: _currentRecord!.reportStatus,
      extra: _currentRecord!.extra,
      updatedAt: _currentRecord!.updatedAt,
    );
  }

  /// 根据会话 ID 更新上报状态
  Future<void> _markReportedBySessionId(
    String sessionId,
    InteractionRecordReportStatus status,
  ) async {
    await _ensureDatabaseInitialized();
    _log(
      '按会话 ID 更新上报状态：sessionId=$sessionId, status=${status.value}',
    );

    if (_currentSessionId == sessionId &&
        _currentRecordId != null &&
        _currentRecord != null) {
      _currentRecord!.setReportStatus(status);
      _currentRecord = _currentRecord!.copyWith(
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await InteractionRecordDatabase.instance.updateStatus(
        _currentRecordId!,
        status,
      );
      return;
    }

    final InteractionRecordModel? record =
        await InteractionRecordDatabase.instance.getBySessionId(sessionId);
    if (record?.id == null) return;

    await InteractionRecordDatabase.instance.updateStatus(record!.id!, status);
  }

  /// 取消用户交互停止探测计时器
  void _cancelInteractionSettleTimer() {
    _pendingInteractionSettleCancelReason = null;
    _interactionSettleTimer?.cancel();
    _interactionSettleTimer = null;
  }

  /// 取消 idle 冻结计时器
  void _cancelIdleFreezeTimer() {
    _pendingIdleFreezeCancelReason = null;
    _idleFreezeTimer?.cancel();
    _idleFreezeTimer = null;
  }

  /// 取消所有内部计时器
  void _cancelAllTimers() {
    _cancelInteractionSettleTimer();
    _cancelIdleFreezeTimer();
  }

  /// 记录最近关键操作，帮助定位异常时长是被哪类事件持续放大。
  void _rememberOperation(String operation, {int? now}) {
    final int timestamp = now ?? DateTime.now().millisecondsSinceEpoch;
    _recentOperationTraces.add('$timestamp:$operation');
    if (_recentOperationTraces.length > 12) {
      _recentOperationTraces.removeAt(0);
    }
  }

  /// 异常大交互时长仅记录一条聚合日志，避免重复刷屏。
  Future<void> _logAbnormalReportPayloadIfNeeded({
    required String sessionId,
    required InteractionRecordModel record,
    required double engagementSeconds,
    double? minimumEngagementSeconds,
  }) async {
    if (engagementSeconds <= _abnormalReportLogThresholdSeconds) return;
    if (!_abnormalReportLoggedSessionIds.add(sessionId)) return;

    final bool isCurrentSession = _currentSessionId == sessionId;
    final InteractionSessionSnapshot? snapshot =
        isCurrentSession ? getCurrentSnapshot() : null;
    final Map<String, dynamic> logPayload = <String, dynamic>{
      '会话ID': sessionId,
      '异常交互时长秒数': engagementSeconds,
      '最小对齐秒数': minimumEngagementSeconds,
      '异常阈值秒数': _abnormalReportLogThresholdSeconds,
      '是否当前会话': isCurrentSession,
      '播放信息': <String, dynamic>{
        '来源': record.source,
        '页面类型': record.type,
        '页面类型ID': record.typeId,
        '风格ID': record.styleId,
        '方言': record.dialect,
        '学习类型': record.learnType,
        '内容类型': record.contentType,
        '内容ID': record.contentId,
        '资源总时长': record.duration,
        '开始时间': record.startedAt,
        '最近活跃时间': record.lastActiveAt,
        'idle开始时间': record.idleStartedAt,
        '结束时间': record.endedAt,
        '累计活跃毫秒': record.accumulatedActiveMs,
        '上报状态': record.reportStatus,
        '更新时间': record.updatedAt,
      },
      '当前快照': snapshot == null
          ? null
          : <String, dynamic>{
              '状态': snapshot.state.name,
              '是否持续播放中': snapshot.isPlaybackActive,
              '是否允许后台累计': snapshot.isBackgroundAllowed,
              '当前累计活跃毫秒': snapshot.accumulatedActiveMs,
              '最近活跃时间': snapshot.lastActiveAt,
              'idle开始时间': snapshot.idleStartedAt,
            },
      '最近关键操作': isCurrentSession
          ? List<String>.from(_recentOperationTraces)
          : <String>[],
    };
    await ErrorLogUtils.to.logInfo(
      '[InteractionSessionManager] 检测到异常大的交互上报时长：${ErrorLogUtils.to.toSingleLineJsonSafe(logPayload)}',
    );
  }

  /// 重置当前运行时状态
  void _resetRuntimeState() {
    _log(
      '重置运行时状态：sessionId=$_currentSessionId, '
      'source=$_currentSource, state=$_state',
    );
    _playingSub?.cancel();
    _playingSub = null;
    _positionSub?.cancel();
    _positionSub = null;

    _playerAdapter?.dispose();
    _playerAdapter = null;

    _currentRecordId = null;
    _currentSessionId = null;
    _currentSource = null;
    _currentOwner = null;
    _currentRecord = null;
    _state = InteractionSessionState.inactive;
    _isPlaybackActive = false;
    _activeSegmentStartedAt = null;
    _lastPointerSignalAt = null;
    _lastPlaybackHeartbeatAt = null;
    _lastObservedPlaybackPosition = null;
    _recentOperationTraces.clear();
  }
}
