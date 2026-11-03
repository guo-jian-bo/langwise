import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:resource_cache_package/resource_cache_package.dart';

import 'utils.dart';

class NSAudioHandler extends BaseAudioHandler {
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayer get audioPlayer => _audioPlayer;

  Future<void> Function()? _onNext;
  Future<void> Function()? _onPrevious;

  NSAudioHandler() {
    // 监听播放状态并更新播放状态流
    _audioPlayer.playbackEventStream.map(_transformEvent).listen((state) {
      print('[NSAudioHandler] playbackState更新: playing=${state.playing}, processingState=${state.processingState}');
      playbackState.add(state);
    });
    
    // 监听播放器处理状态变化
    _audioPlayer.processingStateStream.listen((state) {
      print('[NSAudioHandler] processingState变化: $state');
    });

    // 监听音频中断事件（如来电、其他应用播放音频等）
    _initAudioSessionInterruptionHandler();
  }

  /// 初始化音频中断处理（仅移动端需要）
  void _initAudioSessionInterruptionHandler() {
    if (!Platform.isIOS && !Platform.isAndroid) return;
    
    AudioSession.instance.then((session) {
      // 监听音频中断
      session.interruptionEventStream.listen((event) {
        print('[NSAudioHandler] 音频中断事件: begin=${event.begin}, type=${event.type}');
        if (event.begin) {
          // 被中断（如来电、其他应用播放音频）
          if (_audioPlayer.playing) {
            _audioPlayer.pause();
          }
        } else {
          // 中断结束，根据中断类型决定是否恢复播放
          if (event.type == AudioInterruptionType.pause) {
            // 暂停类型的中断结束后可以恢复播放
            _audioPlayer.play();
          }
        }
      });

      // 监听音频设备变化（如耳机拔出）
      session.becomingNoisyEventStream.listen((_) {
        print('[NSAudioHandler] 音频设备变化（耳机拔出等）');
        if (_audioPlayer.playing) {
          _audioPlayer.pause();
        }
      });
    });
  }

  @override
  Future<void> play() async {
    await _audioPlayer.play();
  }

  @override
  Future<void> pause() async {
    await _audioPlayer.pause();
  }
  

  @override
  Future<void> stop() async {
    print('[NSAudioHandler] stop() 被调用');
    await _audioPlayer.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    print(position);
    await _audioPlayer.seek(position);
  }

  Future<Duration?> setClip({
    required Duration start,
    required Duration end,
  }) async {
    return await _audioPlayer.setClip(
      start: start,
      end: end,
    );
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
    await _audioPlayer.setSpeed(rate);
  }

  /// 刷新锁屏控制状态
  /// 当应用从后台恢复到前台时调用，用于恢复锁屏控制显示
  Future<void> refreshNowPlayingInfo() async {
    final current = mediaItem.value;
    if (current == null) return;
    if (!_audioPlayer.playing) return;
    
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
      _audioPlayer.playing ? MediaControl.pause : MediaControl.play,
      if (_showSkipControls) MediaControl.skipToNext,
    ];
    
    playbackState.add(playbackState.value.copyWith(
      playing: _audioPlayer.playing,
      updatePosition: _audioPlayer.position,
      bufferedPosition: _audioPlayer.bufferedPosition,
      speed: _audioPlayer.speed,
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
      title: lyric,            // 如需主标题显示歌词，改为：title: lyric,
      artist: current.artist,                   // 当前歌词行放到副标题
      album: current.album,
      duration: current.duration,
      artUri: current.artUri,
      extras: current.extras,
    );
    mediaItem.add(updated);
    // 主动刷新系统播放状态的进度，避免进度被系统重置为0
    playbackState.add(
      playbackState.value.copyWith(
        updatePosition: _audioPlayer.position,
        bufferedPosition: _audioPlayer.bufferedPosition,
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
        updatePosition: _audioPlayer.position,
        bufferedPosition: _audioPlayer.bufferedPosition,
      ),
    );
  }
  

  /// 播放指定的MediaItem
  Future<void> playUrl(MediaItem item) async {
    mediaItem.add(item);

    String? audioPath = await CacheManagerUtils.instance.getFile(item.id, ResourceType.audio);
    if(audioPath == null) return;

    await _audioPlayer.setFilePath(audioPath);
    await _audioPlayer.play();
  }

  @override
  Future<void> addQueueItem(MediaItem item) async {
    mediaItem.add(item);

    String? audioPath = await CacheManagerUtils.instance.getFile(item.id, ResourceType.audio);
    if(audioPath == null) return;

    await _audioPlayer.setFilePath(audioPath);
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
      _audioPlayer.playing ? MediaControl.pause : MediaControl.play,
      if (_showSkipControls) MediaControl.skipToNext,
    ];

    if (androidCompactActionIndices != null) {
      final maxIndex = controlsList.length - 1;
      final filtered = androidCompactActionIndices.where((i) => i >= 0 && i <= maxIndex).toList();
      _androidCompactActionIndices = filtered.isEmpty ? [0] : filtered;
    } else {
      _androidCompactActionIndices = null;
    }

    playbackState.add(playbackState.value.copyWith(
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

  /// 更新播放状态流
  PlaybackState _transformEvent(PlaybackEvent event) {
    final controlsList = [
      if (_showSkipControls) MediaControl.skipToPrevious,
      _audioPlayer.playing ? MediaControl.pause : MediaControl.play,
      if (_showSkipControls) MediaControl.skipToNext,
    ];

    return playbackState.value.copyWith(
      playing: _audioPlayer.playing,
      updatePosition: _audioPlayer.position,
      bufferedPosition: _audioPlayer.bufferedPosition,
      speed: _audioPlayer.speed,
      queueIndex: event.currentIndex,
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_audioPlayer.processingState]!,
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
  }
}
