import '../../app/modules/management/enums/enums.dart';
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
  List<SentencePairSentenceRealizationEntity?>? sentenceRealizations;
  String? created;
  String? updated;

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
    this.sentenceRealizations,
    this.created,
    this.updated,
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
    sentenceRealizations = _parseObjectList(json['sentenceRealizations'], SentencePairSentenceRealizationEntity.fromJson);
    created = json['created']?.toString();
    updated = json['updated']?.toString();
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
    data['sentenceRealizations'] = sentenceRealizations?.map((v) => v?.toJson()).toList();
    data['created'] = created;
    data['updated'] = updated;
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
  int? sentenceId;
  int? order;

  SentencePairSentenceRealizationEntity({
    this.sentenceId,
    this.order,
  });

  SentencePairSentenceRealizationEntity.fromJson(Map<String, dynamic> json) {
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
