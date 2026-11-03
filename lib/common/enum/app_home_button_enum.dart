import '../widgets/guide_engine/guide_engine.dart';

enum AppHomeButtonEnum {
  /// 首页
  home("home", "HOME", GuideWidgetIds.homeNavButton, "assets/images/application/nav_main.webp"),
  /// 学习探索
  search("search", "学习探索", GuideWidgetIds.homeSearchNavButton, "assets/images/application/nav_search.webp"),
  /// 分阶时文
  zhenTing("zhenTing", "分阶时文", GuideWidgetIds.homeZhenTingNavButton, "assets/images/application/nav_exlisten.webp"),
  /// 甄读剧场
  script("script", "甄读剧场", GuideWidgetIds.homeScriptNavButton, "assets/images/application/nav_exread.png"),
  /// 情境金曲
  music("music", "情境金曲", GuideWidgetIds.homeMusicNavButton, "assets/images/application/nav_music.webp"),
  /// 语境词典
  dictionary("dictionary", "语境词典", GuideWidgetIds.homeDictionaryNavButton, "assets/images/application/nav_card.webp"),
  /// 自拼音标
  pronunciation("pronunciation", "自拼音标", GuideWidgetIds.homePronunciationNavButton, "assets/images/application/nav_specialized_courses.webp"),

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
