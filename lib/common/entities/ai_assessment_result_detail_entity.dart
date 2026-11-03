import 'package:langwise/app/modules/specialty/model/speciaity_default_phonics_model.dart';

import 'card_public_entity.dart';
import 'assessment_result_detail_entity.dart';

class AiAssessmentResultDetailEntity {
  final AssessmentResultDetailEntity base;
  final bool? isPlan;
  final String? report;
  final bool? isZeroBased;
  final String? lastAssessment;
  final AiAssessmentPlanEntity? plan;
  final bool? validAssessmentPlan;

  AiAssessmentResultDetailEntity({
    required this.base,
    this.isPlan,
    this.report,
    this.plan,
    this.lastAssessment,
    this.isZeroBased,
    this.validAssessmentPlan,
  });

  factory AiAssessmentResultDetailEntity.fromJson(Map<String, dynamic> json) {
    return AiAssessmentResultDetailEntity(
      base: AssessmentResultDetailEntity.fromJson(json),
      isPlan: json['isPlan'],
      report: json['report']?.toString(),
      isZeroBased: json['isZeroBased']??false,
      lastAssessment: json['lastAssessment']?.toString(),
      plan: json['plan'] == null ? null : AiAssessmentPlanEntity.fromJson(json['plan']),
      validAssessmentPlan: json['validAssessmentPlan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...base.toJson(),
      'isPlan': isPlan,
      'report': report,
      'isZeroBased': isZeroBased,
      'lastAssessment': lastAssessment,
      'plan': plan?.toJson(),
      'validAssessmentPlan': validAssessmentPlan,
    };
  }
}

class AiAssessmentPlanEntity {
  final List<AiAssessmentPlanCardEntity> official;
  final List<AiAssessmentPlanCardEntity> textbook;
  final List<AiAssessmentPlanCardEntity> phonics;

  const AiAssessmentPlanEntity({
    this.official = const [],
    this.textbook = const [],
    this.phonics = const [],
  });

  factory AiAssessmentPlanEntity.fromJson(Map<String, dynamic> json) {
    List<AiAssessmentPlanCardEntity> parseList(dynamic v) {
      if (v is! List) return const [];
      return v.whereType<Map<String, dynamic>>().map(AiAssessmentPlanCardEntity.fromJson).toList();
    }

    return AiAssessmentPlanEntity(
      official: parseList(json['official']),
      textbook: parseList(json['textbook']),
      phonics: parseList(json['phonics']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'official': official.map((e) => e.toJson()).toList(),
      'textbook': textbook.map((e) => e.toJson()).toList(),
      'phonics': phonics.map((e) => e.toJson()).toList(),
    };
  }
}

class AiAssessmentPlanCardEntity {
  final String? name;
  final String? description;
  final int? courseId;
  final int? semester;
  final int? levelId;
  final String? levelName;
  final int? moduleId;
  final int? unitId;
  final List<SpeciaityDefaultPhonicsModelDataModuleInfoList> moduleInfoList;
  final List<AiAssessmentPlanDirectionEntity> directionList;
  final AiAssessmentTierRangeEntity? tierRange;
  final int? dailyStudyDuration;
  final String? status;
  final AiAssessmentPlanTriggerEntity? trigger;

  const AiAssessmentPlanCardEntity({
    this.name,
    this.description,
    this.courseId,
    this.semester,
    this.levelId,
    this.levelName,
    this.moduleId,
    this.unitId,
    this.moduleInfoList = const [],
    this.directionList = const [],
    this.tierRange,
    this.dailyStudyDuration,
    this.status,
    this.trigger,
  });

  factory AiAssessmentPlanCardEntity.fromJson(Map<String, dynamic> json) {
    final rawDirections = json['directionList'];
    final rawModuleInfoList = json['moduleInfoList'];
    final modulueInfoList = <SpeciaityDefaultPhonicsModelDataModuleInfoList>[];
    if (rawModuleInfoList is List) {
      for (final item in rawModuleInfoList) {
        if (item is Map<String, dynamic>) {
          modulueInfoList.add(SpeciaityDefaultPhonicsModelDataModuleInfoList.fromJson(item));
        }
      }
    }
    final directions = <AiAssessmentPlanDirectionEntity>[];
    if (rawDirections is List) {
      for (final item in rawDirections) {
        if (item is Map<String, dynamic>) {
          directions.add(AiAssessmentPlanDirectionEntity.fromJson(item));
        }
      }
    }

    return AiAssessmentPlanCardEntity(
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      courseId: json['courseId']?.toInt(),
      semester: json['semester']?.toInt(),
      levelId: json['levelId']?.toInt(),
      levelName: json['levelName']?.toString(),
      moduleId: json['moduleId']?.toInt(),
      unitId: json['unitId']?.toInt(),
      moduleInfoList: modulueInfoList,
      directionList: directions,
      tierRange: json['tierRange'] == null ? null : AiAssessmentTierRangeEntity.fromJson(json['tierRange']),
      dailyStudyDuration: json['dailyStudyDuration']?.toInt(),
      status: json['status'],
      trigger: json['trigger']==null?null:AiAssessmentPlanTriggerEntity.fromJson(json['trigger'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'courseId': courseId,
      'semester':semester,
      'levelId': levelId,
      'levelName': levelName,
      'moduleId': moduleId,
      'unitId': unitId,
      'directionList': directionList.map((e) => e.toJson()).toList(),
      'tierRange': tierRange?.toJson(),
      'dailyStudyDuration': dailyStudyDuration,
      'trigger':trigger?.toJson()
    };
  }
}

class AiAssessmentPlanDirectionEntity {
  final String? direction;
  final String? iconUrl;
  final List<LanguageText> title;
  final List<LanguageText> subtitle;
  final int? order;
  final bool? exclude;

  const AiAssessmentPlanDirectionEntity({
    this.direction,
    this.iconUrl,
    this.title = const [],
    this.subtitle = const [],
    this.order,
    this.exclude,
  });

  factory AiAssessmentPlanDirectionEntity.fromJson(Map<String, dynamic> json) {
    List<LanguageText> parseLangList(dynamic v) {
      if (v is! List) return const [];
      return v.whereType<Map<String, dynamic>>().map(LanguageText.fromJson).toList();
    }

    return AiAssessmentPlanDirectionEntity(
      direction: json['direction']?.toString(),
      iconUrl: json['iconUrl']?.toString(),
      title: parseLangList(json['title']),
      subtitle: parseLangList(json['subtitle']),
      order: json['order']?.toInt(),
      exclude: json['exclude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'direction': direction,
      'iconUrl': iconUrl,
      'title': title.map((e) => e.toJson()).toList(),
      'subtitle': subtitle.map((e) => e.toJson()).toList(),
      'order': order,
      'exclude': exclude,
    };
  }
}

class AiAssessmentTierRangeEntity {
  final int? max;
  final int? min;

  const AiAssessmentTierRangeEntity({this.max, this.min});

  factory AiAssessmentTierRangeEntity.fromJson(Map<String, dynamic> json) {
    return AiAssessmentTierRangeEntity(
      max: json['max']?.toInt(),
      min: json['min']?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'max': max,
      'min': min,
    };
  }

  bool containsTier(int tier) {
    final minV = min;
    final maxV = max;
    if (minV != null && tier < minV) return false;
    if (maxV != null && tier > maxV) return false;
    return true;
  }
}

class AiAssessmentPlanTriggerEntity {
  final String? type;
  final int? tier;

  const AiAssessmentPlanTriggerEntity({this.type, this.tier});

  factory AiAssessmentPlanTriggerEntity.fromJson(Map<String, dynamic> json) {
    return AiAssessmentPlanTriggerEntity(
      type: json['type']?.toString(),
      tier: json['tier']?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'tier': tier,
    };
  }
}


class AssessmentResponse {
  int? offset;
  int? limit;
  int? count;
  List<AiAssessmentHistoryEntity>? datas;

  AssessmentResponse({this.offset, this.limit, this.count, this.datas});

  factory AssessmentResponse.fromJson(Map<String, dynamic> json) => AssessmentResponse(
        offset: json["offset"]?.toInt(),
        limit: json["limit"]?.toInt(),
        count: json["count"]?.toInt(),
        datas: json["datas"] == null
            ? []
            : List<AiAssessmentHistoryEntity>.from(
                (json["datas"] as List).whereType<Map<String, dynamic>>().map((x) => AiAssessmentHistoryEntity.fromJson(x))),
      );
}

class AiAssessmentHistoryEntity {
  int? assessmentId;
  DateTime? assessmentDate;
  int? tier;
  String? cefr;
  List<AssessmentResultDetailEntityTierInfos?>? tierInfos;
  List<AssessmentResultDetailEntityTierSkills?>? tierSkills;

  AiAssessmentHistoryEntity({
    this.assessmentId,
    this.assessmentDate,
    this.tier,
    this.cefr,
    this.tierInfos,
    this.tierSkills,
  });

  AiAssessmentHistoryEntity.fromJson(Map<String, dynamic> json) {
    assessmentId = json['assessmentId']?.toInt();

    final dynamic rawDate = json['assessmentDate'];
    if (rawDate is DateTime) {
      assessmentDate = rawDate;
    } else if (rawDate is String) {
      assessmentDate = DateTime.tryParse(rawDate);
    } else if (rawDate != null) {
      assessmentDate = DateTime.tryParse(rawDate.toString());
    }

    tier = json['tier']?.toInt();
    cefr = json['cefr']?.toString();
    if (json['tierInfos'] != null) {
      final v = json['tierInfos'];
      final arr0 = <AssessmentResultDetailEntityTierInfos>[];
      v.forEach((v) {
        arr0.add(AssessmentResultDetailEntityTierInfos.fromJson(v));
      });
      tierInfos = arr0;
    }
    if (json['tierSkills'] != null) {
      final v = json['tierSkills'];
      final arr0 = <AssessmentResultDetailEntityTierSkills>[];
      v.forEach((v) {
        arr0.add(AssessmentResultDetailEntityTierSkills.fromJson(v));
      });
      tierSkills = arr0;
    }
  }
}
