import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../common/https/https.dart';
import '../audio_playback_utils.dart';
import 'play_record_constants.dart';
import 'play_record_database.dart';
import 'play_record_model.dart';

/// 播放记录管理器（单例）
class PlayRecordManager {
  PlayRecordManager._internal();
  static final PlayRecordManager _instance = PlayRecordManager._internal();
  static PlayRecordManager get instance => _instance;

  /// 当前追踪的音频播放工具
  AudioPlaybackUtils? _audioPlaybackUtils;

  /// 当前追踪的记录模型
  PlayRecordModel? _currentRecord;

  /// 当前追踪源标识
  String? _currentSource;

  /// 当前会话ID
  String? _currentSessionId;

  /// 追踪开始时间（毫秒）- 预留字段，用于后期扩展
  // ignore: unused_field
  int? _trackingStartTime;

  /// 暂停开始时间（毫秒）- 预留字段，用于后期扩展
  // ignore: unused_field
  int? _pauseStartTime;

  /// 暂停超时计时器
  Timer? _pauseTimeoutTimer;

  /// 播放状态监听
  StreamSubscription<bool>? _pauseResumeSub;

  /// 是否已上报过播放完成（防止重复上报）
  bool _hasReportedPlayComplete = false;

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
  /// [type] 类型: unit, favorite, collection, none
  /// [typeId] 关联ID
  /// [contentType] 内容类型
  /// [contentId] 内容ID
  /// [duration] 总时长（秒）
  /// [source] 追踪源标识，用于区分不同控制器
  /// [lastPlayedSeconds] 上一首的播放时长（秒），切换歌曲时传入
  Future<void> startTracking({
    required AudioPlaybackUtils audioPlaybackUtils,
    String? type,
    int? typeId,
    required String contentType,
    required int contentId,
    required double duration,
    String? source,
    double? lastPlayedSeconds,
  }) async {

    // 如果已经在追踪同一个内容，不重复开始
    if (_isTracking && 
        _currentRecord?.contentId == contentId && 
        _currentRecord?.contentType == contentType) {
      debugPrint('[PlayRecordManager] 已在追踪相同内容，跳过');
      return;
    }

    // 如果正在追踪其他内容，先停止（触发切换上报）
    if (_isTracking) {
      _reportSwitchSong(lastPlayedSeconds);
    }

    // 生成新的会话ID
    _currentSessionId = const Uuid().v4();
    _trackingStartTime = DateTime.now().millisecondsSinceEpoch;

    // 创建新的记录模型
    _currentRecord = PlayRecordModel(
      sessionId: _currentSessionId,
      type: type,
      typeId: typeId,
      contentType: contentType,
      contentId: contentId,
      played: 0,
      duration: duration,
    );

    _audioPlaybackUtils = audioPlaybackUtils;
    _currentSource = source;
    _isTracking = true;
    _hasReportedPlayComplete = false; // 重置播放完成上报标记

    // 插入数据库（pending状态，构造函数默认值已是pending）
    await _ensureDatabaseInitialized();
    _currentRecordId = await PlayRecordDatabase.instance.insert(_currentRecord!);
    debugPrint('[PlayRecordManager] 追踪已开始, sessionId=$_currentSessionId, dbId=$_currentRecordId, status=${_currentRecord!.reportStatus}');

    // 监听播放状态变化（暂停/恢复）
    _pauseResumeSub?.cancel();
    _pauseResumeSub = audioPlaybackUtils.pauseResumeStream.listen(_onPauseResumeChanged);
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
    await _reportAndReset(PlayRecordTriggerType.exitPlayer);
  }

  /// 播放状态变化处理
  void _onPauseResumeChanged(bool isPlaying) {
    if (!_isTracking) return;

    if (isPlaying) {
      if(_pauseStartTime == null) return;
      // 恢复播放 - 取消暂停计时器
      _cancelPauseTimer();
      _pauseStartTime = null;
      debugPrint('[PlayRecordManager] 恢复播放，取消暂停计时器');
    } else {
      if(_pauseStartTime != null) return;
      // 暂停 - 开始计时
      _pauseStartTime = DateTime.now().millisecondsSinceEpoch;
      _startPauseTimer();
      debugPrint('[PlayRecordManager] 暂停播放，开始计时');
    }
  }

  /// 播放完成上报（由控制器在播放完成时调用）
  /// [playedSeconds] 已播放时长（秒）
  void reportPlayComplete(double playedSeconds) {
    if (!_isTracking) {
      debugPrint('[PlayRecordManager] 未在追踪状态，跳过播放完成上报');
      return;
    }

    // 防止同一首歌重复上报播放完成
    if (_hasReportedPlayComplete) {
      debugPrint('[PlayRecordManager] 已上报过播放完成，跳过重复上报');
      return;
    }
    _hasReportedPlayComplete = true;

    debugPrint('[PlayRecordManager] 播放完成上报: played=$playedSeconds');
    _doPlayCompleteReport(playedSeconds);
  }

  /// 执行播放完成上报
  Future<void> _doPlayCompleteReport(double playedSeconds) async {
    if (_currentRecord == null) {
      return;
    }

    // 保存当前记录ID，用于上报或删除
    final oldRecordId = _currentRecordId;

    // 检查是否满足最小播放时长
    if (playedSeconds < PlayRecordConstants.minValidPlaySeconds) {
      debugPrint('[PlayRecordManager] 播放时长不足 ${PlayRecordConstants.minValidPlaySeconds} 秒，删除记录');
      if (oldRecordId != null) {
        await PlayRecordDatabase.instance.delete(oldRecordId);
      }
      return;
    }

    // 更新记录
    final record = _currentRecord!.copyWith(
      played: playedSeconds,
      triggerType: PlayRecordTriggerType.playComplete.value,
    );

    // 执行上报（更新原记录）
    await _doReport(record, recordId: oldRecordId);
  }

  /// 开始暂停超时计时器
  void _startPauseTimer() {
    _cancelPauseTimer();
    _pauseTimeoutTimer = Timer(
      const Duration(seconds: PlayRecordConstants.pauseTimeoutSeconds),
      () {
        debugPrint('[PlayRecordManager] 暂停超时，触发上报');
        _reportPauseTimeout();
      },
    );
  }

  /// 取消暂停计时器
  void _cancelPauseTimer() {
    _pauseTimeoutTimer?.cancel();
    _pauseTimeoutTimer = null;
  }

  /// 切换歌曲时的上报处理
  /// [playedSeconds] 上一首的播放时长（秒），由调用方在切换前获取
  void _reportSwitchSong(double? playedSeconds) {
    if (_currentRecord == null) {
      _resetWithoutReport();
      return;
    }

    // 同步保存当前记录（上一首的记录）
    final oldRecord = _currentRecord!;
    final oldRecordId = _currentRecordId;

    // 先重置状态（不取消监听，因为马上会重新设置）
    _resetWithoutReport();

    // 异步上报
    _doSwitchReport(oldRecord, playedSeconds, oldRecordId);
  }

  /// 执行切换上报
  Future<void> _doSwitchReport(PlayRecordModel oldRecord, double? playedSeconds, int? oldRecordId) async {
    try {
      debugPrint('[PlayRecordManager] 切换上报: contentId=${oldRecord.contentId}, played=$playedSeconds, dbId=$oldRecordId');

      // 如果没有传入播放时长，删除记录并返回
      if (playedSeconds == null) {
        debugPrint('[PlayRecordManager] 未传入播放时长，删除记录');
        if (oldRecordId != null) {
          await PlayRecordDatabase.instance.delete(oldRecordId);
        }
        return;
      }

      // 检查是否满足最小播放时长
      if (playedSeconds < PlayRecordConstants.minValidPlaySeconds) {
        debugPrint('[PlayRecordManager] 播放时长不足 ${PlayRecordConstants.minValidPlaySeconds} 秒，删除记录');
        if (oldRecordId != null) {
          await PlayRecordDatabase.instance.delete(oldRecordId);
        }
        return;
      }

      // 更新记录
      final record = oldRecord.copyWith(
        played: playedSeconds,
        triggerType: PlayRecordTriggerType.switchSong.value,
      );

      // 执行上报（使用旧的recordId）
      await _doReport(record, recordId: oldRecordId);
    } catch (e) {
      debugPrint('[PlayRecordManager] 切换上报异常: $e');
    }
  }

  /// 上报并重置状态（用于退出播放器）
  Future<void> _reportAndReset(PlayRecordTriggerType triggerType) async {
    if (_currentRecord == null || _audioPlaybackUtils == null) {
      _reset();
      return;
    }

    // 获取当前播放位置作为已播放时长
    final position = await _audioPlaybackUtils!.getCurrentPosition();
    final playedSeconds = position.inMilliseconds / 1000.0;

    debugPrint('[PlayRecordManager] 准备上报: triggerType=${triggerType.value}, played=$playedSeconds');

    // 保存当前记录ID
    final oldRecordId = _currentRecordId;

    // 检查是否满足最小播放时长
    if (playedSeconds < PlayRecordConstants.minValidPlaySeconds) {
      debugPrint('[PlayRecordManager] 播放时长不足 ${PlayRecordConstants.minValidPlaySeconds} 秒，删除记录');
      if (oldRecordId != null) {
        await PlayRecordDatabase.instance.delete(oldRecordId);
      }
      _reset();
      return;
    }

    // 更新记录
    final record = _currentRecord!.copyWith(
      played: playedSeconds,
      triggerType: triggerType.value,
    );

    // 完全重置状态
    _reset();

    // 执行上报（使用旧的recordId）
    await _doReport(record, recordId: oldRecordId);
  }

  /// 暂停超时上报
  Future<void> _reportPauseTimeout() async {
    if (_currentRecord == null || _audioPlaybackUtils == null) {
      return;
    }

    // 获取当前播放位置作为已播放时长
    final position = await _audioPlaybackUtils!.getCurrentPosition();
    final playedSeconds = position.inMilliseconds / 1000.0;

    debugPrint('[PlayRecordManager] 暂停超时上报: played=$playedSeconds');

    // 保存当前记录ID，用于上报或删除
    final oldRecordId = _currentRecordId;

    // 检查是否满足最小播放时长
    if (playedSeconds < PlayRecordConstants.minValidPlaySeconds) {
      debugPrint('[PlayRecordManager] 播放时长不足 ${PlayRecordConstants.minValidPlaySeconds} 秒，删除记录');
      if (oldRecordId != null) {
        await PlayRecordDatabase.instance.delete(oldRecordId);
      }
      return;
    }

    // 更新记录
    final record = _currentRecord!.copyWith(
      played: playedSeconds,
      triggerType: PlayRecordTriggerType.pauseTimeout.value,
    );

    // 执行上报（更新原记录）
    await _doReport(record, recordId: oldRecordId);
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
      Map<String, dynamic> reqData = {
        "slices": [{
          "type": record.type,
          "typeId": record.typeId,
          "contentType": record.contentType,
          "contentId": record.contentId,
          "played": record.played,
          "duration": record.duration,
          "time": record.createdAt,
          "sessionId": record.sessionId,
        }],
      };

      final success = await SongRequest.reportPlayKnowledgeList(reqData);

      if (success) {
        debugPrint('[PlayRecordManager] 上报成功，更新状态为success');
        await PlayRecordDatabase.instance.updateStatus(dbId, PlayRecordReportStatus.success);
        
        // 尝试重试失败的记录
        retryFailedRecords();
      } else {
        // 上报失败，更新状态为failed
        debugPrint('[PlayRecordManager] 上报失败，更新状态为failed');
        await PlayRecordDatabase.instance.updateStatus(dbId, PlayRecordReportStatus.failed);
      }
    } catch (e) {
      debugPrint('[PlayRecordManager] 上报异常: $e');
      // 异常时更新状态为failed
      await PlayRecordDatabase.instance.updateStatus(dbId, PlayRecordReportStatus.failed);
    }
  }

  /// 重置追踪状态（不取消监听，用于切换歌曲场景）
  void _resetWithoutReport() {
    _cancelPauseTimer();
    // 不取消监听，因为切换歌曲时会立即重新设置
    _currentRecord = null;
    _currentRecordId = null;
    _currentSessionId = null;
    _trackingStartTime = null;
    _pauseStartTime = null;
    _isTracking = false;
    _hasReportedPlayComplete = false;
  }

  /// 重置追踪状态
  void _reset() {
    _cancelPauseTimer();
    _pauseResumeSub?.cancel();

    _audioPlaybackUtils = null;
    _currentRecord = null;
    _currentRecordId = null;
    _currentSource = null;
    _currentSessionId = null;
    _trackingStartTime = null;
    _pauseStartTime = null;
    _isTracking = false;
    _hasReportedPlayComplete = false;

    debugPrint('[PlayRecordManager] 状态已重置');
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
      reqDataList.add({
        "type": validRecords[i].type,
        "typeId": validRecords[i].typeId,
        "contentType": validRecords[i].contentType,
        "contentId": validRecords[i].contentId,
        "played": validRecords[i].played,
        "duration": validRecords[i].duration,
        "time": validRecords[i].createdAt,
        "sessionId": validRecords[i].sessionId,
      });
    }

    Map<String, dynamic> reqData = {
      "slices": reqDataList,
    };

    final success = await SongRequest.reportPlayKnowledgeList(reqData);

    if (success) {
      // 上报成功，更新状态为success
      for (final id in recordIds) {
        await PlayRecordDatabase.instance.updateStatus(id, PlayRecordReportStatus.success);
      }
      debugPrint('[PlayRecordManager] 已更新上报成功的记录状态: ${recordIds.length} 条');
    } else {
      // 上报失败，更新状态为failed
      for (final record in records) {
        if (record.id == null) continue;
        await PlayRecordDatabase.instance.updateStatus(
          record.id!,
          PlayRecordReportStatus.failed,
        );
      }
    }
  }

  /// 释放资源（App 退出时调用，一般不需要）
  void dispose() {
    stopTracking();
    PlayRecordDatabase.instance.close();
  }
}
