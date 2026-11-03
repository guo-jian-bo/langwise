import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../app/modules/management/common/commons.dart';
import '../../values/values.dart';
import '../widgets.dart';

class SentenceSlotMapWidget extends StatefulWidget {
  /// 通用槽位图数据；不传或为空时不显示。
  final SentenceSlotMapEntity? data;

  /// 单个槽位点击回调。
  final void Function(SentenceSlotMapItemEntity item)? onSlotTap;

  /// 是否在组件内部渲染 dependsOn 弧线。
  final bool showDepend;

  /// 顶部标签字号。
  final double? lableFontSzie;

  /// 主体内容字号。
  final double? valueFontSize;

  /// 是否在标签前显示状态圆点。
  final bool showStateDot;

  /// 当前需要额外加深边框的槽位 key。
  final List<String> highlightedSlotKeys;

  /// 句子槽位图
  const SentenceSlotMapWidget({
    super.key,
    this.data,
    this.onSlotTap,
    this.showDepend = false,
    this.lableFontSzie,
    this.valueFontSize,
    this.showStateDot = false,
    this.highlightedSlotKeys = const <String>[],
  });

  @override
  State<SentenceSlotMapWidget> createState() => _SentenceSlotMapWidgetState();
}

class _SentenceSlotMapWidgetState extends State<SentenceSlotMapWidget> {
  /// 整个槽位图内容区 key，用来换算依赖弧线的局部坐标。
  final GlobalKey _contentKey = GlobalKey();

  /// 每个槽位卡片的 key，用来读取当前槽位的底部中心点。
  final Map<String, GlobalKey> _itemKeys = {};

  /// 当前已测量出的 dependsOn 弧线路径。
  List<_SentenceSlotDependArcLayout> _dependArcLayouts = const [];

  /// 防止同一帧内重复发起测量。
  bool _dependLayoutScheduled = false;

  @override
  Widget build(BuildContext context) {
    final SentenceSlotMapEntity? effectiveData = widget.data;
    if (effectiveData == null || effectiveData.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool showDepend = widget.showDepend && effectiveData.dependEdges.isNotEmpty;
    if (showDepend) {
      _scheduleDependLayoutUpdate();
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Stack(
          key: _contentKey,
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: showDepend ? 50.wMin : 0),
              child: IntrinsicHeight(
                child: Row(
                  spacing: 6.wMin,
                  children: effectiveData.items.map(_buildItemAnchorWidget).toList(),
                ),
              ),
            ),
            if (showDepend) ...[
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _SentenceSlotDependArcPainter(
                      arcs: _dependArcLayouts,
                    ),
                  ),
                ),
              ),
              ..._dependArcLayouts.map(_buildDependLabelWidget),
            ],
          ],
        ),
      ),
    );
  }

  /// 包装单个槽位的测量锚点，供 dependsOn 弧线定位。
  Widget _buildItemAnchorWidget(SentenceSlotMapItemEntity item) {
    if (item.isLiteral) {
      return _buildItemWidget(item);
    }

    return KeyedSubtree(
      key: _getItemKey(item.slotKey),
      child: _buildItemWidget(item),
    );
  }

  /// 渲染模板中的单个 segment。
  Widget _buildItemWidget(SentenceSlotMapItemEntity item) {
    final Color primaryColor = _resolvePrimaryColor(item);
    final bool optionalOpen = item.role == SentenceSlotMapRole.optionalOpen;
    final bool unused = item.unused && !item.isLiteral;
    final bool highlighted = _isHighlightedItem(item);
    Widget child = Container(
      padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
          color: unused ? Colors.black.withValues(alpha: 0.2) : primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10.wMin),
          border: optionalOpen
              ? null
              : Border.all(
                  color: _resolveBorderColor(
                    primaryColor: primaryColor,
                    highlighted: highlighted,
                  ),
                  width: 0.8.wMin,
                )),
      child: _buildItemContentWidget(item: item, primaryColor: primaryColor),
    );

    if (unused) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(10.wMin),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _SentenceSlotUnusedHatchPainter(),
                ),
              ),
            ),
            child,
          ],
        ),
      );
      child = DottedBorder(
        color: Colors.white.withValues(alpha: 0.12),
        strokeWidth: 0.8.wMin,
        dashPattern: [3.wMin, 1.5.wMin],
        borderType: BorderType.RRect,
        radius: Radius.circular(10.wMin),
        padding: EdgeInsets.zero,
        child: child,
      );
    } else if (optionalOpen) {
      child = DottedBorder(
        color: _resolveBorderColor(
          primaryColor: primaryColor,
          highlighted: highlighted,
        ),
        strokeWidth: 0.8.wMin,
        dashPattern: [3.wMin, 1.5.wMin],
        borderType: BorderType.RRect,
        radius: Radius.circular(10.wMin),
        padding: EdgeInsets.zero,
        child: child,
      );
    }

    child = _buildTapWidget(item: item, child: child);

    return child;
  }

  /// 当前槽位是否属于这次形态行需要额外强调的槽位。
  bool _isHighlightedItem(SentenceSlotMapItemEntity item) {
    if (item.isLiteral || item.unused) {
      return false;
    }
    return widget.highlightedSlotKeys.contains(item.slotKey);
  }

  /// 高亮态只加深边框颜色，不改变原本底色。
  Color _resolveBorderColor({
    required Color primaryColor,
    required bool highlighted,
  }) {
    return primaryColor.withValues(alpha: highlighted ? 1 : 0.12);
  }

  /// 缓存槽位 key，避免每次 build 重建测量锚点。
  GlobalKey _getItemKey(String slotKey) {
    return _itemKeys.putIfAbsent(slotKey, GlobalKey.new);
  }

  /// 下一帧测量所有 dependsOn 锚点，并换算成曲线路径。
  void _scheduleDependLayoutUpdate() {
    if (_dependLayoutScheduled) {
      return;
    }
    _dependLayoutScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dependLayoutScheduled = false;
      if (!mounted) {
        return;
      }
      final List<_SentenceSlotDependArcLayout> next = _measureDependArcLayouts();
      if (_isSameDependArcLayouts(next)) {
        return;
      }
      setState(() {
        _dependArcLayouts = next;
      });
    });
  }

  /// 读取每条依赖边两端槽位的位置，并生成贝塞尔曲线路径。
  List<_SentenceSlotDependArcLayout> _measureDependArcLayouts() {
    final SentenceSlotMapEntity? effectiveData = widget.data;
    if (effectiveData == null || !widget.showDepend || effectiveData.dependEdges.isEmpty) {
      return const [];
    }

    final RenderBox? contentBox = _contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (contentBox == null || !contentBox.hasSize) {
      return const [];
    }

    final List<_SentenceSlotDependArcLayout> layouts = [];
    for (int index = 0; index < effectiveData.dependEdges.length; index++) {
      final SentenceSlotMapDependEdgeEntity edge = effectiveData.dependEdges[index];
      final RenderBox? dependeeBox = _itemKeys[edge.toSlotKey]?.currentContext?.findRenderObject() as RenderBox?;
      final RenderBox? dependencyBox = _itemKeys[edge.fromSlotKey]?.currentContext?.findRenderObject() as RenderBox?;
      if (dependeeBox == null || dependencyBox == null || !dependeeBox.hasSize || !dependencyBox.hasSize) {
        continue;
      }

      final Offset start = _getBottomCenterOffset(
        targetBox: dependeeBox,
        ancestorBox: contentBox,
      );
      final Offset end = _getBottomCenterOffset(
        targetBox: dependencyBox,
        ancestorBox: contentBox,
      );
      final double span = (end.dx - start.dx).abs();
      final double drop = min(36.wMin, max(18.wMin, span * 0.24)) + (index % 3) * 8.wMin;
      final Offset control1 = Offset(
        start.dx + (end.dx - start.dx) * 0.28,
        start.dy + drop,
      );
      final Offset control2 = Offset(
        start.dx + (end.dx - start.dx) * 0.72,
        end.dy + drop,
      );
      final Offset tip = _buildInsetEndPoint(
        control2: control2,
        end: end,
        inset: 6.wMin,
      );
      layouts.add(
        _SentenceSlotDependArcLayout(
          edge: edge,
          start: start,
          control1: control1,
          control2: control2,
          tip: tip,
          mid: _cubicPoint(start, control1, control2, tip, 0.5),
        ),
      );
    }
    return layouts;
  }

  /// 比较两次测量结果，避免反复 setState。
  bool _isSameDependArcLayouts(List<_SentenceSlotDependArcLayout> next) {
    if (_dependArcLayouts.length != next.length) {
      return false;
    }

    for (int index = 0; index < next.length; index++) {
      final _SentenceSlotDependArcLayout current = _dependArcLayouts[index];
      final _SentenceSlotDependArcLayout candidate = next[index];
      if (current.edge.fromSlotKey != candidate.edge.fromSlotKey ||
          current.edge.toSlotKey != candidate.edge.toSlotKey ||
          !_isSameOffset(current.start, candidate.start) ||
          !_isSameOffset(current.control1, candidate.control1) ||
          !_isSameOffset(current.control2, candidate.control2) ||
          !_isSameOffset(current.tip, candidate.tip) ||
          !_isSameOffset(current.mid, candidate.mid)) {
        return false;
      }
    }
    return true;
  }

  /// 判断两个坐标是否可视为同一点，减少浮点抖动。
  bool _isSameOffset(Offset a, Offset b) {
    return (a - b).distance <= 0.5;
  }

  /// 取目标卡片底部中心点，并换算到内容区坐标系。
  Offset _getBottomCenterOffset({
    required RenderBox targetBox,
    required RenderBox ancestorBox,
  }) {
    final Offset topLeft = targetBox.localToGlobal(Offset.zero, ancestor: ancestorBox);
    return Offset(
      topLeft.dx + targetBox.size.width / 2,
      topLeft.dy + targetBox.size.height,
    );
  }

  /// 给箭头末端留一点回缩，避免压进卡片边框里。
  Offset _buildInsetEndPoint({
    required Offset control2,
    required Offset end,
    required double inset,
  }) {
    final Offset delta = end - control2;
    final double length = delta.distance;
    if (length == 0) {
      return end;
    }
    return end - Offset(delta.dx / length * inset, delta.dy / length * inset);
  }

  /// 计算三阶贝塞尔在 t 点的坐标，用来挂依赖说明气泡。
  Offset _cubicPoint(
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3,
    double t,
  ) {
    final double u = 1 - t;
    return Offset(
      u * u * u * p0.dx + 3 * u * u * t * p1.dx + 3 * u * t * t * p2.dx + t * t * t * p3.dx,
      u * u * u * p0.dy + 3 * u * u * t * p1.dy + 3 * u * t * t * p2.dy + t * t * t * p3.dy,
    );
  }

  /// 在弧肚中间挂 dependsOn 说明。
  Widget _buildDependLabelWidget(_SentenceSlotDependArcLayout arc) {
    return Positioned(
      left: arc.mid.dx,
      top: arc.mid.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cBgPrimary.color,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.28),
              width: 0.8.wMin,
            ),
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: arc.edge.toLabel),
                  TextSpan(
                    text: " 依赖 ",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextSecondary.color,
                    ),
                  ),
                  TextSpan(text: arc.edge.fromLabel),
                ],
              ),
              softWrap: false,
            ),
          ),
        ),
      ),
    );
  }

  /// 优先读取槽位配置颜色，字面量保持文本主色。
  Color _resolvePrimaryColor(SentenceSlotMapItemEntity item) {
    if (item.isLiteral) {
      return AppTheme.cTextPrimary.color;
    }
    return ColorUtils.parseColor(item.color) ?? AppTheme.cSurfaceBrand.color;
  }

  /// 包装槽位点击交互。
  Widget _buildTapWidget({
    required SentenceSlotMapItemEntity item,
    required Widget child,
  }) {
    if (item.isLiteral || item.unused || (widget.onSlotTap == null)) {
      return child;
    }

    return TapScaleWidget(
      onTap: () {
        widget.onSlotTap?.call(item);
      },
      sclae: 1,
      child: child,
    );
  }

  /// 渲染槽位卡片中的标签行与主体文字。
  Widget _buildItemContentWidget({
    required SentenceSlotMapItemEntity item,
    required Color primaryColor,
  }) {
    final bool unused = item.unused && !item.isLiteral;
    final Color labelColor = unused ? Colors.transparent : primaryColor.withValues(alpha: 0.45);
    final Color textColor = unused ? Colors.transparent : primaryColor.withValues(alpha: 0.3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStateDotWidget(item: item),
            _buildGrowthBadgeWidget(item: item, primaryColor: primaryColor),
            SuperpositionTextWidget(
              text: item.label,
              foregroundColor: labelColor,
              style: TextStyle(
                fontSize: widget.lableFontSzie ?? 18.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextSecondary.color.withValues(alpha: item.unused ? 0.4 : 1),
              ),
            ),
            _buildCtrlTagWidget(item: item, primaryColor: primaryColor),
          ],
        ),
        SizedBox(height: 4.wMin),
        SuperpositionTextWidget(
          text: item.text,
          foregroundColor: textColor,
          style: TextStyle(
            fontSize: widget.valueFontSize ?? 24.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color.withValues(alpha: item.unused ? 0.4 : 1),
            decoration: unused ? TextDecoration.lineThrough : null,
            decorationColor: AppTheme.cTextPrimary.color.withValues(alpha: item.unused ? 0.4 : 1),
          ),
        ),
      ],
    );
  }

  /// 形态行里必填/可选标签前补一个浅色圆点。
  Widget _buildStateDotWidget({
    required SentenceSlotMapItemEntity item,
  }) {
    final bool showDot = widget.showStateDot &&
        !item.unused &&
        (item.role == SentenceSlotMapRole.requiredOpen || item.role == SentenceSlotMapRole.optionalOpen);
    if (!showDot) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.wMin,
          height: 8.wMin,
          decoration: BoxDecoration(
            color: AppTheme.cTextPrimary.color.withValues(alpha: 0.82),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.wMin),
      ],
    );
  }

  Widget _buildGrowthBadgeWidget({
    required SentenceSlotMapItemEntity item,
    required Color primaryColor,
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
          child: Stack(
            children: [
              Text(
                "${item.growthIndex}",
                style: TextStyle(
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
              Text(
                "${item.growthIndex}",
                style: TextStyle(
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w500,
                  color: primaryColor.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 4.wMin),
      ],
    );
  }

  Widget _buildCtrlTagWidget({
    required SentenceSlotMapItemEntity item,
    required Color primaryColor,
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
            color: primaryColor.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(4.wMin),
          ),
          child: Stack(
            children: [
              Text(
                "C",
                style: TextStyle(
                  fontSize: 12.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
              Text(
                "C",
                style: TextStyle(
                  fontSize: 12.wMin,
                  fontWeight: FontWeight.w500,
                  color: primaryColor.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// “这次写哪些形态”专用骨架组件。
///
/// 它复用通用槽位图样式，只额外根据当前行的高亮 / 不用槽位，重建一份展示数据。
class SentenceSlotShapeMapWidget extends StatelessWidget {
  /// 当前句型骨架。
  final PatternBlueprintEntity pattern;

  /// 当前行需要保留正常态展示的槽位。
  final List<String> highlightSlotKeys;

  /// 当前行需要标成“不用”的槽位。
  final List<String> unusedSlotKeys;

  /// 顶部标签字号。
  final double? lableFontSzie;

  /// 主体内容字号。
  final double? valueFontSize;

  const SentenceSlotShapeMapWidget({
    super.key,
    required this.pattern,
    this.highlightSlotKeys = const <String>[],
    this.unusedSlotKeys = const <String>[],
    this.lableFontSzie,
    this.valueFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final SentenceSlotMapEntity slotMap = _buildShapeSlotMap();
    if (slotMap.items.isEmpty) {
      return const SizedBox.shrink();
    }
    return SentenceSlotMapWidget(
      data: slotMap,
      lableFontSzie: lableFontSzie,
      valueFontSize: valueFontSize,
      showStateDot: true,
      highlightedSlotKeys: highlightSlotKeys,
    );
  }

  /// 按当前行的形态状态，把可选槽切成“可选”或“不用”。
  SentenceSlotMapEntity _buildShapeSlotMap() {
    final SentenceSlotMapEntity baseSlotMap = SentenceSlotMapUtils.buildFromPatternBlueprint(pattern);
    final Set<String> highlightSlotKeySet = highlightSlotKeys.toSet();
    final Set<String> unusedSlotKeySet = unusedSlotKeys.toSet();
    final List<SentenceSlotMapItemEntity> items = baseSlotMap.items.map((item) {
      if (item.isLiteral || item.role != SentenceSlotMapRole.optionalOpen) {
        return item;
      }

      final bool itemHighlighted = highlightSlotKeySet.contains(item.slotKey);
      final bool itemUnused = unusedSlotKeySet.contains(item.slotKey) || !itemHighlighted;
      return SentenceSlotMapItemEntity(
        key: item.key,
        slotKey: item.slotKey,
        label: itemUnused ? '不用' : '可选',
        text: item.text,
        title: item.title,
        role: item.role,
        color: item.color,
        showCtrl: !itemUnused && item.showCtrl,
        unused: itemUnused,
        growthIndex: item.growthIndex,
        isRenderAlias: item.isRenderAlias,
        sourceControlledKeys: item.sourceControlledKeys,
        dependsOnSlotKeys: item.dependsOnSlotKeys,
        details: item.details,
      );
    }).toList();

    return SentenceSlotMapEntity(
      items: items,
      dependEdges: const <SentenceSlotMapDependEdgeEntity>[],
    );
  }
}

/// 单条 dependsOn 弧线的几何布局结果。
class _SentenceSlotDependArcLayout {
  final SentenceSlotMapDependEdgeEntity edge;
  final Offset start;
  final Offset control1;
  final Offset control2;
  final Offset tip;
  final Offset mid;

  const _SentenceSlotDependArcLayout({
    required this.edge,
    required this.start,
    required this.control1,
    required this.control2,
    required this.tip,
    required this.mid,
  });
}

/// 负责绘制 dependsOn 贝塞尔弧线与箭头。
class _SentenceSlotDependArcPainter extends CustomPainter {
  final List<_SentenceSlotDependArcLayout> arcs;

  const _SentenceSlotDependArcPainter({
    required this.arcs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Color strokeColor = AppTheme.cSurfaceBrand.color.withValues(alpha: 0.72);
    final Paint strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6.wMin
      ..strokeCap = StrokeCap.round;
    final Paint arrowPaint = Paint()
      ..color = AppTheme.cSurfaceBrand.color.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;

    for (final _SentenceSlotDependArcLayout arc in arcs) {
      final Path path = Path()
        ..moveTo(arc.start.dx, arc.start.dy)
        ..cubicTo(
          arc.control1.dx,
          arc.control1.dy,
          arc.control2.dx,
          arc.control2.dy,
          arc.tip.dx,
          arc.tip.dy,
        );
      canvas.drawPath(path, strokePaint);
      _paintArrowHead(
        canvas: canvas,
        paint: arrowPaint,
        from: arc.control2,
        tip: arc.tip,
      );
    }
  }

  /// 在依赖终点画一个小箭头，表达指向 dependency。
  void _paintArrowHead({
    required Canvas canvas,
    required Paint paint,
    required Offset from,
    required Offset tip,
  }) {
    final Offset delta = tip - from;
    final double length = delta.distance;
    if (length == 0) {
      return;
    }

    final Offset direction = Offset(delta.dx / length, delta.dy / length);
    final Offset normal = Offset(-direction.dy, direction.dx);
    final double arrowLength = 8.wMin;
    final double arrowHalfWidth = 3.2.wMin;
    final Offset base = tip - Offset(direction.dx * arrowLength, direction.dy * arrowLength);
    final Path path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        base.dx + normal.dx * arrowHalfWidth,
        base.dy + normal.dy * arrowHalfWidth,
      )
      ..lineTo(
        base.dx - normal.dx * arrowHalfWidth,
        base.dy - normal.dy * arrowHalfWidth,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SentenceSlotDependArcPainter oldDelegate) {
    return oldDelegate.arcs != arcs;
  }
}

/// 为 unused 槽位绘制原型中的斜线遮罩。
class _SentenceSlotUnusedHatchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final RRect clip = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(10.wMin),
    );
    canvas.save();
    canvas.clipRRect(clip);
    final Paint paint = Paint()
      ..color = AppTheme.cTextPrimary.color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.wMin;
    final double spacing = 10.wMin;
    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SentenceSlotUnusedHatchPainter oldDelegate) {
    return false;
  }
}

class SentenceSlotExampleWidget extends StatefulWidget {
  /// 代表句中的已展开 segment；不传或为空时不显示。
  final List<PatternBlueprintSentenceBriefSegmentEntity?>? segmentList;
  final String? content;
  final bool isManagement;

  /// 单个槽位点击回调。
  final void Function(PatternBlueprintSentenceBriefSegmentEntity segment)? onSlotTap;

  /// 槽位嵌套结构展开状态变化回调。
  final ValueChanged<bool>? onExpandedChanged;

  final EdgeInsetsGeometry? padding;

  final double? lableFontSzie;
  final double? valueFontSize;

  /// 代表句槽位实例
  const SentenceSlotExampleWidget({
    super.key,
    required this.content,
    this.segmentList,
    this.onSlotTap,
    this.onExpandedChanged,
    this.isManagement = false,
    this.padding,
    this.lableFontSzie,
    this.valueFontSize,
  });

  @override
  State<SentenceSlotExampleWidget> createState() => _SentenceSlotExampleWidgetState();
}

class _SentenceSlotExampleWidgetState extends State<SentenceSlotExampleWidget> {
  /// 当前展开链路上每一层选中的槽位下标。
  final List<int> _selectedIndexes = [];

  /// 每一层横向内容容器的 key，用来计算子层挂靠位置。
  final Map<int, GlobalKey> _groupContentKeys = {};

  /// 每个 segment 卡片的 key，用来读取当前选中卡片的左侧偏移。
  final Map<String, GlobalKey> _itemKeys = {};

  /// 每一层子层结构相对于当前层内容区的左侧偏移。
  final Map<int, double> _childLeftOffsets = {};

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
      return Container(
        padding: EdgeInsets.symmetric(vertical: 10.wMin),
        child: Row(
          children: [
            Text(
              widget.content ?? '',
              style: TextStyle(
                fontSize: widget.valueFontSize,
                color: AppTheme.cZhenxieFontPrimary.color,
                fontWeight: FontWeight.w500,
                fontFamily: AppFontValue.robotoMono,
              ),
            ),
            Visibility(
              visible: widget.isManagement,
              child: Container(
                margin: EdgeInsets.only(left: 10.wMin),
                padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 2.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                    width: 1.wMin,
                  ),
                ),
                child: Text(
                  "无句型结构",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: AppTheme.cSurfaceWarning.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final PatternBlueprintSentenceBriefSegmentEntity? selectedSegment = _getSelectedSegment(list, depth);
    if (selectedSegment != null) {
      _scheduleChildOffsetUpdate(depth);
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: widget.padding,
        child: KeyedSubtree(
          key: _getGroupContentKey(depth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buiildListWidget(list, depth: depth),
              _buildChildListWidget(
                selectedSegment: selectedSegment,
                context: context,
                depth: depth + 1,
                leftOffset: _childLeftOffsets[depth] ?? 0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 渲染当前选中 segment 的子层结构。
  Widget _buildChildListWidget({
    required PatternBlueprintSentenceBriefSegmentEntity? selectedSegment,
    required BuildContext context,
    required int depth,
    required double leftOffset,
  }) {
    final PatternBlueprintSentenceBriefSegmentChildStructEntity? childStruct = selectedSegment?.childStruct;
    final List<PatternBlueprintSentenceBriefSegmentEntity?>? childList = childStruct?.segmentList;
    if (childStruct == null || childList == null || childList.isEmpty) {
      return const SizedBox.shrink();
    }

    final LanguageText? patternName = LearningLangUtils.getLocalLang(childStruct.patternName);
    final String title = '内层 · ${patternName?.text ?? ''}';
    final String patternNid = childStruct.patternNid ?? '';

    return Container(
      margin: EdgeInsets.only(top: 12.wMin, left: leftOffset),
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
              if (widget.isManagement && patternNid.isNotEmpty) CopyTagWidget(name: "句型", value: patternNid, isShow: widget.isManagement),
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

  Widget _buiildListWidget(List<PatternBlueprintSentenceBriefSegmentEntity?>? list, {required int depth}) {
    if (list == null || list.isEmpty) {
      return const SizedBox.shrink();
    }

    return IntrinsicHeight(
      child: Row(
        spacing: 6.wMin,
        children: List.generate(list.length, (index) {
          return KeyedSubtree(
            key: _getItemKey(depth, index),
            child: _buildExampleItemWidget(
              segment: list[index],
              index: index,
              depth: depth,
            ),
          );
        }),
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
    final Color primaryColor = _resolvePrimaryColor(segment);
    final bool isDottedBorder = role == SentenceSlotMapRole.optionalOpen;
    final bool isLiteral = role == SentenceSlotMapRole.literal;
    final bool hasNestedChildren = _hasNestedChildList(segment);
    final bool selected = _isItemSelected(depth, index);
    Widget child = const SizedBox.shrink();

    if (isDottedBorder) {
      child = DottedBorder(
        color: primaryColor.withValues(alpha: selected ? 0.6 : 0.12),
        strokeWidth: 0.8.wMin,
        dashPattern: [3.wMin, 1.5.wMin],
        borderType: BorderType.RRect,
        radius: Radius.circular(10.wMin),
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10.wMin),
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
          color: primaryColor.withValues(alpha: isLiteral ? 0.08 : 0.08),
          borderRadius: BorderRadius.circular(10.wMin),
          border: Border.all(
            color: primaryColor.withValues(alpha: selected ? 0.6 : (isLiteral ? 0.12 : 0.12)),
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

  /// 优先读取槽位配置颜色，字面量保持文本主色。
  Color _resolvePrimaryColor(PatternBlueprintSentenceBriefSegmentEntity segment) {
    final SentenceSlotMapRole role = _resolveSentenceExampleRole(segment);
    final bool isLiteral = role == SentenceSlotMapRole.literal;
    if (isLiteral) {
      return AppTheme.cTextPrimary.color;
    }
    return ColorUtils.parseColor(segment.slot?.color) ?? AppTheme.cSurfaceBrand.color;
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
    final Color primaryColor = _resolvePrimaryColor(segment);

    final bool showEmptyMask = !isLiteral && text.isEmpty;
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 4.wMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SuperpositionTextWidget(
                    text: label,
                    foregroundColor: primaryColor.withValues(alpha: 0.6),
                    style: TextStyle(
                      fontSize: widget.lableFontSzie ?? 18.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cTextSecondary.color,
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
              SuperpositionTextWidget(
                text: showEmptyMask ? " " : text,
                foregroundColor: primaryColor.withValues(alpha: 0.45),
                style: TextStyle(
                  fontSize: widget.valueFontSize ?? 28.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
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
    _childLeftOffsets.removeWhere((int key, double value) => key >= depth);
    if (selected) {
      setState(() {});
      widget.onExpandedChanged?.call(_selectedIndexes.isNotEmpty);
      return;
    }

    _selectedIndexes.add(index);
    setState(() {});
    widget.onExpandedChanged?.call(_selectedIndexes.isNotEmpty);
  }

  /// 获取当前层内容容器 key。
  GlobalKey _getGroupContentKey(int depth) {
    return _groupContentKeys.putIfAbsent(depth, GlobalKey.new);
  }

  /// 获取当前卡片 key。
  GlobalKey _getItemKey(int depth, int index) {
    return _itemKeys.putIfAbsent('${depth}_$index', GlobalKey.new);
  }

  /// 获取当前层选中卡片下标。
  int? _getSelectedIndex(int depth) {
    if (_selectedIndexes.length <= depth) {
      return null;
    }
    return _selectedIndexes[depth];
  }

  /// 读取选中卡片左边界，并把子层结构挂到同一条竖线上。
  void _scheduleChildOffsetUpdate(int depth) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final int? index = _getSelectedIndex(depth);
      if (index == null) {
        return;
      }

      final BuildContext? groupContext = _getGroupContentKey(depth).currentContext;
      final BuildContext? itemContext = _getItemKey(depth, index).currentContext;
      if (groupContext == null || itemContext == null) {
        return;
      }

      final RenderObject? groupRenderObject = groupContext.findRenderObject();
      final RenderObject? itemRenderObject = itemContext.findRenderObject();
      if (groupRenderObject is! RenderBox || itemRenderObject is! RenderBox) {
        return;
      }

      final double leftOffset = itemRenderObject.localToGlobal(Offset.zero, ancestor: groupRenderObject).dx;
      final double currentOffset = _childLeftOffsets[depth] ?? -1;
      if ((currentOffset - leftOffset).abs() < 0.5) {
        return;
      }

      setState(() {
        _childLeftOffsets[depth] = leftOffset;
      });
    });
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

/// 例句与骨架组合视图：先按蓝图模板展开骨架，再把句子内容回填到对应槽位。
class SentenceSlotAnnotatedExampleWidget extends StatelessWidget {
  /// 当前句型骨架；用于生成完整的模板槽位序列。
  final PatternBlueprintEntity? pattern;

  /// 当前句子结构；用于把句面内容回填到骨架槽位上。
  final PatternBlueprintSentenceBriefEntity? sentence;

  /// 外层内边距，便于在不同容器里复用。
  final EdgeInsetsGeometry? padding;

  /// 是否显示管理端“无句型结构”提示。
  final bool isManagement;

  /// 顶部标签字号。
  final double? lableFontSzie;

  /// 句面字号。
  final double? valueFontSize;

  const SentenceSlotAnnotatedExampleWidget({
    super.key,
    required this.pattern,
    required this.sentence,
    this.padding,
    this.isManagement = false,
    this.lableFontSzie,
    this.valueFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final String content = sentence?.content ?? '';
    final List<PatternBlueprintSentenceBriefSegmentEntity?>? segmentList = sentence?.segmentList;
    if (segmentList == null || segmentList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: padding ?? EdgeInsets.symmetric(vertical: 10.wMin),
        child: Row(
          children: [
            Text(
              content,
              style: TextStyle(
                fontSize: valueFontSize ?? 20.wMin,
                color: AppTheme.cZhenxieFontPrimary.color,
                fontWeight: FontWeight.w500,
                fontFamily: AppFontValue.robotoMono,
              ),
            ),
            Visibility(
              visible: isManagement,
              child: Container(
                margin: EdgeInsets.only(left: 10.wMin),
                padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 2.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                    width: 1.wMin,
                  ),
                ),
                child: Text(
                  '无句型结构',
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: AppTheme.cSurfaceWarning.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    final PatternBlueprintEntity? renderPattern = _resolveRenderPattern();
    if (renderPattern == null) {
      return Container(
        width: double.infinity,
        padding: padding ?? EdgeInsets.zero,
        child: Text(
          content,
          style: TextStyle(
            fontSize: valueFontSize ?? 20.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
            fontFamily: AppFontValue.sourceHanSerifCN,
            height: 1.45,
          ),
        ),
      );
    }

    final SentenceSlotMapEntity mergedSlotMap = _buildMergedSlotMap(
      pattern: renderPattern,
      sentence: sentence,
    );
    if (mergedSlotMap.items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: padding ?? EdgeInsets.zero,
        child: Text(
          content,
          style: TextStyle(
            fontSize: valueFontSize ?? 20.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
            fontFamily: AppFontValue.sourceHanSerifCN,
            height: 1.45,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.zero,
      child: SentenceSlotMapWidget(
        data: mergedSlotMap,
        showDepend: false,
        lableFontSzie: lableFontSzie,
        valueFontSize: valueFontSize,
      ),
    );
  }

  /// 按骨架顺序合并句子内容，得到“像 Web 已有句子列表”那样的骨架+句面组合。
  SentenceSlotMapEntity _buildMergedSlotMap({
    required PatternBlueprintEntity pattern,
    required PatternBlueprintSentenceBriefEntity? sentence,
  }) {
    final SentenceSlotMapEntity baseSlotMap = SentenceSlotMapUtils.buildFromPatternBlueprint(pattern);
    final Map<String, String> sentenceTextMap = _buildSentenceTextMap(sentence?.segmentList);
    final List<SentenceSlotMapItemEntity> items = baseSlotMap.items.map((item) {
      if (item.isLiteral || item.unused) {
        final String mappedText = _resolveMappedText(item, sentenceTextMap);
        if (item.isLiteral || mappedText.isEmpty) {
          return item;
        }
        return SentenceSlotMapItemEntity(
          key: item.key,
          slotKey: item.slotKey,
          label: _buildFilledSlotLabel(item),
          text: mappedText,
          title: item.slotKey,
          role: item.role,
          color: item.color,
          showCtrl: item.showCtrl,
          unused: false,
          growthIndex: item.growthIndex,
          isRenderAlias: item.isRenderAlias,
          sourceControlledKeys: item.sourceControlledKeys,
          dependsOnSlotKeys: item.dependsOnSlotKeys,
          details: item.details,
        );
      }
      final String mappedText = _resolveMappedText(item, sentenceTextMap);
      return SentenceSlotMapItemEntity(
        key: item.key,
        slotKey: item.slotKey,
        label: mappedText.isNotEmpty ? _buildFilledSlotLabel(item) : item.label,
        text: mappedText.isNotEmpty ? mappedText : item.text,
        title: item.title,
        role: item.role,
        color: item.color,
        showCtrl: item.showCtrl,
        unused: item.unused,
        growthIndex: item.growthIndex,
        isRenderAlias: item.isRenderAlias,
        sourceControlledKeys: item.sourceControlledKeys,
        dependsOnSlotKeys: item.dependsOnSlotKeys,
        details: item.details,
      );
    }).toList();
    return SentenceSlotMapEntity(
      items: items,
      dependEdges: const <SentenceSlotMapDependEdgeEntity>[],
    );
  }

  /// Web 端已有句子列表按“每条句子自己的 pattern”渲染，这里优先用句子自带模板覆盖当前页骨架。
  PatternBlueprintEntity? _resolveRenderPattern() {
    if (pattern == null) {
      return null;
    }
    final String sentenceTemplate = sentence?.patternTemplate?.trim() ?? '';
    final String sentencePatternNid = sentence?.patternNid?.trim() ?? '';
    final String sentenceBlueprintScope = sentence?.blueprintScope?.trim() ?? '';
    if (sentenceTemplate.isEmpty && sentencePatternNid.isEmpty && sentenceBlueprintScope.isEmpty) {
      return pattern;
    }
    final PatternBlueprintEntity resolved = PatternBlueprintEntity.fromJson(pattern!.toJson());
    if (sentenceTemplate.isNotEmpty) {
      resolved.template = sentenceTemplate;
    }
    if (sentencePatternNid.isNotEmpty) {
      resolved.nid = sentencePatternNid;
    }
    if (sentenceBlueprintScope.isNotEmpty) {
      resolved.blueprintScope = sentenceBlueprintScope;
    }
    return resolved;
  }

  /// 从句子结构中抽取槽位句面内容，优先按 renderSlotKey 与模板槽位对齐。
  Map<String, String> _buildSentenceTextMap(
    List<PatternBlueprintSentenceBriefSegmentEntity?>? segmentList,
  ) {
    final Map<String, String> resp = <String, String>{};
    for (final PatternBlueprintSentenceBriefSegmentEntity? segment
        in segmentList ?? const <PatternBlueprintSentenceBriefSegmentEntity?>[]) {
      if (segment == null) continue;
      final String text = segment.text?.trim() ?? '';
      final List<String> candidateKeys = <String>[
        segment.renderSlotKey?.trim() ?? '',
        segment.slotKey?.trim() ?? '',
        segment.sourceSlotKey?.trim() ?? '',
      ];
      for (final String key in candidateKeys) {
        if (key.isEmpty || text.isEmpty || resp.containsKey(key)) continue;
        resp[key] = text;
      }
      final Map<String, String> childTextMap = _buildSentenceTextMap(segment.childStruct?.segmentList);
      childTextMap.forEach((key, value) {
        if (key.isEmpty || value.trim().isEmpty || resp.containsKey(key)) {
          return;
        }
        resp[key] = value;
      });
    }
    return resp;
  }

  /// 按槽位别名链路取句面内容，避免 render alias / controlled source 对不齐时丢字。
  String _resolveMappedText(
    SentenceSlotMapItemEntity item,
    Map<String, String> sentenceTextMap,
  ) {
    final List<String> candidateKeys = <String>[
      item.slotKey.trim(),
      ...item.sourceControlledKeys.map((key) => key.trim()),
    ];
    for (final String key in candidateKeys) {
      final String text = sentenceTextMap[key]?.trim() ?? '';
      if (key.isEmpty || text.isEmpty) {
        continue;
      }
      return text;
    }
    return '';
  }

  /// 槽里已有内容时，顶部标签改为槽位显示名，对齐 Web 已有句子列表。
  String _buildFilledSlotLabel(SentenceSlotMapItemEntity item) {
    final String detailsName = item.details?.blueprint?.displayName?.trim() ?? '';
    if (detailsName.isNotEmpty) {
      return detailsName;
    }
    final String text = item.text.trim();
    if (text.isNotEmpty) {
      return text;
    }
    return item.label;
  }
}
