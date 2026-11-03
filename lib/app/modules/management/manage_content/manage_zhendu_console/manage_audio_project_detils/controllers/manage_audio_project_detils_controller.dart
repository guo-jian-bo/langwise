
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';
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


  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    // TODO: 初始化逻辑
    if(Get.arguments != null){
      projectId = Get.arguments['projectId'];
      getDetilData();
    }
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

  /// 试听音频审核
  Future<void> showReviewDialog(BuildContext context, ManageAudioProjectDetilsLineModel dialogue) async{
    List<int?> audioTaskIds = dialogue.data?.audioTaskIds??[];
    if(audioTaskIds.isEmpty) return ToastUtils.showToast(text: "暂无待审核音频");
    // await ManageAudioProjectReviewDialog.show(
    //   context: context,
    //   audioTaskIds: audioTaskIds,
    // );
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_AUDIO,
      arguments: {
        "taskIds": audioTaskIds,
      },
    );
  }
  

  /// 新建台词音频
  Future<void> composeAudioProject() async{
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
  }
}
