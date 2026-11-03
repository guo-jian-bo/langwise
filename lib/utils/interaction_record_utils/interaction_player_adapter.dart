import 'package:video_player/video_player.dart';

import '../audio_playback_utils.dart';

/// 播放器适配器抽象
abstract class InteractionPlayerAdapter {
  /// 播放状态流
  Stream<bool> get playingStream;

  /// 播放位置流
  Stream<Duration>? get positionStream;

  /// 获取当前播放位置
  Future<Duration?> getCurrentPosition();

  /// 释放适配器资源
  void dispose();
}

/// `AudioPlaybackUtils` 交互适配器
class AudioPlaybackInteractionAdapter implements InteractionPlayerAdapter {
  /// 音频播放器工具实例
  final AudioPlaybackUtils audioPlaybackUtils;

  /// 创建音频播放器交互适配器
  AudioPlaybackInteractionAdapter(this.audioPlaybackUtils);

  @override
  Stream<bool> get playingStream => audioPlaybackUtils.pauseResumeStream;

  @override
  Stream<Duration>? get positionStream => audioPlaybackUtils.positionStream;

  @override
  Future<Duration?> getCurrentPosition() async {
    return audioPlaybackUtils.getCurrentPosition();
  }

  @override
  void dispose() {}
}

/// 通用 `Player` 交互适配器
class GenericPlayerInteractionAdapter implements InteractionPlayerAdapter {
  /// 通用播放器实例
  final Player player;

  /// 创建通用播放器交互适配器
  GenericPlayerInteractionAdapter(this.player);

  @override
  Stream<bool> get playingStream => player.stream.playing;

  @override
  Stream<Duration>? get positionStream => player.stream.position;

  @override
  Future<Duration?> getCurrentPosition() async {
    try {
      return player.state.position;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {}
}
