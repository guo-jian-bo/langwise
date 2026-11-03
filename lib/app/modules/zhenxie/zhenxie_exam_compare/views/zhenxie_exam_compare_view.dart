import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/values/app_font_value.dart';
import 'package:langwise/common/widgets/platform_backdrop_filter_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../bindings/zhenxie_exam_compare_binding.dart';
import '../controllers/zhenxie_exam_compare_controller.dart';
import '../../zhenxie_exam/models/zhenxie_exam_models.dart';
import 'widgets/zhenxie_ribbon_flow.dart';

class _ZxColors {
  static Color get inkColor => AppTheme.cZhenxieFontPrimary.color;
  static Color get boneColor => AppTheme.cZhenxieFontPrimary.color;
  static Color get goldColor => AppTheme.cZhenxieColorPrimary.color;
  static Color get lineColor => AppTheme.cZhenxieBorderPrimary.color;
  static Color get ink2Color => AppTheme.cZhenxieFontSecondary.color;
  static Color get ink3Color => AppTheme.cZhenxieFontTertiary.color;
}

class ZhenxieExamCompareView extends GetView<ZhenxieExamCompareController> {
  final String tagText;
  const ZhenxieExamCompareView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieExamCompareView(tagText: tag),
      binding: ZhenxieExamCompareBinding(tagText: tag),
      routeName: Routes.ZHENXIE_EXAM_COMPARE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    controller;
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.wMin, 0, 24.wMin, 12.wMin),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildModuleSwitchWidget(context),
            ],
          ),
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
  }

  Widget _buildBodyWidget() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center();
      }
      final ExamCompareModule module = controller.module.value;
      if (module == ExamCompareModule.genres || module == ExamCompareModule.topics) {
        return _FlowPanel(controller: controller);
      }
      if (module == ExamCompareModule.goals) {
        return _GoalPanel(controller: controller);
      }
      return _LadderPanel(controller: controller);
    });
  }

  Widget _buildBreadcrumbActionWidget() {
    return Obx(() {
      final String title = controller.buildCurrentTitle();
      final String description = controller.buildCurrentDescription();
      if (title.isEmpty && description.isEmpty) return const SizedBox.shrink();
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 520.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (title.isNotEmpty)
              Text(
                title,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 17.wMin,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFontValue.sourceHanSerifCN,
                  color: _ZxColors.inkColor,
                ),
              ),
            if (description.isNotEmpty) ...<Widget>[
              SizedBox(height: 4.wMin),
              Text(
                description,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 16.wMin,
                  height: 1.375,
                  fontWeight: FontWeight.w400,
                  color: _ZxColors.ink3Color,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildModuleSwitchWidget(BuildContext context) {
    return Obx(() {
      final List<ExamRegionFilterOption> options = controller.buildRegionFilterOptions();
      return ClipRRect(
        borderRadius: BorderRadius.circular(999.wMin),
        child: PlatformBackdropFilterWidget(
          sigmaX: 4.wMin,
          sigmaY: 4.wMin,
          child: Container(
            constraints: BoxConstraints(minHeight: 56.wMin),
            padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceSearchBackground.color,
              borderRadius: BorderRadius.circular(999.wMin),
              border: Border.all(color: AppTheme.cBgTertiary.color, width: 1.wMin),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12.wMin,
              runSpacing: 8.wMin,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (final ExamCompareModule item in ExamCompareModule.values) _ModulePill(module: item, controller: controller),
                  ],
                ),
                if (options.isNotEmpty) ...<Widget>[
                  Container(
                    width: 1.wMin,
                    height: 28.wMin,
                    color: AppTheme.cZhenxieBorderPrimary.color,
                  ),
                  _RegionDock(
                    options: options,
                    onHelp: () => _showRegionSheetDialog(context),
                    onToggle: controller.toggleRegionValue,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<void> _showRegionSheetDialog(BuildContext context) async {
    final List<ExamRegionFilterSection> sections = controller.buildRegionFilterSections();
    if (sections.isEmpty) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final List<String> initialSelected = controller.selectedRegionNids.toList();
        final List<String> draft = initialSelected.toList();
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setState) {
            void toggleRegionNids(List<String> regionNids) {
              final Set<String> currentSet = draft.toSet();
              final bool allSelected = regionNids.isNotEmpty && regionNids.every(currentSet.contains);
              if (allSelected) {
                currentSet.removeAll(regionNids);
              } else {
                currentSet.addAll(regionNids);
              }
              final List<String> ordered = controller.buildAllRegionNids().where(currentSet.contains).toList();
              if (ordered.isEmpty) {
                ToastUtils.showToast(text: '请至少保留一个筛选项');
                return;
              }
              setState(() {
                draft
                  ..clear()
                  ..addAll(ordered);
              });
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(24.wMin),
              child: _RegionSheet(
                sections: sections,
                selected: draft,
                onToggleSection: toggleRegionNids,
                onToggleItem: (String nid) => toggleRegionNids(<String>[nid]),
                onCancel: () => Navigator.of(dialogContext).pop(),
                onConfirm: () async {
                  await controller.applyRegionSelection(draft);
                  if (context.mounted) Navigator.of(dialogContext).pop();
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _ModulePill extends StatelessWidget {
  final ExamCompareModule module;
  final ZhenxieExamCompareController controller;

  const _ModulePill({
    required this.module,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool active = controller.module.value == module;
      return GestureDetector(
        onTap: () => controller.switchModule(module),
        child: Container(
          height: 32.wMin,
          margin: EdgeInsets.only(right: 4.wMin),
          padding: EdgeInsets.symmetric(horizontal: 12.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            border: Border.all(
              color: active ? _ZxColors.goldColor.withValues(alpha: 0.7) : _ZxColors.lineColor,
              width: 1.wMin,
            ),
            color: active ? AppTheme.cZhenxieBackgroundPrimary.color : Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                module.title,
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: active ? _ZxColors.inkColor : _ZxColors.boneColor.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _FlowPanel extends StatelessWidget {
  final ZhenxieExamCompareController controller;

  const _FlowPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ZhenxieExamCompareData? data = controller.findCurrentCompareData();
      if (data == null) return const SizedBox.shrink();
      final String? activeId = controller.activeId;
      final String? selectedId = controller.selectedId.value;
      final ZhenxieExamCompareLegendData? picked =
          selectedId == null ? null : data.legends.firstWhereOrNull((item) => item.code == selectedId);
      final List<_FlowLegendGroup> groups = _buildLegendGroups(data);

      return Container(
        margin: EdgeInsets.fromLTRB(90.wMin, 0.wMin, 0, 12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.wMin),
          border: Border.all(color: AppTheme.cZhenxieBorderPrimary, width: 1.wMin),
          color: AppTheme.cZhenxieBackgroundPrimary,
        ),
        child: Row(
          children: <Widget>[
            _LegendSidebar(
              groups: groups,
              note: data.note,
              activeId: activeId,
              controller: controller,
              onHover: controller.hover,
              onSelect: controller.select,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24.wMin, 8.wMin, 24.wMin, 8.wMin),
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    final ZhenxieRibbonFlowHitLayout layout = ZhenxieRibbonFlowHitLayout(
                      data: data,
                      size: constraints.biggest,
                      colorBuilder: controller.buildLegendPrimaryColor,
                    );
                    final Rect? avoidRect = picked == null ? null : layout.buildAvoidRect(picked.code);
                    return Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: MouseRegion(
                            onExit: (_) => controller.hover(null),
                            onHover: (event) => controller.hover(layout.hitTestSeries(event.localPosition)),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapUp: (details) {
                                final String? id = layout.hitTestSeries(details.localPosition);
                                if (id != null) controller.select(id);
                              },
                              child: CustomPaint(
                                size: Size.infinite,
                                painter: ZhenxieRibbonFlowPainter(
                                  data: data,
                                  activeId: activeId,
                                  currentStage: controller.stage ?? '',
                                  colorBuilder: controller.buildLegendPrimaryColor,
                                  textBuilder: controller.buildZhText,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (picked != null && avoidRect != null)
                          Positioned.fill(
                            child: _FlowExplainCard(
                              legend: picked,
                              data: data,
                              currentStage: controller.stage ?? '',
                              controller: controller,
                              avoidRect: avoidRect,
                              onClose: () => controller.select(null),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  List<_FlowLegendGroup> _buildLegendGroups(ZhenxieExamCompareData data) {
    final int gaokaoIndex = data.columns.indexWhere((item) => item.stage == 'gaokao');
    final int rankIndex = gaokaoIndex >= 0 ? gaokaoIndex : math.max(0, data.columns.length - 1);
    final Map<String, _FlowLegendGroup> groupMap = <String, _FlowLegendGroup>{};
    for (final ZhenxieExamCompareLegendData item in data.legends) {
      final String groupId = item.groupCode.isNotEmpty ? item.groupCode : item.code;
      final String groupLabel = item.groupName.isNotEmpty ? controller.buildZhText(item.groupName) : '';
      groupMap
          .putIfAbsent(
            groupId,
            () => _FlowLegendGroup(id: groupId, label: groupLabel, items: <ZhenxieExamCompareLegendData>[]),
          )
          .items
          .add(item);
    }
    final List<_FlowLegendGroup> groups = groupMap.values.toList();
    for (final _FlowLegendGroup group in groups) {
      group.items.sort((a, b) => _compareFlowLegend(data, a, b, rankIndex));
    }
    groups.sort((a, b) {
      final bool aOther = a.id == 'other';
      final bool bOther = b.id == 'other';
      if (aOther != bOther) return aOther ? 1 : -1;
      final int aCount = a.items.fold<int>(0, (sum, item) => sum + _legendValue(data, item.code, rankIndex));
      final int bCount = b.items.fold<int>(0, (sum, item) => sum + _legendValue(data, item.code, rankIndex));
      return compareCountDesc(aCount, bCount, () => compareZh(a.label, b.label));
    });
    return groups;
  }

  int _compareFlowLegend(
    ZhenxieExamCompareData data,
    ZhenxieExamCompareLegendData a,
    ZhenxieExamCompareLegendData b,
    int column,
  ) {
    final bool aOther = a.code == 'other' || a.groupCode == 'other';
    final bool bOther = b.code == 'other' || b.groupCode == 'other';
    if (aOther != bOther) return aOther ? 1 : -1;
    return compareCountDesc(
      _legendValue(data, a.code, column),
      _legendValue(data, b.code, column),
      () => compareZh(controller.buildZhText(a.name), controller.buildZhText(b.name)),
    );
  }

  int _legendValue(ZhenxieExamCompareData data, String code, int column) {
    return data.columns[column].nodes.firstWhereOrNull((item) => item.code == code)?.value ?? 0;
  }
}

class _LegendSidebar extends StatelessWidget {
  final List<_FlowLegendGroup> groups;
  final String note;
  final String? activeId;
  final ZhenxieExamCompareController controller;
  final void Function(String?) onHover;
  final void Function(String?) onSelect;

  const _LegendSidebar({
    required this.groups,
    required this.note,
    required this.activeId,
    required this.controller,
    required this.onHover,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.wMin,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: _ZxColors.lineColor, width: 1.wMin)),
      ),
      padding: EdgeInsets.fromLTRB(16.wMin, 14.wMin, 16.wMin, 12.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final _FlowLegendGroup group in groups) ...<Widget>[
                    if (group.label.isNotEmpty && (group.items.length > 1 || controller.buildZhText(group.items.first.name) != group.label))
                      Padding(
                        padding: EdgeInsets.only(top: 12.wMin, bottom: 4.wMin),
                        child: Text(group.label, style: TextStyle(fontSize: 16.wMin, color: _ZxColors.ink3Color)),
                      ),
                    for (final ZhenxieExamCompareLegendData item in group.items)
                      _LegendItem(
                        legend: item,
                        active: activeId == item.code,
                        dim: activeId != null && activeId != item.code,
                        controller: controller,
                        onHover: onHover,
                        onSelect: onSelect,
                      ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 8.wMin),
          Text(note, style: TextStyle(fontSize: 16.wMin, height: 1.375, color: _ZxColors.ink3Color)),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final ZhenxieExamCompareLegendData legend;
  final bool active;
  final bool dim;
  final ZhenxieExamCompareController controller;
  final void Function(String?) onHover;
  final void Function(String?) onSelect;

  const _LegendItem({
    required this.legend,
    required this.active,
    required this.dim,
    required this.controller,
    required this.onHover,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHover(legend.code),
      onExit: (_) => onHover(null),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelect(legend.code),
        child: Opacity(
          opacity: dim ? 0.35 : 1,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.wMin, vertical: 4.wMin),
            child: Row(
              children: <Widget>[
                Container(
                  width: 10.wMin,
                  height: 10.wMin,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.wMin),
                    color: controller.buildLegendPrimaryColor(legend),
                  ),
                ),
                SizedBox(width: 8.wMin),
                Expanded(
                  child: Text(
                    controller.buildZhText(legend.name),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: active ? _ZxColors.inkColor : _ZxColors.boneColor.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FlowExplainCard extends StatelessWidget {
  final ZhenxieExamCompareLegendData legend;
  final ZhenxieExamCompareData data;
  final String currentStage;
  final ZhenxieExamCompareController controller;
  final Rect avoidRect;
  final VoidCallback onClose;

  const _FlowExplainCard({
    required this.legend,
    required this.data,
    required this.currentStage,
    required this.controller,
    required this.avoidRect,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSingleChildLayout(
      delegate: _ExplainCardLayoutDelegate(avoidRect: avoidRect, padding: 12.wMin),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 440.wMin,
          minWidth: 320.wMin,
          minHeight: 196.wMin,
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(24.wMin, 16.wMin, 24.wMin, 16.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.wMin),
            border: Border.all(color: AppTheme.cZhenxieBorderPrimary.color, width: 1.wMin),
            color: AppTheme.cBgPrimary.color.withValues(alpha: 0.95),
            boxShadow: <BoxShadow>[
              BoxShadow(color: Colors.black.withValues(alpha: 0.58), blurRadius: 56.wMin, offset: Offset(0, 18.wMin)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 12.wMin,
                    height: 12.wMin,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.wMin),
                      color: controller.buildLegendPrimaryColor(legend),
                    ),
                  ),
                  SizedBox(width: 10.wMin),
                  Expanded(
                      child: Text(
                        <String>[
                          controller.buildZhText(legend.groupName),
                          controller.buildZhText(legend.name),
                        ].where((item) => item.isNotEmpty).join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22.wMin,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFontValue.sourceHanSerifCN,
                          color: _ZxColors.inkColor,
                        ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.wMin),
              Row(
                children: <Widget>[
                  for (int i = 0; i < data.columns.length; i++)
                    Expanded(
                      child: _FlowExplainColumn(
                        column: data.columns[i],
                        label: controller.buildZhText(data.columns[i].name),
                        currentStage: currentStage,
                        count: _legendValue(i),
                        total: data.columns[i].taskCount,
                        prevShare: i == 0 ? null : _shareOf(_legendValue(i - 1), data.columns[i - 1].taskCount),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16.wMin),
              _ViewTasksButton(
                onTap: () => controller.openTasks(
                  controller.buildFlowTaskQuery(legend),
                  currentStage: currentStage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double? _shareOf(int value, int total) {
    if (total == 0) return null;
    return value / total;
  }

  int _legendValue(int index) {
    return data.columns[index].nodes.firstWhereOrNull((item) => item.code == legend.code)?.value ?? 0;
  }
}

class _FlowExplainColumn extends StatelessWidget {
  final ZhenxieExamCompareColumnData column;
  final String label;
  final String currentStage;
  final int count;
  final int total;
  final double? prevShare;

  const _FlowExplainColumn({
    required this.column,
    required this.label,
    required this.currentStage,
    required this.count,
    required this.total,
    required this.prevShare,
  });

  @override
  Widget build(BuildContext context) {
    final double? share = total == 0 ? null : count / total;
    final int? points = share == null || prevShare == null ? null : (share * 100).round() - (prevShare! * 100).round();
    final bool lit = column.stage == currentStage;
    final bool rising = (points ?? 0) > 0;
    return Column(
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 16.wMin,
            color: lit ? _ZxColors.goldColor : _ZxColors.boneColor.withValues(alpha: 0.55),
          ),
        ),
        SizedBox(height: 2.wMin),
        Text(
          share == null ? '—' : '${(share * 100).round()}%',
          style: TextStyle(
            fontSize: 26.wMin,
            fontWeight: FontWeight.w600,
            fontFamily: AppFontValue.robotoMono,
            color: _ZxColors.inkColor,
          ),
        ),
        SizedBox(height: 6.wMin),
        SizedBox(
          height: 20.wMin,
          child: points == null || points == 0
              ? const SizedBox.shrink()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      rising ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      size: 18.wMin,
                      color: rising ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceError.color,
                    ),
                    Text(
                      rising ? '+$points%' : '$points%',
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFontValue.robotoMono,
                        color: rising ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceError.color,
                      ),
                    ),
                  ],
                ),
        ),
        SizedBox(height: 4.wMin),
        Text(
          '$count 题',
          style: TextStyle(
            fontSize: 16.wMin,
            fontFamily: AppFontValue.robotoMono,
            color: _ZxColors.boneColor.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

class _RegionDock extends StatelessWidget {
  final List<ExamRegionFilterOption> options;
  final VoidCallback onHelp;
  final void Function(String value) onToggle;

  const _RegionDock({
    required this.options,
    required this.onHelp,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6.wMin,
      runSpacing: 6.wMin,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '卷别 / 地区',
              style: TextStyle(
                fontSize: 16.wMin,
                fontFamily: AppFontValue.sourceHanSerifCN,
                color: _ZxColors.boneColor.withValues(alpha: 0.45),
              ),
            ),
            SizedBox(width: 4.wMin),
            GestureDetector(
              onTap: onHelp,
              child: Container(
                width: 28.wMin,
                height: 28.wMin,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999.wMin),
                  border: Border.all(color: AppTheme.cZhenxieBorderPrimary.color, width: 1.wMin),
                  color: AppTheme.cZhenxieBackgroundPrimary.color,
                ),
                alignment: Alignment.center,
                child: Text(
                  '?',
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppFontValue.sourceHanSerifCN,
                    color: _ZxColors.boneColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ],
        ),
        for (final ExamRegionFilterOption item in options)
          _RegionChip(
            label: item.label,
            active: item.active,
            onTap: () => onToggle(item.value),
          ),
      ],
    );
  }
}

class _RegionChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _RegionChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          border: Border.all(
            color: active ? _ZxColors.goldColor.withValues(alpha: 0.55) : AppTheme.cZhenxieBorderPrimary.color,
            width: 1.wMin,
          ),
          color: active ? _ZxColors.goldColor.withValues(alpha: 0.16) : AppTheme.cBgPrimary.color.withValues(alpha: 0.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w500,
                color: active ? _ZxColors.inkColor : _ZxColors.boneColor.withValues(alpha: 0.28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionSheet extends StatelessWidget {
  final List<ExamRegionFilterSection> sections;
  final List<String> selected;
  final void Function(List<String> regionNids) onToggleSection;
  final void Function(String nid) onToggleItem;
  final VoidCallback onCancel;
  final Future<void> Function() onConfirm;

  const _RegionSheet({
    required this.sections,
    required this.selected,
    required this.onToggleSection,
    required this.onToggleItem,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 960.wMin),
      padding: EdgeInsets.fromLTRB(24.wMin, 18.wMin, 24.wMin, 20.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.wMin),
        border: Border.all(color: _ZxColors.lineColor, width: 1.wMin),
        color: AppTheme.cBgPrimary.color,
        boxShadow: <BoxShadow>[
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 90.wMin, offset: Offset(0, 28.wMin)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                '哪些省市考哪张卷',
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFontValue.sourceHanSerifCN,
                  color: _ZxColors.inkColor,
                ),
              ),
              SizedBox(width: 12.wMin),
              Expanded(
                child: Text(
                  '自主命题卷可按省市筛选；全国卷按卷别实时切换。',
                  style: TextStyle(fontSize: 16.wMin, color: _ZxColors.ink3Color),
                ),
              ),
              GestureDetector(
                onTap: onCancel,
                child: Container(
                  width: 36.wMin,
                  height: 36.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999.wMin),
                    border: Border.all(color: _ZxColors.lineColor, width: 1.wMin),
                  ),
                  child: Text(
                    '×',
                    style: TextStyle(fontSize: 18.wMin, color: _ZxColors.boneColor.withValues(alpha: 0.7)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.wMin),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (int i = 0; i < sections.length; i++) ...<Widget>[
                if (i > 0) SizedBox(width: 12.wMin),
                Expanded(
                  child: _RegionSheetSection(
                    section: sections[i],
                    selected: selected,
                    onToggleSection: onToggleSection,
                    onToggleItem: onToggleItem,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 20.wMin),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              GestureDetector(
                onTap: onCancel,
                child: Container(
                  height: 40.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 18.wMin),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999.wMin),
                    border: Border.all(color: _ZxColors.lineColor, width: 1.wMin),
                  ),
                  child: Text(
                    '取消',
                    style: TextStyle(fontSize: 16.wMin, fontWeight: FontWeight.w500, color: _ZxColors.ink3Color),
                  ),
                ),
              ),
              SizedBox(width: 12.wMin),
              GestureDetector(
                onTap: () async => await onConfirm(),
                child: Container(
                  height: 40.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 18.wMin),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999.wMin),
                    color: _ZxColors.goldColor.withValues(alpha: 0.16),
                    border: Border.all(color: _ZxColors.goldColor.withValues(alpha: 0.55), width: 1.wMin),
                  ),
                  child: Text(
                    '确认',
                    style: TextStyle(fontSize: 16.wMin, fontWeight: FontWeight.w600, color: _ZxColors.inkColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RegionSheetSection extends StatelessWidget {
  final ExamRegionFilterSection section;
  final List<String> selected;
  final void Function(List<String> regionNids) onToggleSection;
  final void Function(String nid) onToggleItem;

  const _RegionSheetSection({
    required this.section,
    required this.selected,
    required this.onToggleSection,
    required this.onToggleItem,
  });

  @override
  Widget build(BuildContext context) {
    final int selectedCount = section.regionNids.where(selected.contains).length;
    final bool paperSelected = selectedCount == section.regionNids.length && section.regionNids.isNotEmpty;
    final bool highlightSection = !section.allowProvinceSelection && paperSelected;
    final Widget content = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.wMin),
        border: Border.all(color: highlightSection ? _ZxColors.goldColor.withValues(alpha: 0.6) : _ZxColors.lineColor, width: 1.wMin),
        color:
            highlightSection ? AppTheme.cZhenxieBackgroundPrimary.color.withValues(alpha: 0.08) : AppTheme.cZhenxieBackgroundPrimary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(16.wMin, 12.wMin, 16.wMin, 12.wMin),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: _ZxColors.lineColor, width: 1.wMin)),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    section.paperName,
                    style: TextStyle(
                      fontSize: 17.wMin,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFontValue.sourceHanSerifCN,
                      color: _ZxColors.inkColor,
                    ),
                  ),
                ),
                Text('${section.provinces.length} 省市', style: TextStyle(fontSize: 16.wMin, color: _ZxColors.ink3Color)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12.wMin, 12.wMin, 12.wMin, 12.wMin),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: section.provinces.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _columnCount(section.provinces.length),
                mainAxisSpacing: 2.wMin,
                crossAxisSpacing: 8.wMin,
                mainAxisExtent: 34.wMin,
              ),
              itemBuilder: (_, index) {
                final ExamRegionFilterItem item = section.provinces[index];
                if (section.allowProvinceSelection) {
                  return _RegionSheetProvinceButton(
                    label: item.name,
                    active: selected.contains(item.nid),
                    onTap: () => onToggleItem(item.nid),
                  );
                }
                return _RegionSheetProvinceLabel(label: item.name, active: paperSelected);
              },
            ),
          ),
        ],
      ),
    );
    if (section.allowProvinceSelection) return content;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onToggleSection(section.regionNids),
      child: content,
    );
  }

  int _columnCount(int count) {
    if (count <= 3) return 1;
    if (count <= 12) return 2;
    return 3;
  }
}

class _RegionSheetProvinceButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _RegionSheetProvinceButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 6.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            border: active ? Border.all(color: _ZxColors.goldColor.withValues(alpha: 0.55), width: 1.wMin) : null,
            color: active ? _ZxColors.goldColor.withValues(alpha: 0.16) : null,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.wMin,
              color: active ? _ZxColors.inkColor : _ZxColors.boneColor.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegionSheetProvinceLabel extends StatelessWidget {
  final String label;
  final bool active;

  const _RegionSheetProvinceLabel({
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 16.wMin,
          color: active ? _ZxColors.inkColor : _ZxColors.boneColor.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

class _GoalPanel extends StatelessWidget {
  final ZhenxieExamCompareController controller;

  const _GoalPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ZhenxieExamGoalSankeyApiData? data = controller.goalSankeyData.value;
      if (data == null) return const SizedBox.shrink();
      final String? activeId = controller.activeId;
      final ZhenxieExamGoalSankeyNodeApiData? picked =
          controller.selectedId.value == null ? null : controller.findGoalNodeByCode(data, controller.selectedId.value!);
      final List<ZhenxieExamGoalSankeyNodeApiData> lineage =
          picked == null ? const <ZhenxieExamGoalSankeyNodeApiData>[] : controller.buildGoalLineage(picked.code, data);

      return Container(
        margin: EdgeInsets.fromLTRB(90.wMin, 0.wMin, 90.wMin, 12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.wMin),
          border: Border.all(color: AppTheme.cZhenxieBorderPrimary, width: 1.wMin),
          color: AppTheme.cZhenxieBackgroundPrimary,
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.wMin, 8.wMin, 20.wMin, 8.wMin),
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    final _GoalLayout layout = _GoalLayout.build(data, constraints.biggest, controller.stage ?? '', controller);
                    return Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _GoalLinkPainter(links: layout.links, activeId: activeId, pickedId: picked?.code),
                          ),
                        ),
                        Positioned.fill(
                          child: MouseRegion(
                            onExit: (_) => controller.hover(null),
                            onHover: (event) => controller.hover(layout.hitTestInteractiveId(event.localPosition)),
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTapUp: (details) => controller.select(layout.hitTestInteractiveId(details.localPosition)),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ),
                        ...layout.headers,
                        ...layout.nodeWidgets(
                          controller: controller,
                          activeId: activeId,
                          selectedId: picked?.code,
                          onHover: controller.hover,
                          onSelect: controller.select,
                        ),
                        if (picked != null)
                          Positioned.fill(
                            child: _GoalExplainCard(
                              controller: controller,
                              data: data,
                              node: picked,
                              lineage: lineage,
                              currentStage: controller.stage ?? '',
                              note: controller.buildGoalExplainNote(picked),
                              avoidRect: layout.buildAvoidRect(picked.code),
                              onClose: () => controller.select(null),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20.wMin, 10.wMin, 20.wMin, 10.wMin),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: _ZxColors.lineColor, width: 1.wMin)),
              ),
              child: Row(
                children: <Widget>[
                  for (int i = 0; i < data.legends.length; i++) ...<Widget>[
                    if (i > 0) SizedBox(width: 16.wMin),
                    _LegendDot(
                      color: controller.buildLegendPrimaryColor(data.legends[i]),
                      label: controller.buildZhText(data.legends[i].name),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    data.note,
                    style: TextStyle(fontSize: 16.wMin, color: _ZxColors.ink2Color),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _GoalExplainCard extends StatelessWidget {
  final ZhenxieExamCompareController controller;
  final ZhenxieExamGoalSankeyApiData data;
  final ZhenxieExamGoalSankeyNodeApiData node;
  final List<ZhenxieExamGoalSankeyNodeApiData> lineage;
  final String currentStage;
  final String note;
  final Rect avoidRect;
  final VoidCallback onClose;

  const _GoalExplainCard({
    required this.controller,
    required this.data,
    required this.node,
    required this.lineage,
    required this.currentStage,
    required this.note,
    required this.avoidRect,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSingleChildLayout(
      delegate: _ExplainCardLayoutDelegate(avoidRect: avoidRect, padding: 12.wMin),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 440.wMin,
          minWidth: 320.wMin,
          minHeight: 196.wMin,
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(24.wMin, 16.wMin, 24.wMin, 16.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.wMin),
            border: Border.all(color: AppTheme.cZhenxieBorderPrimary.color, width: 1.wMin),
            color: AppTheme.cBgPrimary.color.withValues(alpha: 0.95),
            boxShadow: <BoxShadow>[
              BoxShadow(color: Colors.black.withValues(alpha: 0.58), blurRadius: 56.wMin, offset: Offset(0, 18.wMin)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 12.wMin,
                    height: 12.wMin,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.wMin),
                      color: controller.buildGoalNodeColor(
                        controller.findGoalColumnByNodeCode(data, node.code)!,
                        node,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.wMin),
                  Expanded(
                    child: Text(
                      controller.buildGoalNodeName(node),
                      style: TextStyle(
                        fontSize: 22.wMin,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFontValue.sourceHanSerifCN,
                        color: _ZxColors.inkColor,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onClose,
                    child: Icon(Icons.close, size: 18.wMin, color: _ZxColors.ink3Color),
                  ),
                ],
              ),
              if (note.isNotEmpty) ...<Widget>[
                SizedBox(height: 6.wMin),
                Text(note, style: TextStyle(fontSize: 16.wMin, height: 1.375, color: _ZxColors.ink3Color)),
              ],
              SizedBox(height: 14.wMin),
              Builder(
                builder: (_) {
                  final List<int> counts = List<int>.generate(
                    data.columns.length,
                    (i) => lineage
                        .where((item) => controller.goalNodeColumnIndex(data, item.code) == i)
                        .fold<int>(0, (sum, item) => sum + item.value),
                  );
                  final List<int> totals = List<int>.generate(
                    data.columns.length,
                    (i) => data.columns[i].nodes.fold<int>(0, (sum, item) => sum + item.value),
                  );
                  return Row(
                    children: <Widget>[
                      for (int i = 0; i < data.columns.length; i++)
                        Expanded(
                          child: _GoalExplainColumn(
                            controller: controller,
                            column: data.columns[i],
                            currentStage: currentStage,
                            count: counts[i],
                            total: totals[i],
                            prevShare: i == 0
                                ? null
                                : counts[i - 1] == 0
                                    ? null
                                    : totals[i - 1] == 0
                                        ? 0
                                        : counts[i - 1] / totals[i - 1],
                          ),
                        ),
                    ],
                  );
                },
              ),
              SizedBox(height: 16.wMin),
              _ViewTasksButton(
                onTap: () => controller.openTasks(
                  controller.buildGoalTaskQuery(node),
                  currentStage: currentStage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalExplainColumn extends StatelessWidget {
  final ZhenxieExamCompareController controller;
  final ZhenxieExamGoalSankeyColumnApiData column;
  final String currentStage;
  final int count;
  final int total;
  final double? prevShare;

  const _GoalExplainColumn({
    required this.controller,
    required this.column,
    required this.currentStage,
    required this.count,
    required this.total,
    this.prevShare,
  });

  @override
  Widget build(BuildContext context) {
    final bool lit = column.stage == currentStage;
    final double? share = count == 0
        ? null
        : total == 0
            ? 0
            : count / total;
    final int? points = share == null || prevShare == null ? null : (share * 100).round() - (prevShare! * 100).round();
    final bool rising = (points ?? 0) > 0;
    return Column(
      children: <Widget>[
        Text(
          controller.buildZhText(column.name),
          style: TextStyle(
            fontSize: 16.wMin,
            color: lit ? _ZxColors.goldColor : _ZxColors.boneColor.withValues(alpha: 0.55),
          ),
        ),
        SizedBox(height: 2.wMin),
        Text(
          share == null ? '—' : '${(share * 100).round()}%',
          style: TextStyle(
            fontSize: 26.wMin,
            fontWeight: FontWeight.w600,
            fontFamily: AppFontValue.robotoMono,
            color: _ZxColors.inkColor,
          ),
        ),
        SizedBox(height: 6.wMin),
        SizedBox(
          height: 20.wMin,
          child: points == null || points == 0
              ? const SizedBox.shrink()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      rising ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      size: 18.wMin,
                      color: rising ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceError.color,
                    ),
                    Text(
                      rising ? '+$points%' : '$points%',
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFontValue.robotoMono,
                        color: rising ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceError.color,
                      ),
                    ),
                  ],
                ),
        ),
        if (share != null) ...<Widget>[
          SizedBox(height: 4.wMin),
          Text(
            '$count 题',
            style: TextStyle(
              fontSize: 16.wMin,
              fontFamily: AppFontValue.robotoMono,
              color: _ZxColors.boneColor.withValues(alpha: 0.45),
            ),
          ),
        ],
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 8.wMin,
          height: 8.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2.wMin),
            color: color,
          ),
        ),
        SizedBox(width: 6.wMin),
        Text(label, style: TextStyle(fontSize: 16.wMin, color: _ZxColors.ink3Color)),
      ],
    );
  }
}

class _ViewTasksButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ViewTasksButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 44.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999.wMin),
          border: Border.all(color: AppTheme.cZhenxieBorderPrimary.color, width: 1.wMin),
          color: AppTheme.cZhenxieFontPrimary,
        ),
        child: Text(
          '查看真题',
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w600,
            fontFamily: AppFontValue.sourceHanSerifCN,
            color: AppTheme.cBgPrimary,
          ),
        ),
      ),
    );
  }
}

class _LadderPanel extends StatelessWidget {
  final ZhenxieExamCompareController controller;

  const _LadderPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final LadderCompareData data = controller.buildLadderCompareData();
        return Container(
          margin: EdgeInsets.fromLTRB(90.wMin, 0.wMin, 0, 12.wMin),
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(14.wMin),
        //   border: Border.all(color: _ZxColors.lineColor, width: 1.wMin),
        //   color: Colors.white.withValues(alpha: 0.04),
        // ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: data.nodes.isEmpty
                  ? Center(
                      child: Text(
                        '还没有题挂上写作课阶',
                        style: TextStyle(fontSize: 16.wMin, color: _ZxColors.ink3Color),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.fromLTRB(20.wMin, 8.wMin, 20.wMin, 8.wMin),
                      child: LayoutBuilder(
                        builder: (_, constraints) {
                          return _LadderMap(
                            data: data,
                            scrollController: controller.ladderMapScrollController,
                            onTapNode: (node) => controller.openTasks(
                              ZhenxieExamTaskQuery(stageNid: node.stageNid),
                              currentStage: node.examStage,
                            ),
                          );
                        },
                      ),
                    ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20.wMin, 10.wMin, 20.wMin, 10.wMin),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: _ZxColors.lineColor, width: 1.wMin)),
              ),
              child: Row(
                children: <Widget>[
                  for (int i = 0; i < data.covered.length; i++) ...<Widget>[
                    if (i > 0) SizedBox(width: 20.wMin),
                    _LadderCoverageItem(item: data.covered[i], currentStage: controller.stage ?? ''),
                  ],
                  const Spacer(),
                  Text(
                    '点一关 → 只看落在这一关的题',
                    style: TextStyle(fontSize: 16.wMin, color: _ZxColors.ink2Color),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _LadderCoverageItem extends StatelessWidget {
  final LadderCompareCoverageData item;
  final String currentStage;

  const _LadderCoverageItem({
    required this.item,
    required this.currentStage,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = item.stage == currentStage;
    final int rate = item.total == 0 ? 0 : ((item.hit / item.total) * 100).round();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          item.label,
          style: TextStyle(
            fontSize: 16.wMin,
            color: active ? _ZxColors.goldColor : _ZxColors.ink2Color,
          ),
        ),
        SizedBox(width: 6.wMin),
        Text(
          '$rate% 可练 · ${item.hit}/${item.total}',
          style: TextStyle(
            fontSize: 16.wMin,
            fontFamily: AppFontValue.robotoMono,
            color: _ZxColors.ink3Color,
          ),
        ),
      ],
    );
  }
}

class _LadderMap extends StatelessWidget {
  final LadderCompareData data;
  final ScrollController scrollController;
  final ValueChanged<LadderCompareNodeData> onTapNode;

  const _LadderMap({
    required this.data,
    required this.scrollController,
    required this.onTapNode,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, int> laneIndexByGenre = <String, int>{
      for (int i = 0; i < data.lanes.length; i++) data.lanes[i].genreNid: i,
    };
    return LayoutBuilder(
      builder: (_, constraints) {
        const double laneLabelWidth = 200;
        final int laneCount = data.lanes.length;
        if (laneCount == 0) return const SizedBox.shrink();
        final _LadderMapMetrics metrics = _LadderMapMetrics.of(constraints.maxHeight, laneCount);
        final List<_LadderMapColumn> columns = <_LadderMapColumn>[];
        final List<_LadderGateGroup> groups = <_LadderGateGroup>[];
        final Map<String, List<LadderCompareNodeData>> nodesByStage = <String, List<LadderCompareNodeData>>{};
        for (final LadderCompareNodeData item in data.nodes) {
          nodesByStage.putIfAbsent(item.examStage, () => <LadderCompareNodeData>[]).add(item);
        }
        for (final ZhenxieExamStage examStage in ZhenxieExamStage.values) {
          final List<LadderCompareNodeData> stageNodes = nodesByStage[examStage.code] ?? const <LadderCompareNodeData>[];
          if (stageNodes.isEmpty) continue;
          final List<int> orderList = stageNodes.map((item) => item.order).toSet().toList()..sort();
          final int startIndex = columns.length;
          for (final int order in orderList) {
            final Map<int, LadderCompareNodeData> nodesByLane = <int, LadderCompareNodeData>{};
            for (final LadderCompareNodeData item in stageNodes) {
              if (item.order != order) continue;
              final int? laneIndex = laneIndexByGenre[item.genreNid];
              if (laneIndex == null) continue;
              nodesByLane[laneIndex] = item;
            }
            if (nodesByLane.isEmpty) continue;
            columns.add(_LadderMapColumn(nodesByLane: nodesByLane));
          }
          if (columns.length > startIndex) {
            groups.add(_LadderGateGroup(
              stage: examStage.code,
                tags: data.stageTags[examStage.code] ?? const <String>[],
              startIndex: startIndex,
              endIndex: columns.length - 1,
            ));
          }
        }
        final double contentViewportWidth = math.max(0, constraints.maxWidth - laneLabelWidth.wMin);
        return Row(
          children: <Widget>[
            SizedBox(
              width: laneLabelWidth.wMin,
              height: constraints.maxHeight,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: metrics.topReserve,
                    child: _LadderTopReserveArea(drawLeftBorder: true),
                  ),
                  for (int index = 0; index < laneCount; index++)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: metrics.topReserve + index * metrics.laneHeight,
                      height: metrics.laneHeight,
                      child: _LadderLaneBackground(
                        lane: data.lanes[index],
                        laneIndex: index,
                        showLabel: true,
                        drawLeftBorder: true,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: metrics.topReserve,
                    child: const _LadderTopReserveArea(),
                  ),
                  Positioned.fill(
                    child: _buildLaneOverlay(
                      laneCount: laneCount,
                      metrics: metrics,
                    ),
                  ),
                  Positioned.fill(
                    child: ListView.builder(
                      controller: scrollController,
                        padding: EdgeInsets.zero,
                      scrollDirection: Axis.horizontal,
                      itemExtent: metrics.columnWidth,
                      itemCount: columns.length,
                      itemBuilder: (context, index) {
                        return _buildMapColumn(
                          context,
                          column: columns[index],
                          viewportHeight: constraints.maxHeight,
                          metrics: metrics,
                        );
                      },
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: metrics.topReserve,
                    bottom: metrics.bottomReserve,
                    child: Container(
                      width: 1.wMin,
                      color: AppTheme.cBorderTranslucentSubtle.color,
                    ),
                  ),
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: scrollController,
                      builder: (context, _) {
                        return _buildGateOverlay(
                          groups: groups,
                          columnWidth: metrics.columnWidth,
                          viewportWidth: contentViewportWidth,
                          viewportHeight: constraints.maxHeight,
                          topInset: metrics.groupTopInset,
                          bottomReserve: metrics.bottomReserve,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        
          ],
        );
      },
    );
  }

  Widget _buildMapColumn(
    BuildContext context, {
    required _LadderMapColumn column,
    required double viewportHeight,
    required _LadderMapMetrics metrics,
  }) {
    return SizedBox(
      height: viewportHeight,
      child: Stack(
        children: <Widget>[
          for (final MapEntry<int, LadderCompareNodeData> entry in column.nodesByLane.entries)
            Positioned(
              left: 0,
              right: 0,
              top: metrics.topReserve + entry.key * metrics.laneHeight,
              height: metrics.laneHeight,
              child: _LadderMapNode(
                node: entry.value,
                metrics: metrics,
                onTap: () => onTapNode(entry.value),
              ),
            ),
        ],
      ),
     
    );
  }

  Widget _buildLaneOverlay({
    required int laneCount,
    required _LadderMapMetrics metrics,
  }) {
    return Stack(
      children: List.generate(laneCount, (laneIndex) {
        final double top = metrics.topReserve + laneIndex * metrics.laneHeight;
        return Positioned(
          left: 0,
          right: 0,
          top: top,
          height: metrics.laneHeight,
          child: _LadderLaneBackground(
            lane: data.lanes[laneIndex],
            laneIndex: laneIndex,
            showLabel: false,
            drawLeftBorder: false,
          ),
        );
      }),
    );
  }

  Widget _buildGateOverlay({
    required List<_LadderGateGroup> groups,
    required double columnWidth,
    required double viewportWidth,
    required double viewportHeight,
    required double topInset,
    required double bottomReserve,
  }) {
    final double scrollOffset = scrollController.hasClients ? scrollController.offset : 0;
    final double horizontalInset = 3.wMin;
    return IgnorePointer(
      child: Stack(
        children: groups.map((group) {
          final double left = group.startIndex * columnWidth - scrollOffset + horizontalInset;
          final double width = math.max(0, (group.endIndex - group.startIndex + 1) * columnWidth - horizontalInset * 2);
          if (left + width <= 0 || left >= viewportWidth) {
            return const SizedBox.shrink();
          }
          return Positioned(
            left: left,
            top: topInset,
            width: width,
            height: viewportHeight - bottomReserve - topInset,
              child: _LadderGateCard(stage: group.stage, tags: group.tags),
          );
        }).toList(),
      ),
    );
  }
}

class _LadderGateGroup {
  final String stage;
  final List<String> tags;
  final int startIndex;
  final int endIndex;

  const _LadderGateGroup({
    required this.stage,
    required this.tags,
    required this.startIndex,
    required this.endIndex,
  });
}

class _LadderMapMetrics {
  final double topReserve;
  final double bottomReserve;
  final double laneHeight;
  final double groupTopInset;
  final double nodeVerticalPadding;
  final double nodeHorizontalGap;
  final double nodeTitleGap;
  final double nodeTitleHeight;
  final double nodeTitleSize;
  final double columnWidth;

  const _LadderMapMetrics({
    required this.topReserve,
    required this.bottomReserve,
    required this.laneHeight,
    required this.groupTopInset,
    required this.nodeVerticalPadding,
    required this.nodeHorizontalGap,
    required this.nodeTitleGap,
    required this.nodeTitleHeight,
    required this.nodeTitleSize,
    required this.columnWidth,
  });

  double get imageSize => math.max(
        0,
        laneHeight - nodeVerticalPadding * 2 - nodeTitleGap - nodeTitleHeight,
      );

  static _LadderMapMetrics of(double height, int laneCount) {
    const double topReserve = 64;
    const double bottomReserve = 0;
    const double groupTopInset = 8;
    const double nodeVerticalPadding = 8;
    const double nodeHorizontalGap = 12;
    const double nodeTitleGap = 8;
    const double nodeTitleHeight = 22;
    const double nodeTitleSize = 16;
    final double topReserveValue = topReserve.wMin;
    final double bottomReserveValue = bottomReserve.wMin;
    final double groupTopInsetValue = groupTopInset.wMin;
    final double nodeVerticalPaddingValue = nodeVerticalPadding.wMin;
    final double nodeHorizontalGapValue = nodeHorizontalGap.wMin;
    final double nodeTitleGapValue = nodeTitleGap.wMin;
    final double nodeTitleHeightValue = nodeTitleHeight.wMin;
    final double nodeTitleSizeValue = nodeTitleSize.wMin;
    final double laneAreaHeight = math.max(0, height - topReserveValue - bottomReserveValue);
    final double laneHeight = laneCount <= 0 ? 0 : laneAreaHeight / laneCount;
    final double columnWidth = math.max(
      0,
      laneHeight - nodeVerticalPaddingValue * 2 - nodeTitleGapValue - nodeTitleHeightValue + nodeHorizontalGapValue,
    );
    return _LadderMapMetrics(
      topReserve: topReserveValue,
      bottomReserve: bottomReserveValue,
      laneHeight: laneHeight,
      groupTopInset: groupTopInsetValue,
      nodeVerticalPadding: nodeVerticalPaddingValue,
      nodeHorizontalGap: nodeHorizontalGapValue,
      nodeTitleGap: nodeTitleGapValue,
      nodeTitleHeight: nodeTitleHeightValue,
      nodeTitleSize: nodeTitleSizeValue,
      columnWidth: columnWidth,
    );
  }
}

class _LadderMapColumn {
  final Map<int, LadderCompareNodeData> nodesByLane;

  const _LadderMapColumn({
    required this.nodesByLane,
  });
}

class _LadderLaneBackground extends StatelessWidget {
  final LadderCompareLaneData lane;
  final int laneIndex;
  final bool showLabel;
  final bool drawLeftBorder;

  const _LadderLaneBackground({
    required this.lane,
    required this.laneIndex,
    required this.showLabel,
    required this.drawLeftBorder,
  });

  @override
  Widget build(BuildContext context) {
    // AutoSizeText 要求 min/maxFontSize 与 stepGranularity 精确整除，整数步进可避免浮点断言。
    final double maxSize = 16.wMin.roundToDouble();
    final double minSize = 12.wMin.roundToDouble();
    return Container(
      padding: EdgeInsets.fromLTRB(12.wMin, 40.wMin, 12.wMin, 40.wMin),
      decoration: BoxDecoration(
        color: showLabel ? AppTheme.cSurfaceTranslucentBase.color : AppTheme.cSurfaceTranslucentElevated.color,
        border: Border(
          top: BorderSide(
            color: laneIndex == 0 ? AppTheme.cBorderTranslucentSubtle.color : Colors.transparent,
            width: 1.wMin,
          ),
          bottom: BorderSide(color: AppTheme.cBorderTranslucentSubtle.color, width: 1.wMin),
          left: BorderSide(
            color: drawLeftBorder ? AppTheme.cBorderTranslucentSubtle.color : Colors.transparent,
            width: 1.wMin,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (showLabel) ...<Widget>[
            Text(
              lane.label,
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
                fontFamily: AppFontValue.sourceHanSerifCN,
                color: Color(lane.colorValue),
              ),
            ),
            SizedBox(height: 8.wMin),
            AutoSizeText(
              lane.sub,
              maxLines: 1,
              maxFontSize: maxSize,
              minFontSize: minSize,
                stepGranularity: 1,
              style: TextStyle(
                fontSize: maxSize,
                fontFamily: AppFontValue.robotoMono,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LadderTopReserveArea extends StatelessWidget {
  final bool drawLeftBorder;

  const _LadderTopReserveArea({
    this.drawLeftBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.cBorderTranslucentSubtle.color, width: 1.wMin),
          left: BorderSide(
            color: drawLeftBorder ? AppTheme.cBorderTranslucentSubtle.color : Colors.transparent,
            width: 1.wMin,
          ),
                    right: BorderSide(
            color:AppTheme.cBorderTranslucentSubtle.color,
            width: 1.wMin,
          ),
        ),
    
      ),
    );
  }
}

class _LadderGateCard extends StatelessWidget {
  final String stage;
  final List<String> tags;

  const _LadderGateCard({
    required this.stage,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    final ZhenxieExamStage? item = ZhenxieExamStage.values.firstWhereOrNull((row) => row.code == stage);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.wMin),
        border: Border.all(color: AppTheme.cZhenxieGold.color.withValues(alpha: 0.2), width: 1.wMin),
        gradient:  LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xffD4AF37).withValues(alpha: 0.12),
            Colors.transparent,
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 10.wMin),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Icon(Icons.lock, size: 20.wMin, color: AppTheme.cTextPrimary.color),
                SizedBox(width: 6.wMin),
                Text(
                  item?.label ?? stage,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppFontValue.sourceHanSerifCN,
                    color: AppTheme.cTextPrimary.color,
                  ),
                  ),
                  for (final String tag in tags)
                    Container(
                      margin: EdgeInsets.only(left: 4.wMin),
                        padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppTheme.cZhenxieBorderPrimary.color,
                          width: 1.wMin,
                        ),
                          borderRadius: BorderRadius.circular(999.wMin),
                          color: AppTheme.cZhenxieBackgroundPrimary.color,
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 20.wMin,
                          fontWeight: FontWeight.w400,
                            color: AppTheme.cZhenxieFontTertiary.color,
                          height: 1.0,
                        ),
                      ),
                    ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _LadderMapNode extends StatelessWidget {
  final LadderCompareNodeData node;
  final _LadderMapMetrics metrics;
  final VoidCallback onTap;

  const _LadderMapNode({
    required this.node,
    required this.metrics,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = Color(node.colorValue);
    return Opacity(
      opacity: 1,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: metrics.nodeHorizontalGap / 2,
            vertical: metrics.nodeVerticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.wMin),
                  child: node.coverUrl.isNotEmpty
                      ? Image.network(
                          node.coverUrl,
                          alignment: Alignment.topCenter,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _LadderThumbFallback(
                            color: color,
                            skinNid: node.skinNid,
                            size: metrics.imageSize,
                          ),
                        )
                      : node.coverAsset != null
                          ? Image.asset(
                              node.coverAsset!,
                              alignment: Alignment.topCenter,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _LadderThumbFallback(
                                color: color,
                                skinNid: node.skinNid,
                                size: metrics.imageSize,
                              ),
                            )
                          : _LadderThumbFallback(
                              color: color,
                              skinNid: node.skinNid,
                              size: metrics.imageSize,
                            ),
                ),
              ),
              SizedBox(height: metrics.nodeTitleGap),
              SizedBox(
                height: metrics.nodeTitleHeight,
                child: Center(
                  child: Text(
                    node.stageName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: AppFontValue.sourceHanSerifCN,
                      fontSize: metrics.nodeTitleSize,
                      fontWeight: FontWeight.w600,
                        color: AppTheme.cZhenxieFontTertiary.color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LadderThumbFallback extends StatelessWidget {
  final Color color;
  final String skinNid;
  final double size;

  const _LadderThumbFallback({
    required this.color,
    required this.skinNid,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: <Color>[color.withValues(alpha: 0.55), color.withValues(alpha: 0.18)],
        ),
        border: Border.all(color: color.withValues(alpha: 0.9), width: 2.wMin),
        boxShadow: <BoxShadow>[BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 12.wMin)],
      ),
      child: Icon(_skinIcon(skinNid), size: 40.wMin, color: color),
    );
  }
}

class _GoalLayout {
  final List<_GoalPlacedNode> nodes;
  final List<_GoalPlacedLink> links;
  final List<Widget> headers;

  const _GoalLayout({
    required this.nodes,
    required this.links,
    required this.headers,
  });

  Rect buildAvoidRect(String code) {
    final Set<String> ids = <String>{
      code,
      ...links.where((item) => item.source.node.code == code).map((item) => item.target.node.code),
      ...links.where((item) => item.target.node.code == code).map((item) => item.source.node.code),
    };
    final List<_GoalPlacedNode> mine = nodes.where((item) => ids.contains(item.node.code)).toList();
    if (mine.isEmpty) return Rect.fromLTWH(0, 54.wMin, 0, 40.wMin);
    final double labelWidth = 260.wMin;
    return Rect.fromLTRB(
      mine.map((item) => item.columnIndex == 0 ? item.rect.left - labelWidth - 8.wMin : item.rect.left).reduce(math.min),
      mine.map((item) => item.rect.top).reduce(math.min),
      mine.map((item) => item.columnIndex == 0 ? item.rect.right : item.rect.right + labelWidth + 8.wMin).reduce(math.max),
      mine.map((item) => item.rect.bottom).reduce(math.max),
    );
  }

  static _GoalLayout build(
    ZhenxieExamGoalSankeyApiData data,
    Size size,
    String currentStage,
    ZhenxieExamCompareController controller,
  ) {
    const double nodeWidth = 14;
    const double top = 54;
    const double bottom = 6;
    const double gap = 7;
    const double minHeight = 18;
    const double leftPad = 230;
    const double rightPad = 230;
    final double headerWidth = 220.wMin;
    final double headerTitleFontSize = 18.wMin;
    final double headerSummaryFontSize = 16.wMin;
    final int count = data.columns.length;
    final double x0 = leftPad;
    final double x2 = size.width - rightPad - nodeWidth;
    final List<double> xs = List<double>.generate(count, (index) => x0 + ((x2 - x0) * index / math.max(1, count - 1)));
    final double avail = math.max(0, size.height - top - bottom);
    final List<_GoalPlacedNode> placed = <_GoalPlacedNode>[];
    for (int column = 0; column < count; column++) {
      final ZhenxieExamGoalSankeyColumnApiData columnData = data.columns[column];
      final List<ZhenxieExamGoalSankeyNodeApiData> mine = columnData.nodes.toList();
      final int total = mine.fold<int>(0, (sum, item) => sum + item.value);
      double cursor = top;
      final double usable = math.max(0, avail - gap * math.max(0, mine.length - 1) - minHeight * mine.length);
      for (final ZhenxieExamGoalSankeyNodeApiData item in mine) {
        final double extra = total == 0 ? 0 : (item.value / total) * usable;
        final double height = minHeight + extra;
        placed.add(
          _GoalPlacedNode(
            columnIndex: column,
            column: columnData,
            node: item,
            rect: Rect.fromLTWH(xs[column], cursor, nodeWidth, height),
          ),
        );
        cursor += height + gap;
      }
    }

    final List<_GoalPlacedLink> links = <_GoalPlacedLink>[];
    final Map<String, List<String>> outgoing = <String, List<String>>{};
    final Map<String, List<String>> incoming = <String, List<String>>{};
    for (final ZhenxieExamGoalSankeyLinkApiData link in data.links) {
      outgoing.putIfAbsent(link.source, () => <String>[]).add(link.target);
      incoming.putIfAbsent(link.target, () => <String>[]).add(link.source);
    }

    Map<String, (_GoalSlot, _GoalSlot)> slotOf(_GoalPlacedNode owner, List<String> others, int Function(String id) weightOf) {
      final List<String> sorted = others.toList()
        ..sort((a, b) => (placed.firstWhereOrNull((item) => item.node.code == a)?.rect.top ?? 0)
            .compareTo(placed.firstWhereOrNull((item) => item.node.code == b)?.rect.top ?? 0));
      final List<double> weights = sorted.map((id) => math.max(0.0001, weightOf(id).toDouble())).toList();
      final double total = weights.fold<double>(0, (sum, item) => sum + item);
      final double height = owner.rect.height;
      final Map<String, (_GoalSlot, _GoalSlot)> out = <String, (_GoalSlot, _GoalSlot)>{};
      double cursor = owner.rect.top;
      for (int i = 0; i < sorted.length; i++) {
        final double part = (weights[i] / total) * height;
        out[sorted[i]] = (_GoalSlot(start: cursor, end: cursor + part), _GoalSlot(start: cursor, end: cursor + part));
        cursor += part;
      }
      return out;
    }

    final Map<String, Map<String, (_GoalSlot, _GoalSlot)>> outSlots = <String, Map<String, (_GoalSlot, _GoalSlot)>>{};
    final Map<String, Map<String, (_GoalSlot, _GoalSlot)>> inSlots = <String, Map<String, (_GoalSlot, _GoalSlot)>>{};
    for (final _GoalPlacedNode node in placed) {
      outSlots[node.node.code] = slotOf(node, outgoing[node.node.code] ?? const <String>[], (id) {
        return placed.firstWhereOrNull((item) => item.node.code == id)?.node.value ?? 0;
      });
      inSlots[node.node.code] = slotOf(node, incoming[node.node.code] ?? const <String>[], (id) {
        return placed.firstWhereOrNull((item) => item.node.code == id)?.node.value ?? 0;
      });
    }

    for (final ZhenxieExamGoalSankeyLinkApiData link in data.links) {
      final _GoalPlacedNode? source = placed.firstWhereOrNull((item) => item.node.code == link.source);
      final _GoalPlacedNode? target = placed.firstWhereOrNull((item) => item.node.code == link.target);
      if (source == null || target == null) continue;
      final _GoalSlot sourceSlot =
          outSlots[source.node.code]?[target.node.code]?.$1 ?? _GoalSlot(start: source.rect.top, end: source.rect.bottom);
      final _GoalSlot targetSlot =
          inSlots[target.node.code]?[source.node.code]?.$1 ?? _GoalSlot(start: target.rect.top, end: target.rect.bottom);
      links.add(_GoalPlacedLink(
        source: source,
        target: target,
        sourceColor: controller.buildGoalNodeColor(source.column, source.node),
        targetColor: controller.buildGoalNodeColor(target.column, target.node),
        sourceSlot: sourceSlot,
        targetSlot: targetSlot,
        notes: link.notes,
      ));
    }

    final List<Widget> headers = <Widget>[
      for (int i = 0; i < data.columns.length; i++)
        Positioned(
          left: xs[i] - (headerWidth - nodeWidth) / 2,
          top: 8.wMin,
          child: SizedBox(
            width: headerWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  controller.buildZhText(data.columns[i].name),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: headerTitleFontSize,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFontValue.sourceHanSerifCN,
                    color: data.columns[i].stage == currentStage ? _ZxColors.goldColor : _ZxColors.inkColor,
                  ),
                ),
                Text(
                  data.columns[i].summaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: headerSummaryFontSize,
                    fontFamily: AppFontValue.robotoMono,
                    color: _ZxColors.boneColor.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
        ),
    ];

    return _GoalLayout(nodes: placed, links: links, headers: headers);
  }

  List<Widget> nodeWidgets({
    required ZhenxieExamCompareController controller,
    required String? activeId,
    required String? selectedId,
    required void Function(String?) onHover,
    required void Function(String?) onSelect,
  }) {
    final Set<String>? neighbors = activeId == null
        ? null
        : <String>{
            activeId,
            ...links.where((item) => item.source.node.code == activeId).map((item) => item.target.node.code),
            ...links.where((item) => item.target.node.code == activeId).map((item) => item.source.node.code),
          };
    return nodes.map((item) {
      final Color nodeColor = controller.buildGoalNodeColor(item.column, item.node);
      final bool lit = neighbors == null ? item.node.value > 0 : neighbors.contains(item.node.code) && item.node.value > 0;
      final bool self = item.node.code == selectedId;
      final bool leftLabel = item.columnIndex == 0;
      final double labelWidth = 260.wMin;
      final String fullLabel = controller.buildGoalNodeName(item.node);
      final String label = fullLabel.length > 16 ? '${fullLabel.substring(0, 15)}…' : fullLabel;
      return Positioned(
        left: leftLabel ? item.rect.left - labelWidth - 8.wMin : item.rect.left,
        top: item.rect.top,
        child: MouseRegion(
          onEnter: (_) => onHover(item.node.code),
          onExit: (_) => onHover(null),
          child: GestureDetector(
            onTap: () => onSelect(item.node.code),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: item.rect.width + 8.wMin + labelWidth,
              height: item.rect.height,
              child: Row(
                children: <Widget>[
                  if (leftLabel)
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: self ? nodeColor : (lit ? _ZxColors.inkColor : _ZxColors.boneColor.withValues(alpha: 0.3)),
                        ),
                      ),
                    ),
                  if (leftLabel) SizedBox(width: 8.wMin),
                  Container(
                    width: item.rect.width,
                    height: item.rect.height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.wMin),
                      color: nodeColor.withValues(alpha: lit || self ? 1 : 0.22),
                    ),
                  ),
                  if (!leftLabel) ...<Widget>[
                    SizedBox(width: 8.wMin),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: self ? nodeColor : (lit ? _ZxColors.inkColor : _ZxColors.boneColor.withValues(alpha: 0.3)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  String? hitTestInteractiveId(Offset point) {
    for (final _GoalPlacedNode item in nodes.reversed) {
      final bool leftLabel = item.columnIndex == 0;
      final double labelWidth = 260.wMin;
      final Rect hitRect = leftLabel
          ? Rect.fromLTWH(item.rect.left - labelWidth - 8.wMin, item.rect.top, item.rect.width + 8.wMin + labelWidth, item.rect.height)
          : Rect.fromLTWH(item.rect.left, item.rect.top, item.rect.width + 8.wMin + labelWidth, item.rect.height);
      if (hitRect.contains(point)) return item.node.code;
    }
    for (final _GoalPlacedLink item in links.reversed) {
      final Path path = _GoalLinkPainter.bandPath(
        item.source.rect.right,
        item.sourceSlot.start,
        item.sourceSlot.end,
        item.target.rect.left,
        item.targetSlot.start,
        item.targetSlot.end,
      );
      if (path.contains(point)) return item.source.node.code;
    }
    return null;
  }
}

class _GoalLinkPainter extends CustomPainter {
  final List<_GoalPlacedLink> links;
  final String? activeId;
  final String? pickedId;

  const _GoalLinkPainter({
    required this.links,
    required this.activeId,
    required this.pickedId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Set<String>? neighbors = activeId == null
        ? null
        : <String>{
            activeId!,
            ...links.where((item) => item.source.node.code == activeId).map((item) => item.target.node.code),
            ...links.where((item) => item.target.node.code == activeId).map((item) => item.source.node.code),
          };
    for (final _GoalPlacedLink item in links) {
      final bool lit = neighbors != null &&
          neighbors.contains(item.source.node.code) &&
          neighbors.contains(item.target.node.code) &&
          (item.source.node.code == activeId || item.target.node.code == activeId);
      final bool dim = neighbors != null && !lit;
      final Path path = bandPath(
        item.source.rect.right,
        item.sourceSlot.start,
        item.sourceSlot.end,
        item.target.rect.left,
        item.targetSlot.start,
        item.targetSlot.end,
      );
      final Paint paint = Paint()..style = PaintingStyle.fill;
      if (lit) {
        paint.shader = ui.Gradient.linear(
          Offset(item.source.rect.left, 0),
          Offset(item.target.rect.right, 0),
          <Color>[
            item.sourceColor.withValues(alpha: 0.48),
            item.targetColor.withValues(alpha: 0.48),
          ],
        );
      } else {
        paint.shader = ui.Gradient.linear(
          Offset(item.source.rect.left, 0),
          Offset(item.target.rect.right, 0),
          <Color>[
            item.sourceColor.withValues(alpha: dim ? 0.035 : 0.22),
            item.targetColor.withValues(alpha: dim ? 0.035 : 0.22),
          ],
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  static Path bandPath(double x0, double y0a, double y1a, double x1, double y0b, double y1b) {
    final double mx = (x0 + x1) / 2;
    return Path()
      ..moveTo(x0, y0a)
      ..cubicTo(mx, y0a, mx, y0b, x1, y0b)
      ..lineTo(x1, y1b)
      ..cubicTo(mx, y1b, mx, y1a, x0, y1a)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _GoalLinkPainter oldDelegate) {
    return oldDelegate.links != links || oldDelegate.activeId != activeId || oldDelegate.pickedId != pickedId;
  }
}

class _FlowLegendGroup {
  final String id;
  final String label;
  final List<ZhenxieExamCompareLegendData> items;

  const _FlowLegendGroup({
    required this.id,
    required this.label,
    required this.items,
  });
}

class _ExplainCardLayoutDelegate extends SingleChildLayoutDelegate {
  final Rect avoidRect;
  final double padding;

  const _ExplainCardLayoutDelegate({
    required this.avoidRect,
    required this.padding,
  });

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final double cardWidth = math.min(childSize.width, math.max(200, size.width - padding * 2));
    final double cardHeight = childSize.height;
    final double spaceAbove = avoidRect.top - padding;
    final double spaceBelow = size.height - avoidRect.bottom - padding;
    double top = spaceBelow >= cardHeight && spaceBelow >= spaceAbove
        ? avoidRect.bottom + padding
        : spaceAbove >= cardHeight
            ? avoidRect.top - cardHeight - padding
            : spaceBelow >= spaceAbove
                ? avoidRect.bottom + padding
                : avoidRect.top - cardHeight - padding;
    double left = (size.width - cardWidth) / 2;
    final bool overlapsY = !(top + cardHeight <= avoidRect.top || top >= avoidRect.bottom);
    if (overlapsY) {
      final double spaceRight = size.width - avoidRect.right - padding;
      final double spaceLeft = avoidRect.left - padding;
      if (spaceRight >= cardWidth) {
        left = avoidRect.right + padding;
      } else if (spaceLeft >= cardWidth) {
        left = avoidRect.left - cardWidth - padding;
      }
    }
    final double maxLeft = math.max(padding, size.width - cardWidth - padding);
    final double maxTop = math.max(padding, size.height - cardHeight - padding);
    left = left.clamp(padding, maxLeft);
    top = top.clamp(padding, maxTop);
    return Offset(left, top);
  }

  @override
  bool shouldRelayout(covariant _ExplainCardLayoutDelegate oldDelegate) {
    return oldDelegate.avoidRect != avoidRect || oldDelegate.padding != padding;
  }
}

class _GoalPlacedNode {
  final int columnIndex;
  final ZhenxieExamGoalSankeyColumnApiData column;
  final ZhenxieExamGoalSankeyNodeApiData node;
  final Rect rect;

  const _GoalPlacedNode({
    required this.columnIndex,
    required this.column,
    required this.node,
    required this.rect,
  });
}

class _GoalPlacedLink {
  final _GoalPlacedNode source;
  final _GoalPlacedNode target;
  final Color sourceColor;
  final Color targetColor;
  final _GoalSlot sourceSlot;
  final _GoalSlot targetSlot;
  final List<String> notes;

  const _GoalPlacedLink({
    required this.source,
    required this.target,
    required this.sourceColor,
    required this.targetColor,
    required this.sourceSlot,
    required this.targetSlot,
    required this.notes,
  });
}

class _GoalSlot {
  final double start;
  final double end;

  const _GoalSlot({
    required this.start,
    required this.end,
  });
}

IconData _skinIcon(String skinNid) {
  switch (skinNid) {
    case 'report_picture':
      return Icons.image_outlined;
    case 'report_letter':
      return Icons.mail_outline;
    case 'report_people':
      return Icons.person_outline;
    case 'report_event':
      return Icons.event_note_outlined;
    case 'report_view':
      return Icons.travel_explore_outlined;
    case 'report_chart':
      return Icons.query_stats_outlined;
    default:
      return Icons.auto_stories_outlined;
  }
}
