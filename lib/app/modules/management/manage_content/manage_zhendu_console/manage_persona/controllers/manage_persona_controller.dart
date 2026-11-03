import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/utils/utils.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../dialog/dialogs.dart';
import '../../enums/manage_zhendu_enums.dart';
import '../models/manage_persona_model.dart';
import '../views/manage_add_setting_diagram_dialog.dart';
import '../../common/manage_select_timbre_dialog.dart';

class ManagePersonaController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManagePersonaController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_PERSONA;

  @override
  String get breadcrumbTitle => '角色管理';

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
    "variant_count": FilterSortsData(
      title: "变体数",
      sorts: [
        FilterSortsItem(name: "从少到多", direction: FilterSortDirection.up),
        FilterSortsItem(name: "从多到少", direction: FilterSortDirection.down),
      ],
    ),
  }.obs;

  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{
    "enabled": FilterConditionsData(
      title: "启用状态",
      conditions: [
        FilterConditionsItem(name: "启用", value: true),
        FilterConditionsItem(name: "停用", value: false),
      ],
    ),
    "gender": FilterConditionsData(
      title: "性别",
      conditions: ManageZhenduGenderEnum.values.map((e) => FilterConditionsItem(
        name: e.value,
        value: e.value,
      )).toList(),
    ),
    "scope": FilterConditionsData(
      title: "作用域",
      conditions: ManageZhenduPersonaScopeEnum.values.map((e) => FilterConditionsItem(
        name: e.value,
        value: e.value,
      )).toList(),
    ),
    "locale": FilterConditionsData(
      title: "地区",
      conditions: ManageZhenduLocaleEnum.values.map((e) => FilterConditionsItem(
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
  /// 数据列表
  final RxList<ManagePersonaModel> listData = <ManagePersonaModel>[].obs;

  /// 当前选中的下标
  final RxInt currentIndex = 0.obs;
  final RxBool isEditing = false.obs;


  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    if(Get.arguments != null){
      String? nid = Get.arguments['nid'];
      if(nid != null){
        filterSearchs['nid']?.controller.text = nid;
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
        "order": "uid",
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
        variants.add(setVariantModel(v, personaNid: item.nid));
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
      locale: ManageZhenduLocaleEnum.fromValue(item.locale),
      scopeRefIdInput: TextEditingController(text: item.scopeRefId?.toString()??""),
      personalityInput: TextEditingController(text: item.personality),
      appearanceInput: TextEditingController(text: item.appearance),
      tagsInput: TextEditingController(text: tagsStr),
      variants: variants,
    );
  }

  /// set变体模型数据
  ManagePersonaVariantModel setVariantModel(MangePersonaEntityVariants v, {String? personaNid}){
    String enDescription = v.description?.firstWhereOrNull((element) => element?.lang == "en")?.text??"";
    String zhDescription = v.description?.firstWhereOrNull((element) => element?.lang == "zh")?.text??"";
    String nidSuffix = _normalizeVariantNidSuffix(
      personaNid: personaNid,
      inputNid: v.nid ?? "",
    );

    return ManagePersonaVariantModel(
      data: v,
      nidInput: TextEditingController(text: nidSuffix),
      variantNameInput: TextEditingController(text: v.name),
      ageGroup: ManageZhenduAgeGroupEnum.fromValue(v.ageGroup),
      speedOffsetInput: TextEditingController(text: v.speedOffset?.toString()??""),
      enDescInput: TextEditingController(text: enDescription),
      zhDescInput: TextEditingController(text: zhDescription),
    );
  }

  /// 判断当前选中项是否有未保存的改变
  bool _hasChanges(ManagePersonaModel model) {
    if (_hasPersonaFieldChanges(model)) return true;
    // 比较变体
    final data = model.data;
    if (data == null) return false;
    List<MangePersonaEntityVariants?>? origVariants = data.variants;
    int origLen = origVariants?.length ?? 0;
    if (model.variants.length != origLen) return true;
    for (int i = 0; i < model.variants.length; i++) {
      if (_hasVariantChanges(model.variants[i], personaNid: model.nidInput.text)) return true;
    }
    return false;
  }

  bool _hasPersonaFieldChanges(ManagePersonaModel model) {
    if (model.data?.uid == null) return true;
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
    if ((model.scope?.value??"") != (data.scope??"")) return true;
    if (model.zhNameInput.text != zhName) return true;
    if ((model.zhDialectInput?.text ?? "") != zhDialect) return true;
    if (model.enNameInput.text != enName) return true;
    if ((model.enDialectInput?.text ?? "") != enDialect) return true;
    if ((model.gender?.value??"") != (data.gender??"")) return true;
    if (model.speciesInput.text != (data.species ?? "")) return true;
    if ((model.locale?.value??"") != (data.locale??"")) return true;
    if (model.scopeRefIdInput.text != (data.scopeRefId?.toString()??"")) return true;
    if (model.personalityInput.text != (data.personality??"")) return true;
    if (model.appearanceInput.text != (data.appearance??"")) return true;
    if (model.tagsInput.text != origTags) return true;
    return false;
  }

  /// 判断变体是否有未保存的改变
  bool _hasVariantChanges(ManagePersonaVariantModel variant, {String? personaNid}) {
    final data = variant.data;
    if (data == null) return true;
    String enDesc = data.description?.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhDesc = data.description?.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";
    String currentNid = _normalizeVariantNidSuffix(
      personaNid: personaNid,
      inputNid: data.nid ?? "",
    );
    if (variant.nidInput.text != currentNid) return true;
    if (variant.variantNameInput.text != (data.name ?? "")) return true;
    if ((variant.ageGroup?.value??"") != (data.ageGroup??"")) return true;
    String origSpeedOffset = data.speedOffset?.toString()??"";
    if (variant.speedOffsetInput.text != origSpeedOffset) return true;
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
    model.locale = ManageZhenduLocaleEnum.fromValue(data.locale);
    model.scopeRefIdInput.text = data.scopeRefId?.toString()??"";
    model.personalityInput.text = data.personality ?? "";
    model.appearanceInput.text = data.appearance ?? "";
    model.tagsInput.text = origTags;
    // 重置变体列表
    model.variants.clear();
    if (data.variants != null) {
      for (var v in data.variants!) {
        if (v == null) continue;
        model.variants.add(setVariantModel(v, personaNid: data.nid));
      }
    }
    listData.refresh();
  }

  /// 选择角色
  Future<void> selectLeftPersona(BuildContext context, int index) async {
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
        bool saveRes = await _saveCurrentPersonaAndVariants(context);
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

  /// 新增角色
  Future<void> addPersona(BuildContext context) async{
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
          bool saveRes = await _saveCurrentPersonaAndVariants(context);
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

    ManagePersonaModel addModel = ManagePersonaModel(
      nidInput: TextEditingController(text: "persona-${listData.length + 1}-${DateTime.now().millisecondsSinceEpoch}"),
      scope: ManageZhenduPersonaScopeEnum.global,
      zhNameInput: TextEditingController(text: "新角色"),
      zhDialectInput: TextEditingController(text: ManageZhenduDialectEnum.zhCN.value),
      enNameInput: TextEditingController(text: "New Persona"),
      enDialectInput: TextEditingController(text: ManageZhenduDialectEnum.enUS.value),
      gender: ManageZhenduGenderEnum.unknown,
      speciesInput: TextEditingController(),
      // locale: ManageZhenduLocaleEnum.UNIVERSAL,
      scopeRefIdInput: TextEditingController(),
      personalityInput: TextEditingController(),
      appearanceInput: TextEditingController(),
      tagsInput: TextEditingController(),
      variants: [],
    );

    listData.insert(0, addModel);
    currentIndex.value = 0;
    isEditing.value = true;
    listData.refresh();
    if(!leftScrollController.hasClients) return;
    leftScrollController.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.linear);
  }

  /// 删除角色
  Future<void> deletePersona(BuildContext context) async{
    if(listData.isEmpty) return;
    ManagePersonaModel currentModel = listData[currentIndex.value];
    bool askRes = await DeleteDialog.show(
      context: context, 
      title: "删除",
      content: "您确定要删除此角色吗？",
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
      bool res = await LanguageConsoleDramaRequest.deletePersona(currentModel.data!.uid!);
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

  /// 保存角色（新增/编辑）
  Future<bool> editPersona(
    BuildContext context, {
    bool refreshAfterSave = true,
    bool showToast = true,
  }) async{
    if(listData.isEmpty) return false;
    ManagePersonaModel editModel = listData[currentIndex.value];
    bool isCreate = editModel.data?.uid == null;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = _buildPersonaReqData(editModel);
      MangePersonaEntity? res;
      if (isCreate) {
        reqData["enabled"] = false;
        res = await LanguageConsoleDramaRequest.addPersona(data: reqData);
      } else {
        res = await LanguageConsoleDramaRequest.editPersona(editModel.data!.uid!, data: reqData);
      }
      if(res == null) return false;
      if(showToast){
        ToastUtils.showToast(text: isCreate ? "新增成功" : "保存成功", type: ToastType.success);
      }
      if(!refreshAfterSave){
        editModel.data = res;
        listData.refresh();
        return true;
      }
      MangePersonaEntity? getRes = await getListSingleDataForNid(editModel.nidInput.text);
      if(getRes == null) return false;
      listData[currentIndex.value] = setModel(getRes);
      listData.refresh();
      isEditing.value = false;
      return true;
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
      "locale": model.locale?.value,
      "personality": model.personalityInput.text,
      "appearance": model.appearanceInput.text,
      "tags": tags,
    };
  }

  /// 新增变体
  Future<void> addVariant(BuildContext context, ManagePersonaModel data) async{
    if(!isEditing.value) return;
    if(data.data?.uid == null) return;
    
    String nid = "";
    if(data.variants.isEmpty){
      nid += "-default";
    }else{
      nid += "-variant-${data.variants.length + 1}";
    }

    ManagePersonaVariantModel addModel = ManagePersonaVariantModel(
      nidInput: TextEditingController(text: nid),
      variantNameInput: TextEditingController(text: "${data.zhNameInput.text}（新变体）"),
      ageGroup: ManageZhenduAgeGroupEnum.youngAdult,
      speedOffsetInput: TextEditingController(),
      zhDescInput: TextEditingController(),
      enDescInput: TextEditingController(),
    );

    data.variants.add(addModel);
    listData.refresh();
  }

  /// 删除变体
  Future<void> deleteVariant(BuildContext context, ManagePersonaModel data, int index) async{
    if(!isEditing.value) return;
    if(data.variants[index].data?.uid == null){
      data.variants.removeAt(index);
      listData.refresh();
      return;
    }
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
  Future<bool> editVariant(
    BuildContext context,
    ManagePersonaModel data,
    int index, {
    bool refreshAfterSave = true,
    bool showToast = true,
  }) async{
    if(!isEditing.value) return false;
    ManagePersonaVariantModel variant = data.variants[index];
    bool isCreate = variant.data?.uid == null;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = _buildVariantReqData(data, variant, includeNid: isCreate);
      MangePersonaEntityVariants? res;
      if(isCreate){
        reqData["is_default"] = (data.data?.variants?.isEmpty ?? true);
        reqData["enabled"] = false;
        res = await LanguageConsoleDramaRequest.addPersonaVariant(data: reqData);
      }else{
        res = await LanguageConsoleDramaRequest.editPersonaVariant(variant.data!.uid!, data: reqData);
      }
      if(res == null) return false;
      if(showToast){
        ToastUtils.showToast(text: isCreate ? "变体新增成功" : "变体保存成功", type: ToastType.success);
      }
      if(refreshAfterSave){
        await refreshPersonaInList(data);
      }else{
        if(isCreate){
          data.data?.variants ??= [];
          data.data?.variants?.add(res);
        }
        data.variants[index] = setVariantModel(res, personaNid: data.nidInput.text);
      }
      listData.refresh();
      return true;
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 统一保存当前角色及其变体：
  /// 1. 若角色本身有改动，先保存角色（支持新增/编辑）；
  /// 2. 再循环保存所有未保存或已修改的变体（支持新增/编辑）；
  /// 3. 最后统一刷新当前角色，保证本地状态与服务端一致。
  /// 任一步失败都会立即中断并返回 false。
  Future<bool> _saveCurrentPersonaAndVariants(BuildContext context) async{
    if(listData.isEmpty) return false;
    ManagePersonaModel currentModel = listData[currentIndex.value];

    if(_hasPersonaFieldChanges(currentModel)){
      bool personaSaveRes = await editPersona(
        context,
        refreshAfterSave: false,
        showToast: false,
      );
      if(!personaSaveRes) return false;
      currentModel = listData[currentIndex.value];
    }

    while(true){
      int unsavedVariantIndex = currentModel.variants.indexWhere((variant) {
        if(variant.data == null) return true;
        return _hasVariantChanges(variant, personaNid: currentModel.nidInput.text);
      });
      if(unsavedVariantIndex < 0) break;

      bool variantSaveRes = await editVariant(
        context,
        currentModel,
        unsavedVariantIndex,
        refreshAfterSave: false,
        showToast: false,
      );
      if(!variantSaveRes) return false;
      currentModel = listData[currentIndex.value];
    }

    await refreshPersonaInList(currentModel);
    listData.refresh();
    ToastUtils.showToast(text: "保存成功", type: ToastType.success);
    isEditing.value = false;
    return true;
  }

  /// 保存当前角色及其所有变体（新增/编辑）
  Future<bool> saveAllChanges(BuildContext context) async{
    return _saveCurrentPersonaAndVariants(context);
  }

  /// 构建变体请求数据
  Map<String, dynamic> _buildVariantReqData(
    ManagePersonaModel persona,
    ManagePersonaVariantModel model, {
    bool includeNid = false,
  }){
    final Map<String, dynamic> reqData = {
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
    if(includeNid){
      reqData["nid"] = "${persona.nidInput.text}${_normalizeVariantNidSuffix(
        personaNid: persona.nidInput.text,
        inputNid: model.nidInput.text,
        ensureLeadingDash: true,
      )}";
    }
    return reqData;
  }

  String _normalizeVariantNidSuffix({
    String? personaNid,
    required String inputNid,
    bool ensureLeadingDash = false,
  }){
    String suffix = inputNid.trim();
    if(personaNid?.isNotEmpty == true && suffix.startsWith(personaNid!)){
      suffix = suffix.substring(personaNid.length);
    }
    if(ensureLeadingDash && suffix.isNotEmpty && !suffix.startsWith("-")){
      suffix = "-$suffix";
    }
    return suffix;
  }

  /// 拉取最新persona并回写到列表中
  Future<bool> refreshPersonaInList(ManagePersonaModel persona) async{
    final MangePersonaEntity? latestPersona = await getListSingleDataForNid(persona.data?.nid);
    if(latestPersona == null) return false;
    return _replacePersonaModelInList(persona: persona, updatedModel: setModel(latestPersona));
  }

  /// 将更新后的persona模型按uid/nid回写到列表中
  bool _replacePersonaModelInList({
    required ManagePersonaModel persona,
    required ManagePersonaModel updatedModel,
  }){
    final currentUid = persona.data?.uid;
    int replaceIndex = -1;
    if(currentUid != null){
      replaceIndex = listData.indexWhere((item) => item.data?.uid == currentUid);
    }
    if(replaceIndex == -1){
      final currentNid = persona.data?.nid;
      replaceIndex = listData.indexWhere((item) => item.data?.nid == currentNid);
    }
    if(replaceIndex == -1) return false;
    listData[replaceIndex] = updatedModel;
    return true;
  }

  /// 变体设为默认
  Future<void> variantSetDefault(ManagePersonaModel persona, ManagePersonaVariantModel variant) async{
    if(!isEditing.value) return;
    bool isDefault = variant.data?.isDefault == true;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "is_default": !isDefault,
      };
      MangePersonaEntityVariants? res = await LanguageConsoleDramaRequest.editPersonaVariant(variant.data!.uid!, data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      final bool isRefreshSuccess = await refreshPersonaInList(persona);
      if(!isRefreshSuccess){
        variant.data = res;
      }
      listData.refresh();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 变体设置启用
  Future<void> variantEditEnabled(BuildContext context, ManagePersonaModel persona, ManagePersonaVariantModel variant) async{
    if(!isEditing.value) return;
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
    final bool isRefreshSuccess = await refreshPersonaInList(persona);
    if(!isRefreshSuccess) return;
    listData.refresh();
  }

  /// 新增设定图
  Future<void> addSettingDiagram(BuildContext context, ManagePersonaModel persona, ManagePersonaVariantModel variant) async{
    if(variant.data?.uid == null) return;
    // ManageAddSettingDiagramDialog.show(
    //   context: context,
    //   variantId: variant.data!.uid!,
    // );

    ManageZhenduPersonaViewEnum? res = await ManageAddSettingDiagramDialog.showSelectViewType(
      context: context, 
      persona: persona, 
      variant: variant,
    );
    if(res == null) return;
    
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_UNIFIED_IMAGE_CREATE,
      arguments: {
        "uid": variant.data?.uid,
        "type": "PERSONA_VARIANT",
        "viewType": res.value,
        "jumpCode": AppManageRoutesCode.persona,
        "params": {
          "nid": persona.data?.nid,
        },
      },
    );

  }

  /// 设定图放大
  Future<void> zoomSettingDiagram(BuildContext context, ManagePersonaVariantModel variant, MangePersonaEntityVariantsImages? image) async{
    if(image?.imageUrl == null) return;
    bool isLocked = image?.locked == true;
    bool res = await ManageLockBigImageDialog.show(
      context: context, 
      imageUrl: image?.imageUrl,
      relationImageId: image?.relationId,
      locked: isLocked,
    );
    if(!res) return;
    image?.locked = !isLocked;
    listData.refresh();
  }

  /// 调整音色绑定
  Future<void> adjustToneBinding(BuildContext context, ManagePersonaModel persona, ManagePersonaVariantModel variant) async{
    if(!isEditing.value) return;
    ManageSelectTimbreResult? selectRes = await ManageSelectTimbreDialog.show(
      context: context,
      title: "音色绑定",
    );
    if(selectRes == null) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
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

  /// 跳转至音色页面
  Future<void> jumpToTimbrePage(BuildContext context, ManagePersonaModel persona, ManagePersonaVariantModel variant) async{
    if(variant.data?.timbreNid == null) return;
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_VOCAL_TIMBRE,
      arguments: {
        "timbreNid": variant.data?.timbreNid,
      },
    );
    final bool isRefreshSuccess = await refreshPersonaInList(persona);
    if(!isRefreshSuccess) return;
    listData.refresh();
  }

  void startEdit() {
    isEditing.value = true;
  }

  Future<void> cancelEdit(BuildContext context) async {
    if (listData.isEmpty) return;
    final ManagePersonaModel currentModel = listData[currentIndex.value];
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

  @override
  void onClose() {
    super.onClose();
  }
}
