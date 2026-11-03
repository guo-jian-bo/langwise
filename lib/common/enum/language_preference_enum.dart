

enum LearModePreference{
  /// 课程
  course,

  /// 扩展
  extension,
}

enum LangPreference{

  /// 双语对照
  bilingual(code: "bilingual", langCode: "", name: "双语对照"), 

  /// 原文语言
  original(code: "original", langCode: "en", name: "原文语言"),

  /// 译文语言
  translation(code: "translation", langCode: "zh", name: "译文语言"),

  /// 隐藏文本
  none(code: "none", langCode: "en", name: "隐藏文本");

  final String code;
  final String langCode;
  final String name;

  const LangPreference({
    required this.code,
    required this.langCode,
    required this.name,
  });

  factory LangPreference.fromRawValue(String? code) {
    return values.firstWhere(
      (element) => element.code == code,
      orElse: () => LangPreference.bilingual,
    );
  }


}