import 'entities.dart';

/// 单元目标详情实体，对应接口 `data` 节点。
class CourseUnitTargetEntity {
  String? specialty;
  int? moduleId;
  String? moduleName;
  String? moduleTopic;
  String? moduleCoverUrl;
  SpeciaityPhonicsModelDataModuleContentInfo? moduleContentInfo;
  int? unitId;
  String? unitName;
  int? unitIndex;
  CourseUnitTargetDifficultyEntity? difficulty;
  String? description;
  int? lessonCount;
  CourseUnitTargetGrammarSummaryEntity? grammarSummary;
  List<KnowledgeCommonEntityList?>? knowledgeList;

  CourseUnitTargetEntity({
    this.specialty,
    this.moduleId,
    this.moduleName,
    this.moduleTopic,
    this.moduleCoverUrl,
    this.moduleContentInfo,
    this.unitId,
    this.unitName,
    this.unitIndex,
    this.difficulty,
    this.description,
    this.lessonCount,
    this.grammarSummary,
    this.knowledgeList,
  });

  CourseUnitTargetEntity.fromJson(Map<String, dynamic> json) {
    specialty = json['specialty']?.toString();
    moduleId = json['moduleId']?.toInt();
    moduleName = json['moduleName']?.toString();
    moduleTopic = json['moduleTopic']?.toString();
    moduleCoverUrl = json['moduleCoverUrl']?.toString();
    moduleContentInfo = (json['moduleContentInfo'] != null)
        ? SpeciaityPhonicsModelDataModuleContentInfo.fromJson(
            json['moduleContentInfo'],
          )
        : null;
    unitId = json['unitId']?.toInt();
    unitName = json['unitName']?.toString();
    unitIndex = json['unitIndex']?.toInt();
    difficulty = json['difficulty'] != null
        ? CourseUnitTargetDifficultyEntity.fromJson(json['difficulty'])
        : null;
    description = json['description']?.toString();
    lessonCount = json['lessonCount']?.toInt();
    grammarSummary = (json['grammarSummary'] != null)
        ? CourseUnitTargetGrammarSummaryEntity.fromJson(json['grammarSummary'])
        : null;
    if (json['knowledgeList'] != null) {
      final v = json['knowledgeList'];
      final arr0 = <KnowledgeCommonEntityList>[];
      v.forEach((v) {
        arr0.add(KnowledgeCommonEntityList.fromJson(v));
      });
      knowledgeList = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['specialty'] = specialty;
    data['moduleId'] = moduleId;
    data['moduleName'] = moduleName;
    data['moduleTopic'] = moduleTopic;
    data['moduleCoverUrl'] = moduleCoverUrl;
    if (moduleContentInfo != null) {
      data['moduleContentInfo'] = moduleContentInfo!.toJson();
    }
    data['unitId'] = unitId;
    data['unitName'] = unitName;
    data['unitIndex'] = unitIndex;
    if (difficulty != null) {
      data['difficulty'] = difficulty!.toJson();
    }
    data['description'] = description;
    data['lessonCount'] = lessonCount;
    if (grammarSummary != null) {
      data['grammarSummary'] = grammarSummary!.toJson();
    }
    if (knowledgeList != null) {
      final v = knowledgeList;
      final arr0 = [];
      for (final item in v!) {
        arr0.add(item?.toJson());
      }
      data['knowledgeList'] = arr0;
    }
    return data;
  }
}

/// 单元难度区间信息。
class CourseUnitTargetDifficultyEntity {
  int? max;
  int? min;

  CourseUnitTargetDifficultyEntity({
    this.max,
    this.min,
  });

  CourseUnitTargetDifficultyEntity.fromJson(Map<String, dynamic> json) {
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

/// 语法概览信息，包含统计数据和多语言提纲。
class CourseUnitTargetGrammarSummaryEntity {
  int? totalCount;
  int? pendingReviewCount;
  List<LanguageText?>? outlinePoints;

  CourseUnitTargetGrammarSummaryEntity({
    this.totalCount,
    this.pendingReviewCount,
    this.outlinePoints,
  });

  CourseUnitTargetGrammarSummaryEntity.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount']?.toInt();
    pendingReviewCount = json['pendingReviewCount']?.toInt();
    if (json['outlinePoints'] != null) {
      final v = json['outlinePoints'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      outlinePoints = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['totalCount'] = totalCount;
    data['pendingReviewCount'] = pendingReviewCount;
    if (outlinePoints != null) {
      final v = outlinePoints;
      final arr0 = [];
      for (final item in v!) {
        arr0.add(item?.toJson());
      }
      data['outlinePoints'] = arr0;
    }
    return data;
  }
}
