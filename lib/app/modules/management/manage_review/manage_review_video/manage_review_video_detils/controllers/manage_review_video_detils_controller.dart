


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../dialog/dialogs.dart';
import '../../../../enums/video_aspect_ratio_enum.dart';
import '../../../../utils/utils.dart';
import '../../../../common/video_edit_widget.dart';
import '../views/manage_review_video_detils_edit_dialog.dart';


class ManageReviewVideoDetilsController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageReviewVideoDetilsController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_REVIEW_VIDEO_DETILS;

  @override
  String get breadcrumbTitle => '视频详情';


  /// 页面参数 - 视频任务ID
  int? videoTaskId;
  /// 页面参数 - 视频id
  int? videoRelationId;
  /// 页面参数 - 视频ID
  int? videoId;
  /// 页面参数 - 当前视频ID
  int? currentVideoId;
  /// 是否是管理员进入（从知识点进入）
  bool isAdminPage = false;
  /// 是否隐藏重新生成提示词和视频按钮
  bool isHideRegenerateBtn = false;
  /// 默认的比例
  VideoAspectRatioEnum? defaultAspectRatio;

  /// 视频详情数据
  final Rx<VideoTaskEntityList> videoData = VideoTaskEntityList().obs;

  /// 视频列表
  final RxList<VideoTaskEntityListVideos> videoList = <VideoTaskEntityListVideos>[].obs;
  /// 当前视频索引
  final RxInt currentVideoIndex = 0.obs;

  /// 帧信息是否展开
  final Rx<bool> isFrameImageExpanded = true.obs;

  /// 视频信息是否展开
  final Rx<bool> isVideoInfoExpanded = true.obs;
  /// 视频的实际时长 解析出视频后赋值
  final Rx<Duration> actualDuration = Duration.zero.obs;
  /// 当前播放的视频位置
  final Rx<Duration> onVideoPosition = Duration.zero.obs;
  
  /// 视频时长
  final RxInt videoDuration = 0.obs;
  /// 编辑时长 - 可选择的视频时长列表
  final List<int> editVideoDurationList = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,21,22,23,24,25,26,27,28,29,30,];
  /// 编辑时长 - 选择的视频时长
  final RxInt editSelectVideoDuration = 0.obs;
  /// 视频分辨率宽
  final RxInt videoWidth = 0.obs;
  /// 视频分辨率高
  final RxInt videoHeight = 0.obs;
  /// 编辑分辨率 - 可选择的视频分辨率列表
  final List<VideoAspectRatioEnum> editVideoAspectRatioList = VideoAspectRatioEnum.values;
  /// 编辑分辨率 - 选择的视频分辨率
  final Rx<VideoAspectRatioEnum> editSelectVideoAspectRatio = VideoAspectRatioEnum.ratio_1_1.obs;
  /// 编辑分辨率 - 可选择的视频清晰度
  final List<VideoQualityEnum> editVideoQualityList = VideoQualityEnum.values;
  /// 编辑分辨率 - 选择的视频清晰度值
  final Rx<VideoQualityEnum> editSelectVideoQualityValue = VideoQualityEnum.quality_2k.obs;
  /// 视频区域编辑状态 0-未编辑 1-编辑时长 2-编辑分辨率
  final RxInt videoEditStatus = 0.obs;
  /// 视频裁剪区域开始时长 秒
  final Rx<Duration> videoCropStartDuration = Duration.zero.obs;
  /// 视频裁剪区域结束时长 秒
  final Rx<Duration> videoCropEndDuration = Duration.zero.obs;
  /// 视频是否静音
  final RxBool videoIsMute = false.obs;

  /// 场景引导是否展开
  final Rx<bool> isSceneGuideExpanded = true.obs;
  /// 场景引导是否编辑
  final RxBool isSceneGuideEditing = false.obs;
  /// 场景引导 - 场景焦点 文本
  final RxString sceneFocusText = "".obs;
  /// 场景引导 - 场景焦点 输入框
  final TextEditingController sceneFocusController = TextEditingController();
  ////场景引导 - 画面动态 文本
  final RxString suggestedMotionText = "".obs;
  /// 场景引导 - 画面动态 输入框
  final TextEditingController suggestedMotionController = TextEditingController();
  /// 场景引导 - 音频描述  文本
  final RxString suggestedAudioText = "".obs;
  /// 场景引导 - 音频描述  输入框
  final TextEditingController suggestedAudioController = TextEditingController();

  /// 视频提示词是否展开
  final Rx<bool> isPromptExpanded = true.obs;
  /// 视频提示词 - 编辑状态
  final RxBool isPromptEditing = false.obs;
  /// 视频提示词 - 文本
  final RxString videoPromptText = "".obs;
  /// 视频提示词 - 输入框
  final TextEditingController videoPromptController = TextEditingController();

  final VideoEditController videoEditController = VideoEditController();

  /// 台词输入框
  final RxList<TextEditingController> linesInputs = <TextEditingController>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if(Get.arguments != null){
      videoTaskId = Get.arguments['videoTaskId'];
      videoRelationId = Get.arguments['videoRelationId'];
      videoId = Get.arguments['videoId'];
      currentVideoId = Get.arguments['currentVideoId'];
      isAdminPage = Get.arguments['isAdminPage']??false;
      isHideRegenerateBtn = Get.arguments['isHideRegenerateBtn']??false;
      defaultAspectRatio = Get.arguments['defaultAspectRatio'];
      editSelectVideoAspectRatio.value = defaultAspectRatio??VideoAspectRatioEnum.ratio_1_1;
    }
    getTaskVideoData();
  }

  /// 获取任务列表
  Future<bool> getTaskVideoData({bool showLoading = true}) async{
    try {
      if(showLoading) ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "relationUid": videoRelationId,
        "videoTaskId": videoTaskId,
        "videoId": videoId,
      };
      VideoTaskEntityList? response = await LanguageUtil.videoGetInfos(parameters: parameters);
      if(response == null) return false;
      videoData.value = response;

      List<VideoTaskEntityListVideos?> videos = videoData.value.videos??[];
      if(videos.isEmpty) return false;
      
      VideoTaskEntityListVideos? video = videos.firstWhereOrNull((element) => element?.videoId == currentVideoId);
      if(video == null) {
        if(videos.isEmpty) return false;
        video = videos.first;
        if(video == null) return false;
      }
      
      videoDuration.value = video.duration??0;
      videoWidth.value = video.width??0;
      videoHeight.value = video.height??0;
      
      if(video.startSeconds != null){
        videoCropStartDuration.value = DateFormatUtil.secondsToDuration(video.startSeconds??0);
      }

      if(video.endSeconds != null){
        videoCropEndDuration.value = DateFormatUtil.secondsToDuration(video.endSeconds??0);
      }       

      videoIsMute.value = video.isMute??false;

      editSelectVideoDuration.value = videoDuration.value;

      VideoTaskEntityListFrames? firstFrame = videoData.value.frames?.first;

      sceneFocusText.value = firstFrame?.semanticFocus??"";
      sceneFocusController.text = firstFrame?.semanticFocus??"";

      suggestedMotionText.value = firstFrame?.suggestedMotion??"";
      suggestedMotionController.text = firstFrame?.suggestedMotion??"";

      suggestedAudioText.value = firstFrame?.suggestedAudio??"";
      suggestedAudioController.text = firstFrame?.suggestedAudio??"";

      videoPromptText.value = StringUtils.replaceAllLineBreak(videoData.value.videoPrompt??"");
      videoPromptController.text = StringUtils.replaceAllLineBreak(videoData.value.videoPrompt??"");

      List<String?> lines = videoData.value.lines??[];
      linesInputs.clear();
      for (var element in lines) {
        if(element == null) continue;
        linesInputs.add(TextEditingController(text: element));
      }


      videoList.clear();
      for(var video in videos){
        if(video == null) continue;
        videoList.add(video);
      }
      currentVideoIndex.value = videoList.indexOf(video);

      return true;
      
    } finally{
      if(showLoading) ToastUtils.hideLoading();
    }
  }



  /// 切换帧图片展开状态
  void toggleFrameImageExpanded(){
    isFrameImageExpanded.value = !isFrameImageExpanded.value;
  }

  /// 切换视频信息展开状态
  void toggleVideoInfoExpanded(){
    isVideoInfoExpanded.value = !isVideoInfoExpanded.value;
  }

  /// 切换视频区域编辑状态 0-未编辑 1-编辑时长 2-编辑分辨率
  void toggleVideoEditStatus(int status){
    videoEditStatus.value = status;
    if(status == 0){ // 重置编辑选择的数据
      editSelectVideoDuration.value = videoDuration.value;
      editSelectVideoAspectRatio.value = VideoRatioQualityUtils.getAspectRatio(Size(videoWidth.value.toDouble(), videoHeight.value.toDouble()))??VideoAspectRatioEnum.ratio_1_1;
      editSelectVideoQualityValue.value = VideoRatioQualityUtils.getQuality(Size(videoWidth.value.toDouble(), videoHeight.value.toDouble()))??VideoQualityEnum.quality_2k;
    }
  }

  /// 编辑时长 - 选择时长
  void selectEditVideoDuration(int duration){
    if(editSelectVideoDuration.value == duration) return;
    editSelectVideoDuration.value = duration;
    videoDuration.value = duration;
    savePromptOtherEdit(showLoading: false);
  }

  /// 编辑时长 - 保存
  Future<void> saveEditVideoDuration() async{
    videoDuration.value = editSelectVideoDuration.value;
    bool res = await savePromptOtherEdit();
    if(!res) return;
    toggleVideoEditStatus(0);
  }

  /// 编辑分辨率 - 选择分辨率
  void selectEditVideoAspectRatio(VideoAspectRatioEnum aspectRatio){
    editSelectVideoAspectRatio.value = aspectRatio;
  }

  /// 编辑分辨率 - 选择清晰度
  void selectEditVideoQuality(VideoQualityEnum quality){
    editSelectVideoQualityValue.value = quality;
  }

  /// 编辑分辨率 - 保存
  void saveEditVideoAspectRatio(){
    Size size = VideoRatioQualityUtils.getSize(editSelectVideoAspectRatio.value, editSelectVideoQualityValue.value);
    videoWidth.value = size.width.toInt();
    videoHeight.value = size.height.toInt();
    toggleVideoEditStatus(0);
  }

  /// 根据视频比例合清晰度计算视频分辨率
  Size calculateVideoAspectRatio(){
    Size size = VideoRatioQualityUtils.getSize(editSelectVideoAspectRatio.value, editSelectVideoQualityValue.value);
    return size;
  }

  /// 场景引导 - 展开/收起
  void toggleSceneGuideExpanded(){
    isSceneGuideExpanded.value = !isSceneGuideExpanded.value;
  }

  /// 场景引导 - 展开编辑/收起编辑
  void toggleSceneGuideEditing(bool value){
    isSceneGuideEditing.value = value;
    if(value){
      sceneFocusController.text = sceneFocusText.value;
      suggestedMotionController.text = suggestedMotionText.value;
      suggestedAudioController.text = suggestedAudioText.value;
    }
  }

  /// 场景引导 - 保存编辑
  Future<void> saveSceneGuideEdit() async{
    sceneFocusText.value = sceneFocusController.text;
    suggestedMotionText.value = suggestedMotionController.text;
    suggestedAudioText.value = suggestedAudioController.text;
    bool res = await savePromptOtherEdit();
    if(!res) return;
    toggleSceneGuideEditing(false);
  }

  /// 视频提示词 - 展开/收起
  void togglePromptExpanded(){
    isPromptExpanded.value = !isPromptExpanded.value;
  }

  /// 保存提示词
  Future<void> savePromptEdit() async{
    videoPromptText.value = videoPromptController.text;
    bool res = await savePromptOtherEdit();
    if(!res) return;
    togglePromptEditing(false);

  }

  /// 视频提示词 - 展开编辑/收起编辑
  void togglePromptEditing(bool value){
    isPromptEditing.value = value;
    if(value){
      videoPromptController.text = videoPromptText.value;
    }
  }

  /// 刷新
  Future<void> refreshData() async{
    bool res = await getTaskVideoData();
    if(!res) return;
    ToastUtils.showToast(text: "刷新成功", type: ToastType.success);
  } 



  // =================== 以下是右边视频逻辑 ==================

  /// 待审核模式下切换视频
  Future<void> toggleReviewVideo({bool isNext = true}) async{
    if(!isNext){
      if(currentVideoIndex.value <= 0) return;
      currentVideoIndex.value -= 1;
      await videoEditController.setResource(videoList[currentVideoIndex.value].videoUrl??"");
    }else{
      if(currentVideoIndex.value >= videoList.length - 1) return;
      currentVideoIndex.value += 1;
      await videoEditController.setResource(videoList[currentVideoIndex.value].videoUrl??"");
    }
  }


  /// 新增台词
  void addLines(){
    linesInputs.add(TextEditingController());
  }


  /// 删除台词
  void deleteLines(int index){
    linesInputs.removeAt(index);
  }


  // ================== 以下是请求逻辑 =======================


  /// 视频提示词 (同时也编辑时长/场景引导) - 保存编辑
  Future<bool> savePromptOtherEdit({bool showLoading = true}) async{

    try {
      if(showLoading) ToastUtils.showLoading();
      Map<String, dynamic> reqData = {};

      VideoTaskEntityListFrames? firstFrame = videoData.value.frames?.first;

      if(firstFrame?.semanticFocus != sceneFocusController.text){
        reqData['semanticFocus'] = sceneFocusController.text;
      }

      if(firstFrame?.suggestedMotion != suggestedMotionController.text){
        reqData['suggestedMotion'] = suggestedMotionController.text;
      }

      if(firstFrame?.suggestedAudio != suggestedAudioController.text){
        reqData['suggestedAudio'] = suggestedAudioController.text;
      }

      if(videoData.value.videoPrompt != videoPromptController.text){
        reqData['prompt'] = videoPromptController.text;
      }

      if(videoData.value.duration != videoDuration.value){
        reqData['duration'] = videoDuration.value; 
      }

      if(reqData.isEmpty){
        return false;
      }

      reqData['promptId'] = videoData.value.promptId;

      bool response = await LanguageConsoleRequest.updateVideoPrompt(data: reqData);
      if(!response) return false;
      videoData.value.duration = videoDuration.value;
      if(firstFrame != null){
        firstFrame.semanticFocus = sceneFocusController.text;
        sceneFocusText.value = sceneFocusController.text;
        firstFrame.suggestedMotion = suggestedMotionController.text;
        suggestedMotionText.value = suggestedMotionController.text;
        firstFrame.suggestedAudio = suggestedAudioController.text;
        suggestedAudioText.value = suggestedAudioController.text;
      }

      videoData.value.videoPrompt = videoPromptController.text;
      videoPromptText.value = videoPromptController.text;
      
      ToastUtils.showToast(text: '修改成功', type: ToastType.success);
      return true;
    } finally{
      if(showLoading) ToastUtils.hideLoading();
    }

  }

  /// 重新生成提示词和视频
  Future<void> regeneratePromptAndVideos() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "videoTaskId": videoData.value.taskId,
        "width": videoWidth.value,
        "height": videoHeight.value,
      };
      bool response = await LanguageConsoleRequest.regeneratePromptAndVideos(data: reqData);
      if(!response) return;
      ToastUtils.showToast(text: '提交成功', type: ToastType.success);
      Get.back(result: {"type": "remove"});
    } finally{
      ToastUtils.hideLoading();
    }
  }

  ///用提示词重新生成视频
  Future<void> usePromptRegenerateTheVideo() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "videoTaskId": videoData.value.taskId,
        "width": videoWidth.value,
        "height": videoHeight.value,
      };
      bool response = await LanguageConsoleRequest.usePromptRegenerateTheVideo(data: reqData);
      if(!response) return;
      ToastUtils.showToast(text: '提交成功', type: ToastType.success);
      Get.back(result: {"type": "remove"});
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 保存裁剪&静音状态
  Future<void> saveCropMute() async{
    List<String> lines = [];
    for (var element in linesInputs) {
      if(element.text.trim().isEmpty) continue;
      lines.add(element.text);
    }

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "uid": videoList[currentVideoIndex.value].videoId,
        "startSeconds": DateFormatUtil.millisecondsToSecondsWithDecimal(videoCropStartDuration.value.inMilliseconds), 
        "endSeconds": DateFormatUtil.millisecondsToSecondsWithDecimal(videoCropEndDuration.value.inMilliseconds),
        "isMute": videoIsMute.value,
        "lines": lines,
      };
      bool response = await LanguageConsoleRequest.updateVideoInfo(data: reqData);
      if(!response) return;
      ToastUtils.showToast(text: '保存成功', type: ToastType.success);
      // Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 音频增强
  Future<void> audioEnhancement(BuildContext context) async{
    
    bool askRes = await DeleteDialog.show(
      context: context, 
      title: "音频增强",
      subTitle: "确认对该视频执行音频增强？",
      content: "将调用音频增强接口优化视频 #${videoList[currentVideoIndex.value].videoId??''} 的音质。处理完成后会生成新的视频记录。",
      confirmText: "确认增强",
      showCountdown: false,
    );
    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "videoId": videoList[currentVideoIndex.value].videoId,
      };
      bool response = await LanguageConsoleRequest.audioEnhancement(data: reqData);
      if(!response) return;
      ToastUtils.showToast(text: '提交成功', type: ToastType.success);
      Get.back(result: {"type": "remove"});
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 审核通过
  Future<void> videoApprove() async{

    if(videoData.value.approvedVideo?.locked == true) {
      ToastUtils.showToast(text: "视频已定稿，请放弃或删除任务");
      return;
    }

    List<String> lines = [];
    for (var element in linesInputs) {
      if(element.text.trim().isEmpty) continue;
      lines.add(element.text);
    }

    if(videoData.value.hasApprovedVideo == true){
      await videoEditController.pause();
      dynamic res = await ManagePageRegistry.jumpTo(
        Routes.MANAGE_REVIEW_VIDEO_CONFIRMATION, 
        arguments: {
          "videoUrl": videoList[currentVideoIndex.value].videoUrl,
          "videoTaskId": videoData.value.taskId,
          "videoIdSelected": videoList[currentVideoIndex.value].videoId,
          "isMute": videoIsMute.value,
          "startSeconds": videoCropStartDuration.value.inMilliseconds, 
          "endSeconds": videoCropEndDuration.value.inMilliseconds,
          "realDuration": actualDuration.value.inMilliseconds,
          "lines": lines,
          "approvedVideo": videoData.value.approvedVideo?.toJson(),
        },
      );
      if(res == null) return;
      if(res['type'] == "remove"){
        Get.back(result: {"type": "remove"});
      }
      return;
    }

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "videoTaskId": videoData.value.taskId,
        "videoIdSelected": videoList[currentVideoIndex.value].videoId,
        "isMute": videoIsMute.value,
        "startSeconds": DateFormatUtil.millisecondsToSecondsWithDecimal(videoCropStartDuration.value.inMilliseconds), 
        "endSeconds": DateFormatUtil.millisecondsToSecondsWithDecimal(videoCropEndDuration.value.inMilliseconds),
        "realDuration": DateFormatUtil.millisecondsToSecondsWithDecimal(actualDuration.value.inMilliseconds),
        "lines": lines,
      };
      bool response = await LanguageUtil.videoApprove(data: reqData);
      if(!response) return;
      ToastUtils.showToast(text: '审核成功', type: ToastType.success);
      Get.back(result: {"type": "remove"});
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 视频定稿
  Future<void> finalDraftVideo(BuildContext context) async{
    bool askRes = await AskDialog.showUserAsk(
      context: context, 
      title: "温馨提示",
      content: "您确定要将此视频定稿吗？",
    );

    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "relationUid": videoList[currentVideoIndex.value].relationUid,
      };
      bool res = await LanguageConsoleRequest.finalDraftVideo(parameters: parameters);
      if(!res) return;
      ToastUtils.showToast(text: "定稿成功", type: ToastType.success);
      videoList[currentVideoIndex.value].locked = true;
      videoData.refresh();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 视频取消定稿
  Future<void> cancelFinalDraftVideo(BuildContext context) async{
    bool askRes = await AskDialog.showUserAsk(
      context: context, 
      title: "温馨提示",
      content: "您确定要取消视频定稿吗？",
    );

    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "relationUid": videoList[currentVideoIndex.value].relationUid,
      };
      bool res = await LanguageConsoleRequest.unlockDraftVideo(parameters: parameters);
      if(!res) return;
      ToastUtils.showToast(text: "取消定稿成功", type: ToastType.success);
      videoList[currentVideoIndex.value].locked = false;
      videoData.refresh();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 字幕定稿
  Future<void> finalDraftAss(BuildContext context) async{

    bool askRes = await AskDialog.showUserAsk(
      context: context, 
      title: "温馨提示",
      content: "您确定要将此字幕定稿吗？",
    );

    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "relationUid": videoData.value.assRelationId,
      };
      bool res = await LanguageConsoleRequest.finalDraftAss(parameters: parameters);
      if(!res) return;
      ToastUtils.showToast(text: "定稿成功", type: ToastType.success);
      videoData.value.assLocked = true;
      videoData.refresh();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 字幕取消定稿
  Future<void> cancelFinalDraftAss(BuildContext context) async{
    bool askRes = await AskDialog.showUserAsk(
      context: context, 
      title: "温馨提示",
      content: "您确定要取消字幕定稿吗？",
    );

    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "relationUid": videoData.value.assRelationId,
      };
      bool res = await LanguageConsoleRequest.unlockDraftAss(parameters: parameters);
      if(!res) return;
      ToastUtils.showToast(text: "取消定稿成功", type: ToastType.success);
      videoData.value.assLocked = false;
      videoData.refresh();
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 新建视频
  Future<void> createVideo(BuildContext context) async{
    if(videoData.value.contentId == null || videoData.value.contentType == null) return;
    ManageCreateVideoDialog.show(
      context: context,
      uid: videoData.value.contentId,
      type: videoData.value.contentType,
      semanticId: videoData.value.semanticId,
      subTitle: "${videoData.value.localeTitle??""} ${videoData.value.styleTitle??""}",
      styleIds: videoData.value.styleId == null ? null : [videoData.value.styleId!],
    );
  }

  /// 用提示词新建视频
  Future<void> createVideoByPrompt(BuildContext context) async{
    if(videoData.value.promptId == null) return;
    bool res = await ManageReviewVideoDetilsEditDialog.show(
      context: context,
      promptId: videoData.value.promptId!,
      lines: linesInputs.map((e) => e.text).toList(),
      prompt: videoData.value.videoPrompt??"",
    );
    if(!res) return;
    getTaskVideoData();

  }

  /// 新建字幕
  Future<void> assReviewCreateAlign() async{
    if(videoList[currentVideoIndex.value].videoId == null) return;

    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "videoUid": videoList[currentVideoIndex.value].videoId,
        "updateExists": true,
      };
      String? res = await LanguageConsoleRequest.assReviewCreateVideoAlign(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
      getTaskVideoData();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 跳转审核字幕列表页面
  Future<void> toAssReview() async{
    if(videoData.value.assTaskIds?.isEmpty??true) return ToastUtils.showToast(text: "暂无待审核字幕");
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_ASS,
      arguments: {
        "taskIds": videoData.value.assTaskIds?.toList(),
      },
    );
    getTaskVideoData();

  }
  


  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
