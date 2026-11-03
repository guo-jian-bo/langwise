import 'entities.dart';

/// 句型蓝图实体，对齐句型蓝图列表/详情接口返回结构。
class PatternBlueprintEntity {
  String? nid;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  String? familyNid;
  PatternBlueprintNamedInfoEntity? family;
  PatternBlueprintDifficultyEntity? difficulty;
  int? order;
  String? blueprintScope;
  String? patternTier;
  bool? analysisEligible;
  String? template;
  List<PatternBlueprintControlledGrammarSlotEntity?>? controlledGrammarSlots;
  List<PatternBlueprintControlledGrammarSlotListItemEntity?>?
      controlledGrammarSlotList;
  List<PatternBlueprintOpenSlotEntity?>? openSlots;
  List<PatternBlueprintOpenSlotListItemEntity?>? openSlotList;
  String? basicTypeNid;
  PatternBlueprintNamedInfoEntity? basicType;
  String? functionalTypeNid;
  PatternBlueprintNamedInfoEntity? functionalType;
  String? clauseProfileNid;
  PatternBlueprintNamedInfoEntity? clauseProfile;
  List<String?>? grammarFeatureNids;
  List<PatternBlueprintNamedInfoEntity?>? grammarFeatures;
  List<String?>? specialFeatureNids;
  List<PatternBlueprintNamedInfoEntity?>? specialFeatures;
  List<String?>? communicativeFunctionNids;
  List<PatternBlueprintNamedInfoEntity?>? communicativeFunctions;
  List<String?>? discourseRoleNids;
  List<PatternBlueprintNamedInfoEntity?>? discourseRoles;
  List<String?>? teachingRealizations;
  List<String?>? previewTexts;
  bool? system;
  bool? enabled;
  String? primarySvocaCodeNid;
  PatternBlueprintNamedInfoEntity? primarySvoca;
  List<String?>? allowedSvocaCodeNids;
  List<PatternBlueprintNamedInfoEntity?>? allowedSvocas;
  String? tenseScope;
  PatternBlueprintPredicateRealizationProfileEntity?
      predicateRealizationProfile;
  PatternBlueprintPredicateRealizationProfileInfoEntity?
      predicateRealizationProfileInfo;
  List<PatternBlueprintSentenceRealizationEntity?>? sentenceRealizations;
  List<PatternBlueprintSentenceBriefEntity?>? sentenceRealizationList;
  bool? supportsPyramid;
  String? created;
  String? updated;

  PatternBlueprintEntity({
    this.nid,
    this.name,
    this.description,
    this.familyNid,
    this.family,
    this.difficulty,
    this.order,
    this.blueprintScope,
    this.patternTier,
    this.analysisEligible,
    this.template,
    this.controlledGrammarSlots,
    this.controlledGrammarSlotList,
    this.openSlots,
    this.openSlotList,
    this.basicTypeNid,
    this.basicType,
    this.functionalTypeNid,
    this.functionalType,
    this.clauseProfileNid,
    this.clauseProfile,
    this.grammarFeatureNids,
    this.grammarFeatures,
    this.specialFeatureNids,
    this.specialFeatures,
    this.communicativeFunctionNids,
    this.communicativeFunctions,
    this.discourseRoleNids,
    this.discourseRoles,
    this.teachingRealizations,
    this.previewTexts,
    this.system,
    this.enabled,
    this.primarySvocaCodeNid,
    this.primarySvoca,
    this.allowedSvocaCodeNids,
    this.allowedSvocas,
    this.tenseScope,
    this.predicateRealizationProfile,
    this.predicateRealizationProfileInfo,
    this.sentenceRealizations,
    this.sentenceRealizationList,
    this.supportsPyramid,
    this.created,
    this.updated,
  });

  PatternBlueprintEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    name = _parseLanguageTextList(json['name']);
    description = _parseLanguageTextList(json['description']);
    familyNid = json['familyNid']?.toString();
    family =
        _parseObject(json['family'], PatternBlueprintNamedInfoEntity.fromJson);
    difficulty = _parseObject(
        json['difficulty'], PatternBlueprintDifficultyEntity.fromJson);
    order = json['order']?.toInt();
    blueprintScope = json['blueprintScope']?.toString();
    patternTier = json['patternTier']?.toString();
    analysisEligible = json['analysisEligible'];
    template = json['template']?.toString();
    controlledGrammarSlots = _parseObjectList(json['controlledGrammarSlots'],
        PatternBlueprintControlledGrammarSlotEntity.fromJson);
    controlledGrammarSlotList = _parseObjectList(
        json['controlledGrammarSlotList'],
        PatternBlueprintControlledGrammarSlotListItemEntity.fromJson);
    openSlots = _parseObjectList(
        json['openSlots'], PatternBlueprintOpenSlotEntity.fromJson);
    openSlotList = _parseObjectList(
        json['openSlotList'], PatternBlueprintOpenSlotListItemEntity.fromJson);
    basicTypeNid = json['basicTypeNid']?.toString();
    basicType = _parseObject(
        json['basicType'], PatternBlueprintNamedInfoEntity.fromJson);
    functionalTypeNid = json['functionalTypeNid']?.toString();
    functionalType = _parseObject(
        json['functionalType'], PatternBlueprintNamedInfoEntity.fromJson);
    clauseProfileNid = json['clauseProfileNid']?.toString();
    clauseProfile = _parseObject(
        json['clauseProfile'], PatternBlueprintNamedInfoEntity.fromJson);
    grammarFeatureNids = _parseStringList(json['grammarFeatureNids']);
    grammarFeatures = _parseObjectList(
        json['grammarFeatures'], PatternBlueprintNamedInfoEntity.fromJson);
    specialFeatureNids = _parseStringList(json['specialFeatureNids']);
    specialFeatures = _parseObjectList(
        json['specialFeatures'], PatternBlueprintNamedInfoEntity.fromJson);
    communicativeFunctionNids =
        _parseStringList(json['communicativeFunctionNids']);
    communicativeFunctions = _parseObjectList(json['communicativeFunctions'],
        PatternBlueprintNamedInfoEntity.fromJson);
    discourseRoleNids = _parseStringList(json['discourseRoleNids']);
    discourseRoles = _parseObjectList(
        json['discourseRoles'], PatternBlueprintNamedInfoEntity.fromJson);
    teachingRealizations = _parseStringList(json['teachingRealizations']);
    previewTexts = _parseStringList(json['previewTexts']);
    system = json['system'];
    enabled = json['enabled'];
    primarySvocaCodeNid = json['primarySvocaCodeNid']?.toString();
    primarySvoca = _parseObject(
        json['primarySvoca'], PatternBlueprintNamedInfoEntity.fromJson);
    allowedSvocaCodeNids = _parseStringList(json['allowedSvocaCodeNids']);
    allowedSvocas = _parseObjectList(
        json['allowedSvocas'], PatternBlueprintNamedInfoEntity.fromJson);
    tenseScope = json['tenseScope']?.toString();
    predicateRealizationProfile = _parseObject(
        json['predicateRealizationProfile'],
        PatternBlueprintPredicateRealizationProfileEntity.fromJson);
    predicateRealizationProfileInfo = _parseObject(
        json['predicateRealizationProfileInfo'],
        PatternBlueprintPredicateRealizationProfileInfoEntity.fromJson);
    sentenceRealizations = _parseObjectList(json['sentenceRealizations'],
        PatternBlueprintSentenceRealizationEntity.fromJson);
    sentenceRealizationList = _parseObjectList(json['sentenceRealizationList'],
        PatternBlueprintSentenceBriefEntity.fromJson);
    supportsPyramid = json['supportsPyramid'];
    created = json['created']?.toString();
    updated = json['updated']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['name'] = name?.map((e) => e?.toJson()).toList();
    data['description'] = description?.map((e) => e?.toJson()).toList();
    data['familyNid'] = familyNid;
    data['family'] = family?.toJson();
    data['difficulty'] = difficulty?.toJson();
    data['order'] = order;
    data['blueprintScope'] = blueprintScope;
    data['patternTier'] = patternTier;
    data['analysisEligible'] = analysisEligible;
    data['template'] = template;
    data['controlledGrammarSlots'] =
        controlledGrammarSlots?.map((e) => e?.toJson()).toList();
    data['controlledGrammarSlotList'] =
        controlledGrammarSlotList?.map((e) => e?.toJson()).toList();
    data['openSlots'] = openSlots?.map((e) => e?.toJson()).toList();
    data['openSlotList'] = openSlotList?.map((e) => e?.toJson()).toList();
    data['basicTypeNid'] = basicTypeNid;
    data['basicType'] = basicType?.toJson();
    data['functionalTypeNid'] = functionalTypeNid;
    data['functionalType'] = functionalType?.toJson();
    data['clauseProfileNid'] = clauseProfileNid;
    data['clauseProfile'] = clauseProfile?.toJson();
    data['grammarFeatureNids'] = grammarFeatureNids;
    data['grammarFeatures'] = grammarFeatures?.map((e) => e?.toJson()).toList();
    data['specialFeatureNids'] = specialFeatureNids;
    data['specialFeatures'] = specialFeatures?.map((e) => e?.toJson()).toList();
    data['communicativeFunctionNids'] = communicativeFunctionNids;
    data['communicativeFunctions'] =
        communicativeFunctions?.map((e) => e?.toJson()).toList();
    data['discourseRoleNids'] = discourseRoleNids;
    data['discourseRoles'] = discourseRoles?.map((e) => e?.toJson()).toList();
    data['teachingRealizations'] = teachingRealizations;
    data['previewTexts'] = previewTexts;
    data['system'] = system;
    data['enabled'] = enabled;
    data['primarySvocaCodeNid'] = primarySvocaCodeNid;
    data['primarySvoca'] = primarySvoca?.toJson();
    data['allowedSvocaCodeNids'] = allowedSvocaCodeNids;
    data['allowedSvocas'] = allowedSvocas?.map((e) => e?.toJson()).toList();
    data['tenseScope'] = tenseScope;
    data['predicateRealizationProfile'] = predicateRealizationProfile?.toJson();
    data['predicateRealizationProfileInfo'] =
        predicateRealizationProfileInfo?.toJson();
    data['sentenceRealizations'] =
        sentenceRealizations?.map((e) => e?.toJson()).toList();
    data['sentenceRealizationList'] =
        sentenceRealizationList?.map((e) => e?.toJson()).toList();
    data['supportsPyramid'] = supportsPyramid;
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }
}

class PatternBlueprintDifficultyEntity {
  int? max;
  int? min;

  PatternBlueprintDifficultyEntity({
    this.max,
    this.min,
  });

  PatternBlueprintDifficultyEntity.fromJson(Map<String, dynamic> json) {
    max = json['max']?.toInt();
    min = json['min']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['max'] = max;
    data['min'] = min;
    return data;
  }
}

class PatternBlueprintNamedInfoEntity {
  String? nid;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  String? categoryNid;
  List<String?>? usageKinds;
  List<String?>? surfaceFromSlotKeys;
  String? color;

  PatternBlueprintNamedInfoEntity({
    this.nid,
    this.name,
    this.description,
    this.categoryNid,
    this.usageKinds,
    this.surfaceFromSlotKeys,
    this.color,
  });

  PatternBlueprintNamedInfoEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    name = _parseLanguageTextList(json['name']);
    description = _parseLanguageTextList(json['description']);
    categoryNid = json['categoryNid']?.toString();
    usageKinds = _parseStringList(json['usageKinds']);
    surfaceFromSlotKeys = _parseStringList(json['surfaceFromSlotKeys']);
    color = json['color']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['name'] = name?.map((e) => e?.toJson()).toList();
    data['description'] = description?.map((e) => e?.toJson()).toList();
    data['categoryNid'] = categoryNid;
    data['usageKinds'] = usageKinds;
    data['surfaceFromSlotKeys'] = surfaceFromSlotKeys;
    data['color'] = color;
    return data;
  }
}

class PatternBlueprintControlledGrammarSlotEntity {
  String? slotKey;
  String? rendersAs;
  List<String?>? options;
  List<String?>? activationFeatureNids;

  PatternBlueprintControlledGrammarSlotEntity({
    this.slotKey,
    this.rendersAs,
    this.options,
    this.activationFeatureNids,
  });

  PatternBlueprintControlledGrammarSlotEntity.fromJson(
      Map<String, dynamic> json) {
    slotKey = json['slotKey']?.toString();
    rendersAs = json['rendersAs']?.toString();
    options = _parseStringList(json['options']);
    activationFeatureNids = _parseStringList(json['activationFeatureNids']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['slotKey'] = slotKey;
    data['rendersAs'] = rendersAs;
    data['options'] = options;
    data['activationFeatureNids'] = activationFeatureNids;
    return data;
  }
}

class PatternBlueprintControlledGrammarSlotListItemEntity {
  String? slotKey;
  String? rendersAs;
  PatternBlueprintNamedInfoEntity? slot;
  List<String?>? options;
  List<String?>? activationFeatureNids;
  List<PatternBlueprintNamedInfoEntity?>? activationFeatures;

  PatternBlueprintControlledGrammarSlotListItemEntity({
    this.slotKey,
    this.rendersAs,
    this.slot,
    this.options,
    this.activationFeatureNids,
    this.activationFeatures,
  });

  PatternBlueprintControlledGrammarSlotListItemEntity.fromJson(
      Map<String, dynamic> json) {
    slotKey = json['slotKey']?.toString();
    rendersAs = json['rendersAs']?.toString();
    slot = _parseObject(json['slot'], PatternBlueprintNamedInfoEntity.fromJson);
    options = _parseStringList(json['options']);
    activationFeatureNids = _parseStringList(json['activationFeatureNids']);
    activationFeatures = _parseObjectList(
        json['activationFeatures'], PatternBlueprintNamedInfoEntity.fromJson);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['slotKey'] = slotKey;
    data['rendersAs'] = rendersAs;
    data['slot'] = slot?.toJson();
    data['options'] = options;
    data['activationFeatureNids'] = activationFeatureNids;
    data['activationFeatures'] =
        activationFeatures?.map((e) => e?.toJson()).toList();
    return data;
  }
}

class PatternBlueprintOpenSlotEntity {
  String? slotKey;
  bool? required;
  bool? grammarControlling;
  int? growthPriority;
  List<String?>? dependsOn;

  PatternBlueprintOpenSlotEntity({
    this.slotKey,
    this.required,
    this.grammarControlling,
    this.growthPriority,
    this.dependsOn,
  });

  PatternBlueprintOpenSlotEntity.fromJson(Map<String, dynamic> json) {
    slotKey = json['slotKey']?.toString();
    required = json['required'];
    grammarControlling = json['grammarControlling'];
    growthPriority = json['growthPriority']?.toInt();
    dependsOn = _parseStringList(json['dependsOn']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['slotKey'] = slotKey;
    data['required'] = required;
    data['grammarControlling'] = grammarControlling;
    data['growthPriority'] = growthPriority;
    data['dependsOn'] = dependsOn;
    return data;
  }
}

class PatternBlueprintOpenSlotListItemEntity {
  String? slotKey;
  PatternBlueprintNamedInfoEntity? slot;
  bool? required;
  bool? grammarControlling;
  int? growthPriority;
  List<String?>? dependsOn;
  List<PatternBlueprintNamedInfoEntity?>? dependsOnSlots;

  PatternBlueprintOpenSlotListItemEntity({
    this.slotKey,
    this.slot,
    this.required,
    this.grammarControlling,
    this.growthPriority,
    this.dependsOn,
    this.dependsOnSlots,
  });

  PatternBlueprintOpenSlotListItemEntity.fromJson(Map<String, dynamic> json) {
    slotKey = json['slotKey']?.toString();
    slot = _parseObject(json['slot'], PatternBlueprintNamedInfoEntity.fromJson);
    required = json['required'];
    grammarControlling = json['grammarControlling'];
    growthPriority = json['growthPriority']?.toInt();
    dependsOn = _parseStringList(json['dependsOn']);
    dependsOnSlots = _parseObjectList(
        json['dependsOnSlots'], PatternBlueprintNamedInfoEntity.fromJson);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['slotKey'] = slotKey;
    data['slot'] = slot?.toJson();
    data['required'] = required;
    data['grammarControlling'] = grammarControlling;
    data['growthPriority'] = growthPriority;
    data['dependsOn'] = dependsOn;
    data['dependsOnSlots'] = dependsOnSlots?.map((e) => e?.toJson()).toList();
    return data;
  }
}

class PatternBlueprintPredicateRealizationProfileEntity {
  String? kind;
  String? predicateSlotKey;
  List<String?>? operatorSlotKeys;

  PatternBlueprintPredicateRealizationProfileEntity({
    this.kind,
    this.predicateSlotKey,
    this.operatorSlotKeys,
  });

  PatternBlueprintPredicateRealizationProfileEntity.fromJson(
      Map<String, dynamic> json) {
    kind = json['kind']?.toString();
    predicateSlotKey = json['predicateSlotKey']?.toString();
    operatorSlotKeys = _parseStringList(json['operatorSlotKeys']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['kind'] = kind;
    data['predicateSlotKey'] = predicateSlotKey;
    data['operatorSlotKeys'] = operatorSlotKeys;
    return data;
  }
}

class PatternBlueprintPredicateRealizationProfileInfoEntity {
  String? kind;
  String? predicateSlotKey;
  PatternBlueprintNamedInfoEntity? predicateSlot;
  List<String?>? operatorSlotKeys;
  List<PatternBlueprintNamedInfoEntity?>? operatorSlots;

  PatternBlueprintPredicateRealizationProfileInfoEntity({
    this.kind,
    this.predicateSlotKey,
    this.predicateSlot,
    this.operatorSlotKeys,
    this.operatorSlots,
  });

  PatternBlueprintPredicateRealizationProfileInfoEntity.fromJson(
      Map<String, dynamic> json) {
    kind = json['kind']?.toString();
    predicateSlotKey = json['predicateSlotKey']?.toString();
    predicateSlot = _parseObject(
        json['predicateSlot'], PatternBlueprintNamedInfoEntity.fromJson);
    operatorSlotKeys = _parseStringList(json['operatorSlotKeys']);
    operatorSlots = _parseObjectList(
        json['operatorSlots'], PatternBlueprintNamedInfoEntity.fromJson);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['kind'] = kind;
    data['predicateSlotKey'] = predicateSlotKey;
    data['predicateSlot'] = predicateSlot?.toJson();
    data['operatorSlotKeys'] = operatorSlotKeys;
    data['operatorSlots'] = operatorSlots?.map((e) => e?.toJson()).toList();
    return data;
  }
}

class PatternBlueprintSentenceRealizationEntity {
  int? sentenceId;
  int? order;

  PatternBlueprintSentenceRealizationEntity({
    this.sentenceId,
    this.order,
  });

  PatternBlueprintSentenceRealizationEntity.fromJson(
      Map<String, dynamic> json) {
    sentenceId = json['sentenceId']?.toInt();
    order = json['order']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['sentenceId'] = sentenceId;
    data['order'] = order;
    return data;
  }
}

/// 代表句展开摘要，对齐文档中的 SentenceBrief 约定。
class PatternBlueprintSentenceBriefEntity {
  int? sentenceId;
  String? content;
  String? definition;
  String? patternNid;
  String? patternTemplate;
  String? blueprintScope;
  List<PatternBlueprintSentenceBriefSegmentEntity?>? segmentList;
  int? order;

  PatternBlueprintSentenceBriefEntity({
    this.sentenceId,
    this.content,
    this.definition,
    this.patternNid,
    this.patternTemplate,
    this.blueprintScope,
    this.segmentList,
    this.order,
  });

  PatternBlueprintSentenceBriefEntity.fromJson(Map<String, dynamic> json) {
    sentenceId = json['sentenceId']?.toInt();
    content = json['content']?.toString();
    definition = json['definition']?.toString();
    patternNid = json['patternNid']?.toString();
    patternTemplate = json['patternTemplate']?.toString();
    blueprintScope = json['blueprintScope']?.toString();
    segmentList = _parseObjectList(
      json['segmentList'],
      PatternBlueprintSentenceBriefSegmentEntity.fromJson,
    );
    order = json['order']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['sentenceId'] = sentenceId;
    data['content'] = content;
    data['definition'] = definition;
    data['patternNid'] = patternNid;
    data['patternTemplate'] = patternTemplate;
    data['blueprintScope'] = blueprintScope;
    data['segmentList'] = segmentList?.map((e) => e?.toJson()).toList();
    data['order'] = order;
    return data;
  }
}

/// 代表句中的已展开 segment。
class PatternBlueprintSentenceBriefSegmentEntity {
  String? slotKey;
  PatternBlueprintNamedInfoEntity? slot;
  bool? required;
  bool? grammarControlling;
  int? growthPriority;
  List<String?>? dependsOn;
  List<PatternBlueprintNamedInfoEntity?>? dependsOnSlots;
  String? text;
  String? renderSlotKey;
  String? sourceSlotKey;
  PatternBlueprintNamedInfoEntity? sourceSlot;
  int? slotUid;
  List<int?>? semanticIds;
  bool? literal;
  bool? hasChildStruct;
  PatternBlueprintSentenceBriefSegmentChildStructEntity? childStruct;

  PatternBlueprintSentenceBriefSegmentEntity({
    this.slotKey,
    this.slot,
    this.required,
    this.grammarControlling,
    this.growthPriority,
    this.dependsOn,
    this.dependsOnSlots,
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

  PatternBlueprintSentenceBriefSegmentEntity.fromJson(
      Map<String, dynamic> json) {
    slotKey = json['slotKey']?.toString();
    slot = _parseObject(json['slot'], PatternBlueprintNamedInfoEntity.fromJson);
    required = json['required'];
    grammarControlling = json['grammarControlling'];
    growthPriority = json['growthPriority']?.toInt();
    dependsOn = _parseStringList(json['dependsOn']);
    dependsOnSlots = _parseObjectList(
      json['dependsOnSlots'],
      PatternBlueprintNamedInfoEntity.fromJson,
    );
    text = json['text']?.toString();
    renderSlotKey = json['renderSlotKey']?.toString();
    sourceSlotKey = json['sourceSlotKey']?.toString();
    sourceSlot = _parseObject(
      json['sourceSlot'],
      PatternBlueprintNamedInfoEntity.fromJson,
    );
    slotUid = json['slotUid']?.toInt();
    semanticIds = _parseIntList(json['semanticIds']);
    literal = json['literal'];
    hasChildStruct = json['hasChildStruct'];
    childStruct = _parseObject(
      json['childStruct'],
      PatternBlueprintSentenceBriefSegmentChildStructEntity.fromJson,
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
    data['dependsOnSlots'] = dependsOnSlots?.map((e) => e?.toJson()).toList();
    data['text'] = text;
    data['renderSlotKey'] = renderSlotKey;
    data['sourceSlotKey'] = sourceSlotKey;
    data['sourceSlot'] = sourceSlot?.toJson();
    data['slotUid'] = slotUid;
    data['semanticIds'] = semanticIds;
    data['literal'] = literal;
    data['hasChildStruct'] = hasChildStruct;
    data['childStruct'] = childStruct?.toJson();
    return data;
  }
}

/// segment 下挂载的子句结构，内部 segmentList 复用代表句 segment 定义。
class PatternBlueprintSentenceBriefSegmentChildStructEntity {
  String? structType;
  int? rootClauseId;
  List<int?>? clauseIdList;
  String? content;
  String? patternNid;
  String? patternTemplate;
  String? clauseType;
  List<LanguageText?>? patternName;
  List<LanguageText?>? patternDescription;
  List<PatternBlueprintSentenceBriefSegmentEntity?>? segmentList;

  PatternBlueprintSentenceBriefSegmentChildStructEntity({
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

  PatternBlueprintSentenceBriefSegmentChildStructEntity.fromJson(
      Map<String, dynamic> json) {
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
      PatternBlueprintSentenceBriefSegmentEntity.fromJson,
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
    data['patternName'] = patternName?.map((e) => e?.toJson()).toList();
    data['patternDescription'] = patternDescription?.map((e) => e?.toJson()).toList();
    data['segmentList'] = segmentList?.map((e) => e?.toJson()).toList();
    return data;
  }
}

List<LanguageText?>? _parseLanguageTextList(dynamic value) {
  if (value is! List) return null;
  return value.map((item) {
    if (item == null) return null;
    return LanguageText.fromJson(Map<String, dynamic>.from(item as Map));
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

T? _parseObject<T>(
    dynamic value, T Function(Map<String, dynamic> json) parser) {
  if (value is! Map) return null;
  return parser(Map<String, dynamic>.from(value));
}

List<T?>? _parseObjectList<T>(
    dynamic value, T Function(Map<String, dynamic> json) parser) {
  if (value is! List) return null;
  return value.map((item) {
    if (item == null || item is! Map) return null;
    return parser(Map<String, dynamic>.from(item));
  }).toList();
}
