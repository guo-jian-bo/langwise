import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/zhenxie_widgets/word_inflection_info_tag_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ElementsAdaptiveTagTextWidget extends StatelessWidget {
  final String text;
  final List<Widget> trailingWidgets;
  final double maxFontSize;
  final double minFontSize;
  final FontWeight fontWeight;
  final Color textColor;
  final double textHeight;
  final int maxLines;
  final TextOverflow overflow;
  final double tagSpacing;

  const ElementsAdaptiveTagTextWidget({
    super.key,
    required this.text,
    required this.trailingWidgets,
    required this.maxFontSize,
    required this.minFontSize,
    required this.fontWeight,
    required this.textColor,
    required this.textHeight,
    this.maxLines = 2,
    this.overflow = TextOverflow.clip,
    this.tagSpacing = 8,
  });

  static double measureTextWidth(
    String text,
    double fontSize, {
    required FontWeight fontWeight,
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
    return textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final _AdaptiveTagTextLayoutData layoutData = _buildLayoutData(measureOnly: false);
        final double fontSize = _resolveFontSize(
          maxWidth: constraints.maxWidth,
        );
        return Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: textColor,
              height: textHeight,
            ),
            children: layoutData.spans,
          ),
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }

  double _resolveFontSize({
    required double maxWidth,
  }) {
    if (!maxWidth.isFinite) return maxFontSize;
    if (_canFit(
      maxWidth: maxWidth,
      fontSize: maxFontSize,
    )) {
      return maxFontSize;
    }

    double low = minFontSize;
    double high = maxFontSize;
    for (int i = 0; i < 12; i++) {
      final double middle = (low + high) / 2;
      if (_canFit(
        maxWidth: maxWidth,
        fontSize: middle,
      )) {
        low = middle;
      } else {
        high = middle;
      }
    }
    return low;
  }

  bool _canFit({
    required double maxWidth,
    required double fontSize,
  }) {
    final _AdaptiveTagTextLayoutData layoutData = _buildLayoutData(measureOnly: true);
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: textHeight,
        ),
        children: layoutData.spans,
      ),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..setPlaceholderDimensions(layoutData.placeholderDimensions)
     ..layout(maxWidth: maxWidth);
    return !textPainter.didExceedMaxLines;
  }

  _AdaptiveTagTextLayoutData _buildLayoutData({
    required bool measureOnly,
  }) {
    final List<InlineSpan> spans = <InlineSpan>[
      TextSpan(text: text),
    ];
    final List<PlaceholderDimensions> placeholderDimensions = <PlaceholderDimensions>[];
    for (final Widget trailingWidget in trailingWidgets) {
      final Size widgetSize = _resolveTrailingWidgetSize(trailingWidget);
      final Size placeholderSize = Size(
        tagSpacing.wMin + widgetSize.width,
        widgetSize.height,
      );
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: SizedBox(
            width: placeholderSize.width,
            height: placeholderSize.height,
            child: measureOnly
                ? null
                : Padding(
                    padding: EdgeInsets.only(left: tagSpacing.wMin),
                    child: trailingWidget,
                  ),
          ),
        ),
      );
      placeholderDimensions.add(
        PlaceholderDimensions(
          size: placeholderSize,
          alignment: PlaceholderAlignment.middle,
        ),
      );
    }
    return _AdaptiveTagTextLayoutData(
      spans: spans,
      placeholderDimensions: placeholderDimensions,
    );
  }

  Size _resolveTrailingWidgetSize(Widget trailingWidget) {
    if (trailingWidget is SizedBox &&
        trailingWidget.width != null &&
        trailingWidget.height != null) {
      return Size(trailingWidget.width!, trailingWidget.height!);
    }
    if (trailingWidget is WordInflectionInfoTagWidget) {
      final double fontSize = trailingWidget.fontSize ?? 16.wMin;
      final double widgetHeight = 32.wMin;
      return Size(
        measureTextWidth(
              trailingWidget.text,
              fontSize,
              fontWeight: trailingWidget.fontWeight ?? FontWeight.w400,
            ) +
            12.wMin * 2 +
            1.wMin * 2 +
            2.wMin,
        widgetHeight,
      );
    }
    throw FlutterError(
      'ElementsAdaptiveTagTextWidget.trailingWidgets 必须传入带固定尺寸的 SizedBox，或可识别尺寸的 WordInflectionInfoTagWidget。',
    );
  }
}

class _AdaptiveTagTextLayoutData {
  final List<InlineSpan> spans;
  final List<PlaceholderDimensions> placeholderDimensions;

  const _AdaptiveTagTextLayoutData({
    required this.spans,
    required this.placeholderDimensions,
  });
}
