import 'dart:async';

import 'package:get/get.dart';
import 'package:audio_service/audio_service.dart' as audio_service;

import 'audio_handler.dart';
import 'utils.dart';

class AudioPlaybackUtils {
  NSAudioHandler get _audioHandler => Get.find<NSAudioHandler>();

  Stream<bool> get playCompleteStream => _playCompleteStream.stream.distinct();

  // Stream<bool> get playCompleteStream => _isWindows
  //     ? _playCompleteStream.stream
  //     : _playCompleteStream.stream.distinct();

  /// 播放完成监听
  final StreamController<bool> _playCompleteStream =
      StreamController<bool>.broadcast();

  /// 是否已触发过播放完成事件（防止重复触发）
  bool _hasEmittedComplete = false;

  // 统一位置流
  Stream<Duration> get positionStream => _positionController.stream.distinct();

  // 统一的播放位置流（跨平台）
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();

  Stream<bool> get pauseResumeStream => _pauseResumeStream.stream;

  /// 暂停恢复监听
  final StreamController<bool> _pauseResumeStream =
      StreamController<bool>.broadcast();

  // 事件订阅（按平台）
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<audio_service.PlaybackState>?
      _playbackSub;
  StreamSubscription<bool>? _playerStateSub;

  // 统一初始化并绑定事件
  Future<void> prepare({
    required String url,
    String? title,
    String? artist,
    String? album,
    Uri? image,
    Duration? duration,
    double? playSpeed,
    bool showSkipControls = true,
    List<int>? androidCompactActionIndices = const [0, 1, 2],
  }) async {
    final item = audio_service.MediaItem(
      id: url,
      title: title ?? '',
      artist: artist ?? '',
      album: album ?? '',
      artUri: image,
      duration: duration,
    );
    try {
      await _audioHandler.addQueueItem(item);
      if (playSpeed != null) {
        await _audioHandler.setPlaybackRate(playSpeed);
      }
      await _audioHandler.setPlayMode(
        showSkipControls: showSkipControls,
        androidCompactActionIndices: androidCompactActionIndices,
      );
      _bindOtherStreams();
    } catch (e, s) {
      ErrorLogUtils.to.logError('[AudioPlaybackUtils] prepare error: $e', s);
    }
  }

  /// 更新歌词
  void updateLyric(String lyric) {
    _audioHandler.updateLyric(lyric);
  }

  /// 更新图片
  void updateImage(String? image) {
    if (image == null) return;
    _audioHandler.updateImage(Uri.tryParse(image));
  }

  // 统一播放/继续
  Future<void> resume() async {
    await _audioHandler.play();
  }

  // 统一暂停
  Future<void> pause() async {
    await _audioHandler.pause();
  }

  // 统一停止
  Future<void> stop() async {
    await _audioHandler.pause();
  }

  Future<void> hardStop() async {
    await _audioHandler.stop();
  }

  /// 真正停止 清除后台播放
  Future<void> stopB() async {
    await _audioHandler.stop();
    prepare(url: "");
  }

  // 统一拖动进度
  Future<void> seek(Duration position) async {
    await _audioHandler.seek(position);
  }

  // 统一设置倍速
  Future<void> setPlaybackRate(double rate) async {
    await _audioHandler.setPlaybackRate(rate);
  }

  /// 获取倍速
  Future<double> getPlaybackRate() async {
    return _audioHandler.getPlaybackRate();
  }

  // 统一获取时长
  Future<Duration> getDuration() async {
    return _audioHandler.duration;
  }

  /// 获取当前位置
  Future<Duration> getCurrentPosition() async {
    return _audioHandler.position;
  }

  /// 设置音量 0 - 100
  Future<void> setVolume(double volume) async {
    await _audioHandler.setVolume(volume);
  }

  /// 由业务侧注入上一首/下一首的处理逻辑
  void setNavigationHandlers({
    Future<void> Function()? onNext,
    Future<void> Function()? onPrevious,
  }) {
    _audioHandler.setNavigationHandlers(
      onNext: onNext,
      onPrevious: onPrevious,
    );
  }

  // 统一判断是否正在播放
  bool get isPlaying {
    return _audioHandler.isPlaying;
  }

  // 释放资源与解绑
  Future<void> dispose() async {
    await _positionSub?.cancel();
    await _playbackSub?.cancel();
    await _playerStateSub?.cancel();
    await _audioHandler.stop();
    await _positionController.close();
    await _playCompleteStream.close();
    await _pauseResumeStream.close();
  }

  void _bindOtherStreams() {
    _positionSub?.cancel();
    _playbackSub?.cancel();
    _playerStateSub?.cancel();
    _hasEmittedComplete = false; // 重置播放完成标记

    _positionSub = _audioHandler.audioPlayer.stream.position.listen((pos) {
      _positionController.add(pos);
    });

    _playbackSub = _audioHandler.playbackState.listen((state) async {
      _pauseResumeStream.add(state.playing);
      if (state.playing) {
        _playCompleteStream.add(false);
        _hasEmittedComplete = false; // 开始播放时重置标记
      }

      final isCompleted =
          state.processingState == audio_service.AudioProcessingState.completed;
      if (isCompleted && !_hasEmittedComplete) {
        _hasEmittedComplete = true;
        await pause();
        _playCompleteStream.add(true);
      }
    });

    _playerStateSub =
        _audioHandler.audioPlayer.stream.playing.listen((playing) async {
      _pauseResumeStream.add(playing);
      if (playing) {
        _playCompleteStream.add(false);
        _hasEmittedComplete = false; // 开始播放时重置标记
      }
    });
  }
}
