

import 'entities.dart';

class CoursePlanPathInfoEntity {
  final int? assessmentPlan;
  final bool? validAssessmentPlan;
  final String? validAssessmentExplain;
  final List<CoursePlanPathCourseEntity> planPathCourses;

  const CoursePlanPathInfoEntity({
    this.assessmentPlan,
    this.validAssessmentPlan,
    this.validAssessmentExplain,
    this.planPathCourses = const [],
  });

  factory CoursePlanPathInfoEntity.fromJson(Map<String, dynamic> json) {
    final raw = json['planPathCourses'];
    if (raw is! List) {
      return CoursePlanPathInfoEntity(assessmentPlan: json['assessmentPlan']?.toInt());
    }

    final items = <CoursePlanPathCourseEntity>[];
    for (final v in raw) {
      if (v is Map<String, dynamic>) {
        items.add(CoursePlanPathCourseEntity.fromJson(v));
      }
    }
    return CoursePlanPathInfoEntity(
      assessmentPlan: json['assessmentPlan']?.toInt(),
      validAssessmentPlan: json['validAssessmentPlan']??false,
      validAssessmentExplain: json['validAssessmentExplain']?.toString(),
      planPathCourses: items,
    );
  }
}

class CoursePlanPathCourseEntity {
  final int? courseId;
  final String? courseName;
  final String? type;
  final String? specialty;
  final int? assessmentPlan;  //当前是否是评测推荐计划
  final List<StudyPlanCardStepModel> steps;
  final StudyPlanEntityPlanCourses? studyPlan;
  final int? assessmentPlanStatus; //当前是否有可执行的计划
  final LockEntity? rights;

  const CoursePlanPathCourseEntity({
    this.courseId,
    this.courseName,
    this.type,
    this.specialty,
    this.assessmentPlan,
    this.steps = const [],
    this.studyPlan,
    this.assessmentPlanStatus,
    this.rights,
  });

  factory CoursePlanPathCourseEntity.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'];
    final steps = <StudyPlanCardStepModel>[];
    if (rawSteps is List) {
      for (final v in rawSteps) {
        if (v is Map<String, dynamic>) {
          steps.add(StudyPlanCardStepModel.fromJson(v));
        }
      }
    }

    return CoursePlanPathCourseEntity(
      courseId: json['courseId']?.toInt(),
      courseName: json['courseName']?.toString(),
      type: json['type']?.toString(),
      specialty: json['specialty']?.toString(),
      assessmentPlan: json['assessmentPlan']??0,
      steps: steps,
      studyPlan: json['studyPlan'] is Map<String, dynamic> ? StudyPlanEntityPlanCourses.fromJson(json['studyPlan']) : null,
      assessmentPlanStatus: json['assessmentPlanStatus']??0,
      rights: json['rights'] is Map<String, dynamic> ? LockEntity.fromJson(json['rights']) : null,
    );
  }
}

