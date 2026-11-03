import 'dart:async';

import 'package:get/get.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../utils/utils.dart';

class ManageReviewAssController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageReviewAssController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_REVIEW_ASS;

  @override
  String get breadcrumbTitle => '审核字幕';

  /// 知识点 传进来的参数 
  List<int>? taskIds;

  /// 是否 按 条件查询
  final RxBool isSubConditionQuery = false.obs;

  ///　所有数据
  final Rx<AssTaskEntity> allData = AssTaskEntity().obs;

  /// 列表数据
  final RxList<AssTaskEntityList> taskList = <AssTaskEntityList>[].obs;

  /// load status  -1=loading  0=empty  1=success
  final RxInt loadStatus = (-1).obs;



  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if(Get.arguments != null){
      taskIds = Get.arguments['taskIds'];
      isSubConditionQuery.value = taskIds != null;
    }
    getTaskList();
  }


  /// 查询字幕列表
  Future<void> getTaskList({bool showLoading = true, bool reStatus = false}) async{
    try {
      if(reStatus) loadStatus.value = -1;
      if(showLoading) ToastUtils.showLoading();
      Map<String, dynamic> reqData = {};
      if(taskIds != null){
        reqData['taskIds'] = taskIds;
      }
      AssTaskEntity? response = await LanguageUtil.getAssTaskList(data: reqData);
      if(response == null) {
        loadStatus.value = 0;
        return;
      }
      allData.value = response;

      List<AssTaskEntityList?> list = response.list ?? [];
      taskList.clear();
      for(AssTaskEntityList? item in list){
        if(item == null) continue;
        taskList.add(item);
      }

      if(taskList.isEmpty){
        loadStatus.value = 0;
      }else{
        loadStatus.value = 1;
      }
      
    } finally{
      if(showLoading) ToastUtils.hideLoading();
    }
  }

  /// 再来一批
  Future<void> getAssTaskAnotherBatch() async{
    try {
      loadStatus.value = -1;
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {};
      AssTaskEntity? response = await LanguageUtil.getAssTaskAnotherBatch(data: reqData);
      if(response == null) {
        loadStatus.value = 0;
        return;
      }
      allData.value = response;

      List<AssTaskEntityList?> list = response.list ?? [];
      taskList.clear();
      for(AssTaskEntityList? item in list){
        if(item == null) continue;
        taskList.add(item);
      }
      if(taskList.isEmpty){
        loadStatus.value = 0;
      }else{
        loadStatus.value = 1;
      }
      
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 去审核字幕
  Future<void> toReviewAss(AssTaskEntityList data) async{
    if(data.taskId == null) return;

    if(data.stageEnum == ResourceAlignEnum.align){
      /// 审核字幕
      dynamic res = await ManagePageRegistry.jumpTo(
        Routes.MANAGE_REVIEW_ASS_DETILS,
        arguments: {
          "assTaskId": data.taskId,
        },
      );
      if(res == null) return;
      taskList.removeWhere((e) => e.taskId == data.taskId);
      return;
    }

    // TTOD: 审核翻译
    dynamic res = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_ASS_TRANSLATE,
      arguments: {
        "assTaskId": data.taskId,
      },
    );
    if(res == null) return;
    taskList.removeWhere((e) => e.taskId == data.taskId);
    return;
   
  }

    /// 跳转至审核历史页面
  Future<void> toReviewHistory(bool fromAdmin) async{

    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_ASS_HISTORY, 
      arguments: {
        "fromAdmin": fromAdmin,
      },
    );

    if(taskList.isNotEmpty) await getTaskList();
  }


  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
