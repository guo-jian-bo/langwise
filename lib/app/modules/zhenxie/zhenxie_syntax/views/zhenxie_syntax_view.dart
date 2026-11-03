import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/values/app_font_value.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/color_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../bindings/zhenxie_syntax_binding.dart';
import '../controllers/zhenxie_syntax_controller.dart';

class ZhenxieSyntaxView extends GetView<ZhenxieSyntaxController> {
  final String tagText;
  const ZhenxieSyntaxView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieSyntaxView(tagText: tag),
      binding: ZhenxieSyntaxBinding(tagText: tag),
      routeName: Routes.ZHENXIE_SYNTAX,
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
      final List<ZhenxieSyntaxHomeDisplayGroup> groupList = controller.buildDisplayGroupList();
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

  Widget _buildGroupColumnWidget(ZhenxieSyntaxHomeDisplayGroup group) {
    final List<ZhenxieSyntaxHomeDoorItem> doors = group.items;
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
              if ((group.title ?? "").isNotEmpty)
                Text(
                  group.title ?? "",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFontValue.sourceHanSerifCN,
                    color: AppTheme.cZhenxieFontPrimary.color,
                  ),
                ),
              if ((group.description ?? "").isNotEmpty) ...[
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
              ] else
                const Spacer(),
              if (doors.isNotEmpty) SizedBox(width: 12.wMin),
              if (doors.isNotEmpty)
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
        if (doors.isNotEmpty) SizedBox(height: 16.wMin),
        if (doors.isNotEmpty)
          Expanded(
            child: Column(
              spacing: 16.wMin,
              children: List.generate(doors.length, (index) {
                return Expanded(child: _buildDoorCardWidget(doors[index]));
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildDoorCardWidget(ZhenxieSyntaxHomeDoorItem door) {
    final ZhenxieSyntaxHomeCountItem? countItem = door.items.isEmpty ? null : door.items.first;
    final String countText = _buildCountText(countItem);
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
                if (countText.isNotEmpty) SizedBox(width: 12.wMin),
                if (countText.isNotEmpty)
                  Text(
                    countText,
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppFontValue.sourceHanSerifCN,
                      color: AppTheme.cZhenxieFontSecondary.color,
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.wMin),
                  child: door.code == "sentenceLinking" || door.code == "pyramidPattern" || door.code == "sentenceParadigm"
                      ? _buildSpecimenWidget(door)
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: _buildSpecimenWidget(door),
                        ),
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

  Widget _buildSpecimenWidget(ZhenxieSyntaxHomeDoorItem door) {
    switch (door.code) {
      case "sentencePattern":
        return _buildSlotsSpecimenWidget(door);
      case "pyramidPattern":
        return _buildPyramidSpecimenWidget(door);
      case "sentenceParadigm":
        return _buildContrastSpecimenWidget(door);
      case "sentenceGrammarGrid":
        return _buildMiniGridSpecimenWidget(door);
      case "sentenceLinking":
        return _buildPairChainSpecimenWidget(door);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSlotsSpecimenWidget(ZhenxieSyntaxHomeDoorItem door) {
    final List<ZhenxieSyntaxHomeSlotCombinationItem> rows = door.slotCombinationItems.where((item) => item.slots.isNotEmpty).toList();
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(rows.length * 2 - 1, (index) {
        if (index.isOdd) return SizedBox(height: 10.wMin);
        return _buildSlotRowWidget(rows[index ~/ 2]);
      }),
    );
  }

  Widget _buildSlotRowWidget(ZhenxieSyntaxHomeSlotCombinationItem row) {
    final List<ZhenxieSyntaxHomeSlotItem> slots = row.slots.where((item) => item.content.isNotEmpty).toList();
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(slots.length * 2 - 1, (index) {
        if (index.isOdd) return SizedBox(width: 10.wMin);
        return _buildSlotWidget(slots[index ~/ 2]);
      }),
    );
  }

  Widget _buildSlotWidget(ZhenxieSyntaxHomeSlotItem item) {
    final currentStyle = item.currentThemeStyle;
    final Color? textColor = ColorUtils.parseColor(currentStyle.color);
    final Color? backgroundColor = ColorUtils.parseColor(currentStyle.backgroundColor);
    final Color? borderColor = ColorUtils.parseColor(currentStyle.borderColor);
    final bool isDashed = !_hasEnglishLetter(item.content);
    final Widget content = Container(
      padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 9.wMin),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.name ?? "",
            style: TextStyle(
              fontSize: 14.wMin,
              fontWeight: FontWeight.w400,
              fontFamily: AppFontValue.sourceHanSerifCN,
              color: AppTheme.cZhenxieFontSecondary.color,
            ),
          ),
          SizedBox(height: 8.wMin),
          Text(
            item.content,
            style: TextStyle(
              fontSize: 18.wMin,
              height: 1,
              fontWeight: FontWeight.w500,
              fontFamily: AppFontValue.robotoMono,
              color: textColor ?? AppTheme.cZhenxieFontPrimary.color,
            ),
          ),
        ],
      ),
    );
    if (borderColor == null) return content;
    if (!isDashed) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          border: Border.all(color: borderColor, width: 1.wMin),
        ),
        child: content,
      );
    }
    return DottedBorder(
      color: borderColor,
      strokeWidth: 1.wMin,
      dashPattern: [4.wMin, 3.wMin],
      borderType: BorderType.RRect,
      radius: Radius.circular(12.wMin),
      child: content,
    );
  }

  Widget _buildPyramidSpecimenWidget(ZhenxieSyntaxHomeDoorItem door) {
    final List<ZhenxieSyntaxHomeSlotCombinationItem> rows = door.slotCombinationItems.where((item) => item.slots.isNotEmpty).toList();
    if (rows.isEmpty) return const SizedBox.shrink();
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(rows.length * 2 - 1, (index) {
          if (index.isOdd) return SizedBox(height: 10.wMin);
          return _buildInlineSentenceWidget(
            rows[index ~/ 2].slots,
            textStyle: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w400,
              fontFamily: AppFontValue.robotoMono,
              color: AppTheme.cZhenxieFontPrimary.color,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContrastSpecimenWidget(ZhenxieSyntaxHomeDoorItem door) {
    final List<ZhenxieSyntaxHomeSlotCombinationItem> rows = door.slotCombinationItems.where((item) => item.slots.isNotEmpty).toList();
    if (rows.isEmpty) return const SizedBox.shrink();
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(rows.length * 2 - 1, (index) {
          if (index.isOdd) return SizedBox(height: 10.wMin);
          final ZhenxieSyntaxHomeSlotCombinationItem row = rows[index ~/ 2];
          final ZhenxieSyntaxHomeSlotItem? note = _findContrastNoteItem(row);
          final List<ZhenxieSyntaxHomeSlotItem> textSlots = note == null ? row.slots : row.slots.where((item) => item != note).toList();
          if (note == null) {
            return _buildContrastInlineSentenceWidget(
              textSlots,
              textStyle: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w400,
                fontFamily: AppFontValue.robotoMono,
                color: AppTheme.cZhenxieFontPrimary.color,
              ),
            );
          }
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildContrastInlineSentenceWidget(
                textSlots,
                textStyle: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                  fontFamily: AppFontValue.robotoMono,
                  color: AppTheme.cZhenxieFontPrimary.color,
                ),
              ),
              SizedBox(width: 12.wMin),
              Text(
                note.content,
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontSecondary.color,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  ZhenxieSyntaxHomeSlotItem? _findContrastNoteItem(ZhenxieSyntaxHomeSlotCombinationItem row) {
    if (row.slots.isEmpty) return null;
    final ZhenxieSyntaxHomeSlotItem item = row.slots.last;
    if (item.highlight) return null;
    if (_hasSlotStyle(item.currentThemeStyle)) return null;
    if (!item.content.startsWith("←")) return null;
    return item;
  }

  /// 对照句示意单独使用更清晰的高亮样式，避免影响其他门卡的行内句子渲染。
  Widget _buildContrastInlineSentenceWidget(
    List<ZhenxieSyntaxHomeSlotItem> slots, {
    required TextStyle textStyle,
  }) {
    final List<ZhenxieSyntaxHomeSlotItem> visibleSlots = slots.where((item) => item.content.trim().isNotEmpty).toList();
    final List<InlineSpan> spans = <InlineSpan>[];
    for (int index = 0; index < visibleSlots.length; index++) {
      final ZhenxieSyntaxHomeSlotItem item = visibleSlots[index];
      final String currentText = item.content.trim();
      spans.add(_buildContrastSentenceSpan(item, text: currentText, textStyle: textStyle));
      if (index < visibleSlots.length - 1 && _shouldInsertEnglishWordSpace(currentText, visibleSlots[index + 1].content.trim())) {
        spans.add(const TextSpan(text: " "));
      }
    }
    return RichText(
      text: TextSpan(
        style: textStyle,
        children: spans,
      ),
    );
  }

  /// 对照句高亮文字固定使用深色正文，强调色只负责底色和下划线，保证可读性。
  InlineSpan _buildContrastSentenceSpan(
    ZhenxieSyntaxHomeSlotItem item, {
    required String text,
    required TextStyle textStyle,
  }) {
    if (!item.highlight) {
      return _buildSentenceSpan(item, text: text, textStyle: textStyle);
    }
    final currentStyle = item.currentThemeStyle;
    final Color accentColor = ColorUtils.parseColor(currentStyle.color) ?? AppTheme.cZhenxieColorPrimary.color;
    final Color? backgroundColor = ColorUtils.parseColor(currentStyle.backgroundColor);
    final Color? borderColor = ColorUtils.parseColor(currentStyle.borderColor);
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.wMin, vertical: 1.wMin),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: borderColor ?? accentColor,
              width: 1.wMin,
            ),
          ),
          color: backgroundColor ?? accentColor.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(3.wMin),
        ),
        child: Text(
          text,
          style: textStyle.copyWith(
            color: AppTheme.cZhenxieFontPrimary.color,
          ),
        ),
      ),
    );
  }

  Widget _buildInlineSentenceWidget(
    List<ZhenxieSyntaxHomeSlotItem> slots, {
    required TextStyle textStyle,
  }) {
    final List<ZhenxieSyntaxHomeSlotItem> visibleSlots = slots.where((item) => item.content.trim().isNotEmpty).toList();
    final List<InlineSpan> spans = <InlineSpan>[];
    for (int index = 0; index < visibleSlots.length; index++) {
      final ZhenxieSyntaxHomeSlotItem item = visibleSlots[index];
      final String currentText = item.content.trim();
      spans.add(_buildSentenceSpan(item, text: currentText, textStyle: textStyle));
      if (index < visibleSlots.length - 1 && _shouldInsertEnglishWordSpace(currentText, visibleSlots[index + 1].content.trim())) {
        spans.add(const TextSpan(text: " "));
      }
    }
    return RichText(
      text: TextSpan(
        style: textStyle,
        children: spans,
      ),
    );
  }

  InlineSpan _buildSentenceSpan(
    ZhenxieSyntaxHomeSlotItem item, {
    required String text,
    required TextStyle textStyle,
  }) {
    if (!item.highlight) {
      return TextSpan(
        text: text,
        style: TextStyle(
          color: ColorUtils.parseColor(item.currentThemeStyle.color) ?? AppTheme.cZhenxieFontPrimary.color,
        ),
      );
    }
    final currentStyle = item.currentThemeStyle;
    final Color? textColor = ColorUtils.parseColor(currentStyle.color);
    final Color? backgroundColor = ColorUtils.parseColor(currentStyle.backgroundColor);
    final Color? borderColor = ColorUtils.parseColor(currentStyle.borderColor);
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.wMin),
        decoration: BoxDecoration(
          border: borderColor == null
              ? null
              : Border(
                  bottom: BorderSide(
                    color: borderColor,
                    width: 1.wMin,
                  ),
                ),
          color: backgroundColor,
          borderRadius: BorderRadius.circular(3.wMin),
        ),
        child: Text(
          text,
          style: textStyle.copyWith(
            color: textColor ?? AppTheme.cZhenxieFontPrimary.color,
          ),
        ),
      ),
    );
  }

  /// 英文内容被拆成多个 slot 时，补一个词间空格，避免单词直接粘连。
  bool _shouldInsertEnglishWordSpace(String currentText, String nextText) {
    if (currentText.isEmpty || nextText.isEmpty) return false;
    if (RegExp(r'\s$').hasMatch(currentText) || RegExp(r'^\s').hasMatch(nextText)) return false;
    return RegExp(r'[A-Za-z0-9]$').hasMatch(currentText) && RegExp(r'^[A-Za-z0-9]').hasMatch(nextText);
  }

  Widget _buildMiniGridSpecimenWidget(ZhenxieSyntaxHomeDoorItem door) {
    final List<ZhenxieSyntaxHomeSlotCombinationItem> rows = door.slotCombinationItems;
    if (rows.isEmpty) return const SizedBox.shrink();
    final ZhenxieSyntaxHomeSlotCombinationItem headerRow = rows.first;
    final List<ZhenxieSyntaxHomeSlotCombinationItem> bodyRows = rows.skip(1).toList();
    return Padding(
      padding: EdgeInsets.only(right: 40.wMin),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGridLabelWidget(text: "", width: 72),
              ...headerRow.slots.map((item) => _buildGridHeaderCellWidget(item.content)),
            ],
          ),
          ...bodyRows.asMap().entries.expand((entry) {
            final List<Widget> children = <Widget>[
              SizedBox(height: 6.wMin),
              _buildMiniGridRowWidget(entry.value),
            ];
            return children;
          }),
        ],
      ),
    );
  }

  Widget _buildGridHeaderCellWidget(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 6.wMin),
      child: SizedBox(
        width: 96.wMin,
        height: 34.wMin,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontSecondary.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniGridRowWidget(ZhenxieSyntaxHomeSlotCombinationItem row) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildGridLabelWidget(text: row.slotTitle ?? "", width: 72),
        ...row.slots.map((item) => _buildGridCellWidget(item)),
      ],
    );
  }

  Widget _buildGridLabelWidget({required String text, double? width}) {
    return SizedBox(
      width: width?.wMin ?? 86.wMin,
      height: 34.wMin,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cZhenxieFontSecondary.color,
          ),
        ),
      ),
    );
  }

  Widget _buildGridCellWidget(ZhenxieSyntaxHomeSlotItem item) {
    final bool hasContent = item.content.isNotEmpty;
    final currentStyle = item.currentThemeStyle;
    final Color? textColor = ColorUtils.parseColor(currentStyle.color);
    final Color? backgroundColor = ColorUtils.parseColor(currentStyle.backgroundColor);
    final Widget child = SizedBox(
      width: 96.wMin,
      height: 34.wMin,
      child: Center(
        child: Text(
          item.content,
          style: TextStyle(
            fontSize: 18.wMin,
            height: 1,
            fontWeight: FontWeight.w400,
            color: hasContent ? (textColor) : AppTheme.cZhenxieFontSecondary.color,
          ),
        ),
      ),
    );
    if (hasContent) {
      return Container(
        margin: EdgeInsets.only(left: 6.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.wMin),
          color: backgroundColor,
        ),
        child: child,
      );
    }
    return Padding(
      padding: EdgeInsets.only(left: 6.wMin),
      child: DottedBorder(
        color: AppTheme.cZhenxieBorderPrimary.color,
        strokeWidth: 1.wMin,
        dashPattern: [4.wMin, 3.wMin],
        borderType: BorderType.RRect,
        radius: Radius.circular(6.wMin),
        padding: EdgeInsets.zero,
        child: child,
      ),
    );
  }

  Widget _buildPairChainSpecimenWidget(ZhenxieSyntaxHomeDoorItem door) {
    final List<ZhenxieSyntaxHomeSlotCombinationItem> rows = door.slotCombinationItems.where((item) => item.slots.isNotEmpty).toList();
    if (rows.isEmpty) return const SizedBox.shrink();
    final List<Widget> children = <Widget>[];
    for (int index = 0; index < rows.length; index++) {
      final ZhenxieSyntaxHomeSlotCombinationItem row = rows[index];
      if (index > 0 && (row.slotTitle ?? "").isNotEmpty) {
        if (children.isNotEmpty) children.add(SizedBox(height: 12.wMin));
        children.add(_buildPairLinkWidget(row.slotTitle ?? ""));
        children.add(SizedBox(height: 12.wMin));
      } else if (children.isNotEmpty) {
        children.add(SizedBox(height: 12.wMin));
      }
      final List<ZhenxieSyntaxHomeSlotItem> slots = row.slots.where((item) => item.content.isNotEmpty).toList();
      if (slots.isNotEmpty) {
        children.add(
          _buildPairRowWidget(
            isQuestion: true,
            text: slots.first.content,
            textStyle: TextStyle(
              fontSize: 24.wMin,
              height: 1.2,
              fontWeight: FontWeight.w400,
              fontFamily: AppFontValue.robotoMono,
              color: AppTheme.cZhenxieFontPrimary.color,
            ),
          ),
        );
      }
      if (slots.length > 1) {
        children.add(SizedBox(height: 12.wMin));
        children.add(
          _buildPairRowWidget(
            isQuestion: false,
            text: slots[1].content,
            textStyle: TextStyle(
              fontSize: 24.wMin,
              height: 1.2,
              fontWeight: FontWeight.w400,
              fontFamily: AppFontValue.robotoMono,
              color: AppTheme.cZhenxieFontPrimary.color,
            ),
          ),
        );
      }
    }
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildPairRowWidget({
    required bool isQuestion,
    required String text,
    required TextStyle textStyle,
  }) {
    final double fontSize = textStyle.fontSize ?? 14.wMin;
    final double lineHeight = (textStyle.height ?? 1) * fontSize;
    final double dotSize = 10.wMin;
    final double dotTopPadding = (lineHeight - dotSize) <= 0 ? 0 : (lineHeight - dotSize) / 2;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: dotTopPadding, left: 3.wMin, right: 10.wMin),
          child: Container(
            width: 12.wMin,
            height: 12.wMin,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isQuestion ? Colors.transparent : AppTheme.cZhenxieFontTertiary.color,
              border: isQuestion ? Border.all(color: AppTheme.cZhenxieFontTertiary.color, width: 1.5.wMin) : null,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: textStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildPairLinkWidget(String label) {
    return Padding(
      padding: EdgeInsets.only(left: 14.wMin),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 1.wMin,
            height: 14.wMin,
            color: AppTheme.cZhenxieColorPrimary.color.withValues(alpha: 0.6),
          ),
          SizedBox(width: 8.wMin),
          Text(
            label,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieColorPrimary.color,
            ),
          ),
        ],
      ),
    );
  }

  String _buildCountText(ZhenxieSyntaxHomeCountItem? item) {
    if (item == null) return "";
    if (item.count != null && item.name.isNotEmpty) return "${item.count} ${item.name}";
    if (item.count != null) return "${item.count}";
    if (item.name.isNotEmpty) return item.name;
    return "";
  }

  bool _hasEnglishLetter(String text) {
    return RegExp(r'[A-Za-z]').hasMatch(text);
  }

  bool _hasSlotStyle(ZhenxieSyntaxHomeSlotStyle style) {
    return (style.color ?? "").isNotEmpty || (style.backgroundColor ?? "").isNotEmpty || (style.borderColor ?? "").isNotEmpty;
  }
}
