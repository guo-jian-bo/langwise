import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/membership_card_manage.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../models/membership_card_manage_rebate_record_model.dart';

class MembershipCardManageRebateRecordController extends GetxController {
  static const int pageLimit = 20;

  final ScrollController scrollController = ScrollController();

  final RxList<MembershipCardManageRebateRecordModel> recordList =
      <MembershipCardManageRebateRecordModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt totalCount = 0.obs;

  int offset = 0;
  final int limit = pageLimit;
  bool isRequesting = false;

  bool get hasMore => recordList.length < totalCount.value;

  @override
  void onInit() {
    super.onInit();
    _setupScrollListener();
    onRefresh();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

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

  Future<void> onRefresh() async {
    if (isRequesting) {
      return;
    }
    offset = 0;
    await _fetchRecordList(resetList: true, offset: offset, limit: limit);
  }

  Future<void> onLoadMore() async {
    if (isRequesting || !hasMore) {
      return;
    }
    await _fetchRecordList(
      resetList: false,
      offset: offset + limit,
      limit: limit,
    );
  }

  Future<void> _fetchRecordList({
    required bool resetList,
    required int offset,
    required int limit,
  }) async {
    try {
      isRequesting = true;
      isLoading.value = true;
      ToastUtils.showLoading();

      final entity = await MembershipCardManageApi.rebateRecordList(
        parameters: {
          'offset': offset,
          'limit': limit,
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
