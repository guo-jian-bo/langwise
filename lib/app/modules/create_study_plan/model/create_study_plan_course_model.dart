import 'package:get/get.dart';
import 'package:langwise/common/stores/user.dart';

import '../../../../common/entities/entities.dart';

class CreateStudyPlanCourseModel{
  /// 课程名称
  JoinedCoursesEntity? course;
  /// 语言水平
  int? tier = UserStore.to.userInfo.value.assessmentTier;
  /// 计划起点 levelId
  int? planLevelId;
  String? planLevelName;
  /// 计划起点moduleId
  int? planModuleId;
  String? planModuleName;
  /// 计划起点unitId
  int? planUnitId;
  String? planUnitName;

  /// 练习次数
  int? exerciseCount;
  /// 练习时长
  int? exerciseDuration;

  /// 下一单元
  String? nextUnit;
  /// 下一单元天数
  int? nextUnitDay;

  /// 选择的课时类型
  final RxList<LessonTypeEntityList> selectLessonTypeList = <LessonTypeEntityList>[].obs;

  /// 全部的课时类型
  final RxList<LessonTypeEntityList> allLessonTypeList = <LessonTypeEntityList>[].obs;

  /// 每日学习时长 分钟
  final RxInt dailyStudyDuration = 0.obs;
  final RxInt learningDurationSelectIndex = 0.obs;
  /// 学习提醒
  final RxBool learningReminderSwitch = false.obs;
  /// 工作日
  final RxList<DateTime> werkDayList = <DateTime>[].obs;
  /// 休息日
  final RxList<DateTime> holidayDayList = <DateTime>[].obs;
  /// 工作日的周
  final RxList<int> werkWeeks = <int>[].obs;
  /// 休息日的周
  final RxList<int> holidayDaWeeks = <int>[].obs;
  /// 智能把节假日当作休息日
  final RxBool holidayAdjustment = false.obs;

}