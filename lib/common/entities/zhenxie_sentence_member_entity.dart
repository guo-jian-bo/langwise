import 'entities.dart';

/// 折写详情里的句子成员，兼容 pattern、pair、fork、grammar panorama 等详情接口。
class ZhenxieSentenceMemberEntity { 
  int? sentenceId;
  ZhenxieSentenceMemberSentenceEntity? sentence;
  /// 配对 from to / 分叉 fork_from fork_to(多个)
  String? role;
  String? valueNid;
  ZhenxieSentenceMemberCellEntity? cell;
  ZhenxieSentenceMemberPairEntity? pair;
  ZhenxieSentenceMemberPatternInfoEntity? toPattern;
  List<String?>? addedSlotKeys;
  List<ZhenxieSentenceMemberFocusEntity?>? foci;
  int? order;

  ZhenxieSentenceMemberEntity({
    this.sentenceId,
    this.sentence,
    this.role,
    this.valueNid,
    this.cell,
    this.pair,
    this.toPattern,
    this.addedSlotKeys,
    this.foci,
    this.order,
  });

  ZhenxieSentenceMemberEntity.fromJson(Map<String, dynamic> json) {
    sentenceId = json['sentenceId']?.toInt();
    if (json['sentence'] is Map) {
      sentence = ZhenxieSentenceMemberSentenceEntity.fromJson(
        Map<String, dynamic>.from(json['sentence']),
      );
    }
    role = json['role']?.toString();
    valueNid = json['valueNid']?.toString();
    if (json['cell'] is Map) {
      cell = ZhenxieSentenceMemberCellEntity.fromJson(
        Map<String, dynamic>.from(json['cell']),
      );
    }
    if (json['pair'] is Map) {
      pair = ZhenxieSentenceMemberPairEntity.fromJson(
        Map<String, dynamic>.from(json['pair']),
      );
    }
    if (json['toPattern'] is Map) {
      toPattern = ZhenxieSentenceMemberPatternInfoEntity.fromJson(
        Map<String, dynamic>.from(json['toPattern']),
      );
    }
    if (json['addedSlotKeys'] is List) {
      addedSlotKeys = (json['addedSlotKeys'] as List)
          .map((item) => item?.toString())
          .toList();
    }
    if (json['foci'] is List) {
      foci = (json['foci'] as List).map((item) {
        if (item == null || item is! Map) return null;
        return ZhenxieSentenceMemberFocusEntity.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList();
    }
    order = json['order']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['sentenceId'] = sentenceId;
    data['sentence'] = sentence?.toJson();
    data['role'] = role;
    data['valueNid'] = valueNid;
    data['cell'] = cell?.toJson();
    data['pair'] = pair?.toJson();
    data['toPattern'] = toPattern?.toJson();
    data['addedSlotKeys'] = addedSlotKeys;
    data['foci'] = foci?.map((item) => item?.toJson()).toList();
    data['order'] = order;
    return data;
  }
}

/// 成员里挂载的句子详情，保持和详情接口里的 sentence 结构一致。
class ZhenxieSentenceMemberSentenceEntity {
  int? sentenceId;
  int? semanticId;
  String? contentType;
  String? content;
  String? definition;
  String? patternNid;
  String? patternTemplate;
  List<LanguageText?>? patternName;
  List<LanguageText?>? patternDescription;
  String? blueprintScope;
  List<LanguageText?>? blueprintScopeName;
  List<String?>? addedSlotKeys;
  List<ZhenxieSentenceMemberSegmentEntity?>? segmentList;
  String? access;

  /// 是否上架
  bool get isNormal => access == "NORMAL";

  ZhenxieSentenceMemberSentenceEntity({
    this.sentenceId,
    this.semanticId,
    this.contentType,
    this.content,
    this.definition,
    this.patternNid,
    this.patternTemplate,
    this.patternName,
    this.patternDescription,
    this.blueprintScope,
    this.blueprintScopeName,
    this.addedSlotKeys,
    this.segmentList,
    this.access,
  });

  ZhenxieSentenceMemberSentenceEntity.fromJson(Map<String, dynamic> json) {
    sentenceId = json['sentenceId']?.toInt();
    semanticId = json['semanticId']?.toInt();
    contentType = json['contentType']?.toString();
    content = json['content']?.toString();
    definition = json['definition']?.toString();
    patternNid = json['patternNid']?.toString();
    patternTemplate = json['patternTemplate']?.toString();
    patternName = _parseLanguageTextList(json['patternName']);
    patternDescription = _parseLanguageTextList(json['patternDescription']);
    blueprintScope = json['blueprintScope']?.toString();
    blueprintScopeName = _parseLanguageTextList(json['blueprintScopeName']);
    addedSlotKeys = _parseStringList(json['addedSlotKeys']);
    segmentList = _parseObjectList(
      json['segmentList'],
      ZhenxieSentenceMemberSegmentEntity.fromJson,
    );
    access = json['access']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['sentenceId'] = sentenceId;
    data['semanticId'] = semanticId;
    data['contentType'] = contentType;
    data['content'] = content;
    data['definition'] = definition;
    data['patternNid'] = patternNid;
    data['patternTemplate'] = patternTemplate;
    data['patternName'] = patternName?.map((item) => item?.toJson()).toList();
    data['patternDescription'] = patternDescription?.map((item) => item?.toJson()).toList();
    data['blueprintScope'] = blueprintScope;
    data['blueprintScopeName'] = blueprintScopeName?.map((item) => item?.toJson()).toList();
    data['addedSlotKeys'] = addedSlotKeys;

    data['segmentList'] = segmentList?.map((item) => item?.toJson()).toList();
    data['access'] = access;
    return data;
  }
}

/// 句子里的 segment 明细。
class ZhenxieSentenceMemberSegmentEntity {
  String? slotKey;
  ZhenxieSentenceMemberNamedInfoEntity? slot;
  bool? required;
  bool? grammarControlling;
  int? growthPriority;
  List<String?>? dependsOn;
  List<ZhenxieSentenceMemberNamedInfoEntity?>? dependsOnSlots;
  String? key;
  String? text;
  String? grammarValue;
  String? renderSlotKey;
  String? sourceSlotKey;
  ZhenxieSentenceMemberNamedInfoEntity? sourceSlot;
  int? slotUid;
  List<int?>? semanticIds;
  bool? literal;
  String? segmentState;
  int? nestedClauseId;
  bool? hasChildStruct;
  ZhenxieSentenceMemberSegmentChildStructEntity? childStruct;

  ZhenxieSentenceMemberSegmentEntity({
    this.slotKey,
    this.slot,
    this.required,
    this.grammarControlling,
    this.growthPriority,
    this.dependsOn,
    this.dependsOnSlots,
    this.key,
    this.text,
    this.grammarValue,
    this.renderSlotKey,
    this.sourceSlotKey,
    this.sourceSlot,
    this.slotUid,
    this.semanticIds,
    this.literal,
    this.segmentState,
    this.nestedClauseId,
    this.hasChildStruct,
    this.childStruct,
  });

  ZhenxieSentenceMemberSegmentEntity.fromJson(Map<String, dynamic> json) {
    slotKey = json['slotKey']?.toString();
    slot = _parseObject(json['slot'], ZhenxieSentenceMemberNamedInfoEntity.fromJson);
    required = json['required'];
    grammarControlling = json['grammarControlling'];
    growthPriority = json['growthPriority']?.toInt();
    dependsOn = _parseStringList(json['dependsOn']);
    dependsOnSlots = _parseObjectList(
      json['dependsOnSlots'],
      ZhenxieSentenceMemberNamedInfoEntity.fromJson,
    );
    key = json['key']?.toString();
    text = json['text']?.toString();
    grammarValue = json['grammarValue']?.toString();
    renderSlotKey = json['renderSlotKey']?.toString();
    sourceSlotKey = json['sourceSlotKey']?.toString();
    sourceSlot = _parseObject(
      json['sourceSlot'],
      ZhenxieSentenceMemberNamedInfoEntity.fromJson,
    );
    slotUid = json['slotUid']?.toInt();
    semanticIds = _parseIntList(json['semanticIds']);
    literal = json['literal'];
    segmentState = json['segmentState']?.toString();
    nestedClauseId = json['nestedClauseId']?.toInt();
    hasChildStruct = json['hasChildStruct'];
    childStruct = _parseObject(
      json['childStruct'],
      ZhenxieSentenceMemberSegmentChildStructEntity.fromJson,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['slotKey'] = slotKey;
    data['slot'] = slot?.toJson();
    data['required'] = required;
    data['grammarControlling'] = grammarControlling;
    data['growthPriority'] = growthPriority;
    data['dependsOn'] = dependsOn;
    data['dependsOnSlots'] = dependsOnSlots?.map((item) => item?.toJson()).toList();
    data['key'] = key;
    data['text'] = text;
    data['grammarValue'] = grammarValue;
    data['renderSlotKey'] = renderSlotKey;
    data['sourceSlotKey'] = sourceSlotKey;
    data['sourceSlot'] = sourceSlot?.toJson();
    data['slotUid'] = slotUid;
    data['semanticIds'] = semanticIds;
    data['literal'] = literal;
    data['segmentState'] = segmentState;
    data['nestedClauseId'] = nestedClauseId;
    data['hasChildStruct'] = hasChildStruct;
    data['childStruct'] = childStruct?.toJson();
    return data;
  }
}

/// segment 下挂载的子句结构，递归复用本文件的 segment 定义。
class ZhenxieSentenceMemberSegmentChildStructEntity {
  String? structType;
  int? rootClauseId;
  List<int?>? clauseIdList;
  String? content;
  String? patternNid;
  String? patternTemplate;
  String? clauseType;
  List<LanguageText?>? patternName;
  List<LanguageText?>? patternDescription;
  List<ZhenxieSentenceMemberSegmentEntity?>? segmentList;

  ZhenxieSentenceMemberSegmentChildStructEntity({
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

  ZhenxieSentenceMemberSegmentChildStructEntity.fromJson(Map<String, dynamic> json) {
    structType = json['structType']?.toString();
    rootClauseId = json['rootClauseId']?.toInt();
    clauseIdList = _parseIntList(json['clauseIdList']);
    content = json['content']?.toString();
    patternNid = json['patternNid']?.toString();
    patternTemplate = json['patternTemplate']?.toString();
    clauseType = json['clauseType']?.toString();
    patternName = _parseLanguageTextList(json['patternName']);
    patternDescription = _parseLanguageTextList(json['patternDescription']);
    segmentList = _parseObjectList(
      json['segmentList'],
      ZhenxieSentenceMemberSegmentEntity.fromJson,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['structType'] = structType;
    data['rootClauseId'] = rootClauseId;
    data['clauseIdList'] = clauseIdList;
    data['content'] = content;
    data['patternNid'] = patternNid;
    data['patternTemplate'] = patternTemplate;
    data['clauseType'] = clauseType;
    data['patternName'] = patternName?.map((item) => item?.toJson()).toList();
    data['patternDescription'] = patternDescription?.map((item) => item?.toJson()).toList();
    data['segmentList'] = segmentList?.map((item) => item?.toJson()).toList();
    return data;
  }
}

/// 成员句子里复用的轻量命名信息。
class ZhenxieSentenceMemberNamedInfoEntity {
  String? nid;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  List<LanguageText?>? categoryName;
  List<LanguageText?>? categoryDescription;
  String? categoryNid;
  List<String?>? usageKinds;
  List<String?>? surfaceFromSlotKeys;
  String? color;

  ZhenxieSentenceMemberNamedInfoEntity({
    this.nid,
    this.name,
    this.description,
    this.categoryName,
    this.categoryDescription,
    this.categoryNid,
    this.usageKinds,
    this.surfaceFromSlotKeys,
    this.color,
  });

  ZhenxieSentenceMemberNamedInfoEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    name = _parseLanguageTextList(json['name']);
    description = _parseLanguageTextList(json['description']);
    categoryName = _parseLanguageTextList(json['categoryName']);
    categoryDescription = _parseLanguageTextList(json['categoryDescription']);
    categoryNid = json['categoryNid']?.toString();
    usageKinds = _parseStringList(json['usageKinds']);
    surfaceFromSlotKeys = _parseStringList(json['surfaceFromSlotKeys']);
    color = json['color']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['name'] = name?.map((item) => item?.toJson()).toList();
    data['description'] = description?.map((item) => item?.toJson()).toList();
    data['categoryName'] = categoryName?.map((item) => item?.toJson()).toList();
    data['categoryDescription'] = categoryDescription?.map((item) => item?.toJson()).toList();
    data['categoryNid'] = categoryNid;
    data['usageKinds'] = usageKinds;
    data['surfaceFromSlotKeys'] = surfaceFromSlotKeys;
    data['color'] = color;
    return data;
  }
}

/// 句子成员里目标 pattern 的轻量信息。
class ZhenxieSentenceMemberPatternInfoEntity {
  String? nid;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  String? template;

  ZhenxieSentenceMemberPatternInfoEntity({
    this.nid,
    this.name,
    this.description,
    this.template,
  });

  ZhenxieSentenceMemberPatternInfoEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    name = _parseLanguageTextList(json['name']);
    description = _parseLanguageTextList(json['description']);
    template = json['template']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['name'] = name?.map((item) => item?.toJson()).toList();
    data['description'] = description?.map((item) => item?.toJson()).toList();
    data['template'] = template;
    return data;
  }
}

/// 句子成员里挂载的 pair 详情。
class ZhenxieSentenceMemberPairEntity {
  String? nid;
  double? order;
  String? pairTypeNid;
  ZhenxieSentenceMemberNamedInfoEntity? pairType;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  String? teachingExampleFrom;
  String? teachingExampleTo;
  String? practiceMode;
  String? preferredPractice;
  bool? system;
  bool? enabled;
  ZhenxieSentenceMemberRealizationInfoEntity? fromRealization;
  ZhenxieSentenceMemberRealizationInfoEntity? toRealization;
  List<String?>? interactionModes;
  String? relationDirection;
  String? orderConstraint;
  List<ZhenxieSentenceMemberSemanticAnchorMappingEntity?>? semanticAnchorMappings;
  List<ZhenxieSentenceMemberRealizationSetEntity?>? realizationSetList;
  String? created;
  String? updated;

  ZhenxieSentenceMemberPairEntity({
    this.nid,
    this.order,
    this.pairTypeNid,
    this.pairType,
    this.name,
    this.description,
    this.teachingExampleFrom,
    this.teachingExampleTo,
    this.practiceMode,
    this.preferredPractice,
    this.system,
    this.enabled,
    this.fromRealization,
    this.toRealization,
    this.interactionModes,
    this.relationDirection,
    this.orderConstraint,
    this.semanticAnchorMappings,
    this.realizationSetList,
    this.created,
    this.updated,
  });

  ZhenxieSentenceMemberPairEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    order = _parseDouble(json['order']);
    pairTypeNid = json['pairTypeNid']?.toString();
    pairType = _parseObject(json['pairType'], ZhenxieSentenceMemberNamedInfoEntity.fromJson);
    name = _parseLanguageTextList(json['name']);
    description = _parseLanguageTextList(json['description']);
    teachingExampleFrom = json['teachingExampleFrom']?.toString();
    teachingExampleTo = json['teachingExampleTo']?.toString();
    practiceMode = json['practiceMode']?.toString();
    preferredPractice = json['preferredPractice']?.toString();
    system = json['system'];
    enabled = json['enabled'];
    fromRealization = _parseObject(
      json['fromRealization'],
      ZhenxieSentenceMemberRealizationInfoEntity.fromJson,
    );
    toRealization = _parseObject(
      json['toRealization'],
      ZhenxieSentenceMemberRealizationInfoEntity.fromJson,
    );
    interactionModes = _parseStringList(json['interactionModes']);
    relationDirection = json['relationDirection']?.toString();
    orderConstraint = json['orderConstraint']?.toString();
    semanticAnchorMappings = _parseObjectList(
      json['semanticAnchorMappings'],
      ZhenxieSentenceMemberSemanticAnchorMappingEntity.fromJson,
    );
    realizationSetList = _parseObjectList(
      json['realizationSetList'],
      ZhenxieSentenceMemberRealizationSetEntity.fromJson,
    );
    created = json['created']?.toString();
    updated = json['updated']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['order'] = order;
    data['pairTypeNid'] = pairTypeNid;
    data['pairType'] = pairType?.toJson();
    data['name'] = name?.map((item) => item?.toJson()).toList();
    data['description'] = description?.map((item) => item?.toJson()).toList();
    data['teachingExampleFrom'] = teachingExampleFrom;
    data['teachingExampleTo'] = teachingExampleTo;
    data['practiceMode'] = practiceMode;
    data['preferredPractice'] = preferredPractice;
    data['system'] = system;
    data['enabled'] = enabled;
    data['fromRealization'] = fromRealization?.toJson();
    data['toRealization'] = toRealization?.toJson();
    data['interactionModes'] = interactionModes;
    data['relationDirection'] = relationDirection;
    data['orderConstraint'] = orderConstraint;
    data['semanticAnchorMappings'] = semanticAnchorMappings?.map((item) => item?.toJson()).toList();
    data['realizationSetList'] = realizationSetList?.map((item) => item?.toJson()).toList();
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }
}

/// pair 里的 realization 信息。
class ZhenxieSentenceMemberRealizationInfoEntity {
  String? patternNid;
  ZhenxieSentenceMemberPatternInfoEntity? pattern;
  List<String?>? grammarFeatureNids;
  List<ZhenxieSentenceMemberNamedInfoEntity?>? grammarFeatures;

  ZhenxieSentenceMemberRealizationInfoEntity({
    this.patternNid,
    this.pattern,
    this.grammarFeatureNids,
    this.grammarFeatures,
  });

  ZhenxieSentenceMemberRealizationInfoEntity.fromJson(Map<String, dynamic> json) {
    patternNid = json['patternNid']?.toString();
    pattern = _parseObject(json['pattern'], ZhenxieSentenceMemberPatternInfoEntity.fromJson);
    grammarFeatureNids = _parseStringList(json['grammarFeatureNids']);
    grammarFeatures = _parseObjectList(
      json['grammarFeatures'],
      ZhenxieSentenceMemberNamedInfoEntity.fromJson,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['patternNid'] = patternNid;
    data['pattern'] = pattern?.toJson();
    data['grammarFeatureNids'] = grammarFeatureNids;
    data['grammarFeatures'] = grammarFeatures?.map((item) => item?.toJson()).toList();
    return data;
  }
}

/// pair 里的语义锚点映射。
class ZhenxieSentenceMemberSemanticAnchorMappingEntity {
  String? fromPatternSlotKey;
  ZhenxieSentenceMemberNamedInfoEntity? fromPatternSlot;
  String? toPatternSlotKey;
  ZhenxieSentenceMemberNamedInfoEntity? toPatternSlot;

  ZhenxieSentenceMemberSemanticAnchorMappingEntity({
    this.fromPatternSlotKey,
    this.fromPatternSlot,
    this.toPatternSlotKey,
    this.toPatternSlot,
  });

  ZhenxieSentenceMemberSemanticAnchorMappingEntity.fromJson(Map<String, dynamic> json) {
    fromPatternSlotKey = json['fromPatternSlotKey']?.toString();
    fromPatternSlot = _parseObject(
      json['fromPatternSlot'],
      ZhenxieSentenceMemberNamedInfoEntity.fromJson,
    );
    toPatternSlotKey = json['toPatternSlotKey']?.toString();
    toPatternSlot = _parseObject(
      json['toPatternSlot'],
      ZhenxieSentenceMemberNamedInfoEntity.fromJson,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['fromPatternSlotKey'] = fromPatternSlotKey;
    data['fromPatternSlot'] = fromPatternSlot?.toJson();
    data['toPatternSlotKey'] = toPatternSlotKey;
    data['toPatternSlot'] = toPatternSlot?.toJson();
    return data;
  }
}

/// pair 内挂载的 realization set。
class ZhenxieSentenceMemberRealizationSetEntity {
  int? uid;
  int? order;
  ZhenxieSentenceMemberRealizationBranchEntity? forkFrom;
  List<ZhenxieSentenceMemberRealizationBranchEntity?>? forkToList;
  String? access;

  ZhenxieSentenceMemberRealizationSetEntity({
    this.uid,
    this.order,
    this.forkFrom,
    this.forkToList,
    this.access,
  });

  ZhenxieSentenceMemberRealizationSetEntity.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    order = json['order']?.toInt();
    forkFrom = _parseObject(
      json['forkFrom'],
      ZhenxieSentenceMemberRealizationBranchEntity.fromJson,
    );
    forkToList = _parseObjectList(
      json['forkToList'],
      ZhenxieSentenceMemberRealizationBranchEntity.fromJson,
    );
    access = json['access']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['order'] = order;
    data['forkFrom'] = forkFrom?.toJson();
    data['forkToList'] = forkToList?.map((item) => item?.toJson()).toList();
    data['access'] = access;
    return data;
  }
}

/// realization set 里的单个分支成员。
class ZhenxieSentenceMemberRealizationBranchEntity {
  String? role;
  String? valueNid;
  String? pairNid;
  int? sentenceId;
  ZhenxieSentenceMemberSentenceEntity? sentenceStruct;
  ZhenxieSentenceMemberPairEntity? pair;
  ZhenxieSentenceMemberPatternInfoEntity? toPattern;

  ZhenxieSentenceMemberRealizationBranchEntity({
    this.role,
    this.valueNid,
    this.pairNid,
    this.sentenceId,
    this.sentenceStruct,
    this.pair,
    this.toPattern,
  });

  ZhenxieSentenceMemberRealizationBranchEntity.fromJson(Map<String, dynamic> json) {
    role = json['role']?.toString();
    valueNid = json['valueNid']?.toString();
    pairNid = json['pairNid']?.toString();
    sentenceId = json['sentenceId']?.toInt();
    sentenceStruct = _parseObject(
      json['sentenceStruct'],
      ZhenxieSentenceMemberSentenceEntity.fromJson,
    );
    pair = _parseObject(json['pair'], ZhenxieSentenceMemberPairEntity.fromJson);
    toPattern = _parseObject(
      json['toPattern'],
      ZhenxieSentenceMemberPatternInfoEntity.fromJson,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['role'] = role;
    data['valueNid'] = valueNid;
    data['pairNid'] = pairNid;
    data['sentenceId'] = sentenceId;
    data['sentenceStruct'] = sentenceStruct?.toJson();
    data['pair'] = pair?.toJson();
    data['toPattern'] = toPattern?.toJson();
    return data;
  }
}

/// 成员所属的宫格信息，结构和 grammar panorama 详情里的 cell 保持一致。
class ZhenxieSentenceMemberCellEntity {
  String? rowValue;
  String? colValue;
  String? key;
  List<LanguageText?>? label;
  ZhenxieSentenceMemberAxisValuesEntity? axisValues;

  ZhenxieSentenceMemberCellEntity({
    this.rowValue,
    this.colValue,
    this.key,
    this.label,
    this.axisValues,
  });

  ZhenxieSentenceMemberCellEntity.fromJson(Map<String, dynamic> json) {
    rowValue = json['rowValue']?.toString();
    colValue = json['colValue']?.toString();
    key = json['key']?.toString();
    if (json['label'] is List) {
      label = (json['label'] as List).map((item) {
        if (item == null || item is! Map) return null;
        return LanguageText.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    }
    if (json['axisValues'] is Map) {
      axisValues = ZhenxieSentenceMemberAxisValuesEntity.fromJson(
        Map<String, dynamic>.from(json['axisValues']),
      );
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['rowValue'] = rowValue;
    data['colValue'] = colValue;
    data['key'] = key;
    data['label'] = label?.map((item) => item?.toJson()).toList();
    data['axisValues'] = axisValues?.toJson();
    return data;
  }
}

/// cell 当前命中的轴值组合。
class ZhenxieSentenceMemberAxisValuesEntity {
  String? time;
  String? aspect;

  ZhenxieSentenceMemberAxisValuesEntity({
    this.time,
    this.aspect,
  });

  ZhenxieSentenceMemberAxisValuesEntity.fromJson(Map<String, dynamic> json) {
    time = json['time']?.toString();
    aspect = json['aspect']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['time'] = time;
    data['aspect'] = aspect;
    return data;
  }
}

/// 成员里的焦点定义，用于标记句子中需要高亮的片段。
class ZhenxieSentenceMemberFocusEntity {
  String? focusKey;
  List<ZhenxieSentenceMemberFocusRangeEntity?>? ranges;

  ZhenxieSentenceMemberFocusEntity({
    this.focusKey,
    this.ranges,
  });

  ZhenxieSentenceMemberFocusEntity.fromJson(Map<String, dynamic> json) {
    focusKey = json['focusKey']?.toString();
    if (json['ranges'] is List) {
      ranges = (json['ranges'] as List).map((item) {
        if (item == null || item is! Map) return null;
        return ZhenxieSentenceMemberFocusRangeEntity.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['focusKey'] = focusKey;
    data['ranges'] = ranges?.map((item) => item?.toJson()).toList();
    return data;
  }
}

/// 焦点高亮范围，承接 start/end/text/key 四个协议字段。
class ZhenxieSentenceMemberFocusRangeEntity {
  int? start;
  int? end;
  String? text;
  String? key;

  ZhenxieSentenceMemberFocusRangeEntity({
    this.start,
    this.end,
    this.text,
    this.key,
  });

  ZhenxieSentenceMemberFocusRangeEntity.fromJson(Map<String, dynamic> json) {
    start = json['start']?.toInt();
    end = json['end']?.toInt();
    text = json['text']?.toString();
    key = json['key']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['start'] = start;
    data['end'] = end;
    data['text'] = text;
    data['key'] = key;
    return data;
  }
}

List<LanguageText?>? _parseLanguageTextList(dynamic value) {
  if (value is! List) return null;
  return value.map((item) {
    if (item == null || item is! Map) return null;
    return LanguageText.fromJson(Map<String, dynamic>.from(item));
  }).toList();
}

List<String?>? _parseStringList(dynamic value) {
  if (value is! List) return null;
  return value.map((item) => item?.toString()).toList();
}

List<int?>? _parseIntList(dynamic value) {
  if (value is! List) return null;
  return value
      .map((item) => item == null ? null : int.tryParse(item.toString()))
      .toList();
}

T? _parseObject<T>(dynamic value, T Function(Map<String, dynamic> json) parser) {
  if (value is! Map) return null;
  return parser(Map<String, dynamic>.from(value));
}

List<T?>? _parseObjectList<T>(dynamic value, T Function(Map<String, dynamic> json) parser) {
  if (value is! List) return null;
  return value.map((item) {
    if (item == null || item is! Map) return null;
    return parser(Map<String, dynamic>.from(item));
  }).toList();
}

double? _parseDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}
