import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/card_public_entity.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../zhenxie_exam/models/zhenxie_exam_models.dart';

/// 彩带图：三列柱 + 贝塞尔曲线连接带（对齐 React RibbonFlow）。
class ZhenxieRibbonFlowHitLayout {
  final ZhenxieExamCompareData data;
  final Size size;
  final Color Function(ZhenxieExamCompareLegendData legend) colorBuilder;

  static const double _barWidth = 46;
  static const double _gap = 2;
  static const double _top = 54;
  static const double _bottom = 6;

  ZhenxieRibbonFlowHitLayout({
    required this.data,
    required this.size,
    required this.colorBuilder,
  });

  String? hitTestSeries(Offset point) {
    if (data.columns.length < 2 || size.width <= 0 || size.height <= 0) return null;
    final List<double> xs = List<double>.generate(data.columns.length, (i) => i * (size.width - _barWidth) / (data.columns.length - 1));
    final List<ZhenxieExamCompareLegendData> ordered = _orderedLegends()
      ..sort((a, b) => _compareFlowLegend(a, b, _rankIndex()));
    final List<Map<String, _Segment>> segments = _buildSegments(ordered);

    for (int col = 0; col < data.columns.length; col++) {
      for (final ZhenxieExamCompareLegendData item in data.legends.reversed) {
        final _Segment seg = segments[col][item.code]!;
        final Rect rect = Rect.fromLTWH(xs[col], seg.y0, _barWidth, seg.y1 - seg.y0);
        if (rect.contains(point) && rect.height > 0.5) return item.code;
      }
    }

    for (int col = data.columns.length - 2; col >= 0; col--) {
      for (final ZhenxieExamCompareLegendData item in data.legends.reversed) {
        final _Segment a = segments[col][item.code]!;
        final _Segment b = segments[col + 1][item.code]!;
        if (a.y1 - a.y0 < 0.5 && b.y1 - b.y0 < 0.5) continue;
        final Path path = _band(xs[col] + _barWidth, a.y0, a.y1, xs[col + 1], b.y0, b.y1);
        if (path.contains(point)) return item.code;
      }
    }
    return null;
  }

  Rect? buildAvoidRect(String code) {
    if (data.columns.length < 2 || size.width <= 0 || size.height <= 0) return null;
    final List<ZhenxieExamCompareLegendData> ordered = _orderedLegends()
      ..sort((a, b) => _compareFlowLegend(a, b, _rankIndex()));
    final List<Map<String, _Segment>> segments = _buildSegments(ordered);
    double top = size.height;
    double bottom = 0;
    for (int col = 0; col < data.columns.length; col++) {
      final _Segment? seg = segments[col][code];
      if (seg == null || seg.y1 - seg.y0 < 0.5) continue;
      top = math.min(top, seg.y0);
      bottom = math.max(bottom, seg.y1);
    }
    if (bottom <= top) return Rect.fromLTWH(0, _top, size.width, 40);
    return Rect.fromLTRB(0, top, size.width, bottom);
  }

  List<Map<String, _Segment>> _buildSegments(List<ZhenxieExamCompareLegendData> ordered) {
    final double avail = size.height - _top - _bottom;
    final List<Map<String, _Segment>> segments = <Map<String, _Segment>>[];
    for (int col = 0; col < data.columns.length; col++) {
      final List<ZhenxieExamCompareLegendData> present = data.legends.where((item) => _legendValue(item.code, col) > 0).toList();
      final int total = present.fold<int>(0, (sum, item) => sum + _legendValue(item.code, col));
      final double usable = avail - _gap * math.max(0, present.length - 1);
      final Map<String, _Segment> out = <String, _Segment>{};
      double cursor = _top;
      for (final ZhenxieExamCompareLegendData item in ordered) {
        final int value = _legendValue(item.code, col);
        if (value <= 0) {
          out[item.code] = _Segment(y0: cursor, y1: cursor, share: 0);
          continue;
        }
        final double share = value / (total > 0 ? total : 1);
        final double h = share * usable;
        out[item.code] = _Segment(y0: cursor, y1: cursor + h, share: share);
        cursor += h + _gap;
      }
      segments.add(out);
    }
    return segments;
  }

  int _rankIndex() {
    final int gaokaoIndex = data.columns.indexWhere((item) => item.stage == 'gaokao');
    return gaokaoIndex >= 0 ? gaokaoIndex : data.columns.length - 1;
  }

  List<ZhenxieExamCompareLegendData> _orderedLegends() {
    return data.legends.toList();
  }

  int _legendValue(String code, int column) {
    return data.columns[column].nodes.firstWhereOrNull((item) => item.code == code)?.value ?? 0;
  }

  Path _band(double x0, double y0a, double y1a, double x1, double y0b, double y1b) {
    final double mx = (x0 + x1) / 2;
    return Path()
      ..moveTo(x0, y0a)
      ..cubicTo(mx, y0a, mx, y0b, x1, y0b)
      ..lineTo(x1, y1b)
      ..cubicTo(mx, y1b, mx, y1a, x0, y1a)
      ..close();
  }

  int _compareFlowLegend(ZhenxieExamCompareLegendData a, ZhenxieExamCompareLegendData b, int column) {
    final bool aOther = a.code == 'other' || a.groupCode == 'other';
    final bool bOther = b.code == 'other' || b.groupCode == 'other';
    if (aOther != bOther) return aOther ? 1 : -1;
    final int diff = _legendValue(b.code, column) - _legendValue(a.code, column);
    if (diff != 0) return diff;
    return a.code.compareTo(b.code);
  }
}

class ZhenxieRibbonFlowPainter extends CustomPainter {
  final ZhenxieExamCompareData data;
  final String? activeId;
  final String currentStage;
  final Color Function(ZhenxieExamCompareLegendData legend) colorBuilder;
  final String Function(List<LanguageText> texts) textBuilder;

  static const double _barWidth = 46;
  static const double _gap = 2;
  static const double _top = 54;
  static const double _bottom = 6;
  static Color get _bgColor => AppTheme.cBgPrimary.color;
  static Color get _inkColor => AppTheme.cZhenxieFontPrimary.color;
  static Color get _boneColor => AppTheme.cZhenxieFontPrimary.color;
  static Color get _goldColor => AppTheme.cZhenxieColorPrimary.color;

  ZhenxieRibbonFlowPainter({
    required this.data,
    required this.activeId,
    required this.currentStage,
    required this.colorBuilder,
    required this.textBuilder,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.columns.length < 2 || size.width <= 0 || size.height <= 0) return;

    final int n = data.columns.length;
    final List<double> xs = List<double>.generate(n, (i) => i * (size.width - _barWidth) / (n - 1));
    final double avail = size.height - _top - _bottom;

    // 按高考题数排序（所有列同序）。
    final int gaokaoIdx = data.columns.indexWhere((c) => c.stage == 'gaokao');
    final int rankIdx = gaokaoIdx >= 0 ? gaokaoIdx : n - 1;
    final List<ZhenxieExamCompareLegendData> ordered = data.legends.toList()
      ..sort((a, b) => _compareFlowLegend(a, b, rankIdx));

    // 每列的段布局。
    final List<Map<String, _Segment>> segments = <Map<String, _Segment>>[];
    for (int col = 0; col < n; col++) {
      final List<ZhenxieExamCompareLegendData> present = data.legends.where((item) => _legendValue(item.code, col) > 0).toList();
      final int total = present.fold<int>(0, (sum, item) => sum + _legendValue(item.code, col));
      final double usable = avail - _gap * math.max(0, present.length - 1);
      final Map<String, _Segment> out = <String, _Segment>{};
      double cursor = _top;
      for (final ZhenxieExamCompareLegendData item in ordered) {
        final int value = _legendValue(item.code, col);
        if (value <= 0) {
          out[item.code] = _Segment(y0: cursor, y1: cursor, share: 0);
          continue;
        }
        final double share = value / (total > 0 ? total : 1);
        final double h = share * usable;
        out[item.code] = _Segment(y0: cursor, y1: cursor + h, share: share);
        cursor += h + _gap;
      }
      segments.add(out);
    }

    // 画彩带（先画，柱压在上面）。
    for (final ZhenxieExamCompareLegendData item in data.legends) {
      for (int col = 0; col < n - 1; col++) {
        final _Segment a = segments[col][item.code]!;
        final _Segment b = segments[col + 1][item.code]!;
        if (a.y1 - a.y0 < 0.5 && b.y1 - b.y0 < 0.5) continue;
        final bool lit = activeId == item.code;
        final bool dim = activeId != null && !lit;
        final double opacity = dim ? 0.06 : (lit ? 0.82 : 0.42);
        final Path path = _band(
          xs[col] + _barWidth, a.y0, a.y1,
          xs[col + 1], b.y0, b.y1,
        );
        canvas.drawPath(path, Paint()..color = colorBuilder(item).withValues(alpha: opacity));
      }
    }

    // 画柱 + 百分比标签。
    for (int col = 0; col < n; col++) {
      for (final ZhenxieExamCompareLegendData item in data.legends) {
        final _Segment seg = segments[col][item.code]!;
        final double h = seg.y1 - seg.y0;
        if (h < 0.5) continue;
        final bool lit = activeId == item.code;
        final bool dim = activeId != null && !lit;
        final double barOpacity = dim ? 0.22 : 1.0;
        final Rect rect = Rect.fromLTWH(xs[col], seg.y0, _barWidth, h);
        final RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2));
        canvas.drawRRect(rrect, Paint()..color = colorBuilder(item).withValues(alpha: barOpacity));

        // 百分比标签（h >= 18 时画）。
        if (h >= 18) {
          final TextPainter tp = TextPainter(
            text: TextSpan(
              text: '${(seg.share * 100).round()}%',
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w600,
                fontFamily: 'ui-monospace, SFMono-Regular, Menlo, monospace',
                color: _inkColor.withValues(alpha: dim ? 0.25 : 0.95),
              ),
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: _barWidth);
          // 描边效果：先画 stroke 再画 fill。
          final TextPainter strokeTp = TextPainter(
            text: TextSpan(
              text: '${(seg.share * 100).round()}%',
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w600,
                fontFamily: 'ui-monospace, SFMono-Regular, Menlo, monospace',
                foreground: Paint()
                  ..color = _bgColor
                  ..strokeWidth = 2.5
                  ..style = PaintingStyle.stroke,
              ),
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: _barWidth);
          final double dx = xs[col] + _barWidth / 2 - tp.width / 2;
          final double dy = seg.y0 + h / 2 - tp.height / 2;
          strokeTp.paint(canvas, Offset(dx, dy));
          tp.paint(canvas, Offset(dx, dy));
        }
      }
    }

    // 画列头。
    for (int col = 0; col < n; col++) {
      final ZhenxieExamCompareColumnData column = data.columns[col];
      final double x = col == 0
          ? xs[col]
          : (col == n - 1 ? xs[col] + _barWidth : xs[col] + _barWidth / 2);
      final TextAlign anchor = col == 0
          ? TextAlign.left
          : (col == n - 1 ? TextAlign.right : TextAlign.center);
      final bool lit = column.stage == currentStage;

      // 标题。
      final TextPainter titleTp = TextPainter(
        text: TextSpan(
          text: textBuilder(column.name),
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w600,
            fontFamily: 'ui-serif, Georgia, serif',
            color: lit ? _goldColor : _inkColor,
          ),
        ),
        textAlign: anchor,
        textDirection: TextDirection.ltr,
      )..layout();
      final double titleX = anchor == TextAlign.left
          ? x
          : (anchor == TextAlign.right ? x - titleTp.width : x - titleTp.width / 2);
      titleTp.paint(canvas, Offset(titleX, 8));

      // 副标题。
      final TextPainter subTp = TextPainter(
        text: TextSpan(
          text: column.summaryText,
          style: TextStyle(
            fontSize: 16.wMin,
            fontFamily: 'ui-monospace, SFMono-Regular, Menlo, monospace',
            color: _boneColor.withValues(alpha: 0.45),
          ),
        ),
        textAlign: anchor,
        textDirection: TextDirection.ltr,
      )..layout();
      final double subX = anchor == TextAlign.left
          ? x
          : (anchor == TextAlign.right ? x - subTp.width : x - subTp.width / 2);
      subTp.paint(canvas, Offset(subX, 30));
    }
  }

  Path _band(double x0, double y0a, double y1a, double x1, double y0b, double y1b) {
    final double mx = (x0 + x1) / 2;
    return Path()
      ..moveTo(x0, y0a)
      ..cubicTo(mx, y0a, mx, y0b, x1, y0b)
      ..lineTo(x1, y1b)
      ..cubicTo(mx, y1b, mx, y1a, x0, y1a)
      ..close();
  }

  int _compareFlowLegend(ZhenxieExamCompareLegendData a, ZhenxieExamCompareLegendData b, int column) {
    final bool aOther = a.code == 'other' || a.groupCode == 'other';
    final bool bOther = b.code == 'other' || b.groupCode == 'other';
    if (aOther != bOther) return aOther ? 1 : -1;
    final int diff = _legendValue(b.code, column) - _legendValue(a.code, column);
    if (diff != 0) return diff;
    return a.code.compareTo(b.code);
  }

  int _legendValue(String code, int column) {
    return data.columns[column].nodes.firstWhereOrNull((item) => item.code == code)?.value ?? 0;
  }

  @override
  bool shouldRepaint(ZhenxieRibbonFlowPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.activeId != activeId || oldDelegate.currentStage != currentStage;
  }
}

class _Segment {
  final double y0;
  final double y1;
  final double share;
  const _Segment({required this.y0, required this.y1, required this.share});
}
