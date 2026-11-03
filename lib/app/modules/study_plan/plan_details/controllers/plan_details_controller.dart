import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/widgets/guide_engine/guide_engine.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/tag_routes.dart';
import '../../../home/controllers/home_controller.dart';
import '../../../mission_control_center/controllers/mission_control_center_controller.dart';
import '../../../user_center/user_evaluation_level/controllers/user_evaluation_level_controller.dart' show UserEvaluationLevelController;
import '../../controllers/study_plan_controller.dart';
import '../views/plan_details_recommend_lesson_dialog.dart';
import '../views/plan_details_time_setting_dialog.dart';

class PlanDetailsController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  PlanDetailsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.PLAN_DETAILS;

  @override
  String get breadcrumbTitle => "编辑计划";

  // ========= 传进来的参数 =========
  /// 课程id
  int? courseId;
  /// 课程名称
  String? courseName;
  /// 课程类型
  String? specialty;
  /// 等级 要执行的等级 编辑计划和添加计划为null
  int tier = 0;
  /// 学期  要执行的学期 编辑计划和添加计划为null
  int semester = -1;
  /// 模块id  要执行的模块 编辑计划和添加计划为null
  int moduleId = -1;
  /// 计划step索引
  int? phaseIndex;
  /// 评测id
  int? assessmentId;
  /// 页面类型 0=编辑计划 1=执行计划 2=添加计划(空页面)
  int pageType = 0;


  // ========= 数据 =========

  // 计划列表
  final RxList<PlanEntityPlanPathCourses> planList = <PlanEntityPlanPathCourses>[].obs;

  /// 计划的uid
  final RxInt studyPlanUid = (-1).obs;
  /// 评估计划 0=不按照规划走 1=按照规划走
  final RxInt assessmentPlan = 0.obs;

  /// 计划的课程数据
  final Rx<PlanEntityPlanPathCoursesStudyPlanStartUnitInfo> planStartUnitInfo = PlanEntityPlanPathCoursesStudyPlanStartUnitInfo().obs;

  /// 计划可课时列表
  final RxList<LessonTypeEntityList> directionList = <LessonTypeEntityList>[].obs;

  /// 禁用题目数组
  final RxList<PlanEntityDisableExerciseTypeInfos> disableExerciseTypeInfos = <PlanEntityDisableExerciseTypeInfos>[].obs;

  /// 时间安排
  final Rx<PlanDetailsTimeSettingData> timeSettingData = PlanDetailsTimeSettingData(
    workWeekList: [1,2,3,4,5],
    workDuration: 15,
    workDurationRecommend: 15,
    restWeekList: [6,7],
    restDuration: 15,
    restDurationRecommend: 15,
  ).obs;

  /// 时间安排模块的 key
  final GlobalKey timeSettingDialogKey = GlobalKey();


  @override
  void onInit() {
    super.onInit();
    if(Get.arguments != null){
      courseId = Get.arguments["courseId"];
      courseName = Get.arguments["courseName"];
      specialty = Get.arguments["specialty"];
      tier = Get.arguments["tier"] ?? 0;
      semester = Get.arguments["semester"] ?? -1;
      moduleId = Get.arguments["moduleId"] ?? -1;
      phaseIndex = Get.arguments["phaseIndex"];
      assessmentId = Get.arguments["assessmentId"];
      pageType = Get.arguments["pageType"] ?? 0;

      if(specialty == SpecialtyEnum.EN_PHONICS){
        timeSettingData.value.restDurationRecommend = 5;
        timeSettingData.value.workDuration = 5;
        timeSettingData.value.workDurationRecommend = 5;
        timeSettingData.value.restDuration = 5;
      }

    }

    initBreadcrumb(tagText, title: "${courseName??''}计划");
    initData();
  }

  Future<void> initData() async{
    try {
      ToastUtils.showLoading();

      GuideTaskController.to.loadTasks(pageCode: AppRoutesCode.planDetails);
      
      if(pageType == 0){
        await getPlanList();
        getCurrentPlanData();
      }else if(pageType == 1){
        await getPlanPlanList();
        await getRecommendPlanList();
      } else if(pageType == 2){
        getModuleList(courseId);
      }
    } finally{
      ToastUtils.hideLoading();
    }

    GuideTaskController.to.start(AppRoutesCode.planDetails);
  }

  /// 查询现有计划
  Future<void> getPlanList() async{
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCoursePlanPathInfo)) {
      return;
    }
    try {
      PlanEntity? resp = await StudyPlanRequest.getPlanData();
      if(resp == null) return;
      assessmentPlan.value = resp.assessmentPlan??0;
      planList.clear();
      for(PlanEntityPlanPathCourses? item in resp.planPathCourses??[]){
        if(item == null) continue;
        planList.add(item);
      }
    } catch (_) {}
  }

  /// 查询规划计划
  Future<void> getPlanPlanList() async{
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.studyMemberCourseAssessmentDetailPlanV2)) {
      return;
    }
    if(assessmentId == null) return;
    try {
      AiAssessmentResultDetailEntity? resp = await PracticeQuestionsReqest.getAiAssessmentResultDetail(assessmentId!);
      if(resp == null) return;
      // assessmentPlan.value = resp.base.assessmentPlan??0;
      planList.clear();
      for(PlanEntityPlanPathCourses? item in resp.base.planPathCourses??[]){
        if(item == null) continue;
        planList.add(item);
      }
      assessmentPlan.value = 1;
    } catch (_) {}
  }

  /// 获取计划详情
  Future<void> getCurrentPlanData() async{
    PlanEntityPlanPathCourses? currentPlan = planList.firstWhereOrNull((element) => element.courseId == courseId);
    if(currentPlan == null) return;
    PlanEntityPlanPathCoursesStudyPlan? studyPlan = currentPlan.studyPlan;
    if(studyPlan == null) return;
    studyPlanUid.value = studyPlan.uid??-1;
    PlanEntityPlanPathCoursesStudyPlanStartUnitInfo? startUnitInfo = studyPlan.startUnitInfo;
    if(startUnitInfo == null) return;

    directionList.clear();
    for(LessonTypeEntityList? item in studyPlan.directionList??[]){
      if(item == null) continue;
      directionList.add(item);
    }

    disableExerciseTypeInfos.clear();
    for(PlanEntityDisableExerciseTypeInfos? item in studyPlan.disableExerciseTypeInfos??[]){
      if(item == null) continue;
      disableExerciseTypeInfos.add(item);
    }

    timeSettingData.value.isHolidaySwitch = studyPlan.holidayAdjustment??false;

    List<PlanEntityPlanPathCoursesStudyPlanPlans?> planReminders = studyPlan.plans??[];
  
    // 工作日
    PlanEntityPlanPathCoursesStudyPlanPlans? workPlan = planReminders.firstWhereOrNull((element) => element?.isRest != true);
    if(workPlan != null){
      timeSettingData.value.workWeekList = workPlan.weeks?.cast<int>()??[];
      timeSettingData.value.workDuration = ((workPlan.dailyStudyDuration??0) / 60).toInt();
      List<PlanEntityPlanPathCoursesStudyPlanPlansTimes?> times = workPlan.times??[];
      List<DateTime> workTimes = [];
      for(PlanEntityPlanPathCoursesStudyPlanPlansTimes? time in times){
        if(time == null) continue;
        DateTime? dt = DateTime.now().copyWith(hour: time.hour, minute: time.minute);
        workTimes.add(dt);
      }
      timeSettingData.value.workReminderTimeList = workTimes;
    }

    // 休息日
    PlanEntityPlanPathCoursesStudyPlanPlans? restPlan = planReminders.firstWhereOrNull((element) => element?.isRest == true);
    if(restPlan != null){
      timeSettingData.value.restWeekList = restPlan.weeks?.cast<int>()??[];
      timeSettingData.value.restDuration = ((restPlan.dailyStudyDuration??0) / 60).toInt();
      List<PlanEntityPlanPathCoursesStudyPlanPlansTimes?> times = restPlan.times??[];
      List<DateTime> restTimes = [];
      for(PlanEntityPlanPathCoursesStudyPlanPlansTimes? time in times){
        if(time == null) continue;
        DateTime? dt = DateTime.now().copyWith(hour: time.hour, minute: time.minute);
        restTimes.add(dt);
      }
      timeSettingData.value.restReminderTimeList = restTimes;
    }
    timeSettingData.refresh();

    await getCourseModuleInfo(levelId: startUnitInfo.levelId, moduleId: startUnitInfo.moduleId, unitId: startUnitInfo.unitId);

  }


  /// 查询推荐计划
  Future<void> getRecommendPlanList() async{
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.courseTierUnit)) return;

    PlanEntityPlanPathCourses? currentPlan = planList.firstWhereOrNull((element) => element.courseId == courseId);
    if(currentPlan == null) return;
    List<StudyPlanCardStepModel?> steps = currentPlan.steps??[];
    StudyPlanCardStepModel? currentStep;
    if(specialty == SpecialtyEnum.EN_PHONICS){
      if(steps.isNotEmpty){
        currentStep = steps.first;
      }
    }else{
      currentStep = steps.firstWhereOrNull((e) {
        if(moduleId != -1){
          return e?.tierRange?.min == tier && e?.moduleId == moduleId;
        }
        return e?.tierRange?.min == tier;
      });
    }

    if(currentStep != null) {
      directionList.clear();
      for(LessonTypeEntityList? item in currentStep.directionList??[]){
        if(item == null) continue;
        directionList.add(item);
      }
      timeSettingData.value.workDuration = ((currentStep.dailyStudyDuration??0) / 60).toInt();
      timeSettingData.value.restDuration = ((currentStep.dailyStudyDuration??0) / 60).toInt();
      timeSettingData.value.workDurationRecommend = ((currentStep.dailyStudyDuration??0) / 60).toInt();
      timeSettingData.value.restDurationRecommend = ((currentStep.dailyStudyDuration??0) / 60).toInt();
      timeSettingData.refresh();
    }

    if(courseId == null || assessmentPlan.value == 0) return;
    try {
      StudyPlanStartUnitEntity? res = await StudyPlanRequest.getCourseModuleStartUnit(courseId!, tier, semester, moduleId);
      if(res == null) return;

      await getCourseModuleInfo(levelId: res.levelId, moduleId: res.moduleId, unitId: res.unitId);
      
    } catch (_) {}
  }

  /// 根据课程等级模块单元id查询课程信息
  Future<void> getCourseModuleInfo({
    int? levelId,
    int? moduleId,
    int? unitId,
  }) async{
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseModuleUnitLessonInfos)){
      ToastUtils.showToast(text: "无权限");
      return;
    }
    if(courseId == null || levelId == null || moduleId == null || unitId == null) return;
    try {
      List<String> includeDirections = [];
      for (int i = 0; i < directionList.length; i++) {
        if (directionList[i].direction == null) continue;
        if(directionList[i].exclude == true) continue;
        includeDirections.add(directionList[i].direction!);
      }

      List<String> disableExerciseTypes = [];
      for(PlanEntityDisableExerciseTypeInfos item in disableExerciseTypeInfos){
        if(item.exerciseType == null) continue;
        disableExerciseTypes.add(item.exerciseType!);
      }

      List<Map<String, dynamic>> plans = getPlanTimeSettingParams();
      Map<String, dynamic> reqData = {
        "list": [{
          "courseId": courseId,
          "levelId": levelId,
          "moduleId": moduleId,
          "unitId": unitId,
          "plans": plans,
          "includeDirections": includeDirections,
          "disableExerciseTypes": disableExerciseTypes,
        }],
      };
      List<PlanEntityPlanPathCoursesStudyPlanStartUnitInfo>? res = await CourseUtil.getCourseModuleInfo(data: reqData);
      if(res == null) return;
      if(res.isEmpty) return;
      planStartUnitInfo.value = res.first;
      planStartUnitInfo.refresh();
    } finally{
      
    }
  }

  /// 滚动相应的模块
  void scrollToModule(GlobalKey key){
    // 确保下一帧
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 确保 key 存在
      if (key.currentContext == null) return;
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: Duration(milliseconds: 300),
      );
    });
  }


  /// 切换课程
  Future<void> switchCourse(BuildContext context) async{
    if(courseId == null) return GuideTaskController.to.stop();
    dynamic resStart;
    if(specialty == SpecialtyEnum.EN_PHONICS){
      if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCoursePhonicsLevelList)) {
        ToastUtils.showToast(text: "无权限");
        return;
      }
      resStart = await TagRoutes.toNamed(
        Routes.PHONICS_COURSE,
        arguments: {
          "courseId": courseId,
          "isSelectModule": true, // 是否是选择
          "showUnit": true,
          "isSelectThisModule": false,
          "createStudyPlan": true,
        },
      );
    }else{
      if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseLevelModuleUnitList)) {
        ToastUtils.showToast(text: "无权限");
        return;
      }
      resStart = await TagRoutes.toNamed(
        Routes.OFFICIAL_COURSE_DETAILS_LEVEL,
        arguments: {
          "courseId": courseId,
          "showUnit": true,
          "showRecommend": true,
          "isFromCustomCourse": true,
          "scrollToStudyZoneEnum": StudyZoneEnum.study,
          "isFromStudyPlan": true,
          "scrollToLevelId": planStartUnitInfo.value.levelId,
        },
      );
    }
    if (resStart == null) return;
    Map resMap = resStart;

    if (assessmentPlan.value == 1) {
      bool assessment = await coursePlanUnitValidateAssessment(resMap);
      if(!assessment){
        if(Get.context != null) {
          var res = await AskDialog.showUserAsk(context: Get.context!, title: "温馨提示", content: "更改计划后，系统将不再推荐计划");
          if (!res) return;
          assessmentPlan.value = 0;
        }
      }
    } 

    await getCourseModuleInfo(levelId: resMap['levelId'], moduleId: resMap['moduleId'], unitId: resMap['unitId']);

    GuideTaskController.to.continueGuide(AppRoutesCode.planDetails, GuideWidgetIds.planDetailsSwitchCourseButton);

  }

  /// 获取课程下的课时类型
  Future<void> getModuleList(int? cid) async {
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseLessonDirectionAllList)) return;
    if (cid == null) return;
    try {
      Map<String, dynamic> params = {
        "courseId": cid,
      };
      LessonTypeEntity? entity = await StudyPlanRequest.getLessonTypeList(params);
      if (entity == null) return;
      List<LessonTypeEntityList?> list = entity.list ?? [];
      List<LessonTypeEntityList> respList = [];
      for (var item in list) {
        if (item == null) continue;
        respList.add(item);
      }
      directionList.value = respList;
    } finally {}
  }

  /// 判断单元修改是否满足条件
  Future<bool> coursePlanUnitValidateAssessment(Map map) async{
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCoursePlanCourseUnitValidateAssessment)) {
      ToastUtils.showToast(text: "无权限");
      return false;
    }
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "courseId": map['courseId'],
        "levelId": map['levelId'],
        "moduleId": map['moduleId'],
        "unitId": map['unitId'],
        "assessmentId": assessmentId,
        "phaseIndex": phaseIndex,
      };
      bool res = await StudyPlanRequest.coursePlanUnitValidateAssessment(map['courseId'], data: reqData);
      return res;
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 选择课时
  void selectLesson(LessonTypeEntityList item){
    if(item.exclude != true){
      if(item.forceSelect){
        ToastUtils.showToast(text: "必须包含此课时");
        return;
      }
      // 最少选择一个
      int selectCount = 0;
      for (final lesson in directionList) {
        if (lesson.exclude == true) continue;
        selectCount++;
      }
      if (selectCount <= 1) {
        ToastUtils.showToast(text: "最少选择一个课时");
        return;
      }
    }else{
      String? direction = item.direction;
      if(direction != null){
        // 删除 必须包含的禁用题目
        disableExerciseTypeInfos.removeWhere((e) => e.requiredLessons?.contains(direction) == true);
      }
    }
    item.exclude = !(item.exclude??false);
    directionList.refresh();
    getCourseModuleInfo(
      levelId: planStartUnitInfo.value.levelId, 
      moduleId: planStartUnitInfo.value.moduleId, 
      unitId: planStartUnitInfo.value.unitId,
    );
  }


  /// 课时推荐场景
  Future<void> recommendScene(BuildContext context) async{
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseLessonDirectionAllList)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }

    if(courseId == null) return GuideTaskController.to.stop();
    List<String> selectDirectionList = [];
    for(LessonTypeEntityList item in directionList){
      if(item.exclude == true) continue;
      if(item.direction == null) continue;
      selectDirectionList.add(item.direction!);
    }
    List<LessonTypeEntityList>? result = await PlanDetailsRecommendLessonDialog.show(
      context: context,
      courseId: courseId!,
      initDirections: selectDirectionList,
      specialty: specialty,
    );
    if(result == null) return;
    directionList.value = result;
    directionList.refresh();

    GuideTaskController.to.continueGuide(AppRoutesCode.planDetails, GuideWidgetIds.planDetailsRecommendSceneButton);
  }

  /// 去选择题型页面
  Future<void> goSelectExerciseType() async{
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseDirectionExerciseCategoryList)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }

    if(courseId == null) return GuideTaskController.to.stop();

    List<String> selectDirectionList = [];

    for(LessonTypeEntityList item in directionList){
      if(item.exclude == true) continue;
      if(item.direction == null) continue;
      selectDirectionList.add(item.direction!);
    }

    List<String> disableExerciseTypes = [];
    for(PlanEntityDisableExerciseTypeInfos item in disableExerciseTypeInfos){
      if(item.exerciseType == null) continue;
      disableExerciseTypes.add(item.exerciseType!);
    }

    dynamic res = await TagRoutes.toNamed(
      Routes.PLAN_EXERCISE_SETTING,
      arguments: {
        "courseId": courseId,
        "directionList": selectDirectionList,
        "disabledExerciseTypes": disableExerciseTypes,
      },
    );
    if(res == null) return;
    List<PlanEntityDisableExerciseTypeInfos> respData = res?.cast<PlanEntityDisableExerciseTypeInfos>()??[];

    disableExerciseTypeInfos.value = respData;

    getCourseModuleInfo(
      levelId: planStartUnitInfo.value.levelId, 
      moduleId: planStartUnitInfo.value.moduleId, 
      unitId: planStartUnitInfo.value.unitId,
    );

    GuideTaskController.to.continueGuide(AppRoutesCode.planDetails, GuideWidgetIds.planDetailsDisableExerciseButton);

  }


  /// 调整时间安排弹窗
  Future<void> showTimeSettingDialog(BuildContext context) async{
    PlanDetailsTimeSettingData? result = await PlanDetailsTimeSettingDialog.show(
      context: context,
      initData: timeSettingData.value,
    );
    if(result == null) return;
    timeSettingData.value = result;

    getCourseModuleInfo(
      levelId: planStartUnitInfo.value.levelId, 
      moduleId: planStartUnitInfo.value.moduleId, 
      unitId: planStartUnitInfo.value.unitId,
    );

    GuideTaskController.to.continueGuide(AppRoutesCode.planDetails, GuideWidgetIds.planDetailsAdjustTimeButton);
  }

  /// 删除计划
  Future<void> deletePlan(BuildContext context) async{
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCoursePlanCourseDelete)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }
    
    if(courseId == null || studyPlanUid.value == -1) return;
    
    bool delRes = await DeleteDialog.show(
      context: context,
      title: "删除学习计划",
      subTitle: "你确定要删除 ${courseName??''} 学习计划吗？",
      content: "提示：此操作不可逆！",
      subContent: "删除计划不再安排后续课程内容，但是之前的学过的知识点记录不会删除，超级记忆会继续推荐。确定删除计划么？",
    );

    if (!delRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "planId": studyPlanUid.value,
        "clean": 0, // 删除后 原来的学习进度不会被删除
      };
      bool res = await StudyPlanRequest.deletePlan(courseId!, parameters);
      if (!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      final todayPlanControllers = TagRoutes.finds<StudyPlanController>(Routes.STUDY_PLAN);
      if (todayPlanControllers.isNotEmpty) {
        for (final c in todayPlanControllers) {
          c.initData();
        }
      }
      final userEvaluationLevelControllers = TagRoutes.finds<UserEvaluationLevelController>(Routes.USER_EVALUATION_LEVEL);
      if (userEvaluationLevelControllers.isNotEmpty) {
        for (final c in userEvaluationLevelControllers) {
          c.getAssessmentResultDetail();
        }
      }
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().initHomeCardList();
      }
      final missionController = TagRoutes.findLast<MissionControlCenterController>(Routes.MISSION_CONTROL_CENTER);
      if (missionController != null) {
        missionController.getTaskMission(showLoading: false);
      }
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 获取时间安排的参数
  List<Map<String, dynamic>> getPlanTimeSettingParams(){
    List<DateTime> workReminderTimeList = timeSettingData.value.workReminderTimeList??[];
    List<DateTime> restReminderTimeList = timeSettingData.value.restReminderTimeList??[];

    List<Map<String, dynamic>> werkMapList = [];

    for (int i = 0; i < workReminderTimeList.length; i++) {
      werkMapList.add({
        "hour": workReminderTimeList[i].hour,
        "minute": workReminderTimeList[i].minute,
      });
    }
    List<Map<String, dynamic>> holidayMapList = [];
    
    for (int i = 0; i < restReminderTimeList.length; i++) {
      holidayMapList.add({
        "hour": restReminderTimeList[i].hour,
        "minute": restReminderTimeList[i].minute,
      });
    }

    List<Map<String, dynamic>> plans = [];
    List<int> weekdayWeeks = timeSettingData.value.workWeekList??[];
    List<int> holidayWeeks = timeSettingData.value.restWeekList??[];
    plans.add({
      "type": "work",
      "weeks": weekdayWeeks.toList(),
      "times": werkMapList,
      "dailyStudyDuration": (timeSettingData.value.workDuration??0) * 60,
    });
    plans.add({
      "type": "rest",
      "weeks": holidayWeeks.toList(),
      "times": holidayMapList,
      "dailyStudyDuration": (timeSettingData.value.restDuration??0) * 60,
    });

    return plans;
  }

  /// 获取计划进度信息
  Future<PlanEntityPlanPathCoursesStudyPlanStartUnitInfo?> getPlanUnitProgress(List<String> includeDirections, List<String> disableExerciseTypes) async{
    
    try {
      ToastUtils.showLoading();
      if (courseId == null) return null;
      Map<String, dynamic> reqData = {
        "includeDirections": includeDirections,
        "disableExerciseTypes": disableExerciseTypes,
        "startUnit": {
          "levelId": planStartUnitInfo.value.levelId,
          "moduleId": planStartUnitInfo.value.moduleId,
          "unitId": planStartUnitInfo.value.unitId,
        },
      };
      PlanEntityPlanPathCoursesStudyPlanStartUnitInfo? res = await StudiesRequest.getPlanProgress(courseId!, data: reqData);
      if (res == null) return null;
      return res;
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 保存计划
  Future<void> savePlan(BuildContext context) async{
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.manageCoursePlanCreateEdit)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }

    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCoursePlanCourseStartPreview)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }

    if (courseId == null) return GuideTaskController.to.stop();
    if (planStartUnitInfo.value.unitId == null) {
      GuideTaskController.to.stop();
      return ToastUtils.showToast(text: "请先选择课程");
    }
    /// 是否是发音课
    bool isPhonics = specialty == SpecialtyEnum.EN_PHONICS;
    if(!isPhonics){
      if(directionList.isEmpty){
        GuideTaskController.to.stop();
        return ToastUtils.showToast(text: "请选择课时");
      }
    }

    List<String> includeDirections = [];
    for (int i = 0; i < directionList.length; i++) {
      if (directionList[i].direction == null) continue;
      if(directionList[i].exclude == true) continue;
      includeDirections.add(directionList[i].direction!);
    }

    List<String> disableExerciseTypes = [];
    for(PlanEntityDisableExerciseTypeInfos item in disableExerciseTypeInfos){
      if(item.exerciseType == null) continue;
      disableExerciseTypes.add(item.exerciseType!);
    }

    PlanEntityPlanPathCoursesStudyPlanStartUnitInfo? currentUnit = await getPlanUnitProgress(includeDirections, disableExerciseTypes);
    if(currentUnit != null && currentUnit.unitId != planStartUnitInfo.value.unitId){
      bool unitAsk = await AskDialog.showUserAsk(
        context: Get.context ?? context,
        title: "温馨提示",
        content: "当前设置的单元和课时已经学习完毕，当前设置计划将从【${currentUnit.moduleName} - ${currentUnit.unitName}】开始。",
        define: "继续保存",
        cancel: "返回调整",
      );
      if (!unitAsk) return GuideTaskController.to.stop();
    }

    if(pageType == 0){
      bool tipAskRes = await AskDialog.showUserAsk(
        context: Get.context ?? context,
        title: "温馨提示",
        content: "修改计划今日任务会重新计算发下，是否确认保存。",
        define: "保存",
        cancel: "取消",
      );
      if (!tipAskRes) return GuideTaskController.to.stop();
    }

    List<DateTime> workReminderTimeList = timeSettingData.value.workReminderTimeList??[];
    List<DateTime> restReminderTimeList = timeSettingData.value.restReminderTimeList??[];
    if (workReminderTimeList.isEmpty && restReminderTimeList.isEmpty) {
      if(Get.context != null) {
        bool askRes = await AskDialog.showUserAsk(
          context: Get.context!,
          title: "温馨提示",
          content: "建议打开学习提醒，及时接收计划提醒，学习更高效不拖延！",
          define: "继续保存",
          cancel: "返回调整",
        );
        if (!askRes) {
          scrollToModule(timeSettingDialogKey);
          return GuideTaskController.to.stop();
        }
      }
    }

    if (workReminderTimeList.isNotEmpty || restReminderTimeList.isNotEmpty) {
      if(Get.context != null) {
        await PermissionUtils.notification(Get.context!);
      }
    }

    List<Map<String, dynamic>> plans = getPlanTimeSettingParams();

    

    Map<String, dynamic> reviewLimitData = {
      "language": Get.find<ConfigController>().userSetting.value.learningLang,
      "enable": true, // 是否开启超记
      "limit": 0, // 0=无限制 超记的复习限制
    };

    Map<String, dynamic> courseData = {
      "courseId": courseId,
      "phaseIndex": phaseIndex,
      "holidayAdjustment": timeSettingData.value.isHolidaySwitch, // 智能把节假日当作休息日
      "plans": plans,
      "startUnit": {
        "levelId": planStartUnitInfo.value.levelId,
        "moduleId": planStartUnitInfo.value.moduleId,
        "unitId": planStartUnitInfo.value.unitId,
      },
    };
    if(!isPhonics){ // 非是发音课，需要添加课时和禁用的题型
      courseData['includeDirections'] = includeDirections;
      courseData['disableExerciseTypes'] = disableExerciseTypes;
    }

    Map<String, dynamic> data = {
      "superMemo": true, //超级记忆
      "goldRatio": true, //黄金学练
      "reviewLimit": reviewLimitData,
      "courses": [courseData],
    };

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "assessmentId": assessmentId,
        "assessment": assessmentPlan.value,
      };
      bool res = await StudyPlanRequest.createStudyPlan(data: data, parameters: parameters);
      if (!res) return GuideTaskController.to.stop();

      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().initHomeCardList();
      }
      final todayPlanControllers = TagRoutes.finds<StudyPlanController>(Routes.STUDY_PLAN);
      if (todayPlanControllers.isNotEmpty) {
        for (final c in todayPlanControllers) {
          await c.initData();
        }
      }
      final userEvaluationLevelControllers = TagRoutes.finds<UserEvaluationLevelController>(Routes.USER_EVALUATION_LEVEL);
      if (userEvaluationLevelControllers.isNotEmpty) {
        for (final c in userEvaluationLevelControllers) {
          c.getAssessmentResultDetail();
        }
      }
      final missionController = TagRoutes.findLast<MissionControlCenterController>(Routes.MISSION_CONTROL_CENTER);
      if (missionController != null) {
        missionController.getTaskMission(showLoading: false);
      }

      Get.back(result: true);
      GuideTaskController.to.continueGuide(AppRoutesCode.planDetails, GuideWidgetIds.planDetailsSavePlanButton);
    } finally {
      ToastUtils.hideLoading();
    }

  }
  


  @override
  void onClose() {
    super.onClose();
  }
}
