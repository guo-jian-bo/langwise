import 'dart:async';

import 'package:audio_player_ex/audio_player_ex.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:resource_cache_package/resource_cache_package.dart';

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
      await _audioPlayerEx?.stop();
      if (url == null && filePath == null) {
        return;
      }

      // 添加超时处理，最多等待3秒
      if (filePath == null && url != null) {
        try {
          filePath = await Future.any([
            CacheManagerUtils.instance.getFile(url, ResourceType.audio),
            Future.delayed(const Duration(seconds: 3), () => null)
          ]);

          if (filePath == null) {
            // 超时后直接使用URL播放
            print("缓存获取超时，直接使用URL播放: $url");
          }
        } catch (e) {
          print("获取缓存文件出错: $e");
          // 出错时继续使用URL播放
        }
      }
      if (url == null && filePath == null) {
        return;
      }
      print(url);
      print(filePath);

      double expandAudioSpeed = playbackRate ?? Get.find<ConfigController>().userSetting.value.expandAudioSpeed;

      await _audioPlayerEx?.playFileOrNetSync(
        url: url,
        filePath: filePath,
        playbackRate: expandAudioSpeed,
        timeout: const Duration(seconds: 3),
      );
    } catch (_) {
      
    }
  }

  /// 停止所有音频
  Future<void> stopAll() async {
    print('[PlayAudioUtils] stopAll() 被调用');
    await _audioPlayerEx?.stop();
  }
}
