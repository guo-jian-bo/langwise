import 'package:api/entities/entities.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/widgets/widgets.dart';

import '../../../../../routes/routes.dart';
import '../../../dialog/manage_create_unit/view.dart';
import '../../../dialog/manage_edit_unit/view.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';

class ManageUnitController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageUnitController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_UNIT;

  @override
  String get breadcrumbTitle => '单元管理';

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
    update(["manage_unit"]);
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
  Future<DesertsFakeWebServiceResponse<NewUnitResponseEntity>> onFetchPages(
      int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData) async {
    try {
      String? order;
      if (staticDataEntity?.sort != null && staticDataEntity?.basis != null) {
        order = "${staticDataEntity?.sort?.value ?? ''}${staticDataEntity?.basis?.value ?? ''}";
      }

      order ??= "-created";

      final response = await UnitUtil.fetchPages(
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
        return DesertsFakeWebServiceResponse<NewUnitResponseEntity>(0, []);
      }
      final List<NewUnitResponseEntity> entities = <NewUnitResponseEntity>[];
      entities.addAll(response.data?.datas ?? []);
      return DesertsFakeWebServiceResponse<NewUnitResponseEntity>(response.data!.count!, entities);
    } catch (e) {
      return DesertsFakeWebServiceResponse<NewUnitResponseEntity>(0, []);
    }
  }

  /// 筛选
  void showFilter(BuildContext context) {
    // TODO: 实现筛选功能
  }

  // 添加
  void add() {
    ManageCreateUnitManager.show(context: Get.context!)?.then((value) {
      if (value != null && value) {
        onRefresh();
      }
    });
  }

  // 编辑
  void onEdit(NewUnitResponseEntity model) {
    ManageEditUnitDialog.show(context: Get.context!, unitEntity: model)?.then((value) {
      if (value != null) {
        onRefresh();
      }
    });
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

  /// 跳转到模块详情
  void toModuleDetils(NewUnitResponseEntity unitEntity) {
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_MODULE_DETILS,
      arguments: {
        "unitUid": unitEntity.uid,
        "language": unitEntity.language,
        "isFromUnit": true,
      },
    );
  }
}
