// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

enum KnowledgeTypeEnum{
  /// 单词
  EN_WORD("EN_WORD", "单词"), 
  /// 短语
  EN_PHRASE("EN_PHRASE", "短语"), 
  /// 句子
  EN_SENTENCE("EN_SENTENCE", "句子"),
  /// 词素
  EN_MORPHEME("EN_MORPHEME", "词素"),
  /// 文章
  EN_TEXT("EN_TEXT", "文章"),
  /// 专栏
  EN_REVEAL("EN_REVEAL", "专栏"),
  /// 歌曲
  EN_SONG("EN_SONG", "歌曲"),
  /// 剧本
  SCRIPT("SCRIPT", "剧本");

  const KnowledgeTypeEnum(this.value, this.name);

  final String value;
  final String name;

  static KnowledgeTypeEnum? fromRawValue(String value) {
    KnowledgeTypeEnum? type = values.firstWhereOrNull(
      (element) => element.value == value
    );
    return type;
  }
}