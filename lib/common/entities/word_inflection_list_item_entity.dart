import 'entities.dart';

class WordInflectionListItemEntity {
  String? uid;
  String? familyKey;
  String? lemma;
  String? pos;
  int? baseWordId;
  List<String?>? grammaticalTypeNids;
  int? semanticCount;
  List<LanguageText?>? descriptions;
  int? missingCount;
  List<String?>? previewSurfaces;
  String? updated;

  WordInflectionListItemEntity({
    this.uid,
    this.familyKey,
    this.lemma,
    this.pos,
    this.baseWordId,
    this.grammaticalTypeNids,
    this.semanticCount,
    this.descriptions,
    this.missingCount,
    this.previewSurfaces,
    this.updated,
  });

  WordInflectionListItemEntity.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toString();
    familyKey = json['familyKey']?.toString();
    lemma = json['lemma']?.toString();
    pos = json['pos']?.toString();
    baseWordId = json['baseWordId']?.toInt();
    grammaticalTypeNids = _parseStringList(json['grammaticalTypeNids']);
    semanticCount = json['semanticCount']?.toInt();
    descriptions = _parseLanguageTextList(json['descriptions']);
    missingCount = json['missingCount']?.toInt();
    previewSurfaces = _parseStringList(json['previewSurfaces']);
    updated = json['updated']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['familyKey'] = familyKey;
    data['lemma'] = lemma;
    data['pos'] = pos;
    data['baseWordId'] = baseWordId;
    data['grammaticalTypeNids'] = grammaticalTypeNids;
    data['semanticCount'] = semanticCount;
    data['descriptions'] = descriptions?.map((e) => e?.toJson()).toList();
    data['missingCount'] = missingCount;
    data['previewSurfaces'] = previewSurfaces;
    data['updated'] = updated;
    return data;
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
