import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../dialog/dialogs.dart';
import '../../../utils/utils.dart';
import '../models/manage_review_audio_model.dart';

class ManageReviewAudioController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageReviewAudioController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_REVIEW_AUDIO;

  @override
  String get breadcrumbTitle => '审核音频';

  /// 知识点 传进来的参数 
  List<int>? taskIds;

  /// 是否 按 条件查询
  final RxBool isSubConditionQuery = false.obs;

  ///　所有数据
  final Rx<AudioReviewEntity> allData = AudioReviewEntity().obs;

  /// 列表数据
  final RxList<ManageReviewAudioModel> taskList = <ManageReviewAudioModel>[].obs;

  /// load status  -1=loading  0=empty  1=success
  final RxInt loadStatus = (-1).obs;


  final Player player = Player();
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _playingSub;
  final RxBool audioPlaying = false.obs;
  final Rx<Duration> audioPosition = Duration.zero.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if(Get.arguments != null){
      taskIds = Get.arguments['taskIds'];
      isSubConditionQuery.value = taskIds != null;
    }
    getTaskList();
    listenAudio();
  }

  /// 监听音频播放
  void listenAudio(){

    _positionSub = player.stream.position.listen((e){
      audioPosition.value = e;
    });

    _playingSub = player.stream.playing.listen((e){
      audioPlaying.value = e;
    });

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
      AudioReviewEntity? response = await LanguageUtil.getAudioTaskList(data: reqData);
      if(response == null) {
        loadStatus.value = 0;
        return;
      }
      allData.value = response;

      List<AudioReviewEntityList?> list = response.list ?? [];
      taskList.clear();
      for(AudioReviewEntityList? item in list){
        if(item == null) continue;
        taskList.add(ManageReviewAudioModel(data: item));
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
      AudioReviewEntity? response = await LanguageUtil.getAudioTaskAnotherBatch(data: reqData);
      if(response == null) {
        loadStatus.value = 0;
        return;
      }

      List<AudioReviewEntityList?> list = response.list ?? [];
      taskList.clear();
      for(AudioReviewEntityList? item in list){
        if(item == null) continue;
        taskList.add(ManageReviewAudioModel(data: item));
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


  /// 选择的音频
  Future<void> selectAudio(ManageReviewAudioModel data, AudioReviewEntityListAudios? audio) async{
    if(audio == null) return;
    if(audio.audioUrl == null) return;

    if(data.selectAudioId == audio.audioId) return;

    for(int i = 0; i < taskList.length; i++){
      taskList[i].selectAudioId = null;
      taskList[i].publishedAudioPlay = false;
    }
    data.selectAudioId = audio.audioId;
    taskList.refresh();

    if(data.playAudioId== audio.audioId) return;
    await player.pause();
    await player.seek(Duration.zero);
  }

  /// 播放音频
  Future<void> playAudio(ManageReviewAudioModel data, AudioReviewEntityListAudios? audio) async{
    if(audio == null) return;
    if(audio.audioUrl == null) return;

    if(data.playAudioId == audio.audioId){

      if(audioPlaying.value){
        await player.pause();
      }else{
        await player.play();
      }

    }else{
      audioPosition.value = Duration.zero;
      for(int i = 0; i < taskList.length; i++){
        taskList[i].playAudioId = null;
        taskList[i].publishedAudioPlay = false;
      }
      data.playAudioId = audio.audioId;
      taskList.refresh();
      await player.open(Media(audio.audioUrl!), play: true);
    }
    
  }

  /// 播放已有音频
  Future<void> playPublishedAudio(ManageReviewAudioModel data) async{

    if(data.publishedAudio == null){
      try {
        ToastUtils.showLoading();
        Map<String, dynamic> reqData = {
          "audioTaskId": data.data.taskId,
        };
        List<AudioReviewEntityListAudios>? res = await LanguageUtil.getPublishedAudio(data: reqData);
        if((res??[]).isEmpty) return;
        data.publishedAudio = res?.first;
      } finally{
        ToastUtils.hideLoading();
      }
    }

    if(data.publishedAudio?.audioUrl == null) return;
    
    if(data.publishedAudioPlay){
      if(audioPlaying.value){
        data.publishedAudioPlay = false;
        taskList.refresh();
        player.pause();
      }else{
        data.publishedAudioPlay = false;
        taskList.refresh();
        player.play();
      }
      return;
    }
    audioPosition.value = Duration.zero;
    for(int i = 0; i < taskList.length; i++){
      taskList[i].playAudioId = null;
      taskList[i].publishedAudioPlay = false;
    }
    data.publishedAudioPlay = true;
    taskList.refresh();
    await player.open(Media(data.publishedAudio!.audioUrl!), play: true);

  }


  /// 查看提示词
  Future<void> viewPrompt(ManageReviewAudioModel data, BuildContext context) async{
    if(data.data.prompt == null) return;
    ElementsCardType contentType = ElementsCardType.fromRawValue(data.data.contentType??"");
    
    String? result = await PromptInputDialog.show(
      context: context, 
      prompt: data.data.prompt,
      confirmText: contentType == ElementsCardType.song || contentType == ElementsCardType.reveal ? "用提示词重新生成音频" : "重新生成音频",
      confirmColor: AppTheme.cSurfaceWarning.color,
    );
    if(result == null) return;
    
    audioPromptGenerate(data, prompt: result);
  }


  /// 删除任务
  Future<void> deleteTask(BuildContext context, ManageReviewAudioModel data) async{
    bool ask = await AskDialog.showUserAsk(
      context: context,
      title: "删除任务",
      content: "确定删除此任务吗？",
    );
    if(!ask) return;
    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqDtaa = {
        "audioTaskId": data.data.taskId,
      };
      bool res = await LanguageConsoleRequest.aduioReviewDeleteTask(data: reqDtaa);
      if(!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      taskList.removeWhere((e) => e.data.taskId == data.data.taskId);
      taskList.refresh();
      await player.pause();
      await player.seek(Duration.zero);

    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 用提示词重新生成音频
  Future<void> audioPromptGenerate(ManageReviewAudioModel data, {String? prompt}) async{
    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqDtaa = {
        "audioTaskId": data.data.taskId,
      };
      if(prompt != null){
        reqDtaa['prompt'] = prompt;
      }
      String? res = await LanguageConsoleRequest.audioPromptGenerate(data: reqDtaa);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
      taskList.removeWhere((e) => e.data.taskId == data.data.taskId);
      taskList.refresh();
      await player.pause();
      await player.seek(Duration.zero);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 重新生成提示词和图片
  Future<void> audioPromptRegenerate(ManageReviewAudioModel data) async{
    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqDtaa = {
        "audioTaskId": data.data.taskId,
      };
      String? res = await LanguageConsoleRequest.audioPromptRegenerate(data: reqDtaa);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
      taskList.removeWhere((e) => e.data.taskId == data.data.taskId);
      taskList.refresh();
      await player.pause();
      await player.seek(Duration.zero);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 放弃
  Future<void> abandonTask(ManageReviewAudioModel data) async{

    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqDtaa = {
        "audioTaskId": data.data.taskId,
      };
      bool res = await LanguageUtil.audioReviewAbandon(data: reqDtaa);
      if(!res) return;
      ToastUtils.showToast(text: "放弃成功", type: ToastType.success);
      taskList.removeWhere((e) => e.data.taskId == data.data.taskId);
      taskList.refresh();
      await player.pause();
      await player.seek(Duration.zero);

    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 审核通过
  Future<void> approveTask(ManageReviewAudioModel data) async{
    
    if(data.selectAudioId == null) return ToastUtils.showToast(text: "请选择音频");

    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqDtaa = {
        "audioTaskId": data.data.taskId,
        "audioIdSelected": data.selectAudioId,
      };
      bool res = await LanguageUtil.assReviewAudioApprove(data: reqDtaa);
      if(!res) return;
      ToastUtils.showToast(text: "审核成功", type: ToastType.success);
      taskList.removeWhere((e) => e.data.taskId == data.data.taskId);
      taskList.refresh();
      await player.pause();
      await player.seek(Duration.zero);

    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 跳转至审核历史页面
  Future<void> toReviewHistory(bool fromAdmin) async{
    player.pause();
    player.seek(Duration.zero);
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_AUDIO_HISTORY, 
      arguments: {
        "fromAdmin": fromAdmin,
      },
    );

    if(taskList.isNotEmpty) await getTaskList();
  }


  @override
  void onClose() {
    // TODO: 清理逻辑
    _positionSub?.cancel();
    _playingSub?.cancel();
    player.dispose();
    super.onClose();
  }
}
