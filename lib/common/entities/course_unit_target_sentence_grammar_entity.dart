import '../enum/enum.dart';
import 'entities.dart';

/// 单元语法详情实体，对应 `course_unit_target_grammar.json` 的 `data` 节点。
class CourseUnitTargetSentenceGrammarEntity {
  int? unitId;
  List<CourseUnitTargetSentenceGrammarSentenceEntity?>? sentence;
  List<CourseUnitTargetSentenceGrammarGroupEntity?>? groups;
  CourseUnitTargetSentenceGrammarInfoEntity? grammar;

  CourseUnitTargetSentenceGrammarEntity({
    this.unitId,
    this.sentence,
    this.groups,
    this.grammar,
  });

  CourseUnitTargetSentenceGrammarEntity.fromJson(Map<String, dynamic> json) {
    unitId = json['unitId']?.toInt();
    sentence = _parseObjectList(
      json['sentence'],
      CourseUnitTargetSentenceGrammarSentenceEntity.fromJson,
    );
    groups = _parseObjectList(
      json['groups'],
      CourseUnitTargetSentenceGrammarGroupEntity.fromJson,
    );
    grammar = _parseObject(
      json['grammar'],
      CourseUnitTargetSentenceGrammarInfoEntity.fromJson,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['unitId'] = unitId;
    data['sentence'] = sentence?.map((e) => e?.toJson()).toList();
    data['groups'] = groups?.map((e) => e?.toJson()).toList();
    data['grammar'] = grammar?.toJson();
    return data;
  }
}

/// 单元目标例句轻量实体。
class CourseUnitTargetSentenceGrammarSentenceEntity {
  int? unitKnowledgeId;
  String? content;
  int? contentId;
  int? semanticId;
  String? patternNid;

  CourseUnitTargetSentenceGrammarSentenceEntity({
    this.unitKnowledgeId,
    this.content,
    this.contentId,
    this.semanticId,
    this.patternNid,
  });

  CourseUnitTargetSentenceGrammarSentenceEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    unitKnowledgeId = json['unitKnowledgeId']?.toInt();
    content = json['content']?.toString();
    contentId = json['contentId']?.toInt();
    semanticId = json['semanticId']?.toInt();
    patternNid = json['patternNid']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['unitKnowledgeId'] = unitKnowledgeId;
    data['content'] = content;
    data['contentId'] = contentId;
    data['semanticId'] = semanticId;
    data['patternNid'] = patternNid;
    return data;
  }
}

/// unified grammar struct 分组，后续页面会按 `typeEnum` 渲染不同卡片。
class CourseUnitTargetSentenceGrammarGroupEntity {
  int? uid;
  String? type;
  String? nid;
  String? assetType;
  String? assetNid;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  List<CourseUnitTargetSentenceGrammarGroupMemberEntity?>? members;
  CourseUnitTargetSentenceGrammarGroupPayloadEntity? payload;
  double? order;
  String? created;
  String? updated;

  /// 将原始 `type` 映射为统一枚举，避免页面层散落字符串判断。
  ZhenxieEnSentenceType? get typeEnum => ZhenxieEnSentenceType.fromRawValue(type);

  CourseUnitTargetSentenceGrammarGroupEntity({
    this.uid,
    this.type,
    this.nid,
    this.assetType,
    this.assetNid,
    this.name,
    this.description,
    this.members,
    this.payload,
    this.order,
    this.created,
    this.updated,
  });

  CourseUnitTargetSentenceGrammarGroupEntity.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    type = json['type']?.toString();
    nid = json['nid']?.toString();
    assetType = json['assetType']?.toString();
    assetNid = json['assetNid']?.toString();
    name = _parseLanguageTextList(json['name']);
    description = _parseLanguageTextList(json['description']);
    members = _parseObjectList(
      json['members'],
      CourseUnitTargetSentenceGrammarGroupMemberEntity.fromJson,
    );
    payload = CourseUnitTargetSentenceGrammarGroupPayloadEntity.fromJson(
      json['payload'],
      typeEnum: typeEnum,
    );
    order = json['order']?.toDouble();
    created = json['created']?.toString();
    updated = json['updated']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['type'] = type;
    data['nid'] = nid;
    data['assetType'] = assetType;
    data['assetNid'] = assetNid;
    data['name'] = name?.map((e) => e?.toJson()).toList();
    data['description'] = description?.map((e) => e?.toJson()).toList();
    data['members'] = members?.map((e) => e?.toJson()).toList();
    data['payload'] = payload?.toJson();
    data['order'] = order;
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }
}

/// “添加语法”页左侧句组成员轻量实体。
class CourseUnitTargetSentenceGrammarGroupMemberEntity {
  int? sentenceId;

  CourseUnitTargetSentenceGrammarGroupMemberEntity({
    this.sentenceId,
  });

  CourseUnitTargetSentenceGrammarGroupMemberEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    sentenceId = json['sentenceId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['sentenceId'] = sentenceId;
    return data;
  }
}

/// 分组 payload 联合实体，按 unified `type` 复用现有卡片模型。
class CourseUnitTargetSentenceGrammarGroupPayloadEntity {
  PatternBlueprintEntity? patternBlueprint;
  ManageGrammarPanoramaEntity? grammarPanorama;
  SentenceForkEntity? sentenceFork;
  SentencePairEntity? sentencePair;
  SentencePatternCompareEntity? sentencePatternCompare;

  List<PatternBlueprintSentenceRealizationSetEntity?>? sentenceRealizationSet; // 后面要替换掉的
  List<PatternBlueprintSentenceRealizationSetEntity?>? realizationSets;


  CourseUnitTargetSentenceGrammarGroupPayloadEntity({
    this.patternBlueprint,
    this.grammarPanorama,
    this.sentenceFork,
    this.sentencePair,
    this.sentencePatternCompare,
    this.sentenceRealizationSet,
    this.realizationSets,
  });

  /// 按 unified `type` 解析原始 payload，避免误把不同资产塞进错误实体。
  factory CourseUnitTargetSentenceGrammarGroupPayloadEntity.fromJson(
    dynamic json, {
    ZhenxieEnSentenceType? typeEnum,
  }) {
    if (json == null || json is! Map) {
      return CourseUnitTargetSentenceGrammarGroupPayloadEntity();
    }

    final payloadMap = Map<String, dynamic>.from(json);
    switch (typeEnum) {
      case ZhenxieEnSentenceType.EN_SENTENCE_PATTERN:
      case ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID:
        final patternBlueprint = PatternBlueprintEntity.fromJson(payloadMap);
        _hydratePatternBlueprintSentenceRealizationSet(patternBlueprint);
        return CourseUnitTargetSentenceGrammarGroupPayloadEntity(
          patternBlueprint: patternBlueprint,
          sentenceRealizationSet: _parseObjectList(
            json['sentenceRealizationSet'],
            PatternBlueprintSentenceRealizationSetEntity.fromJson,
          ),
          realizationSets: _parseObjectList(
            json['realizationSets'],
            PatternBlueprintSentenceRealizationSetEntity.fromJson,
          ),
        );
      case ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR:
        final sentencePair = SentencePairEntity.fromJson(payloadMap);
        // _hydrateSentencePairDisplayFields(sentencePair);
        return CourseUnitTargetSentenceGrammarGroupPayloadEntity(
          sentencePair: sentencePair,
          sentenceRealizationSet: _parseObjectList(
            json['sentenceRealizationSet'],
            PatternBlueprintSentenceRealizationSetEntity.fromJson,
          ),
          realizationSets: _parseObjectList(
            json['realizationSets'],
            PatternBlueprintSentenceRealizationSetEntity.fromJson,
          ),
        );
      case ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR_FORK:
        final sentenceFork = SentenceForkEntity.fromJson(payloadMap);
        // _hydrateSentenceForkDisplayFields(sentenceFork);
        return CourseUnitTargetSentenceGrammarGroupPayloadEntity(
          sentenceFork: sentenceFork,
          sentenceRealizationSet: _parseObjectList(
            json['sentenceRealizationSet'],
            PatternBlueprintSentenceRealizationSetEntity.fromJson,
          ),
          realizationSets: _parseObjectList(
            json['realizationSets'],
            PatternBlueprintSentenceRealizationSetEntity.fromJson,
          ),
        );
      case ZhenxieEnSentenceType.EN_SENTENCE_PARADIGM:
        return CourseUnitTargetSentenceGrammarGroupPayloadEntity(
          sentencePatternCompare: SentencePatternCompareEntity.fromJson(
            payloadMap,
          ),
          sentenceRealizationSet: _parseObjectList(
            json['sentenceRealizationSet'],
            PatternBlueprintSentenceRealizationSetEntity.fromJson,
          ),
          realizationSets: _parseObjectList(
            json['realizationSets'],
            PatternBlueprintSentenceRealizationSetEntity.fromJson,
          ),
        );
      case ZhenxieEnSentenceType.EN_SENTENCE_GRAMMAR_GRID:
        return CourseUnitTargetSentenceGrammarGroupPayloadEntity(
          grammarPanorama: ManageGrammarPanoramaEntity.fromJson(payloadMap),
          sentenceRealizationSet: _parseObjectList(
            json['sentenceRealizationSet'],
            PatternBlueprintSentenceRealizationSetEntity.fromJson,
          ),
          realizationSets: _parseObjectList(
            json['realizationSets'],
            PatternBlueprintSentenceRealizationSetEntity.fromJson,
          ),
        );
      case null:
        return CourseUnitTargetSentenceGrammarGroupPayloadEntity();
    }





  }

  /// 当前 payload 复用的蓝图实体。
  PatternBlueprintEntity? get patternBlueprintData => patternBlueprint;

  /// 当前 payload 复用的语法全景实体。
  ManageGrammarPanoramaEntity? get grammarPanoramaData => grammarPanorama;

  /// 当前 payload 复用的句子分叉实体。
  SentenceForkEntity? get sentenceForkData => sentenceFork;

  /// 当前 payload 复用的句子配对实体。
  SentencePairEntity? get sentencePairData => sentencePair;

  /// 当前 payload 复用的句型对照实体。
  SentencePatternCompareEntity? get sentencePatternCompareData => sentencePatternCompare;

  Map<String, dynamic>? toJson() {
    if (patternBlueprint != null) return patternBlueprint!.toJson();
    if (sentencePair != null) return sentencePair!.toJson();
    if (sentenceFork != null) return sentenceFork!.toJson();
    if (sentencePatternCompare != null) {
      return sentencePatternCompare!.toJson();
    }
    if (grammarPanorama != null) return grammarPanorama!.toJson();
    return null;
  }
}

/// 将 unified pattern payload 中的 `sentenceRealizationList` 回填为卡片可直接消费的
/// `sentenceRealizationSet` 结构，保持 `PatternBlueprintItemWidget` 的现有读法可用。
void _hydratePatternBlueprintSentenceRealizationSet(
  PatternBlueprintEntity entity,
) {
  if (entity.sentenceRealizationSet?.isNotEmpty == true) return;

  final Map<int, List<PatternBlueprintSentenceBriefEntity?>> groupedMap = {};

  final List<PatternBlueprintSentenceRealizationSetEntity?> sentenceRealizationSet = groupedMap.entries.map((entry) {
    final List<PatternBlueprintSentenceBriefEntity?> memberList = List<PatternBlueprintSentenceBriefEntity?>.from(entry.value);
    memberList.sort((a, b) => (a?.order ?? 0).compareTo(b?.order ?? 0));
    return PatternBlueprintSentenceRealizationSetEntity(
      uid: entry.key > 0 ? entry.key : null,
      assetNid: entity.nid,
      memberList: memberList,
      access: memberList
          .firstWhere(
            (item) => item?.access?.isNotEmpty == true,
            orElse: () => null,
          )
          ?.access,
    );
  }).toList();

  sentenceRealizationSet.sort((a, b) {
    final int aId = a?.uid ?? 0;
    final int bId = b?.uid ?? 0;
    return aId.compareTo(bId);
  });
  entity.sentenceRealizationSet = sentenceRealizationSet;
}

/// 单元语法教学目标信息，聚合概要与 point 列表。
class CourseUnitTargetSentenceGrammarInfoEntity {
  int? outlineId;
  String? summary;
  List<CourseUnitTargetSentenceGrammarPointEntity?>? points;

  CourseUnitTargetSentenceGrammarInfoEntity({
    this.outlineId,
    this.summary,
    this.points,
  });

  CourseUnitTargetSentenceGrammarInfoEntity.fromJson(Map<String, dynamic> json) {
    outlineId = json['outlineId']?.toInt();
    summary = json['summary']?.toString();
    points = _parseObjectList(
      json['points'],
      CourseUnitTargetSentenceGrammarPointEntity.fromJson,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['outlineId'] = outlineId;
    data['summary'] = summary;
    data['points'] = points?.map((e) => e?.toJson()).toList();
    return data;
  }
}

/// 教学 point，描述单元内某一个语法目标分组。
class CourseUnitTargetSentenceGrammarPointEntity {
  int? pointOrder;
  String? title;
  String? description;
  String? objective;
  List<CourseUnitTargetSentenceGrammarTargetEntity?>? targets;

  CourseUnitTargetSentenceGrammarPointEntity({
    this.pointOrder,
    this.title,
    this.description,
    this.objective,
    this.targets,
  });

  CourseUnitTargetSentenceGrammarPointEntity.fromJson(Map<String, dynamic> json) {
    pointOrder = json['pointOrder']?.toInt();
    title = json['title']?.toString();
    description = json['description']?.toString();
    objective = json['objective']?.toString();
    targets = _parseObjectList(
      json['targets'],
      CourseUnitTargetSentenceGrammarTargetEntity.fromJson,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['pointOrder'] = pointOrder;
    data['title'] = title;
    data['description'] = description;
    data['objective'] = objective;
    data['targets'] = targets?.map((e) => e?.toJson()).toList();
    return data;
  }
}

/// 教学目标轻量元数据，不承载复杂 payload 本体。
class CourseUnitTargetSentenceGrammarTargetEntity {
  int? uid;
  int? order;
  String? status;
  String? statusLabel;
  String? assetKind;
  String? assetLabel;
  String? assetNid;
  String? title;
  int? setCount;

  CourseUnitTargetSentenceGrammarTargetEntity({
    this.uid,
    this.order,
    this.status,
    this.statusLabel,
    this.assetKind,
    this.assetLabel,
    this.assetNid,
    this.title,
    this.setCount,
  });

  CourseUnitTargetSentenceGrammarTargetEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    uid = json['uid']?.toInt();
    order = json['order']?.toInt();
    status = json['status']?.toString();
    statusLabel = json['statusLabel']?.toString();
    assetKind = json['assetKind']?.toString();
    assetLabel = json['assetLabel']?.toString();
    assetNid = json['assetNid']?.toString();
    title = json['title']?.toString();
    setCount = json['setCount']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['order'] = order;
    data['status'] = status;
    data['statusLabel'] = statusLabel;
    data['assetKind'] = assetKind;
    data['assetLabel'] = assetLabel;
    data['assetNid'] = assetNid;
    data['title'] = title;
    data['setCount'] = setCount;
    return data;
  }
}

/// 解析单个对象并转换为指定实体。
T? _parseObject<T>(
  dynamic value,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (value == null || value is! Map) return null;
  return fromJson(Map<String, dynamic>.from(value));
}

/// 解析对象列表并转换为指定实体列表。
List<T?>? _parseObjectList<T>(
  dynamic value,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (value is! List) return null;
  return value.map((item) {
    if (item == null || item is! Map) return null;
    return fromJson(Map<String, dynamic>.from(item));
  }).toList();
}

/// 解析多语言文案列表。
List<LanguageText?>? _parseLanguageTextList(dynamic value) {
  if (value is! List) return null;
  return value.map((item) {
    if (item == null || item is! Map) return null;
    return LanguageText.fromJson(Map<String, dynamic>.from(item));
  }).toList();
}
