import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/create_study_plan/views/study_time_choose_dialog.dart';
import 'package:langwise/app/modules/today_plan/controllers/today_plan_controller.dart';
import 'package:langwise/app/modules/user_center/user_evaluation_level/controllers/user_evaluation_level_controller.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/date_time_picker_widget.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/utils.dart';
import '../../home/controllers/home_controller.dart';
import '../../mission_control_center/controllers/mission_control_center_controller.dart';
import '../../specialty/controllers/specialty_controller.dart';

class NewCreateStudyPlanController extends GetxController {
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

  ScrollController scrollController = ScrollController();

  List<String> weekList = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

  RxBool isEditMode = false.obs;

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

  /// 计划起点
  final RxInt sysModuleId = (-1).obs;

  /// 课程起点-模块名称
  final RxString planModuleName = "".obs;

  /// 课程起点-单元id
  final RxInt planUnitId = (-1).obs;

  /// 课程起点-单元名称
  final RxString planUnitName = "".obs;

  /// 自然拼读模块列表（最多12个）
  final RxList<PhonicsCourseLevelListModuleList> phonicsModules = <PhonicsCourseLevelListModuleList>[].obs;

  /// 是否显示选择学习模块卡片
  final RxBool isShowSelectLessonType = false.obs;

  /// 官方推荐时长
  final RxInt officialStudyDuration = 15.obs;

  /// 工作日学习时长
  final RxInt weekdayStudyDuration = 15.obs;

  /// 休息日学习时长
  final RxInt holidayStudyDuration = 15.obs;

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

  /// 工作日(00:00)
  final RxList<DateTime> weekdayList = <DateTime>[].obs;

  /// 休息日(00:00)
  final RxList<DateTime> holidayList = <DateTime>[].obs;

  /// 工作日的周(7-6)
  final RxList<int> weekdayWeeks = <int>[1, 2, 3, 4, 5].obs;

  /// 休息日的周(7-6)
  final RxList<int> holidayWeeks = <int>[0, 6].obs;

  /// 智能把节假日当作休息日
  final RxBool holidayAdjustment = true.obs;

  /// 是否是双休制
  final RxBool isDoubleRestDay = true.obs;

  /// 计划Id
  final RxInt planId = (-1).obs;
  String titleName = '';

  final RxInt tier = 0.obs;
  final RxInt semester = (-1).obs;
  final RxBool initPlan = false.obs;
  final RxInt assessmentPlan = 0.obs;
  final RxInt moduleId = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      List<AiAssessmentPlanDirectionEntity> directionList = Get.arguments['directionList'] ?? [];
      isVerificationPlanList = Get.arguments["isVerificationPlanList"] ?? false;
      for (var item in directionList) {
        LessonTypeEntityList lessonTypeEntityList = LessonTypeEntityList();
        lessonTypeEntityList.direction = item.direction;
        lessonTypeEntityList.iconUrl = item.iconUrl;
        lessonTypeEntityList.subtitle = item.subtitle;
        lessonTypeEntityList.title = item.title;
        lessonTypeEntityList.order = item.order;
        allLessonTypeList.add(lessonTypeEntityList);
        if (!(item.exclude ?? false)) {
          selectLessonTypeList.add(lessonTypeEntityList);
        }
      }
      if (Get.arguments['dailyStudyDuration'] != null) {
        var dailyStudyDuration = Get.arguments['dailyStudyDuration'] ?? 0;
        officialStudyDuration.value = dailyStudyDuration;
        weekdayStudyDuration.value = dailyStudyDuration;
        holidayStudyDuration.value = dailyStudyDuration;
      }
      if (Get.arguments['courseId'] != null) {
        courseId.value = Get.arguments['courseId'] ?? -1;
      }
      if (Get.arguments['titleName'] != null) {
        titleName = Get.arguments['titleName'] ?? '';
      }
      if (Get.arguments['specialty'] != null) {
        specialty.value = Get.arguments['specialty'] ?? '';
      }
      if (Get.arguments['tier'] != null) {
        tier.value = Get.arguments['tier'] ?? 0;
      }
      if (Get.arguments['semester'] != null) {
        semester.value = Get.arguments['semester'] ?? 0;
      }
      if (Get.arguments['initPlan'] != null) {
        initPlan.value = Get.arguments['initPlan'] ?? false;
      }
      if (Get.arguments['moduleId'] != null) {
        moduleId.value = Get.arguments['moduleId'] ?? -1;
      }
      if (Get.arguments['unitId'] != null) {
        planUnitId.value = Get.arguments['unitId'] ?? -1;
      }
    }
    initData();
  }

  initData() async {
    await setInitCourseAndStartPosition();

    if (initPlan.value) {
      assessmentPlan.value = 1;
      await initCourse();
    } else {
      await getPlanList();
    }
    

  }

  /// 设置初始课程及起点
  Future<void> initCourse() async {
    if (courseId.value == -1 || assessmentPlan.value == 0) return;
    var res = await StudyPlanRequest.getCourseModuleStartUnit(courseId.value, tier.value, semester.value, moduleId.value);
    if (res == null) {
      return;
    }

    courseId.value = res.courseId!;
    courseName.value = res.courseName ?? "";
    planLevelId.value = res.levelId ?? -1;
    planLevelName.value = res.levelName ?? "";
    planModuleId.value = res.moduleId ?? -1;
    sysModuleId.value = res.moduleId ?? -1;
    planModuleName.value = res.moduleName ?? "";
    planUnitId.value = res.unitId ?? -1;
    planUnitName.value = res.unitName ?? "";
  }

  bool _hasSameTime(List<DateTime> list, int hour, int minute, {int? excludeIndex}) {
    for (int i = 0; i < list.length; i++) {
      if (excludeIndex != null && excludeIndex == i) continue;
      if (list[i].hour == hour && list[i].minute == minute) return true;
    }
    return false;
  }

  DateTime _normalizeTime(DateTime time) {
    return DateTime(1970, 1, 1, time.hour, time.minute);
  }

  Future<void> addReminderTime({required RxList<DateTime> timeList}) async {
    final ctx = Get.context;
    if (ctx == null) return;

    final picked = await DateTimePickerUtils.showHM(context: ctx, initialDate: DateTime.now(), looping: true);
    if (picked == null) return;
    final normalized = _normalizeTime(picked);
    final list = timeList.toList();
    if (_hasSameTime(list, normalized.hour, normalized.minute)) {
      ToastUtils.showToast(text: '该时间已存在');
      return;
    }

    timeList.add(normalized);
    await scrollToBottom();
  }

  Future<void> editReminderTime({required RxList<DateTime> timeList, required int index}) async {
    final ctx = Get.context;
    if (ctx == null) return;

    final list = timeList.toList();
    if (index < 0 || index >= list.length) return;

    final picked = await DateTimePickerUtils.showHM(context: ctx, initialDate: list[index], looping: true);
    if (picked == null) return;
    if (_hasSameTime(list, picked.hour, picked.minute, excludeIndex: index)) {
      ToastUtils.showToast(text: '该时间已存在');
      return;
    }

    timeList[index] = _normalizeTime(picked);
    timeList.refresh();
  }

  Future<void> scrollToBottom() async {
    if (!scrollController.hasClients) return;
    await Future.delayed(const Duration(milliseconds: 60));
    if (!scrollController.hasClients) return;
    await scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  /// 获取学习计划列表
  Future<void> getPlanList() async {
    try {
      ToastUtils.showLoading();
      CoursePlanPathInfoEntity? studyPlanEntity = await StudyPlanRequest.getCoursePlanPathInfo();
      if (studyPlanEntity == null) return;
      List<CoursePlanPathCourseEntity?> planCourses = studyPlanEntity.planPathCourses;
      assessmentPlan.value = studyPlanEntity.assessmentPlan ?? 0;

      for (int i = 0; i < planCourses.length; i++) {
        if (planCourses[i] == null) continue;
        if (planCourses[i]?.courseId != null) {
          hasReminderCourseIds.add(planCourses[i]!.courseId!);
        }

        if (planCourses[i]!.courseId != courseId.value || planCourses[i]!.studyPlan == null) {
          continue;
        } else {
          isEditMode.value = true;
          var planCourse = planCourses[i]!.studyPlan;
          planId.value = planCourse?.uid ?? -1;
          allLessonTypeList.clear();
          selectLessonTypeList.clear();
          for (LessonTypeEntityList? dir in planCourse?.directionList ?? []) {
            allLessonTypeList.add(dir!);
            if (!(dir.exclude ?? false)) {
              selectLessonTypeList.add(dir);
            }
          }
          var mPlan = planCourse?.plans;
          var off = planCourses[i]?.steps.indexWhere((t) => t.status == 'RUNNING' || t.status == 'READY');
          if (off != -1) {
            officialStudyDuration.value = ((planCourses[i]?.steps[off ?? 0].dailyStudyDuration ?? 0) / 60).round();
          } else {
            officialStudyDuration.value = 15;
          }
          courseId.value = planCourse?.startUnitInfo?.courseId ?? -1;
          courseName.value = planCourse?.courseName ?? "";
          planLevelId.value = planCourse?.startUnitInfo?.levelId ?? -1;
          specialty.value = planCourse?.currentUnitInfo?.specialty ?? '';
          planLevelName.value = planCourse?.startUnitInfo?.levelName ?? "";
          planModuleId.value = planCourse?.startUnitInfo?.moduleId ?? -1;
          planModuleName.value = planCourse?.startUnitInfo?.moduleName ?? "";
          planUnitId.value = planCourse?.startUnitInfo?.unitId ?? -1;
          planUnitName.value = planCourse?.startUnitInfo?.unitName ?? "";
          // 回填学习提醒与学习时长
          holidayAdjustment.value = planCourse?.holidayAdjustment ?? true;

          StudyPlanEntityPlanCoursesPlans? workPlan;
          StudyPlanEntityPlanCoursesPlans? restPlan;
          for (final p in (mPlan ?? const <StudyPlanEntityPlanCoursesPlans?>[])) {
            if (p == null) continue;
            if (p.type == 'work') {
              workPlan = p;
            } else if (p.type == 'rest') {
              restPlan = p;
            }
          }

          List<int> normalizeWeeks(List<int?>? weeks) {
            final res = <int>[];
            for (final w in (weeks ?? const <int?>[])) {
              final v = w?.toInt();
              if (v == null) continue;
              res.add(v == 7 ? 0 : v);
            }
            return res;
          }

          List<DateTime> normalizeTimes(List<StudyPlanEntityPlanCoursesPlansTimes?>? times) {
            final res = <DateTime>[];
            for (final t in (times ?? const <StudyPlanEntityPlanCoursesPlansTimes?>[])) {
              if (t == null) continue;
              final h = t.hour ?? 0;
              final m = t.minute ?? 0;
              res.add(_normalizeTime(DateTime(2000, 1, 1, h, m)));
            }
            return res;
          }

          // weekdayWeeks/holidayWeeks：按 type 拆分并把 7 转成 0
          final workWeeks = normalizeWeeks(workPlan?.weeks);
          if (workWeeks.isNotEmpty) {
            weekdayWeeks.value = workWeeks;
          }
          final restWeeks = normalizeWeeks(restPlan?.weeks);
          if (restWeeks.isNotEmpty) {
            holidayWeeks.value = restWeeks;
          }

          // times：分别对应 weekdayList/holidayList
          final workTimes = normalizeTimes(workPlan?.times);
          weekdayList.value = workTimes;

          final restTimes = normalizeTimes(restPlan?.times);
          holidayList.value = restTimes;

          // 双休推导：仅当 work/rest 都存在时才尝试推断
          if (workPlan != null && restPlan != null) {
            isDoubleRestDay.value = weekdayWeeks.length == 5 && holidayWeeks.length == 2;
          }
          weekdayStudyDuration.value = ((workPlan?.dailyStudyDuration ?? 0) / 60).round();
          holidayStudyDuration.value = ((restPlan?.dailyStudyDuration ?? 0) / 60).round();
        }
      }
      if (selectLessonTypeList.isEmpty) {
        selectLessonTypeList.value = List.from(allLessonTypeList);
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

  Future<void> setInitCourseAndStartPosition() async {
    List<LessonTypeEntityList>? moduleList = await getModuleList(courseId.value);
    if (moduleList != null) {
      allLessonTypeList.value = List.from(moduleList);
    }
  }

  /// 去评测
  Future<void> goToEvaluate(BuildContext context) async {
    await PracticeQuestionsReqest.startToAssessment(context);
  }

  /// 选择课程 及 起始位置
  Future<void> selectCourseAndStartPosition(BuildContext context) async {
    // JoinedCoursesEntity? resCourse = await SelectCourseDialog.show(
    //   context: context,
    //   initCourseId: courseId.value,
    //   disableCourseIds: hasReminderCourseIds,
    // );
    // if (resCourse == null) return;
    // if (resCourse.courseId == null) return;

    // specialty.value = resCourse.specialty ?? "";
    dynamic resStart;
    if (specialty.value == SpecialtyEnum.EN_PHONICS) {
      resStart = await Get.toNamed(
        Routes.PHONICS_COURSE,
        arguments: {
          "courseId": courseId.value,
          "isSelectModule": true, // 是否是选择
          "showUnit": true,
          "isSelectThisModule": false,
          "createStudyPlan": true,
        },
      );
      if (resStart == null) return;
    } else {
      /// 选择起始位置
      resStart = await Get.toNamed(
        Routes.OFFICIAL_COURSE_DETAILS_LEVEL,
        arguments: {
          "courseId": courseId.value,
          "showUnit": true,
          "showRecommend": true,
          "scrollToStudyZoneEnum": StudyZoneEnum.study,
          "isFromStudyPlan": true,
        },
      );
      if (resStart == null) return;
    }
    Map resMap = resStart;

    /// 执行计划： 官方课程/教材 请求接口判断是否符合
    /// 编辑：

    // if (sysModuleId.value != resMap['moduleId'] && assessmentPlan.value == 1) {
    if (assessmentPlan.value == 1) {

      bool assessment = await coursePlanUnitValidateAssessment(resMap);
      if(!assessment){
        var res = await AskDialog.showUserAsk(context: context, title: "温馨提示", content: "更改计划后，系统将不再推荐计划");
        if (!res) return;
        assessmentPlan.value = 0;
      }
      
    } 
    planLevelId.value = resMap['levelId'] ?? -1;
    planLevelName.value = resMap['levelName'] ?? "";
    planModuleId.value = resMap['moduleId'] ?? -1;
    planModuleName.value = resMap['moduleName'] ?? "";
    planUnitId.value = resMap['unitId'] ?? -1;
    planUnitName.value = resMap['unitName'] ?? "";
    courseId.value = resMap['courseId'] ?? -1;
    courseName.value = resMap['courseName'] ?? '';
  }

  /// 判断单元修改是否满足条件
  Future<bool> coursePlanUnitValidateAssessment(Map map) async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "courseId": map['courseId'],
        "levelId": map['levelId'],
        "moduleId": map['moduleId'],
        "unitId": map['unitId'],
      };
      bool res = await StudyPlanRequest.coursePlanUnitValidateAssessment(map['courseId'], data: reqData);
      return res;
    } finally{
      ToastUtils.hideLoading();
    }
    
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

    return true;
  }

  /// 选择学习模块卡片继续按钮
  Future<void> continueAddLessonType() async {
    isShowLearningReminder.value = true;
  }

  /// 保存
  Future<void> save(BuildContext context) async {
    if (selectLessonTypeList.isEmpty&&specialty.value!=SpecialtyEnum.EN_PHONICS) {
      ToastUtils.showToast(text: "请先选择课时类型");
      return;
    }
    if (courseName.isEmpty) {
      ToastUtils.showToast(text: '请选择课程');
      return;
    }
    if (weekdayList.isEmpty && holidayList.isEmpty) {
      bool askRes = await AskDialog.showUserAsk(
        context: context,
        title: "温馨提示",
        content: "建议打开学习提醒，及时接收计划提醒，学习更高效不拖延！",
        define: "继续保存",
        cancel: "返回调整",
      );
      if (!askRes) return;
    }

    if (weekdayList.isNotEmpty || holidayList.isNotEmpty) {
      await PermissionUtils.notification(context);
    }

    List<Map<String, dynamic>> weekdayMapList = [];
    for (int i = 0; i < weekdayList.length; i++) {
      weekdayMapList.add({
        "hour": weekdayList[i].hour,
        "minute": weekdayList[i].minute,
      });
    }

    List<Map<String, dynamic>> holidayMapList = [];
    for (int i = 0; i < holidayList.length; i++) {
      holidayMapList.add({
        "hour": holidayList[i].hour,
        "minute": holidayList[i].minute,
      });
    }

    List<Map<String, dynamic>> plans = [];
    List<int> weekdayWeekClone = List.from(weekdayWeeks);
    for (int i = 0; i < weekdayWeekClone.length; i++) {
      if (weekdayWeekClone[i] == 0) {
        weekdayWeekClone[i] = 7;
      }
    }
    plans.add({
      "type": "work",
      "weeks": weekdayWeekClone.toList(),
      "times": weekdayMapList,
      'dailyStudyDuration': weekdayStudyDuration.value * 60,
    });
    List<int> holidayWeekClone = List.from(holidayWeeks);
    for (int i = 0; i < holidayWeekClone.length; i++) {
      if (holidayWeekClone[i] == 0) {
        holidayWeekClone[i] = 7;
      }
    }
    plans.add({
      "type": "rest",
      "weeks": holidayWeekClone.toList(),
      "times": holidayMapList,
      'dailyStudyDuration': holidayStudyDuration.value * 60,
    });

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
          "holidayAdjustment": holidayAdjustment.value, // 智能把节假日当作休息日
          "dailyStudyDuration": holidayStudyDuration.value * 60,
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
      bool res = await StudyPlanRequest.createStudyPlan(data, assessment: assessmentPlan.value);
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

  /// 删除计划
  Future<void> deletePlan(BuildContext context) async {
    if (courseId.value == -1) return;
    if (planId.value == -1) return;

    bool res = await DeleteDialog.show(
      context: context,
      title: "删除学习计划",
      subTitle: "你确定要删除 ${courseName.value} 学习计划吗？",
      content: "提示：此操作不可逆！",
      subContent: "删除计划不再安排后续课程内容，但是之前的学过的知识点记录不会删除，超级记忆会继续推荐。确定删除计划么？",
    );

    if (!res) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "planId": planId.value,
        "clean": 0, // 删除后 原来的学习进度不会被删除
      };
      bool res2 = await StudyPlanRequest.deletePlan(courseId.value, parameters);
      if (!res2) return;
      if (Get.isRegistered<TodayPlanController>()) {
        await Get.find<TodayPlanController>().initData();
      }
      if (Get.isRegistered<UserEvaluationLevelController>()) {
        await Get.find<UserEvaluationLevelController>().getAssessmentResultDetail();
      }
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().initHomeCardList();
      }
      if (Get.isRegistered<MissionControlCenterController>()) {
        await Get.find<MissionControlCenterController>().getTaskMission(showLoading: false);
      }
      ToastUtils.showToast(text: "删除成功");
      Get.back();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 编辑
  Future<void> edit(BuildContext context) async {
    if (courseId.value == -1) return;
    if (planLevelId.value == -1 || planModuleId.value == -1 || planUnitId.value == -1) {
      return ToastUtils.showToast(text: "请先选择计划起点");
    }

    bool tipAskRes = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "修改计划今天任务会重新计算发下，是否确认保存。",
      define: "保存",
      cancel: "取消",
    );
    if (!tipAskRes) return;

    List<Map<String, dynamic>> werkMapList = [];
    for (int i = 0; i < weekdayList.length; i++) {
      werkMapList.add({
        "hour": weekdayList[i].hour,
        "minute": weekdayList[i].minute,
      });
    }
    List<Map<String, dynamic>> holidayMapList = [];
    for (int i = 0; i < holidayList.length; i++) {
      holidayMapList.add({
        "hour": holidayList[i].hour,
        "minute": holidayList[i].minute,
      });
    }

    List<Map<String, dynamic>> plans = [];
    if (werkMapList.isNotEmpty) {
      for (int i = 0; i < weekdayWeeks.length; i++) {
        if (weekdayWeeks[i] == 0) {
          weekdayWeeks[i] = 7;
        }
      }
      plans.add({
        "type": "work",
        "weeks": weekdayWeeks.toList(),
        "times": werkMapList,
        "dailyStudyDuration": weekdayStudyDuration.value * 60,
      });
    }
    if (holidayMapList.isNotEmpty) {
      for (int i = 0; i < holidayWeeks.length; i++) {
        if (holidayWeeks[i] == 0) {
          holidayWeeks[i] = 7;
        }
      }
      plans.add({
        "type": "rest",
        "weeks": holidayWeeks.toList(),
        "times": holidayMapList,
        "dailyStudyDuration": holidayStudyDuration.value * 60,
      });
    }

    List<String> includeDirections = [];
    for (int i = 0; i < selectLessonTypeList.length; i++) {
      if (selectLessonTypeList[i].direction == null) continue;
      includeDirections.add(selectLessonTypeList[i].direction!);
    }

    Map<String, dynamic> data = {
      "dailyStudyDuration": 300, // 每日学习时长
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
      bool res = await StudyPlanRequest.editPlan(courseId.value, data);
      if (!res) return;
      ToastUtils.showToast(text: "修改成功", type: ToastType.success);
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().initHomeCardList();
      }
      if (Get.isRegistered<MissionControlCenterController>()) {
        await Get.find<MissionControlCenterController>().getTaskMission(showLoading: false);
      }
      Get.back(result: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> showStudyTimeChooseDialog() async {
    await StudyTimeChooseDialog.show(Get.context!);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
