import 'entities.dart';

class WordMorphologyWordsPageEntity {
  String? key;
  String? morphologyType;
  String? contentType;
  int? contentId;
  String? nid;
  String? content;
  String? morphemeTypeNid;
  String? formPosition;
  String? pos;
  String? posTitle;
  String? attachesToPos;
  String? resultPos;
  int? tier;
  CardContentDifficulty? difficulty;
  List<LanguageText?>? translate;
  List<LanguageText?>? semanticHint;
  List<LanguageText?>? descriptions;
  List<LanguageText?>? etymology;
  List<String?>? exampleWords;
  int? memberCount;
  ListResponseEntity<CardMorphemeWordEntityDatas>? data;

  WordMorphologyWordsPageEntity({
    this.key,
    this.morphologyType,
    this.contentType,
    this.contentId,
    this.nid,
    this.content,
    this.morphemeTypeNid,
    this.formPosition,
    this.pos,
    this.posTitle,
    this.attachesToPos,
    this.resultPos,
    this.tier,
    this.difficulty,
    this.translate,
    this.semanticHint,
    this.descriptions,
    this.etymology,
    this.exampleWords,
    this.memberCount,
    this.data,
  });

  WordMorphologyWordsPageEntity.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
    morphologyType = json['morphologyType']?.toString();
    contentType = json['contentType']?.toString();
    contentId = json['contentId']?.toInt();
    nid = json['nid']?.toString();
    content = json['content']?.toString();
    morphemeTypeNid = json['morphemeTypeNid']?.toString() ?? json['morphologyType']?.toString();
    formPosition = json['formPosition']?.toString();
    pos = json['pos']?.toString();
    posTitle = json['posTitle']?.toString();
    attachesToPos = json['attachesToPos']?.toString();
    resultPos = json['resultPos']?.toString();
    tier = json['tier']?.toInt();
    difficulty = json['difficulty'] == null ? null : CardContentDifficulty.fromJson(json['difficulty']);
    translate = _parseLanguageTextList(json['translate']);
    semanticHint = _parseLanguageTextList(json['semanticHint']);
    descriptions = _parseLanguageTextList(json['descriptions']);
    etymology = _parseLanguageTextList(json['etymology']);
    exampleWords = _parseStringList(json['exampleWords']);
    memberCount = json['memberCount']?.toInt();
    data = json['data'] == null
        ? null
        : ListResponseEntity<CardMorphemeWordEntityDatas>.fromJson(
            json['data'],
            fromJson: CardMorphemeWordEntityDatas.fromJson,
          );
  }

  Map<String, dynamic> toJson() {
    final dataMap = <String, dynamic>{};
    dataMap['key'] = key;
    dataMap['morphologyType'] = morphologyType;
    dataMap['contentType'] = contentType;
    dataMap['contentId'] = contentId;
    dataMap['nid'] = nid;
    dataMap['content'] = content;
    dataMap['morphemeTypeNid'] = morphemeTypeNid;
    dataMap['formPosition'] = formPosition;
    dataMap['pos'] = pos;
    dataMap['posTitle'] = posTitle;
    dataMap['attachesToPos'] = attachesToPos;
    dataMap['resultPos'] = resultPos;
    dataMap['tier'] = tier;
    dataMap['difficulty'] = difficulty?.toJson();
    dataMap['translate'] = translate?.map((e) => e?.toJson()).toList();
    dataMap['semanticHint'] = semanticHint?.map((e) => e?.toJson()).toList();
    dataMap['descriptions'] = descriptions?.map((e) => e?.toJson()).toList();
    dataMap['etymology'] = etymology?.map((e) => e?.toJson()).toList();
    dataMap['exampleWords'] = exampleWords;
    dataMap['memberCount'] = memberCount;
    dataMap['data'] = data?.toJson();
    return dataMap;
  }
}

List<String?>? _parseStringList(dynamic value) {
  if (value is! List) return null;
  return value.map((e) => e?.toString()).toList();
}

List<LanguageText?>? _parseLanguageTextList(dynamic value) {
  if (value is! List) return null;
  return value
      .whereType<Map<String, dynamic>>()
      .map((e) => LanguageText.fromJson(e))
      .toList();
}
