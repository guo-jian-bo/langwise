import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/enum/access_enum.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/widgets/filter_widgets.dart';

import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';
import '../models/manage_inspection_staff_model.dart';

class ManageInspectionStatisticsController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageInspectionStatisticsController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_INSPECTION_STATISTICS;

  @override
  String get breadcrumbTitle => '巡检统计';

  final RxString searchKeyword = ''.obs;

  final RxInt onDutyCount = 0.obs;
  final RxInt receivedStudentsCount = 0.obs;
  final RxInt todayOperationsCount = 0.obs;
  final RxInt notificationsCount = 0.obs;
  final RxInt ticketCount = 0.obs;

  final RxList<ManageInspectionStaffModel> staffList = <ManageInspectionStaffModel>[].obs;
  final RxList<String> roleOptions = <String>[].obs;

  List<ManageInspectionStaffModel> get filteredStaffList {
    final selectedAccess = _selectedAccess;
    final selectedRole = _selectedRole;
    final keyword = searchKeyword.value.trim();

    return staffList.where((e) {
      final bool accessOk = selectedAccess == null || e.access == selectedAccess;
      final bool roleOk = selectedRole == null || e.roleNames.contains(selectedRole);
      final bool keywordOk = keyword.isEmpty || _matchesKeyword(e, keyword);
      return accessOk && roleOk && keywordOk;
    }).toList();
  }

  final RxMap<String, FilterConditionsData> filterConditions = {
    "access": FilterConditionsData(
      title: "状态",
      conditions: [
        FilterConditionsItem(name: "全部", value: null, selected: true),
        FilterConditionsItem(name: "已启用", value: AccessEnum.NORMAL.value),
        FilterConditionsItem(name: "已停用", value: AccessEnum.INTERNAL.value),
      ],
    ),
    "role": FilterConditionsData(
      title: "岗位",
      conditions: [
        FilterConditionsItem(name: "全部", value: null, selected: true),
      ],
    ),
  }.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "content": FilterSearchsData(
      title: "搜索",
      hintText: "搜索姓名 / 学员 / 岗位",
      controller: TextEditingController(),
    ),
  };


  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    filterSearchs['content']?.controller.addListener(_syncSearchKeyword);
    loadRoleOptions();
    refreshList();
  }

  Future<void> loadRoleOptions() async {
    final ListResponseEntity<RoleDtoEntity>? res = await AccountConsoleRequest.getRolePages(
      data: const {
        "groupType": "assistant",
      },
      params: const {
        "offset": 0,
        "limit": 100,
      },
    );
    if (res == null) return;

    roleOptions.value = (res.datas ?? const <RoleDtoEntity>[])
        .where((item) => (item.name ?? '').trim().isNotEmpty)
        .map((item) => item.name!.trim())
        .toSet()
        .toList();
    _syncRoleFilterConditions();
  }

  Future<void> refreshList() async {
    final res = await AccountConsoleRequest.getInspectionStaffAccountPage(
      data: {
        'offset': 0,
        'limit': 30,
      },
    );
    if (res == null) return;

    final summary = res.summary!;
    onDutyCount.value = summary.staffCount!;
    receivedStudentsCount.value = summary.receivedUserCount!;
    todayOperationsCount.value = summary.todayOperationCount!;
    notificationsCount.value = summary.notifySendCount!;
    ticketCount.value = summary.ticketHandleCount!;

    final list = res.page!.datas!;
    staffList.assignAll(list.map(ManageInspectionStaffModel.fromEntity).toList());
  }

  bool _matchesKeyword(ManageInspectionStaffModel item, String keyword) {
    return item.name.contains(keyword) ||
        item.id.contains(keyword) ||
        item.role.contains(keyword) ||
        item.roleNames.any((role) => role.contains(keyword)) ||
        item.tags.any((tag) => tag.contains(keyword));
  }

  String? get _selectedAccess {
    final conditions = filterConditions['access']?.conditions ?? const <FilterConditionsItem>[];
    final selected = conditions.firstWhereOrNull((item) => item.selected);
    final value = selected?.value;
    return value is String ? value : null;
  }

  String? get _selectedRole {
    final conditions = filterConditions['role']?.conditions ?? const <FilterConditionsItem>[];
    final selected = conditions.firstWhereOrNull((item) => item.selected);
    final value = selected?.value;
    return value is String ? value : null;
  }

  @override
  void onClose() {
    filterSearchs['content']?.controller.removeListener(_syncSearchKeyword);
    filterSearchs['content']?.controller.dispose();
    super.onClose();
  }

  void checkRecord(ManageInspectionStaffModel staff) {
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_INSPECTION_STATISTICS_RECORD,
      arguments: {
        'staff': staff,
      },
    );
  }

  void onSearchChanged(String value) {
    searchKeyword.value = value;
  }

  void _syncSearchKeyword() {
    searchKeyword.value = filterSearchs['content']?.controller.text ?? '';
  }

  void _syncRoleFilterConditions() {
    final String? selectedRole = _selectedRole;
    final List<String> roles = roleOptions.toList();
    final bool keepSelected = selectedRole != null && roles.contains(selectedRole);
    filterConditions['role'] = FilterConditionsData(
      title: "岗位",
      conditions: [
        FilterConditionsItem(name: "全部", value: null, selected: !keepSelected),
        ...roles.map((role) => FilterConditionsItem(
              name: role,
              value: role,
              selected: keepSelected && selectedRole == role,
            )),
      ],
    );
    filterConditions.refresh();
  }
}
