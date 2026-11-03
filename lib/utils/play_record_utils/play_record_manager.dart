import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../../common/enum/enum.dart';
import '../../common/https/https.dart';
import '../../common/public_controller/manage_sandbox_controller.dart';
import '../audio_playback_utils.dart';
import '../interaction_record_utils/interaction_record_utils.dart';
import 'play_record_constants.dart';
import 'play_record_database.dart';
import 'play_record_model.dart';

/// 播放记录管理器（单例）
class PlayRecordManager {
  PlayRecordManager._internal();
  static final PlayRecordManager _instance = PlayRecordManager._internal();
  static PlayRecordManager get instance => _instance;

  /// 当前追踪会话 ID，只读暴露给协同模块使用
  String? get currentSessionId => _currentSessionId;

  /// 当前追踪的音频播放工具
  AudioPlaybackUtils? _audioPlaybackUtils;
  /// 当前追踪的播放器（非 AudioPlaybackUtils 场景）
  Player? _player;
  /// 当前追踪播放器的位置缓存
  Duration _playerPosition = Duration.zero;
  /// 播放器位置监听
  StreamSubscription<Duration>? _playerPositionSub;

  /// 当前追踪的记录模型
  PlayRecordModel? _currentRecord;

  /// 当前追踪源标识
  String? _currentSource;

  /// 当前会话ID
  String? _currentSessionId;

  /// 追踪开始时间（毫秒）- 预留字段，用于后期扩展
  // ignore: unused_field
  int? _trackingStartTime;

  /// 是否正在追踪
  bool _isTracking = false;

  /// 当前记录的数据库ID
  int? _currentRecordId;

  /// 数据库是否已初始化
  bool _isDatabaseInitialized = false;

  /// 初始化数据库
  Future<void> _ensureDatabaseInitialized() async {
    if (_isDatabaseInitialized) return;
    await PlayRecordDatabase.instance.initialize();
    _isDatabaseInitialized = true;
  }

  /// 开始追踪播放记录
  /// [audioPlaybackUtils] 音频播放工具实例
  /// [player] 通用播放器实例（如 zhendu_look 的 Player）
  /// [type] 类型: unit, favorite, collection, none
  /// [typeId] 关联ID
  /// [contentType] 内容类型
  /// [contentId] 内容ID
  /// [duration] 总时长（秒）
  /// [source] 追踪源标识，用于区分不同控制器
  /// [lastPlayedSeconds] 上一首的播放时长（秒），切换歌曲时传入
  /// [sessionId] 外部传入的会话 ID，用于与交互记录共用同一会话
  Future<void> startTracking({
    AudioPlaybackUtils? audioPlaybackUtils,
    Player? player,
    String? type,
    int? typeId,
    int? styleId,
    String? dialect,
    ZhenduPageTypeEnum? learnType,
    required String contentType,
    required int contentId,
    required double duration,
    String? source,
    double? lastPlayedSeconds,
    String? sessionId,
  }) async {
    if (audioPlaybackUtils == null && player == null) {
      debugPrint('[PlayRecordManager] startTracking 缺少播放器实例，跳过追踪');
      return;
    }

    // 如果已经在追踪同一个内容，不重复开始
    if (_isTracking && 
        _currentRecord?.contentId == contentId && 
        _currentRecord?.contentType == contentType) {
      debugPrint('[PlayRecordManager] 已在追踪相同内容，跳过');
      return;
    }

    // 如果正在追踪其他内容，先按切歌场景结束旧追踪
    if (_isTracking) {
      await _reportAndReset(
        triggerType: PlayRecordTriggerType.switchSong,
        playedSeconds: lastPlayedSeconds,
      );
    }

    // 生成新的会话ID，默认内部生成，也支持外部透传用于和交互记录共用。
    _currentSessionId = sessionId ?? const Uuid().v4();
    _trackingStartTime = DateTime.now().millisecondsSinceEpoch;

    // 创建新的记录模型
    _currentRecord = PlayRecordModel(
      sessionId: _currentSessionId,
      type: type,
      typeId: typeId,
      styleId: styleId,
      dialect: dialect,
      learnType: learnType?.value,
      contentType: contentType,
      contentId: contentId,
      played: 0,
      duration: duration,
    );

    _audioPlaybackUtils = audioPlaybackUtils;
    _player = player;
    _playerPosition = Duration.zero;
    _currentSource = source;
    _isTracking = true;

    // 插入数据库（pending状态，构造函数默认值已是pending）
    await _ensureDatabaseInitialized();
    _currentRecordId = await PlayRecordDatabase.instance.insert(_currentRecord!);
    debugPrint('[PlayRecordManager] 追踪已开始, sessionId=$_currentSessionId, dbId=$_currentRecordId, status=${_currentRecord!.reportStatus}');

    _playerPositionSub?.cancel();
    if (player != null) {
      _playerPositionSub = player.stream.position.listen((event) {
        _playerPosition = event;
      });
    }
  }

  /// 停止追踪（控制器销毁或退出播放器时调用）
  /// [source] 可选，指定要停止的追踪源，只有匹配时才停止
  Future<void> stopTracking({String? source}) async {
    debugPrint('[PlayRecordManager] 停止追踪请求: source=$source, currentSource=$_currentSource');

    // 如果指定了 source，只有匹配时才停止
    if (source != null && _currentSource != source) {
      return;
    }

    if (!_isTracking) {
      return;
    }

    // 触发退出播放器上报
    await _reportAndReset(triggerType: PlayRecordTriggerType.exitPlayer);
  }

  /// 切换歌曲前结束当前播放追踪，并按切歌场景上报。
  /// [lastPlayedSeconds] 上一首的播放时长（秒）
  Future<void> switchTracking({
    String? source,
    double? lastPlayedSeconds,
  }) async {
    debugPrint(
      '[PlayRecordManager] 切歌追踪请求: '
      'source=$source, currentSource=$_currentSource, played=$lastPlayedSeconds',
    );

    if (source != null && _currentSource != source) {
      return;
    }

    if (!_isTracking) {
      return;
    }

    await _reportAndReset(
      triggerType: PlayRecordTriggerType.switchSong,
      playedSeconds: lastPlayedSeconds,
    );
  }

  /// 播放完成上报（由控制器在播放完成时调用）
  /// [playedSeconds] 已播放时长（秒）
  Future<void> reportPlayComplete(double playedSeconds) async {
    if (!_isTracking) {
      debugPrint('[PlayRecordManager] 未在追踪状态，跳过播放完成上报');
      return;
    }

    debugPrint('[PlayRecordManager] 播放完成上报: played=$playedSeconds');
    await _reportAndReset(
      triggerType: PlayRecordTriggerType.playComplete,
      playedSeconds: playedSeconds,
    );
  }

  /// 上报并重置状态。
  /// [playedSeconds] 为空时会自动读取当前播放位置。
  Future<void> _reportAndReset({
    required PlayRecordTriggerType triggerType,
    double? playedSeconds,
  }) async {
    if (_currentRecord == null) {
      _reset();
      return;
    }

    final double resolvedPlayedSeconds;
    if (playedSeconds != null) {
      resolvedPlayedSeconds = playedSeconds;
    } else {
      final position = await _getCurrentPosition();
      resolvedPlayedSeconds = position.inMilliseconds / 1000.0;
    }

    debugPrint('[PlayRecordManager] 准备上报: triggerType=${triggerType.value}, played=$resolvedPlayedSeconds');

    // 保存当前记录ID
    final record = _currentRecord!;
    final oldRecordId = _currentRecordId;

    // 检查是否满足最小播放时长
    if (resolvedPlayedSeconds < PlayRecordConstants.minValidPlaySeconds) {
      debugPrint('[PlayRecordManager] 播放时长不足 ${PlayRecordConstants.minValidPlaySeconds} 秒，删除记录');
      if (oldRecordId != null) {
        await PlayRecordDatabase.instance.delete(oldRecordId);
      }
      _reset();
      return;
    }

    final reportRecord = record.copyWith(
      played: resolvedPlayedSeconds,
      triggerType: triggerType.value,
    );

    // 完全重置状态
    _reset();

    // 执行上报（使用旧的recordId）
    await _doReport(reportRecord, recordId: oldRecordId);
  }

  /// 执行上报逻辑
  /// 更新数据库记录的播放时长和触发类型，然后上报
  Future<void> _doReport(PlayRecordModel record, {int? recordId}) async {
    debugPrint('[PlayRecordManager] 执行上报: ${record.toReportMap()}');

    await _ensureDatabaseInitialized();

    // 如果没有传入recordId，说明是切换歌曲等场景，需要新插入记录
    int? dbId = recordId;
    if (dbId == null) {
      // 构造函数默认值已是 pending
      dbId = await PlayRecordDatabase.instance.insert(record);
      if (dbId == null) {
        debugPrint('[PlayRecordManager] 插入数据库失败，跳过上报');
        return;
      }
      debugPrint('[PlayRecordManager] 已插入数据库, id=$dbId');
    } else {
      // 更新已有记录的播放时长和触发类型
      await PlayRecordDatabase.instance.updateRecord(
        dbId,
        played: record.played,
        triggerType: record.triggerType,
      );
      debugPrint('[PlayRecordManager] 已更新数据库记录, id=$dbId');
    }

    try {
      final Map<String, dynamic> slice = await _buildSliceWithInteraction(record);
      Map<String, dynamic> reqData = {
        "slices": [slice],
      };

      bool success = false;
      if(!ManageSandboxController.to.isSimulate){
        success = await SongRequest.reportPlayKnowledgeList(reqData);
      }else{
        success = true;
      }

      if (success) {
        debugPrint('[PlayRecordManager] 上报成功，更新状态为success');
        await PlayRecordDatabase.instance.updateStatus(dbId, PlayRecordReportStatus.success);
        await InteractionSessionManager.instance.markReportedSuccessBySessionId(
          record.sessionId,
        );
        
        // 尝试重试失败的记录
        retryFailedRecords();
      } else {
        // 上报失败，更新状态为failed
        debugPrint('[PlayRecordManager] 上报失败，更新状态为failed');
        await PlayRecordDatabase.instance.updateStatus(dbId, PlayRecordReportStatus.failed);
        await InteractionSessionManager.instance.markReportedFailedBySessionId(
          record.sessionId,
        );
      }
    } catch (e) {
      debugPrint('[PlayRecordManager] 上报异常: $e');
      // 异常时更新状态为failed
      await PlayRecordDatabase.instance.updateStatus(dbId, PlayRecordReportStatus.failed);
      await InteractionSessionManager.instance.markReportedFailedBySessionId(
        record.sessionId,
      );
    }
  }

  /// 重置追踪状态
  void _reset() {
    _playerPositionSub?.cancel();

    _audioPlaybackUtils = null;
    _player = null;
    _playerPosition = Duration.zero;
    _currentRecord = null;
    _currentRecordId = null;
    _currentSource = null;
    _currentSessionId = null;
    _trackingStartTime = null;
    _isTracking = false;

    debugPrint('[PlayRecordManager] 状态已重置');
  }

  /// 获取当前播放位置，优先 AudioPlaybackUtils，其次 Player 位置缓存
  Future<Duration> _getCurrentPosition() async {
    if (_audioPlaybackUtils != null) {
      try {
        return await _audioPlaybackUtils!.getCurrentPosition();
      } catch (e) {
        debugPrint('[PlayRecordManager] getCurrentPosition from AudioPlaybackUtils failed: $e');
        // 兼容热重载后旧实例方法签名不一致导致的 Lookup failed
        _audioPlaybackUtils = null;
      }
    }
    if (_player != null) {
      return _playerPosition;
    }
    return Duration.zero;
  }

  /// 上报本地缓存的未完成记录（App启动时调用）
  /// 上报所有未成功的记录（pending + failed），不包括 success 状态的
  Future<void> reportPendingRecords() async {
    debugPrint('[PlayRecordManager] App启动，开始上报本地缓存记录');

    try {
      await _ensureDatabaseInitialized();

      // 先清理过期和超出条数的记录
      await PlayRecordDatabase.instance.performCleanup();

      // 获取待上报记录（pending + failed）
      final records = await PlayRecordDatabase.instance.getPendingRecords();
      if (records.isEmpty) {
        debugPrint('[PlayRecordManager] 无待上报记录');
        return;
      }

      debugPrint('[PlayRecordManager] 待上报记录数: ${records.length}');

      await _batchReport(records);
    } catch (e) {
      debugPrint('[PlayRecordManager] 上报本地缓存记录异常: $e');
    }
  }

  /// 重试失败和待上报的记录（上报成功后调用）
  /// 上报 failed 和 pending 状态的记录，排除当前正在追踪的记录
  Future<void> retryFailedRecords() async {
    debugPrint('[PlayRecordManager] 尝试重试失败和待上报的记录');

    try {
      await _ensureDatabaseInitialized();

      // 获取失败和待上报的记录
      final allRecords = await PlayRecordDatabase.instance.getPendingRecords();
      if (allRecords.isEmpty) {
        debugPrint('[PlayRecordManager] 无待上报记录');
        return;
      }

      // 排除当前正在追踪的记录
      final records = allRecords.where((r) => r.id != _currentRecordId).toList();
      if (records.isEmpty) {
        debugPrint('[PlayRecordManager] 无待上报记录（排除当前追踪后）');
        return;
      }

      debugPrint('[PlayRecordManager] 待上报记录数: ${records.length}');

      await _batchReport(records);
    } catch (e) {
      debugPrint('[PlayRecordManager] 重试记录异常: $e');
    }
  }

  /// 批量上报记录
  Future<void> _batchReport(List<PlayRecordModel> records) async {
    if (records.isEmpty) return;

    // 过滤掉 played < 1 的记录，并删除它们
    List<int> invalidIds = [];
    List<PlayRecordModel> validRecords = [];
    
    for (final record in records) {
      if (record.played < PlayRecordConstants.minValidPlaySeconds) {
        if (record.id != null) {
          invalidIds.add(record.id!);
        }
      } else {
        validRecords.add(record);
      }
    }

    // 删除无效记录
    if (invalidIds.isNotEmpty) {
      debugPrint('[PlayRecordManager] 删除播放时长不足的记录: ${invalidIds.length} 条');
      await PlayRecordDatabase.instance.deleteByIds(invalidIds);
    }

    // 如果没有有效记录，直接返回
    if (validRecords.isEmpty) {
      debugPrint('[PlayRecordManager] 无有效记录需要上报');
      return;
    }

    List<int> recordIds = [];
    List<Map<String, dynamic>> reqDataList = [];

    for (int i = 0; i < validRecords.length; i++) {
      if (validRecords[i].id != null) {
        recordIds.add(validRecords[i].id!);
      }
      reqDataList.add(await _buildSliceWithInteraction(validRecords[i]));
    }

    Map<String, dynamic> reqData = {
      "slices": reqDataList,
    };

    bool success = false;
    if(!ManageSandboxController.to.isSimulate){
      success = await SongRequest.reportPlayKnowledgeList(reqData);
    }else{
      success = true;
    }

    if (success) {
      // 上报成功，更新状态为success
      for (final id in recordIds) {
        await PlayRecordDatabase.instance.updateStatus(id, PlayRecordReportStatus.success);
      }
      for (final record in validRecords) {
        await InteractionSessionManager.instance.markReportedSuccessBySessionId(
          record.sessionId,
        );
      }
      debugPrint('[PlayRecordManager] 已更新上报成功的记录状态: ${recordIds.length} 条');
    } else {
      // 上报失败，更新状态为failed
      for (final record in validRecords) {
        if (record.id == null) continue;
        await PlayRecordDatabase.instance.updateStatus(
          record.id!,
          PlayRecordReportStatus.failed,
        );
        await InteractionSessionManager.instance.markReportedFailedBySessionId(
          record.sessionId,
        );
      }
    }
  }

  /// 获取倍速
  Future<double> getPlaybackRate() async {
    if(_audioPlaybackUtils != null){
      return await _audioPlaybackUtils!.getPlaybackRate();
    }else if(_player != null){
      return _player!.state.rate;
    }else{
      return 1.0;
    }
  }

  /// 构建带交互时长的单条上报切片
  Future<Map<String, dynamic>> _buildSliceWithInteraction(
    PlayRecordModel record,
  ) async {
    double playbackRate = await getPlaybackRate();
    final Map<String, dynamic> slice = <String, dynamic>{
      "type": record.type,
      "typeId": record.typeId,
      "learnType": record.learnType,
      "styleId": record.styleId,
      "dialect": record.dialect,
      "contentType": record.contentType,
      "contentId": record.contentId,
      "played": record.played,
      "ratio": playbackRate,
      "duration": record.duration,
      "time": record.createdAt,
      "sessionId": record.sessionId,
    };

    final Map<String, dynamic>? interactionPayload = await InteractionSessionManager.instance.getReportPayloadBySessionId(
      record.sessionId,
      minimumEngagementSeconds: record.played,
    );
    if(interactionPayload != null){
      /// 交互记录时长秒数
      final double learnedSeconds = (interactionPayload["engagementSeconds"] as num?)?.toDouble() ?? 0;
      // 最大学习时长为资源时长的5倍
      final double maxLearnedSeconds = record.duration * 5;
      slice["learned"] = learnedSeconds > maxLearnedSeconds ? maxLearnedSeconds : learnedSeconds;
    }
    

    return slice;
  }

  /// 释放资源（App 退出时调用，一般不需要）
  void dispose() {
    stopTracking();
    PlayRecordDatabase.instance.close();
  }
}
