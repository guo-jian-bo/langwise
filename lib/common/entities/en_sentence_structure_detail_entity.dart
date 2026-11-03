import 'entities.dart';

class EnSentenceStructureDetailEntity {
  int? contentId;
  String? contentType;
  String? content;
  String? definition;
  int? difficulty;
  EnSentenceStructureDetailStructure? structure;
  List<EnSentenceStructureAnalysisEntry?>? analysisEntries;
  EnSentenceStructureAnalysisData? analysisData;

  EnSentenceStructureDetailEntity({
    this.contentId,
    this.contentType,
    this.content,
    this.definition,
    this.difficulty,
    this.structure,
    this.analysisEntries,
    this.analysisData,
  });

  EnSentenceStructureDetailEntity.fromJson(Map<String, dynamic> json) {
    contentId = json['contentId']?.toInt();
    contentType = json['contentType']?.toString();
    content = json['content']?.toString();
    definition = json['definition']?.toString();
    difficulty = json['difficulty']?.toInt();
    structure = json['structure'] != null
        ? EnSentenceStructureDetailStructure.fromJson(json['structure'])
        : null;
    if (json['analysisEntries'] != null) {
      final List<EnSentenceStructureAnalysisEntry> items = [];
      for (final dynamic item in json['analysisEntries']) {
        items.add(EnSentenceStructureAnalysisEntry.fromJson(item));
      }
      analysisEntries = items;
    }
    analysisData = json['analysisData'] != null
        ? EnSentenceStructureAnalysisData.fromJson(json['analysisData'])
        : null;
  }
}

class EnSentenceStructureNamedInfo {
  int? uid;
  String? nid;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  String? color;
  String? categoryNid;

  EnSentenceStructureNamedInfo({
    this.uid,
    this.nid,
    this.name,
    this.description,
    this.color,
    this.categoryNid,
  });

  EnSentenceStructureNamedInfo.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    nid = json['nid']?.toString();
    if (json['name'] != null) {
      final List<LanguageText> items = [];
      for (final dynamic item in json['name']) {
        items.add(LanguageText.fromJson(item));
      }
      name = items;
    }
    if (json['description'] != null) {
      final List<LanguageText> items = [];
      for (final dynamic item in json['description']) {
        items.add(LanguageText.fromJson(item));
      }
      description = items;
    }
    color = json['color']?.toString();
    categoryNid = json['categoryNid']?.toString();
  }
}

class EnSentenceStructureDetailStructure {
  EnSentenceStructureNamedInfo? basicType;
  EnSentenceStructureNamedInfo? functionalType;
  EnSentenceStructureBlueprint? blueprint;

  EnSentenceStructureDetailStructure({
    this.basicType,
    this.functionalType,
    this.blueprint,
  });

  EnSentenceStructureDetailStructure.fromJson(Map<String, dynamic> json) {
    basicType = json['basicType'] != null
        ? EnSentenceStructureNamedInfo.fromJson(json['basicType'])
        : null;
    functionalType = json['functionalType'] != null
        ? EnSentenceStructureNamedInfo.fromJson(json['functionalType'])
        : null;
    blueprint = json['blueprint'] != null
        ? EnSentenceStructureBlueprint.fromJson(json['blueprint'])
        : null;
  }
}

class EnSentenceStructureBlueprint {
  int? sentenceId;
  String? content;
  String? definition;
  String? patternNid;
  String? patternTemplate;
  List<LanguageText?>? patternName;
  List<LanguageText?>? patternDescription;
  String? blueprintScope;
  List<LanguageText?>? blueprintScopeName;
  List<EnSentenceStructurePatternSegment?>? segmentList;

  EnSentenceStructureBlueprint({
    this.sentenceId,
    this.content,
    this.definition,
    this.patternNid,
    this.patternTemplate,
    this.patternName,
    this.patternDescription,
    this.blueprintScope,
    this.blueprintScopeName,
    this.segmentList,
  });

  EnSentenceStructureBlueprint.fromJson(Map<String, dynamic> json) {
    sentenceId = json['sentenceId']?.toInt();
    content = json['content']?.toString();
    definition = json['definition']?.toString();
    patternNid = json['patternNid']?.toString();
    patternTemplate = json['patternTemplate']?.toString();
    if (json['patternName'] != null) {
      final List<LanguageText> items = [];
      for (final dynamic item in json['patternName']) {
        items.add(LanguageText.fromJson(item));
      }
      patternName = items;
    }
    if (json['patternDescription'] != null) {
      final List<LanguageText> items = [];
      for (final dynamic item in json['patternDescription']) {
        items.add(LanguageText.fromJson(item));
      }
      patternDescription = items;
    }
    blueprintScope = json['blueprintScope']?.toString();
    if (json['blueprintScopeName'] != null) {
      final List<LanguageText> items = [];
      for (final dynamic item in json['blueprintScopeName']) {
        items.add(LanguageText.fromJson(item));
      }
      blueprintScopeName = items;
    }
    if (json['segmentList'] != null) {
      final List<EnSentenceStructurePatternSegment> items = [];
      for (final dynamic item in json['segmentList']) {
        items.add(EnSentenceStructurePatternSegment.fromJson(item));
      }
      segmentList = items;
    }
  }
}

class EnSentenceStructurePatternSegment {
  String? slotKey;
  EnSentenceStructureNamedInfo? slot;
  bool? required;
  bool? grammarControlling;
  int? growthPriority;
  List<String?>? dependsOn;
  String? text;
  String? renderSlotKey;
  String? sourceSlotKey;
  EnSentenceStructureNamedInfo? sourceSlot;
  int? slotUid;
  List<int?>? semanticIds;
  bool? literal;
  bool? hasChildStruct;
  EnSentenceStructurePatternChildStruct? childStruct;

  EnSentenceStructurePatternSegment({
    this.slotKey,
    this.slot,
    this.required,
    this.grammarControlling,
    this.growthPriority,
    this.dependsOn,
    this.text,
    this.renderSlotKey,
    this.sourceSlotKey,
    this.sourceSlot,
    this.slotUid,
    this.semanticIds,
    this.literal,
    this.hasChildStruct,
    this.childStruct,
  });

  EnSentenceStructurePatternSegment.fromJson(Map<String, dynamic> json) {
    slotKey = json['slotKey']?.toString();
    slot = json['slot'] != null
        ? EnSentenceStructureNamedInfo.fromJson(json['slot'])
        : null;
    required = json['required'];
    grammarControlling = json['grammarControlling'];
    growthPriority = json['growthPriority']?.toInt();
    if (json['dependsOn'] != null) {
      final List<String?> items = [];
      for (final dynamic item in json['dependsOn']) {
        items.add(item?.toString());
      }
      dependsOn = items;
    }
    text = json['text']?.toString();
    renderSlotKey = json['renderSlotKey']?.toString();
    sourceSlotKey = json['sourceSlotKey']?.toString();
    sourceSlot = json['sourceSlot'] != null
        ? EnSentenceStructureNamedInfo.fromJson(json['sourceSlot'])
        : null;
    slotUid = json['slotUid']?.toInt();
    if (json['semanticIds'] != null) {
      final List<int?> items = [];
      for (final dynamic item in json['semanticIds']) {
        items.add((item as num?)?.toInt());
      }
      semanticIds = items;
    }
    literal = json['literal'];
    hasChildStruct = json['hasChildStruct'];
    childStruct = json['childStruct'] != null
        ? EnSentenceStructurePatternChildStruct.fromJson(json['childStruct'])
        : null;
  }
}

class EnSentenceStructurePatternChildStruct {
  String? structType;
  int? rootClauseId;
  List<int?>? clauseIdList;
  String? content;
  String? patternNid;
  String? patternTemplate;
  String? clauseType;
  List<LanguageText?>? patternName;
  List<LanguageText?>? patternDescription;
  List<EnSentenceStructurePatternSegment?>? segmentList;

  EnSentenceStructurePatternChildStruct({
    this.structType,
    this.rootClauseId,
    this.clauseIdList,
    this.content,
    this.patternNid,
    this.patternTemplate,
    this.clauseType,
    this.patternName,
    this.patternDescription,
    this.segmentList,
  });

  EnSentenceStructurePatternChildStruct.fromJson(Map<String, dynamic> json) {
    structType = json['structType']?.toString();
    rootClauseId = json['rootClauseId']?.toInt();
    if (json['clauseIdList'] != null) {
      final List<int?> items = [];
      for (final dynamic item in json['clauseIdList']) {
        items.add((item as num?)?.toInt());
      }
      clauseIdList = items;
    }
    content = json['content']?.toString();
    patternNid = json['patternNid']?.toString();
    patternTemplate = json['patternTemplate']?.toString();
    clauseType = json['clauseType']?.toString();
    if (json['patternName'] != null) {
      final List<LanguageText> items = [];
      for (final dynamic item in json['patternName']) {
        items.add(LanguageText.fromJson(item));
      }
      patternName = items;
    }
    if (json['patternDescription'] != null) {
      final List<LanguageText> items = [];
      for (final dynamic item in json['patternDescription']) {
        items.add(LanguageText.fromJson(item));
      }
      patternDescription = items;
    }
    if (json['segmentList'] != null) {
      final List<EnSentenceStructurePatternSegment> items = [];
      for (final dynamic item in json['segmentList']) {
        items.add(EnSentenceStructurePatternSegment.fromJson(item));
      }
      segmentList = items;
    }
  }
}

class EnSentenceStructureAnalysisEntryColor {
  String? from;
  String? to;

  EnSentenceStructureAnalysisEntryColor({
    this.from,
    this.to,
  });

  EnSentenceStructureAnalysisEntryColor.fromJson(Map<String, dynamic> json) {
    from = json['from']?.toString();
    to = json['to']?.toString();
  }
}

class EnSentenceStructureAnalysisEntry {
  String? iconUrl;
  String? iconKey;
  EnSentenceStructureAnalysisEntryColor? color;
  String? type;
  List<LanguageText?>? title;
  String? learnTip;
  String? description;
  bool? suitable;
  int? index;
  dynamic jump;
  int? status;
  int? statusTip;

  EnSentenceStructureAnalysisEntry({
    this.iconUrl,
    this.iconKey,
    this.color,
    this.type,
    this.title,
    this.learnTip,
    this.description,
    this.suitable,
    this.index,
    this.jump,
    this.status,
    this.statusTip,
  });

  EnSentenceStructureAnalysisEntry.fromJson(Map<String, dynamic> json) {
    iconUrl = json['iconUrl']?.toString();
    iconKey = json['iconKey']?.toString();
    color = json['color'] != null
        ? EnSentenceStructureAnalysisEntryColor.fromJson(json['color'])
        : null;
    type = json['type']?.toString();
    if (json['title'] != null) {
      final List<LanguageText> items = [];
      for (final dynamic item in json['title']) {
        items.add(LanguageText.fromJson(item));
      }
      title = items;
    }
    learnTip = json['learnTip']?.toString();
    description = json['description']?.toString();
    suitable = json['suitable'];
    index = json['index']?.toInt();
    jump = json['jump'];
    status = json['status']?.toInt();
    statusTip = json['statusTip']?.toInt();
  }
}

class EnSentenceStructureChunkColor {
  String? bgColor;
  String? textColor;
  String? borderColor;

  EnSentenceStructureChunkColor({
    this.bgColor,
    this.textColor,
    this.borderColor,
  });

  EnSentenceStructureChunkColor.fromJson(Map<String, dynamic> json) {
    bgColor = json['bgColor']?.toString();
    textColor = json['textColor']?.toString();
    borderColor = json['borderColor']?.toString();
  }
}

class EnSentenceStructureToken {
  int? id;
  String? text;
  String? lemma;
  String? pos;
  String? upos;
  int? head;
  String? deprel;
  List<LanguageText?>? posTitle;
  EnSentenceStructureChunkColor? posColor;

  EnSentenceStructureToken({
    this.id,
    this.text,
    this.lemma,
    this.pos,
    this.upos,
    this.head,
    this.deprel,
    this.posTitle,
    this.posColor,
  });

  EnSentenceStructureToken.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toInt();
    text = json['text']?.toString();
    lemma = json['lemma']?.toString();
    pos = json['pos']?.toString();
    upos = json['upos']?.toString();
    head = json['head']?.toInt();
    deprel = json['deprel']?.toString();
    if (json['posTitle'] != null) {
      final List<LanguageText> items = [];
      for (final dynamic item in json['posTitle']) {
        items.add(LanguageText.fromJson(item));
      }
      posTitle = items;
    }
    posColor = json['posColor'] != null
        ? EnSentenceStructureChunkColor.fromJson(json['posColor'])
        : null;
  }
}

class EnSentenceStructureConjunction {
  String? typeNid;
  String? text;
  TextReference? textReference;
  int? linkedClauseId;
  List<LanguageText?>? descriptions;

  EnSentenceStructureConjunction({
    this.typeNid,
    this.text,
    this.textReference,
    this.linkedClauseId,
    this.descriptions,
  });

  EnSentenceStructureConjunction.fromJson(Map<String, dynamic> json) {
    typeNid = json['typeNid']?.toString();
    text = json['text']?.toString();
    textReference = json['textReference'] != null
        ? TextReference.fromJson(json['textReference'])
        : null;
    linkedClauseId = json['linkedClauseId']?.toInt();
    if (json['descriptions'] != null) {
      final List<LanguageText> items = [];
      for (final dynamic item in json['descriptions']) {
        items.add(LanguageText.fromJson(item));
      }
      descriptions = items;
    }
  }
}

class EnSentenceStructureChunking {
  String? type;
  EnSentenceStructureNamedInfo? chunkType;
  TextReference? textReference;
  List<LanguageText?>? descriptions;

  EnSentenceStructureChunking({
    this.type,
    this.chunkType,
    this.textReference,
    this.descriptions,
  });

  EnSentenceStructureChunking.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toString();
    chunkType = json['chunkType'] != null
        ? EnSentenceStructureNamedInfo.fromJson(json['chunkType'])
        : null;
    textReference = json['textReference'] != null
        ? TextReference.fromJson(json['textReference'])
        : null;
    if (json['descriptions'] != null) {
      final List<LanguageText> items = [];
      for (final dynamic item in json['descriptions']) {
        items.add(LanguageText.fromJson(item));
      }
      descriptions = items;
    }
  }
}

class EnSentenceStructureSvocaElement {
  String? typeNid;
  EnSentenceStructureNamedInfo? type;
  TextReference? textReference;
  List<LanguageText?>? descriptions;

  EnSentenceStructureSvocaElement({
    this.typeNid,
    this.type,
    this.textReference,
    this.descriptions,
  });

  EnSentenceStructureSvocaElement.fromJson(Map<String, dynamic> json) {
    typeNid = json['typeNid']?.toString();
    type = json['type'] != null
        ? EnSentenceStructureNamedInfo.fromJson(json['type'])
        : null;
    textReference = json['textReference'] != null
        ? TextReference.fromJson(json['textReference'])
        : null;
    if (json['descriptions'] != null) {
      final List<LanguageText> items = [];
      for (final dynamic item in json['descriptions']) {
        items.add(LanguageText.fromJson(item));
      }
      descriptions = items;
    }
  }
}

class EnSentenceStructureSvoca {
  String? codeNid;
  EnSentenceStructureNamedInfo? code;
  List<LanguageText?>? descriptions;
  List<EnSentenceStructureSvocaElement?>? elements;

  EnSentenceStructureSvoca({
    this.codeNid,
    this.code,
    this.descriptions,
    this.elements,
  });

  EnSentenceStructureSvoca.fromJson(Map<String, dynamic> json) {
    codeNid = json['codeNid']?.toString();
    code = json['code'] != null
        ? EnSentenceStructureNamedInfo.fromJson(json['code'])
        : null;
    if (json['descriptions'] != null) {
      final List<LanguageText> items = [];
      for (final dynamic item in json['descriptions']) {
        items.add(LanguageText.fromJson(item));
      }
      descriptions = items;
    }
    if (json['elements'] != null) {
      final List<EnSentenceStructureSvocaElement> items = [];
      for (final dynamic item in json['elements']) {
        items.add(EnSentenceStructureSvocaElement.fromJson(item));
      }
      elements = items;
    }
  }
}

class EnSentenceStructureGrammarFeature {
  String? category;
  String? featureNid;
  EnSentenceStructureNamedInfo? feature;
  List<LanguageText?>? descriptions;

  EnSentenceStructureGrammarFeature({
    this.category,
    this.featureNid,
    this.feature,
    this.descriptions,
  });

  EnSentenceStructureGrammarFeature.fromJson(Map<String, dynamic> json) {
    category = json['category']?.toString();
    featureNid = json['featureNid']?.toString();
    feature = json['feature'] != null
        ? EnSentenceStructureNamedInfo.fromJson(json['feature'])
        : null;
    if (json['descriptions'] != null) {
      final List<LanguageText> items = [];
      for (final dynamic item in json['descriptions']) {
        items.add(LanguageText.fromJson(item));
      }
      descriptions = items;
    }
  }
}

class EnSentenceStructureSpecialClauseFeature {
  String? featureNid;
  TextReference? textReference;
  List<LanguageText?>? descriptions;

  EnSentenceStructureSpecialClauseFeature({
    this.featureNid,
    this.textReference,
    this.descriptions,
  });

  EnSentenceStructureSpecialClauseFeature.fromJson(Map<String, dynamic> json) {
    featureNid = json['featureNid']?.toString();
    textReference = json['textReference'] != null
        ? TextReference.fromJson(json['textReference'])
        : null;
    if (json['descriptions'] != null) {
      final List<LanguageText> items = [];
      for (final dynamic item in json['descriptions']) {
        items.add(LanguageText.fromJson(item));
      }
      descriptions = items;
    }
  }
}

class EnSentenceStructureClause {
  int? clauseId;
  int? orderInSentence;
  int? parentClauseId;
  TextReference? textReference;
  String? text;
  String? type;
  String? roleInParent;
  List<EnSentenceStructureConjunction?>? conjunctions;
  List<EnSentenceStructureChunking?>? chunking;
  EnSentenceStructureSvoca? svoca;
  List<EnSentenceStructureGrammarFeature?>? grammaticalFeatures;
  List<EnSentenceStructureSpecialClauseFeature?>? specialClauseFeatures;

  EnSentenceStructureClause({
    this.clauseId,
    this.orderInSentence,
    this.parentClauseId,
    this.textReference,
    this.text,
    this.type,
    this.roleInParent,
    this.conjunctions,
    this.chunking,
    this.svoca,
    this.grammaticalFeatures,
    this.specialClauseFeatures,
  });

  EnSentenceStructureClause.fromJson(Map<String, dynamic> json) {
    clauseId = json['clauseId']?.toInt() ?? json['uid']?.toInt();
    orderInSentence = json['orderInSentence']?.toInt();
    parentClauseId = json['parentClauseId']?.toInt();
    textReference = json['textReference'] != null
        ? TextReference.fromJson(json['textReference'])
        : null;
    text = json['text']?.toString();
    type = json['type']?.toString();
    roleInParent = json['roleInParent']?.toString();
    if (json['conjunctions'] != null) {
      final List<EnSentenceStructureConjunction> items = [];
      for (final dynamic item in json['conjunctions']) {
        items.add(EnSentenceStructureConjunction.fromJson(item));
      }
      conjunctions = items;
    }
    if (json['chunking'] != null) {
      final List<EnSentenceStructureChunking> items = [];
      for (final dynamic item in json['chunking']) {
        items.add(EnSentenceStructureChunking.fromJson(item));
      }
      chunking = items;
    }
    svoca = json['svoca'] != null
        ? EnSentenceStructureSvoca.fromJson(json['svoca'])
        : null;
    if (json['grammaticalFeatures'] != null) {
      final List<EnSentenceStructureGrammarFeature> items = [];
      for (final dynamic item in json['grammaticalFeatures']) {
        items.add(EnSentenceStructureGrammarFeature.fromJson(item));
      }
      grammaticalFeatures = items;
    }
    if (json['specialClauseFeatures'] != null) {
      final List<EnSentenceStructureSpecialClauseFeature> items = [];
      for (final dynamic item in json['specialClauseFeatures']) {
        items.add(EnSentenceStructureSpecialClauseFeature.fromJson(item));
      }
      specialClauseFeatures = items;
    }
  }
}

class EnSentenceStructurePosForm {
  String? ptb;
  String? abbr;
  String? description;
  List<LanguageText?>? title;
  EnSentenceStructureChunkColor? color;

  EnSentenceStructurePosForm({
    this.ptb,
    this.abbr,
    this.description,
    this.title,
    this.color,
  });

  EnSentenceStructurePosForm.fromJson(Map<String, dynamic> json) {
    ptb = json['ptb']?.toString();
    abbr = json['abbr']?.toString();
    description = json['description']?.toString();
    if (json['title'] != null) {
      final List<LanguageText> items = [];
      for (final dynamic item in json['title']) {
        items.add(LanguageText.fromJson(item));
      }
      title = items;
    }
    color = json['color'] != null
        ? EnSentenceStructureChunkColor.fromJson(json['color'])
        : null;
  }
}

class EnSentenceStructureSyntax {
  String? constituencyParse;
  List<EnSentenceStructurePosForm?>? posForms;

  EnSentenceStructureSyntax({
    this.constituencyParse,
    this.posForms,
  });

  EnSentenceStructureSyntax.fromJson(Map<String, dynamic> json) {
    constituencyParse = json['constituencyParse']?.toString();
    if (json['posForms'] != null) {
      final List<EnSentenceStructurePosForm> items = [];
      for (final dynamic item in json['posForms']) {
        items.add(EnSentenceStructurePosForm.fromJson(item));
      }
      posForms = items;
    }
  }
}

class EnSentenceStructureRelationItem {
  String? type;
  String? nid;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  int? order;
  String? created;
  String? updated;
  dynamic payload;

  EnSentenceStructureRelationItem({
    this.type,
    this.nid,
    this.name,
    this.description,
    this.order,
    this.created,
    this.updated,
    this.payload,
  });

  EnSentenceStructureRelationItem.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toString();
    nid = json['nid']?.toString();
    if (json['name'] != null) {
      final List<LanguageText> items = [];
      for (final dynamic item in json['name']) {
        items.add(LanguageText.fromJson(item));
      }
      name = items;
    }
    if (json['description'] != null) {
      final List<LanguageText> items = [];
      for (final dynamic item in json['description']) {
        items.add(LanguageText.fromJson(item));
      }
      description = items;
    }
    order = json['order']?.toInt();
    created = json['created']?.toString();
    updated = json['updated']?.toString();
    payload = json['payload'];
  }
}

class EnSentenceStructureRelationGroup {
  String? type;
  String? title;
  String? icon;
  String? description;
  String? code;
  String? gradientFrom;
  String? gradientTo;
  List<EnSentenceStructureRelationItem?>? items;

  EnSentenceStructureRelationGroup({
    this.type,
    this.title,
    this.icon,
    this.description,
    this.code,
    this.gradientFrom,
    this.gradientTo,
    this.items,
  });

  EnSentenceStructureRelationGroup.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toString();
    title = json['title']?.toString();
    icon = json['icon']?.toString();
    description = json['description']?.toString();
    code = json['code']?.toString();
    gradientFrom = json['gradientFrom']?.toString();
    gradientTo = json['gradientTo']?.toString();
    if (json['items'] != null) {
      final List<EnSentenceStructureRelationItem> data = [];
      for (final dynamic item in json['items']) {
        data.add(EnSentenceStructureRelationItem.fromJson(item));
      }
      items = data;
    }
  }
}

class EnSentenceStructureAnalysisData {
  List<EnSentenceStructureToken?>? tokens;
  List<EnSentenceStructureClause?>? clauses;
  EnSentenceStructureSyntax? syntax;
  List<EnSentenceStructureRelationGroup?>? relations;

  EnSentenceStructureAnalysisData({
    this.tokens,
    this.clauses,
    this.syntax,
    this.relations,
  });

  EnSentenceStructureAnalysisData.fromJson(Map<String, dynamic> json) {
    if (json['tokens'] != null) {
      final List<EnSentenceStructureToken> items = [];
      int index = 1;
      for (final dynamic item in json['tokens']) {
        final EnSentenceStructureToken token = EnSentenceStructureToken.fromJson(item);
        token.id ??= index;
        items.add(token);
        index++;
      }
      tokens = items;
    }
    if (json['clauses'] != null) {
      final List<EnSentenceStructureClause> items = [];
      for (final dynamic item in json['clauses']) {
        items.add(EnSentenceStructureClause.fromJson(item));
      }
      clauses = items;
    }
    syntax = json['syntax'] != null
        ? EnSentenceStructureSyntax.fromJson(json['syntax'])
        : null;
    if (json['relations'] != null) {
      final List<EnSentenceStructureRelationGroup> items = [];
      for (final dynamic item in json['relations']) {
        items.add(EnSentenceStructureRelationGroup.fromJson(item));
      }
      relations = items;
    }
  }
}
