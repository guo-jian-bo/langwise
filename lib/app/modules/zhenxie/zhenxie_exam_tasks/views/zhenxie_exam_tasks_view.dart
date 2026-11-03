import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/values/app_font_value.dart';
import 'package:langwise/common/widgets/filter_widgets.dart';
import 'package:langwise/common/widgets/not_data_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../zhenxie_exam/models/zhenxie_exam_models.dart';
import '../bindings/zhenxie_exam_tasks_binding.dart';
import '../controllers/zhenxie_exam_tasks_controller.dart';
import 'zhenxie_exam_task_card_widget.dart';

class ZhenxieExamTaskListView extends GetView<ZhenxieExamTaskListController> {
  final String tagText;
  const ZhenxieExamTaskListView({super.key, required this.tagText});

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieExamTaskListView(tagText: tag),
      binding: ZhenxieExamTaskListBinding(tagText: tag),
      routeName: Routes.ZHENXIE_EXAM_TASKS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    controller;
    return Obx(() {
      return Scaffold(
        backgroundColor: AppTheme.cBgPrimary.color,
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.wMin, 0, 24.wMin, 12.wMin),
            child: _buildBottomNavigationBar(context),
          ),
        ),
        body: Column(
          children: <Widget>[
            BreadcrumbWidget(actionWidget: _buildBreadcrumbActionWidget()),
            Expanded(
              child: _buildBodyWidget(),
            ),
          ],
        ),
      );
    });
  }

  /// 面包屑右侧显示当前筛选结果的年份跨度和题量。
  Widget _buildBreadcrumbActionWidget() {
    final String metaText = controller.buildBreadcrumbMetaText();
    if (metaText.isEmpty) return const SizedBox.shrink();
    return Text(
      metaText,
      style: TextStyle(
        fontSize: 16.wMin,
        fontWeight: FontWeight.w400,
        color: AppTheme.cZhenxieFontSecondary.color,
        fontFamily: AppFontValue.robotoMono,
      ),
    );
  }

  /// 列表主体：首屏加载、空态和两列真题网格都在这里切换。
  Widget _buildBodyWidget() {
    if (controller.isLoading.value && controller.taskList.isEmpty) {
      return const Center();
    }
    if (controller.isNotData.value) {
      return NotDataWidget(
        other: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '没有找到相关真题',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cZhenxieFontPrimary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
            SizedBox(height: 8.wMin),
            Text(
              '调整筛选条件后再试一次',
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontSecondary.color,
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => controller.refreshList(showLoading: false),
      child: GridView.builder(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(24.wMin, 12.wMin, 24.wMin, 24.wMin),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.wMin,
          mainAxisSpacing: 16.wMin,
          mainAxisExtent: 250.wMin,
        ),
        itemCount: controller.taskList.length,
        itemBuilder: (_, index) {
          final ZhenxieExamTaskCardData task = controller.taskList[index];
          return ZhenxieExamTaskCardWidget(
            task: task,
            milestoneColors: controller.findMilestoneThemeColors(task.milestone),
            familyColors: controller.findFamilyThemeColors(task.family.code),
            regionText: controller.buildRegionText(task),
            familyText: controller.buildFamilyText(task),
            milestoneText: controller.buildMilestoneText(task),
            stageText: controller.buildStageText(task),
            topicTexts: controller.buildTopicTexts(task).take(2).toList(),
            requiredPoints: controller.buildVisibleRequiredPoints(task),
            onTap: () {
              controller.openTaskDetail(task.uid);
            },
          );
        },
      ),
    );
  }

  /// 底部通用筛选条：直接复用 `FilterStripWidget`。
  Widget _buildBottomNavigationBar(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return FilterStripWidget(
          width: constraints.maxWidth,
          startText: controller.buildFilterSummaryText(),
          sorts: _buildFilterSorts(),
          conditions: _buildFilterConditions(),
          searchs: _buildFilterSearchs(),
          onSorts: (sorts) {
            final String value = _resolveSelectedSortValue(sorts);
            if (value.isEmpty) return;
            controller.applySortSelection(value);
          },
          onConditions: (conditions) {
            controller.applyConditionSelections(_resolveSelectedConditions(conditions));
          },
          onSearch: controller.submitSearch,
          onReset: (_, __) {
            controller.resetAll();
          },
        );
      },
    );
  }

  Map<String, FilterSortsData> _buildFilterSorts() {
    final Map<String, FilterSortsData> result = <String, FilterSortsData>{};
    for (final ZhenxieExamTaskQueryMetaGroupData group in controller.buildOrderGroups()) {
      final String groupCode = group.groupCode.trim();
      if (groupCode.isEmpty || group.items.isEmpty) continue;
      result[groupCode] = FilterSortsData(
        title: group.groupName,
        sorts: group.items.where((item) => item.value.isNotEmpty).map((item) {
          final String itemLabel = controller.buildZhText(item.names);
          return FilterSortsItem(
            name: itemLabel.isNotEmpty ? itemLabel : item.name,
            selected: controller.isSortSelected(item.value),
            isDefault: item.defaultValue,
            direction: item.value.contains('_desc') ? FilterSortDirection.down : FilterSortDirection.up,
          );
        }).toList(),
      );
    }
    return result;
  }

  Map<String, FilterConditionsData> _buildFilterConditions() {
    final Map<String, FilterConditionsData> result = <String, FilterConditionsData>{};
    for (final ZhenxieExamTaskQueryMetaGroupData group in controller.buildFilterGroups()) {
      if (group.groupCode.isEmpty || group.items.isEmpty) continue;
      result[group.groupCode] = FilterConditionsData(
        title: group.groupName,
        isSingle: group.component == 'radio',
        component: group.component,
        filterGroup: group.filterGroup,
        radioGroup: group.radioGroup,
        conditions: group.items
            .map((item) => FilterConditionsItem(
                  name: _buildMetaItemLabel(item),
                  value: item.value,
                  selected: controller.isFilterSelected(group.groupCode, item.value),
                  disabled: item.disabled,
                ))
            .toList(),
      );
    }
    return result;
  }

  Map<String, FilterSearchsData> _buildFilterSearchs() {
    final String hintText = controller.buildCurrentSearchHintText();
    return <String, FilterSearchsData>{
      'content': FilterSearchsData(
        controller: controller.searchController,
        title: '搜索',
        hintText: hintText.isNotEmpty ? hintText : null,
      ),
    };
  }

  String _buildMetaItemLabel(ZhenxieExamTaskQueryMetaItemData item) {
    final String zhText = controller.buildZhText(item.names);
    return zhText.isNotEmpty ? zhText : item.name;
  }

  String _resolveSelectedSortValue(Map<String, FilterSortsData> sorts) {
    for (final ZhenxieExamTaskQueryMetaGroupData group in controller.buildOrderGroups()) {
      final FilterSortsData? data = sorts[group.groupCode];
      if (data == null) continue;
      final FilterSortsItem? selected = data.sorts.firstWhereOrNull((item) => item.selected);
      if (selected == null) continue;
      for (final ZhenxieExamTaskQueryMetaItemData item in group.items) {
        final String itemLabel = controller.buildZhText(item.names);
        if ((itemLabel.isNotEmpty ? itemLabel : item.name) == selected.name) return item.value;
      }
    }
    return '';
  }

  Map<String, List<String>> _resolveSelectedConditions(Map<String, FilterConditionsData> conditions) {
    final Map<String, List<String>> result = <String, List<String>>{};
    for (final MapEntry<String, FilterConditionsData> entry in conditions.entries) {
      final List<String> values = entry.value.conditions
          .where((item) => item.selected)
          .map((item) => item.value?.toString() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
      if (values.isEmpty) continue;
      result[entry.key] = values;
    }
    return result;
  }
}
