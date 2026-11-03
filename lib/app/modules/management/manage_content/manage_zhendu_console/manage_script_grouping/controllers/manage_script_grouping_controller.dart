

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';
import '../models/manage_script_grouping_model.dart';

class ManageScriptGroupingController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageScriptGroupingController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SCRIPT_GROUPING;

  @override
  String get breadcrumbTitle => '剧本分组';

  final ScrollController leftScrollController = ScrollController();

  /// 搜索输入框
  final TextEditingController searchInput = TextEditingController();

  int limit = 20;
  int offset = 0;
  int total = 0;
  bool isLoading = true;

  /// 列表数据
  final RxList<ManageScriptGroupingModel> listData = <ManageScriptGroupingModel>[].obs;

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
  void listenScroll() {
    leftScrollController.addListener(() {
      if (leftScrollController.position.pixels >= leftScrollController.position.maxScrollExtent - 200 && !leftScrollController.position.outOfRange) {
        if (!isLoading && listData.length < total) {
          offset += limit;
          getListData();
        }
      }
    });
  }

  /// 刷新列表数据
  Future<void> refreshListData() async {
    currentIndex.value = 0;
    total = 0;
    offset = 0;
    listData.clear();
    await getListData();
  }

  /// 获取列表数据
  Future<void> getListData() async {
    try {
      isLoading = true;
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "limit": limit,
        "offset": offset,
        "order": "-uid",
      };
      Map<String, dynamic> reqData = {};
      if (searchInput.text.isNotEmpty) {
        reqData["keyword"] = searchInput.text;
      }
      ListResponseEntity<ManageScriptGroupingEntity>? res = await LanguageConsoleDramaRequest.getScriptGroupPages(parameters: parameters, data: reqData);
      if (res == null) return;
      total = res.count ?? 0;
      List<ManageScriptGroupingEntity> list = res.datas ?? [];
      for (ManageScriptGroupingEntity item in list) {
        listData.add(setModel(item));
      }
    } finally {
      isLoading = false;
      ToastUtils.hideLoading();
    }
  }

  /// set模型数据到本地model
  ManageScriptGroupingModel setModel(ManageScriptGroupingEntity item) {
    List<LanguageText?> nameList = item.name ?? [];
    String enName = nameList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhName = nameList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";
    List<LanguageText?> descList = item.description ?? [];
    String enDesc = descList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhDesc = descList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";

    return ManageScriptGroupingModel(
      data: item,
      uidInput: TextEditingController(text: (item.uid ?? "").toString()),
      orderInput: TextEditingController(text: (item.order ?? "").toString()),
      zhNameInput: TextEditingController(text: zhName),
      enNameInput: TextEditingController(text: enName),
      categoryInput: TextEditingController(text: item.category ?? ""),
      zhDescInput: TextEditingController(text: zhDesc),
      enDescInput: TextEditingController(text: enDesc),
    );
  }

  /// 获取最新的order值+10
  int _getNextOrder() {
    if (listData.isEmpty) return 10;
    int maxOrder = 0;
    for (var model in listData) {
      int order = int.tryParse(model.orderInput.text) ?? 0;
      if (order > maxOrder) maxOrder = order;
    }
    return maxOrder + 10;
  }

  /// 判断当前选中项是否有未保存的改变
  bool _hasChanges(ManageScriptGroupingModel model) {
    final data = model.data;
    if (data == null) return false;
    List<LanguageText?> nameList = data.name ?? [];
    String enName = nameList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhName = nameList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";
    List<LanguageText?> descList = data.description ?? [];
    String enDesc = descList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhDesc = descList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";
    if (model.uidInput.text != (data.uid ?? "").toString()) return true;
    if (model.orderInput.text != (data.order ?? "").toString()) return true;
    if (model.zhNameInput.text != zhName) return true;
    if (model.enNameInput.text != enName) return true;
    if (model.categoryInput.text != (data.category ?? "")) return true;
    if (model.zhDescInput.text != zhDesc) return true;
    if (model.enDescInput.text != enDesc) return true;
    return false;
  }

  /// 重置模型到原始数据
  void _resetToOriginal(ManageScriptGroupingModel model) {
    final data = model.data;
    if (data == null) return;
    List<LanguageText?> nameList = data.name ?? [];
    String enName = nameList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhName = nameList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";
    List<LanguageText?> descList = data.description ?? [];
    String enDesc = descList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhDesc = descList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";
    model.uidInput.text = (data.uid ?? "").toString();
    model.orderInput.text = (data.order ?? "").toString();
    model.zhNameInput.text = zhName;
    model.enNameInput.text = enName;
    model.categoryInput.text = data.category ?? "";
    model.zhDescInput.text = zhDesc;
    model.enDescInput.text = enDesc;
    listData.refresh();
  }

  /// 选择分组
  Future<void> selectLeftGroup(BuildContext context, int index) async {
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
        await editGroup(context);
      } else {
        _resetToOriginal(currentModel);
      }
    }
    currentIndex.value = index;
  }

  /// 新增分组
  Future<void> addGroup() async {
    searchInput.clear();

    int order = _getNextOrder();

    ManageScriptGroupingModel addModel = ManageScriptGroupingModel(
      uidInput: TextEditingController(),
      orderInput: TextEditingController(text: order.toString()),
      enNameInput: TextEditingController(),
      zhNameInput: TextEditingController(),
      categoryInput: TextEditingController(text: "custom"),
      enDescInput: TextEditingController(),
      zhDescInput: TextEditingController(),
    );

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = _buildReqData(addModel);
      reqData["enabled"] = false;
      ManageScriptGroupingEntity? res = await LanguageConsoleDramaRequest.addScriptGroup(data: reqData);
      if (res == null) return;
      ToastUtils.showToast(text: "新增成功", type: ToastType.success);
      listData.insert(0, setModel(res));
      currentIndex.value = 0;
      if (!leftScrollController.hasClients) return;
      leftScrollController.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.linear);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 删除分组
  Future<void> deleteGroup(BuildContext context) async {
    if (listData[currentIndex.value].data?.uid == null) return;
    bool askRes = await DeleteDialog.show(
      context: context,
      title: "删除",
      content: "您确定要删除此分组数据吗？",
    );
    if (!askRes) return;

    try {
      ToastUtils.showLoading();
      bool res = await LanguageConsoleDramaRequest.deleteScriptGroup(listData[currentIndex.value].data!.uid!);
      if (!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      listData.removeAt(currentIndex.value);
      if (currentIndex.value != 0) {
        currentIndex.value--;
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 启用/停用
  Future<void> editEnabled(BuildContext context) async {
    if (listData[currentIndex.value].data?.uid == null) return;
    bool enabled = listData[currentIndex.value].data?.enabled ?? false;

    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: enabled ? "停用" : "启用",
      content: "您确定要${enabled ? "停用" : "启用"}此分组吗？",
    );
    if (!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "enabled": !enabled,
      };
      ManageScriptGroupingEntity? res = await LanguageConsoleDramaRequest.editScriptGroup(listData[currentIndex.value].data!.uid!, data: reqData);
      if (res == null) return;
      ToastUtils.showToast(text: enabled ? "停用成功" : "启用成功", type: ToastType.success);
      listData[currentIndex.value].data!.enabled = !enabled;
      listData.refresh();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 保存编辑
  Future<void> editGroup(BuildContext context) async {
    if (listData[currentIndex.value].data?.uid == null) return;
    ManageScriptGroupingModel editModel = listData[currentIndex.value];

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = _buildReqData(editModel);
      ManageScriptGroupingEntity? res = await LanguageConsoleDramaRequest.editScriptGroup(editModel.data!.uid!, data: reqData);
      if (res == null) return;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      editModel.data = res;
      listData.refresh();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 构建请求数据
  Map<String, dynamic> _buildReqData(ManageScriptGroupingModel model) {
    return {
      "uid": model.uidInput.text,
      "order": model.orderInput.text,
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
      "category": model.categoryInput.text,
    };
  }

  @override
  void onClose() {
    super.onClose();
  }
}
