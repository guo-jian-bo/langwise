
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../utils/mqtt_utils/mqtt_message_services_code.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';
import '../../common/manage_select_emotion_dialog.dart';
import '../../enums/manage_zhendu_enums.dart';
import '../models/manage_audio_project_detils_scene_model.dart';

class ManageAudioProjectDetilsController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageAudioProjectDetilsController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_AUDIO_PROJECT_DETILS;

  @override
  String get breadcrumbTitle => '音频项目详情';

  /// 传进来的数据
  int? projectId;

  /// 详情数据
  final Rx<ManageAudioProjectDetilEntity> detilData = ManageAudioProjectDetilEntity().obs;

  /// 场景列表
  final RxList<ManageAudioProjectDetilsSceneModel> sceneList = <ManageAudioProjectDetilsSceneModel>[].obs;

  StreamSubscription<PushMessageServiceEnitiy>? _composeAudioSub;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    // TODO: 初始化逻辑
    if(Get.arguments != null){
      projectId = Get.arguments['projectId'];
      getDetilData();
    }

    _composeAudioSub = MqttNotificationMessage.instance.listenByCode(
      codes: [MqttMessageServicesCode.MESSAGE_VOICE_DIALOGUE_CREATE], 
      onData: (value){
        updateAudioStatus(value.message.code);
      },
    );
  }

  /// 获取剧本详情
  Future<void> getDetilData() async{
    if(projectId == null) return;
    try {
      ToastUtils.showLoading();

      ManageAudioProjectDetilEntity? res = await LanguageConsoleDramaRequest.getAudioProjectDetils(projectId!);
      if(res == null) return;
      detilData.value = res;
      sceneList.clear();
      List<ManageScriptDetilEntityScenes?> scenes = res.scenes??[];
      for (ManageScriptDetilEntityScenes? element in scenes) {
        if(element == null) continue;
        sceneList.add(setSceneData(element));
      }

    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 更新音频状态
  Future<void> updateAudioStatus(String? code) async{
    if(code != MqttMessageServicesCode.MESSAGE_VOICE_DIALOGUE_CREATE) return;
    if(projectId == null) return;
    try {

      ManageAudioProjectDetilEntity? res = await LanguageConsoleDramaRequest.getAudioProjectDetils(projectId!);
      if(res == null) return;
      // 这里只更新音频状态 sceneList.data.dialogues 的 audioStatus，audioTaskIds，audioInfo，error
      final Map<int, ManageScriptDetilEntityScenesDialogues> dialogueMap = {};
      for (final scene in res.scenes ?? []) {
        for (final dialogue in scene?.dialogues ?? []) {
          if (dialogue?.uid == null) continue;
          dialogueMap[dialogue!.uid!] = dialogue;
        }
      }

      for (final scene in sceneList) {
        for (final dialogue in scene.dialogues) {
          final serviceDialogue = dialogueMap[dialogue.data?.uid];
          if(dialogue.data == null || serviceDialogue == null) continue;
          dialogue.data?.audioStatus = serviceDialogue.audioStatus;
          dialogue.data?.audioTaskIds = serviceDialogue.audioTaskIds;
          dialogue.data?.audioInfo = serviceDialogue.audioInfo;
          dialogue.data?.error = serviceDialogue.error;
        }
      }
      sceneList.refresh();

    } finally{
    }
  }



  /// set场景数据model
  ManageAudioProjectDetilsSceneModel setSceneData(
    ManageScriptDetilEntityScenes data,
  ){
    List<ManageScriptDetilEntityScenesPersonas?> personas = data.personas??[];
    List<ManageScriptDetilEntityScenesPersonas> setPersonas = [];
    for (var element in personas) {
      if(element == null) continue;
      setPersonas.add(element);
    }

    List<ManageScriptDetilEntityScenesDialogues?> dialogues = data.dialogues??[];
    List<ManageAudioProjectDetilsLineModel> setDialogues = [];
    for (var element in dialogues) {
      if(element == null) continue;
      setDialogues.add(ManageAudioProjectDetilsLineModel(
        data: element,
        delayAfterInput: TextEditingController(text: element.delayAfter?.toString()??'0'),
        textInput: TextEditingController(text: element.text),
        // filter: ManageZhenduAudioFilterEnum.fromValue(),
      ));
    }

    ManageAudioProjectDetilsSceneModel model = ManageAudioProjectDetilsSceneModel(
      data: data,
      settingInput: TextEditingController(text: data.setting),
      summaryInput: TextEditingController(text: data.summary),
      dialogues: setDialogues,
    );

    return model;
  }

  /// 选择滤镜
  void selectFilter(ManageAudioProjectDetilsLineModel dialogue, ManageZhenduAudioFilterEnum filter){
    dialogue.filter = filter;
    if(filter == ManageZhenduAudioFilterEnum.none){
      dialogue.dryWet = 0;
    }
    sceneList.refresh();
  }

  /// 改变dry / wet
  void changeDryWet(ManageAudioProjectDetilsLineModel dialogue, double value){
    if(dialogue.filter == ManageZhenduAudioFilterEnum.none) return;
    dialogue.dryWet = value;
    sceneList.refresh();
  }


  /// 判断所有scene 是否有音频 并且已经审核通过
  bool isAllSceneChecked(){
    for (var element in sceneList) {
      if(element.dialogues.isEmpty) continue;
      for (var dialogue in element.dialogues) {
        if(dialogue.data?.audioTaskIds?.isNotEmpty ?? false) return false;
      }
    }
    return true;
  }



  /// 新建台词音频
  Future<void> addDialogueAudio(ManageAudioProjectDetilsLineModel dialogue) async{
    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "dialogueId": dialogue.data?.uid,
        "projectId": detilData.value.uid,
        "dialect": dialogue.data?.audioInfo?.dialect,
      };
      String? res = await LanguageConsoleDramaRequest.createDialogueAudio(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 审核音频
  Future<void> toReviewAudioPage(BuildContext context, ManageAudioProjectDetilsLineModel dialogue) async{
    List<int?> audioTaskIds = dialogue.data?.audioTaskIds??[];
    if(audioTaskIds.isEmpty) return ToastUtils.showToast(text: "暂无待审核音频");
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_AUDIO,
      arguments: {
        "taskIds": audioTaskIds,
      },
    );
    getDetilData();
  }

  /// 场景对话选择情绪
  Future<void> dialogueSelectEmotions(BuildContext context, ManageAudioProjectDetilsLineModel dialogue) async{
    ManageVocalEmotionsEntity? res = await ManageSelectEmotionDialog.show(context: context, initEmotionNid: dialogue.data?.emotionNid);
    if(res == null) return;

    Map<String, dynamic> reqData = {"emotionNid": res.nid};
    ManageScriptDetilEntityScenesDialogues? reqRes = await dialogueEdit(dialogue, reqData);
    if(reqRes == null) return;

    dialogue.data?.emotionName = res.name?.firstWhereOrNull((e) => e?.lang == "zh")?.text??"";
    dialogue.data?.emotionNid = res.nid??"";
    sceneList.refresh();
  }

  /// 自动保存台词内容
  Future<void> autoSaveDialogueText(ManageAudioProjectDetilsLineModel dialogue) async{
    final String text = dialogue.textInput.text;
    if(text == (dialogue.data?.text ?? "")) return;
    Map<String, dynamic> reqData = {"text": text};
    ManageScriptDetilEntityScenesDialogues? res = await dialogueEdit(dialogue, reqData, showLoading: false);
    if(res == null){
      dialogue.textInput.text = dialogue.data?.text ?? "";
      return;
    }
    dialogue.data?.text = dialogue.textInput.text;
    sceneList.refresh();
    ToastUtils.showToast(text: "保存成功", type: ToastType.success);
  }

  /// 自动保存停顿时间
  Future<void> autoSaveDialogueDelayAfter(ManageAudioProjectDetilsLineModel dialogue) async{
    final String delayAfter = dialogue.delayAfterInput.text.trim();
    if(delayAfter.isEmpty) return;
    if(delayAfter == (dialogue.data?.delayAfter?.toString() ?? "")) return;
    Map<String, dynamic> reqData = {"delay_after": delayAfter};
    ManageScriptDetilEntityScenesDialogues? res = await dialogueEdit(dialogue, reqData, showLoading: false);
    if(res == null){
      dialogue.delayAfterInput.text = dialogue.data?.delayAfter?.toString() ?? "";
      return;
    }
    dialogue.data?.delayAfter = double.tryParse(delayAfter);
    sceneList.refresh();
    ToastUtils.showToast(text: "保存成功", type: ToastType.success);
  }

  /// 编辑台词
  Future<ManageScriptDetilEntityScenesDialogues?> dialogueEdit(ManageAudioProjectDetilsLineModel dialogue, Map<String, dynamic> reqData, {bool showLoading = true}) async{
    if(dialogue.data?.uid == null) return null;

    try {
      if(showLoading) ToastUtils.showLoading();

      // Map<String, dynamic> reqData = {
      //   "speaker": dialogue.persona.speaker,
      //   // "personaNid": dialogue.data?.personaNid,
      //   "variantNid": dialogue.persona.variantNid,
      //   "emotionNid": dialogue.emotion.emotionNid,
      //   "text": dialogue.textInput.text,
      //   "delay_after": dialogue.delayAfterInput.text,
      // };

      ManageScriptDetilEntityScenesDialogues? res = await LanguageConsoleDramaRequest.sceneDialogueEdit(dialogue.data!.uid!, data: reqData);
      if(res == null) return null;
      if(showLoading) ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      return res;

    } finally{
      if(showLoading) ToastUtils.hideLoading();
    }
  }
  

  /// 新建台词音频
  Future<void> composeAudioProject() async{
    if(!isAllSceneChecked()){
      return ToastUtils.showToast(text: "请先审核所有音频");
    }

    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "projectId": detilData.value.uid,
      };
      String? res = await LanguageConsoleDramaRequest.composeAudioProject(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
  }



  @override
  void onClose() {
    super.onClose();
    _composeAudioSub?.cancel();
  }
}
