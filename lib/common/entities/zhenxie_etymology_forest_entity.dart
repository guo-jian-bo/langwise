import 'entities.dart';

/// 词源森林列表项中的分支文案
/// 接口返回结构为 { "text": [{ "lang": "zh", "text": "绕中心" }, ...] }
class ZhenxieEtymologyForestBranchTextEntity {
  List<LanguageText?>? text;

  ZhenxieEtymologyForestBranchTextEntity({this.text});

  ZhenxieEtymologyForestBranchTextEntity.fromJson(Map<String, dynamic> json) {
    if (json['text'] != null) {
      final v = json['text'];
      final arr0 = <LanguageText>[];
      for (final item in v) {
        arr0.add(LanguageText.fromJson(item));
      }
      text = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (text != null) {
      final v = text;
      final arr0 = [];
      for (final item in v!) {
        arr0.add(item!.toJson());
      }
      data['text'] = arr0;
    }
    return data;
  }
}

/// 词源森林列表项（一片森林一张卡）
class ZhenxieEtymologyForestEntity {
/*
{
  "contentType": "EN_WORD",
  "contentId": 103508,
  "content": "around",
  "contentKey": "around",
  "pos": "PREPOSITION",
  "semanticCount": 9,
  "branchCount": 3,
  "coreText": [
    { "lang": "zh", "text": "绕圈与周围" }
  ],
  "gloss": [
    { "lang": "zh", "text": "..." }
  ],
  "descriptions": [
    { "lang": "zh", "text": "..." }
  ],
  "branchTexts": [
    { "text": [{ "lang": "zh", "text": "绕中心" }] }
  ]
}
*/

  /// 内容类型：EN_WORD 单词 / EN_PHRASE 短语
  String? contentType;
  int? contentId;
  /// 词头
  String? content;
  String? contentKey;
  /// 词性
  String? pos;
  /// 义项数
  int? semanticCount;
  /// 分支数
  int? branchCount;
  /// 根上一句话
  List<LanguageText?>? coreText;
  /// 根下释义
  List<LanguageText?>? gloss;
  /// 卡片描述
  List<LanguageText?>? descriptions;
  /// 各分支文案
  List<ZhenxieEtymologyForestBranchTextEntity?>? branchTexts;

  ZhenxieEtymologyForestEntity({
    this.contentType,
    this.contentId,
    this.content,
    this.contentKey,
    this.pos,
    this.semanticCount,
    this.branchCount,
    this.coreText,
    this.gloss,
    this.descriptions,
    this.branchTexts,
  });

  ZhenxieEtymologyForestEntity.fromJson(Map<String, dynamic> json) {
    contentType = json['contentType']?.toString();
    contentId = json['contentId']?.toInt();
    content = json['content']?.toString();
    contentKey = json['contentKey']?.toString();
    pos = json['pos']?.toString();
    semanticCount = json['semanticCount']?.toInt();
    branchCount = json['branchCount']?.toInt();
    if (json['coreText'] != null) {
      final v = json['coreText'];
      final arr0 = <LanguageText>[];
      for (final item in v) {
        arr0.add(LanguageText.fromJson(item));
      }
      coreText = arr0;
    }
    if (json['gloss'] != null) {
      final v = json['gloss'];
      final arr0 = <LanguageText>[];
      for (final item in v) {
        arr0.add(LanguageText.fromJson(item));
      }
      gloss = arr0;
    }
    if (json['descriptions'] != null) {
      final v = json['descriptions'];
      final arr0 = <LanguageText>[];
      for (final item in v) {
        arr0.add(LanguageText.fromJson(item));
      }
      descriptions = arr0;
    }
    if (json['branchTexts'] != null) {
      final v = json['branchTexts'];
      final arr0 = <ZhenxieEtymologyForestBranchTextEntity>[];
      for (final item in v) {
        arr0.add(ZhenxieEtymologyForestBranchTextEntity.fromJson(item));
      }
      branchTexts = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['contentType'] = contentType;
    data['contentId'] = contentId;
    data['content'] = content;
    data['contentKey'] = contentKey;
    data['pos'] = pos;
    data['semanticCount'] = semanticCount;
    data['branchCount'] = branchCount;
    if (coreText != null) {
      final v = coreText;
      final arr0 = [];
      for (final item in v!) {
        arr0.add(item!.toJson());
      }
      data['coreText'] = arr0;
    }
    if (gloss != null) {
      final v = gloss;
      final arr0 = [];
      for (final item in v!) {
        arr0.add(item!.toJson());
      }
      data['gloss'] = arr0;
    }
    if (descriptions != null) {
      final v = descriptions;
      final arr0 = [];
      for (final item in v!) {
        arr0.add(item!.toJson());
      }
      data['descriptions'] = arr0;
    }
    if (branchTexts != null) {
      final v = branchTexts;
      final arr0 = [];
      for (final item in v!) {
        arr0.add(item!.toJson());
      }
      data['branchTexts'] = arr0;
    }
    return data;
  }
}
