

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

  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{
    "order": FilterSortsData(
      title: "排序值",
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
    "uid": FilterSortsData(
      title: "uid",
      sorts: [
        FilterSortsItem(name: "从小到大", direction: FilterSortDirection.up),
        FilterSortsItem(name: "从大到小", direction: FilterSortDirection.down),
      ],
    ),
  }.obs;

  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{}.obs;

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

  int limit = 20;
  int offset = 0;
  int total = 0;
  bool isLoading = true;

  /// 列表数据
  final RxList<ManageScriptGroupingModel> listData = <ManageScriptGroupingModel>[].obs;

  /// 当前选中的下标
  final RxInt currentIndex = 0.obs;
  final RxBool isEditing = false.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    // TODO: 初始化逻辑
    if(Get.arguments != null){
      List? uids = Get.arguments['uids'];
      if(uids != null){
        filterSearchs['uids']?.controller.text = uids.join(',');
      }
    }

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
  Future<void> refreshListData({bool isReset = true}) async {
    isEditing.value = false;
    if(isReset) currentIndex.value = 0;
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
      };
      Map<String, dynamic> sortOrder = FilterStripUtils.getSortOrderParameter(sorts: filterSorts);
      parameters.addAll(sortOrder);
      Map<String, dynamic> reqData = {};
      Map<String, dynamic> conditionParameter = FilterStripUtils.getConditionParameter(conditions: filterConditions);
      reqData.addAll(conditionParameter);

      Map<String, dynamic> searchParameter = FilterStripUtils.getSearchParameter(searchs: filterSearchs);
      reqData.addAll(searchParameter);
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
    if (model.data?.uid == null) return true;
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
        bool saveRes = await editGroup(context);
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

  /// 新增分组
  Future<void> addGroup(BuildContext context) async {
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
          bool saveRes = await editGroup(context);
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

    listData.insert(0, addModel);
    currentIndex.value = 0;
    isEditing.value = true;
    listData.refresh();
    if (!leftScrollController.hasClients) return;
    leftScrollController.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.linear);
  }

  /// 删除分组
  Future<void> deleteGroup(BuildContext context) async {
    if (listData.isEmpty) return;
    ManageScriptGroupingModel currentModel = listData[currentIndex.value];
    bool askRes = await DeleteDialog.show(
      context: context,
      title: "删除",
      content: "您确定要删除此分组数据吗？",
      showCountdown: currentModel.data?.uid != null,
    );
    if (!askRes) return;

    if (currentModel.data?.uid == null) {
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
      bool res = await LanguageConsoleDramaRequest.deleteScriptGroup(currentModel.data!.uid!);
      if (!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      listData.removeAt(currentIndex.value);
      if (listData.isEmpty) {
        currentIndex.value = 0;
      } else if (currentIndex.value >= listData.length) {
        currentIndex.value = listData.length - 1;
      }
      isEditing.value = false;
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

  /// 保存（新增/编辑）
  Future<bool> editGroup(BuildContext context) async {
    if (listData.isEmpty) return false;
    ManageScriptGroupingModel editModel = listData[currentIndex.value];
    bool isCreate = editModel.data?.uid == null;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = _buildReqData(editModel);
      ManageScriptGroupingEntity? res;
      if (isCreate) {
        reqData["enabled"] = false;
        res = await LanguageConsoleDramaRequest.addScriptGroup(data: reqData);
      } else {
        res = await LanguageConsoleDramaRequest.editScriptGroup(editModel.data!.uid!, data: reqData);
      }
      if (res == null) return false;
      ToastUtils.showToast(text: isCreate ? "新增成功" : "保存成功", type: ToastType.success);
      listData[currentIndex.value] = setModel(res);
      isEditing.value = false;
      listData.refresh();
      return true;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 构建请求数据
  Map<String, dynamic> _buildReqData(ManageScriptGroupingModel model) {
    return {
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

  void startEdit() {
    isEditing.value = true;
  }

  Future<void> cancelEdit(BuildContext context) async {
    if (listData.isEmpty) return;
    final ManageScriptGroupingModel currentModel = listData[currentIndex.value];
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
