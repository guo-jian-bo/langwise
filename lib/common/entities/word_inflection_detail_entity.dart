import 'entities.dart';

class WordInflectionDetailEntity {
  String? uid;
  String? familyKey;
  String? lemma;
  String? pos;
  int? baseWordId;
  List<String?>? grammaticalTypeNids;
  List<String?>? allowedInflectionTypeNids;
  List<WordInflectionDetailParadigmEntity?>? paradigms;
  List<WordInflectionDetailSemanticEntity?>? semantics;

  WordInflectionDetailEntity({
    this.uid,
    this.familyKey,
    this.lemma,
    this.pos,
    this.baseWordId,
    this.grammaticalTypeNids,
    this.allowedInflectionTypeNids,
    this.paradigms,
    this.semantics,
  });

  WordInflectionDetailEntity.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toString();
    familyKey = json['familyKey']?.toString();
    lemma = json['lemma']?.toString();
    pos = json['pos']?.toString();
    baseWordId = json['baseWordId']?.toInt();
    grammaticalTypeNids = _parseStringList(json['grammaticalTypeNids']);
    allowedInflectionTypeNids = _parseStringList(json['allowedInflectionTypeNids']);
    if (json['paradigms'] is List) {
      paradigms = (json['paradigms'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => WordInflectionDetailParadigmEntity.fromJson(e))
          .toList();
    }
    if (json['semantics'] is List) {
      semantics = (json['semantics'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => WordInflectionDetailSemanticEntity.fromJson(e))
          .toList();
    }
  }
}

class WordInflectionDetailParadigmEntity {
  String? uid;
  String? familyKey;
  int? baseWordId;
  List<int?>? semanticIds;
  List<String?>? grammaticalTypeNids;
  List<String?>? allowedInflectionTypeNids;
  List<WordInflectionDetailSlotEntity?>? slots;

  WordInflectionDetailParadigmEntity({
    this.uid,
    this.familyKey,
    this.baseWordId,
    this.semanticIds,
    this.grammaticalTypeNids,
    this.allowedInflectionTypeNids,
    this.slots,
  });

  WordInflectionDetailParadigmEntity.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toString();
    familyKey = json['familyKey']?.toString();
    baseWordId = json['baseWordId']?.toInt();
    if (json['semanticIds'] is List) {
      semanticIds = (json['semanticIds'] as List).map<int?>((e) => e?.toInt()).toList();
    }
    grammaticalTypeNids = _parseStringList(json['grammaticalTypeNids']);
    allowedInflectionTypeNids = _parseStringList(json['allowedInflectionTypeNids']);
    if (json['slots'] is List) {
      slots = (json['slots'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => WordInflectionDetailSlotEntity.fromJson(e))
          .toList();
    }
  }
}

class WordInflectionDetailSlotEntity {
  String? typeNid;
  String? kind;
  int? contentId;
  String? contentType;
  WordInflectionDetailContentCardEntity? contentCard;
  String? content;
  String? surface;
  List<LanguageText?>? descriptions;
  List<WordInflectionDetailSlotVariantEntity?>? variants;
  String? syncretismLabel;
  bool? created;
  bool? isPrimary;

  WordInflectionDetailSlotEntity({
    this.typeNid,
    this.kind,
    this.contentId,
    this.contentType,
    this.contentCard,
    this.content,
    this.surface,
    this.descriptions,
    this.variants,
    this.syncretismLabel,
    this.created,
    this.isPrimary,
  });

  WordInflectionDetailSlotEntity.fromJson(Map<String, dynamic> json) {
    typeNid = json['typeNid']?.toString();
    kind = json['kind']?.toString();
    contentId = json['contentId']?.toInt();
    contentType = json['contentType']?.toString();
    if (json['contentCard'] is Map<String, dynamic>) {
      contentCard = WordInflectionDetailContentCardEntity.fromJson(json['contentCard']);
    }
    content = json['content']?.toString();
    surface = json['surface']?.toString();
    descriptions = _parseLanguageTexts(json['descriptions']);
    if (json['variants'] is List) {
      variants = (json['variants'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => WordInflectionDetailSlotVariantEntity.fromJson(e))
          .toList();
    }
    syncretismLabel = json['syncretismLabel']?.toString();
    created = json['created'];
    isPrimary = json['isPrimary'];
  }
}

class WordInflectionDetailContentCardEntity {
  int? contentId;
  String? content;
  String? definition;
  List<LanguageText?>? gloss;
  List<LanguageText?>? translate;
  List<PronunciationsEntity?>? pronunciations;

  WordInflectionDetailContentCardEntity({
    this.contentId,
    this.content,
    this.definition,
    this.gloss,
    this.translate,
    this.pronunciations,
  });

  WordInflectionDetailContentCardEntity.fromJson(Map<String, dynamic> json) {
    contentId = json['contentId']?.toInt();
    content = json['content']?.toString();
    definition = json['definition']?.toString();
    gloss = _parseLanguageTexts(json['gloss']);
    translate = _parseLanguageTexts(json['translate']);
    if (json['pronunciations'] is List) {
      pronunciations = (json['pronunciations'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => PronunciationsEntity.fromJson(e))
          .toList();
    }
  }
}

class WordInflectionDetailSlotVariantEntity {
  String? surface;
  bool? isPrimary;

  WordInflectionDetailSlotVariantEntity({
    this.surface,
    this.isPrimary,
  });

  WordInflectionDetailSlotVariantEntity.fromJson(Map<String, dynamic> json) {
    surface = json['surface']?.toString();
    isPrimary = json['isPrimary'];
  }
}

class WordInflectionDetailSemanticEntity {
  int? semanticId;
  List<LanguageText?>? translate;
  List<LanguageText?>? gloss;
  String? imageUrl;
  List<String?>? grammaticalTypeNids;
  bool? shared;

  WordInflectionDetailSemanticEntity({
    this.semanticId,
    this.translate,
    this.gloss,
    this.imageUrl,
    this.grammaticalTypeNids,
    this.shared,
  });

  WordInflectionDetailSemanticEntity.fromJson(Map<String, dynamic> json) {
    semanticId = json['semanticId']?.toInt();
    translate = _parseLanguageTexts(json['translate']);
    gloss = _parseLanguageTexts(json['gloss']);
    imageUrl = json['imageUrl']?.toString();
    grammaticalTypeNids = _parseStringList(json['grammaticalTypeNids']);
    shared = json['shared'];
  }
}

List<String?>? _parseStringList(dynamic value) {
  if (value is! List) return null;
  return value.map((e) => e?.toString()).toList();
}

List<LanguageText?>? _parseLanguageTexts(dynamic value) {
  if (value is! List) return null;
  return value
      .whereType<Map<String, dynamic>>()
      .map((e) => LanguageText.fromJson(e))
      .toList();
}
