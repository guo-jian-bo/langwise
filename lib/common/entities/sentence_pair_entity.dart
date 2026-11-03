import '../../app/modules/management/enums/enums.dart';
import '../enum/enum.dart';
import 'card_public_entity.dart';

/// 句子配对实体，对齐 manage_sentence_pair_item_widget.json 结构。
class SentencePairEntity {
  String? nid;
  double? order;
  String? pairTypeNid;
  SentencePairNamedInfoEntity? pairType;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  String? teachingExampleFrom;
  String? teachingExampleTo;
  String? practiceMode;
  String? preferredPractice;
  bool? system;
  bool? enabled;
  SentencePairRealizationInfoEntity? fromRealization;
  SentencePairRealizationInfoEntity? toRealization;
  List<String?>? interactionModes;
  String? relationDirection;
  String? orderConstraint;
  List<SentencePairSemanticAnchorMappingEntity?>? semanticAnchorMappings;
  List<SentencePairSentenceRealizationEntity?>? realizationSetList;
  int? realizationSetCount;
  String? created;
  String? updated;
  List<SentencePairForkEntity?>? pairForks;

  PracticeModeEnum? get practiceModeEnum => PracticeModeEnum.fromValue(practiceMode);

  PairRacticeKindEnum? get pairRacticeKindEnum => PairRacticeKindEnum.fromValue(preferredPractice);

  PairOrderConstraintEnum? get orderConstraintEnum => PairOrderConstraintEnum.fromValue(orderConstraint);

  String get relationDirectionText => relationDirection == "directed"? "有向" : "无向";

  SentencePairEntity({
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
    this.realizationSetCount,
    this.created,
    this.updated,
    this.pairForks,
  });

  SentencePairEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    order = _parseDouble(json['order']);
    pairTypeNid = json['pairTypeNid']?.toString();
    pairType = _parseObject(json['pairType'], SentencePairNamedInfoEntity.fromJson);
    name = _parseLanguageTextList(json['name']);
    description = _parseLanguageTextList(json['description']);
    teachingExampleFrom = json['teachingExampleFrom']?.toString();
    teachingExampleTo = json['teachingExampleTo']?.toString();
    practiceMode = json['practiceMode']?.toString();
    preferredPractice = json['preferredPractice']?.toString();
    system = json['system'];
    enabled = json['enabled'];
    fromRealization = _parseObject(json['fromRealization'], SentencePairRealizationInfoEntity.fromJson);
    toRealization = _parseObject(json['toRealization'], SentencePairRealizationInfoEntity.fromJson);
    interactionModes = _parseStringList(json['interactionModes']);
    relationDirection = json['relationDirection']?.toString();
    orderConstraint = json['orderConstraint']?.toString();
    semanticAnchorMappings = _parseObjectList(json['semanticAnchorMappings'], SentencePairSemanticAnchorMappingEntity.fromJson);
    realizationSetList = _parseObjectList(json['realizationSetList'], SentencePairSentenceRealizationEntity.fromJson);
    realizationSetCount = json['realizationSetCount']?.toInt();
    created = json['created']?.toString();
    updated = json['updated']?.toString();
    pairForks = _parseObjectList(json['pairForks'], SentencePairForkEntity.fromJson);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['order'] = order;
    data['pairTypeNid'] = pairTypeNid;
    data['pairType'] = pairType?.toJson();
    data['name'] = name?.map((v) => v?.toJson()).toList();
    data['description'] = description?.map((v) => v?.toJson()).toList();
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
    data['semanticAnchorMappings'] = semanticAnchorMappings?.map((v) => v?.toJson()).toList();
    data['realizationSetList'] = realizationSetList?.map((v) => v?.toJson()).toList();
    data['realizationSetCount'] = realizationSetCount;
    data['created'] = created;
    data['updated'] = updated;
    data['pairForks'] = pairForks?.map((v) => v?.toJson()).toList();
    return data;
  }
}

/// 句子配对下挂载的分叉信息。
class SentencePairForkEntity {
  String? nid;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  String? kind;
  String? kindLabel;
  String? soloPairPractice;
  String? soloPairPracticeLabel;

  PairRacticeKindEnum? get pairRacticeKindEnum => PairRacticeKindEnum.fromValue(kind);

  SentencePairForkEntity({
    this.nid,
    this.name,
    this.description,
    this.kind,
    this.kindLabel,
    this.soloPairPractice,
    this.soloPairPracticeLabel,
  });

  SentencePairForkEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    name = _parseLanguageTextList(json['name']);
    description = _parseLanguageTextList(json['description']);
    kind = json['kind']?.toString();
    kindLabel = json['kindLabel']?.toString();
    soloPairPractice = json['soloPairPractice']?.toString();
    soloPairPracticeLabel = json['soloPairPracticeLabel']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['name'] = name?.map((v) => v?.toJson()).toList();
    data['description'] = description?.map((v) => v?.toJson()).toList();
    data['kind'] = kind;
    data['kindLabel'] = kindLabel;
    data['soloPairPractice'] = soloPairPractice;
    data['soloPairPracticeLabel'] = soloPairPracticeLabel;
    return data;
  }
}

/// 语义锚点映射，描述问句槽位与答句槽位的对应关系。
class SentencePairSemanticAnchorMappingEntity {
  String? fromPatternSlotKey;
  SentencePairNamedInfoEntity? fromPatternSlot;
  String? toPatternSlotKey;
  SentencePairNamedInfoEntity? toPatternSlot;

  SentencePairSemanticAnchorMappingEntity({
    this.fromPatternSlotKey,
    this.fromPatternSlot,
    this.toPatternSlotKey,
    this.toPatternSlot,
  });

  SentencePairSemanticAnchorMappingEntity.fromJson(Map<String, dynamic> json) {
    fromPatternSlotKey = json['fromPatternSlotKey']?.toString();
    fromPatternSlot = _parseObject(json['fromPatternSlot'], SentencePairNamedInfoEntity.fromJson);
    toPatternSlotKey = json['toPatternSlotKey']?.toString();
    toPatternSlot = _parseObject(json['toPatternSlot'], SentencePairNamedInfoEntity.fromJson);
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

/// 句子配对里的通用命名信息。
class SentencePairNamedInfoEntity {
  String? nid;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  String? categoryNid;
  List<String?>? usageKinds;
  List<String?>? surfaceFromSlotKeys;
  String? color;

  SentencePairNamedInfoEntity({
    this.nid,
    this.name,
    this.description,
    this.categoryNid,
    this.usageKinds,
    this.surfaceFromSlotKeys,
    this.color,
  });

  SentencePairNamedInfoEntity.fromJson(Map<String, dynamic> json) {
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
    data['name'] = name?.map((v) => v?.toJson()).toList();
    data['description'] = description?.map((v) => v?.toJson()).toList();
    data['categoryNid'] = categoryNid;
    data['usageKinds'] = usageKinds;
    data['surfaceFromSlotKeys'] = surfaceFromSlotKeys;
    data['color'] = color;
    return data;
  }
}

/// 句子配对里的轻量句型信息。
class SentencePairPatternInfoEntity {
  String? nid;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  String? template;

  SentencePairPatternInfoEntity({
    this.nid,
    this.name,
    this.description,
    this.template,
  });

  SentencePairPatternInfoEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    name = _parseLanguageTextList(json['name']);
    description = _parseLanguageTextList(json['description']);
    template = json['template']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['name'] = name?.map((v) => v?.toJson()).toList();
    data['description'] = description?.map((v) => v?.toJson()).toList();
    data['template'] = template;
    return data;
  }
}

/// 句子配对里的 realization 信息。
class SentencePairRealizationInfoEntity {
  String? patternNid;
  SentencePairPatternInfoEntity? pattern;
  List<String?>? grammarFeatureNids;
  List<SentencePairNamedInfoEntity?>? grammarFeatures;

  SentencePairRealizationInfoEntity({
    this.patternNid,
    this.pattern,
    this.grammarFeatureNids,
    this.grammarFeatures,
  });

  SentencePairRealizationInfoEntity.fromJson(Map<String, dynamic> json) {
    patternNid = json['patternNid']?.toString();
    pattern = _parseObject(json['pattern'], SentencePairPatternInfoEntity.fromJson);
    grammarFeatureNids = _parseStringList(json['grammarFeatureNids']);
    grammarFeatures = _parseObjectList(json['grammarFeatures'], SentencePairNamedInfoEntity.fromJson);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['patternNid'] = patternNid;
    data['pattern'] = pattern?.toJson();
    data['grammarFeatureNids'] = grammarFeatureNids;
    data['grammarFeatures'] = grammarFeatures?.map((v) => v?.toJson()).toList();
    return data;
  }
}

/// 句子配对里的句子实现。
class SentencePairSentenceRealizationEntity {
  int? uid;
  String? contentType;
  int? realizationSetId;
  int? fromSentenceId;
  SentencePairSentenceBriefEntity? fromSentenceStruct;
  int? toSentenceId;
  SentencePairSentenceBriefEntity? toSentenceStruct;
  int? order;
  String? access;

  bool get isNormal => access == AccessEnum.NORMAL.value;

  SentencePairSentenceRealizationEntity({
    this.uid,
    this.contentType,
    this.realizationSetId,
    this.fromSentenceId,
    this.fromSentenceStruct,
    this.toSentenceId,
    this.toSentenceStruct,
    this.order,
    this.access,
  });

  SentencePairSentenceRealizationEntity.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    contentType = json['contentType']?.toString();
    realizationSetId = json['realizationSetId']?.toInt();
    fromSentenceId = json['fromSentenceId']?.toInt();
    fromSentenceStruct = _parseObject(json['fromSentenceStruct'], SentencePairSentenceBriefEntity.fromJson);
    toSentenceId = json['toSentenceId']?.toInt();
    toSentenceStruct = _parseObject(json['toSentenceStruct'], SentencePairSentenceBriefEntity.fromJson);
    order = json['order']?.toInt();
    access = json['access']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['contentType'] = contentType;
    data['realizationSetId'] = realizationSetId;
    data['fromSentenceId'] = fromSentenceId;
    data['fromSentenceStruct'] = fromSentenceStruct?.toJson();
    data['toSentenceId'] = toSentenceId;
    data['toSentenceStruct'] = toSentenceStruct?.toJson();
    data['order'] = order;
    data['access'] = access;
    return data;
  }
}

/// 句对 realization 中挂载的句子结构摘要。
class SentencePairSentenceBriefEntity {
  int? sentenceId;
  int? semanticId;
  String? content;
  String? definition;
  String? contentType;
  String? patternNid;
  List<LanguageText?>? patternName;
  List<LanguageText?>? patternDescription;
  String? patternTemplate;
  String? blueprintScope;
  List<SentencePairSentenceBriefSegmentEntity?>? segmentList;
  int? order;
  String? access;

  bool get isNormal => access == AccessEnum.NORMAL.value;

  SentencePairSentenceBriefEntity({
    this.sentenceId,
    this.semanticId,
    this.content,
    this.definition,
    this.contentType,
    this.patternNid,
    this.patternName,
    this.patternDescription,
    this.patternTemplate,
    this.blueprintScope,
    this.segmentList,
    this.order,
    this.access,
  });

  SentencePairSentenceBriefEntity.fromJson(Map<String, dynamic> json) {
    sentenceId = json['sentenceId']?.toInt();
    semanticId = json['semanticId']?.toInt();
    content = json['content']?.toString();
    definition = json['definition']?.toString();
    contentType = json['contentType']?.toString();
    patternNid = json['patternNid']?.toString();
    patternName = _parseLanguageTextList(json['patternName']);
    patternDescription = _parseLanguageTextList(json['patternDescription']);
    patternTemplate = json['patternTemplate']?.toString();
    blueprintScope = json['blueprintScope']?.toString();
    segmentList = _parseObjectList(json['segmentList'], SentencePairSentenceBriefSegmentEntity.fromJson);
    order = json['order']?.toInt();
    access = json['access']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['sentenceId'] = sentenceId;
    data['semanticId'] = semanticId;
    data['content'] = content;
    data['definition'] = definition;
    data['contentType'] = contentType;
    data['patternNid'] = patternNid;
    data['patternName'] = patternName?.map((v) => v?.toJson()).toList();
    data['patternDescription'] = patternDescription?.map((v) => v?.toJson()).toList();
    data['patternTemplate'] = patternTemplate;
    data['blueprintScope'] = blueprintScope;
    data['segmentList'] = segmentList?.map((v) => v?.toJson()).toList();
    data['order'] = order;
    data['access'] = access;
    return data;
  }
}

/// 句子结构摘要中的已展开 segment。
class SentencePairSentenceBriefSegmentEntity {
  String? slotKey;
  SentencePairNamedInfoEntity? slot;
  bool? required;
  bool? grammarControlling;
  int? growthPriority;
  List<String?>? dependsOn;
  List<SentencePairNamedInfoEntity?>? dependsOnSlots;
  String? text;
  String? renderSlotKey;
  String? sourceSlotKey;
  SentencePairNamedInfoEntity? sourceSlot;
  int? slotUid;
  List<int?>? semanticIds;
  bool? literal;
  bool? hasChildStruct;
  SentencePairSentenceBriefSegmentChildStructEntity? childStruct;

  SentencePairSentenceBriefSegmentEntity({
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

  SentencePairSentenceBriefSegmentEntity.fromJson(Map<String, dynamic> json) {
    slotKey = json['slotKey']?.toString();
    slot = _parseObject(json['slot'], SentencePairNamedInfoEntity.fromJson);
    required = json['required'];
    grammarControlling = json['grammarControlling'];
    growthPriority = json['growthPriority']?.toInt();
    dependsOn = _parseStringList(json['dependsOn']);
    dependsOnSlots = _parseObjectList(json['dependsOnSlots'], SentencePairNamedInfoEntity.fromJson);
    text = json['text']?.toString();
    renderSlotKey = json['renderSlotKey']?.toString();
    sourceSlotKey = json['sourceSlotKey']?.toString();
    sourceSlot = _parseObject(json['sourceSlot'], SentencePairNamedInfoEntity.fromJson);
    slotUid = json['slotUid']?.toInt();
    semanticIds = _parseIntList(json['semanticIds']);
    literal = json['literal'];
    hasChildStruct = json['hasChildStruct'];
    childStruct = _parseObject(json['childStruct'], SentencePairSentenceBriefSegmentChildStructEntity.fromJson);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['slotKey'] = slotKey;
    data['slot'] = slot?.toJson();
    data['required'] = required;
    data['grammarControlling'] = grammarControlling;
    data['growthPriority'] = growthPriority;
    data['dependsOn'] = dependsOn;
    data['dependsOnSlots'] = dependsOnSlots?.map((v) => v?.toJson()).toList();
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

/// segment 下挂载的子句结构，内部 segmentList 继续复用当前定义。
class SentencePairSentenceBriefSegmentChildStructEntity {
  String? structType;
  int? rootClauseId;
  List<int?>? clauseIdList;
  String? content;
  String? patternNid;
  String? patternTemplate;
  String? clauseType;
  List<LanguageText?>? patternName;
  List<LanguageText?>? patternDescription;
  List<SentencePairSentenceBriefSegmentEntity?>? segmentList;

  SentencePairSentenceBriefSegmentChildStructEntity({
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

  SentencePairSentenceBriefSegmentChildStructEntity.fromJson(Map<String, dynamic> json) {
    structType = json['structType']?.toString();
    rootClauseId = json['rootClauseId']?.toInt();
    clauseIdList = _parseIntList(json['clauseIdList']);
    content = json['content']?.toString();
    patternNid = json['patternNid']?.toString();
    patternTemplate = json['patternTemplate']?.toString();
    clauseType = json['clauseType']?.toString();
    patternName = _parseLanguageTextList(json['patternName']);
    patternDescription = _parseLanguageTextList(json['patternDescription']);
    segmentList = _parseObjectList(json['segmentList'], SentencePairSentenceBriefSegmentEntity.fromJson);
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
    data['patternName'] = patternName?.map((v) => v?.toJson()).toList();
    data['patternDescription'] = patternDescription?.map((v) => v?.toJson()).toList();
    data['segmentList'] = segmentList?.map((v) => v?.toJson()).toList();
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
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

List<int?>? _parseIntList(dynamic value) {
  if (value is! List) return null;
  return value.map((item) => item == null ? null : int.tryParse(item.toString())).toList();
}
