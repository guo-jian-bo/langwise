import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/mixins/mixins.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../theme/theme.dart';
import '../../../management/utils/utils.dart';

class ZhenxieGrammarPanoramaDetailsController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ZhenxieGrammarPanoramaDetailsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_GRAMMAR_PANORAMA_DETAILS;

  @override
  String get breadcrumbTitle => '语法全景详情';

  /// 是否是管理端入口打开
  bool isManagement = false;

  // 传进来的参数
  /// nid: 语法全景nid
  String? nid;
  /// 详情参数 例句列表 realizationSetId
  int? realizationSetId;
  /// 单元语境透传的 unitId，用于后续“添加一组”继续限制候选范围。
  int? unitId;

  final Rx<ManageGrammarPanoramaEntity> grammarPanorama = ManageGrammarPanoramaEntity().obs;

  /// 宫格对应的行列
  final RxList<ManageGrammarPanoramaAxisEntity> axesList = <ManageGrammarPanoramaAxisEntity>[].obs;

  /// 每个 axisKey 当前选中的值，默认全选。
  final RxMap<String, List<String>> selectedAxisValues = <String, List<String>>{}.obs;

  /// contrastFoci
  final RxList<FocusKeyEnum> focusKeyList = <FocusKeyEnum>[].obs;

  /// 当前选择的key
  final Rx<FocusKeyEnum> selectedFocusKey = FocusKeyEnum.tense_marking.obs;

  final RxList<GrammarPanoramaExampleEntity> exampleList = <GrammarPanoramaExampleEntity>[].obs;

  /// 滚动控制器
  final ScrollController scrollController = ScrollController();

  /// 总条数
  int total = 0;

  /// offset
  int offset = 0;

  /// limit
  int limit = 10;

  /// 是否加载中
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if (Get.arguments != null) {
      isManagement = Get.arguments["isManagement"] ?? false;
      nid = Get.arguments["nid"];
      realizationSetId = Get.arguments["realizationSetId"];
      unitId = Get.arguments["unitId"];
      getDatailsData();
    }
    listenScroll();
  }

  /// 监听列表滚动进行分页加载
  void listenScroll() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 && !scrollController.position.outOfRange) {
        if (!isLoading.value && exampleList.length < total) {
          offset += limit;
          getExampleList();
        }
      }
    });
  }

  Future<void> getDatailsData() async {
    if (nid == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> params = {};

      if(realizationSetId != null){
        params['realizationSetId'] = realizationSetId;
        params['optionSlot'] = true; // | realizationSetId > 0 | sentenceId > 0 | 处理 |
      }

      Map<String, dynamic> reqData = {
        "nid": nid,
      };
      ListResponseEntity<ManageGrammarPanoramaEntity>? list;
      if (isManagement) {
        list = await LanguageConsoleRequest.getManageGrammarPanoramaList(
          data: reqData,
          parameters: params,
        );
      } else {
        list = await LanguageUtil.getGrammarPanoramaList(
          data: reqData,
          parameters: params,
        );
      }
      if (list == null) return;
      if (list.datas == null) return;
      List<ManageGrammarPanoramaEntity> datas = list.datas ?? [];
      for (var i = 0; i < datas.length; i++) {
        if (datas[i].nid == nid) {
          grammarPanorama.value = datas[i];
          break;
        }
      }

      List<ManageGrammarPanoramaAxisEntity?> axes = grammarPanorama.value.axes ?? [];
      axesList.clear();
      for (var element in axes) {
        if (element == null) continue;
        axesList.add(element);
      }
      _resetSelectedAxisValues();

      List<ManageGrammarPanoramaContrastFocusEntity?> contrastFoci = grammarPanorama.value.contrastFoci ?? [];
      focusKeyList.clear();
      for (var element in contrastFoci) {
        if (element?.focusKeyEnum == null) continue;
        focusKeyList.add(element!.focusKeyEnum!);
      }
      if (focusKeyList.isNotEmpty && !focusKeyList.contains(selectedFocusKey.value)) {
        selectedFocusKey.value = focusKeyList.first;
      }

      await refreshExampleList();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 刷新列表
  Future<void> refreshExampleList() async {
    exampleList.clear();
    offset = 0;
    total = 0;
    await getExampleList();
  }

  /// 查询例句列表
  Future<void> getExampleList() async {
    if (nid == null && realizationSetId == null) return;
    try {
      isLoading.value = true;
      Map<String, dynamic> params = {
        "offset": offset,
        "limit": limit,
      };
      Map<String, dynamic> reqData = {
        "assetNid": nid,
      };
      if(realizationSetId != null){
        reqData['uids'] = [realizationSetId];
      }
      ListResponseEntity<GrammarPanoramaExampleEntity>? list;
      if (isManagement) {
        list = await LanguageConsoleRequest.getManageGrammarPanoramatExample(
          data: reqData,
          parameters: params,
        );
      } else {
        list = await LanguageUtil.getGrammarPanoramaExample(
          data: reqData,
          parameters: params,
        );
      }
      if (list == null) return;
      if (list.datas == null) return;
      exampleList.addAll(list.datas ?? []);
      total = list.count ?? 0;
    } finally {
      isLoading.value = false;
    }
  }

  /// 重置轴值选择状态，默认每个轴全选。
  void _resetSelectedAxisValues() {
    final map = <String, List<String>>{};
    for (final axis in axesList) {
      final axisKey = axis.axisKey;
      if (axisKey?.isEmpty != false) continue;
      map[axisKey!] = axis.values?.whereType<String>().toList() ?? [];
    }
    selectedAxisValues.value = map;
  }

  /// 当前轴值是否处于选中状态。
  bool isAxisValueSelected(String? axisKey, String? value) {
    if (axisKey?.isEmpty != false || value?.isEmpty != false) return false;
    return selectedAxisValues[axisKey!]?.contains(value) ?? false;
  }

  /// 切换当前高亮焦点。
  void selectFocusKey(FocusKeyEnum focusKey) {
    selectedFocusKey.value = focusKey;
  }

  /// 切换轴值显隐，每个轴至少保留一个值。
  void toggleAxisValue(String? axisKey, String? value) {
    if (axisKey?.isEmpty != false || value?.isEmpty != false) return;
    final selectedList = List<String>.from(selectedAxisValues[axisKey!] ?? []);
    if (selectedList.contains(value)) {
      if (selectedList.length <= 1) return;
      selectedList.remove(value);
    } else {
      selectedList.add(value!);
      ManageGrammarPanoramaAxisEntity? axis;
      for (final item in axesList) {
        if (item.axisKey == axisKey) {
          axis = item;
          break;
        }
      }
      final axisValues = axis?.values?.whereType<String>().toList() ?? [];
      selectedList.sort((a, b) => axisValues.indexOf(a).compareTo(axisValues.indexOf(b)));
    }
    selectedAxisValues[axisKey] = selectedList;
    selectedAxisValues.refresh();
  }

  /// 当前表格可见的轴定义，values 会按选择结果裁剪。
  List<ManageGrammarPanoramaAxisEntity?> get visibleAxes {
    return axesList.map((axis) {
      final axisKey = axis.axisKey;
      final selectedValues = selectedAxisValues[axisKey] ?? [];
      final filteredLabels = axis.valuesLabels?.where((item) => selectedValues.contains(item?.nid)).toList();
      return ManageGrammarPanoramaAxisEntity(
        axisKey: axis.axisKey,
        dimensionNid: axis.dimensionNid,
        dimension: axis.dimension,
        values: selectedValues,
        valuesLabels: filteredLabels,
      );
    }).toList();
  }

  /// 当前表格可见的 cell，按首个行轴和第二个列轴的已选值过滤。
  List<ManageGrammarPanoramaCellEntity?>? get visibleCells {
    final allCells = grammarPanorama.value.cells;
    if (allCells == null) return null;
    if (axesList.length < 2) return allCells;
    final rowAxisKey = axesList.first.axisKey;
    final colAxisKey = axesList[1].axisKey;
    final rowSelectedValues = selectedAxisValues[rowAxisKey] ?? [];
    final colSelectedValues = selectedAxisValues[colAxisKey] ?? [];
    return allCells.where((item) {
      final rowValue = item?.rowValue;
      final colValue = item?.colValue;
      if (rowValue == null || colValue == null) return false;
      return rowSelectedValues.contains(rowValue) && colSelectedValues.contains(colValue);
    }).toList();
  }

  /// 编辑名称说明
  Future<void> editNameDesc(BuildContext context) async {
    if (nid == null) return;

    EditNameDescDialogResult? res = await EditNameDescDialog.show(
      context: context,
      name: grammarPanorama.value.name,
      description: grammarPanorama.value.description,
    );
    if (res == null) return;
    try {
      ToastUtils.showLoading();
      List<Map<String, dynamic>> nameList = [];
      List<Map<String, dynamic>> descriptionList = [];
      res.name?.forEach((e) {
        nameList.add(e?.toJson() ?? {});
      });
      res.description?.forEach((e) {
        descriptionList.add(e?.toJson() ?? {});
      });

      Map<String, dynamic> reqData = {
        "name": nameList,
        "description": descriptionList,
      };

      ManageGrammarPanoramaEntity? resp = await LanguageConsoleRequest.editManageGrammarPanorama(
        nid: nid!,
        data: reqData,
      );
      if (resp == null) return;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      grammarPanorama.value = resp;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 例句句子组上下架
  Future<void> exampleSentenceGroupShelf(GrammarPanoramaExampleEntity example) async {
    if (example.uid == null) return ToastUtils.showToast(text: "uid为空");
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "access": example.isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value,
      };
      bool resp = await LanguageConsoleRequest.zhenxieExampleAccess(
        uid: example.uid!,
        data: reqData,
      );
      if (!resp) return;
      ToastUtils.showToast(text: "${example.isNormal ? "下架" : "上架"}成功", type: ToastType.success);
      example.access = example.isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value;
      exampleList.refresh();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 删除句组
  Future<void> exampleSentenceGroupDelete(BuildContext context, GrammarPanoramaExampleEntity example) async {
    if (example.uid == null) return ToastUtils.showToast(text: "uid为空");
    bool ask = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "确认删除句子吗？",
      defineColor: AppTheme.cSurfaceError.color,
    );
    if (!ask) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "access": AccessEnum.DELETED.value,
      };
      bool resp = await LanguageConsoleRequest.zhenxieExampleAccess(
        uid: example.uid!,
        data: reqData,
      );
      if (!resp) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      exampleList.removeWhere((e) => e.uid == example.uid);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 单句上下架
  Future<void> exampleSentenceShelf(PatternBlueprintSentenceBriefEntity? sentence) async {
    if (sentence == null) return;
    if (sentence.sentenceId == null) return;
    bool isNormal = sentence.isNormal;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "access": isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value,
      };
      bool resp = await LanguageConsoleRequest.zhenxieExampleSingleAccess(
        sentenceId: sentence.sentenceId!,
        data: reqData,
      );
      if (!resp) return;
      ToastUtils.showToast(text: "${isNormal ? "下架" : "上架"}成功", type: ToastType.success);
      sentence.access = isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value;
      exampleList.refresh();
    } finally {
      ToastUtils.hideLoading();
    }
  }


  /// 添加一组
  Future<void> addGroup() async{
    dynamic res = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_SENTENCE_GRAMMAR_ADD_GROUP,
      arguments: {
        "unitId": unitId,
        "grammarDetail": grammarPanorama.value,
      },
    );
    if(res != true) return;
    refreshExampleList();
  }
  
}
