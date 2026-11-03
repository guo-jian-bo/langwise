import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';
import '../../enums/manage_zhendu_enums.dart';
import '../models/manage_vocal_timbre_model.dart';
import '../views/manage_add_dialect_timber_dialog.dart';
import '../views/manage_add_dialect_timber_update_audio_dialog.dart';


class ManageVocalTimbreController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageVocalTimbreController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_VOCAL_TIMBRE;

  @override
  String get breadcrumbTitle => '人声音色';

  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{
    "uid": FilterSortsData(
      title: "uid",
      sorts: [
        FilterSortsItem(name: "从小到大", direction: FilterSortDirection.up),
        FilterSortsItem(name: "从大到小", direction: FilterSortDirection.down, selected: true, isDefault: true),
      ],
    ),
    "name": FilterSortsData(
      title: "中文名",
      sorts: [
        FilterSortsItem(name: "从A到Z", direction: FilterSortDirection.up),
        FilterSortsItem(name: "从Z到A", direction: FilterSortDirection.down),
      ],
    ),
    "dia_count_dialects": FilterSortsData(
      title: "方言数量",
      sorts: [
        FilterSortsItem(name: "从少到多", direction: FilterSortDirection.up),
        FilterSortsItem(name: "从多到少", direction: FilterSortDirection.down),
      ],
    ),
  }.obs;

  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{
    "morality": FilterConditionsData(
      title: "morality",
      conditions: ManageZhenduVocalTimbreMoralityEnum.values.map((e) => FilterConditionsItem(
        name: e.value,
        value: e.value,
      )).toList(),
    ),
    "manner": FilterConditionsData(
      title: "manner",
      conditions: ManageZhenduVocalTimbreMannerEnum.values.map((e) => FilterConditionsItem(
        name: e.value,
        value: e.value,
      )).toList(),
    ),
    "gender": FilterConditionsData(
      title: "gender",
      conditions: ManageZhenduGenderEnum.values.map((e) => FilterConditionsItem(
        name: e.value,
        value: e.value,
      )).toList(),
    ),
    "category": FilterConditionsData(
      title: "category",
      conditions: ManageZhenduVocalTimbreCategoryEnum.values.map((e) => FilterConditionsItem(
        name: e.value,
        value: e.value,
      )).toList(),
    ),
    "background": FilterConditionsData(
      title: "background",
      conditions: ManageZhenduVocalTimbreBackgroundEnum.values.map((e) => FilterConditionsItem(
        name: e.value,
        value: e.value,
      )).toList(),
    ),
    "age_group": FilterConditionsData(
      title: "age_group",
      conditions: ManageZhenduAgeGroupEnum.values.map((e) => FilterConditionsItem(
        name: e.value,
        value: e.value,
      )).toList(),
    ),
  }.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "uids": FilterSearchsData(
      title: "精确uid",
      hintText: "只匹配单个uid",
      controller: TextEditingController(),
      isCommaSeparated: true,
    ),
    "keyword": FilterSearchsData(
      title: "综合搜索",
      hintText: "综合搜索",
      controller: TextEditingController(),
    ),
    "nid": FilterSearchsData(
      title: "nid",
      hintText: "nid",
      controller: TextEditingController(),
    ),
    "name": FilterSearchsData(
      title: "name",
      hintText: "name",
      controller: TextEditingController(),
    ), 
  };


  final ScrollController leftScrollController = ScrollController();

  int limit = 20;
  int offset = 0;
  int total = 0;
  bool isLoading = true;
  /// 列表数据
  final RxList<ManageVocalTimbreModel> listData = <ManageVocalTimbreModel>[].obs;

  /// 当前选中的下标
  final RxInt currentIndex = 0.obs;
  final RxBool isEditing = false.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if(Get.arguments != null){
      String? timbreNid = Get.arguments["timbreNid"];
      if(timbreNid != null){
        filterSearchs["nid"]?.controller.text = timbreNid;
      }
    }

    listenScroll();
    refreshListData();
  }

  /// 监听列表滚动进行分页加载
  void listenScroll(){
    leftScrollController.addListener(() {
      if(leftScrollController.position.pixels >= leftScrollController.position.maxScrollExtent - 200 && !leftScrollController.position.outOfRange){
        if(!isLoading && listData.length < total){
          offset += limit;
          getListData();
        }
      }
    });
  }

  /// 刷新列表数据
  Future<void> refreshListData({bool isReset = true}) async{
    isEditing.value = false;
    if(isReset) currentIndex.value = 0;
    total = 0;
    offset = 0;
    listData.clear();
    await getListData();
  }

  /// 获取列表数据
  Future<void> getListData() async{
    try {
      isLoading = true;
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "limit": limit,
        "offset": offset,
      };
      Map<String, dynamic> sortOrder = FilterStripUtils.getSortOrderParameter(sorts: filterSorts);
      parameters.addAll(sortOrder);
      Map<String, dynamic> reqData = {};
      Map<String, dynamic> conditionParameter = FilterStripUtils.getConditionParameter(conditions: filterConditions);
      reqData.addAll(conditionParameter);

      Map<String, dynamic> searchParameter = FilterStripUtils.getSearchParameter(searchs: filterSearchs);
      reqData.addAll(searchParameter);

      ListResponseEntity<ManageVocalTimbreEntity>? res = await LanguageConsoleDramaRequest.getVocalTimbreList(parameters: parameters, data: reqData);
      if(res == null) return;
      total = res.count ?? 0;
      List<ManageVocalTimbreEntity> list = res.datas??[];
      for(ManageVocalTimbreEntity item in list){
        listData.add(setModel(item));
      }
    } finally{
      isLoading = false;
      ToastUtils.hideLoading();
    }
  }

  /// 根据nid获取单个数据 用作刷新单个数据
  Future<ManageVocalTimbreEntity?> getListSingleDataForNid(String? nid) async{
    if(nid == null) return null;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "limit": 10,
        "offset": 0,
        "order": "-uid",
      };
      Map<String, dynamic> reqData = {
        "nid": nid,
      };
      ListResponseEntity<ManageVocalTimbreEntity>? res = await LanguageConsoleDramaRequest.getVocalTimbreList(parameters: parameters, data: reqData);
      if(res == null) return null;
      List<ManageVocalTimbreEntity> list = res.datas??[];
      if(list.isEmpty) return null;
      return list.first;
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// set模型数据到本地model
  ManageVocalTimbreModel setModel(ManageVocalTimbreEntity item){
    List<LanguageText?> nameList = item.name??[];
    String enName = nameList.firstWhereOrNull((element) => element?.lang == "en")?.text??"";
    String zhName = nameList.firstWhereOrNull((element) => element?.lang == "zh")?.text??"";

    List<ManageVocalDialectTimbreCodeModel> dialectTimbreCodes = [
      ManageVocalDialectTimbreCodeModel(code: ManageZhenduDialectEnum.enUS.value),
      ManageVocalDialectTimbreCodeModel(code: ManageZhenduDialectEnum.enGB.value),
      ManageVocalDialectTimbreCodeModel(code: ManageZhenduDialectEnum.zhCN.value),
    ];

    List<ManageVocalDialectTimbreModel> dialectTimbres = [];
    List<ManageVocalTimbreEntityAudioRefs?>? audioRefs = item.audioRefs;
    if(audioRefs != null){
      for(var ref in audioRefs){
        if(ref == null) continue;
        String dialect = ref.dialect ?? "";
        for(var code in dialectTimbreCodes){
          if(code.code == dialect){
            code.isOccupy = true;
          }
        }
        dialectTimbres.add(ManageVocalDialectTimbreModel(
          dialect: dialect,
          descriptionInput: TextEditingController(text: ref.description ?? ""),
          audioTextInput: TextEditingController(text: ref.audioText ?? ""),
          actorInput: TextEditingController(text: ref.actor ?? ""),
          urlInput: TextEditingController(text: ref.url ?? ""),
          data: ref,
          audio: ref.audio,
        ));
      }
    }

    return ManageVocalTimbreModel(
      data: item,
      nidInput: TextEditingController(text: item.nid ?? ""),
      enNameInput: TextEditingController(text: enName),
      zhNameInput: TextEditingController(text: zhName),
      category: ManageZhenduVocalTimbreCategoryEnum.fromValue(item.category),
      gender: ManageZhenduGenderEnum.fromValue(item.gender),
      ageGroup: ManageZhenduAgeGroupEnum.fromValue(item.ageGroup),
      manner: ManageZhenduVocalTimbreMannerEnum.fromValue(item.manner),
      morality: ManageZhenduVocalTimbreMoralityEnum.fromValue(item.morality),
      background: ManageZhenduVocalTimbreBackgroundEnum.fromValue(item.background),
      labelInput: TextEditingController(text: item.label ?? ""),
      dialectTimbreCodes: dialectTimbreCodes,
      dialectTimbres: dialectTimbres,
    );
  }

  /// 判断当前选中项是否有未保存的改变
  bool _hasChanges(ManageVocalTimbreModel model) {
    if (model.data?.uid == null) return true;
    final data = model.data;
    if (data == null) return false;
    List<LanguageText?> nameList = data.name ?? [];
    String enName = nameList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhName = nameList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";
    if (model.nidInput.text != (data.nid ?? "")) return true;
    if (model.enNameInput.text != enName) return true;
    if (model.zhNameInput.text != zhName) return true;
    if (model.category?.value != data.category) return true;
    if (model.gender?.value != data.gender) return true;
    if (model.ageGroup?.value != data.ageGroup) return true;
    if (model.manner?.value != data.manner) return true;
    if (model.morality?.value != data.morality) return true;
    if (model.background?.value != data.background) return true;
    if (model.labelInput.text != (data.label ?? "")) return true;
    // 比较方言音色
    List<ManageVocalTimbreEntityAudioRefs?>? audioRefs = data.audioRefs;
    int origLen = audioRefs?.length ?? 0;
    if (model.dialectTimbres.length != origLen) return true;
    for (int i = 0; i < model.dialectTimbres.length; i++) {
      final t = model.dialectTimbres[i];
      final r = audioRefs![i];
      if (t.dialect != (r?.dialect ?? "")) return true;
      if (t.descriptionInput.text != (r?.description ?? "")) return true;
      if (t.audioTextInput.text != (r?.audioText ?? "")) return true;
    }
    return false;
  }

  /// 重置模型到原始数据
  void _resetToOriginal(ManageVocalTimbreModel model) {
    final data = model.data;
    if (data == null) return;
    List<LanguageText?> nameList = data.name ?? [];
    String enName = nameList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhName = nameList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";
    model.nidInput.text = data.nid ?? "";
    model.enNameInput.text = enName;
    model.zhNameInput.text = zhName;
    model.category = ManageZhenduVocalTimbreCategoryEnum.fromValue(data.category);
    model.gender = ManageZhenduGenderEnum.fromValue(data.gender);
    model.ageGroup = ManageZhenduAgeGroupEnum.fromValue(data.ageGroup);
    model.manner = ManageZhenduVocalTimbreMannerEnum.fromValue(data.manner);
    model.morality = ManageZhenduVocalTimbreMoralityEnum.fromValue(data.morality);
    model.background = ManageZhenduVocalTimbreBackgroundEnum.fromValue(data.background);
    model.labelInput.text = data.label ?? "";
    // 重置方言音色codes
    for (var code in model.dialectTimbreCodes) {
      code.isOccupy = false;
    }
    // 重置方言音色列表
    model.dialectTimbres.clear();
    List<ManageVocalTimbreEntityAudioRefs?>? audioRefs = data.audioRefs;
    if (audioRefs != null) {
      for (var ref in audioRefs) {
        if (ref == null) continue;
        String dialect = ref.dialect ?? "";
        for (var code in model.dialectTimbreCodes) {
          if (code.code == dialect) {
            code.isOccupy = true;
          }
        }
        model.dialectTimbres.add(ManageVocalDialectTimbreModel(
          dialect: dialect,
          descriptionInput: TextEditingController(text: ref.description ?? ""),
          audioTextInput: TextEditingController(text: ref.audioText ?? ""),
          actorInput: TextEditingController(text: ref.actor ?? ""),
          urlInput: TextEditingController(text: ref.url ?? ""),
          data: ref,
          audio: ref.audio,
        ));
      }
    }
    listData.refresh();
  }

  /// 选择音色
  Future<void> selectLeftTimbre(BuildContext context, int index) async {
    if (index == currentIndex.value) return;
    int targetIndex = index;
    final currentModel = listData[currentIndex.value];
    if (_hasChanges(currentModel)) {
      bool isUnsavedNew = currentModel.data?.uid == null;
      bool? askRes = await AskDialog.showUserCancelAsk(
        context: context,
        title: "提示",
        content: isUnsavedNew ? "新增的数据未保存，是否保存？" : "当前数据已修改，是否保存？",
        cancel: isUnsavedNew ? "取消" : "不保存",
        define: "保存",
      );
      if (askRes == null) return;
      if (askRes) {
        bool saveRes = await editTimbre();
        if (!saveRes) return;
      } else {
        if (isUnsavedNew) {
          int removedIndex = currentIndex.value;
          listData.removeAt(removedIndex);
          if (removedIndex < targetIndex) {
            targetIndex -= 1;
          }
          if (listData.isEmpty) {
            currentIndex.value = 0;
            return;
          }
          if (currentIndex.value >= listData.length) {
            currentIndex.value = listData.length - 1;
          }
        } else {
          _resetToOriginal(currentModel);
        }
      }
    }
    currentIndex.value = targetIndex.clamp(0, listData.length - 1);
    isEditing.value = false;
  }


  /// 新增音色
  Future<void> addTimbre(BuildContext context) async{
    if (listData.isNotEmpty) {
      final currentModel = listData[currentIndex.value];
      if (_hasChanges(currentModel)) {
        bool isUnsavedNew = currentModel.data?.uid == null;
        bool? askRes = await AskDialog.showUserCancelAsk(
          context: context,
          title: "提示",
          content: isUnsavedNew ? "新增的数据未保存，是否保存？" : "当前数据已修改，是否保存？",
          cancel: isUnsavedNew ? "取消" : "不保存",
          define: "保存",
        );
        if (askRes == null) return;
        if (askRes) {
          bool saveRes = await editTimbre();
          if (!saveRes) return;
        } else {
          if (isUnsavedNew) {
            listData.removeAt(currentIndex.value);
            if (listData.isEmpty) {
              currentIndex.value = 0;
            } else if (currentIndex.value >= listData.length) {
              currentIndex.value = listData.length - 1;
            }
          } else {
            _resetToOriginal(currentModel);
          }
        }
      }
    }

    // searchInput.clear();

    List<ManageVocalDialectTimbreCodeModel> dialectTimbreCodes = [
      ManageVocalDialectTimbreCodeModel(code: ManageZhenduDialectEnum.enUS.value, isOccupy: true),
      ManageVocalDialectTimbreCodeModel(code: ManageZhenduDialectEnum.enGB.value),
      ManageVocalDialectTimbreCodeModel(code: ManageZhenduDialectEnum.zhCN.value),
    ];

    ManageVocalTimbreModel addModel = ManageVocalTimbreModel(
      nidInput: TextEditingController(),
      enNameInput: TextEditingController(),
      zhNameInput: TextEditingController(),
      category: ManageZhenduVocalTimbreCategoryEnum.general,
      gender: ManageZhenduGenderEnum.unknown,
      ageGroup: ManageZhenduAgeGroupEnum.youngAdult,
      manner: ManageZhenduVocalTimbreMannerEnum.neutral,
      morality: ManageZhenduVocalTimbreMoralityEnum.neutral,
      background: ManageZhenduVocalTimbreBackgroundEnum.standard,
      labelInput: TextEditingController(text: "label"),
      dialectTimbreCodes: dialectTimbreCodes,
      dialectTimbres: [
        ManageVocalDialectTimbreModel(
          dialect: dialectTimbreCodes.first.code,
          descriptionInput: TextEditingController(),
          audioTextInput: TextEditingController(),
          actorInput: TextEditingController(),
          urlInput: TextEditingController(),
        ),
      ],
    );

    listData.insert(0, addModel);
    currentIndex.value = 0;
    isEditing.value = true;
    listData.refresh();
    if(!leftScrollController.hasClients) return;
    leftScrollController.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.linear);
  }


  /// 删除音色
  Future<void> deleteTimbre(BuildContext context) async{
    if(listData.isEmpty) return;
    ManageVocalTimbreModel currentModel = listData[currentIndex.value];
    bool askRes = await DeleteDialog.show(
      context: context, 
      title: "删除",
      content: "您确定要删除此条音色数据吗？",
      showCountdown: currentModel.data?.uid != null,
    );
    if(!askRes) return;

    if(currentModel.data?.uid == null){
      listData.removeAt(currentIndex.value);
      if (listData.isEmpty) {
        currentIndex.value = 0;
      } else if (currentIndex.value >= listData.length) {
        currentIndex.value = listData.length - 1;
      }
      isEditing.value = false;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      return;
    }

    try {
      ToastUtils.showLoading();
      bool res = await LanguageConsoleDramaRequest.deleteVocalTimbre(currentModel.data!.uid!);
      if(!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      listData.removeAt(currentIndex.value);
      if (listData.isEmpty) {
        currentIndex.value = 0;
      } else if (currentIndex.value >= listData.length) {
        currentIndex.value = listData.length - 1;
      }
      isEditing.value = false;
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 音频定稿
  Future<void> audioLocked(BuildContext context, ManageVocalTimbreEntityAudioRefsAudio? audio) async{
    if(audio?.relationId == null) return;
    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "确定要将此音频定稿吗？",
    );
    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "relationUid": audio!.relationId!,
      };
      bool res = await LanguageConsoleRequest.finalDraftAudio(parameters: parameters);
      if(!res) return;
      ToastUtils.showToast(text: "定稿成功", type: ToastType.success);
      audio.locked = true;
      listData.refresh();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 音频取消定稿
  Future<void> audioUnLocked(BuildContext context, ManageVocalTimbreEntityAudioRefsAudio? audio) async{
    if(audio?.relationId == null) return;
    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "确定要将此音频取消定稿吗？",
    );
    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "relationUid": audio!.relationId!,
      };
      bool res = await LanguageConsoleRequest.unlockDraftAudio(parameters: parameters);
      if(!res) return;
      ToastUtils.showToast(text: "取消定稿成功", type: ToastType.success);
      audio.locked = false;
      listData.refresh();
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 启用/停用
  Future<void> editEnabled(BuildContext context) async{
    if(listData[currentIndex.value].data?.uid == null) return;
    bool enabled = listData[currentIndex.value].data?.enabled??false;

    bool askRes = await AskDialog.showUserAsk(
      context: context, 
      title: enabled ? "停用" : "启用",
      content: "您确定要${enabled ? "停用" : "启用"}此条音色吗？",
    );
    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "enabled": !enabled,
      };
      ManageVocalTimbreEntity? res = await LanguageConsoleDramaRequest.editVocalTimbre(listData[currentIndex.value].data!.uid!, data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: enabled ? "停用成功" : "启用成功", type: ToastType.success);
      listData[currentIndex.value].data!.enabled = !enabled;
      listData.refresh();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 保存（新增/编辑）
  Future<bool> editTimbre() async{
    if(listData.isEmpty) return false;
    ManageVocalTimbreModel editModel = listData[currentIndex.value];
    bool isCreate = editModel.data?.uid == null;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = _buildTimbreReqData(editModel);
      ManageVocalTimbreEntity? res;
      if (isCreate) {
        reqData["enabled"] = false;
        res = await LanguageConsoleDramaRequest.addVocalTimbre(data: reqData);
      } else {
        res = await LanguageConsoleDramaRequest.editVocalTimbre(editModel.data!.uid!, data: reqData);
      }
      if(res == null) return false;
      ToastUtils.showToast(text: isCreate ? "新增成功" : "编辑成功", type: ToastType.success);
      listData[currentIndex.value] = setModel(res);
      isEditing.value = false;
      listData.refresh();
      return true;
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 构建音色请求数据
  Map<String, dynamic> _buildTimbreReqData(ManageVocalTimbreModel model){
    List<Map<String, dynamic>> audioRefs = [];
    for(var timbre in model.dialectTimbres){
      audioRefs.add({
        "language": timbre.dialect.split("-").first,
        "dialect": timbre.dialect,
        "description": timbre.descriptionInput.text,
        "audio_text": timbre.audioTextInput.text,
        "actor": timbre.actorInput.text,
        "url": timbre.urlInput.text,
      });
    }
    return {
      "nid": model.nidInput.text,
      "name": [
        {
          "lang": "en",
          "text": model.enNameInput.text,
        },
        {
          "lang": "zh",
          "text": model.zhNameInput.text,
        },
      ],
      "category": model.category?.value,
      "gender": model.gender?.value,
      "age_group": model.ageGroup?.value,
      "manner": model.manner?.value,
      "morality": model.morality?.value,
      "background": model.background?.value,
      "label": model.labelInput.text,
      "audio_refs": audioRefs,
    };
  }

  /// 拉取最新音色并回写到列表中
  Future<bool> _refreshTimbreInList(ManageVocalTimbreModel data) async{
    final ManageVocalTimbreEntity? latestTimbre = await getListSingleDataForNid(data.data?.nid);
    if(latestTimbre == null) return false;
    return _replaceTimbreModelInList(data: data, updatedModel: setModel(latestTimbre));
  }

  /// 将更新后的音色模型按uid/nid回写到列表中
  bool _replaceTimbreModelInList({
    required ManageVocalTimbreModel data,
    required ManageVocalTimbreModel updatedModel,
  }){
    final int? currentUid = data.data?.uid;
    int replaceIndex = -1;
    if(currentUid != null){
      replaceIndex = listData.indexWhere((item) => item.data?.uid == currentUid);
    }
    if(replaceIndex == -1){
      final currentNid = data.data?.nid;
      replaceIndex = listData.indexWhere((item) => item.data?.nid == currentNid);
    }
    if(replaceIndex == -1) return false;
    listData[replaceIndex] = updatedModel;
    return true;
  }


  /// 新增方言音色
  Future<void> addDialectTimbre(BuildContext context, ManageVocalTimbreModel data) async{
    List<ManageVocalDialectTimbreCodeModel> dialectTimbreCodes = data.dialectTimbreCodes;
    ManageVocalDialectTimbreCodeModel? code;
    for(var item in dialectTimbreCodes){
      if(!item.isOccupy){
        code = item;
        break;
      }
    }

    if(code == null){
      return ToastUtils.showToast(text: "可选 dialect 已全部使用，不能重复新增。");
    }
    
    ManageAddDialectTimberCreateType? reslut = await ManageAddDialectTimberDialog.show(
      context: context, 
    );
    if(reslut == null) return;

    if(reslut == ManageAddDialectTimberCreateType.ai){

      ManageVocalDialectTimbreCodeModel? aiCode = await ManageAddDialectTimberDialog.showAiCreate(
        context: context, 
        dialectTimbreCodes: data.dialectTimbreCodes,
        selectCode: code,
      );
      if(aiCode == null) return;
      // TTDO: ai创建
      try {
        ToastUtils.showLoading();
        Map<String, dynamic> reqData = {
          "timbreUid": data.data!.uid,
          "dialect": aiCode.code,
        };
        String? res = await LanguageConsoleDramaRequest.designVocalTimbreAudioText(data: reqData);
        if(res == null) return;
        ToastUtils.showToast(text: res, type: ToastType.success);
      } finally{
        ToastUtils.hideLoading();
      }

      return;
    }

    /// 手动创建
    code.isOccupy = true;
    data.dialectTimbres.add(ManageVocalDialectTimbreModel(
      dialect: code.code,
      descriptionInput: TextEditingController(),
      audioTextInput: TextEditingController(),
      actorInput: TextEditingController(),
      urlInput: TextEditingController(),
    ));

    listData.refresh();

  }

  /// 获取 dialect 是否被占用
  void updateDialectIsoccupy(ManageVocalTimbreModel data, String orgDialect, String replaceDialect){
    List<ManageVocalDialectTimbreCodeModel> dialectTimbreCodes = data.dialectTimbreCodes;
    for(int i = 0; i < dialectTimbreCodes.length; i++){
      if(dialectTimbreCodes[i].code == orgDialect){
        dialectTimbreCodes[i].isOccupy = false;
      }
      if(dialectTimbreCodes[i].code == replaceDialect){
        dialectTimbreCodes[i].isOccupy = true;
      }
    }
    listData.refresh();

  }

  /// 删除方言音色
  Future<void> deleteDialectTimbre(BuildContext context, ManageVocalTimbreModel data, int index) async{
    bool askRes = await DeleteDialog.show(
      context: context, 
      title: "删除",
      content: "您确定要删除此条方言吗？",
      showCountdown: false,
    );
    if(!askRes) return;
    String code = data.dialectTimbreCodes[index].code;
    for(var item in data.dialectTimbreCodes){
      if(item.code == code) {
        item.isOccupy = false;
      }
    }
    data.dialectTimbres.removeAt(index);
    listData.refresh();
  }

  void startEdit() {
    isEditing.value = true;
  }

  Future<void> cancelEdit(BuildContext context) async {
    if (listData.isEmpty) return;
    final ManageVocalTimbreModel currentModel = listData[currentIndex.value];
    if (_hasChanges(currentModel)) {
      bool? askRes = await AskDialog.showUserCancelAsk(
        context: context,
        title: "提示",
        content: "当前数据已修改，取消编辑将丢失未保存内容，是否继续？",
        cancel: "继续编辑",
        define: "取消编辑",
      );
      if (askRes != true) return;
      if (currentModel.data?.uid == null) {
        listData.removeAt(currentIndex.value);
        if (listData.isEmpty) {
          currentIndex.value = 0;
        } else if (currentIndex.value >= listData.length) {
          currentIndex.value = listData.length - 1;
        }
      } else {
        _resetToOriginal(currentModel);
      }
    }
    isEditing.value = false;
  }


  /// 设计台词
  Future<void> designialogueLines(BuildContext context, ManageVocalTimbreModel data, ManageVocalDialectTimbreModel timbre) async{
    if(data.data?.uid == null) return;
    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: "温馨",
      content: "确定要开始设计台词吗？",
      defineColor: const Color(0xffFB923C),
      define: "开始设计",
    );
    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "timbreUid": data.data!.uid,
        "dialect": timbre.dialect,
      };
      String? res = await LanguageConsoleDramaRequest.designVocalTimbreAudioText(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 上传音频
  Future<void> uploadAudio(BuildContext context, ManageVocalTimbreModel data, ManageVocalDialectTimbreModel timbre) async{
    if(data.data?.uid == null) return;
    if(_hasChanges(data)){
      bool? askRes = await AskDialog.showUserCancelAsk(
        context: context,
        title: "提示",
        content: "当前数据已修改，是否保存？",
        cancel: "不保存",
        define: "保存",
      );
      if(askRes == null) return;
      if(askRes){
        final bool saveRes = await editTimbre();
        if(!saveRes) return;
        final bool isSaveRefreshSuccess = await _refreshTimbreInList(data);
        if(!isSaveRefreshSuccess) return;
        listData.refresh();
      }else{
        _resetToOriginal(data);
      }
    }


    ManageVocalTimbreEntityAudioRefsAudio? res = await ManageAddDialectTimberUpdateAudioDialog.show(
      context: context,
      data: data,
      timbre: timbre,
    );
    if(res == null) return;
    final bool isRefreshSuccess = await _refreshTimbreInList(data);
    if(!isRefreshSuccess) return;
    listData.refresh();
  }

  /// 打开参考链接
  Future<void> openReferenceLink(BuildContext context, ManageVocalDialectTimbreModel timbre) async{
    if(timbre.urlInput.text.isEmpty) return ToastUtils.showToast(text: "暂无参考链接");
    await launchUrl(Uri.parse(timbre.urlInput.text), mode: LaunchMode.externalApplication);
  }


  /// 审核音频
  Future<void> reviewAudio(ManageVocalTimbreModel data, ManageVocalDialectTimbreModel timbre) async{
    if(timbre.data?.audio?.audioTaskIds?.isEmpty ?? true){
      return ToastUtils.showToast(text: "暂无待审核");
    }
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_AUDIO,
      arguments: {
        "taskIds": timbre.data?.audio?.audioTaskIds,
      },
    );
    final bool isRefreshSuccess = await _refreshTimbreInList(data);
    if(!isRefreshSuccess) return;
    listData.refresh();
  }

  /// 生成音频
  Future<void> generateAudio(BuildContext context, ManageVocalTimbreModel data, ManageVocalDialectTimbreModel timbre) async{
    if(data.data?.uid == null) return;

    if(timbre.descriptionInput.text.isEmpty){
      return ToastUtils.showToast(text: "请输入description");
    }
    if(timbre.audioTextInput.text.isEmpty){
      return ToastUtils.showToast(text: "请输入audio_text");
    }

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "timbreUid": data.data!.uid,
        "dialect": timbre.dialect,
      };
      String? res = await LanguageConsoleDramaRequest.generateVocalTimbreAudio(data: reqData);
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
