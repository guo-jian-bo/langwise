import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/common/https/membership_card_manage.dart';
import 'package:langwise/common/widgets/date_time_picker_widget.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../models/membership_card_manage_agent_dashboard_model.dart';

enum MembershipCardManageAgentDashboardDatePreset {
  currentMonth,
  lastMonth,
  custom,
}

class MembershipCardManageAgentDashboardController extends GetxController
    with RoutesBreadcrumbMixin {
  final String tagText;
  MembershipCardManageAgentDashboardController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.MEMBERSHIP_CARD_MANAGE_AGENT_DASHBOARD;

  @override
  String get breadcrumbTitle => '代理商数据看板';

  static const int pageLimit = 20;

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  final RxBool isLoading = false.obs;
  final Rx<MembershipCardManageAgentDashboardEntity> dashboardEntity =
      const MembershipCardManageAgentDashboardEntity().obs;
  final RxList<MembershipCardManageAgentDashboardItemModel> detailList =
      <MembershipCardManageAgentDashboardItemModel>[].obs;
  final Rx<MembershipCardManageAgentDashboardDatePreset> currentPreset =
      MembershipCardManageAgentDashboardDatePreset.currentMonth.obs;
  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();

  int offset = 0;
  final int limit = pageLimit;
  bool isRequesting = false;
  bool _hasMore = true;
  int? totalCount;

  bool get hasMore => _hasMore;

  String get startDateText => _formatDate(startDate.value);
  String get endDateText => _formatDate(endDate.value);

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    _setCurrentMonthRange();
    _setupScrollListener();
    onRefresh();
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
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
      if (position.pixels >= position.maxScrollExtent * 0.9 &&
          hasMore &&
          !isRequesting) {
        onLoadMore();
      }
    });
  }

  Future<void> onRefresh() async {
    if (isRequesting) {
      return;
    }
    offset = 0;
    _hasMore = true;
    await _fetchDashboard(resetList: true, offset: 0);
  }

  Future<void> onLoadMore() async {
    if (isRequesting || !hasMore) {
      return;
    }
    await _fetchDashboard(resetList: false, offset: offset + limit);
  }

  Future<void> onSearch() async {
    await onRefresh();
  }

  void onClearSearch() {
    if (searchController.text.isEmpty) {
      return;
    }
    searchController.clear();
    onRefresh();
  }

  Future<void> selectCurrentMonth() async {
    _setCurrentMonthRange();
    currentPreset.value = MembershipCardManageAgentDashboardDatePreset.currentMonth;
    await onRefresh();
  }

  Future<void> selectLastMonth() async {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(currentMonthStart.year, currentMonthStart.month - 1, 1);
    final lastMonthEnd = DateTime(currentMonthStart.year, currentMonthStart.month, 1)
        .subtract(const Duration(seconds: 1));
    startDate.value = _startOfDay(lastMonthStart);
    endDate.value = _endOfDay(lastMonthEnd);
    currentPreset.value = MembershipCardManageAgentDashboardDatePreset.lastMonth;
    await onRefresh();
  }

  Future<void> filterTime(BuildContext context) async {
    DateTimePickerUtils.showStartEndCalender(
      context: context,
      minDate: DateTime(2024, 1, 1),
      maxDate: DateTime.now(),
      initialStartDate: startDate.value,
      initialEndDate: endDate.value,
      onTap: (start, end) async {
        startDate.value = _startOfDay(start);
        endDate.value = _endOfDay(end);
        _syncPresetState();
        await onRefresh();
      },
    );
  }

  Future<void> clearFilterTime() async {
    _setCurrentMonthRange();
    currentPreset.value = MembershipCardManageAgentDashboardDatePreset.currentMonth;
    await onRefresh();
  }

  Future<void> _fetchDashboard({
    required bool resetList,
    required int offset,
  }) async {
    try {
      isRequesting = true;
      isLoading.value = true;
      ToastUtils.showLoading();

      final entity = await MembershipCardManageApi.salesAgentDetailsList(
        parameters: {
          'offset': offset,
          'limit': limit,
        },
        data: _buildRequestBody(),
      );

      final nextEntity = entity ?? const MembershipCardManageAgentDashboardEntity();
      final list = nextEntity.salesAgentDetails;
      this.offset = offset;
      totalCount = nextEntity.count;
      dashboardEntity.value = nextEntity;

      if (resetList) {
        detailList.value = list;
      } else {
        detailList.addAll(list);
      }

      if (totalCount != null) {
        _hasMore = detailList.length < totalCount!;
      } else {
        _hasMore = list.length >= limit;
      }
    } finally {
      ToastUtils.hideLoading();
      isLoading.value = false;
      isRequesting = false;
    }
  }

  Map<String, dynamic> _buildRequestBody() {
    final Map<String, dynamic> body = {
      'startDate': _formatRequestDate(startDate.value ?? _defaultStartDate),
      'endDate': _formatRequestDate(endDate.value ?? _defaultEndDate),
    };

    final keyword = searchController.text.trim();
    if (keyword.isNotEmpty) {
      // Single search box: if keyword is numeric, treat as salesAgentId; otherwise salesAgentName.
      if (int.tryParse(keyword) != null) {
        body['salesAgentId'] = keyword;
      } else {
        body['salesAgentName'] = keyword;
      }
    }
    return body;
  }

  void _setCurrentMonthRange() {
    final now = DateTime.now();
    startDate.value = DateTime(now.year, now.month, 1, 0, 0, 0);
    endDate.value = now;
  }

  DateTime _startOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day, 0, 0, 0);
  }

  DateTime _endOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day, 23, 59, 59);
  }

  String _formatRequestDate(DateTime value) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(value);
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '';
    }
    return DateFormat('yyyy-MM-dd').format(value);
  }

  DateTime get _defaultStartDate => DateTime.now();

  DateTime get _defaultEndDate => DateTime.now();

  void _syncPresetState() {
    final start = startDate.value;
    final end = endDate.value;
    if (start == null || end == null) {
      currentPreset.value = MembershipCardManageAgentDashboardDatePreset.custom;
      return;
    }

    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1, 0, 0, 0);
    final currentMonthEnd = now;
    final lastMonthStart = DateTime(now.year, now.month - 1, 1, 0, 0, 0);
    final lastMonthEnd =
        DateTime(now.year, now.month, 1, 0, 0, 0).subtract(const Duration(seconds: 1));

    if (_isSameMoment(start, currentMonthStart) &&
        _isSameMoment(end, currentMonthEnd)) {
      currentPreset.value = MembershipCardManageAgentDashboardDatePreset.currentMonth;
      return;
    }

    if (_isSameMoment(start, lastMonthStart) &&
        _isSameMoment(end, lastMonthEnd)) {
      currentPreset.value = MembershipCardManageAgentDashboardDatePreset.lastMonth;
      return;
    }

    currentPreset.value = MembershipCardManageAgentDashboardDatePreset.custom;
  }

  bool _isSameMoment(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute &&
        a.second == b.second;
  }
}
