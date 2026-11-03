import 'package:api/entities/entities.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../routes/routes.dart';
import '../../../dialog/manage_edit_lesson/view.dart';
import '../../../utils/manage_breadcrumb_utils.dart';

class ManageLessonController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageLessonController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_LESSON;

  @override
  String get breadcrumbTitle => '课时管理';

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

  final GlobalKey dialogKey = GlobalKey();

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
    update(["manage_lesson"]);
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
  Future<DesertsFakeWebServiceResponse<LessonResponseEntity>> onFetchPages(
      int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData) async {
    try {
      String? order;
      if (staticDataEntity?.sort != null && staticDataEntity?.basis != null) {
        order = "${staticDataEntity?.sort?.value ?? ''}${staticDataEntity?.basis?.value ?? ''}";
      }

      order ??= "-created";

      final response = await LessonUtil.fetchPages(
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
        return DesertsFakeWebServiceResponse<LessonResponseEntity>(0, []);
      }
      return DesertsFakeWebServiceResponse<LessonResponseEntity>(
        response.data!.count!,
        (response.data?.datas ?? []),
      );
    } catch (e) {
      return DesertsFakeWebServiceResponse<LessonResponseEntity>(0, []);
    }
  }

  // 编辑课时
  void toEditLesson(LessonResponseEntity model) {
    ManageEditLesson.show(context: Get.context!, lessonEntity: model)?.then((value) {
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

  /// 更新lesson描述
  void onEditLesson(LessonResponseEntity lesson, String newDescription) async {
    try {
      if (newDescription.trim().isEmpty) {
        return;
      }

      if (newDescription.trim() == lesson.description?.trim()) {
        return;
      }

      final response = await LessonUtil.edit(
          config: RequestConfig(data: {
            'description': newDescription.trim(),
          }, requireToken: true, cancelToken: cancelToken),
          uid: lesson.uid.toString());
      if (response.data != null) {
        onRefresh();
      } else {
        ToastUtils.showManageToast(text: response.message ?? "更新失败", containerKey: dialogKey);
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "更新失败", containerKey: dialogKey);
    }
  }
}
