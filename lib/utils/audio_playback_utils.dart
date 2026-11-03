import 'dart:async';

import 'package:audio_player_ex/audio_player_ex.dart' as audioex;
import 'package:get/get.dart';
import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:just_audio/just_audio.dart' as juaudio;


import 'audio_handler.dart';

class AudioPlaybackUtils {

  final NSAudioHandler audioHandler = Get.find<NSAudioHandler>();

  audioex.AudioPlayerEx audioPlayerEx = audioex.AudioPlayerEx();

  Stream<bool> get playCompleteStream => _isWindows ? _playCompleteStream.stream : _playCompleteStream.stream.distinct();
  /// 播放完成监听
  final StreamController<bool> _playCompleteStream = StreamController<bool>.broadcast();

  /// 是否已触发过播放完成事件（防止重复触发）
  bool _hasEmittedComplete = false;


  // 统一位置流
  Stream<Duration> get positionStream => _positionController.stream.distinct();

  // 统一的播放位置流（跨平台）
  final StreamController<Duration> _positionController = StreamController<Duration>.broadcast();

  Stream<bool> get pauseResumeStream => _pauseResumeStream.stream;
  /// 暂停恢复监听
  final StreamController<bool> _pauseResumeStream = StreamController<bool>.broadcast();

  // 事件订阅（按平台）
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<dynamic>? _completeSub; // windows onPlayerComplete
  StreamSubscription<audio_service.PlaybackState>? _playbackSub; // 非windows completed
  StreamSubscription<juaudio.PlayerState>? _playerStateSub; // 非windows playerState


  bool get _isWindows => GetPlatform.isWindows;

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
      await audioPlayerEx.setSource(audioex.UrlSource(url));
      await audioPlayerEx.setReleaseMode(audioex.ReleaseMode.stop);
      if (playSpeed != null) {
        await audioPlayerEx.setPlaybackRate(playSpeed);
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
        await audioHandler.addQueueItem(item);
        if (playSpeed != null) {
          await audioHandler.setPlaybackRate(playSpeed);
        }
        await audioHandler.setPlayMode(
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
    audioHandler.updateLyric(lyric);
  }

  /// 更新图片
  void updateImage(String? image) {
    if (image == null) return;
    audioHandler.updateImage(Uri.tryParse(image));
  }

  // 统一播放/继续
  Future<void> resume() async {
    if (_isWindows) {
      await audioPlayerEx.resume();
    } else {
      await audioHandler.play();
    }
  }

  // 统一暂停
  Future<void> pause() async {
    if (_isWindows) {
      await audioPlayerEx.pause();
    } else {
      await audioHandler.pause();
    }
  }

  // 统一停止
  Future<void> stop() async {
    if (_isWindows) {
      await audioPlayerEx.stop();
    } else {
      await audioHandler.stop();
    }
  }

  // 统一拖动进度
  Future<void> seek(Duration position) async {
    if (_isWindows) {
      await audioPlayerEx.seek(position);
    } else {
      await audioHandler.seek(position);
    }
  }

  // 统一设置倍速
  Future<void> setPlaybackRate(double rate) async {
    if (_isWindows) {
      await audioPlayerEx.setPlaybackRate(rate);
    } else {
      await audioHandler.setPlaybackRate(rate);
    }
  }

  // 统一获取时长
  Future<Duration> getDuration() async {
    if (_isWindows) {
      return await audioPlayerEx.getDuration() ?? Duration.zero;
    } else {
      return audioHandler.audioPlayer.duration ?? Duration.zero;
    }
  }

  /// 获取当前位置
  Future<Duration> getCurrentPosition() async {
    if (_isWindows) {
      return await audioPlayerEx.getCurrentPosition() ?? Duration.zero;
    } else {
      return audioHandler.audioPlayer.position;
    }
  }

  /// 由业务侧注入上一首/下一首的处理逻辑
  void setNavigationHandlers({
    Future<void> Function()? onNext,
    Future<void> Function()? onPrevious,
  }) {
    if(_isWindows){

    }else{
      audioHandler.setNavigationHandlers(
        onNext: onNext,
        onPrevious: onPrevious,
      );
    }
  }

  // 统一判断是否正在播放
  bool get isPlaying {
    if (_isWindows) {
      return audioPlayerEx.isPlaying;
    } else {
      return audioHandler.audioPlayer.playing;
    }
  }



  // 释放资源与解绑
  Future<void> dispose() async {
    await _positionSub?.cancel();
    await _completeSub?.cancel();
    await _playbackSub?.cancel();
    await _playerStateSub?.cancel();
    if (_isWindows) {
      await audioPlayerEx.dispose();
    } else {
      await audioHandler.stop();
    }
    await _positionController.close();
    await _playCompleteStream.close();
    await _pauseResumeStream.close();
  }

  void _bindWindowsStreams() {
    _positionSub?.cancel();
    _completeSub?.cancel();
    _hasEmittedComplete = false; // 重置播放完成标记

    _positionSub = audioPlayerEx.onPositionChanged.listen((pos) {
      _positionController.add(pos);
    });

    _completeSub = audioPlayerEx.onPlayerComplete.listen((_) {
      if (!_hasEmittedComplete) {
        _hasEmittedComplete = true;
        _playCompleteStream.add(true);
      }
    });

    audioPlayerEx.onPlayerStateChanged.listen((event) {
      _pauseResumeStream.add(event == audioex.PlayerState.playing);
      if (event == audioex.PlayerState.playing) {
        _hasEmittedComplete = false; // 开始播放时重置标记
      }
    });
  }

  void _bindOtherStreams() {
    _positionSub?.cancel();
    _playbackSub?.cancel();
    _playerStateSub?.cancel();
    _hasEmittedComplete = false; // 重置播放完成标记

    _positionSub = audioHandler.audioPlayer.positionStream.listen((pos) {
      _positionController.add(pos);
    });

    _playbackSub = audioHandler.playbackState.listen((state) async{
      _pauseResumeStream.add(state.playing);
      if(state.playing){
        _playCompleteStream.add(false);
        _hasEmittedComplete = false; // 开始播放时重置标记
      }

      final isCompleted = state.processingState == audio_service.AudioProcessingState.completed;
      if(isCompleted && !_hasEmittedComplete){
        _hasEmittedComplete = true;
        await pause();
        _playCompleteStream.add(true);
      }
    });

    _playerStateSub = audioHandler.audioPlayer.playerStateStream.listen((event) async{
      _pauseResumeStream.add(event.playing);
      if(event.playing){
        _playCompleteStream.add(false);
        _hasEmittedComplete = false; // 开始播放时重置标记
      }

      if (event.processingState == juaudio.ProcessingState.completed) {
        await pause();
      }
    });
  }

}
