import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/widgets/filter_widgets.dart';

import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';
import '../../manage_inspection_statistics/models/manage_inspection_staff_model.dart';
import '../models/manage_inspection_operation_record_model.dart';

class ManageInspectionStatisticsRecordController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageInspectionStatisticsRecordController({required this.tag});

  late final ManageInspectionStaffModel staff;
  final RxString searchKeyword = ''.obs;

  final RxList<ManageInspectionOperationRecordModel> recordList = <ManageInspectionOperationRecordModel>[].obs;
  final RxMap<String, FilterConditionsData> filterConditions = {
    "category": FilterConditionsData(
      title: "类型",
      conditions: [
        FilterConditionsItem(name: "全部", value: null, selected: true),
        FilterConditionsItem(name: "学员数据", value: "member"),
        FilterConditionsItem(name: "领取", value: "receive"),
        FilterConditionsItem(name: "转交", value: "transfer"),
        FilterConditionsItem(name: "工单", value: "ticket"),
        FilterConditionsItem(name: "通知", value: "notify"),
        FilterConditionsItem(name: "查看", value: "view"),
      ],
    ),
  }.obs;
  final Map<String, FilterSearchsData> filterSearchs = {
    "keyword": FilterSearchsData(
      title: "搜索",
      hintText: "搜索标题 / 内容 / 用户 / ID / 手机号",
      controller: TextEditingController(),
    ),
  };

  @override
  String get breadcrumbRoute => Routes.MANAGE_INSPECTION_STATISTICS_RECORD;

  @override
  String get breadcrumbTitle => '巡检记录';

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    final args = (Get.arguments ?? {}) as Map;
    final s = args['staff'];
    if (s is! ManageInspectionStaffModel) {
      throw Exception('ManageInspectionStatisticsRecordController requires ManageInspectionStaffModel argument: staff');
    }
    staff = s;
    filterSearchs['keyword']?.controller.addListener(_syncSearchKeyword);
    refreshList();
  }

  List<ManageInspectionOperationRecordModel> get filteredRecordList {
    final selectedCategory = _selectedCategory;
    final keyword = searchKeyword.value.trim();
    return recordList.where((item) {
      final categoryOk = selectedCategory == null || item.category == selectedCategory;
      final keywordOk = keyword.isEmpty || _matchesKeyword(item, keyword);
      return categoryOk && keywordOk;
    }).toList();
  }

  Future<void> refreshList() async {
    final ListResponseEntity<ManageInspectionHistoryEntity>? res = await AccountConsoleRequest.getInspectionStaffLogPage(
      data: {
        'actorId': staff.userId,
      },
      params: {
        'offset': 0,
        'limit': 30,
      },
    );
    if (res == null) return;
    recordList.assignAll((res.datas ?? const <ManageInspectionHistoryEntity>[]).map(ManageInspectionOperationRecordModel.fromEntity).toList());
  }

  String? get _selectedCategory {
    final conditions = filterConditions['category']?.conditions ?? const <FilterConditionsItem>[];
    final selected = conditions.firstWhereOrNull((item) => item.selected);
    final value = selected?.value;
    return value is String ? value : null;
  }

  String get selectedCategoryLabel {
    final conditions = filterConditions['category']?.conditions ?? const <FilterConditionsItem>[];
    return conditions.firstWhereOrNull((item) => item.selected)?.name ?? '全部';
  }

  bool _matchesKeyword(ManageInspectionOperationRecordModel item, String keyword) {
    return item.tag.contains(keyword) ||
        item.title.contains(keyword) ||
        item.desc.contains(keyword) ||
        item.operator.name.contains(keyword) ||
        item.operator.id.contains(keyword) ||
        item.operator.phone.contains(keyword);
  }

  void onSearchChanged(String value) {
    searchKeyword.value = value;
  }

  void onSelectCategory(String name) {
    final conditions = filterConditions['category']?.conditions;
    if (conditions == null) return;
    for (final item in conditions) {
      item.selected = item.name == name;
    }
    filterConditions.refresh();
  }

  void _syncSearchKeyword() {
    searchKeyword.value = filterSearchs['keyword']?.controller.text.trim() ?? '';
  }

  @override
  void onClose() {
    filterSearchs['keyword']?.controller.removeListener(_syncSearchKeyword);
    filterSearchs['keyword']?.controller.dispose();
    super.onClose();
  }
}
