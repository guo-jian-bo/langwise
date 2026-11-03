import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:quiz_play/models/models.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../routes/routes.dart';
import '../../../utils/manage_auth_utils.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';

class ManageReviewExercisesController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageReviewExercisesController({required this.tag});

  int? lessonId;

  /// 外部传进来的任务ids 如果不为null 说明是要根据ids查询 审核完这些之后 不需要再来一批
  List<int?>? taskIds;

  /// 是否从ids查询
  bool isFromTaskIds = false;


  /// 原始题目数据
  final RxList<ExerciseReviewEntityList> originalExerciseReviewList = RxList<ExerciseReviewEntityList>();

  final RxList<ExerciseReviewEntityList> exerciseReviewList = RxList<ExerciseReviewEntityList>();

  /// 是否还有题目
  final RxBool hasMoreExercise = true.obs;

  final TextEditingController searchController = TextEditingController();
  

  @override
  String get breadcrumbRoute => Routes.MANAGE_REVIEW_EXERCISES;
  
  @override
  String get breadcrumbTitle => '审核题目';

  @override
  void onInit() {
    super.onInit();
    ManageAuthUtils.init();
    initBreadcrumb(tag);
    if(Get.arguments != null){
      taskIds = Get.arguments['taskIds'];
      lessonId = Get.arguments['lessonId'];
      isFromTaskIds = taskIds != null || lessonId != null;
    }
    getExerciseReviewList();
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
      ExerciseReviewEntity? entity = await ExerciseReviewRequest.getExerciseReviewList(reqData);
      if(entity == null) return;
      List<ExerciseReviewEntityList?>? list = entity.list??[];
      exerciseReviewList.clear();
      originalExerciseReviewList.clear();
      for(int i = 0; i < list.length; i++){
        if(list[i] == null) continue;
        exerciseReviewList.add(list[i]!);
        originalExerciseReviewList.add(list[i]!);
      }

      hasMoreExercise.value = originalExerciseReviewList.isNotEmpty;
      
    } finally{
      ToastUtils.hideLoading();
    }
  } 


  /// 重新生成
  Future<void> reGenerate(BuildContext context, ExerciseReviewEntityList entity) async{
    if(exerciseReviewList.isEmpty) return;

    bool ask = await AskDialog.showUserAsk(
      context: context,
      title: "重新生成",
      content: "确定重新生成吗？",
    );
    if(!ask) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "taskId": entity.taskId,
      };
      bool res = await ExerciseReviewRequest.reGenerate(reqData);
      if(!res) return;
      ToastUtils.showToast(text: "提交成功", type: ToastType.success);
      exerciseReviewList.removeWhere((element) => element.taskId == entity.taskId);
      originalExerciseReviewList.removeWhere((element) => element.taskId == entity.taskId);
      taskIds?.remove(entity.taskId);
      resetSearch();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 题目有错误
  Future<void> exercisesErr(BuildContext context, ExerciseReviewEntityList entity, int score) async{
    
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "taskId": entity.taskId,
        "score": score,
      };
      bool res = await ExerciseReviewRequest.exerciseErr(reqData);
      if(!res) return;
      exerciseReviewList.removeWhere((element) => element.taskId == entity.taskId);
      originalExerciseReviewList.removeWhere((element) => element.taskId == entity.taskId);
      taskIds?.remove(entity.taskId);
      resetSearch();
      ToastUtils.showToast(text: "提交成功", type: ToastType.success);
      
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 审核通过
  Future<void> approved(BuildContext context, ExerciseReviewEntityList entity, int score) async{
    if(exerciseReviewList.isEmpty) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "taskId": entity.taskId,
        "score": score,
      };
      bool res = await ExerciseReviewRequest.approved(reqData);
      if(!res) return;
      ToastUtils.showToast(text: "提交成功", type: ToastType.success);
      exerciseReviewList.removeWhere((element) => element.taskId == entity.taskId);
      originalExerciseReviewList.removeWhere((element) => element.taskId == entity.taskId);
      taskIds?.remove(entity.taskId);
      resetSearch();
    } finally{
      ToastUtils.hideLoading();
    }

  }


  /// 再来一批
  Future<void> getMoreExerciseReviewList() async {
    try {
      ToastUtils.showLoading();
      ExerciseReviewEntity? entity = await ExerciseReviewRequest.getMoreExerciseReviewList();
      if(entity == null) return;
      List<ExerciseReviewEntityList?>? list = entity.list??[];
      exerciseReviewList.clear();
      originalExerciseReviewList.clear();
      for(int i = 0; i < list.length; i++){
        if(list[i] == null) continue;
        exerciseReviewList.add(list[i]!);
        originalExerciseReviewList.add(list[i]!);
      }

      hasMoreExercise.value = originalExerciseReviewList.isNotEmpty;
      
    } finally{
      ToastUtils.hideLoading();
    }
  }



  /// 演示题目
  Future<void> demoExercise(BuildContext context, ExerciseReviewEntityList entity) async{
    if(entity.taskId == null) return;
    dynamic res = await Get.toNamed(
      Routes.PRACTICE_QUESTIONS_REVIEW,
      arguments: {
        "taskIds": [entity.taskId],
        "isAdminPage": true,
      },
    );
    if(res == null) return;
    List<int>? ids = res as List<int>?;
    if(ids == null || ids.isEmpty) return;
    taskIds?.removeWhere((element) => ids.contains(element));
    
    getExerciseReviewList();
  }

  /// 逐个审核
  Future<void> oneByOneExercise() async{
    if(!hasMoreExercise.value) {
      ToastUtils.showToast(text: "当前没有题目");
      return;
    }
    dynamic res = await Get.toNamed(
      Routes.PRACTICE_QUESTIONS_REVIEW,
      arguments: {
        "taskIds": taskIds,
        "lessonId": lessonId,
        "isAdminPage": true,
      },
    );
    if(res == null) return;
    List<int>? ids = res as List<int>?;
    if(ids == null || ids.isEmpty) return;
    taskIds?.removeWhere((element) => ids.contains(element));
    if(taskIds?.isEmpty??true){
      originalExerciseReviewList.clear();
      exerciseReviewList.clear();
      resetSearch();
    }
    if(isFromTaskIds) return;
    getExerciseReviewList();
  }


  /// 搜索知识点
  Future<void> searchKnowledge() async{
    exerciseReviewList.clear();

    if(searchController.text.trim().isEmpty){
      exerciseReviewList.addAll(originalExerciseReviewList.toList());
      return;
    }

    // 匹配原始列表中的知识点

    String searchValue = searchController.text.trim().toLowerCase();
    for(int i = 0; i < originalExerciseReviewList.length; i++){
      ExerciseReviewEntityList item = originalExerciseReviewList[i];
      
      List<QuizModelStems?> stems = item.exercise?.stems??[];

      bool isMatch = false;

      for(int j = 0; j < stems.length; j++){
        if(stems[j] == null) continue;
        QuizModelStems stem = stems[j]!;
        if(stem.text?.toLowerCase().contains(searchValue)??false){
          isMatch = true;
          break;
        }
      }

      if(isMatch){
        exerciseReviewList.add(item);
        continue;
      }

      List<QuizModelOptions?> options = item.exercise?.options??[];

      for(int j = 0; j < options.length; j++){
        if(options[j] == null) continue;
        QuizModelOptions option = options[j]!;
        if(option.text?.toLowerCase().contains(searchValue)??false){
          isMatch = true;
          break;
        }
      }

      if(isMatch){
        exerciseReviewList.add(item);
        continue;
      }
    }

  }

  /// 如果没有题目了 就还原搜索
  void resetSearch() {
    hasMoreExercise.value = originalExerciseReviewList.isNotEmpty;

    if(!hasMoreExercise.value || exerciseReviewList.isEmpty){
      searchController.clear();
      exerciseReviewList.clear();
      exerciseReviewList.addAll(originalExerciseReviewList.toList());
    }
   
  }





  /// 审核历史
  Future<void> toExerciseReviewHistory(bool fromAdmin) async {
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_EXERCISES_HISTORY,
      arguments: {
        "fromAdmin": fromAdmin,
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
