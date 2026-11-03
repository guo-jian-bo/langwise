import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/public_controller/config_controller.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/widgets/learning_reminder_widget.dart';
import '../../../../../common/widgets/select_language_level_dialog.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../../../home/controllers/home_controller.dart';
import '../../../mission_control_center/controllers/mission_control_center_controller.dart';
import '../../controllers/today_plan_controller.dart';

class EditTodayPlanController extends GetxController {
  final ConfigController config = Get.find<ConfigController>();

  final DateTime now = DateTime.now();

  final Rx<DifficultieEntity> languageLevel = DifficultieEntity().obs;
 
  final Rx<StudyPlanEntityPlanCourses> course = StudyPlanEntityPlanCourses().obs;
  
  /// 计划起点 levelId
  final RxInt planLevelId = (-1).obs;
  final RxString planLevelName = "".obs;
  /// 计划起点moduleId
  final RxInt planModuleId = (-1).obs;
  final RxString planModuleName = "".obs;
  /// 计划起点unitId
  final RxInt planUnitId = (-1).obs;
  final RxString planUnitName = "".obs;

  /// 选择的课时类型
  final RxList<LessonTypeEntityList> selectLessonTypeList = <LessonTypeEntityList>[].obs;

  /// 全部的课时类型
  final RxList<LessonTypeEntityList> allLessonTypeList = <LessonTypeEntityList>[].obs;

  /// 题目总数
  final RxInt exerciseCount = 0.obs;
  /// 预计时长
  final RxInt exerciseDuration = 0.obs;
  /// 下一单元
  final RxString nextUnit = "".obs;
  /// 下一单元天数
  final RxInt nextUnitDay = 0.obs;

  /// 每日学习时长 分钟
  final RxInt dailyStudyDuration = 0.obs;
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

  final RxBool isDisable = true.obs;

  @override
  void onInit() {
    super.onInit();
    if(Get.arguments != null){
      course.value = Get.arguments;
      dailyStudyDuration.value = (course.value.dailyStudyDuration??0) ~/ 60;
      
      learningReminderSwitch.value = course.value.plans?.isNotEmpty??false;
      
      DifficultieEntity? diff = DifficultieUtils.getLanguageDifficultieLevel(config.appConfig.value, config.userSetting.value.learningLang, course.value.difficulty);
      if(diff != null){
        languageLevel.value = diff;
      }

      List<StudyPlanEntityPlanCoursesPlans?> plans = course.value.plans??[];

      List<DateTime> workDayList = [];
      List<int> workWeeks = [];
      List<DateTime> holidayList = [];
      List<int> holidayWeeks = [];
      for(int i = 0; i < plans.length; i++){
        if(plans[i] == null) continue;
        if(plans[i]!.type == "work"){
          List<StudyPlanEntityPlanCoursesPlansTimes?> times = plans[i]!.times??[];
          workDayList = times.map((e) {
            return DateTime(now.year, now.month, now.day, e?.hour??0, e?.minute??0);
          }).toList();
          workWeeks = (plans[i]!.weeks??[]).map((e) => e??0).toList();
        }else if(plans[i]!.type == "rest"){
          List<StudyPlanEntityPlanCoursesPlansTimes?> times = plans[i]!.times??[];
          holidayList = times.map((e) {
            return DateTime(now.year, now.month, now.day, e?.hour??0, e?.minute??0);
          }).toList();
          holidayWeeks = (plans[i]!.weeks??[]).map((e) => e??0).toList();
        }
      }
      
      werkDayList.value = workDayList;
      holidayDayList.value = holidayList;
      werkWeeks.value = workWeeks;
      holidayDaWeeks.value = holidayWeeks;
      holidayAdjustment.value = course.value.holidayAdjustment??false;

      planLevelId.value = course.value.startUnitInfo?.levelId??(-1);
      planLevelName.value = course.value.startUnitInfo?.levelName??"";
      planModuleId.value = course.value.startUnitInfo?.moduleId??(-1);
      planModuleName.value = course.value.startUnitInfo?.moduleName??"";
      planUnitId.value = course.value.startUnitInfo?.unitId??(-1);
      planUnitName.value = course.value.startUnitInfo?.unitName??"";

      getModuleList();

      getButtonDisable();
    }
  }

  /// 获取课程下的课时类型
  Future<void> getModuleList() async{
    if(course.value.courseId == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> params = {
        "courseId": course.value.courseId,
      };
      LessonTypeEntity? entity = await StudyPlanRequest.getLessonTypeList(params);
      if(entity == null) return;
      List<LessonTypeEntityList?> list = entity.list??[];
      List<LessonTypeEntityList> respList = [];
      for(var item in list){
        if(item == null) continue;
        respList.add(item);
      }
      allLessonTypeList.value = respList;

      List<LessonTypeEntityList?> directionList = course.value.includeDirectionList??[];
      for(int i = 0; i < directionList.length; i++){
        if(directionList[i] == null) continue;
        selectLessonTypeList.add(directionList[i]!);
      }

      if(selectLessonTypeList.isEmpty){
        selectLessonTypeList.value = allLessonTypeList;
      }

      await getCourseModuleStartDuration();

    } finally{
      ToastUtils.hideLoading();
    }
  }

  LessonTypeEntityList getLessonTypeEntityList(String direction){
    return allLessonTypeList.firstWhere((element) => element.direction == direction);
  }

  void getButtonDisable(){
    if(course.value.courseId == null
      || planLevelId.value == -1
      || planModuleId.value == -1
      || planUnitId.value == -1){
        isDisable.value = true;
        return; 
      }

    // if(course.value.courseId == null){
    //     isDisable.value = true;
    //     return; 
    //   }
      
    isDisable.value = false;
  }

  /// 选择语言水平
  Future<void> selectLanguageLevel(BuildContext context) async{
    DifficultieEntity? res = await SelectLanguageLevelDialog.show(
      context: context,
      init: languageLevel.value,
    );
    if(res == null) return;
    languageLevel.value = res;
    getButtonDisable();
  }

  /// 选择计划起点
  Future<void> selectPlanStart() async{
    if(course.value.courseId == null){
      return ToastUtils.showToast(text: "请先选择课程");
    }
    dynamic resStart;

    if(course.value.startUnitInfo?.specialty == SpecialtyEnum.EN_PHONICS){

      resStart = await Get.toNamed(
        Routes.PHONICS_COURSE,
        arguments: {
          "courseId": course.value.courseId,
          "isSelectModule": true, // 是否是选择
          "showUnit": true,
          "isSelectThisModule": false,
        },
      );
      
    }else{
      resStart = await Get.toNamed(
        Routes.OFFICIAL_COURSE_DETAILS_LEVEL,
        arguments: {
          "courseId": course.value.courseId,
          "showUnit": true,
          "showRecommend": true,
          "scrollToStudyZoneEnum": StudyZoneEnum.study,
        },
      );
    }
    if (resStart == null) return;
    Map resMap = resStart;
    planLevelId.value = resMap['levelId']??(-1);
    planLevelName.value = resMap['levelName']??(-1);
    planModuleId.value = resMap['moduleId']??(-1);
    planModuleName.value = resMap['moduleName']??(-1);
    planUnitId.value = resMap['unitId']??(-1);
    planUnitName.value = resMap['unitName']??(-1);

    getCourseModuleStartDuration();
    getButtonDisable();

  }

  /// 选择学习时长
  Future<void> selectLearningDuration(BuildContext context) async {
    List<PlanSettingDurationModel> durationList = [
      PlanSettingDurationModel(name: "适用零基础", minute: 10, color: AppTheme.cTextSecondary.color),
      PlanSettingDurationModel(name: "官方推荐", minute: 15, color: AppTheme.cFeedbackInfoText.color),
      PlanSettingDurationModel(name: "不要超过", minute: 30, color: AppTheme.cFeedbackErrorText.color),
    ];
    int? res = await PlanSettingDurationDialog.show(
      context: context,
      initMinute: dailyStudyDuration.value,
      durationList: durationList,
      maxMinute: 60,
      minMinute: 5,
    );
    if(res == null) return;
    dailyStudyDuration.value = res;
    getCourseModuleStartDuration();
  }

  /// 选择学习模块
  Future<void> selectLearningModule() async{
    if(course.value.courseId == null) return;

    List<String> skipLessonTypeDirections = [];
    for(var item in selectLessonTypeList){
      if(item.direction == null) continue;
      skipLessonTypeDirections.add(item.direction!);
    }

    dynamic res = await Get.toNamed(
      Routes.SELECT_LEARNING_MODULE,
      arguments: {
        "courseId": course.value.courseId,
        "title": "选择课时类型",
        "initDirections": skipLessonTypeDirections,
      },
    );
    if(res == null) return;
    List<LessonTypeEntityList> list = res;
    selectLessonTypeList.value = list;

    getCourseModuleStartDuration();

  }

  /// 获取课程模块的题目和时长
  Future<void> getCourseModuleStartDuration() async{
    if(course.value.courseId == null) return;
    if(planModuleId.value == -1) return;
    if(planLevelId.value == -1) return;
    if(planUnitId.value == -1) return;
    Map<String, dynamic> reqData = {
      "unitId": planUnitId.value,
      "duration": dailyStudyDuration.value * 60,
      "includeDirections": selectLessonTypeList.map((e) => e.direction).toList(),
    };
    CourseModuleStartDurationEntity? entity = await StudyPlanRequest.getCourseModuleStartDuration(
      course.value.courseId!, 
      planLevelId.value,
      planModuleId.value, 
      reqData,
    );
    if(entity == null) return;
    exerciseCount.value = entity.exerciseCount??0;
    exerciseDuration.value = entity.exerciseDuration??0;
    nextUnit.value = entity.nextUnit??"";
    nextUnitDay.value = entity.nextUnitDay??0;

  }


  /// 学习提醒的开关
  Future<void> changeLearningReminder(bool val, BuildContext context) async {
    if (!val) {
      learningReminderSwitch.value = val;
      return;
    }
    await PermissionUtils.notification(context);
    if (holidayDayList.isEmpty && werkDayList.isEmpty) {
      await showLearningReminderWindow(context);
    } else {
      learningReminderSwitch.value = val;
    }
  }

  /// 显示学习提醒添加时间的弹窗
  Future<void> showLearningReminderWindow(BuildContext context) async {
    LearningReminderDialog.show(
      context: context,
      initHolidayAdjustment: holidayAdjustment.value,
      initRestWeeks: holidayDaWeeks.toList(),
      initWerkWeeks: werkWeeks.toList(),
      initWorkDay: werkDayList.toList(),
      initHolidayDay: holidayDayList.toList(),
      onTap: (weekDay, holidayDay, workWeekList, restWeekList, holiday) {
        holidayAdjustment.value = holiday;
        werkDayList.value = weekDay;
        holidayDayList.value = holidayDay;
        werkWeeks.value = workWeekList;
        holidayDaWeeks.value = restWeekList;
        if (holidayDayList.isNotEmpty || werkDayList.isNotEmpty) {
          learningReminderSwitch.value = true;
        } else {
          learningReminderSwitch.value = false;
        }
      },
    );
  }

  /// 删除计划
  Future<void> deletePlan(BuildContext context) async{
    if(course.value.courseId == null) return;
    if(course.value.uid == null) return;

    bool res = await DeleteDialog.show(
      context: context, 
      title: "删除学习计划",
      subTitle: "你确定要删除 ${course.value.courseName??''} 学习计划吗？",
      content: "提示：此操作不可逆！",
      subContent: "删除计划不再安排后续课程内容，但是之前的学过的知识点记录不会删除，超级记忆会继续推荐。确定删除计划么？",
    );

    if(!res) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "planId": course.value.uid,
        "clean": 0, // 删除后 原来的学习进度不会被删除
      };
      bool res2 = await StudyPlanRequest.deletePlan(course.value.courseId!, parameters);
      if(!res2) return;
      if(Get.isRegistered<TodayPlanController>()){
        await Get.find<TodayPlanController>().initData();
      }
      if(Get.isRegistered<HomeController>()){
        await Get.find<HomeController>().initHomeCardList();
      }
      if(Get.isRegistered<MissionControlCenterController>()){
        await Get.find<MissionControlCenterController>().getTaskMission(showLoading: false);
      }
      ToastUtils.showToast(text: "删除成功");
      Get.back();
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 保存
  Future<void> save(BuildContext context) async{
    if(course.value.courseId == null) return;
    if(planLevelId.value == -1 || planModuleId.value == -1 || planUnitId.value == -1){
      return ToastUtils.showToast(text: "请先选择计划起点");
    }
    

    if(!learningReminderSwitch.value){
      bool askRes = await AskDialog.showUserAsk(
        context: context,
        title: "温馨提示",
        content: "建议打开学习提醒，及时接收计划提醒，学习更高效不拖延！",
        define: "去打开",
        cancel: "继续保存",
      );
      if(askRes){
        changeLearningReminder(true, context);
        return;
      }

      holidayAdjustment.value = false;
      werkDayList.clear();
      holidayDayList.clear();
    }

    bool tipAskRes = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "修改计划今天任务会重新计算发下，是否确认保存。",
      define: "保存",
      cancel: "取消",
    );
    if(!tipAskRes) return;

    

    List<Map<String, dynamic>> werkMapList = [];
    for(int i = 0; i < werkDayList.length; i++){
      werkMapList.add({
        "hour": werkDayList[i].hour,
        "minute": werkDayList[i].minute,
      });
    }
    List<Map<String, dynamic>> holidayMapList = [];
    for(int i = 0; i < holidayDayList.length; i++){
      holidayMapList.add({
        "hour": holidayDayList[i].hour,
        "minute": holidayDayList[i].minute,
      });
    }
    
    List<Map<String, dynamic>> plans = [];
    if(werkMapList.isNotEmpty){
      plans.add({
        "type": "work",
        "weeks": werkWeeks.toList(),
        "times": werkMapList,
      });
    }
    if(holidayMapList.isNotEmpty){
      plans.add({
        "type": "rest",
        "weeks": holidayDaWeeks.toList(),
        "times": holidayMapList,
      });
    }

    List<String> includeDirections = [];
    for(int i = 0; i < selectLessonTypeList.length; i++){
      if(selectLessonTypeList[i].direction == null) continue;
      includeDirections.add(selectLessonTypeList[i].direction!);
    }

    Map<String, dynamic> data = {
      // "difficulty": languageLevel.value.level,
      "pause": course.value.pause,
      "dailyStudyDuration": dailyStudyDuration.value * 60, // 每日学习时长
      "holidayAdjustment": holidayAdjustment.value, // 智能把节假日当作休息日
      "plans": plans,
      "includeDirections": includeDirections,
      "startUnit": {
        "levelId": planLevelId.value,
        "moduleId": planModuleId.value,
        "unitId": planUnitId.value,
      },
    };

    try {
      ToastUtils.showLoading();
      bool res = await StudyPlanRequest.editPlan(course.value.courseId!, data);
      if(!res) return;
      ToastUtils.showToast(text: "修改成功", type: ToastType.success);
      if(Get.isRegistered<HomeController>()){
        await Get.find<HomeController>().initHomeCardList();
      }
      if(Get.isRegistered<MissionControlCenterController>()){
        await Get.find<MissionControlCenterController>().getTaskMission(showLoading: false);
      }
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}
