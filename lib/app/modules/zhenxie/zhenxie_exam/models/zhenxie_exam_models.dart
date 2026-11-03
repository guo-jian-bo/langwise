/// 考点页静态快照模型 + 首页 2×2 的视图数据。
/// 字段口径对齐 ui_ux/src/pages/zhenxie/user/exam/catalog.ts 与 facets.ts。
library;

import 'package:langwise/common/entities/card_public_entity.dart';
import 'package:langwise/common/entities/language_config_color_entity.dart';

/// 考段：与 React EXAM_STAGES 同序同文案。
class ZhenxieExamStage {
  final String code;
  final String label;
  final String gate;

  const ZhenxieExamStage._(this.code, this.label, this.gate);

  static const ZhenxieExamStage xiaoshengchu = ZhenxieExamStage._('xiaoshengchu', '小升初', 'A1 · Movers');
  static const ZhenxieExamStage zhongkao = ZhenxieExamStage._('zhongkao', '中考', 'A2 · KET');
  static const ZhenxieExamStage gaokao = ZhenxieExamStage._('gaokao', '高考', 'B1 · PET');

  static const List<ZhenxieExamStage> values = <ZhenxieExamStage>[
    xiaoshengchu,
    zhongkao,
    gaokao,
  ];

  static bool isValid(String? code) {
    return values.any((item) => item.code == code);
  }

  static String findLabel(String? code) {
    for (final ZhenxieExamStage item in values) {
      if (item.code == code) return item.label;
    }
    return '';
  }

  static String findGate(String? code) {
    for (final ZhenxieExamStage item in values) {
      if (item.code == code) return item.gate;
    }
    return '';
  }
}

/// 一道书面表达真题（en_composition_exam_tasks 一条）。
class ZhenxieExamTaskModel {
  final int uid;
  final String milestone;
  final int? year;
  final List<String> regionNids;
  final String regionLabel;
  final String? paperName;
  final String familyNid;
  final String? stageNid;
  final String coverage;
  final String topic;
  final List<String> requiredPoints;
  final String example;
  final String fullText;

  /// topics 叶子 nid；[0] 是主主题，其余 ≤2 个副主题。
  final List<String> topicNids;

  /// 写作目标 nid；[0] 主能力，其余 ≤2 副。
  final List<String> goalNids;

  const ZhenxieExamTaskModel({
    required this.uid,
    required this.milestone,
    required this.year,
    required this.regionNids,
    required this.regionLabel,
    required this.paperName,
    required this.familyNid,
    required this.stageNid,
    required this.coverage,
    required this.topic,
    required this.requiredPoints,
    required this.example,
    required this.fullText,
    required this.topicNids,
    required this.goalNids,
  });

  factory ZhenxieExamTaskModel.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamTaskModel(
      uid: (json['uid'] as num?)?.toInt() ?? 0,
      milestone: json['milestone']?.toString() ?? '',
      year: (json['year'] as num?)?.toInt(),
      regionNids: _stringList(json['regionNids']),
      regionLabel: json['regionLabel']?.toString() ?? '',
      paperName: json['paperName']?.toString(),
      familyNid: json['familyNid']?.toString() ?? '',
      stageNid: json['stageNid']?.toString(),
      coverage: json['coverage']?.toString() ?? 'none',
      topic: json['topic']?.toString() ?? '',
      requiredPoints: _stringList(json['requiredPoints']),
      example: json['example']?.toString() ?? '',
      fullText: json['fullText']?.toString() ?? '',
      topicNids: _stringList(json['topicNids']),
      goalNids: _stringList(json['goalNids']),
    );
  }
}

/// 真题列表页查询参数；键名与 React exam/facets.ts 一致。
class ZhenxieExamTaskQuery {
  final String? regions;
  final String? genre;
  final String? family;
  final String? domain;
  final String? topic;
  final String? goal;
  final String? stageNid;
  final String? examStage;
  final String? year;
  final String? q;
  final String? sort;

  const ZhenxieExamTaskQuery({
    this.regions,
    this.genre,
    this.family,
    this.domain,
    this.topic,
    this.goal,
    this.stageNid,
    this.examStage,
    this.year,
    this.q,
    this.sort,
  });

  factory ZhenxieExamTaskQuery.fromParameters(Map<String, String?> parameters) {
    return ZhenxieExamTaskQuery(
      regions: parameters['regions'],
      genre: parameters['genre'],
      family: parameters['family'],
      domain: parameters['domain'],
      topic: parameters['topic'],
      goal: parameters['goal'],
      stageNid: parameters['stageNid'],
      examStage: parameters['examStage'],
      year: parameters['year'],
      q: parameters['q'],
      sort: parameters['sort'],
    );
  }

  Map<String, String> toParameters() {
    final Map<String, String> out = <String, String>{};
    if (regions?.isNotEmpty == true) out['regions'] = regions!;
    if (genre?.isNotEmpty == true) out['genre'] = genre!;
    if (family?.isNotEmpty == true) out['family'] = family!;
    if (domain?.isNotEmpty == true) out['domain'] = domain!;
    if (topic?.isNotEmpty == true) out['topic'] = topic!;
    if (goal?.isNotEmpty == true) out['goal'] = goal!;
    if (stageNid?.isNotEmpty == true) out['stageNid'] = stageNid!;
    if (examStage?.isNotEmpty == true) out['examStage'] = examStage!;
    if (year?.isNotEmpty == true) out['year'] = year!;
    if (q?.isNotEmpty == true) out['q'] = q!;
    if (sort?.isNotEmpty == true) out['sort'] = sort!;
    return out;
  }

  ZhenxieExamTaskQuery copyWith({
    String? regions,
    String? genre,
    String? family,
    String? domain,
    String? topic,
    String? goal,
    String? stageNid,
    String? examStage,
    String? year,
    String? q,
    String? sort,
  }) {
    return ZhenxieExamTaskQuery(
      regions: regions ?? this.regions,
      genre: genre ?? this.genre,
      family: family ?? this.family,
      domain: domain ?? this.domain,
      topic: topic ?? this.topic,
      goal: goal ?? this.goal,
      stageNid: stageNid ?? this.stageNid,
      examStage: examStage ?? this.examStage,
      year: year ?? this.year,
      q: q ?? this.q,
      sort: sort ?? this.sort,
    );
  }
}

/// 真题列表筛选元数据：直接对齐 `task/query/meta/group/list`。
class ZhenxieExamTaskQueryMetaData {
  final List<ZhenxieExamTaskQueryMetaGroupData> filters;
  final List<ZhenxieExamTaskQueryMetaGroupData> orders;
  final List<ZhenxieExamTaskQuerySearchHintData> searchHints;

  const ZhenxieExamTaskQueryMetaData({
    required this.filters,
    required this.orders,
    required this.searchHints,
  });

  factory ZhenxieExamTaskQueryMetaData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamTaskQueryMetaData(
      filters: (json['filters'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamTaskQueryMetaGroupData.fromJson(item))
          .toList(),
      orders: (json['orders'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamTaskQueryMetaGroupData.fromJson(item))
          .toList(),
      searchHints: (json['searchHints'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) {
            if (item is Map<String, dynamic>) {
              return ZhenxieExamTaskQuerySearchHintData.fromJson(item);
            }
            if (item is String) {
              return ZhenxieExamTaskQuerySearchHintData(text: item);
            }
            return null;
          })
          .whereType<ZhenxieExamTaskQuerySearchHintData>()
          .toList(),
    );
  }
}

class ZhenxieExamTaskQuerySearchHintData {
  final String text;
  final int weight;

  const ZhenxieExamTaskQuerySearchHintData({
    required this.text,
    this.weight = 0,
  });

  factory ZhenxieExamTaskQuerySearchHintData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamTaskQuerySearchHintData(
      text: json['text']?.toString() ?? '',
      weight: (json['weight'] as num?)?.toInt() ?? 0,
    );
  }
}

class ZhenxieExamTaskQueryMetaGroupData {
  final String groupCode;
  final String groupName;
  final String component;
  final String filterGroup;
  final bool radioGroup;
  final List<ZhenxieExamTaskQueryMetaItemData> items;

  const ZhenxieExamTaskQueryMetaGroupData({
    required this.groupCode,
    required this.groupName,
    required this.component,
    required this.filterGroup,
    required this.radioGroup,
    required this.items,
  });

  factory ZhenxieExamTaskQueryMetaGroupData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamTaskQueryMetaGroupData(
      groupCode: json['groupCode']?.toString() ?? '',
      groupName: json['groupName']?.toString() ?? '',
      component: json['component']?.toString() ?? '',
      filterGroup: json['filterGroup']?.toString() ?? '',
      radioGroup: json['radioGroup'] == true,
      items: (json['items'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamTaskQueryMetaItemData.fromJson(item))
          .toList(),
    );
  }
}

class ZhenxieExamTaskQueryMetaItemData {
  final String value;
  final String name;
  final List<LanguageText> names;
  final bool defaultValue;
  final bool disabled;

  const ZhenxieExamTaskQueryMetaItemData({
    required this.value,
    required this.name,
    required this.names,
    required this.defaultValue,
    required this.disabled,
  });

  factory ZhenxieExamTaskQueryMetaItemData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamTaskQueryMetaItemData(
      value: json['value']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      names: _languageTextList(json['names']),
      defaultValue: json['defaultValue'] == true,
      disabled: json['disabled'] == true,
    );
  }
}

/// 真题分页列表：直接对齐 `task/pages`。
class ZhenxieExamTaskPageData {
  final int offset;
  final int limit;
  final int count;
  final List<ZhenxieExamTaskCardData> datas;
  final String yearRange;
  final List<ZhenxieExamTaskColorData> milestoneColors;
  final List<ZhenxieExamTaskColorData> familyColors;

  const ZhenxieExamTaskPageData({
    required this.offset,
    required this.limit,
    required this.count,
    required this.datas,
    required this.yearRange,
    required this.milestoneColors,
    required this.familyColors,
  });

  factory ZhenxieExamTaskPageData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rows = (json['datas'] as List<dynamic>?) ?? (json['list'] as List<dynamic>?) ?? const <dynamic>[];
    return ZhenxieExamTaskPageData(
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
      datas: rows
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamTaskCardData.fromJson(item))
          .toList(),
      yearRange: json['yearRange']?.toString() ?? '',
      milestoneColors: (json['milestoneColors'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamTaskColorData.fromJson(item))
          .toList(),
      familyColors: (json['familyColors'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamTaskColorData.fromJson(item))
          .toList(),
    );
  }
}

class ZhenxieExamTaskCardData {
  final int uid;
  final String milestone;
  final List<LanguageText> milestoneName;
  final int? year;
  final String topic;
  final String? paperName;
  final List<String> requiredPoints;
  final List<ZhenxieExamTaskLabelData> regions;
  final ZhenxieExamTaskLabelData family;
  final List<ZhenxieExamTaskLabelData> topics;
  final ZhenxieExamTaskLabelData stage;
  final ZhenxieExamTaskLabelData coverage;

  const ZhenxieExamTaskCardData({
    required this.uid,
    required this.milestone,
    required this.milestoneName,
    required this.year,
    required this.topic,
    required this.paperName,
    required this.requiredPoints,
    required this.regions,
    required this.family,
    required this.topics,
    required this.stage,
    required this.coverage,
  });

  factory ZhenxieExamTaskCardData.fromJson(Map<String, dynamic> json) {
    final dynamic family = json['family'];
    final dynamic stage = json['stage'];
    final dynamic coverage = json['coverage'];
    return ZhenxieExamTaskCardData(
      uid: (json['uid'] as num?)?.toInt() ?? 0,
      milestone: json['milestone']?.toString() ?? '',
      milestoneName: _languageTextList(json['milestoneName']),
      year: (json['year'] as num?)?.toInt(),
      topic: json['topic']?.toString() ?? '',
      paperName: json['paperName']?.toString(),
      requiredPoints: _stringList(json['requiredPoints']),
      regions: (json['regions'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamTaskLabelData.fromJson(item))
          .toList(),
      family: family is Map<String, dynamic>
          ? ZhenxieExamTaskLabelData.fromJson(family)
          : const ZhenxieExamTaskLabelData(code: '', name: <LanguageText>[]),
      topics: (json['topics'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamTaskLabelData.fromJson(item))
          .toList(),
      stage: stage is Map<String, dynamic>
          ? ZhenxieExamTaskLabelData.fromJson(stage)
          : const ZhenxieExamTaskLabelData(code: '', name: <LanguageText>[]),
      coverage: coverage is Map<String, dynamic>
          ? ZhenxieExamTaskLabelData.fromJson(coverage)
          : const ZhenxieExamTaskLabelData(code: '', name: <LanguageText>[]),
    );
  }
}

class ZhenxieExamTaskLabelData {
  final String code;
  final List<LanguageText> name;

  const ZhenxieExamTaskLabelData({
    required this.code,
    required this.name,
  });

  factory ZhenxieExamTaskLabelData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamTaskLabelData(
      code: json['code']?.toString() ?? '',
      name: _languageTextList(json['name']),
    );
  }
}

class ZhenxieExamTaskColorData {
  final String code;
  final List<LanguageText> name;
  final List<LanguageConfigColorEntityThemeColors> colors;

  const ZhenxieExamTaskColorData({
    required this.code,
    required this.name,
    required this.colors,
  });

  factory ZhenxieExamTaskColorData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamTaskColorData(
      code: json['code']?.toString() ?? '',
      name: _languageTextList(json['name']),
      colors: _themeColorList(json['colors']),
    );
  }
}

class ZhenxieExamTaskDetailData {
  final int uid;
  final String milestone;
  final List<LanguageText> milestoneName;
  final int? year;
  final String topic;
  final String? paperName;
  final String section;
  final String wordLimit;
  final ZhenxieExamTaskWordCountData? wordCount;
  final String fullText;
  final String example;
  final List<String> requiredPoints;
  final List<ZhenxieExamTaskLabelData> regions;
  final ZhenxieExamTaskLabelData family;
  final List<ZhenxieExamTaskColorData> milestoneColors;
  final List<ZhenxieExamTaskColorData> familyColors;
  final List<ZhenxieExamTaskGoalData> goals;
  final List<ZhenxieExamTaskLabelData> topics;
  final ZhenxieExamTaskLabelData? writingStage;
  final ZhenxieExamTaskLabelData? writingTask;
  final ZhenxieExamTaskLabelData? coverage;
  final List<ZhenxieExamRelatedTaskGroupData> relatedTaskGroups;

  const ZhenxieExamTaskDetailData({
    required this.uid,
    required this.milestone,
    required this.milestoneName,
    required this.year,
    required this.topic,
    required this.paperName,
    required this.section,
    required this.wordLimit,
    required this.wordCount,
    required this.fullText,
    required this.example,
    required this.requiredPoints,
    required this.regions,
    required this.family,
    required this.milestoneColors,
    required this.familyColors,
    required this.goals,
    required this.topics,
    required this.writingStage,
    required this.writingTask,
    required this.coverage,
    required this.relatedTaskGroups,
  });

  factory ZhenxieExamTaskDetailData.fromJson(Map<String, dynamic> json) {
    final dynamic family = json['family'];
    final dynamic writingStage = json['writingStage'];
    final dynamic writingTask = json['writingTask'];
    final dynamic coverage = json['coverage'];
    final dynamic wordCount = json['wordCount'];
    return ZhenxieExamTaskDetailData(
      uid: (json['uid'] as num?)?.toInt() ?? 0,
      milestone: json['milestone']?.toString() ?? '',
      milestoneName: _languageTextList(json['milestoneName']),
      year: (json['year'] as num?)?.toInt(),
      topic: json['topic']?.toString() ?? '',
      paperName: json['paperName']?.toString(),
      section: json['section']?.toString() ?? '',
      wordLimit: json['wordLimit']?.toString() ?? '',
      wordCount: wordCount is Map<String, dynamic> ? ZhenxieExamTaskWordCountData.fromJson(wordCount) : null,
      fullText: json['fullText']?.toString() ?? '',
      example: json['example']?.toString() ?? '',
      requiredPoints: _stringList(json['requiredPoints']),
      regions: (json['regions'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamTaskLabelData.fromJson(item))
          .toList(),
      family: family is Map<String, dynamic>
          ? ZhenxieExamTaskLabelData.fromJson(family)
          : const ZhenxieExamTaskLabelData(code: '', name: <LanguageText>[]),
      milestoneColors: (json['milestoneColors'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamTaskColorData.fromJson(item))
          .toList(),
      familyColors: (json['familyColors'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamTaskColorData.fromJson(item))
          .toList(),
      goals: (json['goals'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamTaskGoalData.fromJson(item))
          .toList(),
      topics: (json['topics'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamTaskLabelData.fromJson(item))
          .toList(),
      writingStage:
          writingStage is Map<String, dynamic> ? ZhenxieExamTaskLabelData.fromJson(writingStage) : null,
      writingTask:
          writingTask is Map<String, dynamic> ? ZhenxieExamTaskLabelData.fromJson(writingTask) : null,
      coverage: coverage is Map<String, dynamic> ? ZhenxieExamTaskLabelData.fromJson(coverage) : null,
      relatedTaskGroups: (json['relatedTaskGroups'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamRelatedTaskGroupData.fromJson(item))
          .toList(),
    );
  }
}

class ZhenxieExamTaskWordCountData {
  final int? min;
  final int? max;

  const ZhenxieExamTaskWordCountData({
    required this.min,
    required this.max,
  });

  factory ZhenxieExamTaskWordCountData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamTaskWordCountData(
      min: (json['min'] as num?)?.toInt(),
      max: (json['max'] as num?)?.toInt(),
    );
  }
}

class ZhenxieExamTaskGoalData {
  final String code;
  final List<LanguageText> name;
  final int count;
  final bool current;

  const ZhenxieExamTaskGoalData({
    required this.code,
    required this.name,
    required this.count,
    required this.current,
  });

  factory ZhenxieExamTaskGoalData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamTaskGoalData(
      code: json['code']?.toString() ?? '',
      name: _languageTextList(json['name']),
      count: (json['count'] as num?)?.toInt() ?? 0,
      current: json['current'] == true,
    );
  }
}

class ZhenxieExamRelatedTaskGroupData {
  final String code;
  final List<LanguageText> title;
  final List<ZhenxieExamTaskCardData> items;

  const ZhenxieExamRelatedTaskGroupData({
    required this.code,
    required this.title,
    required this.items,
  });

  factory ZhenxieExamRelatedTaskGroupData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamRelatedTaskGroupData(
      code: json['code']?.toString() ?? '',
      title: _languageTextList(json['title']),
      items: (json['items'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamTaskCardData.fromJson(item))
          .toList(),
    );
  }
}

/// 阶段报告 / overall 总报告（en_composition_milestone_exam_reports 一条）。
class ZhenxieExamReportModel {
  final String nid;
  final String kind;
  final String overview;
  final List<ZhenxieExamGoalModel> goals;
  final List<ZhenxieExamLadderRungModel> ladder;

  /// stage → 一句话结论（overall 报告才有）。
  final Map<String, String> headlines;

  const ZhenxieExamReportModel({
    required this.nid,
    required this.kind,
    required this.overview,
    required this.goals,
    required this.ladder,
    required this.headlines,
  });

  factory ZhenxieExamReportModel.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamReportModel(
      nid: json['nid']?.toString() ?? '',
      kind: json['kind']?.toString() ?? '',
      overview: json['overview']?.toString() ?? '',
      goals: (json['goals'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamGoalModel.fromJson(item))
          .toList(),
      ladder: (json['ladder'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamLadderRungModel.fromJson(item))
          .toList(),
      headlines: (json['headlines'] as Map<String, dynamic>? ?? const <String, dynamic>{})
          .map((key, value) => MapEntry(key, value?.toString() ?? '')),
    );
  }
}

/// 报告里的一条写作能力。
class ZhenxieExamGoalModel {
  final String nid;
  final String goal;
  final String why;
  final String teachingHint;

  const ZhenxieExamGoalModel({
    required this.nid,
    required this.goal,
    required this.why,
    required this.teachingHint,
  });

  factory ZhenxieExamGoalModel.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamGoalModel(
      nid: json['nid']?.toString() ?? '',
      goal: json['goal']?.toString() ?? '',
      why: json['why']?.toString() ?? '',
      teachingHint: json['teachingHint']?.toString() ?? '',
    );
  }
}

/// 指挥棒梯级：小升初 / 中考能力怎么通向一条高考能力。
class ZhenxieExamLadderRungModel {
  final String gaokaoGoalNid;
  final List<String> zhongkaoGoalNids;
  final List<String> xiaoshengchuGoalNids;
  final String note;

  /// 1 起；按高考题数排。
  final int? order;

  const ZhenxieExamLadderRungModel({
    required this.gaokaoGoalNid,
    required this.zhongkaoGoalNids,
    required this.xiaoshengchuGoalNids,
    required this.note,
    required this.order,
  });

  factory ZhenxieExamLadderRungModel.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamLadderRungModel(
      gaokaoGoalNid: json['gaokaoGoalNid']?.toString() ?? '',
      zhongkaoGoalNids: _stringList(json['zhongkaoGoalNids']),
      xiaoshengchuGoalNids: _stringList(json['xiaoshengchuGoalNids']),
      note: json['note']?.toString() ?? '',
      order: (json['order'] as num?)?.toInt(),
    );
  }
}

/// 主题维表（topics.json）：根 = 内容域，叶子 = 题上打的 topicNids。
class ZhenxieExamTopicModel {
  final String nid;
  final String? parentNid;
  final String name;

  const ZhenxieExamTopicModel({
    required this.nid,
    required this.parentNid,
    required this.name,
  });

  factory ZhenxieExamTopicModel.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamTopicModel(
      nid: json['nid']?.toString() ?? '',
      parentNid: json['parentNid']?.toString(),
      name: pickLocalizedText(json['names']),
    );
  }
}

/// 地区维表（en_exam_regions.json）；省市数只数省级，市级归所属省。
class ZhenxieExamRegionModel {
  final String nid;
  final String name;
  final String level;
  final String? parentNid;
  final String? gaokaoPaper;
  final int sortWeight;

  const ZhenxieExamRegionModel({
    required this.nid,
    required this.name,
    required this.level,
    required this.parentNid,
    required this.gaokaoPaper,
    required this.sortWeight,
  });

  factory ZhenxieExamRegionModel.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamRegionModel(
      nid: json['nid']?.toString() ?? '',
      name: pickLocalizedText(json['name']),
      level: json['level']?.toString() ?? '',
      parentNid: json['parentNid']?.toString(),
      gaokaoPaper: json['gaokaoPaper']?.toString(),
      sortWeight: (json['sortWeight'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 文类基表（en_composition_genres.json）。
class ZhenxieExamGenreModel {
  final String nid;
  final int order;
  final String name;

  const ZhenxieExamGenreModel({
    required this.nid,
    required this.order,
    required this.name,
  });

  factory ZhenxieExamGenreModel.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamGenreModel(
      nid: json['nid']?.toString() ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      name: pickLocalizedText(json['name']),
    );
  }
}

/// 家族基表（en_composition_families.json）：家族 → 文类唯一挂靶。
class ZhenxieExamFamilyModel {
  final String nid;
  final int order;
  final String genreNid;
  final String name;

  const ZhenxieExamFamilyModel({
    required this.nid,
    required this.order,
    required this.genreNid,
    required this.name,
  });

  factory ZhenxieExamFamilyModel.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamFamilyModel(
      nid: json['nid']?.toString() ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      genreNid: json['genreNid']?.toString() ?? '',
      name: pickLocalizedText(json['name']),
    );
  }
}

/// 写作课关阶（en_composition_stages.json），考场阶也在里面。
class ZhenxieExamStageNodeModel {
  final String nid;
  final String? compositionBlueprintNid;
  final String name;
  final String description;
  final int order;
  final List<String> milestones;

  const ZhenxieExamStageNodeModel({
    required this.nid,
    required this.compositionBlueprintNid,
    required this.name,
    required this.description,
    required this.order,
    required this.milestones,
  });

  factory ZhenxieExamStageNodeModel.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamStageNodeModel(
      nid: json['nid']?.toString() ?? '',
      compositionBlueprintNid: json['compositionBlueprintNid']?.toString(),
      name: pickLocalizedText(json['name']),
      description: pickLocalizedText(json['description']),
      order: (json['order'] as num?)?.toInt() ?? 0,
      milestones: _stringList(json['milestones']),
    );
  }
}

/// 蓝图（en_composition_blueprints.json）：阶 → 蓝图 → 家族 → 文类色 / 皮图标。
class ZhenxieExamBlueprintModel {
  final String nid;
  final String compositionFamilyNid;
  final String skinNid;

  const ZhenxieExamBlueprintModel({
    required this.nid,
    required this.compositionFamilyNid,
    required this.skinNid,
  });

  factory ZhenxieExamBlueprintModel.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamBlueprintModel(
      nid: json['nid']?.toString() ?? '',
      compositionFamilyNid: json['compositionFamilyNid']?.toString() ?? '',
      skinNid: json['skinNid']?.toString() ?? '',
    );
  }
}

/* ------------------------------------------------------------------ 接口模型 */

/// 考点首页接口数据。
class ZhenxieExamHomeData {
  final String stage;
  final List<LanguageText> title;
  final List<LanguageText> subTitle;
  final String headline;
  final ZhenxieExamHomeSummaryData? summary;
  final List<ZhenxieExamHomeStageData> stages;
  final List<ZhenxieExamHomeBlockData> blocks;

  const ZhenxieExamHomeData({
    required this.stage,
    required this.title,
    required this.subTitle,
    required this.headline,
    required this.summary,
    required this.stages,
    required this.blocks,
  });

  factory ZhenxieExamHomeData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamHomeData(
      stage: json['stage']?.toString() ?? '',
      title: _languageTextList(json['title']),
      subTitle: _languageTextList(json['subTitle']),
      headline: json['headline']?.toString() ?? '',
      summary: json['summary'] is Map<String, dynamic>
          ? ZhenxieExamHomeSummaryData.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      stages: (json['stages'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamHomeStageData.fromJson(item))
          .toList(),
      blocks: (json['blocks'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamHomeBlockData.fromJson(item))
          .toList(),
    );
  }
}

class ZhenxieExamHomeSummaryData {
  final List<LanguageText> levelName;
  final int taskCount;
  final int regionCount;
  final int? startYear;
  final int? endYear;
  final String summaryText;

  const ZhenxieExamHomeSummaryData({
    required this.levelName,
    required this.taskCount,
    required this.regionCount,
    required this.startYear,
    required this.endYear,
    required this.summaryText,
  });

  factory ZhenxieExamHomeSummaryData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamHomeSummaryData(
      levelName: _languageTextList(json['levelName']),
      taskCount: (json['taskCount'] as num?)?.toInt() ?? 0,
      regionCount: (json['regionCount'] as num?)?.toInt() ?? 0,
      startYear: (json['startYear'] as num?)?.toInt(),
      endYear: (json['endYear'] as num?)?.toInt(),
      summaryText: json['summaryText']?.toString() ?? '',
    );
  }
}

class ZhenxieExamHomeStageData {
  final String stage;
  final List<LanguageText> name;
  final int taskCount;
  final List<LanguageConfigColorEntityThemeColors> colors;

  const ZhenxieExamHomeStageData({
    required this.stage,
    required this.name,
    required this.taskCount,
    required this.colors,
  });

  factory ZhenxieExamHomeStageData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamHomeStageData(
      stage: json['stage']?.toString() ?? '',
      name: _languageTextList(json['name']),
      taskCount: (json['taskCount'] as num?)?.toInt() ?? 0,
      colors: _themeColorList(json['colors']),
    );
  }
}

class ZhenxieExamHomeBlockData {
  final String code;
  final List<LanguageText> title;
  final List<LanguageText> description;
  final List<LanguageText> summary;
  final List<ZhenxieExamCompareLegendData> legends;
  final String legendDescription;
  final int total;
  final int coveredCount;
  final int percent;
  final List<ZhenxieExamHomeBlockItemData> items;
  final String route;

  const ZhenxieExamHomeBlockData({
    required this.code,
    required this.title,
    required this.description,
    required this.summary,
    required this.legends,
    required this.legendDescription,
    required this.total,
    required this.coveredCount,
    required this.percent,
    required this.items,
    required this.route,
  });

  factory ZhenxieExamHomeBlockData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamHomeBlockData(
      code: json['code']?.toString() ?? '',
      title: _languageTextList(json['title']),
      description: _languageTextList(json['description']),
      summary: _languageTextList(json['summary']),
      legends: (json['legends'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamCompareLegendData.fromJson(item))
          .toList(),
      legendDescription: json['legendDescription']?.toString() ?? '',
      total: (json['total'] as num?)?.toInt() ?? 0,
      coveredCount: (json['coveredCount'] as num?)?.toInt() ?? 0,
      percent: (json['percent'] as num?)?.toInt() ?? 0,
      items: (json['items'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamHomeBlockItemData.fromJson(item))
          .toList(),
      route: json['route']?.toString() ?? '',
    );
  }
}

class ZhenxieExamHomeBlockItemData {
  final String code;
  final List<LanguageText> name;
  final int count;
  final int secondaryCount;
  final int totalCount;
  final int percent;
  final String groupCode;
  final String cover;
  final String coverUrl;
  final String coverMd5;
  final List<LanguageConfigColorEntityThemeColors> colors;

  const ZhenxieExamHomeBlockItemData({
    required this.code,
    required this.name,
    required this.count,
    required this.secondaryCount,
    required this.totalCount,
    required this.percent,
    required this.groupCode,
    required this.cover,
    required this.coverUrl,
    required this.coverMd5,
    required this.colors,
  });

  factory ZhenxieExamHomeBlockItemData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamHomeBlockItemData(
      code: json['code']?.toString() ?? '',
      name: _languageTextList(json['name']),
      count: (json['count'] as num?)?.toInt() ?? 0,
      secondaryCount: (json['secondaryCount'] as num?)?.toInt() ?? 0,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      percent: (json['percent'] as num?)?.toInt() ?? 0,
      groupCode: json['groupCode']?.toString() ?? '',
      cover: json['cover']?.toString() ?? '',
      coverUrl: json['coverUrl']?.toString() ?? '',
      coverMd5: json['coverMd5']?.toString() ?? '',
      colors: _themeColorList(json['colors']),
    );
  }
}

/// 对比页通用接口数据。
class ZhenxieExamCompareData {
  final List<LanguageText> title;
  final List<LanguageText> description;
  final String note;
  final List<ZhenxieExamCompareLegendData> legends;
  final List<ZhenxieExamCompareGenreColorData> genreColors;
  final List<ZhenxieExamCompareColumnData> columns;

  const ZhenxieExamCompareData({
    required this.title,
    required this.description,
    required this.note,
    required this.legends,
    required this.genreColors,
    required this.columns,
  });

  factory ZhenxieExamCompareData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamCompareData(
      title: _languageTextList(json['title']),
      description: _languageTextList(json['description']),
      note: json['note']?.toString() ?? '',
      legends: (json['legends'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamCompareLegendData.fromJson(item))
          .toList(),
        genreColors: (json['genreColors'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map((item) => ZhenxieExamCompareGenreColorData.fromJson(item))
            .toList(),
      columns: (json['columns'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamCompareColumnData.fromJson(item))
          .toList(),
    );
  }
}

class ZhenxieExamCompareGenreColorData {
  final String code;
  final List<LanguageText> name;
  final List<LanguageConfigColorEntityThemeColors> colors;

  const ZhenxieExamCompareGenreColorData({
    required this.code,
    required this.name,
    required this.colors,
  });

  factory ZhenxieExamCompareGenreColorData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamCompareGenreColorData(
      code: json['code']?.toString() ?? '',
      name: _languageTextList(json['name']),
      colors: _themeColorList(json['colors']),
    );
  }
}

class ZhenxieExamCompareLegendData {
  final String code;
  final List<LanguageText> name;
  final String groupCode;
  final List<LanguageText> groupName;
  final String cover;
  final String coverUrl;
  final String coverMd5;
  final List<LanguageConfigColorEntityThemeColors> colors;

  const ZhenxieExamCompareLegendData({
    required this.code,
    required this.name,
    required this.groupCode,
    required this.groupName,
    required this.cover,
    required this.coverUrl,
    required this.coverMd5,
    required this.colors,
  });

  factory ZhenxieExamCompareLegendData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamCompareLegendData(
      code: json['code']?.toString() ?? '',
      name: _languageTextList(json['name']),
      groupCode: json['groupCode']?.toString() ?? '',
      groupName: _languageTextList(json['groupName']),
      cover: json['cover']?.toString() ?? '',
      coverUrl: json['coverUrl']?.toString() ?? '',
      coverMd5: json['coverMd5']?.toString() ?? '',
      colors: _themeColorList(json['colors']),
    );
  }
}

class ZhenxieExamCompareColumnData {
  final String stage;
  final List<LanguageText> name;
  final int taskCount;
  final String summaryText;
  final List<ZhenxieExamCompareNodeData> nodes;

  const ZhenxieExamCompareColumnData({
    required this.stage,
    required this.name,
    required this.taskCount,
    required this.summaryText,
    required this.nodes,
  });

  factory ZhenxieExamCompareColumnData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamCompareColumnData(
      stage: json['stage']?.toString() ?? '',
      name: _languageTextList(json['name']),
      taskCount: (json['taskCount'] as num?)?.toInt() ?? 0,
      summaryText: json['summaryText']?.toString() ?? '',
      nodes: (json['nodes'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamCompareNodeData.fromJson(item))
          .toList(),
    );
  }
}

class ZhenxieExamCompareNodeData {
  final String code;
  final int value;
  final int secondaryValue;
  final int percent;
  final int order;

  const ZhenxieExamCompareNodeData({
    required this.code,
    required this.value,
    required this.secondaryValue,
    required this.percent,
    required this.order,
  });

  factory ZhenxieExamCompareNodeData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamCompareNodeData(
      code: json['code']?.toString() ?? '',
      value: (json['value'] as num?)?.toInt() ?? 0,
      secondaryValue: (json['secondaryValue'] as num?)?.toInt() ?? 0,
      percent: (json['percent'] as num?)?.toInt() ?? 0,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 能力桑基图专用接口数据。
class ZhenxieExamGoalSankeyApiData {
  final List<LanguageText> title;
  final List<LanguageText> description;
  final String note;
  final List<ZhenxieExamCompareLegendData> legends;
  final List<ZhenxieExamGoalSankeyColumnApiData> columns;
  final List<ZhenxieExamGoalSankeyLinkApiData> links;

  const ZhenxieExamGoalSankeyApiData({
    required this.title,
    required this.description,
    required this.note,
    required this.legends,
    required this.columns,
    required this.links,
  });

  factory ZhenxieExamGoalSankeyApiData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamGoalSankeyApiData(
      title: _languageTextList(json['title']),
      description: _languageTextList(json['description']),
      note: json['note']?.toString() ?? '',
      legends: (json['legends'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamCompareLegendData.fromJson(item))
          .toList(),
      columns: (json['columns'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamGoalSankeyColumnApiData.fromJson(item))
          .toList(),
      links: (json['links'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamGoalSankeyLinkApiData.fromJson(item))
          .toList(),
    );
  }
}

class ZhenxieExamGoalSankeyColumnApiData {
  final String stage;
  final List<LanguageText> name;
  final String summaryText;
  final List<ZhenxieExamGoalSankeyNodeApiData> nodes;

  const ZhenxieExamGoalSankeyColumnApiData({
    required this.stage,
    required this.name,
    required this.summaryText,
    required this.nodes,
  });

  factory ZhenxieExamGoalSankeyColumnApiData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamGoalSankeyColumnApiData(
      stage: json['stage']?.toString() ?? '',
      name: _languageTextList(json['name']),
      summaryText: json['summaryText']?.toString() ?? '',
      nodes: (json['nodes'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamGoalSankeyNodeApiData.fromJson(item))
          .toList(),
    );
  }
}

class ZhenxieExamGoalSankeyNodeApiData {
  final String code;
  final List<LanguageText> name;
  final bool basic;
  final List<ZhenxieExamGoalSankeyMemberApiData> members;
  final List<String> goalCodes;
  final int value;
  final int primaryValue;
  final int order;

  const ZhenxieExamGoalSankeyNodeApiData({
    required this.code,
    required this.name,
    required this.basic,
    required this.members,
    required this.goalCodes,
    required this.value,
    required this.primaryValue,
    required this.order,
  });

  factory ZhenxieExamGoalSankeyNodeApiData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamGoalSankeyNodeApiData(
      code: json['code']?.toString() ?? '',
      name: _languageTextList(json['name']),
      basic: json['basic'] == true,
      members: (json['members'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamGoalSankeyMemberApiData.fromJson(item))
          .toList(),
      goalCodes: _stringList(json['goalCodes']),
      value: (json['value'] as num?)?.toInt() ?? 0,
      primaryValue: (json['primaryValue'] as num?)?.toInt() ?? 0,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }
}

class ZhenxieExamGoalSankeyMemberApiData {
  final String code;
  final List<LanguageText> name;

  const ZhenxieExamGoalSankeyMemberApiData({
    required this.code,
    required this.name,
  });

  factory ZhenxieExamGoalSankeyMemberApiData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamGoalSankeyMemberApiData(
      code: json['code']?.toString() ?? '',
      name: _languageTextList(json['name']),
    );
  }
}

class ZhenxieExamGoalSankeyLinkApiData {
  final String source;
  final String target;
  final List<String> notes;

  const ZhenxieExamGoalSankeyLinkApiData({
    required this.source,
    required this.target,
    required this.notes,
  });

  factory ZhenxieExamGoalSankeyLinkApiData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamGoalSankeyLinkApiData(
      source: json['source']?.toString() ?? '',
      target: json['target']?.toString() ?? '',
      notes: _stringList(json['notes']),
    );
  }
}

/// 对比页筛选元数据。
class ZhenxieExamCompareMetaData {
  final List<ZhenxieExamCompareFixedOptionData> fixedOptions;
  final List<ZhenxieExamCompareRegionGroupData> groups;

  const ZhenxieExamCompareMetaData({
    required this.fixedOptions,
    required this.groups,
  });

  factory ZhenxieExamCompareMetaData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamCompareMetaData(
      fixedOptions: (json['fixedOptions'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamCompareFixedOptionData.fromJson(item))
          .toList(),
      groups: (json['groups'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamCompareRegionGroupData.fromJson(item))
          .toList(),
    );
  }
}

class ZhenxieExamCompareFixedOptionData {
  final String value;
  final String name;
  final String groupCode;
  final List<String> regionNids;

  const ZhenxieExamCompareFixedOptionData({
    required this.value,
    required this.name,
    required this.groupCode,
    required this.regionNids,
  });

  factory ZhenxieExamCompareFixedOptionData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamCompareFixedOptionData(
      value: json['value']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      groupCode: json['groupCode']?.toString() ?? '',
      regionNids: _stringList(json['regionNids']),
    );
  }
}

class ZhenxieExamCompareRegionGroupData {
  final String code;
  final String name;
  final List<ZhenxieExamCompareRegionData> regions;

  const ZhenxieExamCompareRegionGroupData({
    required this.code,
    required this.name,
    required this.regions,
  });

  factory ZhenxieExamCompareRegionGroupData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamCompareRegionGroupData(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      regions: (json['regions'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieExamCompareRegionData.fromJson(item))
          .toList(),
    );
  }
}

class ZhenxieExamCompareRegionData {
  final String nid;
  final List<LanguageText> name;
  final List<LanguageText> description;
  final String gaokaoPaper;
  final String fixedValue;
  final int sortWeight;

  const ZhenxieExamCompareRegionData({
    required this.nid,
    required this.name,
    required this.description,
    required this.gaokaoPaper,
    required this.fixedValue,
    required this.sortWeight,
  });

  factory ZhenxieExamCompareRegionData.fromJson(Map<String, dynamic> json) {
    return ZhenxieExamCompareRegionData(
      nid: json['nid']?.toString() ?? '',
      name: _languageTextList(json['name']),
      description: _languageTextList(json['description']),
      gaokaoPaper: json['gaokaoPaper']?.toString() ?? '',
      fixedValue: json['fixedValue']?.toString() ?? '',
      sortWeight: (json['sortWeight'] as num?)?.toInt() ?? 0,
    );
  }
}

/* ------------------------------------------------------------------ 视图数据 */

/// 环形图一片：id · 名 · 题数 · 色。
class ZhenxieExamSliceData {
  final String id;
  final String label;
  final int value;
  final int colorValue;

  const ZhenxieExamSliceData({
    required this.id,
    required this.label,
    required this.value,
    required this.colorValue,
  });
}

/// 排行柱一行：主段 value + 淡段 secondary（作副能力的题数）。
class ZhenxieExamRankRowData {
  final String id;
  final String label;
  final int value;
  final int secondary;
  final int colorValue;

  /// 在通往高考的能力线上（朱色），否则基本功（骨色）。
  final bool onLine;

  const ZhenxieExamRankRowData({
    required this.id,
    required this.label,
    required this.value,
    required this.secondary,
    required this.colorValue,
    required this.onLine,
  });

  int get total => value + secondary;
}

/// 阶梯格横滚里的一个关阶节点。
class ZhenxieExamLadderNodeData {
  final String stageNid;
  final String stageName;
  final int count;
  final int colorValue;
  final String coverUrl;

  /// 皮图标名（en_composition_skins 的 skinNid），找不到图标时给空。
  final String skinNid;

  /// 蓝图封面本地资源路径（对齐 React coverSrcForBlueprint）；无封面为 null，退回渐变图标。
  final String? coverAsset;

  const ZhenxieExamLadderNodeData({
    required this.stageNid,
    required this.stageName,
    required this.count,
    required this.colorValue,
    required this.coverUrl,
    required this.skinNid,
    this.coverAsset,
  });
}

/// 阶梯格结论数据。
class ZhenxieExamLadderData {
  final int covered;
  final int total;
  final int stages;
  final List<ZhenxieExamLadderNodeData> nodes;

  const ZhenxieExamLadderData({
    required this.covered,
    required this.total,
    required this.stages,
    required this.nodes,
  });

  int get rate => total == 0 ? 0 : ((covered / total) * 100).round();
}

/* ------------------------------------------------------------------ 工具 */

List<String> _stringList(dynamic value) {
  if (value == null) return const <String>[];
  if (value is String) return value.isEmpty ? const <String>[] : <String>[value];
  if (value is! List<dynamic>) return <String>[pickTextValue(value)];
  return value
      .map((item) {
        if (item is String) return item;
        if (item is Map<String, dynamic>) {
          final String text = pickTextValue(item['name']);
          if (text.isNotEmpty) return text;
          return item['text']?.toString() ?? item['code']?.toString() ?? '';
        }
        return item?.toString() ?? '';
      })
      .where((item) => item.isNotEmpty)
      .toList();
}

List<LanguageText> _languageTextList(dynamic value) {
  if (value == null) return const <LanguageText>[];
  if (value is String) {
    if (value.isEmpty) return const <LanguageText>[];
    return <LanguageText>[LanguageText(lang: 'zh', text: value)];
  }
  if (value is Map<String, dynamic>) {
    if (value.containsKey('lang') || value.containsKey('text')) {
      return <LanguageText>[LanguageText.fromJson(value)];
    }
    final String text = pickTextValue(value['name']);
    if (text.isEmpty) return const <LanguageText>[];
    return <LanguageText>[LanguageText(lang: 'zh', text: text)];
  }
  if (value is! List<dynamic>) return const <LanguageText>[];
  return value
      .map((item) {
        if (item is Map<String, dynamic>) return LanguageText.fromJson(item);
        if (item is String && item.isNotEmpty) return LanguageText(lang: 'zh', text: item);
        return null;
      })
      .whereType<LanguageText>()
      .toList();
}

List<LanguageConfigColorEntityThemeColors> _themeColorList(dynamic value) {
  if (value is! List<dynamic>) return const <LanguageConfigColorEntityThemeColors>[];
  return value
      .whereType<Map<String, dynamic>>()
      .map((item) => LanguageConfigColorEntityThemeColors.fromJson(item))
      .toList();
}

String pickTextValue(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is Map<String, dynamic>) {
    final String text = value['text']?.toString() ?? '';
    if (text.isNotEmpty) return text;
    return pickTextValue(value['name']);
  }
  return pickLocalizedText(value);
}

/// LocalizedText[] 取中文，退化取第一条非空。
String pickLocalizedText(dynamic value) {
  final List<dynamic> list = value as List<dynamic>? ?? const <dynamic>[];
  for (final dynamic item in list) {
    if (item is! Map<String, dynamic>) continue;
    if (item['lang']?.toString() == 'zh') return item['text']?.toString() ?? '';
  }
  for (final dynamic item in list) {
    if (item is! Map<String, dynamic>) continue;
    final String text = item['text']?.toString() ?? '';
    if (text.isNotEmpty) return text;
  }
  return '';
}

/// 同题数时的次级排序。React 用 `localeCompare(…, 'zh')`，
/// Dart 无内置中文拼音 collator；只在计数打平时生效，退化为码点序。
int compareZh(String a, String b) {
  return a.compareTo(b);
}

/// 降序计数比较，打平时走次级比较器（对应 JS 的 `b - a || cmp`）。
int compareCountDesc(int a, int b, int Function() tieBreak) {
  final int diff = b - a;
  return diff != 0 ? diff : tieBreak();
}

/* ------------------------------------------------------------------ 色板 */

const String otherId = 'other';
const int otherColorValue = 0xFF7A746A;

const Map<String, int> genreColors = <String, int>{
  'narrative': 0xFFFB7185,
  'expository': 0xFF2DD4BF,
  'argumentative': 0xFFC4B5FD,
  'practical': 0xFFFBBF24,
};

const int fallbackGenreColorValue = 0xFFCBD5E1;

int genreColorValue(String genreNid) {
  if (genreNid == otherId) return otherColorValue;
  return genreColors[genreNid] ?? fallbackGenreColorValue;
}

const List<int> topicPalette = <int>[
  0xFFD4AF37,
  0xFFC9855B,
  0xFF9BBF8A,
  0xFF7FB3C8,
  0xFFB58BB5,
  0xFF8AA4A8,
  0xFFC46F5A,
  0xFFA3B18A,
];

const int zxGoldValue = 0xFFD4AF37;
const int zxSealValue = 0xFFD44832;
const int zxBoneValue = 0xFFE6DCC8;

const Map<String, int> stageToneValues = <String, int>{
  'xiaoshengchu': 0xFF7EB8B3,
  'zhongkao': zxGoldValue,
  'gaokao': zxSealValue,
};
