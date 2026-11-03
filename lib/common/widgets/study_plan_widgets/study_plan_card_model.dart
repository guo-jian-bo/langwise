



import '../../entities/entities.dart';
import '../../enum/enum.dart';
import 'study_plan_status_enum.dart';

class StudyPlanCardModel {

  /// 课程id
  int? courseId;

  /// 评测id
  int? assessmentId;

  /// 课程类型 [SpecialtyEnum]
  String specialty;

  /// 课程计划状态
  StudyCourseStatusEnum? courseStatus;

  /// 计划暂停后 恢复时间
  String? resumeDate;

  /// 课程计划步骤
  List<StudyPlanCardStepModel?> steps;

  /// 计划当前的进度
  String? currentUnitInfoText;

  /// 下一个单元的描述
  String? nextUnitInfoText;

  /// 计划信息
  PlanEntityPlanPathCoursesStudyPlan? studyPlan;

  String? get courseName {
    return SpecialtyEnum.getCourseName(specialty);
  }

  SpecialtyColor get courseColor => SpecialtyEnum.getCourseColor(specialty);

  StudyPlanCardModel({
    this.courseId,
    required this.assessmentId,
    required this.steps,
    required this.specialty,
    this.courseStatus,
    this.studyPlan,
    this.resumeDate,
    this.currentUnitInfoText,
    this.nextUnitInfoText,
  });
}


