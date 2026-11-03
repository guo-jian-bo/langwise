import 'entities.dart';

/// 句型对照实体，对齐句型对照详情接口返回结构。
class SentencePatternCompareEntity {
  String? nid;
  String? dimensionNid;
  PatternBlueprintNamedInfoEntity? dimension;
  String? transformationKindNid;
  PatternBlueprintNamedInfoEntity? transformationKind;
  String? contrastTypeNid;
  SentencePatternCompareContrastTypeEntity? contrastType;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  SentencePatternCompareMemberSwitchPolicyEntity? memberSwitchPolicy;
  SentencePatternCompareTeachingEntryEntity? teachingEntry;
  SentencePatternCompareTeachingEntryInfoEntity? teachingEntryInfo;
  List<SentencePatternCompareParadigmSlotEntity?>? paradigmSlots;
  List<SentencePatternCompareMemberEntity?>? members;
  List<SentencePatternCompareMemberEntity?>? memberList;
  List<SentencePatternCompareSentenceRealizationSetEntity?>? sentenceRealizationSets;
  List<SentencePatternCompareSentenceRealizationSetEntity?>? sentenceRealizationSetList;
  List<SentencePatternCompareSentenceRealizationSetEntity?>? realizationSetList; 
  int? order;
  bool? system;
  bool? enabled;
  String? created;
  String? updated;

  SentencePatternCompareEntity({
    this.nid,
    this.dimensionNid,
    this.dimension,
    this.transformationKindNid,
    this.transformationKind,
    this.contrastTypeNid,
    this.contrastType,
    this.name,
    this.description,
    this.memberSwitchPolicy,
    this.teachingEntry,
    this.teachingEntryInfo,
    this.paradigmSlots,
    this.members,
    this.memberList,
    this.sentenceRealizationSets,
    this.sentenceRealizationSetList,
    this.realizationSetList,
    this.order,
    this.system,
    this.enabled,
    this.created,
    this.updated,
  });

  SentencePatternCompareEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    dimensionNid = json['dimensionNid']?.toString();
    dimension = _parseObject(json['dimension'], PatternBlueprintNamedInfoEntity.fromJson);
    transformationKindNid = json['transformationKindNid']?.toString();
    transformationKind = _parseObject(json['transformationKind'], PatternBlueprintNamedInfoEntity.fromJson);
    contrastTypeNid = json['contrastTypeNid']?.toString();
    contrastType = _parseObject(json['contrastType'], SentencePatternCompareContrastTypeEntity.fromJson);
    name = _parseLanguageTextList(json['name']);
    description = _parseLanguageTextList(json['description']);
    memberSwitchPolicy = _parseObject(json['memberSwitchPolicy'], SentencePatternCompareMemberSwitchPolicyEntity.fromJson);
    teachingEntry = _parseObject(json['teachingEntry'], SentencePatternCompareTeachingEntryEntity.fromJson);
    teachingEntryInfo = _parseObject(json['teachingEntryInfo'], SentencePatternCompareTeachingEntryInfoEntity.fromJson);
    paradigmSlots = _parseObjectList(json['paradigmSlots'], SentencePatternCompareParadigmSlotEntity.fromJson);
    members = _parseObjectList(json['members'], SentencePatternCompareMemberEntity.fromJson);
    memberList = _parseObjectList(json['memberList'], SentencePatternCompareMemberEntity.fromJson);
    sentenceRealizationSets = _parseObjectList(
      json['sentenceRealizationSets'],
      SentencePatternCompareSentenceRealizationSetEntity.fromJson,
    );
    sentenceRealizationSetList = _parseObjectList(
      json['sentenceRealizationSetList'],
      SentencePatternCompareSentenceRealizationSetEntity.fromJson,
    );

    realizationSetList = _parseObjectList(json['realizationSetList'], SentencePatternCompareSentenceRealizationSetEntity.fromJson);
    order = json['order']?.toInt();
    system = json['system'];
    enabled = json['enabled'];
    created = json['created']?.toString();
    updated = json['updated']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['dimensionNid'] = dimensionNid;
    data['dimension'] = dimension?.toJson();
    data['transformationKindNid'] = transformationKindNid;
    data['transformationKind'] = transformationKind?.toJson();
    data['contrastTypeNid'] = contrastTypeNid;
    data['contrastType'] = contrastType?.toJson();
    data['name'] = name?.map((e) => e?.toJson()).toList();
    data['description'] = description?.map((e) => e?.toJson()).toList();
    data['memberSwitchPolicy'] = memberSwitchPolicy?.toJson();
    data['teachingEntry'] = teachingEntry?.toJson();
    data['teachingEntryInfo'] = teachingEntryInfo?.toJson();
    data['paradigmSlots'] = paradigmSlots?.map((e) => e?.toJson()).toList();
    data['members'] = members?.map((e) => e?.toJson()).toList();
    data['memberList'] = memberList?.map((e) => e?.toJson()).toList();
    data['sentenceRealizationSets'] = sentenceRealizationSets?.map((e) => e?.toJson()).toList();
    data['sentenceRealizationSetList'] = sentenceRealizationSetList?.map((e) => e?.toJson()).toList();
    data['realizationSetList'] = realizationSetList?.map((e) => e?.toJson()).toList();
    data['order'] = order;
    data['system'] = system;
    data['enabled'] = enabled;
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }
}

/// 对照类型，描述成员之间的对照关系。
class SentencePatternCompareContrastTypeEntity {
  String? nid;
  List<LanguageText?>? name;
  List<LanguageText?>? description;

  SentencePatternCompareContrastTypeEntity({
    this.nid,
    this.name,
    this.description,
  });

  SentencePatternCompareContrastTypeEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    name = _parseLanguageTextList(json['name']);
    description = _parseLanguageTextList(json['description']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['name'] = name?.map((e) => e?.toJson()).toList();
    data['description'] = description?.map((e) => e?.toJson()).toList();
    return data;
  }
}

/// 成员切换策略。
class SentencePatternCompareMemberSwitchPolicyEntity {
  String? mode;
  String? carry;
  String? unmappedSourceSlots;
  String? targetControlledSlots;

  SentencePatternCompareMemberSwitchPolicyEntity({
    this.mode,
    this.carry,
    this.unmappedSourceSlots,
    this.targetControlledSlots,
  });

  SentencePatternCompareMemberSwitchPolicyEntity.fromJson(Map<String, dynamic> json) {
    mode = json['mode']?.toString();
    carry = json['carry']?.toString();
    unmappedSourceSlots = json['unmappedSourceSlots']?.toString();
    targetControlledSlots = json['targetControlledSlots']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['mode'] = mode;
    data['carry'] = carry;
    data['unmappedSourceSlots'] = unmappedSourceSlots;
    data['targetControlledSlots'] = targetControlledSlots;
    return data;
  }
}

/// 教学入口配置。
class SentencePatternCompareTeachingEntryEntity {
  String? patternNid;
  List<String?>? grammarFeatureNids;

  SentencePatternCompareTeachingEntryEntity({
    this.patternNid,
    this.grammarFeatureNids,
  });

  SentencePatternCompareTeachingEntryEntity.fromJson(Map<String, dynamic> json) {
    patternNid = json['patternNid']?.toString();
    grammarFeatureNids = _parseStringList(json['grammarFeatureNids']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['patternNid'] = patternNid;
    data['grammarFeatureNids'] = grammarFeatureNids;
    return data;
  }
}

/// 教学入口详情，补充 pattern 与 grammarFeatures 信息。
class SentencePatternCompareTeachingEntryInfoEntity {
  String? patternNid;
  SentencePatternComparePatternInfoEntity? pattern;
  List<String?>? grammarFeatureNids;
  List<PatternBlueprintNamedInfoEntity?>? grammarFeatures;

  SentencePatternCompareTeachingEntryInfoEntity({
    this.patternNid,
    this.pattern,
    this.grammarFeatureNids,
    this.grammarFeatures,
  });

  SentencePatternCompareTeachingEntryInfoEntity.fromJson(Map<String, dynamic> json) {
    patternNid = json['patternNid']?.toString();
    pattern = _parseObject(json['pattern'], SentencePatternComparePatternInfoEntity.fromJson);
    grammarFeatureNids = _parseStringList(json['grammarFeatureNids']);
    grammarFeatures = _parseObjectList(json['grammarFeatures'], PatternBlueprintNamedInfoEntity.fromJson);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['patternNid'] = patternNid;
    data['pattern'] = pattern?.toJson();
    data['grammarFeatureNids'] = grammarFeatureNids;
    data['grammarFeatures'] = grammarFeatures?.map((e) => e?.toJson()).toList();
    return data;
  }
}

/// 轻量句型信息，保留模板字段。
class SentencePatternComparePatternInfoEntity {
  String? nid;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  String? template;

  SentencePatternComparePatternInfoEntity({
    this.nid,
    this.name,
    this.description,
    this.template,
  });

  SentencePatternComparePatternInfoEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    name = _parseLanguageTextList(json['name']);
    description = _parseLanguageTextList(json['description']);
    template = json['template']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['name'] = name?.map((e) => e?.toJson()).toList();
    data['description'] = description?.map((e) => e?.toJson()).toList();
    data['template'] = template;
    return data;
  }
}

/// 对照维度中的范式槽位。
class SentencePatternCompareParadigmSlotEntity {
  String? slotKey;
  bool? required;
  String? slotRole;

  SentencePatternCompareParadigmSlotEntity({
    this.slotKey,
    this.required,
    this.slotRole,
  });

  SentencePatternCompareParadigmSlotEntity.fromJson(Map<String, dynamic> json) {
    slotKey = json['slotKey']?.toString();
    required = json['required'];
    slotRole = json['slotRole']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['slotKey'] = slotKey;
    data['required'] = required;
    data['slotRole'] = slotRole;
    return data;
  }
}

/// 对照成员，可同时承载轻量 members 与展开 memberList。
class SentencePatternCompareMemberEntity {
  String? valueNid;
  SentencePatternCompareValueLabelEntity? valueLabel;
  SentencePatternCompareTeachingEntryEntity? realization;
  SentencePatternCompareTeachingEntryInfoEntity? realizationInfo;
  String? teachingExample;
  List<String?>? activeParadigmSlotKeys;
  List<SentencePatternCompareSlotMappingEntity?>? slotMappings;
  List<String?>? controlledSlotKeys;
  SentencePatternCompareContrastFocusEntity? contrastFocus;

  SentencePatternCompareMemberEntity({
    this.valueNid,
    this.valueLabel,
    this.realization,
    this.realizationInfo,
    this.teachingExample,
    this.activeParadigmSlotKeys,
    this.slotMappings,
    this.controlledSlotKeys,
    this.contrastFocus,
  });

  SentencePatternCompareMemberEntity.fromJson(Map<String, dynamic> json) {
    valueNid = json['valueNid']?.toString();
    valueLabel = _parseObject(json['valueLabel'], SentencePatternCompareValueLabelEntity.fromJson);
    realization = _parseObject(json['realization'], SentencePatternCompareTeachingEntryEntity.fromJson);
    realizationInfo = _parseObject(json['realizationInfo'], SentencePatternCompareTeachingEntryInfoEntity.fromJson);
    teachingExample = json['teachingExample']?.toString();
    activeParadigmSlotKeys = _parseStringList(json['activeParadigmSlotKeys']);
    slotMappings = _parseObjectList(json['slotMappings'], SentencePatternCompareSlotMappingEntity.fromJson);
    controlledSlotKeys = _parseStringList(json['controlledSlotKeys']);
    contrastFocus = _parseObject(json['contrastFocus'], SentencePatternCompareContrastFocusEntity.fromJson);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['valueNid'] = valueNid;
    data['valueLabel'] = valueLabel?.toJson();
    data['realization'] = realization?.toJson();
    data['realizationInfo'] = realizationInfo?.toJson();
    data['teachingExample'] = teachingExample;
    data['activeParadigmSlotKeys'] = activeParadigmSlotKeys;
    data['slotMappings'] = slotMappings?.map((e) => e?.toJson()).toList();
    data['controlledSlotKeys'] = controlledSlotKeys;
    data['contrastFocus'] = contrastFocus?.toJson();
    return data;
  }
}

class SentencePatternCompareValueLabelEntity {
  String? nid;
  List<LanguageText?>? name;
  List<LanguageText?>? description;

  SentencePatternCompareValueLabelEntity({
    this.nid,
    this.name,
    this.description,
  });

  SentencePatternCompareValueLabelEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    name = _parseLanguageTextList(json['name']);
    description = _parseLanguageTextList(json['description']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['name'] = name?.map((e) => e?.toJson()).toList();
    data['description'] = description?.map((e) => e?.toJson()).toList();
    return data;
  }
}

class SentencePatternCompareSlotMappingEntity {
  String? paradigmSlotKey;
  String? patternSlotKey;

  SentencePatternCompareSlotMappingEntity({
    this.paradigmSlotKey,
    this.patternSlotKey,
  });

  SentencePatternCompareSlotMappingEntity.fromJson(Map<String, dynamic> json) {
    paradigmSlotKey = json['paradigmSlotKey']?.toString();
    patternSlotKey = json['patternSlotKey']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['paradigmSlotKey'] = paradigmSlotKey;
    data['patternSlotKey'] = patternSlotKey;
    return data;
  }
}

class SentencePatternCompareContrastFocusEntity {
  List<String?>? patternSlotKeys;
  List<String?>? templateLiterals;

  SentencePatternCompareContrastFocusEntity({
    this.patternSlotKeys,
    this.templateLiterals,
  });

  SentencePatternCompareContrastFocusEntity.fromJson(Map<String, dynamic> json) {
    patternSlotKeys = _parseStringList(json['patternSlotKeys']);
    templateLiterals = _parseStringList(json['templateLiterals']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['patternSlotKeys'] = patternSlotKeys;
    data['templateLiterals'] = templateLiterals;
    return data;
  }
}

/// 代表句实现集合，bindingList 中复用 SentenceBrief。
class SentencePatternCompareSentenceRealizationSetEntity {
  int? uid;
  int? order;
  String? access;
  List<SentencePatternCompareSentenceBindingEntity?>? bindings;
  List<SentencePatternCompareSentenceBindingEntity?>? bindingList;

  bool get isNormal => access == "NORMAL";

  SentencePatternCompareSentenceRealizationSetEntity({
    this.uid,
    this.order,
    this.access,
    this.bindings,
    this.bindingList,
  });

  SentencePatternCompareSentenceRealizationSetEntity.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    order = json['order']?.toInt();
    access = json['access']?.toString();
    bindings = _parseObjectList(json['bindings'], SentencePatternCompareSentenceBindingEntity.fromJson);
    bindingList = _parseObjectList(json['bindingList'], SentencePatternCompareSentenceBindingEntity.fromJson);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['order'] = order;
    data['bindings'] = bindings?.map((e) => e?.toJson()).toList();
    data['bindingList'] = bindingList?.map((e) => e?.toJson()).toList();
    return data;
  }
}

class SentencePatternCompareSentenceBindingEntity {
  String? valueNid;
  int? sentenceId;
  PatternBlueprintSentenceBriefEntity? sentenceStruct;

  SentencePatternCompareSentenceBindingEntity({
    this.valueNid,
    this.sentenceId,
    this.sentenceStruct,
  });

  SentencePatternCompareSentenceBindingEntity.fromJson(Map<String, dynamic> json) {
    valueNid = json['valueNid']?.toString();
    sentenceId = json['sentenceId']?.toInt();
    sentenceStruct = _parseObject(json['sentenceStruct'], PatternBlueprintSentenceBriefEntity.fromJson);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['valueNid'] = valueNid;
    data['sentenceId'] = sentenceId;
    data['sentenceStruct'] = sentenceStruct?.toJson();
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
