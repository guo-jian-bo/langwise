import '../widgets/guide_engine/guide_engine.dart';

enum AppHomeButtonEnum {
  /// 首页
  home("home", "HOME", GuideWidgetIds.homeNavButton, "assets/images/application/nav_main.webp"),
  /// 甄听
  zhenTing("zhenTing", "时文", GuideWidgetIds.homeZhenTingNavButton, "assets/images/application/nav_exlisten.webp"),
  /// 剧场
  script("script", "剧场", GuideWidgetIds.homeScriptNavButton, "assets/images/application/nav_exread.png"),
  /// 音乐
  music("music", "音乐", GuideWidgetIds.homeMusicNavButton, "assets/images/application/nav_music.webp"),
  /// 词典
  dictionary("dictionary", "词典", GuideWidgetIds.homeDictionaryNavButton, "assets/images/application/nav_card.webp"),
  /// 发音课
  pronunciation("pronunciation", "发音课", GuideWidgetIds.homePronunciationNavButton, "assets/images/application/nav_specialized_courses.webp"),

  /// 管理
  management("management", "管理", "", "assets/images/application/nav_manage_new.webp");


  const AppHomeButtonEnum(this.value, this.name, this.widgetId, this.imagePath);

  /// 值
  final String value;

  /// 名称
  final String name;

  /// 引导组件ID
  final String widgetId;

  /// 图片路径
  final String imagePath;

}