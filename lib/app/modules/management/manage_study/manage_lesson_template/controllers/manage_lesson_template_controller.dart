import 'package:api/entities/entities.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../routes/routes.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';
import '../manage_lesson_template_filter.dart';

class ManageLessonTemplateController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageLessonTemplateController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_LESSON_TEMPLATE;

  @override
  String get breadcrumbTitle => '课时模板';

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

  /// 筛选- 语言/上架状态/考核方向
  ManageLessonTemplateFilterResult? filterResult;

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
    update(["manage_lesson_template"]);
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
  Future<DesertsFakeWebServiceResponse<LessonTemplateResponseEntity>> onFetchPages(
      int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData) async {
    try {
      String? order, access;
      List<String> language = [], purpose = [], types = [];
      if (staticDataEntity?.sort != null && staticDataEntity?.basis != null) {
        order = "${staticDataEntity?.sort?.value ?? ''}${staticDataEntity?.basis?.value ?? ''}";
      }

      if ((filterResult?.launguageList ?? []).isNotEmpty) {
        language = filterResult!.launguageList!.map((e) => e.value).toList();
      }

      if (filterResult?.offShelf?.value != null) {
        access = filterResult?.offShelf?.value;
      }

      if ((filterResult?.assessmentDirectionList ?? []).isNotEmpty) {
        purpose = filterResult!.assessmentDirectionList!.map((e) => e.value).toList();
      }

      if ((filterResult?.lessonTypes ?? []).isNotEmpty) {
        types = filterResult!.lessonTypes!.map((e) => e.value).toList();
      }

      order = order ?? "-created";

      Map<String, dynamic> reqData = {
        "uid": uids.isEmpty ? null : uids,
        "name": title,
        "description": des,
        "language": language.isEmpty ? null : language,
        "purpose": purpose.isEmpty ? null : purpose,
      };
      if (access != null) {
        reqData["access"] = [access];
      }
      if (types.isNotEmpty) {
        reqData["types"] = types;
      }

      final response = await LessonTemplateUtil.fetchPages(
          config: RequestConfig(parameters: {
        'offset': startingAt,
        'limit': count,
        "order": order
      }, data: reqData, requireToken: true, cancelToken: cancelToken));
      if (!(response.data?.hasData ?? false)) {
        return DesertsFakeWebServiceResponse<LessonTemplateResponseEntity>(0, []);
      }

      return DesertsFakeWebServiceResponse<LessonTemplateResponseEntity>(
          response.data!.count!, (response.data?.datas ?? []));
    } catch (e) {
      return DesertsFakeWebServiceResponse<LessonTemplateResponseEntity>(0, []);
    }
  }

  /// 筛选
  void showFilter(BuildContext context) {
    ManageLessonTemplateFilter.show(
      context: context,
      initFilterResult: filterResult,
      onSure: (result) {
        filterResult = result;
        onRefresh();
      },
    );
  }

  // 添加
  void add(BuildContext context) async {
    final int? resUid = await AddLessonTemplateDialog.show(
      context: context,
      isEdit: false,
    );
    if (resUid == null) return;
    onRefresh();
    toManageLessonTemplate(resUid);
  }

  // 编辑
  Future<void> onEdit(BuildContext context, {LessonTemplateResponseEntity? data}) async {
    final int? resUid = await AddLessonTemplateDialog.show(
      context: context,
      isEdit: data != null,
      uid: data?.uid,
      templateName: data?.name,
      templateDesc: data?.description,
      languageValue: data?.language,
      assessmentDirectionValue: data?.direction,
      minDifficulty: data?.minDifficulty,
      maxDifficulty: data?.maxDifficulty,
      lessonTypeValue: data?.type,
    );
    if (resUid == null) return;
    onRefresh();
  }

  /// 更新课时模板信息（名称或描述）
  void onEditLessonTemplateInline(LessonTemplateResponseEntity template,
      {String? newName, String? newDescription}) async {
    try {
      final Map<String, dynamic> data = {};

      if (newName != null && newName.trim().isNotEmpty) {
        if (newName.trim() != template.name?.trim()) {
          data["name"] = newName.trim();
        }
      }

      if (newDescription != null && newDescription.trim().isNotEmpty) {
        if (newDescription.trim() != template.description?.trim()) {
          data["description"] = newDescription.trim();
        }
      }

      if (data.isEmpty) {
        return;
      }

      final res = await ManageLessonTemplateRequest.editLessonTemplate(data, template.uid);

      if (res != null && res.data != null) {
        onRefresh();
      } else {
        ToastUtils.showManageToast(text: res?.message ?? "更新失败");
      }
    } catch (e) {
      if (kDebugMode) {
        print('更新课时模板信息失败: $e');
      }
      ToastUtils.showManageToast(text: "更新失败");
    }
  }

  /// 跳转至管理模版页面
  void toManageLessonTemplate(int? uid) {
    if (uid == null) return;
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_LESSON_TEMPLATE_MANAGE,
      arguments: {
        "lessonTemplateUid": uid,
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

  /// 上架/下架
  void accessSong(context, LessonTemplateResponseEntity item) async {
    final askRes = await AskDialog.showUserAsk(
      context: context,
      content: "您确定要${item.access == 'NORMAL' ? '下架' : '上架'}此课时模版吗？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) {
      return;
    }

    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "access": item.access == 'NORMAL' ? 'INTERNAL' : 'NORMAL',
      };
      dynamic res = await ManageLessonTemplateRequest.editLessonTemplate(reqData, item.uid);
      if (res != null && res.data != null) {
        ToastUtils.showToast(text: item.access == 'NORMAL' ? '下架成功' : '上架成功', type: ToastType.success);
        onRefresh();
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }
}
