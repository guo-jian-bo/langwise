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

  final ScrollController leftScrollController = ScrollController();

  /// 搜索输入框
  final TextEditingController searchInput = TextEditingController();

  /// 列表数据
  final RxList<ManageScriptThemeModel> listData = <ManageScriptThemeModel>[].obs;

  /// 当前选中的下标
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    refreshListData();
  }

  /// 刷新列表数据
  Future<void> refreshListData() async{
    currentIndex.value = 0;
    listData.clear();
    await getListData();
  }

  /// 获取列表数据
  Future<void> getListData() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "order": "-created",
      };
      Map<String, dynamic> reqData = {};
      if(searchInput.text.isNotEmpty){
        reqData["keyword"] = searchInput.text;
      }
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
        await editTheme(context);
      } else {
        _resetToOriginal(currentModel);
      }
    }
    currentIndex.value = index;
  }

  /// 新增主题
  Future<void> addTheme() async{
    searchInput.clear();

    ManageScriptThemeModel addModel = ManageScriptThemeModel(
      nidInput: TextEditingController(text: "new-theme-${listData.length + 1}-${DateTime.now().millisecondsSinceEpoch}"),
      categoryInput: TextEditingController(text: "daily_life"),
      zhNameInput: TextEditingController(),
      enNameInput: TextEditingController(),
      zhDescInput: TextEditingController(),
      enDescInput: TextEditingController(),
      difficultyMinInput: TextEditingController(),
      difficultyMaxInput: TextEditingController(),
      suggestedPersonasInput: TextEditingController(text: "lw-wise"),
    );

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = _buildReqData(addModel);
      reqData["enabled"] = false;
      ManageScriptThemeEntity? res = await LanguageConsoleDramaRequest.addScriptTheme(data: reqData);
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

  /// 删除主题
  Future<void> deleteTheme(BuildContext context) async{
    if(listData[currentIndex.value].data?.nid == null) return;
    bool askRes = await DeleteDialog.show(
      context: context, 
      title: "删除",
      content: "您确定要删除此主题数据吗？",
    );
    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      bool res = await LanguageConsoleDramaRequest.deleteScriptTheme(
        parameters: {"nid": listData[currentIndex.value].data!.nid!},
      );
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
    if(listData[currentIndex.value].data?.nid == null) return;
    bool enabled = listData[currentIndex.value].data?.enabled ?? false;

    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: enabled ? "停用" : "启用",
      content: "您确定要${enabled ? "停用" : "启用"}此主题吗？",
    );
    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "nid": listData[currentIndex.value].data!.nid!,
        "enabled": !enabled,
      };
      ManageScriptThemeEntity? res = await LanguageConsoleDramaRequest.editScriptTheme(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: enabled ? "停用成功" : "启用成功", type: ToastType.success);
      listData[currentIndex.value].data!.enabled = !enabled;
      listData.refresh();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 保存编辑
  Future<void> editTheme(BuildContext context) async{
    if(listData[currentIndex.value].data?.nid == null) return;
    ManageScriptThemeModel editModel = listData[currentIndex.value];

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = _buildReqData(editModel);
      ManageScriptThemeEntity? res = await LanguageConsoleDramaRequest.editScriptTheme(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      editModel.data = res;
      listData.refresh();
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

  @override
  void onClose() {
    super.onClose();
  }
}
