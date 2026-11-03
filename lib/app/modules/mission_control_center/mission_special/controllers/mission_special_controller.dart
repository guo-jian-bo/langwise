import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/mission_control_center/controllers/mission_control_center_controller.dart';
import 'package:quiz_play/models/models.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';

class MissionSpecialController extends GetxController {
  String? taskType;

  final Rx<TaskMissionMenuListEntity> taskSpecial = TaskMissionMenuListEntity().obs;

  final RxList<TaskMissionMenuListEntityList> taskSpecialList = <TaskMissionMenuListEntityList>[].obs;

  /// 新任务
  final RxInt nowTaskCount = 0.obs;

  /// 已完成的任务
  final RxInt completedCount = 0.obs;

  /// 数据拉取状态 -1=还未请求 0=有数据 1=无数据
  final RxInt dataStatus = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if(Get.arguments != null){
      taskType = Get.arguments['taskType'];
      getTaskSpecialList();
    }
  }

  Future<void> getTaskSpecialList({bool showLoading = true}) async {
    dataStatus.value = -1;
    if(taskType == null) {
      dataStatus.value = 1;
      return;
    }
    try {
      if(showLoading) ToastUtils.showLoading();
      TaskMissionMenuListEntity? res = await MissionRequest.getTaskMissionGroup(taskType!);
      if(res == null) {
        dataStatus.value = 1;
        return;
      }
      taskSpecial.value = res;
      List<TaskMissionMenuListEntityList?> list = res.list ?? [];
      taskSpecialList.clear();
      for(var item in list){
        if(item == null) continue;
        taskSpecialList.add(item);
      }
      nowTaskCount.value = taskSpecialList.where((element) => element.notYetLearned).length;
      completedCount.value = taskSpecialList.where((element) => element.learned && element.isNormal).length;
      dataStatus.value = taskSpecialList.isEmpty ? 1 : 0;
    } finally{
      if(showLoading) ToastUtils.hideLoading();
    }
  }


  Future<void> onTapItem(BuildContext context, TaskMissionMenuListEntityList item) async{
    bool lock = await LockUtils.checkLock(
      item.rights, 
      context, 
      contentType: item.type,
    );
    if(lock) return;

    if(item.uid == null) return;
    if(item.notYetLearned){
      MissionRequest.readTask(item.uid!).then((value){
        if(value){
          item.status = LearnedStatusEnum.learning;
          nowTaskCount.value = nowTaskCount.value - 1;
          taskSpecialList.refresh();
          if(Get.isRegistered<MissionControlCenterController>()){
            Get.find<MissionControlCenterController>().getTaskMissionMenu();
          }
        }
      });
    }

    if(item.module == TaskModuleEnum.LISTENING_PREVIEW_COURSE_UNIT_CONTENT){
      await previewCourseUnitContent(item);
    } else if(item.module == TaskModuleEnum.LISTENING_PREVIEW_COURSE_UNIT_SONG){
      await previewCourseUnitSong(item);
    } else if(item.module == TaskModuleEnum.LISTENING_TODAY_NEW_KNOWLEDGE){
      await listeningTodayNewKnowledge(item);
    } else if(item.module == TaskModuleEnum.LISTENING_REVIEW_TODAY_KNOWLEDGE){
      await listeningReviewTodayKnowledge(item);
    } else if(item.module == TaskModuleEnum.SPEAKING_TODAY_NEW_KNOWLEDGE){
      await speakingTodayNewKnowledgeQuiz(item);
    } else if(item.module == TaskModuleEnum.SPEAKING_REVIEW_TODAY_KNOWLEDGE){
      await speakingReviewTodayKnowledgeQuiz(item);
    } else if(item.module == TaskModuleEnum.READING_TODAY_NEW_KNOWLEDGE){
      await readingTodayNewKnowledge(item);
    } else if(item.module == TaskModuleEnum.READING_REVIEW_TODAY_KNOWLEDGE){
      await readingReviewTodayKnowledge(item);
    } else if(item.module == TaskModuleEnum.WRITING_TODAY_NEW_KNOWLEDGE){
      await writingTodayNewKnowledge(item);
    } else if(item.module == TaskModuleEnum.WRITING_REVIEW_TODAY_KNOWLEDGE){
      await writingReviewTodayKnowledge(item);
    } else{
      if(item.jump == null) return;
      // LISTENING_REVEAL READING_REVEAL OVERALL_COURSE_UNIT_TEXT
      await JumpPageUtils.jumpUserPages(item.jump!.code, item.jump!.params);
    }
    getTaskSpecialList(showLoading: false);
  }


  /// 预习课程
  Future<void> previewCourseUnitContent(TaskMissionMenuListEntityList item) async{
    // 获取单元目标列表接口 跳转至预习页面
    List<UnitKnowledgePointsEntityKnowledgeList> pageKnowledgeList = await getUnitKnowledgePoints(item);
    if(pageKnowledgeList.isEmpty) return;

    await Get.toNamed(Routes.OFFICIAL_COURSE_DETAILS_PREVIEW, arguments: {
      "unitName": item.title,
      "knowledgeList": pageKnowledgeList,
    });
  }

  /// 预习音乐
  Future<void> previewCourseUnitSong(TaskMissionMenuListEntityList item) async{
    List<UnitKnowledgePointsEntityKnowledgeList> pageKnowledgeList = await getUnitKnowledgePoints(item);
    if(pageKnowledgeList.isEmpty) return;

    List<Map<String, dynamic>> contents = [];
    for(var item in pageKnowledgeList){
      if(item.isSong){
        contents.add({
          "contentId": item.contentId,
          "contentType": item.contentType,
          "styleId": item.styleId,
          "dialect": item.dialect,
        });
      }
    }

    await JumpPageUtils.jumpSongMv(contents: contents);
    
  }

  /// 听-今日新学知识点
  Future<void> listeningTodayNewKnowledge(TaskMissionMenuListEntityList item) async{
    // 获取今天新学的知识点 然后暂时跳转至预习
    List<UnitKnowledgePointsEntityKnowledgeList> pageKnowledgeList = await getTodayNewKnowledge();
    if(pageKnowledgeList.isEmpty) return;
    await Get.toNamed(Routes.OFFICIAL_COURSE_DETAILS_PREVIEW, arguments: {
      "unitName": item.title,
      "knowledgeList": pageKnowledgeList,
    });

  }

  /// 听-今日所有知识点
  Future<void> listeningReviewTodayKnowledge(TaskMissionMenuListEntityList item) async{
    // 获取今天所有的知识点 然后暂时跳转至预习
    List<UnitKnowledgePointsEntityKnowledgeList> pageKnowledgeList = await getTodayAllKnowledge();
    if(pageKnowledgeList.isEmpty) return;
    await Get.toNamed(Routes.OFFICIAL_COURSE_DETAILS_PREVIEW, arguments: {
      "unitName": item.title,
      "knowledgeList": pageKnowledgeList,
    });
  }

  /// 说今日新学知识点
  Future<void> speakingTodayNewKnowledgeQuiz(TaskMissionMenuListEntityList item) async{
    List<QuizModel> pageQuizist = await getTodayNewKnowledgeQuiz();
    if(pageQuizist.isEmpty) return;
    
    dynamic res = await Get.toNamed(
      Routes.PRACTICE_QUESTIONS,
      arguments: {
        "quizDatas": pageQuizist,
        "questionIsReport": true,
        "isCollectCard": true,
        "isShowPercentageProgress": true,
      },
    );
    if (res == null) return;
  }

  /// 说-今日所有知识点
  Future<void> speakingReviewTodayKnowledgeQuiz (TaskMissionMenuListEntityList item) async{
    List<QuizModel> pageQuizist = await getTodayAllKnowledgeQuiz();
    if(pageQuizist.isEmpty) return;
    
    dynamic res = await Get.toNamed(
      Routes.PRACTICE_QUESTIONS,
      arguments: {
        "quizDatas": pageQuizist,
        "questionIsReport": true,
        "isCollectCard": true,
        "isShowPercentageProgress": true,
      },
    );
    if (res == null) return;
  }

  /// 读-今日新学知识点
  Future<void> readingTodayNewKnowledge(TaskMissionMenuListEntityList item) async{
    // 获取今天的知识点 然后暂时跳转至闪卡
    List<UnitKnowledgePointsEntityKnowledgeList> pageKnowledgeList = await getTodayNewKnowledge();
    if(pageKnowledgeList.isEmpty) return;

    await Get.toNamed(Routes.OFFICIAL_COURSE_DETAILS_FLASH_NOTES, arguments: {
      "unitName": item.title,
      "knowledgeList": pageKnowledgeList,
    });
  }

  /// 读-今天学习过的知识点
  Future<void> readingReviewTodayKnowledge(TaskMissionMenuListEntityList item) async{
    // 获取今天所有的知识点 然后暂时跳转至闪卡
    List<UnitKnowledgePointsEntityKnowledgeList> pageKnowledgeList = await getTodayAllKnowledge();
    if(pageKnowledgeList.isEmpty) return;

    await Get.toNamed(Routes.OFFICIAL_COURSE_DETAILS_FLASH_NOTES, arguments: {
      "unitName": item.title,
      "knowledgeList": pageKnowledgeList,
    });
  }


  /// 写-今日新学知识点
  Future<void> writingTodayNewKnowledge(TaskMissionMenuListEntityList item) async{
    // 获取今天的知识点 然后暂时跳转至听写
    List<UnitKnowledgePointsEntityKnowledgeList> pageKnowledgeList = await getTodayNewKnowledge();
    if(pageKnowledgeList.isEmpty) return;

    await Get.toNamed(Routes.OFFICIAL_COURSE_DETAILS_DICTATION, arguments: {
      "unitName": item.title,
      "knowledgeList": pageKnowledgeList,
    });
  }

  /// 写今天学习过的知识点
  Future<void> writingReviewTodayKnowledge(TaskMissionMenuListEntityList item) async{
    // 获取今天所有的知识点 然后暂时跳转至听写
    List<UnitKnowledgePointsEntityKnowledgeList> pageKnowledgeList = await getTodayAllKnowledge();
    if(pageKnowledgeList.isEmpty) return;

    await Get.toNamed(Routes.OFFICIAL_COURSE_DETAILS_DICTATION, arguments: {
      "unitName": item.title,
      "knowledgeList": pageKnowledgeList,
    });
  }





  /// 获取单元目标知识点数据
  Future<List<UnitKnowledgePointsEntityKnowledgeList>> getUnitKnowledgePoints(TaskMissionMenuListEntityList item) async{
    List<String?>? contentTypes = item.contentTypes;
    Map<String, dynamic>? params = item.jump?.params;
    if(params == null) return [];
    int? courseId = params['courseId'];
    int? moduleId = params['moduleId'];
    int? unitId = params['unitId'];
    if(courseId == null || moduleId == null || unitId == null) return [];
    
    try {
      ToastUtils.showLoading();
      UnitKnowledgePointsEntity? entity = await OfficialCourseDetailsRequest.getUnitTarget(
        courseId, 
        moduleId, 
        unitId,  
        contentTypes: contentTypes,
      );  
      if(entity == null) return [];
      List<UnitKnowledgePointsEntityKnowledgeList?>? knowledgeList = entity.knowledgeList;
      if(knowledgeList == null) return [];

      List<UnitKnowledgePointsEntityKnowledgeList> pageKnowledgeList = [];
      for(var item in knowledgeList){
        if(item == null) continue;
        pageKnowledgeList.add(item);
      }
      
      // 排序 按照单词 短语 句子 排序
      pageKnowledgeList.sort((a, b) {
        int getPriority(UnitKnowledgePointsEntityKnowledgeList item) {
          if (item.isWord) return 0;
          if (item.isPhrase) return 1;
          if (item.isSentence) return 2;
          if (item.isSong) return 3;
          return 3; // 其他类型排在最后
        }
        return getPriority(a).compareTo(getPriority(b));
      });
      
      return pageKnowledgeList;

    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 获取今日新学的知识点题目
  Future<List<QuizModel>> getTodayNewKnowledgeQuiz() async{
    try {
      ToastUtils.showLoading();
      QuizListEntity? quizListEntity = await MissionRequest.getTodayNewKnowledgeQuiz();
      if(quizListEntity == null) return [];
      if(quizListEntity.list == null) return [];
      List<QuizModel?> list = quizListEntity.list??[];
      List<QuizModel> quizList = [];
      for(var item in list){
        if(item == null) continue;
        quizList.add(item);
      }
      return quizList;
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 获取今日所有的知识点题目
  Future<List<QuizModel>> getTodayAllKnowledgeQuiz() async{
    try {
      ToastUtils.showLoading();
      QuizListEntity? quizListEntity = await MissionRequest.getTodayKnowledgeQuiz();
      if(quizListEntity == null) return [];
      if(quizListEntity.list == null) return [];
      List<QuizModel?> list = quizListEntity.list??[];
      List<QuizModel> quizList = [];
      for(var item in list){
        if(item == null) continue;
        quizList.add(item);
      }
      return quizList;
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 获取今日新学的知识点
  Future<List<UnitKnowledgePointsEntityKnowledgeList>> getTodayNewKnowledge() async{
    try {
      ToastUtils.showLoading();
      TodayKnowledgeEntity? todayKnowledgeEntity = await MissionRequest.getTodayNewKnowledge();
      if(todayKnowledgeEntity == null) return [];
      if(todayKnowledgeEntity.list == null) return [];
      List<UnitKnowledgePointsEntityKnowledgeList?> list = todayKnowledgeEntity.list??[];
      List<UnitKnowledgePointsEntityKnowledgeList> knowledgeList = [];
      for(var item in list){
        if(item == null) continue;
        knowledgeList.add(item);
      }
      // 排序 按照单词 短语 句子 排序
      knowledgeList.sort((a, b) {
        int getPriority(UnitKnowledgePointsEntityKnowledgeList item) {
          if (item.isWord) return 0;
          if (item.isPhrase) return 1;
          if (item.isSentence) return 2;
          if (item.isSong) return 3;
          return 3; // 其他类型排在最后
        }
        return getPriority(a).compareTo(getPriority(b));
      });
      return knowledgeList;
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 获取今日所有的知识点
  Future<List<UnitKnowledgePointsEntityKnowledgeList>> getTodayAllKnowledge() async{
    try {
      ToastUtils.showLoading();
      TodayKnowledgeEntity? todayKnowledgeEntity = await MissionRequest.getTodayKnowledge();
      if(todayKnowledgeEntity == null) return [];
      if(todayKnowledgeEntity.list == null) return [];
      List<UnitKnowledgePointsEntityKnowledgeList?> list = todayKnowledgeEntity.list??[];
      List<UnitKnowledgePointsEntityKnowledgeList> knowledgeList = [];
      for(var item in list){
        if(item == null) continue;
        knowledgeList.add(item);
      }
      // 排序 按照单词 短语 句子 排序
      knowledgeList.sort((a, b) {
        int getPriority(UnitKnowledgePointsEntityKnowledgeList item) {
          if (item.isWord) return 0;
          if (item.isPhrase) return 1;
          if (item.isSentence) return 2;
          if (item.isSong) return 3;
          return 3; // 其他类型排在最后
        }
        return getPriority(a).compareTo(getPriority(b));
      });
      return knowledgeList;
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 听读一体
  Future<void> readingIntegrated(TaskMissionMenuListEntityList item) async{
    if(item.jump == null) return;
    await JumpPageUtils.jumpUserPages(item.jump!.code, item.jump!.params);
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
