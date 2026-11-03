

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';
import '../../common/manage_select_emotion_dialog.dart';
import '../../common/manage_select_persona_variants_dialog.dart';
import '../models/manage_script_details_model.dart';
import '../views/manage_script_add_lines_dialog.dart';
import '../views/manage_script_view_full_dialog.dart';



class ManageScriptDetailsController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageScriptDetailsController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SCRIPT_DETAILS;

  @override
  String get breadcrumbTitle => '剧本详情';
  
  /// 传进来的参数
  int? scriptId;
  ScriptTypeEnum? scriptType;

  /// 剧本详情数据
  final Rx<ManageScriptDetilEntity> detilData = ManageScriptDetilEntity().obs;

  /// 场景列表
  final RxList<ManageScriptDetailsModel> sceneList = <ManageScriptDetailsModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if(Get.arguments != null){
      scriptId = Get.arguments['scriptId'];
      String scriptTypeValue = Get.arguments['scriptType'];
      scriptType = ScriptTypeEnum.fromValue(scriptTypeValue);
      getDetilData();
    }
  }


  /// 获取剧本详情
  Future<void> getDetilData() async{
    if(scriptId == null) return;
    try {
      ToastUtils.showLoading();

      ManageScriptDetilEntity? res = await LanguageConsoleDramaRequest.getScriptDetils(scriptId!);
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
  ManageScriptDetailsModel setSceneData(ManageScriptDetilEntityScenes data){
    List<ManageScriptDetilEntityScenesPersonas?> personas = data.personas??[];
    List<ManageScriptDetilEntityScenesPersonas> setPersonas = [];
    for (var element in personas) {
      if(element == null) continue;
      setPersonas.add(element);
    }

    List<ManageScriptDetilEntityScenesDialogues?> dialogues = data.dialogues??[];
    List<ManageScriptDetailsLinesModel> setDialogues = [];
    for (var element in dialogues) {
      if(element == null) continue;
      setDialogues.add(ManageScriptDetailsLinesModel(
        data: element,
        persona: ManageScriptDetilEntityScenesPersonas(
          speaker: element.speaker,
          variantNid: element.variantNid,
          imageUrl: element.imageUrl,
        ),
        emotion: ManageScriptDetailsEmotionModel(
          emotionNid: element.emotionNid??"",
          emotionName: element.emotionName??"",
        ),
        delayAfterInput: TextEditingController(text: element.delayAfter?.toString()),
        enabled: element.enabled == true,
        textInput: TextEditingController(text: element.text),
      ));
    }

    ManageScriptDetailsModel model = ManageScriptDetailsModel(
      data: data,
      showNameInput: false,
      nameInput: TextEditingController(text: data.title),
      settingInput: TextEditingController(text: data.setting),
      summaryInput: TextEditingController(text: data.summary),
      personas: setPersonas,
      dialogues: setDialogues,
    );

    return model;
  }






  /// 核心知识点
  Future<void> coreKnowledge() async{
    if((detilData.value.usedKnowledgePoints?.length??0) == 0) return ToastUtils.showToast(text: "暂无核心知识点");
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_CORE_KNOWLEDGE,
      arguments: {
        "uid": detilData.value.uid,
        "type": KnowledgeTypeEnum.SCRIPT.value,
      },
    );
  }

  /// 关联课程
  Future<void> relatedCourses() async{
    if(detilData.value.courseInfo == null) return;
    Get.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS_TARGET,
      arguments: {
        "courseId": detilData.value.courseInfo?.courseId,
        "moduleId": detilData.value.courseInfo?.courseModuleId,
        "unitId": detilData.value.courseInfo?.courseUnitId,
        "isAdminPage": true,
        "language": detilData.value.lang,
      },
    );
  }

  /// 创建音频项目
  Future<void> createAudioProject() async{
    if(scriptId == null) return ToastUtils.showToast(text: "缺少 scriptId");
    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "scriptId": scriptId,
        "numberOfVoices": 4,
      };

      String? res = await LanguageConsoleDramaRequest.createAudioProject(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);

    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 跳转至音频项目详情
  Future<void> toAudioProjectDetail(ManageScriptDetilEntityAudioProjects? audioProject) async{
    if(audioProject?.projectId == null) return;
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_AUDIO_PROJECT_DETILS,
      arguments: {
        "projectId": audioProject?.projectId,
      },
    );
    getDetilData();
  }

  /// 查看全文
  Future<void> viewFull(BuildContext context) async{
    await ManageScriptViewFullDialog.show(context: context, data: detilData.value);
  }


  /// 保存全部
  Future<void> saveAllEdit() async{
    try {
      ToastUtils.showLoading();
      bool hasChanges = false;

      for (final scene in sceneList) {
        // 检查场景是否有改动
        bool sceneChanged = false;
        Map<String, dynamic> sceneReqData = {};
        
        if(scene.nameInput.text != (scene.data.title ?? "")) {
          sceneReqData["title"] = scene.nameInput.text;
          sceneChanged = true;
        }
        if(scene.settingInput.text != (scene.data.setting ?? "")) {
          sceneReqData["setting"] = scene.settingInput.text;
          sceneChanged = true;
        }
        if(scene.summaryInput.text != (scene.data.summary ?? "")) {
          sceneReqData["summary"] = scene.summaryInput.text;
          sceneChanged = true;
        }
        
        if(sceneChanged) {
          await sceneEdit(scene, sceneReqData, showLoading: false);
          hasChanges = true;
        }

        // 检查台词是否有改动
        for (final dialogue in scene.dialogues) {
          bool dialogueChanged = false;
          Map<String, dynamic> dialogueReqData = {};
          
          if(dialogue.persona.speaker != dialogue.data?.speaker) {
            dialogueReqData["speaker"] = dialogue.persona.speaker;
            dialogueChanged = true;
          }
          if(dialogue.persona.variantNid != dialogue.data?.variantNid) {
            dialogueReqData["variantNid"] = dialogue.persona.variantNid;
            dialogueChanged = true;
          }
          if(dialogue.emotion.emotionNid != (dialogue.data?.emotionNid ?? "")) {
            dialogueReqData["emotionNid"] = dialogue.emotion.emotionNid;
            dialogueChanged = true;
          }
          if(dialogue.textInput.text != (dialogue.data?.text ?? "")) {
            dialogueReqData["text"] = dialogue.textInput.text;
            dialogueChanged = true;
          }
          if(dialogue.delayAfterInput.text != (dialogue.data?.delayAfter?.toString() ?? "")) {
            dialogueReqData["delay_after"] = dialogue.delayAfterInput.text;
            dialogueChanged = true;
          }
          
          if(dialogueChanged) {
            await dialogueEdit(dialogue, dialogueReqData, showLoading: false);
            hasChanges = true;
          }
        }
      }

      if(hasChanges) {
        await getDetilData();
        ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      } else {
        ToastUtils.showToast(text: "没有需要保存的改动");
      }
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 判断是否有编辑改动
  bool getIsEdit(){
    for (final scene in sceneList) {
      if(scene.nameInput.text != (scene.data.title ?? "")) return true;
      if(scene.settingInput.text != (scene.data.setting ?? "")) return true;
      if(scene.summaryInput.text != (scene.data.summary ?? "")) return true;
      for (final dialogue in scene.dialogues) {
        if(dialogue.persona.speaker != dialogue.data?.speaker) return true;
        if(dialogue.persona.variantNid != dialogue.data?.variantNid) return true;
        if(dialogue.textInput.text != (dialogue.data?.text ?? "")) return true;
        if(dialogue.delayAfterInput.text != (dialogue.data?.delayAfter?.toString() ?? "")) return true;
      }
    }
    return false;
  }

  /// 退出前检查是否有未保存的改动
  Future<bool> checkBeforeExit(BuildContext context) async{
    if(!getIsEdit()) return true;

    bool? res = await AskDialog.showUserCancelAsk(
      context: context,
      title: "提示",
      content: "当前页面有未保存的修改，是否确认退出？",
      cancel: "取消",
      define: "不保存，直接退出",
    );

    return res == true;
  }

  /// 编辑scene名称
  Future<void> editSceneName(ManageScriptDetailsModel scene) async{
    scene.showNameInput = !scene.showNameInput;
    sceneList.refresh();
    if(scene.nameInput.text.trim().isEmpty) return ToastUtils.showToast(text: "请输入场景名称");
    if(scene.data.title == scene.nameInput.text) return;
    Map<String, dynamic> reqData = {"title": scene.nameInput.text};
    ManageScriptDetilEntityScenes? res = await sceneEdit(scene, reqData);
    if(res == null){
      scene.nameInput.text = scene.data.title??""; // 重置
    }
  }

  /// 自动保存setting
  Future<void> autoSaveSceneSetting(ManageScriptDetailsModel scene) async{
    final String setting = scene.settingInput.text;
    if(setting == (scene.data.setting ?? "")) return;
    Map<String, dynamic> reqData = {"setting": setting};
    ManageScriptDetilEntityScenes? res = await sceneEdit(scene, reqData);
    if(res == null){
      scene.settingInput.text = scene.data.setting??"";
      return;
    }
    scene.data = res;
    scene.settingInput.text = res.setting??setting;
    sceneList.refresh();
  }

  /// 自动保存summary
  Future<void> autoSaveSceneSummary(ManageScriptDetailsModel scene) async{
    final String summary = scene.summaryInput.text;
    if(summary == (scene.data.summary ?? "")) return;
    Map<String, dynamic> reqData = {"summary": summary};
    ManageScriptDetilEntityScenes? res = await sceneEdit(scene, reqData);
    if(res == null){
      scene.summaryInput.text = scene.data.summary??"";
      return;
    }
    scene.data = res;
    scene.summaryInput.text = res.summary??summary;
    sceneList.refresh();
  }
  

  /// 编辑场景
  Future<ManageScriptDetilEntityScenes?> sceneEdit(ManageScriptDetailsModel scene, Map<String, dynamic> reqData, {bool showLoading = true}) async{
    if(scene.data.uid == null) return null;
    try {
      if(showLoading) ToastUtils.showLoading();

      ManageScriptDetilEntityScenes? res = await LanguageConsoleDramaRequest.sceneEdit(scene.data.uid!, data: reqData);
      if(res == null) return null;
      if(showLoading) ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      return res;
    } finally{
      if(showLoading) ToastUtils.hideLoading();
    }
  }

  /// 查看参演人员大图
  Future<void> showPersonaImage(BuildContext context, ManageScriptDetailsModel scene, ManageScriptDetilEntityScenesPersonas persona) async{
    // TTOD: 查看参演人员大图
    if(persona.imageUrl == null) return;
    ShowBigResourceDialog.showImage(
      context: context, 
      imageUrls: [persona.imageUrl??""],
    );
  }

  /// 新增参演人员
  Future<void> addParticipants(BuildContext context, ManageScriptDetailsModel scene) async{
    List<String?>? initVariantNid = scene.personas.map((e) => e.variantNid).toList();
    ManageSelectPersonaVariantsReslut? selectRes = await ManageSelectPersonaVariantsDialog.show(context: context, initVariantNid: initVariantNid);
    if(selectRes == null) return;
    // TTDO: 把选择的角色[res] 添加到[scene.personas]里面

    // MangePersonaEntityVariants? variant = selectRes.variants?.firstWhereOrNull((e) => e?.isDefault == true);
    // variant ??= selectRes.variants?.firstWhereOrNull((e) => e?.enabled == true);


    List<Map<String, dynamic>> list = [];
    for (var i = 0; i < scene.personas.length; i++) {
      list.add({
        "speaker": scene.personas[i].speaker,
        "variantNid": scene.personas[i].variantNid,
      });
    }
    list.add({
      "speaker": selectRes.variant.name,
      "variantNid": selectRes.variant.nid,
    });
    Map<String, dynamic> reqData = {
      "personas": list,
    };
    ManageScriptDetilEntityScenes? res = await sceneEdit(scene, reqData);
    if(res == null) return;
    /// 更新角色数据
    scene.data = res;
    List<ManageScriptDetilEntityScenesPersonas?> personas = res.personas??[];
    List<ManageScriptDetilEntityScenesPersonas> setPersonas = [];
    for (var element in personas) {
      if(element == null) continue;
      setPersonas.add(element);
    }
    scene.personas = setPersonas;
    sceneList.refresh();
  }

  /// 移除参演人员
  Future<void> removePersona(BuildContext context, ManageScriptDetailsModel scene, ManageScriptDetilEntityScenesPersonas persona) async{
    // TTOD: 在[scene.personas] 中移除 persona ，并检查[scene.dialogues.persona]是否是移除的演员 如果是 删除这条[scene.dialogues.persona]

    if(scene.personas.length <= 1) return ToastUtils.showToast(text: "至少保留一个参演人员");

    bool delAsk = await DeleteDialog.show(
      context: context, 
      title: "移除参演人员",
      subTitle: "确认要移除 ${persona.speaker??''} 吗？",
    );
    if(!delAsk) return;

    try {
      ToastUtils.showLoading();
      List<Map<String, dynamic>> list = [];
      for (var i = 0; i < scene.personas.length; i++) {
        if(scene.personas[i].variantNid == persona.variantNid) continue;
        list.add({
          "speaker": scene.personas[i].speaker,
          "variantNid": scene.personas[i].variantNid,
        });
      }
      Map<String, dynamic> reqData = {
        "personas": list,
      };
      ManageScriptDetilEntityScenes? res = await sceneEdit(scene, reqData, showLoading: false);
      if(res == null) return;
      getDetilData();
    } finally{
      ToastUtils.hideLoading();
    }

  }

  /// 替换参演人员
  Future<void> replacePersona(BuildContext context, ManageScriptDetailsModel scene, ManageScriptDetilEntityScenesPersonas persona) async{
    final String oldVariantNid = persona.variantNid ?? "";
    if(oldVariantNid.isEmpty) return;
    List<String?> initVariantNid = scene.personas.map((e) => e.variantNid).toList();
    ManageSelectPersonaVariantsReslut? selectRes = await ManageSelectPersonaVariantsDialog.show(
      context: context,
      initVariantNid: initVariantNid,
    );
    if(selectRes == null) return;

    final String newVariantNid = selectRes.variant.nid ?? "";
    final String newSpeaker = selectRes.variant.name ?? "";
    if(newVariantNid.isEmpty || newSpeaker.isEmpty) return;

    try {
      ToastUtils.showLoading();
      List<Map<String, dynamic>> list = [];
      for (var i = 0; i < scene.personas.length; i++) {
        if(scene.personas[i].variantNid == oldVariantNid){
          list.add({
            "speaker": newSpeaker,
            "variantNid": newVariantNid,
          });
          continue;
        }
        list.add({
          "speaker": scene.personas[i].speaker,
          "variantNid": scene.personas[i].variantNid,
        });
      }

      Map<String, dynamic> reqData = {
        "personas": list,
      };
      ManageScriptDetilEntityScenes? res = await sceneEdit(scene, reqData, showLoading: false);
      if(res == null) return;

      /// 更新角色数据
      scene.data = res;
      List<ManageScriptDetilEntityScenesPersonas?> personas = res.personas??[];
      List<ManageScriptDetilEntityScenesPersonas> setPersonas = [];
      for (var element in personas) {
        if(element == null) continue;
        setPersonas.add(element);
      }
      scene.personas = setPersonas;

      for(int i = scene.dialogues.length - 1; i >= 0; i--){
        final ManageScriptDetailsLinesModel dialogue = scene.dialogues[i];
        final String dialogueVariantNid = dialogue.persona.variantNid ?? dialogue.data?.variantNid ?? "";

        if(dialogueVariantNid != oldVariantNid) continue;

        Map<String, dynamic> dialogueReqData = {
          "speaker": newSpeaker,
          "variantNid": newVariantNid,
        };
        ManageScriptDetilEntityScenesDialogues? dialogueRes = await dialogueEdit(dialogue, dialogueReqData, showLoading: false);
        if(dialogueRes == null) continue;
        getDetilData();
      }
      sceneList.refresh();
      ToastUtils.showToast(text: "替换成功", type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 新增台词
  Future<void> addLines(BuildContext context, ManageScriptDetailsModel scene) async{
    ManageScriptAddLinesReslut? selectRes = await ManageScriptAddLinesDialog.show(context: context, personas: scene.personas);
    if(selectRes == null) return;

    
    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "scriptId": scene.data.scriptId,
        "sceneId": scene.data.uid,
        "speaker": selectRes.persona.speaker,
        "variantNid": selectRes.persona.variantNid,
        "emotionNid": selectRes.emotion.nid,
        "text": selectRes.lines,
        "delay_after": selectRes.delayAfter,
        "enabled": false,
      };

      ManageScriptDetilEntityScenesDialogues? res = await LanguageConsoleDramaRequest.sceneDialogueAdd(data: reqData);
      if(res == null) return;
      
      getDetilData();

      ToastUtils.showToast(text: "新增成功", type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }

  }


  /// 台词向上移动
  Future<void> dialogueMovesUp(ManageScriptDetailsModel scene, ManageScriptDetailsLinesModel dialogue) async{
    if(scene.data.uid == null) return;
    final int currentIndex = scene.dialogues.indexOf(dialogue);
    if(currentIndex <= 0){
      ToastUtils.showToast(text: "已经在最上面了");
      return;
    }
    scene.dialogues.removeAt(currentIndex);
    scene.dialogues.insert(currentIndex - 1, dialogue);
    sceneList.refresh();

    bool res = await dialogueMovesReq(scene);
    if(res) return;
    // 失败则根据data.index重置排序
    scene.dialogues.sort((a, b) => (a.data?.index ?? 0).compareTo(b.data?.index ?? 0));
    sceneList.refresh();
  }

  /// 台词向下移动
  Future<void> dialogueMovesDown(ManageScriptDetailsModel scene, ManageScriptDetailsLinesModel dialogue) async{
    if(scene.data.uid == null) return;
    final int currentIndex = scene.dialogues.indexOf(dialogue);
    if(currentIndex >= scene.dialogues.length - 1){
      ToastUtils.showToast(text: "已经在最下面了");
      return;
    }
    scene.dialogues.removeAt(currentIndex);
    scene.dialogues.insert(currentIndex + 1, dialogue);
    sceneList.refresh();

    bool res = await dialogueMovesReq(scene);
    if(res) return;
    // 失败则根据data.index重置排序
    scene.dialogues.sort((a, b) => (a.data?.index ?? 0).compareTo(b.data?.index ?? 0));
    sceneList.refresh();
  }

  /// 台词排序请求
  Future<bool> dialogueMovesReq(ManageScriptDetailsModel scene) async{
    if(scene.data.uid == null) return false;
    try {
      ToastUtils.showLoading();

      List<Map<String, dynamic>> reqData = [];

      for (int i = 0; i < scene.dialogues.length; i++) {
        reqData.add({
          "uid": scene.dialogues[i].data?.uid,
          "index": i,
        });
      }

      bool res = await LanguageConsoleDramaRequest.sceneDialogueSort(scene.data.uid!, data: reqData);
      if(!res) return false;
      ToastUtils.showToast(text: "操作成功", type: ToastType.success);
      for (int i = 0; i < scene.dialogues.length; i++) {
        scene.dialogues[i].data?.index = i;
      }
      sceneList.refresh();
      return true;
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 在场景对话中改变演员
  Future<void> dialogueChangePersona(ManageScriptDetailsModel scene, ManageScriptDetailsLinesModel dialogue, String selectVariantNid) async{

    ManageScriptDetilEntityScenesPersonas? selectVariant;

    for (var element in scene.personas) {
      if(element.variantNid == selectVariantNid){
        selectVariant = element;
        break;
      }
    }
    if(selectVariant == null) return;

    final String previousVariantNid = dialogue.persona.variantNid??"";
    if(previousVariantNid == selectVariantNid) return;
    dialogue.persona = selectVariant;
    sceneList.refresh();
    await autoSaveDialoguePersona(dialogue, previousVariantNid);
  }

  /// 场景对话选择情绪
  Future<void> dialogueSelectEmotions(BuildContext context, ManageScriptDetailsLinesModel dialogue) async{
    ManageVocalEmotionsEntity? res = await ManageSelectEmotionDialog.show(context: context, initEmotionNid: dialogue.emotion.emotionNid);
    if(res == null) return;

    Map<String, dynamic> reqData = {"emotionNid": res.nid};
    ManageScriptDetilEntityScenesDialogues? reqRes = await dialogueEdit(dialogue, reqData);
    if(reqRes == null) return;
    getDetilData();
  }

  /// 场景对话启用/禁用
  Future<void> dialogueChangeEnabled(ManageScriptDetailsLinesModel dialogue) async{
    Map<String, dynamic> reqData = {"enabled": !dialogue.enabled};
    ManageScriptDetilEntityScenesDialogues? res = await dialogueEdit(dialogue, reqData);
    if(res == null) return;
    dialogue.data = res;
    dialogue.enabled = res.enabled == true;
    sceneList.refresh();
  }

  /// 自动保存台词演员
  Future<void> autoSaveDialoguePersona(ManageScriptDetailsLinesModel dialogue, String previousVariantNid) async{
    final String previousSpeaker = dialogue.data?.speaker ?? dialogue.persona.speaker ?? "";
    final String previousImageUrl = dialogue.data?.imageUrl ?? dialogue.persona.imageUrl ?? "";
    if((dialogue.persona.variantNid??"").isEmpty) return;
    if(dialogue.persona.variantNid == (dialogue.data?.variantNid ?? "")) return;
    Map<String, dynamic> reqData = {
      "speaker": dialogue.persona.speaker,
      "variantNid": dialogue.persona.variantNid,
    };
    ManageScriptDetilEntityScenesDialogues? res = await dialogueEdit(dialogue, reqData);
    if(res == null){
      dialogue.persona.speaker = previousSpeaker;
      dialogue.persona.variantNid = previousVariantNid;
      dialogue.persona.imageUrl = previousImageUrl;
      sceneList.refresh();
      return;
    }
    getDetilData();
  }

  /// 自动保存台词内容
  Future<void> autoSaveDialogueText(ManageScriptDetailsLinesModel dialogue) async{
    final String text = dialogue.textInput.text;
    if(text == (dialogue.data?.text ?? "")) return;
    Map<String, dynamic> reqData = {"text": text};
    ManageScriptDetilEntityScenesDialogues? res = await dialogueEdit(dialogue, reqData, showLoading: false);
    if(res == null){
      dialogue.textInput.text = dialogue.data?.text ?? "";
      return;
    }
    dialogue.data?.text = dialogue.textInput.text;
    ToastUtils.showToast(text: "保存成功", type: ToastType.success);
  }

  /// 自动保存停顿时间
  Future<void> autoSaveDialogueDelayAfter(ManageScriptDetailsLinesModel dialogue) async{
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
    ToastUtils.showToast(text: "保存成功", type: ToastType.success);
  }




  /// 编辑台词
  Future<ManageScriptDetilEntityScenesDialogues?> dialogueEdit(ManageScriptDetailsLinesModel dialogue, Map<String, dynamic> reqData, {bool showLoading = true}) async{
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


  /// 删除台词
  Future<void> dialogueDelete(BuildContext context, ManageScriptDetailsModel scene, ManageScriptDetailsLinesModel dialogue, {bool showToast = true}) async{
    if(dialogue.data?.uid == null) return;
    if(showToast){
      bool askRes = await DeleteDialog.show(
        context: context, 
        title: "删除",
        content: "您确定要删除此条对话吗？",
        showCountdown: false,
      );
      if(!askRes) return;
    }
    
    try {
      if(showToast) ToastUtils.showLoading();

      bool res = await LanguageConsoleDramaRequest.sceneDialogueDelete(dialogue.data!.uid!);
      if(!res) return;
      if(showToast) ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      scene.dialogues.removeWhere((e) => e.data?.uid == dialogue.data?.uid);
      sceneList.refresh();

    } finally{
      if(showToast) ToastUtils.hideLoading();
    }
  }


  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
