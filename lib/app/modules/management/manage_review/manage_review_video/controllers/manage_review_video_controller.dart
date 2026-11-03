import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../routes/routes.dart';
import '../../../dialog/dialogs.dart';
import '../../../utils/utils.dart';
import '../model/video_rame_mode_enum.dart';
import '../model/video_task_status_enum.dart';

class ManageReviewVideoController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageReviewVideoController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_REVIEW_VIDEO;

  @override
  String get breadcrumbTitle => '视频审核';

  /// 传进来的参数 {'uid': 0, 'type': 'EN_TEXT', 'semanticId': null}
  Map<String, dynamic>? subContent;

  /// 是否 按 条件查询
  final RxBool isSubConditionQuery = false.obs;


  /// 状态筛选
  final Rx<VideoTaskStatusEnum> statusFilter = VideoTaskStatusEnum.all.obs;

  /// 帧模式筛选
  final Rx<VideoRameModeEnum> rameMode = VideoRameModeEnum.all.obs;

  ///　所有数据
  final Rx<VideoTaskEntity> allData = VideoTaskEntity().obs;

  /// 原始列表数据
  final RxList<VideoTaskEntityList> originalTaskList = <VideoTaskEntityList>[].obs;

  /// 列表数据
  final RxList<VideoTaskEntityList> taskList = <VideoTaskEntityList>[].obs;

  /// load status  -1=loading  0=empty  1=success
  final RxInt loadStatus = (-1).obs;



  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if(Get.arguments != null){
      subContent = Get.arguments['subContent'];
      isSubConditionQuery.value = subContent != null;
    }
    getTaskList();
  }


  /// 获取任务列表
  Future<void> getTaskList({bool showLoading = true, bool reStatus = false}) async{
    try {
      if(reStatus) loadStatus.value = -1;
      if(showLoading) ToastUtils.showLoading();
      Map<String, dynamic> reqData = {};
      if(statusFilter.value != VideoTaskStatusEnum.all){
        reqData['taskStatus'] = statusFilter.value.value;
      }
      if(subContent != null){
        reqData['subContent'] = subContent;
      }
      VideoTaskEntity? response = await LanguageUtil.getVideoTaskList(data: reqData);
      if(response == null) {
        loadStatus.value = 0;
        return;
      }
      allData.value = response;

      List<VideoTaskEntityList?> list = response.list ?? [];
      taskList.clear();
      originalTaskList.clear();
      for(VideoTaskEntityList? item in list){
        if(item == null) continue;
        originalTaskList.add(item);
        taskList.add(item);
      }

      if(originalTaskList.isEmpty){
        loadStatus.value = 0;
      }else{
        loadStatus.value = 1;
      }
      
    } finally{
      if(showLoading) ToastUtils.hideLoading();
    }
  }


  /// 切换状态
  void chanageFilterStatus(VideoTaskStatusEnum status){
    statusFilter.value = status;
    _applyFilters();
  }

  /// 切换帧模式
  void chanageFilterRameMode(VideoRameModeEnum ream){
    rameMode.value = ream;
    _applyFilters();
  }

  /// 应用所有筛选条件
  void _applyFilters(){
    List<VideoTaskEntityList> result = originalTaskList.toList();

    // 应用状态筛选
    if(statusFilter.value != VideoTaskStatusEnum.all){
      result = result.where((element) => element.status == statusFilter.value.value).toList();
    }

    // 应用帧模式筛选
    if(rameMode.value != VideoRameModeEnum.all){
      result = result.where((item) => _matchRameMode(item, rameMode.value)).toList();
    }

    taskList.value = result;
  }

  /// 判断是否匹配帧模式
  bool _matchRameMode(VideoTaskEntityList item, VideoRameModeEnum mode){
    List<VideoTaskEntityListFrames?> frames = item.frames ?? [];
    switch(mode){
      case VideoRameModeEnum.all:
        return true;
      case VideoRameModeEnum.firstFrame:
        return frames.isNotEmpty && frames.first?.index == 0;
      case VideoRameModeEnum.firstAndLastFrame:
        bool isFirstFrame = frames.isNotEmpty && frames.first?.index == 0;
        bool isLastFrame = frames.isNotEmpty && frames.firstWhereOrNull((element) => element?.index == -1) != null;
        return isFirstFrame && isLastFrame;
      case VideoRameModeEnum.multiFrame:
        return frames.length > 2;
    }
  }


  /// 升级为首尾帧模式
  Future<void> upgradeToFirstLastFrameMode(VideoTaskEntityList? item) async{
    if(item == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "videoTaskId": item.taskId,
      };
      String? response = await LanguageConsoleRequest.upgradeToFirstLastFrameMode(data: reqData);
      if(response == null) return;
      ToastUtils.showToast(text: response, type: ToastType.success);
      originalTaskList.removeWhere((element) => element.taskId == item.taskId);
      taskList.removeWhere((element) => element.taskId == item.taskId);
      if(taskList.isNotEmpty) await getTaskList();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 编辑图片提示词
  Future<void> editImagePrompt(BuildContext context, VideoTaskEntityListFrames? prompt) async{
    if(prompt == null) return;
    String? result = await PromptInputDialog.show(context: context, prompt: prompt.prompt);
    if(result == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "promptId": prompt.promptId,
        "prompt": result,
      };
      bool response = await LanguageConsoleRequest.editImagePrompt(data: reqData);
      if(!response) return;
      ToastUtils.showToast(text: '修改成功', type: ToastType.success);
      prompt.prompt = result;
      taskList.refresh();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 重新生成图片提示词和图片
  Future<void> reGenerateImagePrompt(VideoTaskEntityList data, VideoTaskEntityListFrames? frame) async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "videoTaskId": data.taskId,
        "frameIndex": frame?.index,
      };
      String? response = await LanguageConsoleRequest.reGenerateImagePrompt(data: reqData);
      if(response == null) return;
      ToastUtils.showToast(text: response, type: ToastType.success);
      originalTaskList.removeWhere((element) => element.taskId == data.taskId);
      taskList.removeWhere((element) => element.taskId == data.taskId);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 用提示词重新生成图片
  Future<void> reGenerateImageByPrompt(VideoTaskEntityList data, VideoTaskEntityListFrames? frame) async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "videoTaskId": data.taskId,
        "frameIndex": frame?.index,
        "imageTaskId": frame?.imageTaskId,
      };
      String? response = await LanguageConsoleRequest.reGenerateImage(data: reqData);
      if(response == null) return;
      ToastUtils.showToast(text: response, type: ToastType.success);
      originalTaskList.removeWhere((element) => element.taskId == data.taskId);
      taskList.removeWhere((element) => element.taskId == data.taskId);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 图片审核通过
  Future<void> imageReviewPass(VideoTaskEntityList? item, VideoTaskEntityListFrames? frame) async{
    if(frame == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "imageIdSelected": frame.selectedImageId,
        "imageTaskId": frame.imageTaskId,
      };
      bool response = await LanguageUtil.videoImageReviewPass(data: reqData);
      if(!response) return;
      originalTaskList.removeWhere((element) => element.taskId == item?.taskId);
      taskList.removeWhere((element) => element.taskId == item?.taskId);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 删除任务
  Future<void> deleteTask(BuildContext context, VideoTaskEntityList? item) async{
    if(item == null) return;

    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: '删除任务',
      content: '确定删除任务吗？',
      titleColor: AppTheme.cFeedbackErrorText.color,
      defineColor: AppTheme.cFeedbackErrorText.color,
    );
    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "videoTaskId": item.taskId,
      };
      bool response = await LanguageConsoleRequest.deleteVideoTask(data: reqData);
      if(!response) return;
      ToastUtils.showToast(text: '删除成功', type: ToastType.success);
      originalTaskList.removeWhere((element) => element.taskId == item.taskId);
      taskList.removeWhere((element) => element.taskId == item.taskId);
      if(taskList.isNotEmpty) await getTaskList();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 放弃任务
  Future<void> giveUpTask(BuildContext context, VideoTaskEntityList? item, {bool showDialog = true}) async{
    if(item == null) return;

    if(showDialog){
      bool askRes = await AskDialog.showUserAsk(
        context: context,
        title: '放弃任务',
        content: '确定放弃此任务吗？',
      );
      if(!askRes) return;
    }

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "videoTaskId": item.taskId,
      };
      bool response = await LanguageUtil.videoReviewGiveUp(data: reqData);
      if(!response) return;
      ToastUtils.showToast(text: '放弃成功', type: ToastType.success);
      originalTaskList.removeWhere((element) => element.taskId == item.taskId);
      taskList.removeWhere((element) => element.taskId == item.taskId);
      if(taskList.isNotEmpty) await getTaskList();
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 跳转至视频详情
  Future<void> toVideoDetail(VideoTaskEntityList? item, {VideoTaskEntityListVideos? video}) async{
    if(item == null) return;

    dynamic res = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_VIDEO_DETILS, 
      arguments: {
        "videoTaskId": item.taskId,
        "currentVideoId": video?.videoId,
      },
    );
    if(taskList.isNotEmpty) await getTaskList();
    if(res == null) return;
    if(res['type'] == "remove"){
      originalTaskList.removeWhere((element) => element.taskId == item.taskId);
      taskList.removeWhere((element) => element.taskId == item.taskId);
    }
  }


  /// 查看此任务已审核视频
  Future<void> taskReviewedVideo(BuildContext context, VideoTaskEntityList? item) async{
    if(item?.taskId == null) return;
    bool res = await ManagePlayApprovedVideo.show(context: context, videoTaskId: item!.taskId!);
    if(!res) return;

    // 选择的 沿用已有视频 先调用放弃接口
    giveUpTask(context, item, showDialog: false);
  }

  /// 跳转至审核历史页面
  Future<void> toVideoReviewHistory(bool fromAdmin) async{

    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_VIDEO_HISTORY, 
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
