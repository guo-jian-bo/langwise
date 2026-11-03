import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';

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


  final ScrollController leftScrollController = ScrollController();

  /// 搜索输入框
  final TextEditingController searchInput = TextEditingController();

  int limit = 20;
  int offset = 0;
  int total = 0;
  bool isLoading = true;
  /// 列表数据
  final RxList<ManageVocalTimbreModel> listData = <ManageVocalTimbreModel>[].obs;

  /// 当前选中的下标
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
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
  Future<void> refreshListData() async{
    currentIndex.value = 0;
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
        "order": "-uid",
      };
      Map<String, dynamic> reqData = {};
      if(searchInput.text.isNotEmpty){
        reqData["keyword"] = searchInput.text;
      }
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
          audio: ref.audio,
        ));
      }
    }
    listData.refresh();
  }

  /// 选择音色
  Future<void> selectLeftTimbre(BuildContext context, int index) async {
    if (index == currentIndex.value) return;
    final currentModel = listData[currentIndex.value];
    if (_hasChanges(currentModel)) {
      bool? askRes = await AskDialog.showUserCancelAsk(
        context: context,
        title: "提示",
        content: "当前数据已修改，是否保存？",
        cancel: "不保存",
        define: "保存",
      );
      if (askRes == null) return;
      if (askRes) {
        await editTimbre();
      } else {
        _resetToOriginal(currentModel);
      }
    }
    currentIndex.value = index;
  }


  /// 新增音色
  Future<void> addTimbre() async{
    searchInput.clear();

    List<ManageVocalDialectTimbreCodeModel> dialectTimbreCodes = [
      ManageVocalDialectTimbreCodeModel(code: ManageZhenduDialectEnum.enUS.value, isOccupy: true),
      ManageVocalDialectTimbreCodeModel(code: ManageZhenduDialectEnum.enGB.value),
      ManageVocalDialectTimbreCodeModel(code: ManageZhenduDialectEnum.zhCN.value),
    ];

    ManageVocalTimbreModel addModel = ManageVocalTimbreModel(
      nidInput: TextEditingController(text: "new-timbre-${listData.length + 1}-${DateTime.now().millisecondsSinceEpoch}"),
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
        ),
      ],
    );

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = _buildTimbreReqData(addModel);
      reqData["enabled"] = false;
      ManageVocalTimbreEntity? res = await LanguageConsoleDramaRequest.addVocalTimbre(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: "新增成功", type: ToastType.success);
      listData.insert(0, setModel(res));
      currentIndex.value = 0;
      if(!leftScrollController.hasClients) return;
      leftScrollController.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.linear);
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 删除音色
  Future<void> deleteTimbre(BuildContext context) async{
    if(listData[currentIndex.value].data?.uid == null) return;
    bool askRes = await DeleteDialog.show(
      context: context, 
      title: "删除",
      content: "您确定要删除此条音色数据吗？",
    );
    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      bool res = await LanguageConsoleDramaRequest.deleteVocalTimbre(listData[currentIndex.value].data!.uid!);
      if(!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      listData.removeAt(currentIndex.value);
      if(currentIndex.value != 0) {
        currentIndex.value --;
      }
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

  /// 保存编辑
  Future<void> editTimbre() async{
    if(listData[currentIndex.value].data?.uid == null) return;
    ManageVocalTimbreModel editModel = listData[currentIndex.value];

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = _buildTimbreReqData(editModel);
      ManageVocalTimbreEntity? res = await LanguageConsoleDramaRequest.editVocalTimbre(editModel.data!.uid!, data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: "编辑成功", type: ToastType.success);
      editModel.data = res;
      listData.refresh();
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
    ));

    listData.refresh();

    editTimbre();

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
    editTimbre();
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

    ManageVocalTimbreEntityAudioRefsAudio? res = await ManageAddDialectTimberUpdateAudioDialog.show(
      context: context,
      data: data,
      timbre: timbre,
    );
    if(res == null) return;
    timbre.audio = res;
    listData.refresh();
  }


  /// 审核音频
  Future<void> reviewAudio(ManageVocalTimbreModel data, ManageVocalDialectTimbreModel timbre) async{
    if(timbre.audio?.audioTaskIds?.isEmpty ?? true){
      return ToastUtils.showToast(text: "暂无待审核");
    }
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_AUDIO,
      arguments: {
        "taskIds": timbre.audio?.audioTaskIds,
      },
    );
    ManageVocalTimbreEntity? res = await getListSingleDataForNid(data.data?.nid);
    if(res == null) return;
    data = setModel(res);
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
