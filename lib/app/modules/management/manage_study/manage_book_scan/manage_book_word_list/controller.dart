import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_select_knowledge_table/view.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/mixins/mixins.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';
import 'state.dart';
import 'views/batch_edit_unit_page.dart';
import 'views/edit_unit_page.dart';
import 'views/edit_word_page.dart';

class ManageBookWordListController extends BaseController with FilterMixin, ManageBreadcrumbMixin {
  final String tag;
  ManageBookWordListController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_WORD_LIST;

  @override
  String get breadcrumbTitle => '词汇表';

  final ManageBookWordListState state = ManageBookWordListState();

  DessertDataSource? _dessertDataSourceSync;

  String? _moduleId, bookId, bookName;

  String? _title, _definition, _unitName;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    _moduleId = Get.arguments?["moduleId"]?.toString();
    bookId = Get.arguments?["bookId"]?.toString();
    bookName = Get.arguments?["bookName"]?.toString();
    state.editEnable = Get.arguments?["editEnable"] ?? false;
    print('---Get.routing.route?.settings:${Get.routing.route?.settings}---');
    _refreshWordListData();
    _onFetchSimpleUnits();
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void _initData() {
    update(["manage_word_list"]);
  }

  void _refreshWordListData() async {
    await onFetchKnowledge();
    _applyFiltersAndRefresh();
  }

  // 词汇表
  Future<void> onFetchKnowledge() async {
    try {
      if (_moduleId == null || _moduleId!.trim().isEmpty) {
        throw "moduleId为空";
      }
      final response = await ModuleUtil.knowledge(moduleId: _moduleId ?? '', config: RequestConfig(requireToken: true, cancelToken: cancelToken));
      state.units = response.data?.list ?? [];
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _initData();
      onRefreshDessert(state.units);
    }
  }

  // 确认
  void onConfirm() async {
    try {
      final response = await BookUtil.confirm(uid: bookId ?? '', config: RequestConfig(requireToken: true, cancelToken: cancelToken));
      if (response.data != null) {
        ToastUtils.showManageToast(text: '确认成功');
        Get.back(result: true);
      } else {
        ToastUtils.showManageToast(text: response.message ?? '确认失败');
      }
    } catch (e) {
      if (kDebugMode) {
        print('---异常e: ${e.toString()}---');
      }
    }
  }

  // 创建词汇
  void onCreateKnowledge(Map<String, dynamic> body) async {
    try {
      final response = await ModuleUtil.add(moduleId: _moduleId ?? '', config: RequestConfig(requireToken: true, data: body, cancelToken: cancelToken));
      if (response.data != null) {
        ToastUtils.showManageToast(text: '创建词汇成功');
      } else {
        ToastUtils.showManageToast(text: response.message ?? '创建词汇失败');
      }
    } catch (e) {
      if (kDebugMode) {
        print('---异常e: ${e.toString()}---');
      }
      ToastUtils.showManageToast(text: '创建词汇失败');
    } finally {
      _refreshWordListData();
    }
  }

  // 编辑词汇
  void onEditKnowledge(Map<String, dynamic> body) async {
    try {
      final response = await KnowledgeUtil.edit(
          unitId: body["oldUnitId"] ?? '', config: RequestConfig(requireToken: true, data: {"uid": body["oldUid"], "unitId": body["unitId"]}, cancelToken: cancelToken));
      if (response.data != null) {
        ToastUtils.showManageToast(text: '编辑词汇成功');
      } else {
        ToastUtils.showManageToast(text: '编辑词汇失败');
      }
    } catch (e) {
      if (kDebugMode) {
        print('---异常e: ${e.toString()}---');
      }
    } finally {
      _refreshWordListData();
    }
  }

  // 批量删除词汇
  void onBatchDeleteKnowledge() async {
    if (_moduleId == null) {
      ToastUtils.showManageToast(text: "moduleId为空");
      return;
    }

    try {
      final response = await ModuleUtil.delete(
          moduleId: _moduleId, config: RequestConfig(requireToken: true, data: state.selectedRows.map((element) => element.uid).toList(), cancelToken: cancelToken));
      if (response.data != null) {
        ToastUtils.showManageToast(text: '批量删除词汇成功');
        state.selectedRows.clear();
        _refreshWordListData();
      } else {
        ToastUtils.showManageToast(text: '批量删除词汇失败');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      ToastUtils.showManageToast(text: e.toString());
    }
  }

  // 批量编辑词汇
  void onBatchEditKnowledge(Map<String, dynamic> body) async {
    try {
      final response = await UnitUtil.batchEdit(
          config: RequestConfig(requireToken: true, data: {"uids": state.selectedRows.map((element) => element.uid).toList(), "unitId": body["unitId"]}, cancelToken: cancelToken));
      if (response.data != null) {
        ToastUtils.showManageToast(text: '批量编辑词汇成功');
        state.selectedRows.clear();
        _refreshWordListData();
      } else {
        ToastUtils.showManageToast(text: '批量编辑词汇失败');
      }
    } catch (e) {
      if (kDebugMode) {
        print('---异常e: ${e.toString()}---');
      }
      ToastUtils.showManageToast(text: '批量编辑词汇失败');
    }
  }

  void _onFetchSimpleUnits() async {
    state.simpleUnits = await onFetchSimpleUnits();
    // 更新状态筛选组件
    update(['manage_word_list', 'unit_response_entity_filter']);
  }

  // 模块下的简单单元列表
  Future<List<UnitResponseEntity>> onFetchSimpleUnits() async {
    try {
      if (_moduleId == null || _moduleId!.trim().isEmpty) {
        throw "moduleId为空";
      }
      final response = await ModuleUtil.simpleUnits(moduleId: _moduleId ?? '', config: RequestConfig(requireToken: true, cancelToken: cancelToken));
      return response.data?.list ?? [];
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }

    return [];
  }

  // 创建单元
  Future<NewUnitResponseEntity?> onCreateUnit({required name, required int createSelectLanguageIndex}) async {
    if (_moduleId == null || _moduleId!.trim().isEmpty) {
      throw "moduleId为空";
    }

    // 语言
    String? language;
    try {
      language = CommonUtil.languageKeys[createSelectLanguageIndex];
    } catch (e) {
      print('---语言e:$e---');
    }

    if (language == null) {
      ToastUtils.showManageToast(text: "请选择语言");
      return null;
    }

    NewUnitResponseEntity? unitResponseEntity;
    try {
      final response =
          await UnitUtil.create(config: RequestConfig(requireToken: true, data: {"name": name, "language": language, "moduleId": _moduleId}, cancelToken: cancelToken));
      if (response.data != null) {
        unitResponseEntity = response.data;
        _onFetchSimpleUnits();
        ToastUtils.showManageToast(text: "创建单元成功");
      } else {
        ToastUtils.showManageToast(text: response.message ?? "创建单元失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "创建单元失败");
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _initData();
    }

    return unitResponseEntity;
  }

  // 编辑单元
  Future<NewUnitResponseEntity?> onEditUnit({required int uid, required name}) async {
    if (_moduleId == null || _moduleId!.trim().isEmpty) {
      throw "moduleId为空";
    }

    NewUnitResponseEntity? unitResponseEntity;
    try {
      final response = await UnitUtil.edit(uid: uid.toString(), config: RequestConfig(requireToken: true, data: {"name": name, "moduleId": _moduleId}, cancelToken: cancelToken));
      if (response?.data != null) {
        unitResponseEntity = response?.data;
        _onFetchSimpleUnits();
        ToastUtils.showManageToast(text: "编辑单元成功");
      } else {
        ToastUtils.showManageToast(text: response?.message ?? "编辑单元失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "编辑单元失败");
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _initData();
    }

    return unitResponseEntity;
  }

  // 排序单元
  Future<void> onSortUnits(List<int> unitIds) async {
    if (_moduleId == null) {
      ToastUtils.showManageToast(text: "moduleId为空");
      return;
    }

    if (unitIds.isEmpty) {
      ToastUtils.showManageToast(text: "单元Id为空");
      return;
    }

    try {
      final response = await ModuleUtil.edit(uid: _moduleId.toString(), config: RequestConfig(requireToken: true, data: {"unitIds": unitIds}, cancelToken: cancelToken));
      if (response.data != null) {
        _onFetchSimpleUnits();
        ToastUtils.showManageToast(text: "单元排序成功");
      } else {
        ToastUtils.showManageToast(text: response.message ?? "单元排序失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "单元排序失败");
      if (kDebugMode) {
        print(e.toString());
      }
      ToastUtils.showManageToast(text: e.toString());
    }
  }

  // 同步数据处理器
  void onSetDataSourceSync(DessertDataSource? source) {
    _dessertDataSourceSync = source;
  }

  // 鼠标右键点击
  void onSecondaryTap(int index, UnitResponseEntity v1) {
    print('---鼠标右键点击,index:$index, v1:$v1---');
    if (!state.editEnable) {
      return;
    }
    InsertRowManager.show(
        context: Get.context!,
        onUpTap: () {
          print('---向上,index:$index, v1:$v1---');
          InsertRowManager.dismiss();
          ManageEditWordManager.show(
              context: Get.context!,
              wordEntity: v1,
              index: index,
              onCreateTap: (Map<String, dynamic> body) {
                onCreateKnowledge(body);
              });
        },
        onDownTap: () {
          print('---向下,index:$index, v1:$v1---');
          InsertRowManager.dismiss();
          ManageEditWordManager.show(
              context: Get.context!,
              wordEntity: v1,
              index: index + 2,
              onCreateTap: (Map<String, dynamic> body) {
                onCreateKnowledge(body);
              });
        });
  }

  // 编辑单元
  void toEditUnit(int index, UnitResponseEntity v1) {
    ManageEditUnitManager.show(
        context: Get.context!,
        defaultEntity: v1,
        onOkTap: (Map<String, dynamic> body) {
          onEditKnowledge(body);
        });
  }

  // 批量删除
  void toBathDelete(BuildContext context) async {
    if (state.selectedRows.isEmpty) {
      return;
    }

    final bool ask = await AskDialog.show(
      context: context,
      showLastCountdown: true,
      title: "温馨提示",
      content: "确定要删除吗？",
    );
    if (!ask) return;
    onBatchDeleteKnowledge();
  }

  // 批量编辑
  void toBathEdit() {
    if (state.selectedRows.isEmpty) {
      return;
    }
    ManageBatchEditUnitManager.show(
        context: Get.context!,
        onOkTap: (Map<String, dynamic> body) {
          onBatchEditKnowledge(body);
        });
  }

  // 单元管理
  Future<void> toUnitManage() async{
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_WORD_LIST_CHECK_KNOWLEDGE,
      arguments: {
        "moduleId": _moduleId,
      },
    );
    _refreshWordListData();
  }

  // 选中/未选中行
  bool onDataDisableCallback(UnitResponseEntity value) {
    return !state.editEnable;
  }

  // 选中/未选中行
  void onRowSelectChanged(bool selected, int id, UnitResponseEntity value) {
    if (selected) {
      state.selectedRows.add(value);
    } else {
      state.selectedRows.remove(value);
    }
  }

  /// 设置状态筛选
  void setStatusFilter(int index, String? status) {
    state.statusFilter = status;
    state.statusFilterIndex = index;
    // 更新状态筛选组件
    update(['match_status_filter']);
    _applyFiltersAndRefresh();
  }

  /// 设置状态筛选
  void setUnitResponseEntityFilter(UnitResponseEntity? status) {
    state.unitResponseEntityFilter = status;
    onSetName(status?.unitName ?? '', isSubmit: true);
    // 更新状态筛选组件
    update(['unit_response_entity_filter']);
  }

  /// 设置排序字段和方向
  void setSort(String field) {
    if (state.sortField == field) {
      state.sortDirection = state.sortDirection == 'asc' ? 'desc' : 'asc';
    } else {
      state.sortField = field;
      state.sortDirection = 'desc';
    }

    // 更新排序按钮组件
    update(['sort_buttons']);

    _applyFiltersAndRefresh();
  }

  // 英文标题过滤
  void onSetTitle(String? title, {bool isSubmit = false}) {
    _title = title?.trim();
    if (isSubmit) {
      _applyFiltersAndRefresh();
    }
  }

  // 翻译内容过滤
  void onSetDefinition(String? definition, {bool isSubmit = false}) {
    _definition = definition?.trim();
    if (isSubmit) {
      _applyFiltersAndRefresh();
    }
  }

  // 翻译内容过滤
  @override
  void onSetName(String name, {bool isSubmit = false}) {
    _unitName = name.trim();
    if (isSubmit) {
      _applyFiltersAndRefresh();
    }
  }

  // 综合过滤方法
  void _applyFiltersAndRefresh() {
    // 先过滤
    final filtered = state.units.where(_matchAllConditions).toList();

    // 如果是按相似度排序，直接处理
    if (state.sortField == 'similarity') {
      filtered.sort((a, b) {
        final double valueA = a.similarity ?? 0.0;
        final double valueB = b.similarity ?? 0.0;
        final int result = valueA.compareTo(valueB);
        return state.sortDirection == 'asc' ? result : -result;
      });
    }

    onRefreshDessert(filtered);
  }

  // 多条件联合匹配（必须同时满足所有非空条件）
  bool _matchAllConditions(UnitResponseEntity element) {
    bool match = true;

    // 英文标题匹配（连续）
    if (_title?.isNotEmpty ?? false) {
      final content = element.content?.toLowerCase() ?? '';
      match &= content.contains(_title!.toLowerCase());
    }

    // 翻译匹配（连续）
    if (_definition?.isNotEmpty ?? false) {
      final definition = element.definition?.toLowerCase() ?? '';
      match &= definition.contains(_definition!.toLowerCase());
    }

    // 单元名称匹配（连续）
    if (_unitName?.isNotEmpty ?? false) {
      final unitName = element.unitName?.toLowerCase() ?? '';
      match &= unitName.contains(_unitName!.toLowerCase());
    }

    // 根据匹配状态过滤
    if (state.statusFilterIndex > 0) {
      // 状态过滤索引为1表示"已匹配"，为2表示"未匹配"
      final bool shouldBeMatched = state.statusFilterIndex == 1;
      match &= element.hasMatch == shouldBeMatched;
    }

    return match;
  }

  // 刷新表单
  void onRefreshDessert(final List<UnitResponseEntity> ds) {
    _dessertDataSourceSync?.setDesserts(ds);
  }

  // 知识点
  Future<void> toAddKnowledge(BuildContext context, int index, UnitResponseEntity unitResponseEntity, List<BaseKnowledge> existList) async {
    if (ObjectUtil.isEmpty(unitResponseEntity.contentType?.trim())) {
      ToastUtils.showManageToast(text: "请更新英语类型", type: ManageToastType.error);
      return;
    }

    var value = await ManageSelectKnowledgeTableManager.showWithButtonStrategy(
        context: context,
        // unitId: 0,
        defaultDessert: existList,
        buttonConfig: KnowledgeTableConfig(
          showAddButton: true,
          hasFixedButtonVisibility: true,
          singleSelectionMode: true,
        ),
        word: unitResponseEntity.content?.trim(),
        definition: unitResponseEntity.definition?.trim(),
        // 知识点类型索引
        tabCurrentIndex: unitResponseEntity.newKnowledgeType.index,
        dataDisableCallback: (BaseKnowledge targetEntity) {
          bool isDisable = false;
          for (final BaseKnowledge exist in existList) {
            if (exist.contentId == targetEntity.uid) {
              isDisable = true;
              break;
            }
          }
          return isDisable;
        });

    Map<String, dynamic> targetData = {};

    if (value != null && value.isNotEmpty) {
      final entity = value.first;
      if (entity is EnWordEntity) {
        targetData = {
          "content": unitResponseEntity.content,
          "contentType": unitResponseEntity.contentType,
          "contentId": entity.uid,
          "semanticId": entity.selectedSemantics?.uid,
          "target": entity.selectedSemantics?.glossZhTitle,
        };
      } else if (entity is EnPhraseEntity) {
        targetData = {
          "content": unitResponseEntity.content,
          "contentType": unitResponseEntity.contentType,
          "contentId": entity.uid,
          "semanticId": entity.selectedSemantics?.uid,
          "target": entity.selectedSemantics?.glossZhTitle,
        };
      } else if (entity is EnSentenceEntity) {
        targetData = {
          "content": unitResponseEntity.content,
          "contentType": unitResponseEntity.contentType,
          "contentId": entity.uid,
          "semanticId": entity.selectedSemantics?.uid,
          "target": entity.selectedSemantics?.glossZhTitle,
        };
      }
    }

    if (targetData.isNotEmpty) {
      onConfirmMatch(unitResponseEntity.unitId ?? 0, targetData);
    }
  }

  /// 取消匹配
  void onCancelMatch(BuildContext context, UnitResponseEntity dessert) {
    if (ObjectUtil.isEmpty(dessert.contentType?.trim())) {
      ToastUtils.showManageToast(text: "请更新英语类型", type: ManageToastType.error);
      return;
    }

    _onCancelMatch(dessert);
  }

  // 取消绑定
  void _onCancelMatch(UnitResponseEntity dessert) async {
    try {
      ToastUtils.showLoading();
      final response = await UnitUtil.revokeMatchKnowledge(
          unitId: dessert.unitId, config: RequestConfig(requireToken: true, data: {"content": dessert.content, "contentType": dessert.contentType}, cancelToken: cancelToken));
      if (response.data != null) {
        ToastUtils.showManageToast(text: "取消匹配成功");
        _refreshWordListData();
      } else {
        ToastUtils.showManageToast(text: response.message ?? "取消匹配失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "取消匹配失败");
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      ToastUtils.hideLoading();
      _initData();
    }
  }

  // 知识点绑定
  void onConfirmMatch(int unitId, Map<String, dynamic> dessert) async {
    try {
      ToastUtils.showLoading();
      final response = await UnitUtil.confirmMatchKnowledge(unitId: unitId, config: RequestConfig(requireToken: true, data: dessert, cancelToken: cancelToken));
      if (response.data != null) {
        ToastUtils.showManageToast(text: "知识点匹配成功");
        _refreshWordListData();
      } else {
        ToastUtils.showManageToast(text: response.message ?? "知识点匹配失败");
      }
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message ?? "知识点匹配失败");
    } catch (e) {
      ToastUtils.showManageToast(text: "知识点匹配失败");
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      ToastUtils.hideLoading();
      _initData();
    }
  }

  // 编辑知识点详情
  void onEditKnowledgeDetail(UnitResponseEntity unitResponseEntity, {String? newContent, String? newDefinition, String? newContentType}) async {
    try {
      // 构建请求数据
      final Map<String, dynamic> data = {};

      // 添加名称（如果有且不为空）
      if (newContent != null && newContent.trim().isNotEmpty) {
        // 检查是否有变化
        if (newContent.trim() != unitResponseEntity.content?.trim()) {
          data["content"] = newContent.trim();
        }
      }

      // 添加翻译（如果有且不为空）
      if (newDefinition != null && newDefinition.trim().isNotEmpty) {
        // 检查是否有变化
        if (newDefinition.trim() != unitResponseEntity.definition?.trim()) {
          data["definition"] = newDefinition.trim();
        }
      }

      // 添加类型（如果有且不为空）
      if (newContentType != null && newContentType.trim().isNotEmpty) {
        // 检查是否有变化
        if (newContentType.trim() != unitResponseEntity.contentType?.trim()) {
          data["contentType"] = newContentType.trim();
        }
      }

      // 如果没有需要更新的数据，直接返回
      if (data.isEmpty) {
        return;
      }

      data["uid"] = unitResponseEntity.uid;

      final response = await UnitUtil.editKnowledgeDetail(unitId: unitResponseEntity.unitId, config: RequestConfig(requireToken: true, data: data, cancelToken: cancelToken));
      if (response.data != null) {
        ToastUtils.showManageToast(text: '编辑知识点成功');
        _refreshWordListData();
      } else {
        ToastUtils.showManageToast(text: '编辑知识点失败');
      }
    } catch (e) {
      if (kDebugMode) {
        print('---异常e: ${e.toString()}---');
      }
      ToastUtils.showManageToast(text: '编辑知识点失败');
    }
  }

  // 自动匹配知识点
  // void onAutoMatch() async {
  //   if (bookId == null || bookId!.trim().isEmpty) {
  //     throw "bookId为空";
  //   }

  //   try {
  //     ToastUtils.showLoading();
  //     final response = await UnitUtil.autoMatchKnowledge(bookId: bookId!, config: RequestConfig(requireToken: true, cancelToken: cancelToken));
  //     if (response.data != null) {
  //       ToastUtils.showManageToast(text: "知识点自动匹配成功");
  //       // 刷新数据
  //       _refreshWordListData();
  //     } else {
  //       ToastUtils.showManageToast(text: response.message ?? "知识点自动匹配失败");
  //     }
  //   } on FormatException catch (e) {
  //     ToastUtils.showToast(text: e.source?.message ?? "知识点自动匹配失败");
  //   } on TimeoutException catch (_) {
  //     ToastUtils.showManageToast(text: "请求超时，请检查网络连接");
  //   } catch (e) {
  //     ToastUtils.showManageToast(text: "知识点自动匹配失败");
  //   } finally {
  //     ToastUtils.hideLoading();
  //     // 确保数据状态同步
  //     _initData();
  //   }
  // }

  @override
  void onClose() {
    _moduleId = null;
    bookId = null;
    state.selectedRows.clear();
    state.units.clear();
    state.simpleUnits.clear();
    cancelToken.cancel("词汇表取消");
    print("词汇表销毁");
    super.onClose();
  }
}
