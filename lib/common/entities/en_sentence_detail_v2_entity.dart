import 'entities.dart';

class EnSentenceDetailV2ThemeStyle {
  String? theme;
  String? color;
  double? fontSize;
  int? weight;
  bool? italic;
  String? backgroundColor;
  String? borderColor;
  String? shadowColor;

  EnSentenceDetailV2ThemeStyle({
    this.theme,
    this.color,
    this.fontSize,
    this.weight,
    this.italic,
    this.backgroundColor,
    this.borderColor,
    this.shadowColor,
  });

  EnSentenceDetailV2ThemeStyle.fromJson(Map<String, dynamic> json) {
    theme = json['theme']?.toString();
    color = json['color']?.toString();
    fontSize = json['fontsize']?.toDouble() ?? json['fontSize']?.toDouble();
    weight = json['weight']?.toInt();
    italic = json['italic'];
    backgroundColor = json['backgroundColor']?.toString();
    borderColor = json['borderColor']?.toString();
    shadowColor = json['shadowColor']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['theme'] = theme;
    data['color'] = color;
    data['fontsize'] = fontSize;
    data['weight'] = weight;
    data['italic'] = italic;
    data['backgroundColor'] = backgroundColor;
    data['borderColor'] = borderColor;
    data['shadowColor'] = shadowColor;
    return data;
  }
}

class EnSentenceDetailV2GlossTag {
  List<LanguageText?>? gloss;
  List<EnSentenceDetailV2ThemeStyle?>? style;

  EnSentenceDetailV2GlossTag({
    this.gloss,
    this.style,
  });

  EnSentenceDetailV2GlossTag.fromJson(Map<String, dynamic> json) {
    if (json['gloss'] != null) {
      final v = json['gloss'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      gloss = arr0;
    }
    if (json['style'] != null) {
      final v = json['style'];
      final arr0 = <EnSentenceDetailV2ThemeStyle>[];
      v.forEach((v) {
        arr0.add(EnSentenceDetailV2ThemeStyle.fromJson(v));
      });
      style = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (gloss != null) {
      final v = gloss;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['gloss'] = arr0;
    }
    if (style != null) {
      final v = style;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['style'] = arr0;
    }
    return data;
  }
}

class EnSentenceDetailV2NidInfo {
  int? uid;
  String? nid;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  String? color;

  EnSentenceDetailV2NidInfo({
    this.uid,
    this.nid,
    this.name,
    this.description,
    this.color,
  });

  EnSentenceDetailV2NidInfo.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    nid = json['nid']?.toString();
    if (json['name'] != null) {
      final v = json['name'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      name = arr0;
    }
    if (json['description'] != null) {
      final v = json['description'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      description = arr0;
    }
    color = json['color']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['nid'] = nid;
    if (name != null) {
      final v = name;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['name'] = arr0;
    }
    if (description != null) {
      final v = description;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['description'] = arr0;
    }
    data['color'] = color;
    return data;
  }
}

class EnSentenceDetailV2Media {
  String? imageUrl;
  String? imageKey;
  String? imageMd5;
  EnKnowledgeEntityRelationVideo? video;
  List<PronunciationsEntity?>? pronunciations;

  EnSentenceDetailV2Media({
    this.imageUrl,
    this.imageKey,
    this.imageMd5,
    this.video,
    this.pronunciations,
  });

  EnSentenceDetailV2Media.fromJson(Map<String, dynamic> json) {
    imageUrl = json['imageUrl']?.toString();
    imageKey = json['imageKey']?.toString();
    imageMd5 = json['imageMd5']?.toString();
    video = json['video'] != null
        ? EnKnowledgeEntityRelationVideo.fromJson(json['video'])
        : null;
    if (json['pronunciations'] != null) {
      final v = json['pronunciations'];
      final arr0 = <PronunciationsEntity>[];
      v.forEach((v) {
        arr0.add(PronunciationsEntity.fromJson(v));
      });
      pronunciations = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['imageUrl'] = imageUrl;
    data['imageKey'] = imageKey;
    data['imageMd5'] = imageMd5;
    if (video != null) {
      data['video'] = video!.toJson();
    }
    if (pronunciations != null) {
      final v = pronunciations;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['pronunciations'] = arr0;
    }
    return data;
  }
}

class EnSentenceDetailV2Study {
  ElementsCardStar? cardStar;
  CardDetilsEntityStat? stat;
  LockEntity? rights;

  EnSentenceDetailV2Study({
    this.cardStar,
    this.stat,
    this.rights,
  });

  EnSentenceDetailV2Study.fromJson(Map<String, dynamic> json) {
    cardStar = json['cardStar'] != null
        ? ElementsCardStar.fromJson(json['cardStar'])
        : null;
    stat = json['stat'] != null ? CardDetilsEntityStat.fromJson(json['stat']) : null;
    rights = json['rights'] != null ? LockEntity.fromJson(json['rights']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (cardStar != null) {
      data['cardStar'] = cardStar!.toJson();
    }
    if (stat != null) {
      data['stat'] = stat!.toJson();
    }
    if (rights != null) {
      data['rights'] = rights!.toJson();
    }
    return data;
  }
}

class EnSentenceDetailV2Legacy {
  List<CardWordSemanticModuleItem?>? moduleItems;
  List<ElementsCardEntityDatas?>? subContents;

  EnSentenceDetailV2Legacy({
    this.moduleItems,
    this.subContents,
  });

  EnSentenceDetailV2Legacy.fromJson(Map<String, dynamic> json) {
    if (json['moduleItems'] != null) {
      final v = json['moduleItems'];
      final arr0 = <CardWordSemanticModuleItem>[];
      v.forEach((v) {
        arr0.add(CardWordSemanticModuleItem.fromJson(v));
      });
      moduleItems = arr0;
    }
    if (json['subContents'] != null) {
      final v = json['subContents'];
      final arr0 = <ElementsCardEntityDatas>[];
      v.forEach((v) {
        arr0.add(ElementsCardEntityDatas.fromJson(v));
      });
      subContents = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (moduleItems != null) {
      final v = moduleItems;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['moduleItems'] = arr0;
    }
    if (subContents != null) {
      final v = subContents;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['subContents'] = arr0;
    }
    return data;
  }
}

class EnSentenceDetailV2PatternChildStruct {
  String? structType;
  int? rootClauseId;
  List<int?>? clauseIdList;
  String? content;
  String? patternNid;
  String? patternTemplate;
  List<LanguageText?>? patternName;
  List<LanguageText?>? patternDescription;
  String? clauseType;
  String? roleInParent;
  List<EnSentenceDetailV2PatternSegment?>? segmentList;

  EnSentenceDetailV2PatternChildStruct({
    this.structType,
    this.rootClauseId,
    this.clauseIdList,
    this.content,
    this.patternNid,
    this.patternTemplate,
    this.patternName,
    this.patternDescription,
    this.clauseType,
    this.roleInParent,
    this.segmentList,
  });

  EnSentenceDetailV2PatternChildStruct.fromJson(Map<String, dynamic> json) {
    structType = json['structType']?.toString();
    rootClauseId = json['rootClauseId']?.toInt();
    clauseIdList = json['clauseIdList']?.cast<int>();
    content = json['content']?.toString();
    patternNid = json['patternNid']?.toString();
    patternTemplate = json['patternTemplate']?.toString();
    if (json['patternName'] != null) {
      final v = json['patternName'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      patternName = arr0;
    }
    if (json['patternDescription'] != null) {
      final v = json['patternDescription'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      patternDescription = arr0;
    }
    clauseType = json['clauseType']?.toString();
    roleInParent = json['roleInParent']?.toString();
    if (json['segmentList'] != null) {
      final v = json['segmentList'];
      final arr0 = <EnSentenceDetailV2PatternSegment>[];
      v.forEach((v) {
        arr0.add(EnSentenceDetailV2PatternSegment.fromJson(v));
      });
      segmentList = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['structType'] = structType;
    data['rootClauseId'] = rootClauseId;
    data['clauseIdList'] = clauseIdList;
    data['content'] = content;
    data['patternNid'] = patternNid;
    data['patternTemplate'] = patternTemplate;
    if (patternName != null) {
      final v = patternName;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['patternName'] = arr0;
    }
    if (patternDescription != null) {
      final v = patternDescription;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['patternDescription'] = arr0;
    }
    data['clauseType'] = clauseType;
    data['roleInParent'] = roleInParent;
    if (segmentList != null) {
      final v = segmentList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['segmentList'] = arr0;
    }
    return data;
  }
}

class EnSentenceDetailV2PatternSegment {
  String? text;
  String? slotKey;
  EnSentenceDetailV2NidInfo? slot;
  String? renderSlotKey;
  String? sourceSlotKey;
  EnSentenceDetailV2NidInfo? sourceSlot;
  int? slotUid;
  List<int?>? semanticIds;
  bool? literal;
  bool? required;
  bool? grammarControlling;
  int? growthPriority;
  List<String?>? dependsOn;
  bool? hasChildStruct;
  EnSentenceDetailV2PatternChildStruct? childStruct;

  EnSentenceDetailV2PatternSegment({
    this.text,
    this.slotKey,
    this.slot,
    this.renderSlotKey,
    this.sourceSlotKey,
    this.sourceSlot,
    this.slotUid,
    this.semanticIds,
    this.literal,
    this.required,
    this.grammarControlling,
    this.growthPriority,
    this.dependsOn,
    this.hasChildStruct,
    this.childStruct,
  });

  EnSentenceDetailV2PatternSegment.fromJson(Map<String, dynamic> json) {
    text = json['text']?.toString();
    slotKey = json['slotKey']?.toString();
    slot = json['slot'] != null ? EnSentenceDetailV2NidInfo.fromJson(json['slot']) : null;
    renderSlotKey = json['renderSlotKey']?.toString();
    sourceSlotKey = json['sourceSlotKey']?.toString();
    sourceSlot = json['sourceSlot'] != null
        ? EnSentenceDetailV2NidInfo.fromJson(json['sourceSlot'])
        : null;
    slotUid = json['slotUid']?.toInt();
    semanticIds = json['semanticIds']?.cast<int>();
    literal = json['literal'];
    required = json['required'];
    grammarControlling = json['grammarControlling'];
    growthPriority = json['growthPriority']?.toInt();
    dependsOn = json['dependsOn']?.cast<String>();
    hasChildStruct = json['hasChildStruct'];
    childStruct = json['childStruct'] != null
        ? EnSentenceDetailV2PatternChildStruct.fromJson(json['childStruct'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['text'] = text;
    data['slotKey'] = slotKey;
    if (slot != null) {
      data['slot'] = slot!.toJson();
    }
    data['renderSlotKey'] = renderSlotKey;
    data['sourceSlotKey'] = sourceSlotKey;
    if (sourceSlot != null) {
      data['sourceSlot'] = sourceSlot!.toJson();
    }
    data['slotUid'] = slotUid;
    data['semanticIds'] = semanticIds;
    data['literal'] = literal;
    data['required'] = required;
    data['grammarControlling'] = grammarControlling;
    data['growthPriority'] = growthPriority;
    data['dependsOn'] = dependsOn;
    data['hasChildStruct'] = hasChildStruct;
    if (childStruct != null) {
      data['childStruct'] = childStruct!.toJson();
    }
    return data;
  }
}

class EnSentenceDetailV2Blueprint {
  int? sentenceId;
  String? content;
  String? definition;
  String? patternNid;
  String? patternTemplate;
  List<LanguageText?>? patternName;
  List<LanguageText?>? patternDescription;
  String? blueprintScope;
  List<LanguageText?>? blueprintScopeName;
  List<EnSentenceDetailV2PatternSegment?>? segmentList;

  EnSentenceDetailV2Blueprint({
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

  EnSentenceDetailV2Blueprint.fromJson(Map<String, dynamic> json) {
    sentenceId = json['sentenceId']?.toInt();
    content = json['content']?.toString();
    definition = json['definition']?.toString();
    patternNid = json['patternNid']?.toString();
    patternTemplate = json['patternTemplate']?.toString();
    if (json['patternName'] != null) {
      final v = json['patternName'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      patternName = arr0;
    }
    if (json['patternDescription'] != null) {
      final v = json['patternDescription'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      patternDescription = arr0;
    }
    blueprintScope = json['blueprintScope']?.toString();
    if (json['blueprintScopeName'] != null) {
      final v = json['blueprintScopeName'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      blueprintScopeName = arr0;
    }
    if (json['segmentList'] != null) {
      final v = json['segmentList'];
      final arr0 = <EnSentenceDetailV2PatternSegment>[];
      v.forEach((v) {
        arr0.add(EnSentenceDetailV2PatternSegment.fromJson(v));
      });
      segmentList = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['sentenceId'] = sentenceId;
    data['content'] = content;
    data['definition'] = definition;
    data['patternNid'] = patternNid;
    data['patternTemplate'] = patternTemplate;
    if (patternName != null) {
      final v = patternName;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['patternName'] = arr0;
    }
    if (patternDescription != null) {
      final v = patternDescription;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['patternDescription'] = arr0;
    }
    data['blueprintScope'] = blueprintScope;
    if (blueprintScopeName != null) {
      final v = blueprintScopeName;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['blueprintScopeName'] = arr0;
    }
    if (segmentList != null) {
      final v = segmentList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['segmentList'] = arr0;
    }
    return data;
  }
}

class EnSentenceDetailV2Structure {
  EnSentenceDetailV2NidInfo? basicType;
  EnSentenceDetailV2NidInfo? functionalType;
  List<EnSentenceDetailV2GlossTag?>? structureTags;
  List<EnSentenceDetailV2GlossTag?>? blueprintTags;
  EnSentenceDetailV2Blueprint? blueprint;

  EnSentenceDetailV2Structure({
    this.basicType,
    this.functionalType,
    this.structureTags,
    this.blueprintTags,
    this.blueprint,
  });

  EnSentenceDetailV2Structure.fromJson(Map<String, dynamic> json) {
    basicType = json['basicType'] != null
        ? EnSentenceDetailV2NidInfo.fromJson(json['basicType'])
        : null;
    functionalType = json['functionalType'] != null
        ? EnSentenceDetailV2NidInfo.fromJson(json['functionalType'])
        : null;
    if (json['structureTags'] != null) {
      final v = json['structureTags'];
      final arr0 = <EnSentenceDetailV2GlossTag>[];
      v.forEach((v) {
        arr0.add(EnSentenceDetailV2GlossTag.fromJson(v));
      });
      structureTags = arr0;
    }
    if (json['blueprintTags'] != null) {
      final v = json['blueprintTags'];
      final arr0 = <EnSentenceDetailV2GlossTag>[];
      v.forEach((v) {
        arr0.add(EnSentenceDetailV2GlossTag.fromJson(v));
      });
      blueprintTags = arr0;
    }
    blueprint = json['blueprint'] != null
        ? EnSentenceDetailV2Blueprint.fromJson(json['blueprint'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (basicType != null) {
      data['basicType'] = basicType!.toJson();
    }
    if (functionalType != null) {
      data['functionalType'] = functionalType!.toJson();
    }
    if (structureTags != null) {
      final v = structureTags;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['structureTags'] = arr0;
    }
    if (blueprintTags != null) {
      final v = blueprintTags;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['blueprintTags'] = arr0;
    }
    if (blueprint != null) {
      data['blueprint'] = blueprint!.toJson();
    }
    return data;
  }
}

class EnSentenceDetailV2EntryStyle {
  List<EnSentenceDetailV2ThemeStyle?>? textStyle;
  List<EnSentenceDetailV2ThemeStyle?>? cardStyle;

  EnSentenceDetailV2EntryStyle({
    this.textStyle,
    this.cardStyle,
  });

  EnSentenceDetailV2EntryStyle.fromJson(Map<String, dynamic> json) {
    if (json['textStyle'] != null) {
      final v = json['textStyle'];
      final arr0 = <EnSentenceDetailV2ThemeStyle>[];
      v.forEach((v) {
        arr0.add(EnSentenceDetailV2ThemeStyle.fromJson(v));
      });
      textStyle = arr0;
    }
    if (json['cardStyle'] != null) {
      final v = json['cardStyle'];
      final arr0 = <EnSentenceDetailV2ThemeStyle>[];
      v.forEach((v) {
        arr0.add(EnSentenceDetailV2ThemeStyle.fromJson(v));
      });
      cardStyle = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (textStyle != null) {
      final v = textStyle;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['textStyle'] = arr0;
    }
    if (cardStyle != null) {
      final v = cardStyle;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['cardStyle'] = arr0;
    }
    return data;
  }
}

class EnSentenceDetailV2GradientColor {
  String? from;
  String? to;

  EnSentenceDetailV2GradientColor({
    this.from,
    this.to,
  });

  EnSentenceDetailV2GradientColor.fromJson(Map<String, dynamic> json) {
    from = json['from']?.toString();
    to = json['to']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['from'] = from;
    data['to'] = to;
    return data;
  }
}

class EnSentenceDetailV2Jump {
  String? code;
  Map<String, dynamic>? params;

  EnSentenceDetailV2Jump({
    this.code,
    this.params,
  });

  EnSentenceDetailV2Jump.fromJson(Map<String, dynamic> json) {
    code = json['code']?.toString();
    if (json['params'] != null) {
      params = Map<String, dynamic>.from(json['params']);
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['code'] = code;
    if (params != null) {
      data['params'] = params;
    }
    return data;
  }
}

class EnSentenceDetailV2AnalysisEntry {
  String? type;
  List<LanguageText?>? title;
  String? description;
  int? status;
  String? iconKey;
  String? iconUrl;
  EnSentenceDetailV2GradientColor? color;
  String? learnTip;
  bool? suitable;
  int? index;
  EnSentenceDetailV2Jump? jump;
  int? statusTip;

  EnSentenceDetailV2AnalysisEntry({
    this.type,
    this.title,
    this.description,
    this.status,
    this.iconKey,
    this.iconUrl,
    this.color,
    this.learnTip,
    this.suitable,
    this.index,
    this.jump,
    this.statusTip,
  });

  EnSentenceDetailV2AnalysisEntry.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toString();
    if (json['title'] != null) {
      final v = json['title'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      title = arr0;
    }
    description = json['description']?.toString();
    status = json['status']?.toInt();
    iconKey = json['iconKey']?.toString();
    iconUrl = json['iconUrl']?.toString();
    color = json['color'] != null
        ? EnSentenceDetailV2GradientColor.fromJson(json['color'])
        : null;
    learnTip = json['learnTip']?.toString();
    suitable = json['suitable'];
    index = json['index']?.toInt();
    jump = json['jump'] != null ? EnSentenceDetailV2Jump.fromJson(json['jump']) : null;
    statusTip = json['statusTip']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    if (title != null) {
      final v = title;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['title'] = arr0;
    }
    data['description'] = description;
    data['status'] = status;
    data['iconKey'] = iconKey;
    data['iconUrl'] = iconUrl;
    if (color != null) {
      data['color'] = color!.toJson();
    }
    data['learnTip'] = learnTip;
    data['suitable'] = suitable;
    data['index'] = index;
    if (jump != null) {
      data['jump'] = jump!.toJson();
    }
    data['statusTip'] = statusTip;
    return data;
  }
}

class EnSentenceDetailV2ChunkColor {
  String? bgColor;
  String? textColor;
  String? borderColor;

  EnSentenceDetailV2ChunkColor({
    this.bgColor,
    this.textColor,
    this.borderColor,
  });

  EnSentenceDetailV2ChunkColor.fromJson(Map<String, dynamic> json) {
    bgColor = json['bgColor']?.toString();
    textColor = json['textColor']?.toString();
    borderColor = json['borderColor']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['bgColor'] = bgColor;
    data['textColor'] = textColor;
    data['borderColor'] = borderColor;
    return data;
  }
}

class EnSentenceDetailV2SyntaxToken {
  int? id;
  String? text;
  String? lemma;
  String? pos;
  String? upos;
  int? head;
  String? deprel;
  List<LanguageText?>? posTitle;
  EnSentenceDetailV2ChunkColor? posColor;

  EnSentenceDetailV2SyntaxToken({
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

  EnSentenceDetailV2SyntaxToken.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toInt();
    text = json['text']?.toString();
    lemma = json['lemma']?.toString();
    pos = json['pos']?.toString();
    upos = json['upos']?.toString();
    head = json['head']?.toInt();
    deprel = json['deprel']?.toString();
    if (json['posTitle'] != null) {
      final v = json['posTitle'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      posTitle = arr0;
    }
    posColor = json['posColor'] != null
        ? EnSentenceDetailV2ChunkColor.fromJson(json['posColor'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['text'] = text;
    data['lemma'] = lemma;
    data['pos'] = pos;
    data['upos'] = upos;
    data['head'] = head;
    data['deprel'] = deprel;
    if (posTitle != null) {
      final v = posTitle;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['posTitle'] = arr0;
    }
    if (posColor != null) {
      data['posColor'] = posColor!.toJson();
    }
    return data;
  }
}

class EnSentenceDetailV2Conjunction {
  String? typeNid;
  String? text;
  TextReference? textReference;
  int? linkedClauseId;
  List<LanguageText?>? descriptions;

  EnSentenceDetailV2Conjunction({
    this.typeNid,
    this.text,
    this.textReference,
    this.linkedClauseId,
    this.descriptions,
  });

  EnSentenceDetailV2Conjunction.fromJson(Map<String, dynamic> json) {
    typeNid = json['typeNid']?.toString();
    text = json['text']?.toString();
    textReference = json['textReference'] != null
        ? TextReference.fromJson(json['textReference'])
        : null;
    linkedClauseId = json['linkedClauseId']?.toInt();
    if (json['descriptions'] != null) {
      final v = json['descriptions'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      descriptions = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['typeNid'] = typeNid;
    data['text'] = text;
    if (textReference != null) {
      data['textReference'] = textReference!.toJson();
    }
    data['linkedClauseId'] = linkedClauseId;
    if (descriptions != null) {
      final v = descriptions;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['descriptions'] = arr0;
    }
    return data;
  }
}

class EnSentenceDetailV2Chunking {
  String? type;
  TextReference? textReference;
  List<LanguageText?>? descriptions;

  EnSentenceDetailV2Chunking({
    this.type,
    this.textReference,
    this.descriptions,
  });

  EnSentenceDetailV2Chunking.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toString();
    textReference = json['textReference'] != null
        ? TextReference.fromJson(json['textReference'])
        : null;
    if (json['descriptions'] != null) {
      final v = json['descriptions'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      descriptions = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    if (textReference != null) {
      data['textReference'] = textReference!.toJson();
    }
    if (descriptions != null) {
      final v = descriptions;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['descriptions'] = arr0;
    }
    return data;
  }
}

class EnSentenceDetailV2SvocaElement {
  String? typeNid;
  EnSentenceDetailV2NidInfo? type;
  TextReference? textReference;
  List<LanguageText?>? descriptions;

  EnSentenceDetailV2SvocaElement({
    this.typeNid,
    this.type,
    this.textReference,
    this.descriptions,
  });

  EnSentenceDetailV2SvocaElement.fromJson(Map<String, dynamic> json) {
    typeNid = json['typeNid']?.toString();
    type = json['type'] != null ? EnSentenceDetailV2NidInfo.fromJson(json['type']) : null;
    textReference = json['textReference'] != null
        ? TextReference.fromJson(json['textReference'])
        : null;
    if (json['descriptions'] != null) {
      final v = json['descriptions'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      descriptions = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['typeNid'] = typeNid;
    if (type != null) {
      data['type'] = type!.toJson();
    }
    if (textReference != null) {
      data['textReference'] = textReference!.toJson();
    }
    if (descriptions != null) {
      final v = descriptions;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['descriptions'] = arr0;
    }
    return data;
  }
}

class EnSentenceDetailV2Svoca {
  String? codeNid;
  EnSentenceDetailV2NidInfo? code;
  List<LanguageText?>? descriptions;
  List<EnSentenceDetailV2SvocaElement?>? elements;

  EnSentenceDetailV2Svoca({
    this.codeNid,
    this.code,
    this.descriptions,
    this.elements,
  });

  EnSentenceDetailV2Svoca.fromJson(Map<String, dynamic> json) {
    codeNid = json['codeNid']?.toString();
    code = json['code'] != null ? EnSentenceDetailV2NidInfo.fromJson(json['code']) : null;
    if (json['descriptions'] != null) {
      final v = json['descriptions'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      descriptions = arr0;
    }
    if (json['elements'] != null) {
      final v = json['elements'];
      final arr0 = <EnSentenceDetailV2SvocaElement>[];
      v.forEach((v) {
        arr0.add(EnSentenceDetailV2SvocaElement.fromJson(v));
      });
      elements = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['codeNid'] = codeNid;
    if (code != null) {
      data['code'] = code!.toJson();
    }
    if (descriptions != null) {
      final v = descriptions;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['descriptions'] = arr0;
    }
    if (elements != null) {
      final v = elements;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['elements'] = arr0;
    }
    return data;
  }
}

class EnSentenceDetailV2GrammarFeature {
  String? category;
  String? featureNid;
  EnSentenceDetailV2NidInfo? feature;
  List<LanguageText?>? descriptions;

  EnSentenceDetailV2GrammarFeature({
    this.category,
    this.featureNid,
    this.feature,
    this.descriptions,
  });

  EnSentenceDetailV2GrammarFeature.fromJson(Map<String, dynamic> json) {
    category = json['category']?.toString();
    featureNid = json['featureNid']?.toString();
    feature = json['feature'] != null
        ? EnSentenceDetailV2NidInfo.fromJson(json['feature'])
        : null;
    if (json['descriptions'] != null) {
      final v = json['descriptions'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      descriptions = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['category'] = category;
    data['featureNid'] = featureNid;
    if (feature != null) {
      data['feature'] = feature!.toJson();
    }
    if (descriptions != null) {
      final v = descriptions;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['descriptions'] = arr0;
    }
    return data;
  }
}

class EnSentenceDetailV2SpecialClauseFeature {
  String? featureNid;
  TextReference? textReference;
  List<LanguageText?>? descriptions;

  EnSentenceDetailV2SpecialClauseFeature({
    this.featureNid,
    this.textReference,
    this.descriptions,
  });

  EnSentenceDetailV2SpecialClauseFeature.fromJson(Map<String, dynamic> json) {
    featureNid = json['featureNid']?.toString();
    textReference = json['textReference'] != null
        ? TextReference.fromJson(json['textReference'])
        : null;
    if (json['descriptions'] != null) {
      final v = json['descriptions'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      descriptions = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['featureNid'] = featureNid;
    if (textReference != null) {
      data['textReference'] = textReference!.toJson();
    }
    if (descriptions != null) {
      final v = descriptions;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['descriptions'] = arr0;
    }
    return data;
  }
}

class EnSentenceDetailV2Clause {
  int? clauseId;
  int? orderInSentence;
  int? parentClauseId;
  TextReference? textReference;
  String? text;
  String? type;
  String? roleInParent;
  List<EnSentenceDetailV2Conjunction?>? conjunctions;
  List<EnSentenceDetailV2Chunking?>? chunking;
  EnSentenceDetailV2Svoca? svoca;
  List<EnSentenceDetailV2GrammarFeature?>? grammaticalFeatures;
  List<EnSentenceDetailV2SpecialClauseFeature?>? specialClauseFeatures;

  EnSentenceDetailV2Clause({
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

  EnSentenceDetailV2Clause.fromJson(Map<String, dynamic> json) {
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
      final v = json['conjunctions'];
      final arr0 = <EnSentenceDetailV2Conjunction>[];
      v.forEach((v) {
        arr0.add(EnSentenceDetailV2Conjunction.fromJson(v));
      });
      conjunctions = arr0;
    }
    if (json['chunking'] != null) {
      final v = json['chunking'];
      final arr0 = <EnSentenceDetailV2Chunking>[];
      v.forEach((v) {
        arr0.add(EnSentenceDetailV2Chunking.fromJson(v));
      });
      chunking = arr0;
    }
    svoca = json['svoca'] != null ? EnSentenceDetailV2Svoca.fromJson(json['svoca']) : null;
    if (json['grammaticalFeatures'] != null) {
      final v = json['grammaticalFeatures'];
      final arr0 = <EnSentenceDetailV2GrammarFeature>[];
      v.forEach((v) {
        arr0.add(EnSentenceDetailV2GrammarFeature.fromJson(v));
      });
      grammaticalFeatures = arr0;
    }
    if (json['specialClauseFeatures'] != null) {
      final v = json['specialClauseFeatures'];
      final arr0 = <EnSentenceDetailV2SpecialClauseFeature>[];
      v.forEach((v) {
        arr0.add(EnSentenceDetailV2SpecialClauseFeature.fromJson(v));
      });
      specialClauseFeatures = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['clauseId'] = clauseId;
    data['orderInSentence'] = orderInSentence;
    data['parentClauseId'] = parentClauseId;
    if (textReference != null) {
      data['textReference'] = textReference!.toJson();
    }
    data['text'] = text;
    data['type'] = type;
    data['roleInParent'] = roleInParent;
    if (conjunctions != null) {
      final v = conjunctions;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['conjunctions'] = arr0;
    }
    if (chunking != null) {
      final v = chunking;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['chunking'] = arr0;
    }
    if (svoca != null) {
      data['svoca'] = svoca!.toJson();
    }
    if (grammaticalFeatures != null) {
      final v = grammaticalFeatures;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['grammaticalFeatures'] = arr0;
    }
    if (specialClauseFeatures != null) {
      final v = specialClauseFeatures;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['specialClauseFeatures'] = arr0;
    }
    return data;
  }
}

class EnSentenceDetailV2PosForm {
  String? ptb;
  String? abbr;
  String? description;
  List<LanguageText?>? title;
  EnSentenceDetailV2ChunkColor? color;

  EnSentenceDetailV2PosForm({
    this.ptb,
    this.abbr,
    this.description,
    this.title,
    this.color,
  });

  EnSentenceDetailV2PosForm.fromJson(Map<String, dynamic> json) {
    ptb = json['ptb']?.toString();
    abbr = json['abbr']?.toString();
    description = json['description']?.toString();
    if (json['title'] != null) {
      final v = json['title'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      title = arr0;
    }
    color = json['color'] != null
        ? EnSentenceDetailV2ChunkColor.fromJson(json['color'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ptb'] = ptb;
    data['abbr'] = abbr;
    data['description'] = description;
    if (title != null) {
      final v = title;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['title'] = arr0;
    }
    if (color != null) {
      data['color'] = color!.toJson();
    }
    return data;
  }
}

class EnSentenceDetailV2Syntax {
  String? constituencyParse;
  List<EnSentenceDetailV2PosForm?>? posForms;

  EnSentenceDetailV2Syntax({
    this.constituencyParse,
    this.posForms,
  });

  EnSentenceDetailV2Syntax.fromJson(Map<String, dynamic> json) {
    constituencyParse = json['constituencyParse']?.toString();
    if (json['posForms'] != null) {
      final v = json['posForms'];
      final arr0 = <EnSentenceDetailV2PosForm>[];
      v.forEach((v) {
        arr0.add(EnSentenceDetailV2PosForm.fromJson(v));
      });
      posForms = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['constituencyParse'] = constituencyParse;
    if (posForms != null) {
      final v = posForms;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['posForms'] = arr0;
    }
    return data;
  }
}

class EnSentenceDetailV2Relations {
  int? status;
  String? title;
  String? description;
  List<EnSentenceDetailV2RelationItem?>? items;

  EnSentenceDetailV2Relations({
    this.status,
    this.title,
    this.description,
    this.items,
  });

  EnSentenceDetailV2Relations.fromJson(Map<String, dynamic> json) {
    status = json['status']?.toInt();
    title = json['title']?.toString();
    description = json['description']?.toString();
    if (json['items'] != null) {
      final v = json['items'];
      final arr0 = <EnSentenceDetailV2RelationItem>[];
      v.forEach((v) {
        arr0.add(EnSentenceDetailV2RelationItem.fromJson(v));
      });
      items = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    data['title'] = title;
    data['description'] = description;
    if (items != null) {
      final v = items;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['items'] = arr0;
    }
    return data;
  }
}

class EnSentenceDetailV2RelationItem {
  String? type;
  String? title;
  String? color;
  int? previewCount;

  EnSentenceDetailV2RelationItem({
    this.type,
    this.title,
    this.color,
    this.previewCount,
  });

  EnSentenceDetailV2RelationItem.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toString();
    title = json['title']?.toString();
    color = json['color']?.toString();
    previewCount = json['previewCount']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    data['title'] = title;
    data['color'] = color;
    data['previewCount'] = previewCount;
    return data;
  }
}

class EnSentenceDetailV2AnalysisData {
  List<EnSentenceDetailV2SyntaxToken?>? tokens;
  List<EnSentenceDetailV2Clause?>? clauses;
  EnSentenceDetailV2Syntax? syntax;
  EnSentenceDetailV2Relations? relations;

  EnSentenceDetailV2AnalysisData({
    this.tokens,
    this.clauses,
    this.syntax,
    this.relations,
  });

  EnSentenceDetailV2AnalysisData.fromJson(Map<String, dynamic> json) {
    if (json['tokens'] != null) {
      final v = json['tokens'];
      final arr0 = <EnSentenceDetailV2SyntaxToken>[];
      v.forEach((v) {
        arr0.add(EnSentenceDetailV2SyntaxToken.fromJson(v));
      });
      tokens = arr0;
    }
    if (json['clauses'] != null) {
      final v = json['clauses'];
      final arr0 = <EnSentenceDetailV2Clause>[];
      v.forEach((v) {
        arr0.add(EnSentenceDetailV2Clause.fromJson(v));
      });
      clauses = arr0;
    }
    syntax = json['syntax'] != null ? EnSentenceDetailV2Syntax.fromJson(json['syntax']) : null;
    relations = json['relations'] != null
        ? EnSentenceDetailV2Relations.fromJson(json['relations'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (tokens != null) {
      final v = tokens;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['tokens'] = arr0;
    }
    if (clauses != null) {
      final v = clauses;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['clauses'] = arr0;
    }
    if (syntax != null) {
      data['syntax'] = syntax!.toJson();
    }
    if (relations != null) {
      data['relations'] = relations!.toJson();
    }
    return data;
  }
}

class EnSentenceDetailV2Entity {
  int? contentId;
  int? semanticId;
  String? contentType;
  String? content;
  String? definition;
  int? difficulty;
  bool? favorited;
  String? module;
  String? layer;
  EnSentenceDetailV2Media? media;
  EnSentenceDetailV2Study? study;
  EnSentenceDetailV2Legacy? legacy;
  EnSentenceDetailV2Structure? structure;
  List<EnSentenceDetailV2AnalysisEntry?>? analysisEntries;
  EnSentenceDetailV2AnalysisData? analysisData;
  /// 是否有发音题目
  bool? pronunciationExercise;

  EnSentenceDetailV2Entity({
    this.contentId,
    this.semanticId,
    this.contentType,
    this.content,
    this.definition,
    this.difficulty,
    this.favorited,
    this.module,
    this.layer,
    this.media,
    this.study,
    this.legacy,
    this.structure,
    this.analysisEntries,
    this.analysisData,
    this.pronunciationExercise,
  });

  EnSentenceDetailV2Entity.fromJson(Map<String, dynamic> json) {
    contentId = json['contentId']?.toInt();
    semanticId = json['semanticId']?.toInt();
    contentType = json['contentType']?.toString();
    content = json['content']?.toString();
    definition = json['definition']?.toString();
    difficulty = json['difficulty']?.toInt();
    favorited = json['favorited'];
    module = json['module']?.toString();
    layer = json['layer']?.toString();
    media = json['media'] != null ? EnSentenceDetailV2Media.fromJson(json['media']) : null;
    study = json['study'] != null ? EnSentenceDetailV2Study.fromJson(json['study']) : null;
    legacy = json['legacy'] != null ? EnSentenceDetailV2Legacy.fromJson(json['legacy']) : null;
    structure = json['structure'] != null
        ? EnSentenceDetailV2Structure.fromJson(json['structure'])
        : null;
    if (json['analysisEntries'] != null) {
      final v = json['analysisEntries'];
      final arr0 = <EnSentenceDetailV2AnalysisEntry>[];
      v.forEach((v) {
        arr0.add(EnSentenceDetailV2AnalysisEntry.fromJson(v));
      });
      analysisEntries = arr0;
    }
    analysisData = json['analysisData'] != null
        ? EnSentenceDetailV2AnalysisData.fromJson(json['analysisData'])
        : null;
    pronunciationExercise = json['pronunciationExercise'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['contentId'] = contentId;
    data['semanticId'] = semanticId;
    data['contentType'] = contentType;
    data['content'] = content;
    data['definition'] = definition;
    data['difficulty'] = difficulty;
    data['favorited'] = favorited;
    data['module'] = module;
    data['layer'] = layer;
    if (media != null) {
      data['media'] = media!.toJson();
    }
    if (study != null) {
      data['study'] = study!.toJson();
    }
    if (legacy != null) {
      data['legacy'] = legacy!.toJson();
    }
    if (structure != null) {
      data['structure'] = structure!.toJson();
    }
    if (analysisEntries != null) {
      final v = analysisEntries;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['analysisEntries'] = arr0;
    }
    if (analysisData != null) {
      data['analysisData'] = analysisData!.toJson();
    }
    data['pronunciationExercise'] = pronunciationExercise;
    return data;
  }
}
