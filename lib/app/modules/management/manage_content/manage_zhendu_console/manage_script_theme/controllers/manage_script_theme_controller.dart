import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';
import '../models/manage_script_theme_model.dart';

class ManageScriptThemeController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageScriptThemeController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SCRIPT_THEME;

  @override
  String get breadcrumbTitle => '剧本主题';

  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{
    "order": FilterSortsData(
      title: "排序",
      sorts: [
        FilterSortsItem(name: "从小到大", direction: FilterSortDirection.up),
        FilterSortsItem(name: "从大到小", direction: FilterSortDirection.down, isDefault: true, selected: true),
      ],
    ),
    "name": FilterSortsData(
      title: "中文名",
      sorts: [
        FilterSortsItem(name: "从A到Z", direction: FilterSortDirection.up),
        FilterSortsItem(name: "从Z到A", direction: FilterSortDirection.down),
      ],
    ),
    "category": FilterSortsData(
      title: "分类",
      sorts: [
        FilterSortsItem(name: "从A到Z", direction: FilterSortDirection.up),
        FilterSortsItem(name: "从Z到A", direction: FilterSortDirection.down),
      ],
    ),
  }.obs;

  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{}.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
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
    "category": FilterSearchsData(
      title: "分类",
      hintText: "分类",
      controller: TextEditingController(),
    ),
    "name": FilterSearchsData(
      title: "name",
      hintText: "name",
      controller: TextEditingController(),
    ), 
  };

  final ScrollController leftScrollController = ScrollController();

  /// 列表数据
  final RxList<ManageScriptThemeModel> listData = <ManageScriptThemeModel>[].obs;

  /// 当前选中的下标
  final RxInt currentIndex = 0.obs;
  final RxBool isEditing = false.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    refreshListData();
  }

  /// 刷新列表数据
  Future<void> refreshListData({bool isReset = true}) async{
    isEditing.value = false;
    if(isReset) currentIndex.value = 0;
    listData.clear();
    await getListData();
  }

  /// 获取列表数据
  Future<void> getListData() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {};
      Map<String, dynamic> sortOrder = FilterStripUtils.getSortOrderParameter(sorts: filterSorts);
      parameters.addAll(sortOrder);

      Map<String, dynamic> reqData = {};
      Map<String, dynamic> conditionParameter = FilterStripUtils.getConditionParameter(conditions: filterConditions);
      reqData.addAll(conditionParameter);

      Map<String, dynamic> searchParameter = FilterStripUtils.getSearchParameter(searchs: filterSearchs);
      reqData.addAll(searchParameter);
      List<ManageScriptThemeEntity>? res = await LanguageConsoleDramaRequest.getScriptThemeList(parameters: parameters, data: reqData);
      if(res == null) return;
      List<ManageScriptThemeEntity> list = res;
      for(ManageScriptThemeEntity item in list){
        listData.add(setModel(item));
      }
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// set模型数据到本地model
  ManageScriptThemeModel setModel(ManageScriptThemeEntity item){
    List<LanguageText?> nameList = item.name ?? [];
    String enName = nameList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhName = nameList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";
    List<LanguageText?> descList = item.description ?? [];
    String enDesc = descList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhDesc = descList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";

    String suggestedPersonasStr = "";
    if(item.suggestedPersonas != null){
      suggestedPersonasStr = item.suggestedPersonas!.whereType<String>().join(",");
    }

    return ManageScriptThemeModel(
      data: item,
      nidInput: TextEditingController(text: item.nid),
      categoryInput: TextEditingController(text: item.category),
      zhNameInput: TextEditingController(text: zhName),
      enNameInput: TextEditingController(text: enName),
      zhDescInput: TextEditingController(text: zhDesc),
      enDescInput: TextEditingController(text: enDesc),
      difficultyMinInput: TextEditingController(text: item.difficulty?.min?.toString()??""),
      difficultyMaxInput: TextEditingController(text: item.difficulty?.max?.toString()??""),
      suggestedPersonasInput: TextEditingController(text: suggestedPersonasStr),
    );
  }

  /// 判断当前选中项是否有未保存的改变
  bool _hasChanges(ManageScriptThemeModel model) {
    if (model.data?.nid == null) return true;
    final data = model.data;
    if (data == null) return false;
    List<LanguageText?> nameList = data.name ?? [];
    String enName = nameList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhName = nameList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";
    List<LanguageText?> descList = data.description ?? [];
    String enDesc = descList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhDesc = descList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";
    String suggestedPersonasStr = "";
    if (data.suggestedPersonas != null) {
      suggestedPersonasStr = data.suggestedPersonas!.whereType<String>().join(",");
    }
    if (model.nidInput.text != (data.nid ?? "")) return true;
    if (model.categoryInput.text != (data.category ?? "")) return true;
    if (model.enNameInput.text != enName) return true;
    if (model.zhNameInput.text != zhName) return true;
    if (model.enDescInput.text != enDesc) return true;
    if (model.zhDescInput.text != zhDesc) return true;
    if (model.difficultyMinInput.text != (data.difficulty?.min ?? "").toString()) return true;
    if (model.difficultyMaxInput.text != (data.difficulty?.max ?? "").toString()) return true;
    if (model.suggestedPersonasInput.text != suggestedPersonasStr) return true;
    return false;
  }

  /// 重置模型到原始数据
  void _resetToOriginal(ManageScriptThemeModel model) {
    final data = model.data;
    if (data == null) return;
    List<LanguageText?> nameList = data.name ?? [];
    String enName = nameList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhName = nameList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";
    List<LanguageText?> descList = data.description ?? [];
    String enDesc = descList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhDesc = descList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";
    String suggestedPersonasStr = "";
    if (data.suggestedPersonas != null) {
      suggestedPersonasStr = data.suggestedPersonas!.whereType<String>().join(",");
    }
    model.nidInput.text = data.nid ?? "";
    model.categoryInput.text = data.category ?? "";
    model.enNameInput.text = enName;
    model.zhNameInput.text = zhName;
    model.enDescInput.text = enDesc;
    model.zhDescInput.text = zhDesc;
    model.difficultyMinInput.text = data.difficulty?.min?.toString()??"";
    model.difficultyMaxInput.text = data.difficulty?.max?.toString()??"";
    model.suggestedPersonasInput.text = suggestedPersonasStr;
    listData.refresh();
  }

  /// 选择主题
  Future<void> selectLeftTheme(BuildContext context, int index) async {
    if (index == currentIndex.value) return;
    int targetIndex = index;
    final currentModel = listData[currentIndex.value];
    if (_hasChanges(currentModel)) {
      bool isUnsavedNew = currentModel.data?.nid == null;
      bool? askRes = await AskDialog.showUserCancelAsk(
        context: context,
        title: "提示",
        content: isUnsavedNew ? "新增的数据未保存，是否保存？" : "当前数据已修改，是否保存？",
        cancel: isUnsavedNew ? "取消" : "不保存",
        define: "保存",
      );
      if (askRes == null) return;
      if (askRes) {
        bool saveRes = await editTheme(context);
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

  /// 新增主题
  Future<void> addTheme(BuildContext context) async{
    if (listData.isNotEmpty) {
      final currentModel = listData[currentIndex.value];
      if (_hasChanges(currentModel)) {
        bool isUnsavedNew = currentModel.data?.nid == null;
        bool? askRes = await AskDialog.showUserCancelAsk(
          context: context,
          title: "提示",
          content: isUnsavedNew ? "新增的数据未保存，是否保存？" : "当前数据已修改，是否保存？",
          cancel: isUnsavedNew ? "取消" : "不保存",
          define: "保存",
        );
        if (askRes == null) return;
        if (askRes) {
          bool saveRes = await editTheme(context);
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

    ManageScriptThemeModel addModel = ManageScriptThemeModel(
      nidInput: TextEditingController(),
      categoryInput: TextEditingController(text: "daily_life"),
      zhNameInput: TextEditingController(),
      enNameInput: TextEditingController(),
      zhDescInput: TextEditingController(),
      enDescInput: TextEditingController(),
      difficultyMinInput: TextEditingController(),
      difficultyMaxInput: TextEditingController(),
      suggestedPersonasInput: TextEditingController(text: "lw-wise"),
    );

    listData.insert(0, addModel);
    currentIndex.value = 0;
    isEditing.value = true;
    listData.refresh();
    if(!leftScrollController.hasClients) return;
    leftScrollController.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.linear);
  }

  /// 删除主题
  Future<void> deleteTheme(BuildContext context) async{
    if(listData.isEmpty) return;
    ManageScriptThemeModel currentModel = listData[currentIndex.value];
    bool askRes = await DeleteDialog.show(
      context: context, 
      title: "删除",
      content: "您确定要删除此主题数据吗？",
      showCountdown: currentModel.data?.nid != null,
    );
    if(!askRes) return;

    if(currentModel.data?.nid == null){
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
      bool res = await LanguageConsoleDramaRequest.deleteScriptTheme(
        parameters: {"nid": currentModel.data!.nid!},
      );
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

  /// 保存（新增/编辑）
  Future<bool> editTheme(BuildContext context) async{
    if(listData.isEmpty) return false;
    ManageScriptThemeModel editModel = listData[currentIndex.value];
    bool isCreate = editModel.data?.nid == null;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = _buildReqData(editModel);
      ManageScriptThemeEntity? res;
      if (isCreate) {
        reqData["enabled"] = false;
        res = await LanguageConsoleDramaRequest.addScriptTheme(data: reqData);
      } else {
        res = await LanguageConsoleDramaRequest.editScriptTheme(data: reqData);
      }
      if(res == null) return false;
      ToastUtils.showToast(text: isCreate ? "新增成功" : "保存成功", type: ToastType.success);
      listData[currentIndex.value] = setModel(res);
      isEditing.value = false;
      listData.refresh();
      return true;
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 构建请求数据
  Map<String, dynamic> _buildReqData(ManageScriptThemeModel model){
    List<String> suggestedPersonas = [];
    if(model.suggestedPersonasInput.text.isNotEmpty){
      suggestedPersonas = model.suggestedPersonasInput.text.split(",").map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return {
      "nid": model.nidInput.text,
      "category": model.categoryInput.text,
      "name": [
        {
          "lang": "zh",
          "text": model.zhNameInput.text,
        },
        {
          "lang": "en",
          "text": model.enNameInput.text,
        },
      ],
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
      "difficulty": {
        "min": model.difficultyMinInput.text,
        "max": model.difficultyMaxInput.text,
      },
      "suggested_personas": suggestedPersonas,
    };
  }

  void startEdit() {
    isEditing.value = true;
  }

  Future<void> cancelEdit(BuildContext context) async {
    if (listData.isEmpty) return;
    final ManageScriptThemeModel currentModel = listData[currentIndex.value];
    if (_hasChanges(currentModel)) {
      bool? askRes = await AskDialog.showUserCancelAsk(
        context: context,
        title: "提示",
        content: "当前数据已修改，取消编辑将丢失未保存内容，是否继续？",
        cancel: "继续编辑",
        define: "取消编辑",
      );
      if (askRes != true) return;
      if (currentModel.data?.nid == null) {
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
