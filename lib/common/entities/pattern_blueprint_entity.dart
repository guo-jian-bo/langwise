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
  List<PatternBlueprintEditSlotEntity?>? editSlots;
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
  List<ZhenxieRealizationSetsEntity?>? realizationSets;
  bool? supportsPyramid;
  String? created;
  String? updated;
  
  List<PatternBlueprintSentenceBriefEntity?>? sentenceRealizationList;

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
    this.editSlots,
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
    this.realizationSets,
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
    editSlots = _parseObjectList(
      json['editSlots'],
      PatternBlueprintEditSlotEntity.fromJson,
    );
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
    realizationSets = _parseObjectList(
      json['realizationSets'],
      ZhenxieRealizationSetsEntity.fromJson,
    );
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
    data['editSlots'] = editSlots?.map((e) => e?.toJson()).toList();
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
    data['realizationSets'] = realizationSets?.map((e) => e?.toJson()).toList();
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
  List<LanguageText?>? categoryName;
  List<LanguageText?>? categoryDescription;
  String? categoryNid;
  List<String?>? usageKinds;
  List<String?>? surfaceFromSlotKeys;
  String? color;

  PatternBlueprintNamedInfoEntity({
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

  PatternBlueprintNamedInfoEntity.fromJson(Map<String, dynamic> json) {
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
    data['name'] = name?.map((e) => e?.toJson()).toList();
    data['description'] = description?.map((e) => e?.toJson()).toList();
    data['categoryNid'] = categoryNid;
    data['categoryName'] = categoryName?.map((e) => e?.toJson()).toList();
    data['categoryDescription'] = categoryDescription?.map((e) => e?.toJson()).toList();
    data['usageKinds'] = usageKinds;
    data['surfaceFromSlotKeys'] = surfaceFromSlotKeys;
    data['color'] = color;
    return data;
  }
}

/// 蓝图可编辑槽位定义。
class PatternBlueprintEditSlotEntity {
  String? positionKey;
  String? patternNid;
  String? template;
  List<PatternBlueprintEditOptionSlotEntity?>? optionSlots;

  PatternBlueprintEditSlotEntity({
    this.positionKey,
    this.patternNid,
    this.template,
    this.optionSlots,
  });

  PatternBlueprintEditSlotEntity.fromJson(Map<String, dynamic> json) {
    positionKey = json['positionKey']?.toString();
    patternNid = json['patternNid']?.toString();
    template = json['template']?.toString();
    optionSlots = _parseObjectList(
      json['optionSlots'],
      PatternBlueprintEditOptionSlotEntity.fromJson,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['positionKey'] = positionKey;
    data['patternNid'] = patternNid;
    data['template'] = template;
    data['optionSlots'] = optionSlots?.map((e) => e?.toJson()).toList();
    return data;
  }
}

/// 编辑态下的候选槽位配置。
class PatternBlueprintEditOptionSlotEntity {
  String? slotKey;
  String? role;
  bool? required;
  bool? selected;
  bool? selectable;
  bool? dialSelectable;
  bool? growthSelectable;
  int? growthOrder;
  bool? unused;
  List<String?>? dependsOn;

  PatternBlueprintEditOptionSlotEntity({
    this.slotKey,
    this.role,
    this.required,
    this.selected,
    this.selectable,
    this.dialSelectable,
    this.growthSelectable,
    this.growthOrder,
    this.unused,
    this.dependsOn,
  });

  PatternBlueprintEditOptionSlotEntity.fromJson(Map<String, dynamic> json) {
    slotKey = json['slotKey']?.toString();
    role = json['role']?.toString();
    required = json['required'];
    selected = json['selected'];
    selectable = json['selectable'];
    dialSelectable = json['dialSelectable'];
    growthSelectable = json['growthSelectable'];
    growthOrder = json['growthOrder']?.toInt();
    unused = json['unused'];
    dependsOn = _parseStringList(json['dependsOn']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['slotKey'] = slotKey;
    data['role'] = role;
    data['required'] = required;
    data['selected'] = selected;
    data['selectable'] = selectable;
    data['dialSelectable'] = dialSelectable;
    data['growthSelectable'] = growthSelectable;
    data['growthOrder'] = growthOrder;
    data['unused'] = unused;
    data['dependsOn'] = dependsOn;
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

/// 代表句展开摘要，对齐文档中的 SentenceBrief 约定。
class PatternBlueprintSentenceBriefEntity {
  int? uid;
  String? valueNid;
  int? sentenceId;
  int? semanticId;
  String? content;
  String? definition;
  String? contentType;
  String? patternNid;
  List<LanguageText?>? patternName;
  String? patternTemplate;
  String? blueprintScope;
  List<ZhenxieSentenceMemberSegmentEntity?>? segmentList;
  int? order;
  int? realizationSetId;
  int? fromSentenceId;
  SentencePairSentenceBriefEntity? fromSentenceStruct;
  int? toSentenceId;
  SentencePairSentenceBriefEntity? toSentenceStruct;
  PatternBlueprintSentenceBriefEntity? sentenceStruct;
  SentenceForkRealizationBranchEntity? forkFrom;
  List<SentenceForkRealizationBranchEntity?>? forkToList;

  String? access;

  /// 是否上架
  bool get isNormal => actualAccess == "NORMAL" || forkFrom?.sentenceStruct?.isNormal == true;

  int? get actualSentenceId =>
      sentenceId ?? sentenceStruct?.sentenceId ?? fromSentenceStruct?.sentenceId ?? fromSentenceId ?? forkFrom?.sentenceStruct?.sentenceId ?? forkFrom?.sentenceId;

  String? get actualContent => content ?? sentenceStruct?.content ?? fromSentenceStruct?.content ?? forkFrom?.sentenceStruct?.content;

  String? get actualDefinition => definition ?? sentenceStruct?.definition ?? fromSentenceStruct?.definition ?? forkFrom?.sentenceStruct?.definition;

  String? get actualAccess => access ?? sentenceStruct?.access ?? fromSentenceStruct?.access ?? forkFrom?.sentenceStruct?.access;

  String? get actualPatternNid => patternNid ?? sentenceStruct?.patternNid ?? fromSentenceStruct?.patternNid ?? forkFrom?.sentenceStruct?.patternNid;

  List<LanguageText?>? get actualPatternName => patternName ?? sentenceStruct?.patternName ?? forkFrom?.sentenceStruct?.patternName;

  PatternBlueprintSentenceBriefEntity({
    this.uid,
    this.valueNid,
    this.sentenceId,
    this.semanticId,
    this.content,
    this.definition,
    this.contentType,
    this.patternNid,
    this.patternName,
    this.patternTemplate,
    this.blueprintScope,
    this.segmentList,
    this.order,
    this.realizationSetId,
    this.fromSentenceId,
    this.fromSentenceStruct,
    this.toSentenceId,
    this.toSentenceStruct,
    this.sentenceStruct,
    this.forkFrom,
    this.forkToList,
    this.access,
  });

  PatternBlueprintSentenceBriefEntity.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    valueNid = json['valueNid']?.toString();
    sentenceId = json['sentenceId']?.toInt();
    semanticId = json['semanticId']?.toInt();
    content = json['content']?.toString();
    definition = json['definition']?.toString();
    contentType = json['contentType']?.toString();
    patternNid = json['patternNid']?.toString();
    patternName = _parseLanguageTextList(json['patternName']);
    patternTemplate = json['patternTemplate']?.toString();
    blueprintScope = json['blueprintScope']?.toString();
    segmentList = _parseObjectList(
      json['segmentList'],
      ZhenxieSentenceMemberSegmentEntity.fromJson,
    );
    order = json['order']?.toInt();
    realizationSetId = json['realizationSetId']?.toInt();
    fromSentenceId = json['fromSentenceId']?.toInt();
    fromSentenceStruct = _parseObject(json['fromSentenceStruct'], SentencePairSentenceBriefEntity.fromJson);
    toSentenceId = json['toSentenceId']?.toInt();
    toSentenceStruct = _parseObject(json['toSentenceStruct'], SentencePairSentenceBriefEntity.fromJson);
    sentenceStruct = _parseObject(json['sentenceStruct'], PatternBlueprintSentenceBriefEntity.fromJson);
    forkFrom = _parseObject(json['forkFrom'], SentenceForkRealizationBranchEntity.fromJson);
    forkToList = _parseObjectList(
      json['forkToList'],
      SentenceForkRealizationBranchEntity.fromJson,
    );
    access = json['access']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['valueNid'] = valueNid;
    data['sentenceId'] = sentenceId;
    data['semanticId'] = semanticId;
    data['content'] = content;
    data['definition'] = definition;
    data['contentType'] = contentType;
    data['patternNid'] = patternNid;
    data['patternName'] = patternName?.map((e) => e?.toJson()).toList();
    data['patternTemplate'] = patternTemplate;
    data['blueprintScope'] = blueprintScope;
    data['segmentList'] = segmentList?.map((e) => e?.toJson()).toList();
    data['order'] = order;
    data['realizationSetId'] = realizationSetId;
    data['fromSentenceId'] = fromSentenceId;
    data['fromSentenceStruct'] = fromSentenceStruct?.toJson();
    data['toSentenceId'] = toSentenceId;
    data['toSentenceStruct'] = toSentenceStruct?.toJson();
    data['sentenceStruct'] = sentenceStruct?.toJson();
    data['forkFrom'] = forkFrom?.toJson();
    data['forkToList'] = forkToList?.map((e) => e?.toJson()).toList();
    data['access'] = access;
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
