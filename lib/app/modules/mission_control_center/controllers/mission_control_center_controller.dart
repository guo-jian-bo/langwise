import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/home/controllers/home_controller.dart';
import 'package:langwise/common/widgets/guide_engine/guide_manager.dart';
import 'package:langwise/utils/utils.dart';
import 'package:quiz_play/quiz_play.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../routes/routes.dart';
import '../common/mission_control_center_statistics_dialog.dart';
import '../model/mission_model.dart';

class MissionControlCenterController extends GetxController {
  /// 传进来的参数 0=巩固今日 1=明日
  int review = 0;

  final ScrollController scrollController = ScrollController();

  final GlobalKey listRootKey = GlobalKey();

  /// 当前mission下标
  final RxInt currentMissionIndex = 0.obs;

  /// 当前题目ID
  final RxInt currentExerciseId = 0.obs;

  /// 预计用时
  final RxInt exerciseDuration = 0.obs;

  /// 原始数据
  final Rx<TaskMissionEntity> missionEntity = TaskMissionEntity().obs;

  /// 实际展示的任务列表
  final RxList<MissionModel> missionList = <MissionModel>[].obs;

  /// 计划列表
  final RxList<TaskMissionEntityMissionUnits> missionUnits = <TaskMissionEntityMissionUnits>[].obs;

  /// 任务菜单列表
  final RxList<TaskMissionMenuEntityList> taskMissionMenuList = <TaskMissionMenuEntityList>[].obs;

  /// 今日是否有任务
  final RxBool isTodayMission = true.obs;

  /// 是否全部完成
  final RxBool isAllCompleted = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      review = Get.arguments['review'] ?? 0;
    }
    getTaskMission().then((_) {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().initHomeCardList();
      }
    });
  }

  Future<void> getTaskMission({bool showLoading = true, bool scrollToCurrent = true}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      if (showLoading) ToastUtils.showLoading();
      TaskMissionEntity? entity = await MissionRequest.getMissionList(review);
      if (entity == null) return;
      await getTaskMissionMenu();
      missionEntity.value = entity;
      currentExerciseId.value = entity.exerciseId ?? 0;
      exerciseDuration.value = entity.exerciseDuration ?? 0;
      groupMissionData(entity);
      getCurrentMission();

      List<TaskMissionEntityMissionUnits?>? units = entity.missionUnits;
      if (units == null) return;
      missionUnits.clear();
      for (int i = 0; i < units.length; i++) {
        if (units[i] == null) continue;
        missionUnits.add(units[i]!);
      }

      if (scrollToCurrent) {
        scrollToCurrentMission();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToCurrentMission();
        });
      }
    } finally {
      review = 0;
      if (showLoading) ToastUtils.hideLoading();
    }
  }

  /// 获取任务菜单列表
  Future<void> getTaskMissionMenu() async {
    TaskMissionMenuEntity? entity = await MissionRequest.getTaskMissionMenu();
    if (entity == null) return;
    List<TaskMissionMenuEntityList?>? list = entity.list;
    if (list == null) return;
    taskMissionMenuList.clear();
    for (int i = 0; i < list.length; i++) {
      if (list[i] == null) continue;
      taskMissionMenuList.add(list[i]!);
    }
  }

  /// 对任务数据进行分组
  void groupMissionData(TaskMissionEntity entity) {
    List<TaskMissionEntityMissions?> missions = entity.missions ?? [];

    missionList.clear();
    for (int i = 0; i < missions.length; i++) {
      if (missions[i] == null) continue;
      int? missionId = missions[i]?.missionId;
      if (missionId == null) continue;

      missionList.add(MissionModel(
        missions: missions[i]!,
      ));
    }

    if(missionList.isEmpty){
      isAllCompleted.value = false;
      isTodayMission.value = false;
      return;
    }

    missionList.sort((a, b) => (a.missions.missionIndex ?? 0).compareTo(b.missions.missionIndex ?? 0));

    isAllCompleted.value = true;
    for (int i = 0; i < missionList.length; i++) {
      bool learned = missionList[i].missions.learned;
      if(learned) continue;
      isAllCompleted.value = false;
      break;
    }

  }

  /// 获取当前的mission
  void getCurrentMission() {
    if (missionList.isEmpty) return;
    for (int i = 0; i < missionList.length; i++) {
      bool notYetLearned = missionList[i].missions.notYetLearned;
      if (notYetLearned) {
        currentMissionIndex.value = i;
        break;
      }
    }
  }

  Future<void>? scrollToCurrentMission() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!scrollController.hasClients) return;
    if (missionList.isEmpty) return;

    double itemWidth = 350.wMin;

    // 计算滚动视图的可见宽度
    double viewportWidth = scrollController.position.viewportDimension;

    // 计算当前任务的中心位置
    double targetCenter = (currentMissionIndex.value * itemWidth) + itemWidth / 2 + 88.wMin;

    // 计算滚动位置，让当前任务居中
    double targetScrollOffset = targetCenter - viewportWidth / 2;

    // 获取滚动范围的最小值和最大值
    double minScrollExtent = scrollController.position.minScrollExtent;
    double maxScrollExtent = scrollController.position.maxScrollExtent;

    // 确保滚动位置不超出范围
    targetScrollOffset = targetScrollOffset.clamp(minScrollExtent, maxScrollExtent);

    // 执行滚动动画
    scrollController.animateTo(
      targetScrollOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  /// 根据missionId获取任务下的所有exercise
  List<TaskMissionEntityExercises>? getMissionExercises(List<TaskMissionEntityExercises?> exercises, int missionId) {
    if (exercises.isEmpty) return null;
    List<TaskMissionEntityExercises> respList = [];
    for (int i = 0; i < exercises.length; i++) {
      if (exercises[i] == null) continue;
      if (exercises[i]?.missionId != missionId) continue;
      respList.add(exercises[i]!);
    }
    return respList;
  }

  /// 提前学按钮
  Future<void> advanceLearning(BuildContext context) async {
    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "是否确认提前学习？",
      showLastCountdown: true,
    );
    if (!askRes) return;
    
    review = 1;
    try {
      ToastUtils.showLoading();
      await getTaskMission(showLoading: false, scrollToCurrent: false);
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().initHomeCardList();
      }
    } finally {
      review = 0;
      ToastUtils.hideLoading();
    }
  }


  /// 开始任务
  Future<void> startMission(MissionModel mission, int index, {bool again = false}) async {

    if(mission.missions.isTest){
      await testMission(mission, index, again: again);
    } else if(mission.missions.isPreview){
      await previewMission(mission, index);
    }else{
      await toMission(mission, index);
    }
  }


  /// 普通任务
  Future<void> toMission(MissionModel mission, int index) async {
    try {
      ToastUtils.showLoading();
      int? missionId = mission.missions.missionId;
      if(missionId == null) return;
      TaskMissionEntity? entity = await MissionRequest.getMissionQuizList(missionId);
      if(entity == null) return;
      currentExerciseId.value = entity.exerciseId ?? 0;
      List<TaskMissionEntityExercises?>? exercises = entity.exercises??[];
      if(exercises.isEmpty) return;
      List<TaskMissionEntityExercises> missionExercises = [];
      for (int i = 0; i < exercises.length; i++) {
        if (exercises[i] == null) continue;
        missionExercises.add(exercises[i]!);
      }

      mission.exercises = missionExercises;

      await normalDoMission(mission, index);
      
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 预习任务
  Future<void> previewMission(MissionModel mission, int index) async {
    try {
      ToastUtils.showLoading();

      if(mission.missions.missionId != null){
        MissionRequest.minMissionComplete(mission.missions.missionId!).then((value){
          if(value){
            getTaskMission(showLoading: false, scrollToCurrent: false);
          }
        });
      }

      int? courseId = mission.missions.context?.courseId;
      int? moduleId = mission.missions.context?.moduleId;
      int? unitId = mission.missions.context?.unitId;
      if(courseId == null || moduleId == null || unitId == null) return;
      UnitKnowledgePointsEntity? entity = await OfficialCourseDetailsRequest.getUnitTarget(
        courseId,
        moduleId,
        unitId,
      );
      if(entity == null) return;
      
      List<UnitKnowledgePointsEntityKnowledgeList?>? list = entity.knowledgeList;
      if (list == null) return;
      List<UnitKnowledgePointsEntityKnowledgeList> knowledgeList = [];

      for (int i = 0; i < list.length; i++) {
        UnitKnowledgePointsEntityKnowledgeList? item = list[i];
        if (item == null) continue;
        if (item.isWord) knowledgeList.add(item);
        if (item.isPhrase) knowledgeList.add(item);
        if (item.isSentence) knowledgeList.add(item);
        if (item.isText) knowledgeList.add(item);
      }
      
      if (knowledgeList.isEmpty) return;

      Get.toNamed(Routes.OFFICIAL_COURSE_DETAILS_PREVIEW, arguments: {
        "unitName": mission.missions.title,
        "knowledgeList": knowledgeList,
      });

    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 测试任务
  Future<void> testMission(MissionModel mission, int index, {bool again = false}) async {
    if(mission.missions.targetId == null) return;

    if(!again && mission.missions.learned){
      // 没有分数不让进
      if(mission.missions.score == null || mission.missions.score == 0){
        ToastUtils.showToast(text: "当前单元测试没有题目");
        return;
      }

      // 已经评测过 跳转至结果页面
      goToTestResultPage(targetId: mission.missions.targetId);
      return;
    }
    
    List<TaskMissionEntityExercises> exerciseList = [];
    int? unitTestRecordId;
    try {
      ToastUtils.showLoading();

      int restart = 0;
      /// 重新开始
      if(again){
        // 需要拉取接口 是否继续
        restart = 1;
      }

      TaskMissionUnitTestEntity? unitTestEntity = await MissionRequest.getTestMissionExercises(
        mission.missions.targetId!,
        restart: restart,
      );
      if(unitTestEntity == null) return;

      if(unitTestEntity.hasExercises == false){
        // 没有题目
        ToastUtils.showToast(text: "当前单元测试没有题目");
        mission.missions.status = LearnedStatusEnum.learned;
        missionList.refresh();
        getTaskMission(showLoading: false, scrollToCurrent: false);
        return;
      }

      unitTestRecordId = unitTestEntity.unitTestRecordId;
      
      if(unitTestEntity.exerciseId != null){
        currentExerciseId.value = unitTestEntity.exerciseId!;
      }
      
      List<TaskMissionEntityExercises?> exercises = unitTestEntity.exercises ?? [];
      if(exercises.isEmpty) return;
      for (int i = 0; i < exercises.length; i++) {
        if(exercises[i] == null) continue;
        exerciseList.add(exercises[i]!);
      }

    } finally{
      ToastUtils.hideLoading();
    }

    mission.exercises = exerciseList;
    
    await normalDoMission(
      mission, 
      index, 
      isAutoSkip: true, 
      maxErrorCount: 1, 
      isCanSwitchByNumber: false, 
      unitTestRecordId: unitTestRecordId,
      isShowImageGloss: false,
    );
    
  }

  /// 正常做题
  Future<void> normalDoMission(
    MissionModel mission, 
    int index, 
    {
      bool? isAutoSkip, 
      int? maxErrorCount, 
      bool? isCanSwitchByNumber,
      int? unitTestRecordId,
      bool isShowImageGloss = true,
    }) async {

    ErrorLogUtils.to.logInfo("练习 - mission ----- 开始");
    List<TaskMissionEntityExercises> exercises = mission.exercises??[];

    List<QuizModel> quizList = [];

    for (int i = 0; i < exercises.length; i++) {
      if (exercises[i].exercise == null) continue;
      exercises[i].exercise?.context = exercises[i].context;
      exercises[i].exercise?.testType = exercises[i].testType;
      exercises[i].exercise?.duration = exercises[i].duration;
      quizList.add(exercises[i].exercise!);
    }
    if (quizList.isEmpty) return;
    try {
      ToastUtils.showLoading();
      await CacheManagerUtils.instance.cacheQuizAssetsFirstTwo(quizList, exerciseCurrentId: currentExerciseId.value);
    } finally {}
    dynamic res = await Get.toNamed(
      Routes.PRACTICE_QUESTIONS,
      arguments: {
        "currentQuizId": currentExerciseId.value,
        "quizDatas": quizList,
        "questionIsReport": true,
        "isCollectCard": false,
        "isShowPercentageProgress": true,
        "settingTotalDurationSecond": mission.missions.estimatedTime?.toInt(),
        "isAutoSkip": isAutoSkip,
        "maxErrorCount": maxErrorCount,
        "isShowImageGloss": isShowImageGloss,
        "isCanSwitchByNumber": isCanSwitchByNumber,
      },
    );
    ErrorLogUtils.to.logInfo("练习 - mission ----- 退出了做题页面 $res");
    if (res == null) return;
    if (res["manual"] == true) return; // 说明是手动暂停退出 不显示结算页面

    ErrorLogUtils.to.logInfo("练习 - mission ----- 结束 --- 准备显示结果");

    if(mission.missions.isPreview){
      
    }else if(mission.missions.isTest){
      goToTestResultPage(unitTestRecordId: unitTestRecordId);
    }else{
      goToCompletePage(mission.missions);
    }
    
  }

  /// 跳转至评测结果页面
  Future<void> goToTestResultPage({int? unitTestRecordId, int? targetId}) async{
    ErrorLogUtils.to.logInfo("练习 - mission ----- 跳转至评测结果页面");
    dynamic res = await Get.toNamed(
      Routes.MISSION_TEST_RESULT,
      arguments: {
        "unitTestRecordId": unitTestRecordId,
        "targetId": targetId,
      },
    );
    if(res == null) return;
  }

  /// 跳转至mission完成页面
  Future<void> goToCompletePage(TaskMissionEntityMissions missions) async {
    ErrorLogUtils.to.logInfo("练习 - mission ----- 跳转至mission完成页面 ${missions.missionId}");
    if(missions.missionId == null) return;

    bool isLastMission = false;

    int currentIndex = 0;
    for (int i = 0; i < missionList.length; i++) {
      if (missionList[i].missions.missionId == missions.missionId) {
        isLastMission = i == missionList.length - 1;
        currentIndex = i;
        break;
      }
    }

    TaskMissionEntityMissions? nextMission;
    if(!isLastMission){
      nextMission = missionList[currentIndex + 1].missions;
    }

    dynamic res = await Get.toNamed(
      Routes.MISSION_COMPLETE,
      arguments: {
        "missionId": missions.missionId,
        "isLastMission": isLastMission,
        "nextMission": nextMission,
      },
    );
    if (res == null) return; // 0=返回控制中心 1=再做一遍 2=继续下一个任务
    if (res == 0){
      await GuideManager.instance.completeDeferredStep();
      return;
    }
    if (res == 1) {
      int index = 0;
      MissionModel? missionModel;
      for (int i = 0; i < missionList.length; i++) {
        if (missionList[i].missions.missionId == missions.missionId) {
          index = i;
          missionModel = missionList[i];
          break;
        }
      }
      if (missionModel == null) return;
      startMission(missionModel, index);
    } else if (res == 2) {
      // 继续下一个任务
      startMission(missionList[currentMissionIndex.value], currentMissionIndex.value);
    }
  }


  /// 显示任务统计弹窗
  void showMissionStatisticsDialog(BuildContext context) {
    MissionControlCenterStatisticsDialog.show(
      context: context, 
      missionDurationAvg: DateFormatUtil.convertMillisecondsToMinSec(missionEntity.value.missionDurationAvgInt), 
      missionScoreAvg: "${missionEntity.value.missionScoreAvg??0}", 
      duration: DateFormatUtil.convertMillisecondsToMinSec(missionEntity.value.durationInt), 
      missionPoints: "+${missionEntity.value.missionPoints??0}",
    );
  }

  /// 任务菜单弹窗
  Future<void> showMissionTaskPop(BuildContext context, TaskMissionMenuEntityList item) async {
    if(item.type == null) return;

    Get.toNamed(
      Routes.MISSION_SPECIAL,
      arguments: {
        "taskType": item.type,
      },
    );
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
