import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';
import '../models/manage_script_genre_model.dart';

class ManageScriptGenreController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageScriptGenreController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SCRIPT_GENRE;

  @override
  String get breadcrumbTitle => '剧本题材';

  final ScrollController leftScrollController = ScrollController();

  /// 搜索输入框
  final TextEditingController searchInput = TextEditingController();

  /// 列表数据
  final RxList<ManageScriptGenreModel> listData = <ManageScriptGenreModel>[].obs;

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
      List<ManageScriptGenreEntity>? res = await LanguageConsoleDramaRequest.getScriptGenreList(parameters: parameters, data: reqData);
      if(res == null) return;
      for(ManageScriptGenreEntity item in res){
        listData.add(setModel(item));
      }
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// set模型数据到本地model
  ManageScriptGenreModel setModel(ManageScriptGenreEntity item){
    List<LanguageText?> nameList = item.name ?? [];
    String enName = nameList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhName = nameList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";
    List<LanguageText?> descList = item.description ?? [];
    String enDesc = descList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhDesc = descList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";

    return ManageScriptGenreModel(
      data: item,
      nidInput: TextEditingController(text: item.nid),
      zhNameInput: TextEditingController(text: zhName),
      enNameInput: TextEditingController(text: enName),
      zhDescInput: TextEditingController(text: zhDesc),
      enDescInput: TextEditingController(text: enDesc),
      difficultyMinInput: TextEditingController(text: item.difficulty?.min?.toString()??""),
      difficultyMaxInput: TextEditingController(text: item.difficulty?.max?.toString()??""),
      descriptionForPromptInput: TextEditingController(text: item.descriptionForPrompt),
      audioCharacteristicsInput: TextEditingController(text: item.audioCharacteristics),
    );
  }

  /// 判断当前选中项是否有未保存的改变
  bool _hasChanges(ManageScriptGenreModel model) {
    final data = model.data;
    if (data == null) return false;
    List<LanguageText?> nameList = data.name ?? [];
    String enName = nameList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhName = nameList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";
    List<LanguageText?> descList = data.description ?? [];
    String enDesc = descList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhDesc = descList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";
    if (model.nidInput.text != (data.nid ?? "")) return true;
    if (model.enNameInput.text != enName) return true;
    if (model.zhNameInput.text != zhName) return true;
    if (model.enDescInput.text != enDesc) return true;
    if (model.zhDescInput.text != zhDesc) return true;
    if (model.difficultyMinInput.text != (data.difficulty?.min ?? "").toString()) return true;
    if (model.difficultyMaxInput.text != (data.difficulty?.max ?? "").toString()) return true;
    if (model.descriptionForPromptInput.text != (data.descriptionForPrompt ?? "")) return true;
    if (model.audioCharacteristicsInput.text != (data.audioCharacteristics ?? "")) return true;
    return false;
  }

  /// 重置模型到原始数据
  void _resetToOriginal(ManageScriptGenreModel model) {
    final data = model.data;
    if (data == null) return;
    List<LanguageText?> nameList = data.name ?? [];
    String enName = nameList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhName = nameList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";
    List<LanguageText?> descList = data.description ?? [];
    String enDesc = descList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhDesc = descList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";
    model.nidInput.text = data.nid ?? "";
    model.enNameInput.text = enName;
    model.zhNameInput.text = zhName;
    model.enDescInput.text = enDesc;
    model.zhDescInput.text = zhDesc;
    model.difficultyMinInput.text = data.difficulty?.min?.toString()??"";
    model.difficultyMaxInput.text = data.difficulty?.max?.toString()??"";
    model.descriptionForPromptInput.text = data.descriptionForPrompt ?? "";
    model.audioCharacteristicsInput.text = data.audioCharacteristics ?? "";
    listData.refresh();
  }

  /// 选择题材
  Future<void> selectLeftGenre(BuildContext context, int index) async {
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
        await editGenre(context);
      } else {
        _resetToOriginal(currentModel);
      }
    }
    currentIndex.value = index;
  }

  /// 新增题材
  Future<void> addGenre() async{
    searchInput.clear();

    ManageScriptGenreModel addModel = ManageScriptGenreModel(
      nidInput: TextEditingController(text: "new-genre-${listData.length + 1}-${DateTime.now().millisecondsSinceEpoch}"),
      zhNameInput: TextEditingController(),
      enNameInput: TextEditingController(),
      zhDescInput: TextEditingController(),
      enDescInput: TextEditingController(),
      difficultyMinInput: TextEditingController(),
      difficultyMaxInput: TextEditingController(),
      descriptionForPromptInput: TextEditingController(),
      audioCharacteristicsInput: TextEditingController(),
    );

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = _buildReqData(addModel);
      reqData["enabled"] = false;
      ManageScriptGenreEntity? res = await LanguageConsoleDramaRequest.addScriptGenre(data: reqData);
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

  /// 删除题材
  Future<void> deleteGenre(BuildContext context) async{
    if(listData[currentIndex.value].data?.nid == null) return;
    bool askRes = await DeleteDialog.show(
      context: context, 
      title: "删除",
      content: "您确定要删除此题材数据吗？",
    );
    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      bool res = await LanguageConsoleDramaRequest.deleteScriptGenre(
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
      content: "您确定要${enabled ? "停用" : "启用"}此题材吗？",
    );
    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "nid": listData[currentIndex.value].data!.nid!,
        "enabled": !enabled,
      };
      ManageScriptGenreEntity? res = await LanguageConsoleDramaRequest.editScriptGenre(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: enabled ? "停用成功" : "启用成功", type: ToastType.success);
      listData[currentIndex.value].data!.enabled = !enabled;
      listData.refresh();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 保存编辑
  Future<void> editGenre(BuildContext context) async{
    if(listData[currentIndex.value].data?.nid == null) return;
    ManageScriptGenreModel editModel = listData[currentIndex.value];

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = _buildReqData(editModel);
      ManageScriptGenreEntity? res = await LanguageConsoleDramaRequest.editScriptGenre(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      editModel.data = res;
      listData.refresh();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 构建请求数据
  Map<String, dynamic> _buildReqData(ManageScriptGenreModel model){
    return {
      "nid": model.nidInput.text,
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
      "description_for_prompt": model.descriptionForPromptInput.text,
      "audio_characteristics": model.audioCharacteristicsInput.text,
    };
  }

  @override
  void onClose() {
    super.onClose();
  }
}
