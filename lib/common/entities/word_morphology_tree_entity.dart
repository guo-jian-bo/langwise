import 'entities.dart';

class WordMorphologyTreeBranchEntity {
  int? order;
  String? type;
  String? pos;
  String? morphemeNid;
  int? contentId;
  String? content;
  String? key;
  List<LanguageText?>? summary;
  List<KnowledgeCommonEntityList?>? siblings;

  WordMorphologyTreeBranchEntity({
    this.order,
    this.type,
    this.pos,
    this.morphemeNid,
    this.contentId,
    this.content,
    this.key,
    this.summary,
    this.siblings,
  });

  WordMorphologyTreeBranchEntity.fromJson(Map<String, dynamic> json) {
    order = json['order']?.toInt();
    type = json['type']?.toString();
    pos = json['pos']?.toString();
    morphemeNid = json['morphemeNid']?.toString();
    contentId = json['contentId']?.toInt();
    content = json['content']?.toString();
    key = json['key']?.toString();
    summary = _parseLanguageTextList(json['summary']);
    if (json['siblings'] != null) {
      final values = json['siblings'];
      final list = <KnowledgeCommonEntityList>[];
      values.forEach((v) {
        list.add(KnowledgeCommonEntityList.fromJson(v));
      });
      siblings = list;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['order'] = order;
    data['type'] = type;
    data['pos'] = pos;
    data['morphemeNid'] = morphemeNid;
    data['contentId'] = contentId;
    data['content'] = content;
    data['key'] = key;
    data['summary'] = summary?.map((e) => e?.toJson()).toList();
    data['siblings'] = siblings?.map((e) => e?.toJson()).toList();
    return data;
  }
}

class WordMorphologyTreeFocusedMorphemeEntity {
  String? nid;
  String? content;
  String? morphemeTypeNid;
  String? formPosition;
  String? attachesToPos;
  String? resultPos;
  int? tier;
  CardContentDifficulty? difficulty;
  List<LanguageText?>? semanticHint;
  List<LanguageText?>? descriptions;
  List<LanguageText?>? etymology;
  List<KnowledgeCommonEntityList?>? exampleWords;

  WordMorphologyTreeFocusedMorphemeEntity({
    this.nid,
    this.content,
    this.morphemeTypeNid,
    this.formPosition,
    this.attachesToPos,
    this.resultPos,
    this.tier,
    this.difficulty,
    this.semanticHint,
    this.descriptions,
    this.etymology,
    this.exampleWords,
  });

  WordMorphologyTreeFocusedMorphemeEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    content = json['content']?.toString();
    morphemeTypeNid = json['morphemeTypeNid']?.toString();
    formPosition = json['formPosition']?.toString();
    attachesToPos = json['attachesToPos']?.toString();
    resultPos = json['resultPos']?.toString();
    tier = json['tier']?.toInt();
    difficulty = json['difficulty'] == null ? null : CardContentDifficulty.fromJson(json['difficulty']);
    semanticHint = _parseLanguageTextList(json['semanticHint']);
    descriptions = _parseLanguageTextList(json['descriptions']);
    etymology = _parseLanguageTextList(json['etymology']);
    if (json['exampleWords'] != null) {
      final values = json['exampleWords'];
      final list = <KnowledgeCommonEntityList>[];
      values.forEach((v) {
        list.add(KnowledgeCommonEntityList.fromJson(v));
      });
      exampleWords = list;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['content'] = content;
    data['morphemeTypeNid'] = morphemeTypeNid;
    data['formPosition'] = formPosition;
    data['attachesToPos'] = attachesToPos;
    data['resultPos'] = resultPos;
    data['tier'] = tier;
    data['difficulty'] = difficulty?.toJson();
    data['semanticHint'] = semanticHint?.map((e) => e?.toJson()).toList();
    data['descriptions'] = descriptions?.map((e) => e?.toJson()).toList();
    data['etymology'] = etymology?.map((e) => e?.toJson()).toList();
    data['exampleWords'] = exampleWords?.map((e) => e?.toJson()).toList();
    return data;
  }
}

class WordMorphologyTreeEntity {
  int? contentId;
  String? content;
  String? lemma;
  String? pos;
  List<LanguageText?>? translate;
  List<LanguageText?>? gloss;
  CardContentDifficulty? difficulty;
  List<LanguageText?>? descriptions;
  WordMorphologyTreeFocusedMorphemeEntity? focusedMorpheme;
  List<WordMorphologyTreeBranchEntity?>? branches;

  WordMorphologyTreeEntity({
    this.contentId,
    this.content,
    this.lemma,
    this.pos,
    this.translate,
    this.gloss,
    this.difficulty,
    this.descriptions,
    this.focusedMorpheme,
    this.branches,
  });

  WordMorphologyTreeEntity.fromJson(Map<String, dynamic> json) {
    contentId = json['contentId']?.toInt();
    content = json['content']?.toString();
    lemma = json['lemma']?.toString();
    pos = json['pos']?.toString();
    translate = _parseLanguageTextList(json['translate']);
    gloss = _parseLanguageTextList(json['gloss']);
    difficulty = json['difficulty'] == null ? null : CardContentDifficulty.fromJson(json['difficulty']);
    descriptions = _parseLanguageTextList(json['descriptions']);
    focusedMorpheme = json['focusedMorpheme'] == null
        ? null
        : WordMorphologyTreeFocusedMorphemeEntity.fromJson(json['focusedMorpheme']);
    if (json['branches'] != null) {
      final values = json['branches'];
      final list = <WordMorphologyTreeBranchEntity>[];
      values.forEach((v) {
        list.add(WordMorphologyTreeBranchEntity.fromJson(v));
      });
      branches = list;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['contentId'] = contentId;
    data['content'] = content;
    data['lemma'] = lemma;
    data['pos'] = pos;
    data['translate'] = translate?.map((e) => e?.toJson()).toList();
    data['gloss'] = gloss?.map((e) => e?.toJson()).toList();
    data['difficulty'] = difficulty?.toJson();
    data['descriptions'] = descriptions?.map((e) => e?.toJson()).toList();
    data['focusedMorpheme'] = focusedMorpheme?.toJson();
    data['branches'] = branches?.map((e) => e?.toJson()).toList();
    return data;
  }
}

List<LanguageText?>? _parseLanguageTextList(dynamic value) {
  if (value is! List) return null;
  return value
      .whereType<Map<String, dynamic>>()
      .map((e) => LanguageText.fromJson(e))
      .toList();
}
