import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/utils/utils.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../enums/manage_zhendu_enums.dart';
import '../models/manage_persona_model.dart';
import '../views/manage_add_setting_diagram_dialog.dart';
import '../views/manage_adjust_tone_binding_dialog.dart';

class ManagePersonaController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManagePersonaController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_PERSONA;

  @override
  String get breadcrumbTitle => '角色管理';


  final ScrollController leftScrollController = ScrollController();

  /// 搜索输入框
  final TextEditingController searchInput = TextEditingController();

  int limit = 20;
  int offset = 0;
  int total = 0;
  bool isLoading = true;
  /// 数据列表
  final RxList<ManagePersonaModel> listData = <ManagePersonaModel>[].obs;

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
      ListResponseEntity<MangePersonaEntity>? res = await LanguageConsoleDramaRequest.getPersonaList(parameters: parameters, data: reqData);
      if(res == null) return;
      total = res.count ?? 0;
      List<MangePersonaEntity> list = res.datas??[];
      for(MangePersonaEntity item in list){
        listData.add(setModel(item));
      }
    } finally{
      isLoading = false;
      ToastUtils.hideLoading();
    }
  }

  /// 根据nid获取单个数据 用作刷新单个数据
  Future<MangePersonaEntity?> getListSingleDataForNid(String? nid) async{
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
      ListResponseEntity<MangePersonaEntity>? res = await LanguageConsoleDramaRequest.getPersonaList(parameters: parameters, data: reqData);
      if(res == null) return null;
      List<MangePersonaEntity> list = res.datas??[];
      if(list.isEmpty) return null;
      return list.first;
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// set模型数据到本地model
  ManagePersonaModel setModel(MangePersonaEntity item){
    List<MangePersonaEntityName?> nameList = item.name ?? [];
    String enName = "";
    String zhName = "";
    String enDialect = "";
    String zhDialect = "";
    for(var n in nameList){
      if(n == null) continue;
      if(n.lang == "en"){
        enName = n.text ?? "";
        enDialect = n.dialect ?? "";
      } else if(n.lang == "zh"){
        zhName = n.text ?? "";
        zhDialect = n.dialect ?? "";
      }
    }

    List<ManagePersonaVariantModel> variants = [];
    if(item.variants != null){
      for(var v in item.variants!){
        if(v == null) continue;
        variants.add(setVariantModel(v));
      }
    }

    String tagsStr = "";
    if(item.tags != null){
      tagsStr = item.tags!.whereType<String>().join(",");
    }

    return ManagePersonaModel(
      data: item,
      nidInput: TextEditingController(text: item.nid),
      scope: ManageZhenduPersonaScopeEnum.fromValue(item.scope),
      zhNameInput: TextEditingController(text: zhName),
      zhDialectInput: TextEditingController(text: zhDialect),
      enNameInput: TextEditingController(text: enName),
      enDialectInput: TextEditingController(text: enDialect),
      gender: ManageZhenduGenderEnum.fromValue(item.gender),
      speciesInput: TextEditingController(text: item.species),
      scopeRefIdInput: TextEditingController(text: item.scopeRefId?.toString()??""),
      personalityInput: TextEditingController(text: item.personality),
      appearanceInput: TextEditingController(text: item.appearance),
      tagsInput: TextEditingController(text: tagsStr),
      variants: variants,
    );
  }

  /// set变体模型数据
  ManagePersonaVariantModel setVariantModel(MangePersonaEntityVariants v){
    String enDescription = v.description?.firstWhereOrNull((element) => element?.lang == "en")?.text??"";
    String zhDescription = v.description?.firstWhereOrNull((element) => element?.lang == "zh")?.text??"";

    return ManagePersonaVariantModel(
      data: v,
      nidInput: TextEditingController(text: v.nid),
      variantNameInput: TextEditingController(text: v.name),
      ageGroup: ManageZhenduAgeGroupEnum.fromValue(v.ageGroup),
      speedOffsetInput: TextEditingController(text: v.speedOffset?.toString()??""),
      enDescInput: TextEditingController(text: enDescription),
      zhDescInput: TextEditingController(text: zhDescription),
    );
  }

  /// 判断当前选中项是否有未保存的改变
  bool _hasChanges(ManagePersonaModel model) {
    final data = model.data;
    if (data == null) return false;
    List<MangePersonaEntityName?> nameList = data.name ?? [];
    String enName = "";
    String zhName = "";
    String enDialect = "";
    String zhDialect = "";
    for (var n in nameList) {
      if (n == null) continue;
      if (n.lang == "en") {
        enName = n.text ?? "";
        enDialect = n.dialect ?? "";
      } else if (n.lang == "zh") {
        zhName = n.text ?? "";
        zhDialect = n.dialect ?? "";
      }
    }
    String origTags = "";
    if (data.tags != null) {
      origTags = data.tags!.whereType<String>().join(",");
    }
    if (model.nidInput.text != (data.nid ?? "")) return true;
    if (model.scope?.value != data.scope) return true;
    if (model.zhNameInput.text != zhName) return true;
    if ((model.zhDialectInput?.text ?? "") != zhDialect) return true;
    if (model.enNameInput.text != enName) return true;
    if ((model.enDialectInput?.text ?? "") != enDialect) return true;
    if (model.gender?.value != data.gender) return true;
    if (model.speciesInput.text != (data.species ?? "")) return true;
    if (model.scopeRefIdInput.text != (data.scopeRefId?.toString()??"")) return true;
    if (model.personalityInput.text != data.personality) return true;
    if (model.appearanceInput.text != data.appearance) return true;
    if (model.tagsInput.text != origTags) return true;
    // 比较变体
    List<MangePersonaEntityVariants?>? origVariants = data.variants;
    int origLen = origVariants?.length ?? 0;
    if (model.variants.length != origLen) return true;
    for (int i = 0; i < model.variants.length; i++) {
      if (_hasVariantChanges(model.variants[i])) return true;
    }
    return false;
  }

  /// 判断变体是否有未保存的改变
  bool _hasVariantChanges(ManagePersonaVariantModel variant) {
    final data = variant.data;
    if (data == null) return false;
    String enDesc = data.description?.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhDesc = data.description?.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";
    if (variant.nidInput.text != (data.nid ?? "")) return true;
    if (variant.variantNameInput.text != (data.name ?? "")) return true;
    if (variant.ageGroup?.value != data.ageGroup) return true;
    if (variant.speedOffsetInput.text != (data.speedOffset?.toString()??"")) return true;
    if (variant.enDescInput.text != enDesc) return true;
    if (variant.zhDescInput.text != zhDesc) return true;
    return false;
  }

  /// 重置模型到原始数据
  void _resetToOriginal(ManagePersonaModel model) {
    final data = model.data;
    if (data == null) return;
    List<MangePersonaEntityName?> nameList = data.name ?? [];
    String enName = "";
    String zhName = "";
    String enDialect = "";
    String zhDialect = "";
    for (var n in nameList) {
      if (n == null) continue;
      if (n.lang == "en") {
        enName = n.text ?? "";
        enDialect = n.dialect ?? "";
      } else if (n.lang == "zh") {
        zhName = n.text ?? "";
        zhDialect = n.dialect ?? "";
      }
    }
    String origTags = "";
    if (data.tags != null) {
      origTags = data.tags!.whereType<String>().join(",");
    }
    model.nidInput.text = data.nid ?? "";
    model.scope = ManageZhenduPersonaScopeEnum.fromValue(data.scope);
    model.zhNameInput.text = zhName;
    model.zhDialectInput?.text = zhDialect;
    model.enNameInput.text = enName;
    model.enDialectInput?.text = enDialect;
    model.gender = ManageZhenduGenderEnum.fromValue(data.gender);
    model.speciesInput.text = data.species ?? "";
    model.scopeRefIdInput.text = data.scopeRefId?.toString()??"";
    model.personalityInput.text = data.personality ?? "";
    model.appearanceInput.text = data.appearance ?? "";
    model.tagsInput.text = origTags;
    // 重置变体列表
    model.variants.clear();
    if (data.variants != null) {
      for (var v in data.variants!) {
        if (v == null) continue;
        model.variants.add(setVariantModel(v));
      }
    }
    listData.refresh();
  }

  /// 选择角色
  Future<void> selectLeftPersona(BuildContext context, int index) async {
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
        await editPersona(context);
      } else {
        _resetToOriginal(currentModel);
      }
    }
    currentIndex.value = index;
  }

  /// 新增角色
  Future<void> addPersona() async{
    searchInput.clear();

    ManagePersonaModel addModel = ManagePersonaModel(
      nidInput: TextEditingController(text: "persona-${listData.length + 1}-${DateTime.now().millisecondsSinceEpoch}"),
      scope: ManageZhenduPersonaScopeEnum.global,
      zhNameInput: TextEditingController(text: "新角色"),
      zhDialectInput: TextEditingController(text: ManageZhenduDialectEnum.zhCN.value),
      enNameInput: TextEditingController(text: "New Persona"),
      enDialectInput: TextEditingController(text: ManageZhenduDialectEnum.enUS.value),
      gender: ManageZhenduGenderEnum.unknown,
      speciesInput: TextEditingController(),
      scopeRefIdInput: TextEditingController(),
      personalityInput: TextEditingController(),
      appearanceInput: TextEditingController(),
      tagsInput: TextEditingController(),
      variants: [],
    );

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = _buildPersonaReqData(addModel);
      reqData["enabled"] = false;
      MangePersonaEntity? res = await LanguageConsoleDramaRequest.addPersona(data: reqData);
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

  /// 删除角色
  Future<void> deletePersona(BuildContext context) async{
    if(listData[currentIndex.value].data?.uid == null) return;
    bool askRes = await DeleteDialog.show(
      context: context, 
      title: "删除",
      content: "您确定要删除此角色吗？",
    );
    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      bool res = await LanguageConsoleDramaRequest.deletePersona(listData[currentIndex.value].data!.uid!);
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

  /// 启用/停用角色
  Future<void> editEnabled(BuildContext context) async{
    if(listData[currentIndex.value].data?.uid == null) return;
    bool enabled = listData[currentIndex.value].data?.enabled ?? false;

    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: enabled ? "停用" : "启用",
      content: "您确定要${enabled ? "停用" : "启用"}此角色吗？",
    );
    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "enabled": !enabled,
      };
      MangePersonaEntity? res = await LanguageConsoleDramaRequest.editPersona(listData[currentIndex.value].data!.uid!, data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: enabled ? "停用成功" : "启用成功", type: ToastType.success);
      listData[currentIndex.value].data!.enabled = !enabled;
      listData.refresh();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 保存角色编辑
  Future<void> editPersona(BuildContext context) async{
    if(listData[currentIndex.value].data?.uid == null) return;
    ManagePersonaModel editModel = listData[currentIndex.value];

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = _buildPersonaReqData(editModel);
      MangePersonaEntity? res = await LanguageConsoleDramaRequest.editPersona(editModel.data!.uid!, data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      editModel.data = res;
      listData.refresh();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 构建角色请求数据
  Map<String, dynamic> _buildPersonaReqData(ManagePersonaModel model){
    List<String> tags = [];
    if(model.tagsInput.text.isNotEmpty){
      tags = model.tagsInput.text.split(",").map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return {
      "nid": model.nidInput.text,
      "name": [
        {
          "lang": "zh",
          "text": model.zhNameInput.text,
          "dialect": model.zhDialectInput?.text ?? "",
        },
        {
          "lang": "en",
          "text": model.enNameInput.text,
          "dialect": model.enDialectInput?.text ?? "",
        },
      ],
      "scope": model.scope?.value,
      "scopeRefId": model.scopeRefIdInput.text,
      "gender": model.gender?.value,
      "species": model.speciesInput.text,
      "personality": model.personalityInput.text,
      "appearance": model.appearanceInput.text,
      "tags": tags,
    };
  }

  /// 新增变体
  Future<void> addVariant(BuildContext context, ManagePersonaModel data) async{
    if(data.data?.uid == null) return;

    ManageAdjustToneBindingResult? selectRes = await ManageAdjustToneBindingDialog.show(
      context: context,
    );
    if(selectRes == null) return;

    ManagePersonaVariantModel addModel = ManagePersonaVariantModel(
      nidInput: TextEditingController(text: "${data.nidInput.text}-variant-${data.variants.length + 1}"),
      variantNameInput: TextEditingController(text: "${data.zhNameInput.text}（新变体）"),
      ageGroup: ManageZhenduAgeGroupEnum.youngAdult,
      speedOffsetInput: TextEditingController(),
      zhDescInput: TextEditingController(),
      enDescInput: TextEditingController(),
    );

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = _buildVariantReqData(data, addModel);
      reqData["is_default"] = false;
      reqData["enabled"] = false;
      reqData["timbreNid"] = selectRes.timbreNid;
      MangePersonaEntityVariants? res = await LanguageConsoleDramaRequest.addPersonaVariant(data: reqData);
      if(res == null) return;
      data.data?.variants ??= [];
      data.data?.variants?.add(res);
      data.variants.add(setVariantModel(res));
      listData.refresh();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 删除变体
  Future<void> deleteVariant(BuildContext context, ManagePersonaModel data, int index) async{
    if(data.variants[index].data?.uid == null) return;
    bool askRes = await DeleteDialog.show(
      context: context, 
      title: "删除",
      content: "您确定要删除此变体吗？",
      showCountdown: false,
    );
    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      bool res = await LanguageConsoleDramaRequest.deletePersonaVariant(data.variants[index].data!.uid!);
      if(!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      data.data?.variants?.removeAt(index);
      data.variants.removeAt(index);
      listData.refresh();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 保存变体编辑
  Future<void> editVariant(BuildContext context, ManagePersonaModel data, int index) async{
    ManagePersonaVariantModel variant = data.variants[index];
    if(variant.data?.uid == null) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = _buildVariantReqData(data, variant);
      MangePersonaEntityVariants? res = await LanguageConsoleDramaRequest.editPersonaVariant(variant.data!.uid!, data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: "变体保存成功", type: ToastType.success);
      variant.data = res;
      listData.refresh();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 构建变体请求数据
  Map<String, dynamic> _buildVariantReqData(ManagePersonaModel persona, ManagePersonaVariantModel model){
    return {
      "nid": model.nidInput.text,
      "personaNid": persona.nidInput.text,
      "name": model.variantNameInput.text,
      "description": [
        {
          "lang": "zh",
          "text": model.zhDescInput.text,
        },
        {
          "lang": "en",
          "text": model.enDescInput.text,
        },
      ],
      "age_group": model.ageGroup?.value,
      "speed_offset": model.speedOffsetInput.text,
    };
  }

  /// 变体设为默认
  Future<void> variantSetDefault(ManagePersonaModel persona, ManagePersonaVariantModel variant) async{
    bool isDefault = variant.data?.isDefault == true;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "is_default": !isDefault,
      };
      MangePersonaEntityVariants? res = await LanguageConsoleDramaRequest.editPersonaVariant(variant.data!.uid!, data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      variant.data = res;
      listData.refresh();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 变体设置启用
  Future<void> variantEditEnabled(BuildContext context, ManagePersonaModel persona, ManagePersonaVariantModel variant) async{
    if(variant.data?.uid == null) return;
    bool enabled = variant.data?.enabled ?? false;

    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: enabled ? "停用" : "启用",
      content: "您确定要${enabled ? "停用" : "启用"}此变体吗？",
    );
    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "enabled": !enabled,
      };
      MangePersonaEntityVariants? res = await LanguageConsoleDramaRequest.editPersonaVariant(variant.data!.uid!, data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: enabled ? "停用成功" : "启用成功", type: ToastType.success);
      variant.data = res;
      listData.refresh();
    } finally{
      ToastUtils.hideLoading();
    }
  }
  

  /// 审核设定图
  Future<void> reviewSettingDiagramImage(ManagePersonaModel persona, ManagePersonaVariantModel variant) async{
    if(variant.data?.imageTaskIds?.isEmpty??true) return ToastUtils.showToast(text: "暂无待审核");
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_CHECK_IMAGE,
      arguments: {
        "taskIds": variant.data?.imageTaskIds,
      },
    );
    MangePersonaEntity? res = await getListSingleDataForNid(persona.data?.nid);
    if(res == null) return;
    persona = setModel(res);
    listData.refresh();
  }

  /// 新增设定图
  Future<void> addSettingDiagram(BuildContext context, ManagePersonaVariantModel variant) async{
    if(variant.data?.uid == null) return;
    ManageAddSettingDiagramDialog.show(
      context: context,
      variantId: variant.data!.uid!,
    );
  }

  /// 调整音色绑定
  Future<void> adjustToneBinding(BuildContext context, ManagePersonaModel persona, ManagePersonaVariantModel variant) async{
    ManageAdjustToneBindingResult? selectRes = await ManageAdjustToneBindingDialog.show(
      context: context,
    );
    if(selectRes == null) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "nid": persona.data?.nid,
        "timbreNid": selectRes.timbreNid,
      };
      MangePersonaEntityVariants? res = await LanguageConsoleDramaRequest.editPersonaVariant(variant.data!.uid!, data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      variant.data = res;
      listData.refresh();
    } finally{
      ToastUtils.hideLoading();
    }

  }

  @override
  void onClose() {
    super.onClose();
  }
}
