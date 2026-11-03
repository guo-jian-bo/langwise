enum ElementsCardType { 
  none("none", ""),
  /// 单词
  word("EN_WORD", "单词"), 
  /// 短语
  phrase("EN_PHRASE", "短语"), 
  /// 句子
  sentence("EN_SENTENCE", "句子"),
  /// 词素
  morpheme("EN_MORPHEME", "词素"),
  /// 文章
  text("EN_TEXT", "文章"),
  /// 专栏
  reveal("EN_REVEAL", "专栏"),
  /// 歌曲
  song("EN_SONG", "歌曲"),
  /// 写作
  composition("EN_COMPOSITION", "写作"),
  /// 脚本
  script("SCRIPT", "剧本");



  const ElementsCardType(this.value, this.name);

  final String value;
  final String name;

  factory ElementsCardType.fromRawValue(String value) {
    return values.firstWhere(
      (element) => element.value == value,
      orElse: () => ElementsCardType.none,
    );
  }

}