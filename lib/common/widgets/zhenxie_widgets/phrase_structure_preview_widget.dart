import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../entities/entities.dart';
import '../../public_controller/config_controller.dart';
import '../../../theme/theme.dart';
import '../../../utils/utils.dart';

/// 短语结构预览组件。
///
/// 输入为短语结构 item 列表，组件会按角色配置自动渲染标题、颜色和自适应宽高。
class PhraseStructurePreviewWidget extends StatelessWidget {
  final List<CardPhraseStructureItem?>? items;

  /// 标题字号。
  final double? titleFontSize;

  /// 内容最大字号。
  final double? contentMaxFontSize;

  /// 内容最小字号。
  final double? contentMinFontSize;

  /// 项间距。
  final double? itemSpacing;

  /// 项内边距。
  final double? itemPadding;

  /// 边框宽度。
  final double? itemBorderWidth;

  /// 文本测量安全宽度。
  final double? textSafetyWidth;

  /// 圆角。
  final double? borderRadius;

  /// 最小高度。
  final double? minHeight;

  /// 最大高度。
  final double? maxHeight;

  /// 约束不足时的缩放对齐方式。
  final Alignment? fitAlignment;

  const PhraseStructurePreviewWidget({
    super.key,
    required this.items,
    this.titleFontSize,
    this.contentMaxFontSize,
    this.contentMinFontSize,
    this.itemSpacing,
    this.itemPadding,
    this.itemBorderWidth,
    this.textSafetyWidth,
    this.borderRadius,
    this.minHeight,
    this.maxHeight,
    this.fitAlignment,
  });

  @override
  Widget build(BuildContext context) {
    final List<CardPhraseStructureItem> previewItems =
        items?.whereType<CardPhraseStructureItem>().toList() ?? <CardPhraseStructureItem>[];
    if (previewItems.isEmpty) return const SizedBox.shrink();

    final double resolvedTitleFontSize = titleFontSize ?? 18.wMin;
    final double resolvedContentMaxFontSize = contentMaxFontSize ?? 46.wMin;
    final double resolvedContentMinFontSize = contentMinFontSize ?? resolvedTitleFontSize;
    final double resolvedItemSpacing = itemSpacing ?? 8.wMin;
    final double resolvedItemPadding = itemPadding ?? 6.wMin;
    final double resolvedItemBorderWidth = itemBorderWidth ?? 1.wMin;
    final double resolvedTextSafetyWidth = textSafetyWidth ?? 6.wMin;
    final double resolvedBorderRadius = borderRadius ?? 12.wMin;
    final double resolvedMinHeight = minHeight ?? 54.wMin;
    final double resolvedMaxHeight = maxHeight ?? 108.wMin;
    final Alignment resolvedFitAlignment = fitAlignment ?? Alignment.centerLeft;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double contentFontSize = _resolvePhraseStructureContentFontSize(
          items: previewItems,
          maxWidth: constraints.maxWidth,
          titleFontSize: resolvedTitleFontSize,
          contentMaxFontSize: resolvedContentMaxFontSize,
          contentMinFontSize: resolvedContentMinFontSize,
          itemSpacing: resolvedItemSpacing,
          itemPadding: resolvedItemPadding,
          itemBorderWidth: resolvedItemBorderWidth,
          textSafetyWidth: resolvedTextSafetyWidth,
        );
        final double totalWidth = _measurePhraseStructureTotalWidth(
          items: previewItems,
          titleFontSize: resolvedTitleFontSize,
          contentFontSize: contentFontSize,
          itemSpacing: resolvedItemSpacing,
          itemPadding: resolvedItemPadding,
          itemBorderWidth: resolvedItemBorderWidth,
          textSafetyWidth: resolvedTextSafetyWidth,
        );
        final double itemHeight = _resolvePhraseStructureItemHeight(
          contentFontSize: contentFontSize,
          contentMaxFontSize: resolvedContentMaxFontSize,
          minHeight: resolvedMinHeight,
          maxHeight: resolvedMaxHeight,
        );

        final List<Widget> children = [];
        for (int index = 0; index < previewItems.length; index++) {
          final CardPhraseStructureItem item = previewItems[index];
          final _PhraseStructureRoleStyle style = _resolveStructureRoleStyle(item.roleNid);
          final double itemWidth = _measurePhraseStructureItemWidth(
            item: item,
            style: style,
            titleFontSize: resolvedTitleFontSize,
            contentFontSize: contentFontSize,
            itemPadding: resolvedItemPadding,
            itemBorderWidth: resolvedItemBorderWidth,
            textSafetyWidth: resolvedTextSafetyWidth,
          );
          children.add(
            SizedBox(
              width: itemWidth,
              child: Container(
                height: itemHeight,
                padding: EdgeInsets.all(resolvedItemPadding),
                decoration: BoxDecoration(
                  color: style.bgColor,
                  borderRadius: BorderRadius.circular(resolvedBorderRadius),
                  border: Border.all(
                    color: style.borderColor,
                    width: resolvedItemBorderWidth,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      style.title,
                      style: TextStyle(
                        fontSize: resolvedTitleFontSize,
                        fontWeight: FontWeight.w400,
                        color: style.textColor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.text ?? '',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: contentFontSize,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          if (index < previewItems.length - 1) {
            children.add(SizedBox(width: resolvedItemSpacing));
          }
        }

        final Widget row = Row(mainAxisSize: MainAxisSize.min, children: children);
        if (!constraints.maxWidth.isFinite || totalWidth <= constraints.maxWidth) {
          return row;
        }
        return SizedBox(
          width: constraints.maxWidth,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: resolvedFitAlignment,
            child: row,
          ),
        );
      },
    );
  }

  _PhraseStructureRoleStyle _resolveStructureRoleStyle(String? roleNid) {
    final ConfigController configController = Get.find<ConfigController>();
    final LanguageConfigColorModel? colorConfig = StatusUtils.getConfigColor(
      configController.colorConfigs.value.phraseItemRoles,
      roleNid,
    );
    final String title = colorConfig?.title ?? ((roleNid ?? '').trim().isEmpty ? '' : roleNid!);
    return _PhraseStructureRoleStyle(
      title: title,
      textColor: colorConfig?.color?.textColor ?? AppTheme.cTextSecondary.color,
      bgColor: colorConfig?.color?.bgColor ?? AppTheme.cSurfaceTranslucentBase.color,
      borderColor: colorConfig?.color?.borderColor ?? AppTheme.cBorderTranslucentThin.color,
    );
  }

  double _resolvePhraseStructureContentFontSize({
    required List<CardPhraseStructureItem> items,
    required double maxWidth,
    required double titleFontSize,
    required double contentMaxFontSize,
    required double contentMinFontSize,
    required double itemSpacing,
    required double itemPadding,
    required double itemBorderWidth,
    required double textSafetyWidth,
  }) {
    if (items.isEmpty || !maxWidth.isFinite) return contentMaxFontSize;
    final double maxTotalWidth = _measurePhraseStructureTotalWidth(
      items: items,
      titleFontSize: titleFontSize,
      contentFontSize: contentMaxFontSize,
      itemSpacing: itemSpacing,
      itemPadding: itemPadding,
      itemBorderWidth: itemBorderWidth,
      textSafetyWidth: textSafetyWidth,
    );
    if (maxTotalWidth <= maxWidth) return contentMaxFontSize;

    double low = contentMinFontSize;
    double high = contentMaxFontSize;
    for (int i = 0; i < 12; i++) {
      final double middle = (low + high) / 2;
      final double totalWidth = _measurePhraseStructureTotalWidth(
        items: items,
        titleFontSize: titleFontSize,
        contentFontSize: middle,
        itemSpacing: itemSpacing,
        itemPadding: itemPadding,
        itemBorderWidth: itemBorderWidth,
        textSafetyWidth: textSafetyWidth,
      );
      if (totalWidth <= maxWidth) {
        low = middle;
      } else {
        high = middle;
      }
    }
    return low;
  }

  double _resolvePhraseStructureItemHeight({
    required double contentFontSize,
    required double contentMaxFontSize,
    required double minHeight,
    required double maxHeight,
  }) {
    if (contentMaxFontSize <= 0) return maxHeight;
    final double scale = (contentFontSize / contentMaxFontSize).clamp(0.0, 1.0);
    return minHeight + (maxHeight - minHeight) * scale;
  }

  double _measurePhraseStructureTotalWidth({
    required List<CardPhraseStructureItem> items,
    required double titleFontSize,
    required double contentFontSize,
    required double itemSpacing,
    required double itemPadding,
    required double itemBorderWidth,
    required double textSafetyWidth,
  }) {
    double totalWidth = 0;
    for (int index = 0; index < items.length; index++) {
      final CardPhraseStructureItem item = items[index];
      totalWidth += _measurePhraseStructureItemWidth(
        item: item,
        style: _resolveStructureRoleStyle(item.roleNid),
        titleFontSize: titleFontSize,
        contentFontSize: contentFontSize,
        itemPadding: itemPadding,
        itemBorderWidth: itemBorderWidth,
        textSafetyWidth: textSafetyWidth,
      );
      if (index < items.length - 1) totalWidth += itemSpacing;
    }
    return totalWidth;
  }

  double _measurePhraseStructureItemWidth({
    required CardPhraseStructureItem item,
    required _PhraseStructureRoleStyle style,
    required double titleFontSize,
    required double contentFontSize,
    required double itemPadding,
    required double itemBorderWidth,
    required double textSafetyWidth,
  }) {
    final double headerWidth =
        _measureTextWidth(style.title, titleFontSize, fontWeight: FontWeight.w400) +
        textSafetyWidth;
    final double contentWidth =
        _measureTextWidth(item.text ?? '', contentFontSize, fontWeight: FontWeight.w500) +
        textSafetyWidth;
    return (headerWidth > contentWidth ? headerWidth : contentWidth) +
        itemPadding * 2 +
        itemBorderWidth * 2;
  }

  double _measureTextWidth(
    String text,
    double fontSize, {
    FontWeight fontWeight = FontWeight.w400,
  }) {
    if (text.isEmpty) return 0;
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width.ceilToDouble();
  }
}

class _PhraseStructureRoleStyle {
  final String title;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;

  const _PhraseStructureRoleStyle({
    required this.title,
    required this.textColor,
    required this.bgColor,
    required this.borderColor,
  });
}
