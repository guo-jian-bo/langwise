import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/application/controllers/application_controller.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/common.dart';
import 'package:quiz_play/quiz_play.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../../common/values/values.dart';
import '../../../routes/app_pages.dart';
import '../../home/controllers/home_controller.dart';
import '../../specialty/controllers/specialty_controller.dart';
import '../views/asking_for_tasks_dialog.dart';

class OfficialCourseDetailsController extends GetxController {
  /// 传进来的参数
  int? courseId;
  int? levelId;
  int? moduleId;

  /// 拉取自定义课程创建进度之后 是否需要跳转至进度详情页面
  bool goCustomCourseProgress = false;

  /// 是否是切换教材进来的
  final RxBool isSwitchCourse = false.obs;

  /// 是否可以管理课程
  final RxBool isManageCourse = false.obs;
  bool isNew = false;

  final ScrollController scrollController = ScrollController();

  /// 自定义课程当前步骤
  final RxList<CustomCourseStatusEntityStatuses> customCourseStatusList = <CustomCourseStatusEntityStatuses>[].obs;
  final RxBool showCustomCourseStatus = false.obs;
  final RxInt customCourseModuleId = (-1).obs;

  /// 从服务器获取的模块列表
  final RxList<CourseModuleHoursEntityModules> moduleList = <CourseModuleHoursEntityModules>[].obs;

  /// 从服务器获取的列表数据
  final Rx<CourseModuleHoursEntity> detilData = CourseModuleHoursEntity().obs;

  /// 从服务器获取的自定义课程状态
  final Rx<CustomCourseStatusEntity> statusEntity = CustomCourseStatusEntity().obs;

  /// 当前做到的lessonId
  final RxInt currentLessonId = (-1).obs;

  /// 当前做到的unit
  final Rx<CourseModuleHoursEntityUnits> currentUnit = CourseModuleHoursEntityUnits().obs;

  /// 当前做到的lesson
  final Rx<CourseModuleHoursEntityUnitsLessons> currentLessons = CourseModuleHoursEntityUnitsLessons().obs;
  
  int fromType = 0;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      Map arguments = Get.arguments;
      courseId = arguments['courseId'];
      levelId = arguments['levelId'] ?? 0;
      moduleId = arguments['moduleId'] ?? 0;
      isNew = arguments['isNew'] ?? false;
      isSwitchCourse.value = arguments['isSwitchCourse'] ?? false;
      fromType = arguments['fromType'] ?? 0;
      goCustomCourseProgress = arguments['goCustomCourseProgress'] ?? false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getModuleList(isPlan: true, isFirst: true);
      });
    }
  }

  /// 获取自定义课程当前步骤
  Future<void> getCustomCourseStatus() async {
    if (courseId == null) return;
    Map<String, dynamic> reqParameters = {
      "courseId": courseId,
    };
    CustomCourseStatusEntity? resp = await OfficialCourseDetailsRequest.getCustomCourseStatus(reqParameters);
    if (resp == null) return;
    statusEntity.value = resp;

    List<CustomCourseStatusEntityStatuses?> statuses = resp.statuses ?? [];
    customCourseStatusList.clear();
    if (statuses.last?.completed == true && isNew&&resp.finished==false) {
      goToLearn(statuses.last?.comments?.last?.jump?.params?['taskId'] ?? 0);
      return;
    }
    for (int i = 0; i < statuses.length; i++) {
      if (statuses[i] == null) continue;
      customCourseStatusList.add(statuses[i]!);
    }

    print("---课程是否生成完成: ${resp.finished}");
    if (resp.finished == true) {
      showCustomCourseStatus.value = false;
      customCourseModuleId.value = -1;
    } else {
      if(fromType==4){
        PushMessageEntityJump? jump = customCourseStatusList.last.comments?.last?.jump;
        if (jump == null) return;
        Map<String,dynamic> parameters = jump.params??{};
        parameters['fromType'] = fromType;
        parameters['moduleId'] = resp.currentModule?.uid;
        parameters['levelId'] = levelId;
        parameters['courseId'] = courseId;
        await Get.offNamed(jump.code??'', arguments: parameters);
        return;
      }
      customCourseModuleId.value = resp.currentModule?.uid ?? -1;
      if (!isSwitchCourse.value && customCourseModuleId.value != detilData.value.moduleId) {
        if (goCustomCourseProgress) {
          PushMessageEntityJump? jump = customCourseStatusList.last.comments?.last?.jump;
          if (jump == null) return;
          toCustomCoursePage(jump);
          goCustomCourseProgress = false;
        } else {
          showCustomCourseStatus.value = true;
        }
      }
    }
  }

  /// 去学习
  Future<void> goToLearn(int taskId) async {
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "taskId": taskId,
      };
      bool isSuccess = await CustomizedCoursesRequest.customConfirm(parameters);
      if (!isSuccess) return;

      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().initHomeCardList();
      }
      if (Get.isRegistered<OfficialCourseDetailsController>()) {
        await Get.find<OfficialCourseDetailsController>().getModuleList(isLoading: false, isFirst: true);
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 外部删除等级刷新
  /// 参数 delLId要删除的id
  Future<void> otherDeleteLevelRefresh(int? delLId) async {
    if (courseId == null) return;
    if (delLId == null) return;
    if (delLId != levelId) return;
    getLevleListData(null);
  }

  /// 外部删除模块刷新
  /// 参数 delMId要删除的id
  Future<void> otherDeleteModuleRefresh(int? delMId) async {
    if (courseId == null) return;
    if (delMId == null) return;
    if (delMId != moduleId) return;
    getLevleListData(levelId);
  }

  Future<void> getLevleListData(int? dLid) async {
    if (courseId == null) return;
    CourseLevelEntity? resp = await OfficialCourseDetailsLevelRequest.getCourseLevelList(courseId!);
    if (resp == null) return;
    List<CourseLevelEntityLevelList?>? list = resp.levelList;
    if (list == null || list.isEmpty) return;
    int? lId = dLid;
    int? mId;

    List<CourseLevelEntityLevelListModuleList?> moduleList = [];

    if (lId != null) {
      for (int i = 0; i < list.length; i++) {
        if (list[i] == null) continue;
        moduleList = list[i]!.moduleList ?? [];
        if (list[i]!.levelId == lId) {
          moduleList = list[i]!.moduleList ?? [];
          break;
        }
      }
    }

    if (moduleList.isEmpty) {
      for (int i = 0; i < list.length; i++) {
        if (list[i] == null) continue;
        lId = list[i]!.levelId;
        moduleList = list[i]!.moduleList ?? [];
        if (moduleList.isNotEmpty) {
          break;
        }
      }
    }

    if (moduleList.isEmpty) {
      moduleId = 0;
      getModuleList(isLoading: false);
      return;
    }

    mId = moduleList.first?.moduleId;

    if (lId != null && mId != null) {
      levelId = lId;
      moduleId = mId;
      getModuleList(isLoading: false);
    } else {
      Get.back();
    }
  }

  Future<void> getModuleList({bool isScroll = true, bool isLoading = true, bool isPlan = false, bool onlyRefreshProgress = false, bool isFirst = false}) async {
    try {
      if (isLoading) ToastUtils.showLoading();
      CourseModuleHoursEntity? resp = await OfficialCourseDetailsRequest.getModuleClassHours(courseId, levelId, moduleId);
      if (resp == null) return;
      if (onlyRefreshProgress) {
        //只刷新进度
        refreshProgress(resp);
        return;
      }

      // 是否自定义课程
      isManageCourse.value = resp.isManageCourse;
      detilData.value = resp;

      moduleId = detilData.value.moduleId ?? 0;
      levelId = detilData.value.levelId ?? 0;

      currentLessonId.value = detilData.value.lessonId ?? (-1);

      if (isManageCourse.value && detilData.value.customModuleId == moduleId) {
        await getCustomCourseStatus();
      } else {
        showCustomCourseStatus.value = false;
      }

      List<CourseModuleHoursEntityModules?> modules = detilData.value.modules ?? [];

      moduleList.clear();
      for (int i = 0; i < modules.length; i++) {
        if (modules[i] == null) continue;
        moduleList.add(modules[i]!);
      }
    } finally {
      if (isLoading) ToastUtils.hideLoading();
      if (isFirst) {
        // 首次进入页面, 也要展示蒙层
        // 需要展示蒙层
        getCustomCourseStatus();
      }
    }

    scrollToCurrentLesson(isScroll: isScroll, isPlan: isPlan);
  }

  /// 定位到当前做到的地方
  Future<void> scrollToCurrentLesson({bool isScroll = true, bool isPlan = false}) async {
    if (showCustomCourseStatus.value) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (isPlan) {
        DateTime now = DateTime.now().toLocal();
        String nowStr = "${now.year}${now.month}${now.day}";
        String notRemindCourse = StorageUtil().getString(NOT_REMIND_COURSE_KEY);

        if (detilData.value.planNode != null && notRemindCourse != nowStr) {
          // 有计划
          int? result = await AskingForTasksDialog.show(context: Get.context!);
          if (result == 1) {
            // 继续计划
            continuePlan();
            return;
          }
        }
      }

      /// 定位到当前做到的地方
      double offset = 0;
      List<CourseModuleHoursEntityUnits?> units = detilData.value.units ?? [];
      bool found = false;

      for (int i = 0; i < units.length && !found; i++) {
        if (units[i] == null) continue;
        List<CourseModuleHoursEntityUnitsLessons?> lessons = units[i]!.lessons ?? [];

        // 每个单元的第一个lesson是目标，宽度为430.wMin
        if (lessons.isNotEmpty) {
          offset += 430.wMin; // 单元目标的宽度
        }

        for (int j = 1; j < lessons.length; j++) {
          // 从索引1开始，跳过目标lesson
          if (lessons[j] == null) continue;

          if (currentLessonId.value == lessons[j]!.uid) {
            currentUnit.value = units[i]!;
            currentLessons.value = lessons[j]!;
            found = true;

            if (isScroll) {
              // 等待UI渲染完成后再滚动
              Future.delayed(const Duration(milliseconds: 500), () {
                // 使用更精确的偏移量计算
                double targetOffset = offset - (430.wMin); // 居中显示

                // 确保偏移量在有效范围内
                double maxOffset = scrollController.position.maxScrollExtent;
                targetOffset = targetOffset.clamp(0.0, maxOffset);

                scrollController.animateTo(
                  targetOffset,
                  duration: const Duration(milliseconds: 300), // 稍微延长动画时间
                  curve: Curves.easeInOut, // 使用更平滑的曲线
                );
              });
            }
            break;
          }
          offset += 360.wMin; // 课程项的宽度
        }
      }
    });
  }

  /// 继续计划
  Future<void> continuePlan() async {
    if (Get.isRegistered<ApplicationController>()) {
      ApplicationController applicationController = Get.find<ApplicationController>();
      applicationController.navIndex.value = 0;
      applicationController.previousIndex = 0;
      Get.back(result: {"type": 0});
    }
  }

  /// 只刷新进度
  void refreshProgress(CourseModuleHoursEntity resp) {
    detilData.value.lessonIndex = resp.lessonIndex;
    detilData.value.lessonCount = resp.lessonCount;
    List<CourseModuleHoursEntityUnits?> localUnits = detilData.value.units ?? [];
    List<CourseModuleHoursEntityUnits?> serveUnits = resp.units ?? [];
    List<CourseModuleHoursEntityUnitsLessons?> serverLessons = [];
    for (int i = 0; i < serveUnits.length; i++) {
      if (serveUnits[i] == null) continue;
      serverLessons.addAll(serveUnits[i]?.lessons ?? []);
    }

    for (int i = 0; i < localUnits.length; i++) {
      if (localUnits[i] == null) continue;
      List<CourseModuleHoursEntityUnitsLessons?> lessons = localUnits[i]!.lessons ?? [];
      for (int j = 0; j < lessons.length; j++) {
        if (lessons[j] == null) continue;
        for (var item in serverLessons) {
          if (item == null) continue;
          if (item.uid == lessons[j]?.uid && (lessons[j]?.exerciseIndex != item.exerciseIndex || lessons[j]?.exerciseTotal != item.exerciseTotal)) {
            lessons[j]?.exerciseIndex = item.exerciseIndex;
            lessons[j]?.exerciseTotal = item.exerciseTotal;
          }
        }
      }
    }
    detilData.refresh();
  }

  /// 切换模块
  Future<void> switchModule(int? uid) async {
    if (uid == null) return;
    if (moduleId == uid) return;
    moduleId = uid;
    await getModuleList();
  }

  /// 获取课时下的任务
  Future<void> getLessonTasks(BuildContext context, int? unitId, int? lessonId) async {
    bool experience = await LockUtils.checkExperienceApp(context);
    if (experience) return;
    bool student = await LockUtils.checkStudent(context);
    if (!student) return;

    if (courseId == null || levelId == null || moduleId == null || unitId == null || lessonId == null) return;
    Map<String, dynamic> reqData = {
      "courseId": courseId,
      "levelId": levelId,
      "moduleId": moduleId,
      "unitId": unitId,
      "lessonId": lessonId,
    };
    LessonTasksEntity? taksRes;
    List<QuizModel>? quizList = [];
    try {
      ToastUtils.showLoading();
      await getModuleList(onlyRefreshProgress: true);
      taksRes = await OfficialCourseDetailsRequest.getLessonTasks(reqData);
      if (taksRes == null) return;
      List<int?> taksIds = taksRes.exerciseIds ?? [];
      List<int> exerciseIds = [];
      for (int i = 0; i < taksIds.length; i++) {
        if (taksIds[i] == null) continue;
        exerciseIds.add(taksIds[i]!);
      }
      if (exerciseIds.isEmpty) return;
      // exerciseIds = [418606];
      quizList = await HomeRequest.getQuizListByIds(exerciseIds);
      if (quizList == null) return;
    } finally {
      ToastUtils.hideLoading();
    }

    toQuizPage(unitId, lessonId, taksRes.exerciseCurrentId, quizList);
  }

  /// 开始做题
  Future<void> toQuizPage(int unitId, int lessonId, int? exerciseCurrentId, List<QuizModel> quizList) async {
    if (quizList.isEmpty) return;

    for (int i = 0; i < quizList.length; i++) {
      quizList[i].testType = "COURSE";
      quizList[i].context = QuizModelContext(
        courseId: courseId,
        levelId: levelId,
        moduleId: moduleId,
        unitId: unitId,
        lessonId: lessonId,
      );
    }

    ToastUtils.showLoading();

    await CacheManagerUtils.instance.cacheQuizAssetsFirstTwo(quizList, exerciseCurrentId: exerciseCurrentId);
    await Get.toNamed(
      Routes.PRACTICE_QUESTIONS,
      arguments: {
        "quizDatas": quizList,
        "currentQuizId": exerciseCurrentId,
        "questionIsReport": true,
      },
    );
    if (Get.isRegistered<HomeController>()) {
      HomeController homeController = Get.find<HomeController>();
      if (homeController.memberCourseList.isEmpty) {
        homeController.initHomeCardList();
      }
    }
    if (Get.isRegistered<SpecialtyController>()) {
      await Get.find<SpecialtyController>().initHomeCardList();
    }
    getModuleList(isLoading: false, isScroll: false);
  }

  /// 跳转至单元目标
  Future<void> toTargetPage(int? unitId) async {
    if (courseId == null || levelId == null || moduleId == null || unitId == null) return;
    await Get.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS_TARGET,
      arguments: {
        "courseId": courseId,
        "levelId": levelId,
        "moduleId": moduleId,
        "unitId": unitId,
      },
    );
  }

  /// todo 跳转至等级
  Future<void> toLevel() async {
    if (courseId == null) return;

    dynamic pageRes;
    if (detilData.value.specialty == SpecialtyEnum.EN_PHONICS) {
      // 自然拼读课选择等级模块
      pageRes = await Get.toNamed(
        Routes.PHONICS_COURSE,
        arguments: {
          "courseId": courseId,
          "isSelectModule": true, // 是否是选择
        },
      );
    } else {
      pageRes = await Get.toNamed(
        Routes.OFFICIAL_COURSE_DETAILS_LEVEL,
        arguments: {
          "courseId": courseId,
          "levelId": levelId,
          "moduleId": moduleId,
          "isFromCustomCourse": isManageCourse.value,
          "showRecommend": true,
          "scrollToStudyZoneEnum": StudyZoneEnum.study,
        },
      );
    }

    if (pageRes == null) return;
    Map? map = pageRes;
    if (map == null || map.isEmpty) return;
    levelId = map['levelId'];
    moduleId = map['moduleId'];
    if (levelId == null || moduleId == null) return;
    print("---跳转至等级levelId: $levelId, moduleId:$moduleId---");
    getModuleList();
  }

  /// 跳转至自定义课程页面
  Future<void> toCustomCoursePage(PushMessageEntityJump? jump) async {
    if (jump == null) return;
    await JumpPageUtils.jumpUserPages(jump.code, jump.params);
    getModuleList(isLoading: false, isScroll: false);
  }

  /// 跳转至自定义课程编辑弹窗
  // Future<void> toEditCoustomCourse(BuildContext context) async {
  //   if (courseId == null) return;
  //   OperateCoustomCourseDialogResult? editRes = await OperateCoustomCourseDialog.show(
  //     context: context,
  //     courseId: courseId!,
  //     initLevelId: levelId,
  //   );
  //   if (editRes == null) return;
  //   if (editRes.type == OperateCoustomCourseDialogType.addModule) {
  //     if (detilData.value.customModuleId != null && detilData.value.customModuleId != -1) {
  //       return ToastUtils.showToast(text: '有未创建完的自定义课程');
  //     }
  //     dynamic res = await Get.toNamed(
  //       Routes.CUSTOMIZED_COURSES,
  //       arguments: {
  //         "courseId": courseId,
  //         "levelId": editRes.levelId,
  //         "pageType": 2,
  //       },
  //     );
  //     if (res == null) return;
  //     Map resMap = res;
  //     levelId = resMap['levelId'] ?? 0;
  //     moduleId = resMap['moduleId'] ?? 0;
  //     goCustomCourseProgress = resMap['goCustomCourseProgress'] ?? false;
  //     getModuleList();
  //   } else if (editRes.type == OperateCoustomCourseDialogType.addLevel) {
  //     if (detilData.value.customModuleId != null && detilData.value.customModuleId != -1) {
  //       return ToastUtils.showToast(text: '有未创建完的自定义课程');
  //     }
  //     dynamic res = await Get.toNamed(
  //       Routes.CUSTOMIZED_COURSES,
  //       arguments: {
  //         "courseId": courseId,
  //         "pageType": 1,
  //       },
  //     );
  //     if (res == null) return;
  //     Map resMap = res;
  //     levelId = resMap['levelId'] ?? 0;
  //     moduleId = resMap['moduleId'] ?? 0;
  //     goCustomCourseProgress = resMap['goCustomCourseProgress'] ?? false;
  //     getModuleList();
  //   } else if (editRes.type == OperateCoustomCourseDialogType.editCourse) {
  //     // EditAppCourseDetailDialog.show(
  //     //   onCancel: () {

  //     //   },
  //     // );

  //     EditCustomCoursesDialog.show(context: context, courseId: courseId!);
  //   }
  // }

  /// 编辑教材
  Future<void> editCourse(BuildContext context) async {
    bool isPwdRight = await ParentPasswordialog.show(context: context, isCheckHasPassword: false);
    if (!isPwdRight) return;

    Get.toNamed(
      Routes.CUSTOM_COURSE_MANAGE_GRADE,
      arguments: {
        "courseId": courseId,
        "levelId": levelId,
        "moduleId": moduleId,
      },
    );
  }
}
