import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../app/modules/management/common/commons.dart';
import '../tap_scale_widget.dart';
import 'sentence_slot_map_model.dart';

class SentenceSlotMapWidget extends StatelessWidget {
  /// 通用槽位图数据；不传或为空时不显示。
  final SentenceSlotMapEntity? data;

  /// 单个槽位点击回调。
  final void Function(SentenceSlotMapItemEntity item)? onSlotTap;

  /// 句子槽位图
  const SentenceSlotMapWidget({
    super.key,
    this.data,
    this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    final SentenceSlotMapEntity? effectiveData = data;
    if (effectiveData == null || effectiveData.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicHeight(
          child: Row(
            spacing: 2.wMin,
            children: effectiveData.items.map(_buildItemWidget).toList(),
          ),
        ),
      ),
    );
  }

  /// 渲染模板中的单个 segment。
  Widget _buildItemWidget(SentenceSlotMapItemEntity item) {
    final SentenceSlotMapVisualEntity visual = SentenceSlotMapUtils.resolveSlotVisual(item);
    Widget child = Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        color: visual.primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.wMin),
        border: visual.isDottedBorder
            ? null
            : Border.all(
                color: visual.primaryColor.withValues(alpha: 0.3),
                width: 0.8.wMin,
              ),
      ),
      child: _buildItemContentWidget(item: item, visual: visual),
    );

    if (visual.isDottedBorder) {
      child = DottedBorder(
        color: visual.primaryColor.withValues(alpha: 0.3),
        strokeWidth: 0.8.wMin,
        dashPattern: [3.wMin, 1.5.wMin],
        borderType: BorderType.RRect,
        radius: Radius.circular(6.wMin),
        padding: EdgeInsets.zero,
        child: child,
      );
    }

    child = _buildTapWidget(item: item, child: child);

    return child;
  }

  /// 包装槽位点击交互。
  Widget _buildTapWidget({
    required SentenceSlotMapItemEntity item,
    required Widget child,
  }) {
    if (item.isLiteral || (onSlotTap == null)) {
      return child;
    }

    return TapScaleWidget(
      onTap: () {
        onSlotTap?.call(item);
      },
      sclae: 1,
      child: child,
    );
  }

  /// 渲染槽位卡片中的标签行与主体文字。
  Widget _buildItemContentWidget({
    required SentenceSlotMapItemEntity item,
    required SentenceSlotMapVisualEntity visual,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGrowthBadgeWidget(item: item, visual: visual),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: visual.primaryColor.withValues(alpha: 0.8),
              ),
            ),
            _buildCtrlTagWidget(item: item, visual: visual),
          ],
        ),
        SizedBox(height: 4.wMin),
        Text(
          item.text,
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            color: visual.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthBadgeWidget({
    required SentenceSlotMapItemEntity item,
    required SentenceSlotMapVisualEntity visual,
  }) {
    if (item.growthIndex == null) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(
            minWidth: 18.wMin,
            minHeight: 18.wMin,
          ),
          padding: EdgeInsets.symmetric(horizontal: 4.wMin),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(99),
          ),
          alignment: Alignment.center,
          child: Text(
            "${item.growthIndex}",
            style: TextStyle(
              fontSize: 13.wMin,
              fontWeight: FontWeight.w500,
              color: visual.primaryColor,
            ),
          ),
        ),
        SizedBox(width: 4.wMin),
      ],
    );
  }

  Widget _buildCtrlTagWidget({
    required SentenceSlotMapItemEntity item,
    required SentenceSlotMapVisualEntity visual,
  }) {
    if (!item.showCtrl) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 4.wMin),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.wMin, vertical: 1.wMin),
          decoration: BoxDecoration(
            color: visual.primaryColor.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(4.wMin),
          ),
          child: Text(
            "C",
            style: TextStyle(
              fontSize: 12.wMin,
              fontWeight: FontWeight.w500,
              color: visual.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

class SentenceSlotExampleWidget extends StatefulWidget {
  /// 代表句中的已展开 segment；不传或为空时不显示。
  final List<PatternBlueprintSentenceBriefSegmentEntity?>? segmentList;

  /// 单个槽位点击回调。
  final void Function(PatternBlueprintSentenceBriefSegmentEntity segment)? onSlotTap;

  /// 代表句槽位实例
  const SentenceSlotExampleWidget({
    super.key,
    this.segmentList,
    this.onSlotTap,
  });

  @override
  State<SentenceSlotExampleWidget> createState() => _SentenceSlotExampleWidgetState();
}

class _SentenceSlotExampleWidgetState extends State<SentenceSlotExampleWidget> {
  /// 当前展开链路上每一层选中的槽位下标。
  final List<int> _selectedIndexes = [];

  @override
  Widget build(BuildContext context) {
    return _buildNestedListGroupWidget(
      list: widget.segmentList,
      context: context,
      depth: 0,
    );
  }

  /// 递归渲染当前层列表，以及被选中 segment 对应的子层结构。
  Widget _buildNestedListGroupWidget({
    required List<PatternBlueprintSentenceBriefSegmentEntity?>? list,
    required BuildContext context,
    required int depth,
  }) {
    if (list == null || list.isEmpty) {
      return const SizedBox.shrink();
    }

    final PatternBlueprintSentenceBriefSegmentEntity? selectedSegment = _getSelectedSegment(list, depth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buiildListWidget(list, context, depth: depth),
        _buildChildListWidget(
          selectedSegment: selectedSegment,
          context: context,
          depth: depth + 1,
        ),
      ],
    );
  }

  /// 渲染当前选中 segment 的子层结构。
  Widget _buildChildListWidget({
    required PatternBlueprintSentenceBriefSegmentEntity? selectedSegment,
    required BuildContext context,
    required int depth,
  }) {
    final PatternBlueprintSentenceBriefSegmentChildStructEntity? childStruct = selectedSegment?.childStruct;
    final List<PatternBlueprintSentenceBriefSegmentEntity?>? childList = childStruct?.segmentList;
    if (childStruct == null || childList == null || childList.isEmpty) {
      return const SizedBox.shrink();
    }

    final LanguageText? patternName = LearningLangUtils.getLocalLang(childStruct.patternName);
    final String title = '内层 · ${ patternName?.text ?? ''}';
    final String patternNid = childStruct.patternNid ?? '';

    return Container(
      margin: EdgeInsets.only(top: 12.wMin),
      padding: EdgeInsets.only(left: 16.wMin),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            width: 1.wMin,
            color: AppTheme.cBorderDefault.color,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 4.wMin,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (patternNid.isNotEmpty) CopyTagWidget(name: "句型", value: patternNid),
            ],
          ),
          SizedBox(height: 12.wMin),
          _buildNestedListGroupWidget(
            list: childList,
            context: context,
            depth: depth,
          ),
        ],
      ),
    );
  }

  Widget _buiildListWidget(
    List<PatternBlueprintSentenceBriefSegmentEntity?>? list,
    BuildContext context, {
    required int depth,
  }) {
    if (list == null || list.isEmpty) {
      return const SizedBox.shrink();
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicHeight(
          child: Row(
            spacing: 2.wMin,
            children: List.generate(list.length, (index) {
              return _buildExampleItemWidget(
                segment: list[index],
                index: index,
                depth: depth,
              );
            }),
          ),
        ),
      ),
    );
  }

  /// 代表句 segment 的角色判定，优先使用 literal / required 信息。
  static SentenceSlotMapRole _resolveSentenceExampleRole(
    PatternBlueprintSentenceBriefSegmentEntity segment,
  ) {
    if (segment.literal == true) {
      return SentenceSlotMapRole.literal;
    }
    if (segment.required == null) {
      return SentenceSlotMapRole.controlled;
    }
    if (segment.required == true) {
      return SentenceSlotMapRole.requiredOpen;
    }
    return SentenceSlotMapRole.optionalOpen;
  }

  /// 渲染代表句中的单个 segment。
  Widget _buildExampleItemWidget({
    required PatternBlueprintSentenceBriefSegmentEntity? segment,
    required int index,
    required int depth,
  }) {
    if (segment == null) return const SizedBox.shrink();
    final SentenceSlotMapRole role = _resolveSentenceExampleRole(segment);
    final Color primaryColor = const Color(0xff0EA5E9);
    final bool isDottedBorder = role == SentenceSlotMapRole.optionalOpen;
    final bool hasNestedChildren = _hasNestedChildList(segment);
    final bool selected = _isItemSelected(depth, index);
    Widget child = const SizedBox.shrink();

    if (isDottedBorder) {
      child = DottedBorder(
        color: primaryColor.withValues(alpha: selected ? 0.6 : 0.3),
        strokeWidth: 0.8.wMin,
        dashPattern: [3.wMin, 1.5.wMin],
        borderType: BorderType.RRect,
        radius: Radius.circular(6.wMin),
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6.wMin),
          ),
          child: _buildExampleItemContentWidget(
            segment,
            index,
            depth: depth,
            hasNestedChildren: hasNestedChildren,
          ),
        ),
      );
    } else {
      child = Container(
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6.wMin),
          border: Border.all(
            color: primaryColor.withValues(alpha: selected ? 0.6 : 0.3),
            width: 0.8.wMin,
          ),
        ),
        child: _buildExampleItemContentWidget(
          segment,
          index,
          depth: depth,
          hasNestedChildren: hasNestedChildren,
        ),
      );
    }

    return IgnorePointer(
      ignoring: role == SentenceSlotMapRole.literal || (!hasNestedChildren && widget.onSlotTap == null),
      child: TapScaleWidget(
        onTap: () {
          if (hasNestedChildren) {
            _toggleSelectedIndex(depth, index);
          } else {
            widget.onSlotTap?.call(segment);
          }
        },
        sclae: 1,
        child: child,
      ),
    );
  }

  /// 渲染实例卡片中的标签行与句面文字。
  Widget _buildExampleItemContentWidget(
    PatternBlueprintSentenceBriefSegmentEntity? segment,
    int index, {
    required int depth,
    required bool hasNestedChildren,
  }) {
    if (segment == null) return const SizedBox.shrink();
    final SentenceSlotMapRole role = _resolveSentenceExampleRole(segment);
    final bool isLiteral = role == SentenceSlotMapRole.literal;
    final bool showCtrl = role == SentenceSlotMapRole.controlled;
    final String name = LearningLangUtils.getLocalLang(segment.slot?.name)?.text ?? '';
    final String label = isLiteral ? '固定' : name;
    final String text = segment.text ?? '';
    final Color primaryColor = const Color(0xff0EA5E9);

    final bool showEmptyMask = !isLiteral && text.isEmpty;
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w600,
                      color: primaryColor.withValues(alpha: 0.8),
                    ),
                  ),
                  _buildExampleCtrlTagWidget(
                    showCtrl: showCtrl,
                    primaryColor: primaryColor,
                  ),
                  Visibility(
                    visible: hasNestedChildren,
                    child: Container(
                      margin: EdgeInsets.only(left: 8.wMin),
                      child: Transform.rotate(
                        angle: _isItemSelected(depth, index) ? pi : 0,
                        child: SvgPicture.asset(
                          "assets/svg/public/icon_caret_down.svg",
                          width: 18.wMin,
                          colorFilter: ColorFilter.mode(primaryColor.withValues(alpha: 0.8), BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.wMin),
              Text(
                showEmptyMask ? " " : text,
                style: TextStyle(
                  fontSize: isLiteral ? 26.wMin : 24.wMin,
                  fontWeight: FontWeight.w500,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: showEmptyMask,
          child: Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.wMin),
              child: CustomPaint(
                painter: _SentenceSlotEmptyMaskPainter(
                  primaryColor: primaryColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 获取当前层已展开的 segment。
  PatternBlueprintSentenceBriefSegmentEntity? _getSelectedSegment(
    List<PatternBlueprintSentenceBriefSegmentEntity?> list,
    int depth,
  ) {
    if (_selectedIndexes.length <= depth) {
      return null;
    }

    final int index = _selectedIndexes[depth];
    if (index < 0 || index >= list.length) {
      return null;
    }

    return list[index];
  }

  /// 判断当前卡片是否处于选中展开状态。
  bool _isItemSelected(int depth, int index) {
    return _selectedIndexes.length > depth && _selectedIndexes[depth] == index;
  }

  /// 切换当前层的选中项，并清理更深层的展开状态。
  void _toggleSelectedIndex(int depth, int index) {
    final bool selected = _isItemSelected(depth, index);
    if (_selectedIndexes.length > depth) {
      _selectedIndexes.removeRange(depth, _selectedIndexes.length);
    }
    if (selected) {
      setState(() {});
      return;
    }

    _selectedIndexes.add(index);
    setState(() {});
  }

  /// 判断 segment 是否挂载了可继续展开的子层数据。
  bool _hasNestedChildList(PatternBlueprintSentenceBriefSegmentEntity segment) {
    final List<PatternBlueprintSentenceBriefSegmentEntity?>? childList = segment.childStruct?.segmentList;
    return childList != null && childList.isNotEmpty;
  }

  Widget _buildExampleCtrlTagWidget({
    required bool showCtrl,
    required Color primaryColor,
  }) {
    if (!showCtrl) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 4.wMin),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.wMin, vertical: 1.wMin),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(4.wMin),
          ),
          child: Text(
            "C",
            style: TextStyle(
              fontSize: 12.wMin,
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _SentenceSlotEmptyMaskPainter extends CustomPainter {
  const _SentenceSlotEmptyMaskPainter({
    required this.primaryColor,
  });

  /// 空槽位遮罩主色
  final Color primaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()..color = primaryColor.withValues(alpha: 0.08);
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final Paint linePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.12)
      ..strokeWidth = 1.wMin;

    final double spacing = 12.wMin;
    for (double startX = -size.height; startX < size.width; startX += spacing) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + size.height, size.height),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SentenceSlotEmptyMaskPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor;
  }
}
