import 'dart:async';

import 'package:audio_player_ex/audio_player_ex.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:video_player/video_player.dart';

import '../common/public_controller/config_controller.dart';

class PlayAudioUtils {
  factory PlayAudioUtils() => _getInstance();

  static PlayAudioUtils get instance => _getInstance();

  static PlayAudioUtils? _instance;

  AudioPlayerEx? _audioPlayerEx;

  // 单例模式实现
  static PlayAudioUtils _getInstance() {
    _instance ??= PlayAudioUtils._internal();
    return _instance!;
  }

  PlayAudioUtils._internal();

  Future<void> init() async {
    print('[PlayAudioUtils] init() 被调用，准备设置AudioContext');
    _audioPlayerEx = AudioPlayerEx();
    await _audioPlayerEx!.setAudioContext();
    print('[PlayAudioUtils] setAudioContext() 完成');
  }

  /// 播放单条音频
  Future<void> playSingle(String? url, {String? filePath, double? playbackRate}) async {
    try {
      print('[PlayAudioUtils] playSingle() 被调用, url=$url');
      if (_audioPlayerEx == null) {
        await init();
      }

      if (url == null && filePath == null) {
        return;
      }

      if (filePath == null && url != null) {
        try {
          filePath = await Future.any([
            CacheManagerUtils.instance.getFile(url, ResourceType.audio),
            Future.delayed(const Duration(seconds: 3), () => null)
          ]);

          if (filePath == null) {
            print("缓存获取超时，直接使用URL播放: $url");
          }
        } catch (e) {
          print("获取缓存文件出错: $e");
        }
      }

      if (url == null && filePath == null) {
        return;
      }

      final double expandAudioSpeed = playbackRate ??
          Get.find<ConfigController>().userSetting.value.expandAudioSpeed;

      await _audioPlayerEx?.stop();
      await _audioPlayerEx?.playFileOrNetSync(
        url: url,
        filePath: filePath,
        playbackRate: expandAudioSpeed,
        timeout: const Duration(seconds: 3),
      );
    } catch (_) {}
  }

  /// 停止所有音频
  Future<void> stopAll() async {
    print('[PlayAudioUtils] stopAll() 被调用');
    await _audioPlayerEx?.stop();
  }
}

class PlaybackInterlockUtils {
  PlaybackInterlockUtils._();

  static final PlaybackInterlockUtils instance = PlaybackInterlockUtils._();
  static final Object sharedAudioOwner = Object();

  final Map<Object, Future<void> Function()> _audioStoppers =
      <Object, Future<void> Function()>{};

  void registerAudioStopper(
    Object owner,
    Future<void> Function() stopper,
  ) {
    _audioStoppers[owner] = stopper;
  }

  void unregisterAudioStopper(Object owner) {
    _audioStoppers.remove(owner);
  }

  Future<void> stopAllAudio({Object? exceptAudioOwner}) async {
    if (!identical(exceptAudioOwner, sharedAudioOwner)) {
      await PlayAudioUtils.instance.stopAll();
    }
    final List<MapEntry<Object, Future<void> Function()>> entries =
        _audioStoppers.entries.toList();
    for (final entry in entries) {
      if (identical(entry.key, exceptAudioOwner)) continue;
      await entry.value();
    }
  }

  Future<void> stopAllMedia({
    Object? exceptAudioOwner,
    Object? exceptVideoController,
  }) async {
    await stopAllAudio(exceptAudioOwner: exceptAudioOwner);
    TipsVideoManager.instance.stopAll(except: exceptVideoController);
  }

  Future<void> playSharedAudio(
    String? url, {
    String? filePath,
    double? playbackRate,
    Object? exceptVideoController,
  }) async {
    await stopAllMedia(
      exceptAudioOwner: sharedAudioOwner,
      exceptVideoController: exceptVideoController,
    );
    await PlayAudioUtils.instance.playSingle(
      url,
      filePath: filePath,
      playbackRate: playbackRate,
    );
  }
}


class VideoPlayerAudioUtils{
  factory VideoPlayerAudioUtils() => _getInstance();

  static VideoPlayerAudioUtils get instance => _getInstance();

  static VideoPlayerAudioUtils? _instance;

  Player? _audioPlayerEx;

  bool isPlaying = false;

  String? currentUrl;

  final StreamController<bool> playingStream = StreamController.broadcast();

  final StreamController<Duration> durationStream = StreamController.broadcast();

  final StreamController<Duration> positionStream = StreamController.broadcast();

  // 单例模式实现
  static VideoPlayerAudioUtils _getInstance() {
    _instance ??= VideoPlayerAudioUtils._internal();
    return _instance!;
  }

  VideoPlayerAudioUtils._internal(){
    _audioPlayerEx = Player();

    _audioPlayerEx?.stream.playing.listen((playing){
      isPlaying = playing;
      playingStream.add(isPlaying);
    });

    _audioPlayerEx?.stream.duration.listen((duration){
      durationStream.add(duration);
    });

    _audioPlayerEx?.stream.position.listen((position){
      positionStream.add(position);
    });

  }


  /// 打开音频
  Future<void> open(String? audioUrl, {bool play = false}) async{
    if(audioUrl == null) return;
    currentUrl = audioUrl;
    String? filePath = await CacheManagerUtils.instance.getFile(audioUrl, ResourceType.audio);
    if(filePath == null) return;
    await _audioPlayerEx?.open(Media(audioUrl), play: play);

  }

  /// 播放暂停
  Future<void> playOrPause(String? audioUrl, {double? playbackRate, bool autoPlay = false}) async{
    if(currentUrl != audioUrl){
      await open(audioUrl, play: autoPlay);
      double expandAudioSpeed = playbackRate ?? Get.find<ConfigController>().userSetting.value.expandAudioSpeed;
      await _audioPlayerEx?.setRate(expandAudioSpeed);
      return;
    }

    await _audioPlayerEx?.playOrPause();
  }

  /// 暂停
  Future<void> pause() async{
    await _audioPlayerEx?.pause();
  }

  /// 设置播放速度
  Future<void> setRate(double value) async{
    await _audioPlayerEx?.setRate(value);
  }

  /// 设置播放位置
  Future<void> seek(Duration position) async{
    await _audioPlayerEx?.seek(position);
  }


  


}
