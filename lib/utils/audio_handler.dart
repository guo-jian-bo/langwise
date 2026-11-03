import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:video_player/video_player.dart';

import 'utils.dart';

class NSAudioHandler extends BaseAudioHandler {
  final Player _audioPlayer = Player();

  Player get audioPlayer => _audioPlayer;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _playbackRate = 1.0;
  bool _isPlaying = false;
  AudioProcessingState _processingState = AudioProcessingState.idle;
  Duration _lastEmittedPosition = Duration.zero;
  bool _hasEmittedPlaybackState = false;

  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _isPlaying;

  Future<void> Function()? _onNext;
  Future<void> Function()? _onPrevious;

  NSAudioHandler() {
    _audioPlayer.stream.position.listen((position) {
      _position = position;
      _emitPlaybackState();
    }, onError: (e, s) {
      ErrorLogUtils.to.logError('NSAudioHandler position stream error: $e', s);
    });

    _audioPlayer.stream.duration.listen((duration) {
      _duration = duration;
      _emitPlaybackState();
    }, onError: (e, s) {
      ErrorLogUtils.to.logError('NSAudioHandler duration stream error: $e', s);
    });

    _audioPlayer.stream.playing.listen((playing) {
      _isPlaying = playing;
      if (playing) {
        _processingState = AudioProcessingState.ready;
      }
      _emitPlaybackState();
    }, onError: (e, s) {
      ErrorLogUtils.to.logError('NSAudioHandler playing stream error: $e', s);
    });

    _audioPlayer.stream.completed.listen((completed) {
      if (!completed) return;
      _isPlaying = false;
      _processingState = AudioProcessingState.completed;
      _emitPlaybackState();
    }, onError: (e, s) {
      ErrorLogUtils.to.logError('NSAudioHandler completed stream error: $e', s);
    });

    _initAudioSessionInterruptionHandler();
  }

  /// 初始化音频中断处理（仅移动端需要）
  void _initAudioSessionInterruptionHandler() {
    if (!Platform.isIOS && !Platform.isAndroid) return;

    AudioSession.instance.then((session) async {
      try {
        await session.configure(AudioSessionConfiguration.music());
      } catch (e, s) {
        ErrorLogUtils.to
            .logError('NSAudioHandler audio session configure error: $e', s);
      }
      // 监听音频中断
      session.interruptionEventStream.listen((event) {
        print(
            '[NSAudioHandler] 音频中断事件: begin=${event.begin}, type=${event.type}');
        if (event.begin) {
          // 被中断（如来电、其他应用播放音频）
          if (_isPlaying) {
            _audioPlayer.pause().catchError((e, s) {
              ErrorLogUtils.to
                  .logError('NSAudioHandler interruption pause error: $e', s);
            });
          }
        } else {
          // 中断结束，根据中断类型决定是否恢复播放
          if (event.type == AudioInterruptionType.pause) {
            // 暂停类型的中断结束后可以恢复播放
            _audioPlayer.play().catchError((e, s) {
              ErrorLogUtils.to
                  .logError('NSAudioHandler interruption resume error: $e', s);
            });
          }
        }
      }, onError: (e, s) {
        ErrorLogUtils.to
            .logError('NSAudioHandler interruptionEventStream error: $e', s);
      });

      // 监听音频设备变化（如耳机拔出）
      session.becomingNoisyEventStream.listen((_) {
        print('[NSAudioHandler] 音频设备变化（耳机拔出等）');
        if (_isPlaying) {
          _audioPlayer.pause().catchError((e, s) {
            ErrorLogUtils.to
                .logError('NSAudioHandler becomingNoisy pause error: $e', s);
          });
        }
      }, onError: (e, s) {
        ErrorLogUtils.to
            .logError('NSAudioHandler becomingNoisyEventStream error: $e', s);
      });
    }).catchError((e, s) {
      ErrorLogUtils.to
          .logError('NSAudioHandler AudioSession.instance error: $e', s);
    });
  }

  @override
  Future<void> play() async {
    try {
      _processingState = AudioProcessingState.ready;
      await _audioPlayer.play();
      _emitPlaybackState();
    } catch (e, s) {
      ErrorLogUtils.to.logError('NSAudioHandler play error: $e', s);
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      _emitPlaybackState();
    } catch (e, s) {
      ErrorLogUtils.to.logError('NSAudioHandler pause error: $e', s);
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    print('[NSAudioHandler] stop() 被调用');
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _position = Duration.zero;
      _processingState = AudioProcessingState.idle;
      _emitPlaybackState();
    } catch (e, s) {
      ErrorLogUtils.to.logError('NSAudioHandler stop error: $e', s);
      rethrow;
    }
  }

  @override
  Future<void> seek(Duration position) async {
    print(position);
    try {
      await _audioPlayer.seek(position);
      _position = position;
      _emitPlaybackState();
    } catch (e, s) {
      ErrorLogUtils.to
          .logError('NSAudioHandler seek error: $e, position=$position', s);
      rethrow;
    }
  }

  /// 由业务侧注入上一首/下一首的处理逻辑
  void setNavigationHandlers({
    Future<void> Function()? onNext,
    Future<void> Function()? onPrevious,
  }) {
    _onNext = onNext;
    _onPrevious = onPrevious;
  }

  @override
  Future<void> skipToNext() async {
    if (_onNext != null) {
      await _onNext!.call();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_onPrevious != null) {
      await _onPrevious!.call();
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    ErrorLogUtils.to.logError("NSAudioHandler onTaskRemoved() - 应用被系统移除", null);
    super.onTaskRemoved();
  }

  /// 设置播放速率
  Future<void> setPlaybackRate(double rate) async {
    _playbackRate = rate;
    await _audioPlayer.setRate(rate);
    _emitPlaybackState();
  }

  /// 设置音量 0 - 100
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
    _emitPlaybackState();
  }

  /// 刷新锁屏控制状态
  /// 当应用从后台恢复到前台时调用，用于恢复锁屏控制显示
  Future<void> refreshNowPlayingInfo() async {
    final current = mediaItem.value;
    if (current == null) return;
    if (!_isPlaying) return;

    print('[NSAudioHandler] refreshNowPlayingInfo() 被调用');

    // 创建一个略微修改的mediaItem来强制触发更新
    // 通过添加一个时间戳到extras中来确保数据"变化"
    final refreshedItem = MediaItem(
      id: current.id,
      title: current.title,
      artist: current.artist,
      album: current.album,
      duration: current.duration,
      artUri: current.artUri,
      extras: {
        ...?current.extras,
        '_refreshTimestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    // 先发送修改后的mediaItem
    mediaItem.add(refreshedItem);

    // 短暂延迟后再发送原始mediaItem，确保iOS原生层接收到更新
    await Future.delayed(const Duration(milliseconds: 100));

    // 重新发送playbackState以刷新控制按钮
    final controlsList = [
      if (_showSkipControls) MediaControl.skipToPrevious,
      _isPlaying ? MediaControl.pause : MediaControl.play,
      if (_showSkipControls) MediaControl.skipToNext,
    ];

    playbackState.add(playbackState.value.copyWith(
      playing: _isPlaying,
      updatePosition: _position,
      bufferedPosition: _position,
      speed: _playbackRate,
      processingState: AudioProcessingState.ready,
      controls: controlsList,
      androidCompactActionIndices: _androidCompactActionIndices,
      systemActions: {
        MediaAction.play,
        MediaAction.pause,
        if (_showSkipControls) MediaAction.skipToNext,
        if (_showSkipControls) MediaAction.skipToPrevious,
        MediaAction.seek,
      },
    ));
  }

  /// 更新锁屏/通知栏歌词显示
  /// 默认将歌词写到 `artist`（副标题）；如需主标题显示，改为设置 `title`
  void updateLyric(String lyric) {
    final current = mediaItem.value;
    if (current == null) return;

    final updated = MediaItem(
      id: current.id,
      title: lyric, // 如需主标题显示歌词，改为：title: lyric,
      artist: current.artist, // 当前歌词行放到副标题
      album: current.album,
      duration: current.duration,
      artUri: current.artUri,
      extras: current.extras,
    );
    mediaItem.add(updated);
    // 主动刷新系统播放状态的进度，避免进度被系统重置为0
    playbackState.add(
      playbackState.value.copyWith(
        updatePosition: _position,
        bufferedPosition: _position,
      ),
    );
  }

  /// 更新锁屏/通知栏图片显示
  void updateImage(Uri? imageUri) {
    final current = mediaItem.value;
    if (current == null) return;

    final updated = MediaItem(
      id: current.id,
      title: current.title,
      artist: current.artist,
      album: current.album,
      duration: current.duration,
      artUri: imageUri,
      extras: current.extras,
    );
    mediaItem.add(updated);
    // 主动刷新系统播放状态的进度，避免进度被系统重置为0
    playbackState.add(
      playbackState.value.copyWith(
        updatePosition: _position,
        bufferedPosition: _position,
      ),
    );
  }

  /// 播放指定的MediaItem
  Future<void> playUrl(MediaItem item) async {
    mediaItem.add(item);

    String? audioPath =
        await CacheManagerUtils.instance.getFile(item.id, ResourceType.audio);
    if (audioPath == null) return;

    _processingState = AudioProcessingState.loading;
    _emitPlaybackState();
    await _audioPlayer.open(
      Media(audioPath),
      play: true,
    );
    _processingState = AudioProcessingState.ready;
    _emitPlaybackState();
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    this.mediaItem.add(mediaItem);

    final Future<String?> cacheFuture = CacheManagerUtils.instance.getFile(mediaItem.id, ResourceType.audio);
    String? audioPath;
    try {
      audioPath = await cacheFuture.timeout(const Duration(milliseconds: 300));
    } on TimeoutException {
      // 超时后立即走网络播放，缓存任务继续在后台执行。
      audioPath = mediaItem.id;
    }
    final String sourcePath =
        (audioPath != null && audioPath.isNotEmpty) ? audioPath : mediaItem.id;
    if (sourcePath.isEmpty) return;

    _processingState = AudioProcessingState.loading;
    _emitPlaybackState();
    await _audioPlayer.pause();
    await _audioPlayer.seek(Duration.zero);
    await _audioPlayer.open(
      Media(sourcePath),
      play: false,
    );
    _processingState = AudioProcessingState.ready;
    _emitPlaybackState();
  }

  /// 缓存控件配置，供事件更新时复用
  bool _showSkipControls = true;
  List<int>? _androidCompactActionIndices = const [0, 1, 2];

  /// 设置播放模式
  Future<void> setPlayMode({
    bool showSkipControls = true,
    List<int>? androidCompactActionIndices,
  }) async {
    _showSkipControls = showSkipControls;

    final controlsList = [
      if (_showSkipControls) MediaControl.skipToPrevious,
      _isPlaying ? MediaControl.pause : MediaControl.play,
      if (_showSkipControls) MediaControl.skipToNext,
    ];

    if (androidCompactActionIndices != null) {
      final maxIndex = controlsList.length - 1;
      final filtered = androidCompactActionIndices
          .where((i) => i >= 0 && i <= maxIndex)
          .toList();
      _androidCompactActionIndices = filtered.isEmpty ? [0] : filtered;
    } else {
      _androidCompactActionIndices = null;
    }

    playbackState.add(playbackState.value.copyWith(
      playing: _isPlaying,
      updatePosition: _position,
      bufferedPosition: _position,
      speed: _playbackRate,
      controls: controlsList,
      androidCompactActionIndices: _androidCompactActionIndices,
      systemActions: {
        MediaAction.play,
        MediaAction.pause,
        if (_showSkipControls) MediaAction.skipToNext,
        if (_showSkipControls) MediaAction.skipToPrevious,
        MediaAction.seek,
      },
    ));
  }

  void _emitPlaybackState() {
    final controlsList = [
      if (_showSkipControls) MediaControl.skipToPrevious,
      _isPlaying ? MediaControl.pause : MediaControl.play,
      if (_showSkipControls) MediaControl.skipToNext,
    ];

    final Duration nextPosition = _position;
    final Duration previousPosition = _lastEmittedPosition;
    final Duration positionDelta = (nextPosition - previousPosition).abs();
    final bool forceEmit = !_hasEmittedPlaybackState ||
        playbackState.value.playing != _isPlaying ||
        playbackState.value.processingState != _processingState ||
        playbackState.value.speed != _playbackRate;
    if (!forceEmit && positionDelta < const Duration(milliseconds: 400)) {
      return;
    }

    final state = playbackState.value.copyWith(
      playing: _isPlaying,
      updatePosition: nextPosition,
      bufferedPosition: nextPosition,
      speed: _playbackRate,
      processingState: _processingState,
      controls: controlsList,
      androidCompactActionIndices: _androidCompactActionIndices,
      systemActions: {
        MediaAction.play,
        MediaAction.pause,
        if (_showSkipControls) MediaAction.skipToNext,
        if (_showSkipControls) MediaAction.skipToPrevious,
        MediaAction.seek,
      },
    );
    _lastEmittedPosition = nextPosition;
    _hasEmittedPlaybackState = true;
    playbackState.add(state);
  }
}
