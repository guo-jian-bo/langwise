// ignore_for_file: constant_identifier_names

/// 单元语法详情里 unified grammar struct 的类型枚举。
///
/// 该枚举对应 `course_unit_target_grammar.json` 中 `groups[].type`，
/// 后续页面需要基于它决定渲染哪一种语法卡片。
enum ZhenxieEnSentenceType {
  /// 句型蓝图
  EN_SENTENCE_PATTERN("EN_SENTENCE_PATTERN"),

  /// 句型金字塔
  EN_SENTENCE_PYRAMID("EN_SENTENCE_PYRAMID"),

  /// 句间配链。
  EN_SENTENCE_PATTERN_PAIR("EN_SENTENCE_PATTERN_PAIR"),

  /// 句间配链分叉。
  EN_SENTENCE_PATTERN_PAIR_FORK("EN_SENTENCE_PATTERN_PAIR_FORK"),

  /// 句型对照。
  EN_SENTENCE_PARADIGM("EN_SENTENCE_PARADIGM"),

  /// 语法全景宫格。
  EN_SENTENCE_GRAMMAR_GRID("EN_SENTENCE_GRAMMAR_GRID");

  final String rawValue;

  const ZhenxieEnSentenceType(this.rawValue);

  /// 按 unified type 原始值解析枚举。
  static ZhenxieEnSentenceType? fromRawValue(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) return null;
    for (final item in ZhenxieEnSentenceType.values) {
      if (item.rawValue == rawValue) return item;
    }
    return null;
  }
}


enum ZhenxieEnSentenceAssetKind{
  pattern("pattern", "句型蓝图"),
  pair("pair", "句型对照"),
  pairFork("pair_fork", "配句分叉"),
  paradigm("paradigm", "句型对照"),
  pyramid("pyramid", "句子金字塔"),
  grid("grid", "语法全景");

  final String value;
  final String name;

  const ZhenxieEnSentenceAssetKind(this.value, this.name);

  static ZhenxieEnSentenceAssetKind? fromValue(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final item in ZhenxieEnSentenceAssetKind.values) {
      if (item.value == value) return item;
    }
    return null;
  }


}