import 'dart:async';

import 'package:audio_player_ex/audio_player_ex.dart' as audioex;
import 'package:get/get.dart';
import 'package:audio_service/audio_service.dart' as audio_service;

import 'audio_handler.dart';
import 'utils.dart';

class AudioPlaybackUtils {
  NSAudioHandler get _audioHandler => Get.find<NSAudioHandler>();

  audioex.AudioPlayerEx? _audioPlayerEx;

  Stream<bool> get playCompleteStream => _isWindows
      ? _playCompleteStream.stream
      : _playCompleteStream.stream.distinct();

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
  StreamSubscription<dynamic>? _completeSub; // windows onPlayerComplete
  StreamSubscription<audio_service.PlaybackState>?
      _playbackSub; // 非windows completed
  StreamSubscription<dynamic>? _playerStateSub; // 非windows playerState

  bool get _isWindows => GetPlatform.isWindows;

  audioex.AudioPlayerEx get _audioPlayerExSafe =>
      _audioPlayerEx ??= audioex.AudioPlayerEx();

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
    if (_isWindows) {
      await _audioPlayerExSafe.setSource(audioex.UrlSource(url));
      await _audioPlayerExSafe.setReleaseMode(audioex.ReleaseMode.stop);
      if (playSpeed != null) {
        await _audioPlayerExSafe.setPlaybackRate(playSpeed);
      }
      _bindWindowsStreams();
    } else {
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
      } catch (e) {
        print(e);
      }
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
    if (_isWindows) {
      await _audioPlayerExSafe.resume();
    } else {
      await _audioHandler.play();
    }
  }

  // 统一暂停
  Future<void> pause() async {
    if (_isWindows) {
      await _audioPlayerExSafe.pause();
    } else {
      await _audioHandler.pause();
    }
  }

  // 统一停止
  Future<void> stop() async {
    if (_isWindows) {
      await _audioPlayerExSafe.stop();
    } else {
      await _audioHandler.pause();
    }
  }

  /// 真正停止 清除后台播放
  Future<void> stopB() async {
    if (_isWindows) {
      await _audioPlayerExSafe.stop();
    } else {
      await _audioHandler.stop();
      prepare(url: "");
    }
  }

  // 统一拖动进度
  Future<void> seek(Duration position) async {
    if (_isWindows) {
      try {
        await _audioPlayerExSafe.seek(position).timeout(const Duration(seconds: 3));
      } on TimeoutException catch (e, s) {
        ErrorLogUtils.to.logError(
          '[AudioPlaybackUtils] seek timeout, position=${position.inMilliseconds}ms: $e',
          s,
        );
      } catch (e, s) {
        ErrorLogUtils.to.logError(
          '[AudioPlaybackUtils] seek error, position=${position.inMilliseconds}ms: $e',
          s,
        );
      }
    } else {
      await _audioHandler.seek(position);
    }
  }

  // 统一设置倍速
  Future<void> setPlaybackRate(double rate) async {
    if (_isWindows) {
      await _audioPlayerExSafe.setPlaybackRate(rate);
    } else {
      await _audioHandler.setPlaybackRate(rate);
    }
  }

  // 统一获取时长
  Future<Duration> getDuration() async {
    if (_isWindows) {
      return await _audioPlayerExSafe.getDuration() ?? Duration.zero;
    } else {
      return _audioHandler.duration;
    }
  }

  /// 获取当前位置
  Future<Duration> getCurrentPosition() async {
    if (_isWindows) {
      return await _audioPlayerExSafe.getCurrentPosition() ?? Duration.zero;
    } else {
      return _audioHandler.position;
    }
  }

  /// 由业务侧注入上一首/下一首的处理逻辑
  void setNavigationHandlers({
    Future<void> Function()? onNext,
    Future<void> Function()? onPrevious,
  }) {
    if (_isWindows) return;
    _audioHandler.setNavigationHandlers(
      onNext: onNext,
      onPrevious: onPrevious,
    );
  }

  // 统一判断是否正在播放
  bool get isPlaying {
    if (_isWindows) {
      return _audioPlayerExSafe.isPlaying;
    } else {
      return _audioHandler.isPlaying;
    }
  }

  // 释放资源与解绑
  Future<void> dispose() async {
    await _positionSub?.cancel();
    await _completeSub?.cancel();
    await _playbackSub?.cancel();
    await _playerStateSub?.cancel();
    if (_isWindows) {
      await _audioPlayerExSafe.dispose();
    } else {
      await _audioHandler.stop();
    }
    await _positionController.close();
    await _playCompleteStream.close();
    await _pauseResumeStream.close();
  }

  void _bindWindowsStreams() {
    _positionSub?.cancel();
    _completeSub?.cancel();
    _hasEmittedComplete = false; // 重置播放完成标记

    _positionSub = _audioPlayerExSafe.onPositionChanged.listen((pos) {
      _positionController.add(pos);
    });

    _completeSub = _audioPlayerExSafe.onPlayerComplete.listen((_) {
      if (!_hasEmittedComplete) {
        _hasEmittedComplete = true;
        _playCompleteStream.add(true);
      }
    });

    _playerStateSub = _audioPlayerExSafe.onPlayerStateChanged.listen((event) {
      _pauseResumeStream.add(event == audioex.PlayerState.playing);
      if (event == audioex.PlayerState.playing) {
        _hasEmittedComplete = false;
        _playCompleteStream.add(false);
      }
    });
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
