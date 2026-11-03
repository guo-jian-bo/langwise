import 'package:langwise/app/modules/specialty/model/speciaity_default_phonics_model.dart';
import 'package:langwise/common/entities/ai_assessment_result_detail_entity.dart';
import 'package:langwise/common/entities/lock_entity.dart';
import 'package:langwise/common/entities/study_plan_entity.dart';

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
  final List<CoursePlanPathStepEntity> steps;
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
    final steps = <CoursePlanPathStepEntity>[];
    if (rawSteps is List) {
      for (final v in rawSteps) {
        if (v is Map<String, dynamic>) {
          steps.add(CoursePlanPathStepEntity.fromJson(v));
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

class CoursePlanPathStepEntity {
  final String? name;
  final String? description;
  final int? courseId;
  final int? moduleId;
  final int? semester;
  final int? levelId;
  final String? levelName;
  final List<AiAssessmentPlanDirectionEntity> directionList;
  final AiAssessmentTierRangeEntity? tierRange;
  final int? dailyStudyDuration;
  final String? status;
  final AiAssessmentPlanTriggerEntity? trigger;
  final List<SpeciaityDefaultPhonicsModelDataModuleInfoList> moduleInfoList;

  const CoursePlanPathStepEntity({
    this.name,
    this.description,
    this.courseId,
    this.moduleId,
    this.semester,
    this.levelId,
    this.levelName,
    this.directionList = const [],
    this.tierRange,
    this.dailyStudyDuration,
    this.status,
    this.trigger,
    this.moduleInfoList = const [],
  });

  factory CoursePlanPathStepEntity.fromJson(Map<String, dynamic> json) {
    final rawDirections = json['directionList'];
    final directions = <AiAssessmentPlanDirectionEntity>[];
    if (rawDirections is List) {
      for (final v in rawDirections) {
        if (v is Map<String, dynamic>) {
          directions.add(AiAssessmentPlanDirectionEntity.fromJson(v));
        }
      }
    }

    final rawModuleInfoList = json['moduleInfoList'];
    final moduleInfoList = <SpeciaityDefaultPhonicsModelDataModuleInfoList>[];
    if (rawModuleInfoList is List) {
      for (final v in rawModuleInfoList) {
        if (v is Map<String, dynamic>) {
          moduleInfoList.add(SpeciaityDefaultPhonicsModelDataModuleInfoList.fromJson(v));
        }
      }
    }

    return CoursePlanPathStepEntity(
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      courseId: json['courseId']?.toInt(),
      semester: json['semester']?.toInt(),
      moduleId: json['moduleId']?.toInt(),
      levelId: json['levelId']?.toInt(),
      levelName: json['levelName']?.toString(),
      directionList: directions,
      tierRange: json['tierRange'] == null ? null : AiAssessmentTierRangeEntity.fromJson(json['tierRange']),
      dailyStudyDuration: json['dailyStudyDuration']?.toInt(),
      status: json['status']?.toString(),
      moduleInfoList: moduleInfoList,
      trigger: json['trigger'] == null ? null : AiAssessmentPlanTriggerEntity.fromJson(json['trigger']),
    );
  }
}
