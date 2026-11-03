import 'package:api/entities/entities.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/widgets/widgets.dart';

import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../dialog/manage_create_module/view.dart';
import '../../../dialog/manage_edit_module/view.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';

class ManageModuleController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageModuleController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_MODULE;

  @override
  String get breadcrumbTitle => '模块管理';

  // 数据源
  AsyncDataTableSource? _dataSource;
  void onSetDataSourceAsync(AsyncDataTableSource source) {
    _dataSource = source;
  }

  void onRefresh() {
    _dataSource?.refreshDatasource();
  }

  // 筛选条件
  List<int> uids = [];
  String? title;
  String? des;
  CancelToken? cancelToken;

  // 状态
  final RxInt _filterIndex = 5.obs;
  set filterIndex(int value) => _filterIndex.value = value;
  int get filterIndex => _filterIndex.value;

  // 排序
  List<StaticDataEntity> sortList = [
    StaticDataEntity(name: "UID", value: "uid"),
    StaticDataEntity(name: "创建时间", value: "created"),
  ];
  SortDialogResult? staticDataEntity;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    cancelToken = CancelToken();
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  @override
  void onClose() {
    cancelToken?.cancel();
    super.onClose();
  }

  void _initData() {
    update(["manage_module"]);
  }

  // 设置筛选条件
  void onSetId(String value, {bool isSubmit = false}) {
    uids = value.split(',').where((e) => e.isNotEmpty).map((e) => int.tryParse(e.trim()) ?? 0).where((e) => e > 0).toList();
    if (isSubmit) onRefresh();
  }

  void onSetName(String value, {bool isSubmit = false}) {
    title = value.isEmpty ? null : value;
    if (isSubmit) onRefresh();
  }

  void onSetDes(String value, {bool isSubmit = false}) {
    des = value.isEmpty ? null : value;
    if (isSubmit) onRefresh();
  }

  // 获取数据
  Future<DesertsFakeWebServiceResponse<ModuleResponseEntity>> onFetchPages(
      int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData) async {
    try {
      String? order;
      if (staticDataEntity?.sort != null && staticDataEntity?.basis != null) {
        order = "${staticDataEntity?.sort?.value ?? ''}${staticDataEntity?.basis?.value ?? ''}";
      }

      order ??= "-created";

      final response = await ModuleUtil.fetchPages(
          config: RequestConfig(parameters: {
        'offset': startingAt,
        'limit': count,
        "order": order
      }, data: {
        "uid": uids.isEmpty ? null : uids,
        "name": title,
        "description": des,
      }, requireToken: true, cancelToken: cancelToken));
      if (!(response.data?.hasData ?? false)) {
        return DesertsFakeWebServiceResponse<ModuleResponseEntity>(0, []);
      }
      return DesertsFakeWebServiceResponse<ModuleResponseEntity>(
        response.data!.count!,
        (response.data?.datas ?? []),
      );
    } catch (e) {
      return DesertsFakeWebServiceResponse<ModuleResponseEntity>(0, []);
    }
  }

  /// 筛选
  void showFilter(BuildContext context) {
    // TODO: 实现筛选功能
  }

  // 添加
  void add() {
    ManageCreateModuleManager.show(context: Get.context!)?.then((value) {
      if (value != null && value) {
        onRefresh();
      }
    });
  }

  // 编辑模块
  void onEdit(ModuleResponseEntity model) {
    ManageEditModule.show(context: Get.context!, moduleEntity: model)?.then((value) {
      if (value != null) {
        onRefresh();
      }
    });
  }

  /// 跳转到模块详情
  void toModuleDetils(ModuleResponseEntity moduleEntity) {
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_MODULE_DETILS,
      arguments: {
        "moduleId": moduleEntity.uid,
        "moduleName": moduleEntity.name,
        "language": moduleEntity.language,
      },
    );
  }

  /// 排序
  void toSort(BuildContext context) {
    SortDialog.show(
      context: context,
      basisList: sortList,
      init: staticDataEntity,
      onSort: (data) {
        staticDataEntity = data;
        onRefresh();
      },
    );
  }

  /// 更新模块信息（名称或描述）
  void onEditModule(ModuleResponseEntity module, {String? newName, String? newDescription}) async {
    try {
      final Map<String, dynamic> data = {};

      if (newName != null && newName.trim().isNotEmpty) {
        if (newName.trim() != module.name?.trim()) {
          data["name"] = newName.trim();
        }
      }

      if (newDescription != null && newDescription.trim().isNotEmpty) {
        if (newDescription.trim() != module.description?.trim()) {
          data["description"] = newDescription.trim();
        }
      }

      if (data.isEmpty) {
        return;
      }

      final response = await ModuleUtil.edit(
          uid: module.uid.toString(),
          config: RequestConfig(requireToken: true, data: data, cancelToken: cancelToken));

      if (response.data != null) {
        onRefresh();
      } else {
        ToastUtils.showManageToast(text: response.message ?? "更新失败", type: ManageToastType.error);
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "更新失败", type: ManageToastType.error);
    }
  }
}
