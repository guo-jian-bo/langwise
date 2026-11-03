import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/values/app_font_value.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/color_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../bindings/zhenxie_lexis_binding.dart';
import '../controllers/zhenxie_lexis_controller.dart';

class ZhenxieLexisView extends GetView<ZhenxieLexisController> {
  final String tagText;
  const ZhenxieLexisView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieLexisView(tagText: tag),
      binding: ZhenxieLexisBinding(tagText: tag),
      routeName: Routes.ZHENXIE_LEXIS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Column(
        children: [
          BreadcrumbWidget(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(90.wMin, 0, 90.wMin, 42.wMin),
              child: _buildContentWidget(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentWidget() {
    return Obx(() {
      final List<ZhenxieLexisHomeGroup> groupList = controller.buildGroupList();
      if (groupList.isEmpty) return const SizedBox.shrink();
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(groupList.length * 2 - 1, (index) {
          if (index.isOdd) return SizedBox(width: 18.wMin);
          return Expanded(child: _buildGroupColumnWidget(groupList[index ~/ 2]));
        }),
      );
    });
  }

  Widget _buildGroupColumnWidget(ZhenxieLexisHomeGroup group) {
    final List<ZhenxieLexisHomeDoorItem> doors = group.items;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 12.wMin),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppTheme.cZhenxieBorderPrimary.color,
                width: 1.wMin,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                group.title ?? "",
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFontValue.sourceHanSerifCN,
                  color: AppTheme.cZhenxieFontPrimary.color,
                ),
              ),
              SizedBox(width: 12.wMin),
              Expanded(
                child: Text(
                  group.description ?? "",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontSecondary.color,
                    fontFamily: AppFontValue.sourceHanSerifCN,
                  ),
                ),
              ),
              SizedBox(width: 12.wMin),
              Text(
                "${doors.length}门",
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFontValue.sourceHanSerifCN,
                  color: AppTheme.cZhenxieFontSecondary.color,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.wMin),
        Expanded(
          child: Column(
            spacing: 16.wMin,
            children: List.generate(doors.length, (index) {
              final ZhenxieLexisHomeDoorItem door = doors[index];
              return Expanded(child: _buildDoorCardWidget(door));
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDoorCardWidget(ZhenxieLexisHomeDoorItem door) {
    final ZhenxieLexisHomeCountItem? mainCountItem = door.items.isNotEmpty ? door.items.first : null;
    final ZhenxieLexisHomeCountItem? countNoteItem = door.items.length > 1 ? door.items[1] : null;
    final String countNoteText = _buildCountNoteText(countNoteItem);
    final bool hasMainCount = mainCountItem != null && (mainCountItem.count != null || mainCountItem.name.isNotEmpty);
    return TapScaleWidget(
      onTap: () {
        controller.onTapDoor(door.code);
      },
      sclae: 1.01,
      borderRadius: 20.wMin,
      backColor: AppTheme.cZhenxieFontPrimary.color.withValues(alpha: 0.04),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.wMin),
          border: Border.all(
            color: AppTheme.cZhenxieBorderPrimary.color,
            width: 1.wMin,
          ),
          color: AppTheme.cZhenxieBackgroundPrimary.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    door.title ?? "",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFontValue.sourceHanSerifCN,
                      color: AppTheme.cZhenxieFontPrimary.color,
                    ),
                  ),
                ),
                SizedBox(width: 12.wMin),
                if (hasMainCount || countNoteText.isNotEmpty) ...[
                  RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFontValue.sourceHanSerifCN,
                        color: AppTheme.cZhenxieFontSecondary.color,
                      ),
                      children: [
                        if (mainCountItem?.count != null)
                          TextSpan(
                            text: "${mainCountItem!.count}",
                            style: TextStyle(
                              fontSize: 18.wMin,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppFontValue.sourceHanSerifCN,
                              color: AppTheme.cZhenxieFontSecondary.color,
                            ),
                          ),
                        if ((mainCountItem?.name ?? "").isNotEmpty)
                          TextSpan(
                            text: mainCountItem?.count != null ? " ${mainCountItem!.name}" : mainCountItem!.name,
                          ),
                        if (countNoteText.isNotEmpty) TextSpan(text: " · $countNoteText"),
                      ],
                    ),
                  ),
                ],
                  
              ],
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.wMin),
                  child: _buildSpecimenWidget(door),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    door.description ?? "",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cZhenxieFontTertiary.color,
                    ),
                  ),
                ),
                Text(
                  "→",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cZhenxieFontSecondary.color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecimenWidget(ZhenxieLexisHomeDoorItem door) {
    switch (door.code) {
      case "wordMorphology":
        return _buildMorphologySpecimenWidget(door);
      case "etymology":
        return _buildEtymologySpecimenWidget(door);
      case "phraseParadigm":
        return _buildPhraseParadigmsSpecimenWidget(door);
      case "phrasePair":
        return _buildPhrasePairsSpecimenWidget(door);
      case "phraseCluster":
        return _buildPhraseClustersSpecimenWidget(door);
      case "phraseStructure":
        return _buildPhraseStructuresSpecimenWidget(door);
      case "phraseGrammaticalProfile":
        return _buildPhraseProfilesSpecimenWidget(door);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMorphologySpecimenWidget(ZhenxieLexisHomeDoorItem door) {
    final List<ZhenxieLexisHomeSlotCombinationItem> rows = door.slotCombinationItems;
    if (rows.isEmpty) return const SizedBox.shrink();
    return IntrinsicWidth(
      child: Column(
        spacing: 12.wMin,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(rows.length, (index) {
          return _buildMorphRowWidget(rows[index]);
        }),
      ),
    );
  }

  Widget _buildMorphRowWidget(ZhenxieLexisHomeSlotCombinationItem row) {
    final List<ZhenxieLexisHomeSlotItem> list = row.slots;
    final String tipText = list.map((item) => item.tip ?? "").firstWhere((item) => item.isNotEmpty, orElse: () => "");
    final Widget rowWidget = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8.wMin,
      children: list.asMap().entries.map((entry) {
        final ZhenxieLexisHomeSlotItem item = entry.value;
          if(_hasSlotStyle(item.currentThemeStyle)){
          return _buildSlotChipWidget(
            item,
            padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 8.wMin),
            borderRadius: BorderRadius.circular(8.wMin),
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
          );
        }
        return Text(
          item.content,
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cZhenxieFontSecondary.color,
          ),
        );
      }).toList(),
    );
    if (tipText.isEmpty) return rowWidget;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        rowWidget,
        SizedBox(width: 14.wMin),
        Text(
          tipText,
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cZhenxieFontTertiary.color,
          ),
        ),
      ],
    );
  }

  Widget _buildEtymologySpecimenWidget(ZhenxieLexisHomeDoorItem door) {
    final List<ZhenxieLexisHomeSlotCombinationItem> rows = door.slotCombinationItems;
    final ZhenxieLexisHomeSlotItem? root = rows.isNotEmpty && rows[0].slots.isNotEmpty ? rows[0].slots.first : null;
    final ZhenxieLexisHomeSlotItem? trunk = rows.length > 1 && rows[1].slots.isNotEmpty ? rows[1].slots.first : null;
    final List<ZhenxieLexisHomeSlotItem> leaves =
        rows.length > 2 ? rows[2].slots.where((item) => item.content.isNotEmpty).toList() : const <ZhenxieLexisHomeSlotItem>[];
    if (root == null && trunk == null && leaves.isEmpty) return const SizedBox.shrink();
    final double treeWidth = 320.wMin;
    final double treeHeight = 156.wMin;
    final double branchRowWidth = 304.wMin;
    final double branchGap = 24.wMin;
    final double branchWidth = leaves.isEmpty ? branchRowWidth : (branchRowWidth - branchGap * (leaves.length - 1)) / leaves.length;
    final double rowLeft = (treeWidth - branchRowWidth) / 2;
    return SizedBox(
      width: treeWidth,
      height: treeHeight,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(treeWidth, treeHeight),
            painter: _ZxEtymologyTreePainter(
              rootX: treeWidth / 2,
              anchorY: 60.wMin,
              leafTopY: 110.wMin,
              leafXs: List.generate(leaves.length, (index) {
                return rowLeft + branchWidth / 2 + index * (branchWidth + branchGap);
              }),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                root?.content??"",
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cZhenxieFontPrimary.color,
                  fontFamily: AppFontValue.robotoMono,
                ),
              ),
              SizedBox(height: 6.wMin),
              Text(
                trunk?.content??"",
                style: TextStyle(
                  fontSize: 16.wMin,
                  height: 1,
                  fontWeight: FontWeight.w400,
                  color: ColorUtils.parseColor(trunk?.currentThemeStyle.color) ?? AppTheme.cZhenxieAmberText.color,
                ),
              ),
              SizedBox(height: 52.wMin),
              if (leaves.isNotEmpty) ...[
                SizedBox(
                  width: branchRowWidth,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(leaves.length * 2 - 1, (index) {
                      if (index.isOdd) return SizedBox(width: branchGap);
                      final ZhenxieLexisHomeSlotItem leaf = leaves[index ~/ 2];
                      return SizedBox(
                        width: branchWidth,
                        child: Text(
                          leaf.content,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: 16.wMin,
                            height: 1,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cZhenxieFontSecondary.color,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhraseParadigmsSpecimenWidget(ZhenxieLexisHomeDoorItem door) {
    final List<ZhenxieLexisHomeSlotCombinationItem> rows =
        door.slotCombinationItems.where((item) => item.slots.any((slot) => slot.content.isNotEmpty)).toList();
    if (rows.isEmpty) return const SizedBox.shrink();
    final ZhenxieLexisHomeSlotCombinationItem? leadRow =
        rows.firstWhereOrNull((item) => item.slots.where((slot) => slot.content.isNotEmpty).length > 1);
    if (leadRow == null) return const SizedBox.shrink();
    final List<ZhenxieLexisHomeSlotItem> leadSlots = leadRow.slots.where((item) => item.content.isNotEmpty).toList();
    final ZhenxieLexisHomeSlotItem lead = leadSlots.first;
    final String tipText =
        rows.expand((item) => item.slots).map((item) => item.tip ?? "").firstWhere((item) => item.isNotEmpty, orElse: () => "");
    final List<ZhenxieLexisHomeSlotItem> dialItems = <ZhenxieLexisHomeSlotItem>[];
    for (final ZhenxieLexisHomeSlotCombinationItem row in rows) {
      final List<ZhenxieLexisHomeSlotItem> currentSlots = row.slots.where((item) => item.content.isNotEmpty).toList();
      if (currentSlots.isEmpty) continue;
      if (identical(row, leadRow)) {
        final ZhenxieLexisHomeSlotItem? legacyTail = currentSlots.length > 2 &&
                !_hasSlotStyle(currentSlots.last.currentThemeStyle) &&
                !currentSlots.last.highlight
            ? currentSlots.last
            : null;
        final int end = legacyTail == null ? currentSlots.length : currentSlots.length - 1;
        dialItems.addAll(currentSlots.sublist(1, end));
        continue;
      }
      dialItems.addAll(currentSlots);
    }
    final String legacyTailText = tipText.isNotEmpty
        ? ""
        : leadSlots.length > 2 && !_hasSlotStyle(leadSlots.last.currentThemeStyle) && !leadSlots.last.highlight
            ? leadSlots.last.content
            : "";
    final String suffixText = tipText.isNotEmpty ? tipText : legacyTailText;
    if (lead.content.isEmpty || dialItems.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          lead.content,
          style: TextStyle(
            fontSize: 22.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cZhenxieFontPrimary.color,
            fontFamily: AppFontValue.robotoMono,
          ),
        ),
        SizedBox(width: 18.wMin),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.wMin),
            border: Border.all(color: AppTheme.cBorderDefault.color, width: 1.wMin),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: dialItems.map((item) => _buildDialItemWidget(item)).toList(),
          ),
        ),
        if (suffixText.isNotEmpty) SizedBox(width: 16.wMin),
        if (suffixText.isNotEmpty)
          Text(
            suffixText,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontSecondary.color,
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
      ],
    );
  }

  Widget _buildDialItemWidget(ZhenxieLexisHomeSlotItem item) {
    final ZhenxieLexisHomeSlotStyle style = item.currentThemeStyle;
    final Color? textColor = ColorUtils.parseColor(style.color);
    return Container(
      constraints: BoxConstraints(
        minWidth: 92.wMin,
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        color: ColorUtils.parseColor(style.backgroundColor) ??
            (item.highlight ? AppTheme.cZhenxieColorPrimary.color.withValues(alpha: 0.22) : Colors.transparent),
      ),
      child: Text(
        item.content,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: TextStyle(
          fontSize: 19.wMin,
          fontWeight: FontWeight.w500,
          color: textColor ?? (item.highlight ? AppTheme.cZhenxieFontPrimary.color : AppTheme.cZhenxieFontSecondary.color),
          fontFamily: AppFontValue.robotoMono,
        ),
      ),
    );
  }

  Widget _buildPhrasePairsSpecimenWidget(ZhenxieLexisHomeDoorItem door) {
    final List<ZhenxieLexisHomeSlotCombinationItem> rows = door.slotCombinationItems.where((item) => item.slots.isNotEmpty).toList();
    if (rows.isEmpty) return const SizedBox.shrink();
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16.wMin,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(rows.length, (index) {
          return _buildPhrasePairRowWidget(rows[index], rowIndex: index);
        }),
      ),
    );
  }

  Widget _buildPhrasePairRowWidget(ZhenxieLexisHomeSlotCombinationItem row, {required int rowIndex}) {
    final List<ZhenxieLexisHomeSlotItem> slots = row.slots;
    if (slots.length < 3) return const SizedBox.shrink();
    final bool isDashed = rowIndex > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPhrasePairItemWidget(slots[0], isDashed: isDashed),
        SizedBox(width: 12.wMin),
        Text(
          slots[1].content,
          style: TextStyle(
            fontSize: 22.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cZhenxieFontSecondary.color,
          ),
        ),
        SizedBox(width: 12.wMin),
        _buildPhrasePairItemWidget(slots[2], isDashed: isDashed),
      ],
    );
  }

  Widget _buildPhrasePairItemWidget(ZhenxieLexisHomeSlotItem item, {required bool isDashed}) {
    final Widget content = Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 4.wMin),
      child: Text(
        item.content,
        style: TextStyle(
          fontSize: 20.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cZhenxieFontPrimary.color,
          fontFamily: AppFontValue.robotoMono,
        ),
      ),
    );
    if (!isDashed) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          border: Border.all(color: AppTheme.cBorderDefault.color, width: 1.wMin),
        ),
        child: content,
      );
    }
    return Opacity(
      opacity: 0.7,
      child: DottedBorder(
        color: AppTheme.cBorderDefault.color,
        strokeWidth: 1.wMin,
        dashPattern: [4.wMin, 3.wMin],
        borderType: BorderType.RRect,
        radius: Radius.circular(8.wMin),
        padding: EdgeInsets.zero,
        child: content,
      ),
    );
  }

  Widget _buildPhraseClustersSpecimenWidget(ZhenxieLexisHomeDoorItem door) {
    final ZhenxieLexisHomeSlotCombinationItem? row = door.slotCombinationItems.isEmpty ? null : door.slotCombinationItems.first;
    if (row == null || row.slots.isEmpty) return const SizedBox.shrink();
    final ZhenxieLexisHomeSlotItem lead = row.slots.first;
    final List<ZhenxieLexisHomeSlotItem> bubbles = row.slots.skip(1).where((item) => item.content.isNotEmpty).toList();
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4.wMin),
          child: Text(
            lead.content,
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cZhenxieFontPrimary.color,
              fontFamily: AppFontValue.robotoMono,
            ),
          ),
        ),
        if (bubbles.isNotEmpty) SizedBox(width: 10.wMin),
        if (bubbles.isNotEmpty)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(bubbles.length * 2 - 1, (index) {
              if (index.isOdd) return SizedBox(height: 6.wMin);
              return _buildPhraseBubbleWidget(bubbles[index ~/ 2]);
            }),
          ),
      ],
    );
  }

  Widget _buildPhraseBubbleWidget(ZhenxieLexisHomeSlotItem item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999.wMin),
        border: Border.all(color: AppTheme.cBorderDefault.color, width: 1.wMin),
      ),
      child: Text(
        item.content,
        style: TextStyle(
          fontSize: 20.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cZhenxieFontPrimary.color,
          fontFamily: AppFontValue.robotoMono,
        ),
      ),
    );
  }

  Widget _buildPhraseStructuresSpecimenWidget(ZhenxieLexisHomeDoorItem door) {
    final ZhenxieLexisHomeSlotCombinationItem? row = door.slotCombinationItems.isEmpty ? null : door.slotCombinationItems.first;
    if (row == null || row.slots.isEmpty) return const SizedBox.shrink();
    return IntrinsicWidth(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(row.slots.length * 2 - 1, (index) {
          if (index.isOdd) return SizedBox(width: 12.wMin);
          final ZhenxieLexisHomeSlotItem item = row.slots[index ~/ 2];
            final ZhenxieLexisHomeSlotStyle style = item.currentThemeStyle;
            final Color? titleColor = ColorUtils.parseColor(style.color);
            final Color? borderColor = ColorUtils.parseColor(style.borderColor);
            final Color? backgroundColor = ColorUtils.parseColor(style.backgroundColor);
          return Container(
            constraints: BoxConstraints(minWidth: 112.wMin),
            height: 92.wMin,
            padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 9.wMin),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12.wMin),
              border: borderColor == null
                  ? null
                  : Border.all(
                      color: borderColor,
                      width: 1.wMin,
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((item.name ?? "").isNotEmpty && titleColor != null)
                  Text(
                    item.name ?? "",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w400,
                      color: titleColor,
                    ),
                  ),
                const Spacer(),
                if (item.content.isNotEmpty)
                  Text(
                    item.content,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 34.wMin,
                      height: 1,
                      fontWeight: FontWeight.w500,
                        color: titleColor ?? AppTheme.cZhenxieFontPrimary.color,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPhraseProfilesSpecimenWidget(ZhenxieLexisHomeDoorItem door) {
    final List<ZhenxieLexisHomeSlotCombinationItem> rows = door.slotCombinationItems.where((item) => item.slots.isNotEmpty).toList();
    if (rows.isEmpty) return const SizedBox.shrink();
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(rows.length * 2 - 1, (index) {
          if (index.isOdd) return SizedBox(height: 16.wMin);
          return _buildPhraseProfileRowWidget(rows[index ~/ 2]);
        }),
      ),
    );
  }

  Widget _buildPhraseProfileRowWidget(ZhenxieLexisHomeSlotCombinationItem row) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((row.slotTitle ?? "").isNotEmpty)
          Text(
            row.slotTitle ?? "",
            style: TextStyle(
              fontSize: 14.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontSecondary.color,
            ),
          ),
        if ((row.slotTitle ?? "").isNotEmpty) SizedBox(height: 6.wMin),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 24.wMin,
              height: 1.2,
              fontWeight: FontWeight.w400,
              fontFamily: AppFontValue.robotoMono,
              color: AppTheme.cZhenxieFontPrimary.color,
            ),
            children: row.slots.map((item) {
              if (!item.highlight) {
                return TextSpan(text: item.content);
              }
                final ZhenxieLexisHomeSlotStyle style = item.currentThemeStyle;
              final Color borderColor =
                    ColorUtils.parseColor(style.borderColor) ?? AppTheme.cZhenxieColorPrimary.color.withValues(alpha: 0.75);
              final Color backgroundColor =
                    ColorUtils.parseColor(style.backgroundColor) ?? AppTheme.cZhenxieColorPrimary.color;
              return WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 1.wMin),
                  padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.wMin),
                    border: Border(
                      bottom: BorderSide(
                        color: borderColor,
                        width: 1.wMin,
                      ),
                    ),
                    color: backgroundColor.withValues(alpha: 0.2),
                  ),
                  child: Text(
                    item.content,
                    style: TextStyle(
                      fontSize: 24.wMin,
                      height: 1.2,
                      fontWeight: FontWeight.w400,
                      fontFamily: AppFontValue.robotoMono,
                      color: AppTheme.cZhenxieFontPrimary.color,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _buildCountNoteText(ZhenxieLexisHomeCountItem? item) {
    if (item == null) return "";
    if (item.count != null && item.name.isNotEmpty) return "${item.count} ${item.name}";
    if (item.count != null) return "${item.count}";
    if (item.name.isNotEmpty) return item.name;
    return "";
  }

  bool _hasSlotStyle(ZhenxieLexisHomeSlotStyle style) {
    return (style.color ?? "").isNotEmpty || (style.backgroundColor ?? "").isNotEmpty || (style.borderColor ?? "").isNotEmpty;
  }

  Widget _buildSlotChipWidget(
    ZhenxieLexisHomeSlotItem item, {
    required EdgeInsetsGeometry padding,
    required BorderRadiusGeometry borderRadius,
    required double fontSize,
    required FontWeight fontWeight,
  }) {
    final ZhenxieLexisHomeSlotStyle style = item.currentThemeStyle;
    final Color borderColor = ColorUtils.parseColor(style.borderColor) ??
        (item.highlight ? AppTheme.cZhenxieColorPrimary.color.withValues(alpha: 0.55) : AppTheme.cBorderDefault.color);
    final Color backgroundColor = ColorUtils.parseColor(style.backgroundColor) ??
        (item.highlight ? AppTheme.cZhenxieColorPrimary.color.withValues(alpha: 0.14) : Colors.transparent);
    final Color textColor = ColorUtils.parseColor(style.color) ?? AppTheme.cZhenxieFontPrimary.color;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: borderColor, width: 1.wMin),
        color: backgroundColor,
      ),
      child: Text(
        item.content,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          fontFamily: AppFontValue.robotoMono,
        ),
      ),
    );
  }
}

class _ZxEtymologyTreePainter extends CustomPainter {
  final double rootX;
  final double anchorY;
  final double leafTopY;
  final List<double> leafXs;

  const _ZxEtymologyTreePainter({
    required this.rootX,
    required this.anchorY,
    required this.leafTopY,
    required this.leafXs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint basePaint = Paint()
      ..color = const Color(0xFFF5C16C).withValues(alpha: 0.16)
      ..strokeWidth = 6.wMin
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Paint linePaint = Paint()
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.55)
      ..strokeWidth = 1.7.wMin
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final double leafX in leafXs) {
      final double mid = (leafTopY - anchorY) / 1.7;
      final Path path = Path()
        ..moveTo(rootX, anchorY)
        ..cubicTo(rootX, anchorY + mid, leafX, leafTopY - mid, leafX, leafTopY);
      canvas.drawPath(path, basePaint);
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ZxEtymologyTreePainter oldDelegate) {
    return oldDelegate.rootX != rootX || oldDelegate.anchorY != anchorY || oldDelegate.leafTopY != leafTopY || oldDelegate.leafXs != leafXs;
  }
}
