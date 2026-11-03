import 'package:api/entities/entities.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../dialog/manage_create_level/view.dart';
import '../../../dialog/manage_edit_level/view.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';

class ManageLevelController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageLevelController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_LEVEL;

  @override
  String get breadcrumbTitle => '等级管理';

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
    update(["manage_level"]);
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
  Future<DesertsFakeWebServiceResponse<LevelResponseEntity>> onFetchPages(
      int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData) async {
    try {
      String? order;
      if (staticDataEntity?.sort != null && staticDataEntity?.basis != null) {
        order = "${staticDataEntity?.sort?.value ?? ''}${staticDataEntity?.basis?.value ?? ''}";
      }

      order ??= "-created";

      final response = await LevelUtil.fetchPages(
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
        return DesertsFakeWebServiceResponse<LevelResponseEntity>(0, []);
      }

      return DesertsFakeWebServiceResponse<LevelResponseEntity>(
          response.data!.count!, (response.data?.datas ?? []));
    } catch (e) {
      return DesertsFakeWebServiceResponse<LevelResponseEntity>(0, []);
    }
  }

  /// 筛选
  void showFilter(BuildContext context) {
    // TODO: 实现筛选功能
  }

  // 添加
  void add() {
    ManageCreateLevelManager.show(context: Get.context!)?.then((value) {
      if (value != null && value) {
        onRefresh();
      }
    });
  }

  // 编辑
  void onEdit(LevelResponseEntity model) {
    ManageEditLevel.show(context: Get.context!, levelEntity: model)?.then((value) {
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

  // 跳转课程详情
  void toAllCourseDetail(LevelResponseEntity entity) {
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_ALL_COURSES_DETILS,
      arguments: {
        "name": entity.name,
        "uid": entity.uid,
        "language": entity.language,
        "isFromLevel": true,
      },
    );
  }

  /// 更新级别信息（名称或描述）
  void onEditLevel(LevelResponseEntity level, {String? newName, String? newDescription}) async {
    try {
      final Map<String, dynamic> data = {};

      if (newName != null && newName.trim().isNotEmpty) {
        if (newName.trim() != level.name?.trim()) {
          data["name"] = newName.trim();
        }
      }

      if (newDescription != null && newDescription.trim().isNotEmpty) {
        if (newDescription.trim() != level.description?.trim()) {
          data["description"] = newDescription.trim();
        }
      }

      if (data.isEmpty) {
        return;
      }

      final response = await LevelUtil.edit(
          uid: level.uid.toString(),
          config: RequestConfig(requireToken: true, data: data, cancelToken: cancelToken));

      if (response.data != null) {
        onRefresh();
      } else {
        ToastUtils.showManageToast(text: response.message ?? "更新失败");
      }
    } catch (e) {
      if (kDebugMode) {
        print('更新级别信息失败: $e');
      }
      ToastUtils.showManageToast(text: "更新失败");
    }
  }
}
