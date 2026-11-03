import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:langwise/common/values/app_font_value.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../models/zhenxie_exam_models.dart';

/// 环形图 + 图例（对齐 React ExamCharts.tsx 的 Donut / SliceLegend）。
/// hover 只高亮：环上片、中心文案、图例三处联动。
/// 点击切片可回调（首页用于跳对比页并高亮）。
class ZxDonutBlock extends StatefulWidget {
  final List<ZhenxieExamHomeBlockItemData> items;
  final String emptyText;
  final Color Function(ZhenxieExamHomeBlockItemData item) colorBuilder;
  final ValueChanged<String>? onSliceTap;

  const ZxDonutBlock({
    super.key,
    required this.items,
    required this.emptyText,
    required this.colorBuilder,
    this.onSliceTap,
  });

  @override
  State<ZxDonutBlock> createState() => _ZxDonutBlockState();
}

class _ZxDonutBlockState extends State<ZxDonutBlock> {
  String? _active;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (widget.items.isEmpty) {
          return Center(
            child: Text(
              widget.emptyText,
              style: TextStyle(fontSize: 16.wMin, fontWeight: FontWeight.w500, color: _zxInk3Color),
            ),
          );
        }
        final double logicalSize = constraints.maxHeight/4*3;
        final double size = 260.wMin;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ZxDonutChart(
              items: widget.items,
              size: size,
              logicalSize: logicalSize,
              active: _active,
              colorBuilder: widget.colorBuilder,
              onHover: _setActive,
              onSliceTap: widget.onSliceTap,
            ),
            SizedBox(width: 24.wMin),
            _ZxSliceLegend(
              items: widget.items,
              active: _active,
              colorBuilder: widget.colorBuilder,
              onHover: _setActive,
            ),
          ],
        );
      },
    );
  }

  void _setActive(String? id) {
    if (_active == id) return;
    setState(() => _active = id);
  }
}

class _ZxDonutChart extends StatelessWidget {
  final List<ZhenxieExamHomeBlockItemData> items;
  final double size;
  final double logicalSize;
  final String? active;
  final Color Function(ZhenxieExamHomeBlockItemData item) colorBuilder;
  final ValueChanged<String?> onHover;
  final ValueChanged<String>? onSliceTap;

  const _ZxDonutChart({
    required this.items,
    required this.size,
    required this.logicalSize,
    required this.active,
    required this.colorBuilder,
    required this.onHover,
    this.onSliceTap,
  });

  @override
  Widget build(BuildContext context) {
    final int total = items.fold(0, (sum, item) => sum + item.count);
    final ZhenxieExamHomeBlockItemData top = items.reduce((a, b) => a.count >= b.count ? a : b);
    final ZhenxieExamHomeBlockItemData shown = active == null
        ? top
        : items.where((item) => item.code == active).firstOrNull ?? top;
    final double thickness = (size * 0.18).roundToDouble();
    return SizedBox(
      width: size,
      height: size,
      child: MouseRegion(
        onExit: (_) => onHover(null),
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerHover: (event) => onHover(_sliceAt(event.localPosition, size, total)),
          onPointerDown: (event) {
            final String? id = _sliceAt(event.localPosition, size, total);
            if (id != null) onSliceTap?.call(id);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _ZxDonutPainter(
                  items: items,
                  active: active,
                  thickness: thickness,
                  colorBuilder: colorBuilder,
                ),
              ),
              // 中心：默认最大一片的占比 + 名字，hover 换成那一片。
              Padding(
                padding: EdgeInsets.all(thickness + 8.wMin),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      percentOfSlice(shown.count, total),
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: math.max(16, (logicalSize * 0.17).round()).wMin,
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFontValue.robotoMono,
                        color: colorBuilder(shown),
                      ),
                    ),
                    SizedBox(height: 4.wMin),
                    Text(
                      pickLocalizedText(shown.name.map((text) => text.toJson()).toList()),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: math.max(16, (logicalSize * 0.08).round()).wMin,
                        height: 1.25,
                        fontWeight: FontWeight.w400,
                        color: _zxInk2Color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 按极坐标命中切片（环带内才响应）。
  String? _sliceAt(Offset position, double size, int total) {
    if (total <= 0) return null;
    final Offset center = Offset(size / 2, size / 2);
    final Offset delta = position - center;
    final double radius = size / 2;
    final double thickness = (radius * 0.18).roundToDouble();
    if (delta.distance < radius - thickness - 6 || delta.distance > radius + 2) return null;
    double angle = math.atan2(delta.dy, delta.dx) + math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;
    double cursor = 0;
    for (final ZhenxieExamHomeBlockItemData item in items) {
      final double sweep = (item.count / total) * 2 * math.pi;
      if (angle >= cursor && angle < cursor + sweep) return item.code;
      cursor += sweep;
    }
    return null;
  }
}

class _ZxDonutPainter extends CustomPainter {
  final List<ZhenxieExamHomeBlockItemData> items;
  final String? active;
  final double thickness;
  final Color Function(ZhenxieExamHomeBlockItemData item) colorBuilder;

  _ZxDonutPainter({
    required this.items,
    required this.active,
    required this.thickness,
    required this.colorBuilder,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int total = items.fold(0, (sum, item) => sum + item.count);
    if (total <= 0) return;
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide / 2;
    final double padAngle = items.length > 1 ? 0.018 : 0;

    // 底环
    canvas.drawCircle(
      center,
      radius - thickness / 2 - 4,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..color = AppTheme.cZhenxieBackgroundPrimary.color,
    );

    double start = -math.pi / 2;
    for (final ZhenxieExamHomeBlockItemData item in items) {
      final double share = item.count / total;
      final double fullSweep = share * 2 * math.pi;
      final bool lit = active == item.code;
      final bool dim = active != null && !lit;
      // 高亮片外扩 1px（React ringLit：inner 再进 1、outer 到边）。
      final double outer = lit ? radius : radius - 4;
      final double inner = lit ? radius - thickness - 5 : radius - thickness - 4;
      final Color color = colorBuilder(item).withValues(alpha: dim ? 0.22 : 1);
      // padAngle 从段两端各扣一半（对齐 d3.arc padAngle）。
      final double a0 = start + padAngle / 2;
      final double a1 = start + fullSweep - padAngle / 2;

      if (a1 > a0) {
        // 填充环带扇形：外弧 → 内弧闭合（对齐 d3.arc 的 fill path）。
        // 必须用 arcTo（forceMoveTo:false 会先 lineTo 弧起点、续在同一条轮廓上）；
        // addArc 会新开子路径，导致内外弧不相连、close 闭成弦，填充出黑色缺口。
        final Path path = Path()
          ..arcTo(Rect.fromCircle(center: center, radius: outer), a0, a1 - a0, true)
          ..arcTo(Rect.fromCircle(center: center, radius: inner), a1, -(a1 - a0), false)
          ..close();
        canvas.drawPath(path, Paint()..color = color);
      }

      // 环带上标百分比（份额 ≥ 10% 才标）。
      if (share >= 0.1) {
        final double mid = start + fullSweep / 2;
        final double labelRadius = radius - thickness / 2 - 4;
        final Offset labelPos = center + Offset(math.cos(mid), math.sin(mid)) * labelRadius;
        final TextPainter painter = TextPainter(
          text: TextSpan(
            text: '${(share * 100).round()}%',
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w600,
              fontFamily: AppFontValue.robotoMono,
              color: textOnColor(colorBuilder(item)).withValues(alpha: dim ? 0.25 : 0.95),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        painter.paint(canvas, labelPos - Offset(painter.width / 2, painter.height / 2));
      }
      start += fullSweep;
    }
  }

  @override
  bool shouldRepaint(_ZxDonutPainter oldDelegate) {
    return oldDelegate.active != active || oldDelegate.items != items || oldDelegate.thickness != thickness;
  }
}

/// 亮底墨字 / 暗底骨字（React textOn）。
Color textOnColor(Color color) {
  final double luminance = (color.r * 255 * 299 + color.g * 255 * 587 + color.b * 255 * 114) / 1000;
  return luminance > 150 ? AppTheme.cStaticBlack.color : AppTheme.cStaticWhite.color;
}

String percentOfSlice(int value, int total) {
  if (total == 0) return '0%';
  return '${((value / total) * 100).round()}%';
}

class _ZxSliceLegend extends StatelessWidget {
  final List<ZhenxieExamHomeBlockItemData> items;
  final String? active;
  final Color Function(ZhenxieExamHomeBlockItemData item) colorBuilder;
  final ValueChanged<String?> onHover;

  const _ZxSliceLegend({
    required this.items,
    required this.active,
    required this.colorBuilder,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    final int total = items.fold(0, (sum, item) => sum + item.count);
    return SizedBox(
      width: 188.wMin,
      child: MouseRegion(
        onExit: (_) => onHover(null),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items.map((item) {
            final bool lit = active == item.code;
            final bool dim = active != null && !lit;
            return MouseRegion(
              onEnter: (_) => onHover(item.code),
              child: Opacity(
                opacity: dim ? 0.35 : 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.wMin),
                  child: Row(
                    children: [
                      Container(
                        width: 10.wMin,
                        height: 10.wMin,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.wMin),
                            color: colorBuilder(item),
                        ),
                      ),
                      SizedBox(width: 8.wMin),
                      Expanded(
                        child: Text(
                            pickLocalizedText(item.name.map((text) => text.toJson()).toList()),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16.wMin,
                            fontWeight: FontWeight.w400,
                            color: lit ? _zxInkColor : _zxBoneColor.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.wMin),
                      Text(
                          percentOfSlice(item.count, total),
                        style: TextStyle(
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppFontValue.robotoMono,
                          color: lit ? _zxGoldColor : _zxBoneColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/* 甄写图表里的普通文字与承托色统一跟随 AppTheme。 */
Color get _zxInkColor => AppTheme.cZhenxieFontPrimary.color;
Color get _zxBoneColor => AppTheme.cZhenxieFontPrimary.color;
Color get _zxGoldColor => AppTheme.cZhenxieColorPrimary.color;
Color get _zxInk2Color => AppTheme.cZhenxieFontSecondary.color;
Color get _zxInk3Color => AppTheme.cZhenxieFontTertiary.color;
