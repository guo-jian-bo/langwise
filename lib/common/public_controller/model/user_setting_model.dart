import '../../entities/entities.dart';
import '../../enum/enum.dart';

class UserSettingModel {
  /// 课程内的菜单
  List<UserPreferenceDefinitionDisplayModeOption>? courseDropdownMenu;

  /// 切换节奏菜单
  List<UserPreferenceIntervalSpeedOption>? intervalMenu;

  /// * 课程内设置语言
  /// * 显示语言的全局设置
  /// * "en"=学习语言，"zh=本土语言，""=双语
  /// * 单词短语正常显示 句子本地语言和双语一样
  LangPreference courseLang;

  /// 课程内音频播放速度配置
  List<double> courseAudioSpeedList;

  /// 课程内音频播放速度
  double courseAudioSpeed;

  /// 拓展内的菜单
  List<UserPreferenceDefinitionDisplayModeOption>? expandDropdownMenu;

  /// 拓展设置语言
  LangPreference expandLang;

  /// 拓展音频播放速度配置
  List<double> expandAudioSpeedList;

  /// 拓展音频播放速度
  double expandAudioSpeed;

  /// 学习语言
  String learningLang;

  /// 本地语言
  String localLang;

  UserSettingModel({
    this.courseLang = LangPreference.original,
    this.courseAudioSpeedList = const [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0],
    this.courseAudioSpeed = 1.0,
    this.expandLang = LangPreference.bilingual,
    this.expandAudioSpeedList = const [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0],
    this.expandAudioSpeed = 1.0,
    this.intervalMenu,
    this.courseDropdownMenu,
    this.expandDropdownMenu,
    this.learningLang = "en",
    this.localLang = "zh",
  });
}
