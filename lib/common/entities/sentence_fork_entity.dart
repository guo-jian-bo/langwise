import '../../app/modules/management/enums/enums.dart';
import '../enum/enum.dart';
import 'card_public_entity.dart';
import 'zhenxie_realization_sets_entity.dart';

/// 句子分叉实体，对齐 manage_sentence_fork_item_widget.json 结构。
class SentenceForkEntity {
  String? nid;
  String? pairTypeNid;
  SentenceForkNamedInfoEntity? pairType;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  double? order;
  String? kind;
  SentenceForkRealizationInfoEntity? sharedFrom;
  String? sharedToPatternNid;
  SentenceForkPatternInfoEntity? sharedToPattern;
  String? contrastDimensionNid;
  SentenceForkNamedInfoEntity? contrastDimension;
  String? soloPairPractice;
  List<SentenceForkMemberEntity?>? members;
  SentenceForkBoardExampleEntity? boardExample;
  List<LanguageText?>? usage;
  List<ZhenxieRealizationSetsEntity?>? realizationSets;
  bool? system;
  bool? enabled;
  String? created;
  String? updated;

  PairRacticeKindEnum? get kindEnum => PairRacticeKindEnum.fromValue(kind);

  SoloPairPracticeEnum? get soloPairPracticeEnum => SoloPairPracticeEnum.fromValue(soloPairPractice);

  SentenceForkEntity({
    this.nid,
    this.pairTypeNid,
    this.pairType,
    this.name,
    this.description,
    this.order,
    this.kind,
    this.sharedFrom,
    this.sharedToPatternNid,
    this.sharedToPattern,
    this.contrastDimensionNid,
    this.contrastDimension,
    this.soloPairPractice,
    this.members,
    this.boardExample,
    this.usage,
    this.realizationSets,
    this.system,
    this.enabled,
    this.created,
    this.updated,
  });

  SentenceForkEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    pairTypeNid = json['pairTypeNid']?.toString();
    pairType = _parseObject(json['pairType'], SentenceForkNamedInfoEntity.fromJson);
    name = _parseLanguageTextList(json['name']);
    description = _parseLanguageTextList(json['description']);
    order = _parseDouble(json['order']);
    kind = json['kind']?.toString();
    sharedFrom = _parseObject(json['sharedFrom'], SentenceForkRealizationInfoEntity.fromJson);
    sharedToPatternNid = json['sharedToPatternNid']?.toString();
    sharedToPattern = _parseObject(json['sharedToPattern'], SentenceForkPatternInfoEntity.fromJson);
    contrastDimensionNid = json['contrastDimensionNid']?.toString();
    contrastDimension = _parseObject(json['contrastDimension'], SentenceForkNamedInfoEntity.fromJson);
    soloPairPractice = json['soloPairPractice']?.toString();
    members = _parseObjectList(json['members'], SentenceForkMemberEntity.fromJson);
    boardExample = _parseObject(json['boardExample'], SentenceForkBoardExampleEntity.fromJson);
    usage = _parseLanguageTextList(json['usage']);
    realizationSets = _parseObjectList(
      json['realizationSets'],
      ZhenxieRealizationSetsEntity.fromJson,
    );
    system = json['system'];
    enabled = json['enabled'];
    created = json['created']?.toString();
    updated = json['updated']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['pairTypeNid'] = pairTypeNid;
    data['pairType'] = pairType?.toJson();
    data['name'] = name?.map((v) => v?.toJson()).toList();
    data['description'] = description?.map((v) => v?.toJson()).toList();
    data['order'] = order;
    data['kind'] = kind;
    data['sharedFrom'] = sharedFrom?.toJson();
    data['sharedToPatternNid'] = sharedToPatternNid;
    data['sharedToPattern'] = sharedToPattern?.toJson();
    data['contrastDimensionNid'] = contrastDimensionNid;
    data['contrastDimension'] = contrastDimension?.toJson();
    data['soloPairPractice'] = soloPairPractice;
    data['members'] = members?.map((v) => v?.toJson()).toList();
    data['boardExample'] = boardExample?.toJson();
    data['usage'] = usage?.map((v) => v?.toJson()).toList();
    data['realizationSets'] = realizationSets?.map((v) => v?.toJson()).toList();
    data['system'] = system;
    data['enabled'] = enabled;
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }
}

/// 句子分叉里的通用命名信息。
class SentenceForkNamedInfoEntity {
  String? nid;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  String? categoryNid;
  List<String?>? usageKinds;
  List<String?>? surfaceFromSlotKeys;
  String? color;

  SentenceForkNamedInfoEntity({
    this.nid,
    this.name,
    this.description,
    this.categoryNid,
    this.usageKinds,
    this.surfaceFromSlotKeys,
    this.color,
  });

  SentenceForkNamedInfoEntity.fromJson(Map<String, dynamic> json) {
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

/// 句子分叉里的轻量句型信息。
class SentenceForkPatternInfoEntity {
  String? nid;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  String? template;

  SentenceForkPatternInfoEntity({
    this.nid,
    this.name,
    this.description,
    this.template,
  });

  SentenceForkPatternInfoEntity.fromJson(Map<String, dynamic> json) {
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

/// 句子分叉里的 realization 信息。
class SentenceForkRealizationInfoEntity {
  String? patternNid;
  SentenceForkPatternInfoEntity? pattern;
  List<String?>? grammarFeatureNids;
  List<SentenceForkNamedInfoEntity?>? grammarFeatures;

  SentenceForkRealizationInfoEntity({
    this.patternNid,
    this.pattern,
    this.grammarFeatureNids,
    this.grammarFeatures,
  });

  SentenceForkRealizationInfoEntity.fromJson(Map<String, dynamic> json) {
    patternNid = json['patternNid']?.toString();
    pattern = _parseObject(json['pattern'], SentenceForkPatternInfoEntity.fromJson);
    grammarFeatureNids = _parseStringList(json['grammarFeatureNids']);
    grammarFeatures = _parseObjectList(json['grammarFeatures'], SentenceForkNamedInfoEntity.fromJson);
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

/// fork 内嵌的配对实体。
class SentenceForkPairEntity {
  String? nid;
  double? order;
  String? pairTypeNid;
  SentenceForkNamedInfoEntity? pairType;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  String? teachingExampleFrom;
  String? teachingExampleTo;
  String? practiceMode;
  String? preferredPractice;
  bool? system;
  bool? enabled;
  SentenceForkRealizationInfoEntity? fromRealization;
  SentenceForkRealizationInfoEntity? toRealization;
  List<String?>? interactionModes;
  String? relationDirection;
  String? orderConstraint;
  List<SentenceForkSemanticAnchorMappingEntity?>? semanticAnchorMappings;
  List<ZhenxieRealizationSetsEntity?>? realizationSets;
  String? created;
  String? updated;

  SentenceForkPairEntity({
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
    this.realizationSets,
    this.created,
    this.updated,
  });

  SentenceForkPairEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    order = _parseDouble(json['order']);
    pairTypeNid = json['pairTypeNid']?.toString();
    pairType = _parseObject(json['pairType'], SentenceForkNamedInfoEntity.fromJson);
    name = _parseLanguageTextList(json['name']);
    description = _parseLanguageTextList(json['description']);
    teachingExampleFrom = json['teachingExampleFrom']?.toString();
    teachingExampleTo = json['teachingExampleTo']?.toString();
    practiceMode = json['practiceMode']?.toString();
    preferredPractice = json['preferredPractice']?.toString();
    system = json['system'];
    enabled = json['enabled'];
    fromRealization = _parseObject(json['fromRealization'], SentenceForkRealizationInfoEntity.fromJson);
    toRealization = _parseObject(json['toRealization'], SentenceForkRealizationInfoEntity.fromJson);
    interactionModes = _parseStringList(json['interactionModes']);
    relationDirection = json['relationDirection']?.toString();
    orderConstraint = json['orderConstraint']?.toString();
    semanticAnchorMappings = _parseObjectList(json['semanticAnchorMappings'], SentenceForkSemanticAnchorMappingEntity.fromJson);
    realizationSets = _parseObjectList(
      json['realizationSets'],
      ZhenxieRealizationSetsEntity.fromJson,
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
    data['realizationSets'] = realizationSets?.map((v) => v?.toJson()).toList();
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }
}

/// fork 内嵌配对里的语义锚点映射。
class SentenceForkSemanticAnchorMappingEntity {
  String? fromPatternSlotKey;
  SentenceForkNamedInfoEntity? fromPatternSlot;
  String? toPatternSlotKey;
  SentenceForkNamedInfoEntity? toPatternSlot;

  SentenceForkSemanticAnchorMappingEntity({
    this.fromPatternSlotKey,
    this.fromPatternSlot,
    this.toPatternSlotKey,
    this.toPatternSlot,
  });

  SentenceForkSemanticAnchorMappingEntity.fromJson(Map<String, dynamic> json) {
    fromPatternSlotKey = json['fromPatternSlotKey']?.toString();
    fromPatternSlot = _parseObject(json['fromPatternSlot'], SentenceForkNamedInfoEntity.fromJson);
    toPatternSlotKey = json['toPatternSlotKey']?.toString();
    toPatternSlot = _parseObject(json['toPatternSlot'], SentenceForkNamedInfoEntity.fromJson);
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

/// fork 代表句里的单个分支节点，可能是共享问句，也可能是某个答句分支。
class SentenceForkRealizationBranchEntity {
  String? role;
  String? valueNid;
  SentenceForkValueLabelEntity? valueLabel;
  String? pairNid;
  int? sentenceId;
  SentenceForkSentenceBriefEntity? sentenceStruct;
  SentenceForkPairEntity? pair;
  SentenceForkPatternInfoEntity? toPattern;

  SentenceForkRealizationBranchEntity({
    this.role,
    this.valueNid,
    this.pairNid,
    this.sentenceId,
    this.sentenceStruct,
    this.pair,
    this.toPattern,
  });

  SentenceForkRealizationBranchEntity.fromJson(Map<String, dynamic> json) {
    role = json['role']?.toString();
    valueNid = json['valueNid']?.toString();
    valueLabel = _parseObject(json['valueLabel'], SentenceForkValueLabelEntity.fromJson);
    pairNid = json['pairNid']?.toString();
    sentenceId = json['sentenceId']?.toInt();
    sentenceStruct = _parseObject(json['sentenceStruct'], SentenceForkSentenceBriefEntity.fromJson);
    pair = _parseObject(json['pair'], SentenceForkPairEntity.fromJson);
    toPattern = _parseObject(json['toPattern'], SentenceForkPatternInfoEntity.fromJson);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['role'] = role;
    data['valueNid'] = valueNid;
    data['valueLabel'] = valueLabel?.toJson();
    data['pairNid'] = pairNid;
    data['sentenceId'] = sentenceId;
    data['sentenceStruct'] = sentenceStruct?.toJson();
    data['pair'] = pair?.toJson();
    data['toPattern'] = toPattern?.toJson();
    return data;
  }
}

/// fork 代表句中挂载的句子摘要。
class SentenceForkSentenceBriefEntity {
  int? sentenceId;
  String? content;
  String? definition;
  String? patternNid;
  String? patternTemplate;
  List<LanguageText?>? patternName;
  List<LanguageText?>? patternDescription;
  String? blueprintScope;
  List<LanguageText?>? blueprintScopeName;
  List<SentenceForkSentenceBriefSegmentEntity?>? segmentList;
  int? order;
  String? access;

  /// 是否上架
  bool get isNormal => access == AccessEnum.NORMAL.value;

  SentenceForkSentenceBriefEntity({
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
    this.order,
    this.access,
  });

  SentenceForkSentenceBriefEntity.fromJson(Map<String, dynamic> json) {
    sentenceId = json['sentenceId']?.toInt();
    content = json['content']?.toString();
    definition = json['definition']?.toString();
    patternNid = json['patternNid']?.toString();
    patternTemplate = json['patternTemplate']?.toString();
    patternName = _parseLanguageTextList(json['patternName']);
    patternDescription = _parseLanguageTextList(json['patternDescription']);
    blueprintScope = json['blueprintScope']?.toString();
    blueprintScopeName = _parseLanguageTextList(json['blueprintScopeName']);
    segmentList = _parseObjectList(json['segmentList'], SentenceForkSentenceBriefSegmentEntity.fromJson);
    order = json['order']?.toInt();
    access = json['access']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['sentenceId'] = sentenceId;
    data['content'] = content;
    data['definition'] = definition;
    data['patternNid'] = patternNid;
    data['patternTemplate'] = patternTemplate;
    data['patternName'] = patternName?.map((v) => v?.toJson()).toList();
    data['patternDescription'] = patternDescription?.map((v) => v?.toJson()).toList();
    data['blueprintScope'] = blueprintScope;
    data['blueprintScopeName'] = blueprintScopeName?.map((v) => v?.toJson()).toList();
    data['segmentList'] = segmentList?.map((v) => v?.toJson()).toList();
    data['order'] = order;
    data['access'] = access;
    return data;
  }
}

/// fork 代表句中已展开的单个 segment。
class SentenceForkSentenceBriefSegmentEntity {
  String? slotKey;
  SentenceForkNamedInfoEntity? slot;
  bool? required;
  bool? grammarControlling;
  int? growthPriority;
  List<String?>? dependsOn;
  String? text;
  String? renderSlotKey;
  String? sourceSlotKey;
  SentenceForkNamedInfoEntity? sourceSlot;
  int? slotUid;
  List<int?>? semanticIds;
  bool? literal;
  bool? hasChildStruct;

  SentenceForkSentenceBriefSegmentEntity({
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
  });

  SentenceForkSentenceBriefSegmentEntity.fromJson(Map<String, dynamic> json) {
    slotKey = json['slotKey']?.toString();
    slot = _parseObject(json['slot'], SentenceForkNamedInfoEntity.fromJson);
    required = json['required'];
    grammarControlling = json['grammarControlling'];
    growthPriority = json['growthPriority']?.toInt();
    dependsOn = _parseStringList(json['dependsOn']);
    text = json['text']?.toString();
    renderSlotKey = json['renderSlotKey']?.toString();
    sourceSlotKey = json['sourceSlotKey']?.toString();
    sourceSlot = _parseObject(json['sourceSlot'], SentenceForkNamedInfoEntity.fromJson);
    slotUid = json['slotUid']?.toInt();
    semanticIds = _parseIntList(json['semanticIds']);
    literal = json['literal'];
    hasChildStruct = json['hasChildStruct'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['slotKey'] = slotKey;
    data['slot'] = slot?.toJson();
    data['required'] = required;
    data['grammarControlling'] = grammarControlling;
    data['growthPriority'] = growthPriority;
    data['dependsOn'] = dependsOn;
    data['text'] = text;
    data['renderSlotKey'] = renderSlotKey;
    data['sourceSlotKey'] = sourceSlotKey;
    data['sourceSlot'] = sourceSlot?.toJson();
    data['slotUid'] = slotUid;
    data['semanticIds'] = semanticIds;
    data['literal'] = literal;
    data['hasChildStruct'] = hasChildStruct;
    return data;
  }
}

/// fork 成员，承载具体 pair 与该分支示例。
class SentenceForkMemberEntity {
  String? pairNid;
  SentenceForkPairEntity? pair;
  String? valueNid;
  SentenceForkValueLabelEntity? valueLabel;
  String? teachingExampleFrom;
  String? teachingExampleTo;

  SentenceForkMemberEntity({
    this.pairNid,
    this.pair,
    this.valueNid,
    this.valueLabel,
    this.teachingExampleFrom,
    this.teachingExampleTo,
  });

  SentenceForkMemberEntity.fromJson(Map<String, dynamic> json) {
    pairNid = json['pairNid']?.toString();
    pair = _parseObject(json['pair'], SentenceForkPairEntity.fromJson);
    valueNid = json['valueNid']?.toString();
    valueLabel = _parseObject(json['valueLabel'], SentenceForkValueLabelEntity.fromJson);
    teachingExampleFrom = json['teachingExampleFrom']?.toString();
    teachingExampleTo = json['teachingExampleTo']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['pairNid'] = pairNid;
    data['pair'] = pair?.toJson();
    data['valueNid'] = valueNid;
    data['valueLabel'] = valueLabel?.toJson();
    data['teachingExampleFrom'] = teachingExampleFrom;
    data['teachingExampleTo'] = teachingExampleTo;
    return data;
  }
}

/// fork 成员上的取值标签。
class SentenceForkValueLabelEntity {
  String? nid;
  List<LanguageText?>? name;

  SentenceForkValueLabelEntity({
    this.nid,
    this.name,
  });

  SentenceForkValueLabelEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    name = _parseLanguageTextList(json['name']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['name'] = name?.map((v) => v?.toJson()).toList();
    return data;
  }
}

/// 板书示例配置，描述 from 文案与候选匹配项。
class SentenceForkBoardExampleEntity {
  String? fromText;
  List<LanguageText?>? fromVisualHint;
  List<SentenceForkBoardExampleMatchEntity?>? matches;

  SentenceForkBoardExampleEntity({
    this.fromText,
    this.fromVisualHint,
    this.matches,
  });

  SentenceForkBoardExampleEntity.fromJson(Map<String, dynamic> json) {
    fromText = json['fromText']?.toString();
    fromVisualHint = _parseLanguageTextList(json['fromVisualHint']);
    matches = _parseObjectList(json['matches'], SentenceForkBoardExampleMatchEntity.fromJson);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['fromText'] = fromText;
    data['fromVisualHint'] = fromVisualHint?.map((v) => v?.toJson()).toList();
    data['matches'] = matches?.map((v) => v?.toJson()).toList();
    return data;
  }
}

/// 板书中的单个候选答句。
class SentenceForkBoardExampleMatchEntity {
  String? valueNid;
  String? toText;
  List<LanguageText?>? visualHint;

  SentenceForkBoardExampleMatchEntity({
    this.valueNid,
    this.toText,
    this.visualHint,
  });

  SentenceForkBoardExampleMatchEntity.fromJson(Map<String, dynamic> json) {
    valueNid = json['valueNid']?.toString();
    toText = json['toText']?.toString();
    visualHint = _parseLanguageTextList(json['visualHint']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['valueNid'] = valueNid;
    data['toText'] = toText;
    data['visualHint'] = visualHint?.map((v) => v?.toJson()).toList();
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
  return value.map((item) => item == null ? null : (item as num).toInt()).toList();
}
