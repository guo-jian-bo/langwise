import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_play/quiz_play.dart';
import 'package:quiz_play/utils/oral_evaluation_service.dart' as oral_evaluation_service;
import 'package:quiz_play/utils/recording_server_utils.dart' as recording_server_utils;
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/entities/third_party_account_entity.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../../../management/utils/utils.dart';

class PracticeQuestionsReviewController extends GetxController {

  /// 是否是管理端页面
  bool isAdminPage = false;
  int? lessonId;

  /// 是否是查询审核历史 为true说明是从审核历史进来的 需要根据taskIds去调用审核历史详情的接口
  bool isReviewHistory = false;

  /// 外部传进来的任务ids 如果不为null 说明是要根据ids查询 审核完这些之后 不需要再来一批
  List<int?>? taskIds;

  

  /// 题目控制器
  final StreamController<QuizStateType> quizStateController = StreamController<QuizStateType>.broadcast();

  /// 声通账号
  final Rx<ThirdPartyAccountEntityList> soundAccount = ThirdPartyAccountEntityList().obs;

  /// 题目列表
  final RxList<ExerciseReviewEntityList> exerciseReviewList = RxList<ExerciseReviewEntityList>();

  /// 当前审核到的题目下标
  final RxInt currentQuizIndex = 0.obs;
  final RxInt previousQuizIndex = 0.obs;

  /// 当前题目是否执行完
  final RxBool isReviewCurrentQuestion = false.obs;

  /// 已经审核/删除/放弃/重新生成的taskIds
  List<int> approvedTaskIds = [];

  /// 是否审核完所有题目
  final RxBool isReviewAll = false.obs;

  /// 再做一遍 key
  final RxInt reGenerateKey = 0.obs;

  /// 是否正在提交 如果正在提交那么不允许改变底部按钮状态
  bool isSubmit = false;


  
  @override
  void onInit() {
    super.onInit();
    WakelockPlus.enable();
    if(Get.arguments != null){
      taskIds = Get.arguments['taskIds'];
      lessonId = Get.arguments['lessonId'];
      isReviewHistory = Get.arguments['isReviewHistory']??false;
      isAdminPage = Get.arguments['isAdminPage'] ?? false;
    }
    initSetting();
  }

  Future<void> initSetting() async {
    try {
      ToastUtils.showLoading();
      await getThirdPartyAccount();
      await getExerciseReviewList();
    } finally {
      ToastUtils.hideLoading();
    }
  }


  /// 获取声通账号
  Future<void> getThirdPartyAccount() async {
    try {
      ThirdPartyAccountEntityList? account = await Get.find<ConfigController>().getThirdPartyAccountByCode(ThirdPartyAccountEnum.stkouyu);
      if (account == null) {
        ToastUtils.showToast(text: "获取评测配置失败，请稍后重试");
        return;
      }
      soundAccount.value = account;
     
    } catch (_){}
  }


  /// 获取待审核题目列表
  Future<void> getExerciseReviewList() async {
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {};
      if(lessonId != null){
        reqData["lessonIds"] = [lessonId];
      }else if(taskIds != null && taskIds!.isNotEmpty){
        reqData["taskIds"] = taskIds;
      }

      // 根据 isReviewHistory 区分 接口
      if(isReviewHistory){
        ListResponseEntity<ExerciseReviewEntityList>? response = await ExerciseReviewRequest.getExerciseReviewHistoryList({}, reqData);
        if(response == null) return;
        List<ExerciseReviewEntityList>? list = response.datas??[];
        exerciseReviewList.value = list;
      }else{
        ExerciseReviewEntity? entity = await ExerciseReviewRequest.getExerciseReviewList(reqData);
        if(entity == null) return;
        List<ExerciseReviewEntityList?>? list = entity.list??[];
        exerciseReviewList.clear();
        for(int i = 0; i < list.length; i++){
          if(list[i] == null) continue;
          exerciseReviewList.add(list[i]!);
        }
        
      }
      

      reGenerateKey.value = 0;
      isReviewAll.value = exerciseReviewList.isEmpty;
      isReviewCurrentQuestion.value = false;
      currentQuizIndex.value = 0;
      
    } finally{
      ToastUtils.hideLoading();
    }
  } 



  /// 完成题目
  void onFinish(){
    if(isSubmit) return;
    isReviewCurrentQuestion.value = true;
  }
  

  /// 再做一遍
  void reGenerateQuiz(){
    if(exerciseReviewList.length <= currentQuizIndex.value) return;
    isReviewCurrentQuestion.value = false;
    reGenerateKey.value++;
  }




  /// 删除题目
  Future<void> deleteExercis(BuildContext context) async{
    if(exerciseReviewList.length <= currentQuizIndex.value) return;
    ExerciseReviewEntityList entity = exerciseReviewList[currentQuizIndex.value];

    bool ask = await AskDialog.showUserAsk(
      context: context,
      title: "删除题目",
      content: "确定删除该题目吗？",
      contentColor: AppTheme.cSurfaceError.color,
      defineColor: AppTheme.cSurfaceError.color,
    );
    if(!ask) return;

    try {
      isSubmit = true;
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "taskId": entity.taskId,
      };
      bool res = await ExerciseReviewRequest.deleteTask(reqData);
      if(!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      if(entity.taskId != null){
        if(!approvedTaskIds.contains(entity.taskId!)){
          approvedTaskIds.add(entity.taskId!);
        }
      }
      await nextQuestion();
    } finally{
      ToastUtils.hideLoading();
      isSubmit = false;
    }
  }

  /// 放弃
  Future<void> giveUp(BuildContext context) async{
    if(exerciseReviewList.length <= currentQuizIndex.value) return;
    ExerciseReviewEntityList entity = exerciseReviewList[currentQuizIndex.value];

    try {
      isSubmit = true;
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "taskId": entity.taskId,
      };
      bool res = await ExerciseReviewRequest.giveUp(reqData);
      if(!res) return;
      if(entity.taskId != null){
        if(!approvedTaskIds.contains(entity.taskId!)){
          approvedTaskIds.add(entity.taskId!);
        }
      }
      await nextQuestion();
    } finally{
      ToastUtils.hideLoading();
      isSubmit = false;
    }
  }

  /// 重新生成
  Future<void> reGenerate(BuildContext context) async{
    if(exerciseReviewList.length <= currentQuizIndex.value) return;
    ExerciseReviewEntityList entity = exerciseReviewList[currentQuizIndex.value];

    bool ask = await AskDialog.showUserAsk(
      context: context,
      title: "重新生成",
      content: "确定重新生成吗？",
    );
    if(!ask) return;

    try {
      isSubmit = true;
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "taskId": entity.taskId,
      };
      bool res = await ExerciseReviewRequest.reGenerate(reqData);
      if(!res) return;
      ToastUtils.showToast(text: "提交成功", type: ToastType.success);
      if(entity.taskId != null){
        if(!approvedTaskIds.contains(entity.taskId!)){
          approvedTaskIds.add(entity.taskId!);
        }
      }
      await nextQuestion();
    } finally{
      ToastUtils.hideLoading();
      isSubmit = false;
    }
  }

  /// 题目有错误
  Future<void> exercisesErr(BuildContext context, int score) async{
    if(exerciseReviewList.length <= currentQuizIndex.value) return;
    ExerciseReviewEntityList entity = exerciseReviewList[currentQuizIndex.value];
    
    try {
      isSubmit = true;
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "taskId": entity.taskId,
        "score": score,
      };
      bool res = await ExerciseReviewRequest.exerciseErr(reqData);
      if(!res) return;
      if(entity.taskId != null){
        if(!approvedTaskIds.contains(entity.taskId!)){
          approvedTaskIds.add(entity.taskId!);
        }
      }
      ToastUtils.showToast(text: "提交成功", type: ToastType.success);
      await nextQuestion();
      
    } finally{
      ToastUtils.hideLoading();
      isSubmit = false;
    }
  }


  /// 审核通过
  Future<void> approved(BuildContext context, int score) async{
    if(exerciseReviewList.length <= currentQuizIndex.value) return;
    ExerciseReviewEntityList entity = exerciseReviewList[currentQuizIndex.value];

    try {
      isSubmit = true;
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "taskId": entity.taskId,
        "score": score,
      };
      bool res = await ExerciseReviewRequest.approved(reqData);
      if(!res) return;
      if(entity.taskId != null){
        if(!approvedTaskIds.contains(entity.taskId!)){
          approvedTaskIds.add(entity.taskId!);
        }
      }
      ToastUtils.showToast(text: "提交成功", type: ToastType.success);
      await nextQuestion();
      
    } finally{
      ToastUtils.hideLoading();
      isSubmit = false;
    }

  }

  /// 编辑题目
  Future<void> editExercises() async{
    if(!isAdminPage) return;
    if(exerciseReviewList.length <= currentQuizIndex.value) return;
    ExerciseReviewEntityList entity = exerciseReviewList[currentQuizIndex.value];

    String? manageRoute = QuizRoutesUtils.getEditQuizRouteNameByContentType(entity.type);
    if (manageRoute == null || manageRoute == "") {
      ToastUtils.showManageToast(text: "不支持编辑此类型题目");
      return;
    }
    exitReview();
    await ManagePageRegistry.jumpTo(
      manageRoute,
      arguments: {
        "quizId": entity.exerciseId,
      },
    );
  }


  /// 再来一批
  Future<void> getMoreExerciseReviewList() async {
    try {
      ToastUtils.showLoading();
      ExerciseReviewEntity? entity = await ExerciseReviewRequest.getMoreExerciseReviewList();
      if(entity == null) return;
      List<ExerciseReviewEntityList?>? list = entity.list??[];
      exerciseReviewList.clear();
      for(int i = 0; i < list.length; i++){
        if(list[i] == null) continue;
        exerciseReviewList.add(list[i]!);
      }

      reGenerateKey.value = 0;
      isReviewAll.value = false;
      isReviewCurrentQuestion.value = false;
      currentQuizIndex.value = 0;
      
    } finally{
      ToastUtils.hideLoading();
    }
  }



  /// 下一个题目
  Future<void> nextQuestion() async {
    
    if(currentQuizIndex.value >= exerciseReviewList.length - 1) {
      // 证明没有题目了
      isReviewAll.value = true; 
      if(taskIds != null || lessonId != null){
        Future.delayed(const Duration(milliseconds: 300), () {
          exitReview();
        });
      }
      return;
    }
    reGenerateKey.value = 0;
    isReviewCurrentQuestion.value = false;
    currentQuizIndex.value++;
    await Future.delayed(const Duration(milliseconds: 500));
    

  }


  /// 审核历史
  Future<void> toReviewHistory({bool fromAdmin = false}) async{
    exitReview();
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_EXERCISES_HISTORY,
      arguments: {
        "fromAdmin": fromAdmin,
      },
    );
  }


  /// 退出审核
  void exitReview() {
   // 是否审核了题目
   Get.back(result: approvedTaskIds.isEmpty ? null : approvedTaskIds);
  }



  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    try {
      oral_evaluation_service.OralEvaluationHttpService.instance.disposeWebSocket();
      recording_server_utils.RecordingServerUtils.instance.dispose();
      WakelockPlus.disable();
      quizStateController.close();
    } catch (_) {
    }
    super.onClose();
  }

}
