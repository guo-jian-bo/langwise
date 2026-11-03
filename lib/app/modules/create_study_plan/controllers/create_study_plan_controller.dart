import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/today_plan/controllers/today_plan_controller.dart';
import 'package:langwise/app/modules/user_center/user_evaluation_level/controllers/user_evaluation_level_controller.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/stores/user.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../../home/controllers/home_controller.dart';
import '../../mission_control_center/controllers/mission_control_center_controller.dart';
import '../../specialty/controllers/specialty_controller.dart';

class CreateStudyPlanController extends GetxController {
  /// 传进来的参数 是否校验计划列表 如果已有计划 那么刷新首页 关闭当前页面跳转至计划列表页面
  bool isVerificationPlanList = false;

  /// 传进来的起始单元信息 如果有 那么自动 加一个课程
  /// "courseId": courseId,
  /// "courseName": courseLevel.value.name,
  /// "moduleId": module.moduleId,
  /// "moduleName": module.name,
  /// "levelId" : level.levelId,
  /// "levelName" : level.name,
  /// "unitId": unitId,
  /// "unitName": unitName,
  /// "difficulty": difficulty,
  /// 初始化数据
  Map<String, dynamic>? initStartUnit;

  final PageController pageController = PageController(viewportFraction: 0.4);
  final RxDouble currentPageIndex = 0.0.obs;

  /// 已经有计划的课程id
  final RxList<int> hasReminderCourseIds = <int>[].obs;

  /// 选择的课程的类型
  final RxString specialty = "".obs;

  /// 课程id
  final RxInt courseId = (-1).obs;

  /// 课程名称
  final RxString courseName = "".obs;

  /// 课程起点-等级id
  final RxInt planLevelId = (-1).obs;

  /// 课程起点-等级名称
  final RxString planLevelName = "".obs;

  /// 课程起点-模块id
  final RxInt planModuleId = (-1).obs;

  /// 课程起点-模块名称
  final RxString planModuleName = "".obs;

  /// 课程起点-单元id
  final RxInt planUnitId = (-1).obs;

  /// 课程起点-单元名称
  final RxString planUnitName = "".obs;

  /// 是否显示选择学习模块卡片
  final RxBool isShowSelectLessonType = false.obs;

  /// 每日学习时长
  final RxInt dailyStudyDuration = 15.obs;

  /// 需要的练习时长
  final RxInt exerciseDuration = 0.obs;

  /// 需要的天数
  final RxInt nextUnitDay = 0.obs;

  /// 下一个单元
  final RxString nextUnit = "".obs;

  /// 选择的学习模块
  final RxList<LessonTypeEntityList> selectLessonTypeList = <LessonTypeEntityList>[].obs;
  final RxList<LessonTypeEntityList> allLessonTypeList = <LessonTypeEntityList>[].obs;

  /// 是否显示学习提醒卡片
  final RxBool isShowLearningReminder = false.obs;

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

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      isVerificationPlanList = Get.arguments["isVerificationPlanList"] ?? false;
      initStartUnit = Get.arguments["initStartUnit"];
    }
    getPlanList();
    pageController.addListener(() {
      currentPageIndex.value = pageController.page ?? 0;
    });

    setInitCourseAndStartPosition();
  }

  /// 获取学习计划列表
  Future<void> getPlanList() async {
    try {
      ToastUtils.showLoading();
      StudyPlanEntity? studyPlanEntity = await StudyPlanRequest.getStudyPlanList();
      if (studyPlanEntity == null) return;
      List<StudyPlanEntityPlanCourses?> planCourses = studyPlanEntity.planCourses ?? [];
      for (int i = 0; i < planCourses.length; i++) {
        if (planCourses[i] == null) continue;
        if (planCourses[i]!.courseId == null) continue;
        hasReminderCourseIds.add(planCourses[i]!.courseId!);
      }
      // 首次进入页面　如果有计划 那么跳转至 今日计划 页面
      if (planCourses.isNotEmpty && isVerificationPlanList) {
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().initHomeCardList();
        }
        Get.offAndToNamed(Routes.TODAY_PLAN);
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 设置初始课程及起点
  Future<void> setInitCourseAndStartPosition({bool isPush = true}) async {
    if (initStartUnit == null) return;
    courseId.value = initStartUnit!['courseId'];
    courseName.value = initStartUnit!['courseName'];
    planLevelId.value = initStartUnit!['levelId'];
    planLevelName.value = initStartUnit!['levelName'];
    planModuleId.value = initStartUnit!['moduleId'];
    planModuleName.value = initStartUnit!['moduleName'];
    planUnitId.value = initStartUnit!['unitId'];
    planUnitName.value = initStartUnit!['unitName'];
    isShowSelectLessonType.value = false;
    isShowLearningReminder.value = false;
    isVerificationPlanList = false;

    List<LessonTypeEntityList>? moduleList = await getModuleList(courseId.value);
    if (moduleList != null) {
      selectLessonTypeList.value = moduleList;
      allLessonTypeList.value = moduleList;
    }
    await getCourseStartDuration();
    if (isPush) return;
    pageController.jumpToPage(0);
  }

  /// 去评测
  Future<void> goToEvaluate(BuildContext context) async {
    await PracticeQuestionsReqest.startToAssessment(context);
  }

  /// 选择课程 及 起始位置
  Future<void> selectCourseAndStartPosition(BuildContext context) async {
    JoinedCoursesEntity? resCourse = await SelectCourseDialog.show(
      context: context,
      initCourseId: courseId.value,
      disableCourseIds: hasReminderCourseIds,
    );
    if (resCourse == null) return;
    if (resCourse.courseId == null) return;

    specialty.value = resCourse.specialty ?? "";
    dynamic resStart;
    if (resCourse.specialty == SpecialtyEnum.EN_PHONICS) {
      resStart = await Get.toNamed(
        Routes.PHONICS_COURSE,
        arguments: {
          "courseId": resCourse.courseId,
          "isSelectModule": true, // 是否是选择
          "showUnit": true,
          "isSelectThisModule": false,
        },
      );
      if (resStart == null) return;
    } else {
      /// 选择起始位置
      resStart = await Get.toNamed(
        Routes.OFFICIAL_COURSE_DETAILS_LEVEL,
        arguments: {
          "courseId": resCourse.courseId,
          "showUnit": true,
          "showRecommend": true,
          "scrollToStudyZoneEnum": StudyZoneEnum.study,
          "isFromStudyPlan": true,
          "scrollToLevelId":
              courseId.value == resCourse.courseId && planLevelId.value != -1
                  ? planLevelId.value
                  : null,
        },
      );
      if (resStart == null) return;

      if (courseId.value != resCourse.courseId) {
        List<LessonTypeEntityList>? moduleList = await getModuleList(resCourse.courseId);
        if (moduleList != null) {
          selectLessonTypeList.value = moduleList;
          allLessonTypeList.value = moduleList;
        }
      }
    }

    courseId.value = resCourse.courseId!;
    courseName.value = resCourse.courseName ?? "";
    Map resMap = resStart;
    planLevelId.value = resMap['levelId'] ?? -1;
    planLevelName.value = resMap['levelName'] ?? "";
    planModuleId.value = resMap['moduleId'] ?? -1;
    planModuleName.value = resMap['moduleName'] ?? "";
    planUnitId.value = resMap['unitId'] ?? -1;
    planUnitName.value = resMap['unitName'] ?? "";
    getCourseStartDuration();
  }

  /// 获取课程下的课时类型
  Future<List<LessonTypeEntityList>?> getModuleList(int? cid) async {
    if (cid == null) return null;
    try {
      Map<String, dynamic> params = {
        "courseId": cid,
      };
      LessonTypeEntity? entity = await StudyPlanRequest.getLessonTypeList(params);
      if (entity == null) return null;
      List<LessonTypeEntityList?> list = entity.list ?? [];
      List<LessonTypeEntityList> respList = [];
      for (var item in list) {
        if (item == null) continue;
        respList.add(item);
      }
      return respList;
    } finally {}
  }

  /// 获取课程模块的题目和时长
  Future<void> getCourseStartDuration() async {
    if (courseId.value == -1) return;
    if (planLevelId.value == -1) return;
    if (planModuleId.value == -1) return;
    if (planUnitId.value == -1) return;
    Map<String, dynamic> reqData = {
      "unitId": planUnitId.value,
      "duration": dailyStudyDuration.value * 60,
      "includeDirections": selectLessonTypeList.map((e) => e.direction).toList(),
    };
    CourseModuleStartDurationEntity? entity = await StudyPlanRequest.getCourseModuleStartDuration(
      courseId.value,
      planLevelId.value,
      planModuleId.value,
      reqData,
    );
    if (entity == null) return;

    exerciseDuration.value = entity.exerciseDuration ?? 0;
    nextUnitDay.value = entity.nextUnitDay ?? 0;
    nextUnit.value = entity.nextUnit ?? "";
  }

  /// 选择每日学习时长
  Future<void> selectDailyStudyDuration(BuildContext context) async {
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
    if (res == null) return;
    dailyStudyDuration.value = res;
  }

  /// 创建学习计划-选择课程的继续按钮
  Future<void> continueAddCourse(BuildContext context) async {
    if (courseId.value == -1) {
      ToastUtils.showToast(text: "请先选择课程");
      return;
    }

    if (UserStore.to.userInfo.value.assessmentTier == null) {
      bool? res = await AskDialog.showUserCancelAsk(
        context: context,
        title: "推荐先评测水平",
        content: "评测后我们会根据你的水平，推荐更合适的学习计划。",
        cancel: "跳过评测，继续创建",
        define: "去评测",
      );
      if (res == null) return;
      if (res) {
        goToEvaluate(context);
        return;
      }
    }

    if (specialty.value != SpecialtyEnum.EN_PHONICS) {
      bool res = await selectLessonType();
      if (!res) return;
    }

    isShowSelectLessonType.value = true;
    pageController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.linear);
  }

  /// 选择学习模块
  Future<bool> selectLessonType() async {
    if (courseId.value == -1) {
      ToastUtils.showToast(text: "请先选择课程");
      return false;
    }
    List<String> lessonTypeDirections = [];
    for (var item in selectLessonTypeList) {
      if (item.direction == null) continue;
      lessonTypeDirections.add(item.direction!);
    }

    dynamic res = await Get.toNamed(
      Routes.SELECT_LEARNING_MODULE,
      arguments: {
        "courseId": courseId.value,
        "title": "选择课时类型",
        "initDirections": lessonTypeDirections,
      },
    );
    if (res == null) return false;
    List<LessonTypeEntityList> list = res;
    selectLessonTypeList.value = list;
    getCourseStartDuration();

    return true;
  }

  /// 选择学习模块卡片继续按钮
  Future<void> continueAddLessonType() async {
    isShowLearningReminder.value = true;
    pageController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.linear);
  }

  /// 保存
  Future<void> save(BuildContext context) async {
    // for(int i = 0; i < courseList.length; i++){
    //   if(courseList[i].learningReminderSwitch.value) continue;
    //     bool askRes = await AskDialog.showUserAsk(
    //       context: context,
    //       title: "温馨提示",
    //       content: "建议打开学习提醒，及时接收计划提醒，学习更高效不拖延！",
    //       define: "去打开",
    //       cancel: "继续保存",
    //     );
    //     if(askRes){
    //       await pageController.animateToPage(
    //         i + (continueAddCourse ? 0 : 1),
    //         duration: const Duration(milliseconds: 300),
    //         curve: Curves.linear,
    //       );
    //       changeLearningReminder(true, i, context);
    //       return;
    //     }
    // }

    // List<Map<String, dynamic>> courses = [];
    // for (var element in courseList) {

    //   if(!element.learningReminderSwitch.value){
    //     element.holidayAdjustment.value = false;
    //     element.werkDayList.clear();
    //     element.holidayDayList.clear();
    //   }

    //   List<DateTime> werkDayList = element.werkDayList;
    //   List<Map<String, dynamic>> werkMapList = [];
    //   for(int i = 0; i < werkDayList.length; i++){
    //     werkMapList.add({
    //       "hour": werkDayList[i].hour,
    //       "minute": werkDayList[i].minute,
    //     });
    //   }
    //   List<DateTime> holidayDayList = element.holidayDayList;
    //   List<Map<String, dynamic>> holidayMapList = [];
    //   for(int i = 0; i < holidayDayList.length; i++){
    //     holidayMapList.add({
    //       "hour": holidayDayList[i].hour,
    //       "minute": holidayDayList[i].minute,
    //     });
    //   }

    //   List<Map<String, dynamic>> plans = [];
    //   if(werkMapList.isNotEmpty){
    //     plans.add({
    //       "type": "work",
    //       "weeks": element.werkWeeks,
    //       "times": werkMapList,
    //     });
    //   }
    //   if(holidayMapList.isNotEmpty){
    //     plans.add({
    //       "type": "rest",
    //       "weeks": element.holidayDaWeeks,
    //       "times": holidayMapList,
    //     });
    //   }

    //   List<String> selectTypeIds = [];
    //   for(int i = 0; i < element.selectLessonTypeList.length; i++){
    //     if(element.selectLessonTypeList[i].direction == null) continue;
    //     selectTypeIds.add(element.selectLessonTypeList[i].direction!);
    //   }

    //   List<String> includeDirections = [];
    //   for(int i = 0; i < element.selectLessonTypeList.length; i++){
    //     if(element.selectLessonTypeList[i].direction == null) continue;
    //     includeDirections.add(element.selectLessonTypeList[i].direction!);
    //   }

    //   courses.add({
    //     "tier": element.tier,
    //     "courseId": element.course?.courseId,
    //     // "difficulty": element.languageLevel?.level,
    //     "dailyStudyDuration": element.dailyStudyDuration.value * 60, // 每日学习时长
    //     "holidayAdjustment": element.holidayAdjustment.value, // 智能把节假日当作休息日
    //     "plans": plans,
    //     "includeDirections": includeDirections,
    //     "startUnit": {
    //       "levelId": element.planLevelId,
    //       "moduleId": element.planModuleId,
    //       "unitId": element.planUnitId,
    //     },
    //   });
    // }

    if (werkDayList.isEmpty && holidayDayList.isEmpty) {
      bool askRes = await AskDialog.showUserAsk(
        context: context,
        title: "温馨提示",
        content: "建议打开学习提醒，及时接收计划提醒，学习更高效不拖延！",
        define: "继续保存",
        cancel: "返回调整",
      );
      if (!askRes) return;
    }

    if (werkDayList.isNotEmpty || holidayDayList.isNotEmpty) {
      await PermissionUtils.notification(context);
    }

    List<Map<String, dynamic>> werkMapList = [];
    for (int i = 0; i < werkDayList.length; i++) {
      werkMapList.add({
        "hour": werkDayList[i].hour,
        "minute": werkDayList[i].minute,
      });
    }

    List<Map<String, dynamic>> holidayMapList = [];
    for (int i = 0; i < holidayDayList.length; i++) {
      holidayMapList.add({
        "hour": holidayDayList[i].hour,
        "minute": holidayDayList[i].minute,
      });
    }

    List<Map<String, dynamic>> plans = [];
    if (werkMapList.isNotEmpty) {
      plans.add({
        "type": "work",
        "weeks": werkWeeks.toList(),
        "times": werkMapList,
      });
    }
    if (holidayMapList.isNotEmpty) {
      plans.add({
        "type": "rest",
        "weeks": holidayDaWeeks.toList(),
        "times": holidayMapList,
      });
    }

    List<String> includeDirections = [];
    for (int i = 0; i < selectLessonTypeList.length; i++) {
      if (selectLessonTypeList[i].direction == null) continue;
      includeDirections.add(selectLessonTypeList[i].direction!);
    }

    Map<String, dynamic> reviewLimitData = {
      "language": Get.find<ConfigController>().userSetting.value.learningLang,
      "enable": true,
      "limit": 0, // 0=无限制
    };

    Map<String, dynamic> data = {
      "superMemo": true, //超级记忆
      "goldRatio": true, //黄金学练
      "reviewLimit": reviewLimitData,
      "courses": [
        {
          "tier": UserStore.to.userInfo.value.assessmentTier,
          "courseId": courseId.value,
          // "difficulty": element.languageLevel?.level,
          "dailyStudyDuration": dailyStudyDuration.value * 60, // 每日学习时长
          "holidayAdjustment": holidayAdjustment.value, // 智能把节假日当作休息日
          "plans": plans,
          "includeDirections": includeDirections,
          "startUnit": {
            "levelId": planLevelId.value,
            "moduleId": planModuleId.value,
            "unitId": planUnitId.value,
          },
        }
      ],
    };
    try {
      ToastUtils.showLoading();
      bool res = await StudyPlanRequest.createStudyPlan(data);
      if (!res) return;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().initHomeCardList();
      }
      if (Get.isRegistered<SpecialtyController>()) {
        await Get.find<SpecialtyController>().initHomeCardList();
      }
      if (Get.isRegistered<UserEvaluationLevelController>()) {
        Get.find<UserEvaluationLevelController>().getAssessmentResultDetail();
      }
      if (Get.isRegistered<MissionControlCenterController>()) {
        await Get.find<MissionControlCenterController>().getTaskMission(showLoading: false);
      }

      if (Get.isRegistered<TodayPlanController>()) {
        // 路由堆栈中有计划列表页面 刷新计划列表后返回到计划列表页面
        await Get.find<TodayPlanController>().initData();
        Get.until((route) => route.settings.name == Routes.TODAY_PLAN);
      } else {
        // 路由堆栈中没有计划列表页面 关闭当前页面跳转至计划列表页面
        Get.offAndToNamed(Routes.TODAY_PLAN);
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
