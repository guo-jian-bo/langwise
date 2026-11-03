import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'writing_boards.dart';

class BoardDiaryPaperWidget extends StatelessWidget {
  final Widget? child;

  /// 横线间距 默认51.wMin
  final double? lineSpacing;

  /// 日记的纸张
  const BoardDiaryPaperWidget({
    super.key,
    this.child,
    this.lineSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0x00000000),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLeftRuleLineWidget(),
            Expanded(
              child: CustomPaint(
                painter: BoardNoisePaperPainter(
                  baseColor: const Color(0xffFFF7ED),
                  lineSpacing: lineSpacing ?? 51.wMin,
                  showRuleLines: true,
                  lineColor: Color(0xffF97316).withValues(alpha: 0.2),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 50.wMin, vertical: 32.wMin),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 装订条
  Widget _buildLeftRuleLineWidget() {
    return const _BoardDiaryBindingStrip();
  }
}

/// 根据真实渲染高度动态生成装订孔数量。
class _BoardDiaryBindingStrip extends StatefulWidget {
  const _BoardDiaryBindingStrip();

  @override
  State<_BoardDiaryBindingStrip> createState() => _BoardDiaryBindingStripState();
}

class _BoardDiaryBindingStripState extends State<_BoardDiaryBindingStrip> {
  /// 装订条节点 key，用来回读真实渲染高度。
  final GlobalKey _stripKey = GlobalKey();

  /// 当前装订条真实高度。
  double _stripHeight = 0;

  @override
  void initState() {
    super.initState();
    _scheduleMeasureStripHeight();
  }

  @override
  Widget build(BuildContext context) {
    const ruleLineColor = Color(0xff7C2D12);
    const holeColor = Color(0xffD9D9D9);
    final verticalPadding = 40.wMin;
    final holeSize = 20.wMin;
    final holeSpacing = 50.wMin;
    final usableHeight = (_stripHeight - verticalPadding * 2).clamp(0.0, double.infinity).toDouble();
    final holeStep = holeSize + holeSpacing;
    final holeCount = usableHeight <= 0 ? 1 : ((usableHeight + holeSpacing) / holeStep).floor().clamp(1, 999);
    _scheduleMeasureStripHeight();
    return Container(
      key: _stripKey,
      width: 80.wMin,
      color: ruleLineColor,
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(holeCount * 2 - 1, (index) {
            if (index.isOdd) return SizedBox(height: holeSpacing);
            return Container(
              width: holeSize,
              height: holeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: holeColor,
              ),
            );
          }),
        ),
      ),
    );
  }

  /// 等装订条布局完成后读取真实高度。
  void _scheduleMeasureStripHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final currentContext = _stripKey.currentContext;
      if (currentContext == null) return;
      final renderBox = currentContext.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) return;
      final nextHeight = renderBox.size.height;
      if ((_stripHeight - nextHeight).abs() < 0.5) return;
      setState(() {
        _stripHeight = nextHeight;
      });
    });
  }
}
