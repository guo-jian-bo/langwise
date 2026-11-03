
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:video_player/video_player.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/karaoke_subtitles_utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';
import '../models/manage_subtitle_mapping_ass_model.dart';

/// Persona 卡片需要展示的 dialogue 信息
class PersonaDialogueDisplayModel{
  final String dialogueUidText;
  final String dialogueContentText;

  const PersonaDialogueDisplayModel({
    required this.dialogueUidText,
    required this.dialogueContentText,
  });
}

class ManageSubtitleMappingController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageSubtitleMappingController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SUBTITLE_MAPPING;

  @override
  String get breadcrumbTitle => '字幕映射';

  /// 创建来的参数
  int? projectId;
  String? projectName;

  /// 字幕映射数据
  final Rx<ManageVisuaAssMappingEntity> mappingEntity = ManageVisuaAssMappingEntity().obs;

  /// 场景列表
  final RxList<ManageVisuaAssMappingEntityScenes> scenesList = <ManageVisuaAssMappingEntityScenes>[].obs;

  /// 字幕列表
  final RxList<ManageSubtitleMappingAssModel> dialogueList = <ManageSubtitleMappingAssModel>[].obs;

  /// 当前选择的场景index
  final RxInt currentSceneIndex = 0.obs;

  /// 当前编辑的帧
  final Rx<SceneTypeEnum> currentSceneTypeEnum = SceneTypeEnum.start_frame.obs;

  /// ass index -> 所属 scene uid
  final RxMap<int, int> assOwnerSceneUidMap = <int, int>{}.obs;

  /// ass index -> 所属关键帧类型
  final RxMap<int, SceneTypeEnum> assOwnerSceneTypeMap = <int, SceneTypeEnum>{}.obs;

  // ================= 音频播放器 =================

  /// 音频播放器
  final Player player = Player();

  /// 音频播放器状态订阅
  StreamSubscription<bool>? playerStateSubscription;

  /// 是否正在播放
  final RxBool isPlaying = false.obs;

  /// 音频时长订阅
  StreamSubscription<Duration>? playerDurationSubscription;

  /// 音频时长
  final Rx<Duration> audioDuration = Duration.zero.obs;

  /// 音频播放器位置订阅
  StreamSubscription<Duration>? playerPositionSubscription;

  /// 当前播放位置
  final Rx<Duration> currentPosition = Duration.zero.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    // TODO: 初始化逻辑
    if(Get.arguments != null){
      projectId = Get.arguments['projectId'];
      projectName = Get.arguments['projectName'];
      getMappingData();
      listenPlayerStateChange();
    }
  }

  /// 查询字幕映射
  Future<void> getMappingData() async{
    if(projectId == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "projectId": projectId,
      };
      ManageVisuaAssMappingEntity? res = await LanguageConsoleDramaRequest.getVisualProjectFrameMappingDetils(data: reqData);
      if(res == null) return;
      mappingEntity.value = res;
      //TTOD： 这里是要设置player的音频资源 暂时没有 先搁置
      if(res.assInfo?.audioInfo?.audioUrl != null && player.state.playlist.medias.isEmpty){
        player.open(Media(res.assInfo!.audioInfo!.audioUrl!), play: false);
      }
      List<ManageVisuaAssMappingEntityScenes?> scenes = res.scenes??[];
      scenesList.clear();
      dialogueList.clear();

      for (var element in scenes) {
        if(element == null) continue;
        scenesList.add(element);
      }

      List<ManageVisuaAssMappingEntityAssInfoDialogueList?> dialogues = res.assInfo?.dialogueList??[];
      for (var element in dialogues) {
        if(element == null) continue;

        dialogueList.add(ManageSubtitleMappingAssModel(
          data: element,
          sentence: KaraokeSubtitlesUtils.parseDialogueLineToSentenceModel(element.dialogue??""),
        ));
      }

      _rebuildAssOwnerMap();

    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 是否满足“创建关键帧字幕”的前置条件
  bool canCreateKeyframeSubtitles(){
    if(scenesList.isEmpty || dialogueList.isEmpty) return false;

    for (var scene in scenesList) {
      Map<SceneTypeEnum, List<int>> draft = <SceneTypeEnum, List<int>>{
        SceneTypeEnum.start_frame: _getSceneTypeAssList(scene, SceneTypeEnum.start_frame),
        SceneTypeEnum.highlight_frame: _getSceneTypeAssList(scene, SceneTypeEnum.highlight_frame),
        SceneTypeEnum.end_frame: _getSceneTypeAssList(scene, SceneTypeEnum.end_frame),
      };

      // 每个 scene 至少要有一条映射
      int sceneAssCount = draft.values.fold(0, (sum, list) => sum + list.length);
      if(sceneAssCount == 0) return false;

      // scene 内关键帧连续校验
      if(_validateSceneFramesContinuity(draft) != null) return false;
      for (var list in draft.values) {
        if(_validateFrameListContinuity(list) != null) return false;
      }
    }

    List<int> allIndexes = <int>[];
    for (var scene in scenesList) {
      allIndexes.addAll(_getSceneTypeAssList(scene, SceneTypeEnum.start_frame));
      allIndexes.addAll(_getSceneTypeAssList(scene, SceneTypeEnum.highlight_frame));
      allIndexes.addAll(_getSceneTypeAssList(scene, SceneTypeEnum.end_frame));
    }
    allIndexes.sort();

    // 必须完整覆盖所有 ASS（0..N-1）
    if(allIndexes.length != dialogueList.length) return false;
    for (int i = 0; i < allIndexes.length; i++) {
      if(allIndexes[i] != i) return false;
    }

    return true;
  }

  /// 监听音频播放状态
  void listenPlayerStateChange(){
    playerStateSubscription = player.stream.playing.listen((event) {
      isPlaying.value = event;
    });
    playerDurationSubscription = player.stream.duration.listen((event) {
      audioDuration.value = event;
    });
    playerPositionSubscription = player.stream.position.listen((event) {
      currentPosition.value = event;
    });
  }

  /// 拖动进度条跳转播放位置
  Future<void> seekAudioTo(Duration position) async{
    Duration duration = audioDuration.value;
    if(duration <= Duration.zero){
      await player.seek(Duration.zero);
      currentPosition.value = Duration.zero;
      return;
    }
    Duration safePosition = position;
    if(safePosition < Duration.zero){
      safePosition = Duration.zero;
    } else if(safePosition > duration){
      safePosition = duration;
    }
    await player.seek(safePosition);
    currentPosition.value = safePosition;
  }

  /// 选择场景
  void selectScene(int index){
    currentSceneIndex.value = index;
    currentSceneTypeEnum.value = SceneTypeEnum.start_frame;
  }

  /// 选择帧
  void selectSceneTypeEnum(SceneTypeEnum? type){
    if(type == null) return;
    currentSceneTypeEnum.value = type;

  }

  /// 切换 ASS 的选中状态（当前 scene + 当前帧）
  /// 1) 若被其他 scene/帧占用，则提示并拦截
  /// 2) 若当前已选，则取消
  /// 3) 若当前未选，则加入并按序排序
  void toggleAssDialogue(ManageSubtitleMappingAssModel data){
    if(scenesList.isEmpty) return;
    int? dialogueIndex = data.data.index;
    if(dialogueIndex == null) return;
    if(currentSceneIndex.value < 0 || currentSceneIndex.value >= scenesList.length) return;

    ManageVisuaAssMappingEntityScenes currentScene = scenesList[currentSceneIndex.value];
    int? currentSceneUid = currentScene.uid;
    if(currentSceneUid == null) return;

    int? dialogueSceneUid = _getDialogueSceneUidByIndex(dialogueIndex);
    if(!_isDialogueAssignableToCurrentScene(dialogueIndex)){
      int? sceneIndex = _findSceneByUid(dialogueSceneUid)?.index;
      ToastUtils.showToast(text: "这条 ASS 仅允许 Scene ${sceneIndex ?? '?'} 选择", type: ToastType.warning);
      return;
    }

    SceneTypeEnum currentType = currentSceneTypeEnum.value;
    int? ownerSceneUid = assOwnerSceneUidMap[dialogueIndex];
    SceneTypeEnum? ownerSceneType = assOwnerSceneTypeMap[dialogueIndex];
    bool selectedByCurrent = ownerSceneUid == currentSceneUid && ownerSceneType == currentType;
    bool selectedByOther = ownerSceneUid != null && ownerSceneType != null && !selectedByCurrent;

    if(selectedByOther){
      int? sceneIndex = _findSceneByUid(ownerSceneUid)?.index;
      ToastUtils.showToast(text: "这条 ASS 已被 Scene ${sceneIndex ?? '?'} · ${ownerSceneType.label} 选中", type: ToastType.warning);
      return;
    }

    // 当前 scene 三个关键帧的临时草稿（先改草稿，校验通过再落库）
    List<int> startDraftList = _getSceneTypeAssList(currentScene, SceneTypeEnum.start_frame);
    List<int> highlightDraftList = _getSceneTypeAssList(currentScene, SceneTypeEnum.highlight_frame);
    List<int> endDraftList = _getSceneTypeAssList(currentScene, SceneTypeEnum.end_frame);

    Map<SceneTypeEnum, List<int>> draft = <SceneTypeEnum, List<int>>{
      SceneTypeEnum.start_frame: startDraftList,
      SceneTypeEnum.highlight_frame: highlightDraftList,
      SceneTypeEnum.end_frame: endDraftList,
    };

    List<int> targetList = draft[currentType] ?? <int>[];
    if(selectedByCurrent){
      targetList.removeWhere((item) => item == dialogueIndex);
    } else {
      if(!targetList.contains(dialogueIndex)){
        targetList.add(dialogueIndex);
      }
    }
    targetList.sort();
    draft[currentType] = targetList;

    // 1) 同一关键帧内必须连续
    String? frameContinuityError = _validateFrameListContinuity(draft[currentType] ?? <int>[]);
    if(frameContinuityError != null){
      ToastUtils.showToast(text: frameContinuityError, type: ToastType.warning);
      return;
    }

    // 2) 同一个 scene 的起始/高光/结束帧之间必须首尾连续
    String? sceneContinuityError = _validateSceneFramesContinuity(draft);
    if(sceneContinuityError != null){
      ToastUtils.showToast(text: sceneContinuityError, type: ToastType.warning);
      return;
    }

    _setSceneTypeAssList(currentScene, SceneTypeEnum.start_frame, draft[SceneTypeEnum.start_frame]??[]);
    _setSceneTypeAssList(currentScene, SceneTypeEnum.highlight_frame, draft[SceneTypeEnum.highlight_frame]??[]);
    _setSceneTypeAssList(currentScene, SceneTypeEnum.end_frame, draft[SceneTypeEnum.end_frame]??[]);

    _rebuildAssOwnerMap();

    scenesList.refresh();
  }

  /// 校验同一关键帧内 ASS 是否连续（不能跳选，取消中间也不行）
  String? _validateFrameListContinuity(List<int> assDialogueList){
    if(assDialogueList.isEmpty) return null;
    List<int> sorted = List<int>.from(assDialogueList)..sort();
    for (int i = 1; i < sorted.length; i++) {
      if(sorted[i] != sorted[i - 1] + 1){
        return "同一关键帧选中的 ASS 字幕必须连续，不能跳选。";
      }
    }
    return null;
  }

  /// 校验同一个 scene 内三种关键帧之间是否首尾连续
  String? _validateSceneFramesContinuity(Map<SceneTypeEnum, List<int>> draft){
    int? previousEnd;
    List<SceneTypeEnum> order = <SceneTypeEnum>[
      SceneTypeEnum.start_frame,
      SceneTypeEnum.highlight_frame,
      SceneTypeEnum.end_frame,
    ];
    for (var sceneType in order) {
      List<int> list = List<int>.from(draft[sceneType] ?? <int>[])..sort();
      if(list.isEmpty) continue;
      if(previousEnd != null && list.first != previousEnd + 1){
        return "同一个 scene 的起始帧 / 高光帧 / 结束帧之间必须首尾连续，不能遗漏中间句子。";
      }
      previousEnd = list.last;
    }
    return null;
  }

  /// 当前 ASS 是否由“当前 scene + 当前帧”选中
  bool assSelectedByCurrentFrame(int? dialogueIndex){
    if(dialogueIndex == null) return false;
    if(!_isDialogueAssignableToCurrentScene(dialogueIndex)) return false;
    if(currentSceneIndex.value < 0 || currentSceneIndex.value >= scenesList.length) return false;
    int? currentSceneUid = scenesList[currentSceneIndex.value].uid;
    if(currentSceneUid == null) return false;
    return assOwnerSceneUidMap[dialogueIndex] == currentSceneUid && assOwnerSceneTypeMap[dialogueIndex] == currentSceneTypeEnum.value;
  }

  /// 当前 ASS 是否被其他 scene/帧占用（锁定态）
  bool assLockedByOtherFrame(int? dialogueIndex){
    if(dialogueIndex == null) return false;
    if(!_isDialogueAssignableToCurrentScene(dialogueIndex)) return true;
    if(currentSceneIndex.value < 0 || currentSceneIndex.value >= scenesList.length) return false;
    int? currentSceneUid = scenesList[currentSceneIndex.value].uid;
    if(currentSceneUid == null) return false;

    int? ownerSceneUid = assOwnerSceneUidMap[dialogueIndex];
    SceneTypeEnum? ownerSceneType = assOwnerSceneTypeMap[dialogueIndex];
    if(ownerSceneUid == null || ownerSceneType == null) return false;
    return !(ownerSceneUid == currentSceneUid && ownerSceneType == currentSceneTypeEnum.value);
  }

  /// 获取 ASS 归属文案（用于列表底部提示）
  String getAssOwnerLabel(int? dialogueIndex){
    if(dialogueIndex == null) return "可选择";
    if(!_isDialogueAssignableToCurrentScene(dialogueIndex)){
      int? sceneUid = _getDialogueSceneUidByIndex(dialogueIndex);
      int? sceneIndex = _findSceneByUid(sceneUid)?.index;
      return "仅可被 Scene ${sceneIndex ?? '?'} 选择";
    }
    int? ownerSceneUid = assOwnerSceneUidMap[dialogueIndex];
    SceneTypeEnum? ownerSceneType = assOwnerSceneTypeMap[dialogueIndex];
    if(ownerSceneUid == null || ownerSceneType == null) return "可选择";
    int? sceneIndex = _findSceneByUid(ownerSceneUid)?.index;
    return "已被 Scene ${sceneIndex ?? '?'} · ${ownerSceneType.label} 选中";
  }

  /// 这条 ASS 是否允许被当前 scene 选择（由 dialogue.sceneId 限制）
  bool _isDialogueAssignableToCurrentScene(int? dialogueIndex){
    if(dialogueIndex == null) return false;
    if(currentSceneIndex.value < 0 || currentSceneIndex.value >= scenesList.length) return false;
    int? currentSceneUid = scenesList[currentSceneIndex.value].uid;
    int? dialogueSceneUid = _getDialogueSceneUidByIndex(dialogueIndex);
    if(currentSceneUid == null) return false;
    if(dialogueSceneUid == null) return true;
    return dialogueSceneUid == currentSceneUid;
  }

  /// 通过 ASS index 找到该 ASS 的 sceneId
  int? _getDialogueSceneUidByIndex(int dialogueIndex){
    for (var item in dialogueList) {
      if(item.data.index == dialogueIndex){
        return item.data.sceneId;
      }
    }
    return null;
  }
  
  /// 从场景数据重建 ASS 归属索引
  /// 用于初始化页面时同步后端已有 mapping 状态
  void _rebuildAssOwnerMap(){
    assOwnerSceneUidMap.clear();
    assOwnerSceneTypeMap.clear();

    for (var scene in scenesList) {
      _bindOwnerFromSceneType(
        sceneUid: scene.uid,
        sceneType: SceneTypeEnum.start_frame,
        assDialogueList: scene.composition?.keyframes?.start?.mappings?.assDialogueList,
      );
      _bindOwnerFromSceneType(
        sceneUid: scene.uid,
        sceneType: SceneTypeEnum.highlight_frame,
        assDialogueList: scene.composition?.keyframes?.highlight?.mappings?.assDialogueList,
      );
      _bindOwnerFromSceneType(
        sceneUid: scene.uid,
        sceneType: SceneTypeEnum.end_frame,
        assDialogueList: scene.composition?.keyframes?.end?.mappings?.assDialogueList,
      );
    }
  }

  /// 把某个 sceneType 下的 assDialogueList 写入归属索引
  void _bindOwnerFromSceneType({
    required int? sceneUid,
    required SceneTypeEnum sceneType,
    required List<int?>? assDialogueList,
  }){
    if(sceneUid == null || assDialogueList == null) return;
    for (var item in assDialogueList) {
      if(item == null) continue;
      assOwnerSceneUidMap[item] = sceneUid;
      assOwnerSceneTypeMap[item] = sceneType;
    }
  }

  /// 通过 sceneUid 查找 scene
  ManageVisuaAssMappingEntityScenes? _findSceneByUid(int? sceneUid){
    if(sceneUid == null) return null;
    for (var scene in scenesList) {
      if(scene.uid == sceneUid){
        return scene;
      }
    }
    return null;
  }

  /// 取得当前 sceneType 对应 mapping；不存在则自动补齐结构并创建
  ManageVisuaAssMappingEntityScenesCompositionKeyframeMapping _getOrCreateSceneTypeMapping({
    required ManageVisuaAssMappingEntityScenes scene,
    required SceneTypeEnum sceneType,
  }){
    scene.composition ??= ManageVisuaAssMappingEntityScenesComposition();
    scene.composition!.keyframes ??= ManageVisuaAssMappingEntityScenesCompositionKeyframes();

    ManageVisuaAssMappingEntityScenesCompositionKeyframe? keyframe;
    if(sceneType == SceneTypeEnum.start_frame){
      scene.composition!.keyframes!.start ??= ManageVisuaAssMappingEntityScenesCompositionKeyframe();
      keyframe = scene.composition!.keyframes!.start;
    } else if(sceneType == SceneTypeEnum.highlight_frame){
      scene.composition!.keyframes!.highlight ??= ManageVisuaAssMappingEntityScenesCompositionKeyframe();
      keyframe = scene.composition!.keyframes!.highlight;
    } else {
      scene.composition!.keyframes!.end ??= ManageVisuaAssMappingEntityScenesCompositionKeyframe();
      keyframe = scene.composition!.keyframes!.end;
    }

    keyframe!.mappings ??= ManageVisuaAssMappingEntityScenesCompositionKeyframeMapping(
      sceneType: sceneType.value,
      assDialogueList: <int>[],
    );
    keyframe.mappings!.sceneType = sceneType.value;
    keyframe.mappings!.assDialogueList ??= <int>[];
    return keyframe.mappings!;
  }

  /// 获取某个 scene + 帧类型下的 ASS 列表（已过滤并排序）
  List<int> _getSceneTypeAssList(ManageVisuaAssMappingEntityScenes scene, SceneTypeEnum sceneType){
    List<int?> assDialogueList = _getOrCreateSceneTypeMapping(scene: scene, sceneType: sceneType).assDialogueList??[];
    return assDialogueList.whereType<int>().toList()..sort();
  }

  /// 覆盖某个 scene + 帧类型下的 ASS 列表
  void _setSceneTypeAssList(ManageVisuaAssMappingEntityScenes scene, SceneTypeEnum sceneType, List<int> list){
    _getOrCreateSceneTypeMapping(scene: scene, sceneType: sceneType).assDialogueList = List<int>.from(list);
  }

  /// 清空当前scene所有ASS映射
  void clearCurrentSceneMapping(){
    if(scenesList.isEmpty) return;
    if(currentSceneIndex.value < 0 || currentSceneIndex.value >= scenesList.length) return;

    ManageVisuaAssMappingEntityScenes currentScene = scenesList[currentSceneIndex.value];
    int? currentSceneUid = currentScene.uid;
    if(currentSceneUid == null) return;

    // 1) 清理该 scene 在 ASS 归属索引中的占用
    List<int> removeAssIndexList = assOwnerSceneUidMap.entries.where((entry) => entry.value == currentSceneUid).map((entry) => entry.key).toList();
    for (var assIndex in removeAssIndexList) {
      assOwnerSceneUidMap.remove(assIndex);
      assOwnerSceneTypeMap.remove(assIndex);
    }

    // 2) 清空该 scene 下三种关键帧的映射列表
    currentScene.composition?.keyframes?.start?.mappings?.assDialogueList = <int>[];
    currentScene.composition?.keyframes?.highlight?.mappings?.assDialogueList = <int>[];
    currentScene.composition?.keyframes?.end?.mappings?.assDialogueList = <int>[];

    // 3) 刷新列表与依赖状态
    scenesList.refresh();
    ToastUtils.showToast(text: "已清空当前 scene 的映射，请保存后生效", type: ToastType.success);
  }


  /// 根据当前播放进度获取 对应的scene和scene对应的帧 返回字符串示例 Scene 1(Scene的index)  ·  起始帧(实际的帧)
  /// 如果没有返回空字符串
  String getCurrentPlaybackSceneFrameLabel(){
    int currentMs = currentPosition.value.inMilliseconds;
    int? assIndex = _getCurrentAssIndexByPosition(currentMs);
    if(assIndex == null) return "";

    int? sceneUid = assOwnerSceneUidMap[assIndex];
    SceneTypeEnum? sceneType = assOwnerSceneTypeMap[assIndex];
    if(sceneUid == null || sceneType == null) return "";

    ManageVisuaAssMappingEntityScenes? scene = _findSceneByUid(sceneUid);
    if(scene == null) return "";

    return "Scene ${scene.index ?? ''} · ${sceneType.label}";
  }

  /// 根据播放毫秒数，返回命中的 ASS index
  int? _getCurrentAssIndexByPosition(int currentMs){
    for (var item in dialogueList) {
      int? start = item.sentence.sentenceStartTime;
      int? end = item.sentence.sentenceEndTime;
      int? index = item.data.index;
      if(start == null || end == null || index == null) continue;
      if(currentMs >= start && currentMs < end){
        return index;
      }
    }
    return null;
  }

  /// 获取 persona 对应的 dialogue 展示文案（按 variantNid 关联 scene.dialogues）
  PersonaDialogueDisplayModel getPersonaDialogueDisplayModel({
    required ManageVisuaAssMappingEntityScenes scene,
    required ManageVisuaAssMappingEntityScenesPersonas? persona,
  }){
    List<ManageVisuaAssMappingEntityScenesDialogues> relatedDialogues = _findDialoguesByVariantNid(scene, persona?.variantNid);

    String dialogueUidText = "dialogue_uid: -";
    if(relatedDialogues.isNotEmpty){
      List<String> uidList = relatedDialogues.map((item) => item.uid).whereType<int>().map((uid) => uid.toString()).toList();
      if(uidList.isNotEmpty){
        dialogueUidText = "dialogue_uid: ${uidList.join(", ")}";
      }
    }

    String dialogueContentText = relatedDialogues.map((item) => item.text ?? "").where((item) => item.isNotEmpty).join("\n");
    if(dialogueContentText.isEmpty){
      dialogueContentText = "-";
    }

    return PersonaDialogueDisplayModel(
      dialogueUidText: dialogueUidText,
      dialogueContentText: dialogueContentText,
    );
  }

  /// 在一个 scene 内，根据 persona 的 variantNid 找到对应 dialogues（按 index 排序）
  List<ManageVisuaAssMappingEntityScenesDialogues> _findDialoguesByVariantNid(
    ManageVisuaAssMappingEntityScenes scene,
    String? variantNid,
  ){
    List<ManageVisuaAssMappingEntityScenesDialogues?> sceneDialogues = scene.dialogues ?? [];
    List<ManageVisuaAssMappingEntityScenesDialogues> relatedDialogues = <ManageVisuaAssMappingEntityScenesDialogues>[];
    for (var dialogue in sceneDialogues) {
      if(dialogue == null) continue;
      if(dialogue.variantNid != variantNid) continue;
      relatedDialogues.add(dialogue);
    }
    relatedDialogues.sort((a, b) => (a.index ?? 0).compareTo(b.index ?? 0));
    return relatedDialogues;
  }

  /// 保存当前scene映射
  Future<void> saveSceneMapping() async{
    if(projectId == null) return;
    if(projectId == null) return;
    if(projectId == null) return;
    ManageVisuaAssMappingEntityScenes currentScene = scenesList[currentSceneIndex.value];
    try {
      ToastUtils.showLoading();

      List<int?>? sAssDialogueList = currentScene.composition?.keyframes?.start?.mappings?.assDialogueList??[];
      List<int> startAssDialogueList = sAssDialogueList.whereType<int>().toList()..sort();
      
      List<int?>? hAssDialogueList = currentScene.composition?.keyframes?.highlight?.mappings?.assDialogueList??[];
      List<int> highlightAssDialogueList = hAssDialogueList.whereType<int>().toList()..sort();
      
      List<int?>? eAssDialogueList = currentScene.composition?.keyframes?.end?.mappings?.assDialogueList??[];
      List<int> endAssDialogueList = eAssDialogueList.whereType<int>().toList()..sort();
      
      Map<String, dynamic> reqData = {
        "projectId": projectId,
        "sceneId": currentScene.uid,
        "mapping": [
          {
            "sceneType": SceneTypeEnum.start_frame.value,
            "assDialogueList": startAssDialogueList,
          },
          {
            "sceneType": SceneTypeEnum.highlight_frame.value,
            "assDialogueList": highlightAssDialogueList,
          },
          {
            "sceneType": SceneTypeEnum.end_frame.value,
            "assDialogueList": endAssDialogueList,
          },
        ],
      };
      bool res = await LanguageConsoleDramaRequest.visualProjectSaveSceneMapping(data: reqData);
      if(!res) return;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      getMappingData();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 生成关键帧字幕
  Future<void> generateKeyframeSubtitles(BuildContext context) async{
    if(projectId == null) return;

    if(!canCreateKeyframeSubtitles()){
      ToastUtils.showToast(text: "只有在所有 scene 和所有 ASS 字幕都完成连续映射后，才能创建关键帧字幕。", type: ToastType.warning);
      return;
    }

    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: "提示",
      content: "确定创建关键帧字幕吗？",
      cancel: "取消",
      define: "确定",
    );
    if(!askRes) return;

    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "projectId": projectId,
      };
      bool res = await LanguageConsoleDramaRequest.visualGenerateKeyframeSubtitles(data: reqData);
      if(!res) return;
      ToastUtils.showToast(text: "提交成功", type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
  }



  @override
  void onClose() {
    playerStateSubscription?.cancel();
    playerDurationSubscription?.cancel();
    playerPositionSubscription?.cancel();
    // TODO: 清理逻辑
    super.onClose();
  }
}
