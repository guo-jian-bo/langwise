import 'entities.dart';

class CardPhraseSemanticItem {
  String? contentType;
  int? contentId;
  int? semanticId;
  String? pos;
  String? posAddr;
  List<LanguageText?>? posTitle;
  String? translate;
  List<ThemeTextStyleEntity?>? textStyle;

  CardPhraseSemanticItem({
    this.contentType,
    this.contentId,
    this.semanticId,
    this.pos,
    this.posAddr,
    this.posTitle,
    this.translate,
    this.textStyle,
  });

  CardPhraseSemanticItem.fromJson(Map<String, dynamic> json) {
    contentType = json['contentType']?.toString();
    contentId = json['contentId']?.toInt();
    semanticId = json['semanticId']?.toInt();
    pos = json['pos']?.toString();
    posAddr = json['posAddr']?.toString();
    if (json['posTitle'] != null) {
      final List<LanguageText> items = [];
      for (final dynamic item in json['posTitle']) {
        items.add(LanguageText.fromJson(item));
      }
      posTitle = items;
    }
    translate = json['translate']?.toString();
    if (json['textStyle'] != null) {
      final List<ThemeTextStyleEntity> items = [];
      for (final dynamic item in json['textStyle']) {
        items.add(ThemeTextStyleEntity.fromJson(item));
      }
      textStyle = items;
    }
  }
}

class CardPhraseSemantic {
  int? uid;
  String? imageUrl;
  String? imageKey;
  String? imageMd5;
  EnKnowledgeEntityRelationVideo? video;
  List<LanguageText?>? gloss;
  List<LanguageText?>? descriptions;
  int? difficulty;
  int? contentId;
  int? semanticId;
  List<PronunciationsEntity?>? pronunciations;

  CardPhraseSemantic({
    this.uid,
    this.imageUrl,
    this.imageKey,
    this.imageMd5,
    this.video,
    this.gloss,
    this.descriptions,
    this.difficulty,
    this.contentId,
    this.semanticId,
    this.pronunciations,
  });

  CardPhraseSemantic.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    imageUrl = json['imageUrl']?.toString();
    imageKey = json['imageKey']?.toString();
    imageMd5 = json['imageMd5']?.toString();
    if (json['video'] != null) {
      video = EnKnowledgeEntityRelationVideo.fromJson(json['video']);
    }
    if (json['gloss'] != null) {
      final List<LanguageText> items = [];
      for (final dynamic item in json['gloss']) {
        items.add(LanguageText.fromJson(item));
      }
      gloss = items;
    }
    if (json['descriptions'] != null) {
      final List<LanguageText> items = [];
      for (final dynamic item in json['descriptions']) {
        items.add(LanguageText.fromJson(item));
      }
      descriptions = items;
    }
    difficulty = json['difficulty']?.toInt();
    contentId = json['contentId']?.toInt();
    semanticId = json['semanticId']?.toInt();
    if (json['pronunciations'] != null) {
      final List<PronunciationsEntity> items = [];
      for (final dynamic item in json['pronunciations']) {
        items.add(PronunciationsEntity.fromJson(item));
      }
      pronunciations = items;
    }
  }
}

class CardPhraseStructureItem {
  int? uid;
  String? roleNid;
  int? tokenPosition;
  String? text;

  CardPhraseStructureItem({
    this.uid,
    this.roleNid,
    this.tokenPosition,
    this.text,
  });

  CardPhraseStructureItem.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    roleNid = json['roleNid']?.toString();
    tokenPosition = json['tokenPosition']?.toInt();
    text = json['text']?.toString();
  }
}

class CardPhraseStructure {
  int? uid;
  String? phrasePos;
  List<LanguageText?>? explanations;
  List<CardPhraseStructureItem?>? items;

  CardPhraseStructure({
    this.uid,
    this.phrasePos,
    this.explanations,
    this.items,
  });

  CardPhraseStructure.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    phrasePos = json['phrasePos']?.toString();
    if (json['explanations'] != null) {
      final List<LanguageText> values = [];
      for (final dynamic item in json['explanations']) {
        values.add(LanguageText.fromJson(item));
      }
      explanations = values;
    }
    if (json['items'] != null) {
      final List<CardPhraseStructureItem> values = [];
      for (final dynamic item in json['items']) {
        values.add(CardPhraseStructureItem.fromJson(item));
      }
      items = values;
    }
  }
}

class CardPhraseAnalysisEntryColor {
  String? from;
  String? to;

  CardPhraseAnalysisEntryColor({
    this.from,
    this.to,
  });

  CardPhraseAnalysisEntryColor.fromJson(Map<String, dynamic> json) {
    from = json['from']?.toString();
    to = json['to']?.toString();
  }
}

class CardPhraseAnalysisEntry {
  CardPhraseAnalysisEntryColor? color;
  String? type;
  List<LanguageText?>? title;
  int? index;
  int? status;

  CardPhraseAnalysisEntry({
    this.color,
    this.type,
    this.title,
    this.index,
    this.status,
  });

  CardPhraseAnalysisEntry.fromJson(Map<String, dynamic> json) {
    if (json['color'] != null) {
      color = CardPhraseAnalysisEntryColor.fromJson(json['color']);
    }
    type = json['type']?.toString();
    if (json['title'] != null) {
      final List<LanguageText> values = [];
      for (final dynamic item in json['title']) {
        values.add(LanguageText.fromJson(item));
      }
      title = values;
    }
    index = json['index']?.toInt();
    status = json['status']?.toInt();
  }
}

class CardPhraseSentencePreviewRange {
  int? start;
  int? end;
  String? text;
  String? key;

  CardPhraseSentencePreviewRange({
    this.start,
    this.end,
    this.text,
    this.key,
  });

  CardPhraseSentencePreviewRange.fromJson(Map<String, dynamic> json) {
    start = json['start']?.toInt();
    end = json['end']?.toInt();
    text = json['text']?.toString();
    key = json['key']?.toString();
  }
}

class CardPhraseSentencePreviewItem {
  KnowledgeCommonEntityList? contentCard;
  List<CardPhraseSentencePreviewRange?>? ranges;

  CardPhraseSentencePreviewItem({
    this.contentCard,
    this.ranges,
  });

  CardPhraseSentencePreviewItem.fromJson(Map<String, dynamic> json) {
    if (json['contentCard'] != null) {
      contentCard = KnowledgeCommonEntityList.fromJson(json['contentCard']);
    }
    if (json['ranges'] != null) {
      final List<CardPhraseSentencePreviewRange> values = [];
      for (final dynamic item in json['ranges']) {
        values.add(CardPhraseSentencePreviewRange.fromJson(item));
      }
      ranges = values;
    }
  }
}

class CardPhraseAnalysisSentenceData {
  List<LanguageText?>? grammaticalType;
  String? grammaticalTypeNameZh;
  String? descriptionsZh;
  List<LanguageText?>? descriptions;
  List<List<LanguageText?>?>? sentenceSlotCategory;
  List<String?>? sentenceSlotCategoryNamesZh;
  List<EnterSentenceEntityPreviewGovernedSlots?>? governedSlots;
  List<CardPhraseSentencePreviewItem?>? previewSentences;

  CardPhraseAnalysisSentenceData({
    this.grammaticalType,
    this.grammaticalTypeNameZh,
    this.descriptionsZh,
    this.descriptions,
    this.sentenceSlotCategory,
    this.sentenceSlotCategoryNamesZh,
    this.governedSlots,
    this.previewSentences,
  });

  CardPhraseAnalysisSentenceData.fromJson(Map<String, dynamic> json) {
    if (json['grammaticalType'] != null) {
      final List<LanguageText> values = [];
      for (final dynamic item in json['grammaticalType']) {
        values.add(LanguageText.fromJson(item));
      }
      grammaticalType = values;
    }
    grammaticalTypeNameZh = json['grammaticalTypeNameZh']?.toString();
    descriptionsZh = json['descriptionsZh']?.toString();
    if (json['descriptions'] != null) {
      final List<LanguageText> values = [];
      for (final dynamic item in json['descriptions']) {
        values.add(LanguageText.fromJson(item));
      }
      descriptions = values;
    }
    if (json['sentenceSlotCategory'] != null) {
      final List<List<LanguageText?>?> values = [];
      for (final dynamic item in json['sentenceSlotCategory']) {
        if (item == null) {
          values.add(null);
          continue;
        }
        final List<LanguageText> categoryValues = [];
        for (final dynamic categoryItem in item) {
          categoryValues.add(LanguageText.fromJson(categoryItem));
        }
        values.add(categoryValues);
      }
      sentenceSlotCategory = values;
    }
    if (json['sentenceSlotCategoryNamesZh'] != null) {
      sentenceSlotCategoryNamesZh = (json['sentenceSlotCategoryNamesZh'] as List<dynamic>)
          .map((dynamic item) => item?.toString())
          .toList();
    }
    if (json['governedSlots'] != null) {
      final List<EnterSentenceEntityPreviewGovernedSlots> values = [];
      for (final dynamic item in json['governedSlots']) {
        values.add(EnterSentenceEntityPreviewGovernedSlots.fromJson(item));
      }
      governedSlots = values;
    }
    if (json['previewSentences'] != null) {
      final List<CardPhraseSentencePreviewItem> values = [];
      for (final dynamic item in json['previewSentences']) {
        values.add(CardPhraseSentencePreviewItem.fromJson(item));
      }
      previewSentences = values;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (grammaticalType != null) {
      final List<Map<String, dynamic>> values = [];
      for (final LanguageText? item in grammaticalType!) {
        if (item == null) continue;
        values.add(item.toJson());
      }
      data['grammaticalType'] = values;
    }
    data['grammaticalTypeNameZh'] = grammaticalTypeNameZh;
    data['descriptionsZh'] = descriptionsZh;
    if (descriptions != null) {
      final List<Map<String, dynamic>> values = [];
      for (final LanguageText? item in descriptions!) {
        if (item == null) continue;
        values.add(item.toJson());
      }
      data['descriptions'] = values;
    }
    if (sentenceSlotCategory != null) {
      final List<List<Map<String, dynamic>>> values = [];
      for (final List<LanguageText?>? category in sentenceSlotCategory!) {
        if (category == null) continue;
        final List<Map<String, dynamic>> categoryValues = [];
        for (final LanguageText? item in category) {
          if (item == null) continue;
          categoryValues.add(item.toJson());
        }
        values.add(categoryValues);
      }
      data['sentenceSlotCategory'] = values;
    }
    data['sentenceSlotCategoryNamesZh'] = sentenceSlotCategoryNamesZh;
    if (governedSlots != null) {
      final List<Map<String, dynamic>> values = [];
      for (final EnterSentenceEntityPreviewGovernedSlots? item in governedSlots!) {
        if (item == null) continue;
        values.add(item.toJson());
      }
      data['governedSlots'] = values;
    }
    return data;
  }
}

class CardPhraseAnalysisMemoryBranchText {
  List<LanguageText?>? text;

  CardPhraseAnalysisMemoryBranchText({
    this.text,
  });

  CardPhraseAnalysisMemoryBranchText.fromJson(Map<String, dynamic> json) {
    if (json['text'] != null) {
      final List<LanguageText> values = [];
      for (final dynamic item in json['text']) {
        values.add(LanguageText.fromJson(item));
      }
      text = values;
    }
  }
}

class CardPhraseAnalysisMemoryData {
  List<LanguageText?>? coreText;
  List<LanguageText?>? gloss;
  List<LanguageText?>? descriptions;
  List<CardPhraseAnalysisMemoryBranchText?>? branchTexts;

  CardPhraseAnalysisMemoryData({
    this.coreText,
    this.gloss,
    this.descriptions,
    this.branchTexts,
  });

  CardPhraseAnalysisMemoryData.fromJson(Map<String, dynamic> json) {
    if (json['coreText'] != null) {
      final List<LanguageText> values = [];
      for (final dynamic item in json['coreText']) {
        values.add(LanguageText.fromJson(item));
      }
      coreText = values;
    }
    if (json['gloss'] != null) {
      final List<LanguageText> values = [];
      for (final dynamic item in json['gloss']) {
        values.add(LanguageText.fromJson(item));
      }
      gloss = values;
    }
    if (json['descriptions'] != null) {
      final List<LanguageText> values = [];
      for (final dynamic item in json['descriptions']) {
        values.add(LanguageText.fromJson(item));
      }
      descriptions = values;
    }
    if (json['branchTexts'] != null) {
      final List<CardPhraseAnalysisMemoryBranchText> values = [];
      for (final dynamic item in json['branchTexts']) {
        values.add(CardPhraseAnalysisMemoryBranchText.fromJson(item));
      }
      branchTexts = values;
    }
  }
}

class CardPhraseAnalysisRelationItem {
  String? type;
  String? title;
  String? color;
  int? previewCount;

  CardPhraseAnalysisRelationItem({
    this.type,
    this.title,
    this.color,
    this.previewCount,
  });

  CardPhraseAnalysisRelationItem.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toString();
    title = json['title']?.toString();
    color = json['color']?.toString();
    previewCount = json['previewCount']?.toInt();
  }
}

class CardPhraseAnalysisRelationData {
  List<CardPhraseAnalysisRelationItem?>? items;

  CardPhraseAnalysisRelationData({
    this.items,
  });

  CardPhraseAnalysisRelationData.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      final List<CardPhraseAnalysisRelationItem> values = [];
      for (final dynamic item in json['items']) {
        values.add(CardPhraseAnalysisRelationItem.fromJson(item));
      }
      items = values;
    }
  }
}

class CardPhraseAnalysisSynonymData {
  int? count;

  CardPhraseAnalysisSynonymData({
    this.count,
  });

  CardPhraseAnalysisSynonymData.fromJson(Map<String, dynamic> json) {
    count = json['count']?.toInt();
  }
}

class CardPhraseLexicalSetPreviewItem {
  String? code;
  String? name;
  List<String?>? chips;

  CardPhraseLexicalSetPreviewItem({
    this.code,
    this.name,
    this.chips,
  });

  CardPhraseLexicalSetPreviewItem.fromJson(Map<String, dynamic> json) {
    code = json['code']?.toString();
    name = json['name']?.toString();
    if (json['chips'] != null) {
      final List<String> values = [];
      for (final dynamic item in json['chips']) {
        values.add(item.toString());
      }
      chips = values;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['code'] = code;
    data['name'] = name;
    data['chips'] = chips;
    return data;
  }
}

class CardPhraseAnalysisData {
  CardPhraseAnalysisSentenceData? sentence;
  CardPhraseAnalysisMemoryData? memory;
  CardPhraseAnalysisRelationData? relation;
  CardPhraseAnalysisSynonymData? synonym;
  List<CardPhraseLexicalSetPreviewItem?>? lexicalSetPreview;

  CardPhraseAnalysisData({
    this.sentence,
    this.memory,
    this.relation,
    this.synonym,
    this.lexicalSetPreview,
  });

  CardPhraseAnalysisData.fromJson(Map<String, dynamic> json) {
    if (json['sentence'] != null) {
      sentence = CardPhraseAnalysisSentenceData.fromJson(json['sentence']);
    }
    if (json['memory'] != null) {
      memory = CardPhraseAnalysisMemoryData.fromJson(json['memory']);
    }
    if (json['relation'] != null) {
      relation = CardPhraseAnalysisRelationData.fromJson(json['relation']);
    }
    if (json['synonym'] != null) {
      synonym = CardPhraseAnalysisSynonymData.fromJson(json['synonym']);
    }
    if (json['lexicalSetPreview'] != null) {
      final List<CardPhraseLexicalSetPreviewItem> values = [];
      for (final dynamic item in json['lexicalSetPreview']) {
        values.add(CardPhraseLexicalSetPreviewItem.fromJson(item));
      }
      lexicalSetPreview = values;
    }
  }
}

class CardPhraseSemanticDetilsEntity {
  String? contentType;
  String? content;
  int? contentId;
  int? semanticId;
  List<CardPhraseSemanticItem?>? semanticItems;
  CardPhraseSemantic? semantic;
  LockEntity? rights;
  bool? favorited;
  CardPhraseStructure? structure;
  List<CardPhraseAnalysisEntry?>? analysisEntries;
  CardPhraseAnalysisData? analysisData;
  /// 是否有发音题目
  bool? pronunciationExercise;

  CardPhraseSemanticDetilsEntity({
    this.contentType,
    this.content,
    this.contentId,
    this.semanticId,
    this.semanticItems,
    this.semantic,
    this.rights,
    this.favorited,
    this.structure,
    this.analysisEntries,
    this.analysisData,
    this.pronunciationExercise,
  });

  CardPhraseSemanticDetilsEntity.fromJson(Map<String, dynamic> json) {
    contentType = json['contentType']?.toString();
    content = json['content']?.toString();
    contentId = json['contentId']?.toInt();
    semanticId = json['semanticId']?.toInt();
    if (json['semanticItems'] != null) {
      final List<CardPhraseSemanticItem> values = [];
      for (final dynamic item in json['semanticItems']) {
        values.add(CardPhraseSemanticItem.fromJson(item));
      }
      semanticItems = values;
    }
    if (json['semantic'] != null) {
      semantic = CardPhraseSemantic.fromJson(json['semantic']);
    }
    if (json['rights'] != null) {
      rights = LockEntity.fromJson(json['rights']);
    }
    favorited = json['favorited'];
    if (json['structure'] != null) {
      structure = CardPhraseStructure.fromJson(json['structure']);
    }
    if (json['analysisEntries'] != null) {
      final List<CardPhraseAnalysisEntry> values = [];
      for (final dynamic item in json['analysisEntries']) {
        values.add(CardPhraseAnalysisEntry.fromJson(item));
      }
      analysisEntries = values;
    }
    if (json['analysisData'] != null) {
      analysisData = CardPhraseAnalysisData.fromJson(json['analysisData']);
    }
    pronunciationExercise = json['pronunciationExercise'];
  }
}
