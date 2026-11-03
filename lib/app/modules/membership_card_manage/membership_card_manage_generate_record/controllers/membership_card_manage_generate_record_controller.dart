import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/common/https/membership_card_manage.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../models/membership_card_manage_generate_record_model.dart';

class MembershipCardManageGenerateRecordController extends GetxController
    with RoutesBreadcrumbMixin {
  final String tagText;
  MembershipCardManageGenerateRecordController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.MEMBERSHIP_CARD_MANAGE_GENERATE_RECORD;

  @override
  String get breadcrumbTitle => '建卡记录';

  static const int pageLimit = 20;

  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final RxList<MembershipCardManageGenerateRecordModel> recordList =
      <MembershipCardManageGenerateRecordModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt totalCount = 0.obs;

  int offset = 0;
  final int limit = pageLimit;
  bool isRequesting = false;

  bool get hasMore => recordList.length < totalCount.value;

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (!scrollController.hasClients) {
        return;
      }
      final position = scrollController.position;
      if (position.maxScrollExtent <= 0) {
        return;
      }
      final shouldLoadMore =
          position.pixels >= position.maxScrollExtent * 0.9;
      if (shouldLoadMore && hasMore && !isRequesting) {
        onLoadMore();
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    _setupScrollListener();
    onRefresh();
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> onRefresh() async {
    if (isRequesting) {
      return;
    }
    _resetPaging();
    final keyword = searchController.text.trim();
    await _fetchRecordList(
      resetList: true,
      offset: offset,
      limit: limit,
      keyword: keyword.isEmpty ? null : keyword,
    );
  }

  Future<void> onSearch() async {
    await onRefresh();
  }

  Future<void> onClearSearch() async {
    if (searchController.text.isEmpty) {
      return;
    }
    searchController.clear();
    await onRefresh();
  }

  Future<void> onLoadMore() async {
    if (isRequesting) {
      return;
    }
    if (!hasMore) {
      return;
    }
    final keyword = searchController.text.trim();
    await _fetchRecordList(
      resetList: false,
      offset: offset + limit,
      limit: limit,
      keyword: keyword.isEmpty ? null : keyword,
    );
  }

  void _resetPaging() {
    offset = 0;
  }

  Future<void> _fetchRecordList({
    required bool resetList,
    required int offset,
    required int limit,
    String? keyword,
  }) async {
    try {
      isRequesting = true;
      isLoading.value = true;
      ToastUtils.showLoading();

      final entity = await MembershipCardManageApi.generateRecordList(
        parameters: {
          'offset': offset,
          'limit': limit,
        },
        data: {
          if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
        },
      );
      this.offset = offset;
      totalCount.value = entity?.count ?? 0;
      final list = entity?.list ?? [];
      if (resetList) {
        recordList.value = list;
      } else {
        recordList.addAll(list);
      }
    } finally {
      ToastUtils.hideLoading();
      isLoading.value = false;
      isRequesting = false;
    }
  }
}
