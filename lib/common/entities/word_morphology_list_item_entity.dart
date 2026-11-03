import 'entities.dart';

class WordMorphologyListItemEntity {
  String? nid;
  String? content;
  String? morphemeTypeNid;
  String? formPosition;
  String? formPositionTitle;
  String? attachesToPos;
  String? resultPos;
  int? tier;
  String? tierTitle;
  String? tierColor;
  List<LanguageConfigColorEntityThemeColors?>? tierColors;
  CardContentDifficulty? difficulty;
  List<LanguageText?>? semanticHint;
  List<LanguageText?>? descriptions;
  List<LanguageText?>? etymology;
  List<String?>? exampleWords;
  int? memberCount;
  List<int?>? memberWordIds;

  WordMorphologyListItemEntity({
    this.nid,
    this.content,
    this.morphemeTypeNid,
    this.formPosition,
    this.formPositionTitle,
    this.attachesToPos,
    this.resultPos,
    this.tier,
    this.tierTitle,
    this.tierColor,
    this.tierColors,
    this.difficulty,
    this.semanticHint,
    this.descriptions,
    this.etymology,
    this.exampleWords,
    this.memberCount,
    this.memberWordIds,
  });

  WordMorphologyListItemEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    content = json['content']?.toString();
    morphemeTypeNid = json['morphemeTypeNid']?.toString();
    formPosition = json['formPosition']?.toString();
    formPositionTitle = json['formPositionTitle']?.toString();
    attachesToPos = json['attachesToPos']?.toString();
    resultPos = json['resultPos']?.toString();
    tier = json['tier']?.toInt();
    tierTitle = json['tierTitle']?.toString();
    tierColor = json['tierColor']?.toString();
    tierColors = _parseThemeColorList(json['tierColors']);
    difficulty = json['difficulty'] == null ? null : CardContentDifficulty.fromJson(json['difficulty']);
    semanticHint = _parseLanguageTextList(json['semanticHint']);
    descriptions = _parseLanguageTextList(json['descriptions']);
    etymology = _parseLanguageTextList(json['etymology']);
    exampleWords = _parseStringList(json['exampleWords']);
    memberCount = json['memberCount']?.toInt();
    memberWordIds = _parseIntList(json['memberWordIds']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['content'] = content;
    data['morphemeTypeNid'] = morphemeTypeNid;
    data['formPosition'] = formPosition;
    data['formPositionTitle'] = formPositionTitle;
    data['attachesToPos'] = attachesToPos;
    data['resultPos'] = resultPos;
    data['tier'] = tier;
    data['tierTitle'] = tierTitle;
    data['tierColor'] = tierColor;
    data['tierColors'] = tierColors?.map((e) => e?.toJson()).toList();
    data['difficulty'] = difficulty?.toJson();
    data['semanticHint'] = semanticHint?.map((e) => e?.toJson()).toList();
    data['descriptions'] = descriptions?.map((e) => e?.toJson()).toList();
    data['etymology'] = etymology?.map((e) => e?.toJson()).toList();
    data['exampleWords'] = exampleWords;
    data['memberCount'] = memberCount;
    data['memberWordIds'] = memberWordIds;
    return data;
  }
}

List<String?>? _parseStringList(dynamic value) {
  if (value is! List) return null;
  return value.map((e) => e?.toString()).toList();
}

List<int?>? _parseIntList(dynamic value) {
  if (value is! List) return null;
  return value.map((e) => e is num ? e.toInt() : int.tryParse(e?.toString() ?? '')).toList();
}

List<LanguageText?>? _parseLanguageTextList(dynamic value) {
  if (value is! List) return null;
  return value
      .whereType<Map<String, dynamic>>()
      .map((e) => LanguageText.fromJson(e))
      .toList();
}

List<LanguageConfigColorEntityThemeColors?>? _parseThemeColorList(dynamic value) {
  if (value is! List) return null;
  return value
      .whereType<Map<String, dynamic>>()
      .map((e) => LanguageConfigColorEntityThemeColors.fromJson(e))
      .toList();
}
