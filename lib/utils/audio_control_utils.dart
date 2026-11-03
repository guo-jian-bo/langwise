
import 'dart:convert';

import 'package:lib_common/common.dart';
import 'package:video_player/video_player.dart';

import '../common/values/values.dart';

class AudioControlSettingModel {
  /// 倍速
  double? playbackRate;

  /// 播放模式
  PlayerModeEnum? playOrder;

  /// 循环次数
  int? playOrderLoopCount;

  /// 文字大小倍数
  double? fontSizeMultiple;

  /// 文字大小
  FontSizeEnum? fontSize;
  
  /// 音量
  int? volume;

  /// 翻译配置
  LangPreference? translate;

  /// 视频填充方式
  VideoFitEnum? fit;
  
  AudioControlSettingModel({
    this.playbackRate,
    this.playOrder,
    this.playOrderLoopCount,
    this.fontSizeMultiple,
    this.translate,
    this.fontSize,
    this.volume,
    this.fit,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    if (playbackRate != null) {
      map['playbackRate'] = playbackRate;
    }
    if (playOrder != null) {
      map['playOrder'] = playOrder!.value;
    }
    if (playOrderLoopCount != null) {
      map['playOrderLoopCount'] = playOrderLoopCount;
    }
    if (fontSizeMultiple != null) {
      map['fontSizeMultiple'] = fontSizeMultiple;
    }
    if(translate != null){
      map['translate'] = translate!.code;
    }
    if(fontSize != null){
      map['fontSize'] = fontSize!.value;
    }
    if(volume != null){
      map['volume'] = volume;
    }
    if(fit != null){
      map['fit'] = fit!.value;
    }
    return map;
  }

  AudioControlSettingModel.fromJson(Map map) {
    if (map['playbackRate'] != null) {
      playbackRate = map['playbackRate']?.toDouble();
    }
    if (map['playOrder'] != null) {
      playOrder = PlayerModeEnum.fromRawValue(map['playOrder']);
    }
    if (map['playOrderLoopCount'] != null) {
      playOrderLoopCount = map['playOrderLoopCount']?.toInt();
    }
    if (map['fontSizeMultiple'] != null) {
      fontSizeMultiple = map['fontSizeMultiple']?.toDouble();
    }
    if(map['translate'] != null){
      translate = LangPreference.fromRawValue(map['translate']);
    }
    if(map['fontSize'] != null){
      fontSize = FontSizeEnum.fromRawValue(map['fontSize']);
    }
    if(map['volume'] != null){
      volume = map['volume']?.toInt();
    }
    if(map['fit'] != null){
      fit = VideoFitEnum.fromValue(map['fit']);
    }
  }
}

class AudioControlUtils {
  /// 储存配置到本地
  static void saveSetting(AudioControlSettingModel setting) {
    String? settingStr = StorageUtil().getString(AUDIO_CONTROL_SETTING_KEY);
    Map settingMap = {};
    if (settingStr.isEmpty) {
      settingMap = setting.toJson();
    } else {
      Map oldSettingMap = jsonDecode(settingStr);
      if (setting.playbackRate != null) {
        oldSettingMap['playbackRate'] = setting.playbackRate;
      }
      if (setting.fontSizeMultiple != null) {
        oldSettingMap['fontSizeMultiple'] = setting.fontSizeMultiple;
      }
      if (setting.playOrder != null) {
        oldSettingMap['playOrder'] = setting.playOrder!.value;
      }
      if (setting.playOrderLoopCount != null) {
        oldSettingMap['playOrderLoopCount'] = setting.playOrderLoopCount;
      }
      if(setting.translate != null){
        oldSettingMap['translate'] = setting.translate!.code;
      }
      if(setting.fontSize != null){
        oldSettingMap['fontSize'] = setting.fontSize!.value;
      }
      if(setting.volume != null){
        oldSettingMap['volume'] = setting.volume;
      }
      if(setting.fit != null){
        oldSettingMap['fit'] = setting.fit!.value;
      }
      settingMap = oldSettingMap;
    }
    StorageUtil().setString(AUDIO_CONTROL_SETTING_KEY, jsonEncode(settingMap));
  }

  /// 获取本地储存配置
  static AudioControlSettingModel? getSetting() {
    String settingStr = StorageUtil().getString(AUDIO_CONTROL_SETTING_KEY);
    if (settingStr.isEmpty) return null;
    try {
      Map settingMap = jsonDecode(settingStr);
      return AudioControlSettingModel.fromJson(settingMap);
    } catch (e) {
      return null;
    }
  }
}