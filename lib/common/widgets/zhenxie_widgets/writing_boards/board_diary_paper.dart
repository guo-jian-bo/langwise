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
      height: double.infinity,
      color: const Color(0x00000000),
      child: Row(
        children: [
          _buildLeftRuleLineWidget(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    scrollbars: false, // 隐藏滚动条
                  ),
                  child: SingleChildScrollView(
                    child: CustomPaint(
                      painter: BoardNoisePaperPainter(
                        baseColor: const Color(0xffFFF7ED),
                        lineSpacing: lineSpacing ?? 51.wMin,
                        showRuleLines: true,
                        lineColor: Color(0xffF97316).withValues(alpha: 0.2),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 50.wMin, vertical: 32.wMin),
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: child,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 装订条
  Widget _buildLeftRuleLineWidget() {
    return Container(
      width: 80.wMin,
      height: double.infinity,
      color: Color(0xff7C2D12),
      padding: EdgeInsets.symmetric(vertical: 42.wMin),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double height = constraints.maxHeight;
          double spacing = 60.wMin;
          double dotSize = 20.wMin;
          int count = ((height + spacing) / (spacing + dotSize)).floor();
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 60.wMin,
            children: List.generate(count, (index) {
              return Container(
                width: 20.wMin,
                height: 20.wMin,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xffD9D9D9),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
