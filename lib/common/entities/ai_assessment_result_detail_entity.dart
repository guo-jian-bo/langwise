
import 'entities.dart';

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
  final List<StudyPlanCardStepModel> official;
  final List<StudyPlanCardStepModel> textbook;
  final List<StudyPlanCardStepModel> phonics;

  const AiAssessmentPlanEntity({
    this.official = const [],
    this.textbook = const [],
    this.phonics = const [],
  });

  factory AiAssessmentPlanEntity.fromJson(Map<String, dynamic> json) {
    List<StudyPlanCardStepModel> parseList(dynamic v) {
      if (v is! List) return const [];
      return v.whereType<Map<String, dynamic>>().map(StudyPlanCardStepModel.fromJson).toList();
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
