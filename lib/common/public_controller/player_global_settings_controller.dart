
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../utils/utils.dart';
import 'config_controller.dart';

/// 播放器全局设置控制器
class PlayerGlobalSettingsController extends GetxController {
  Worker? _speedSettingWorker;
  
  /// 字幕显示 本地获取
  final Rx<LangPreference> subtitleDisplay = LangPreference.bilingual.obs;

  /// 倍速列表 从用户设置获取
  final RxList<double> expandAudioSpeedList = <double>[0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].obs;

  /// 播放速度 从用户设置获取
  final RxDouble playbackRate = 1.0.obs;

  /// 播放模式 本地获取
  final Rx<PlayerModeEnum> audioControlPlayOrder = PlayerModeEnum.list.obs;

  /// 循环次数 本地获取
  final RxInt audioLoopCount = 1.obs;

  /// 文字大小 本地获取
  final Rx<FontSizeEnum> audioFontSize = FontSizeEnum.standard.obs;

  /// 当前音量 本地获取
  final RxInt volume = 100.obs;

  /// 视频填充方式 本地获取
  final Rx<VideoFitEnum> fit = VideoFitEnum.contain.obs;

  /// 初始化设置
  Future<void> initSettings() async {
    final ConfigController configController = Get.find<ConfigController>();
    playbackRate.value = configController.userSetting.value.expandAudioSpeed;
    expandAudioSpeedList.assignAll(configController.userSetting.value.expandAudioSpeedList);
    _speedSettingWorker?.dispose();
    _speedSettingWorker = ever(configController.userSetting, (value) {
      playbackRate.value = value.expandAudioSpeed;
      expandAudioSpeedList.assignAll(value.expandAudioSpeedList);
    });

    AudioControlSettingModel? setting = AudioControlUtils.getSetting();
    if(setting == null) return;
    subtitleDisplay.value = setting.translate ?? LangPreference.bilingual;
    audioControlPlayOrder.value = setting.playOrder ?? PlayerModeEnum.list;
    audioLoopCount.value = setting.playOrderLoopCount ?? 1;
    audioFontSize.value = setting.fontSize ?? FontSizeEnum.standard;
    volume.value = setting.volume ?? 100;
    fit.value = setting.fit ?? VideoFitEnum.contain;
  }

  /// 改变字幕显示
  Future<void> onSubtitleDisplayChange(LangPreference value) async {
    subtitleDisplay.value = value;
    AudioControlUtils.saveSetting(AudioControlSettingModel(translate: value));
  }

  /// 改变播放倍速
  Future<void> onPlaybackRateChange(double value) async {
    playbackRate.value = value;
    AudioControlUtils.saveSetting(AudioControlSettingModel(playbackRate: value));
    ConfigController configController = Get.find<ConfigController>();
    configController.setUserSetting(expandAudioSpeed: value);
  }

  /// 改变播放模式
  Future<void> onPlayOrderChange(PlayerModeEnum value) async {
    audioControlPlayOrder.value = value;
    AudioControlUtils.saveSetting(AudioControlSettingModel(playOrder: value));
  }

  /// 改变循环次数
  Future<void> onLoopCountChange(int value) async {
    audioLoopCount.value = value;
    AudioControlUtils.saveSetting(AudioControlSettingModel(playOrderLoopCount: value));
  }

  /// 改变文字大小
  Future<void> onFontSizeChange(FontSizeEnum value) async {
    audioFontSize.value = value;
    AudioControlUtils.saveSetting(AudioControlSettingModel(fontSize: value));
  }

  /// 改变音量
  Future<void> onVolumeChange(int value) async {
    volume.value = value;
    AudioControlUtils.saveSetting(AudioControlSettingModel(volume: value));
  }

  /// 改变视频填充方式
  Future<void> onFitChange(VideoFitEnum value) async {
    fit.value = value;
    AudioControlUtils.saveSetting(AudioControlSettingModel(fit: value));
  }
  
  @override
  void onClose() {
    _speedSettingWorker?.dispose();
    super.onClose();
  }
}
