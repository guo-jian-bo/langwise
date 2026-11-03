import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'board_noise_paper_painter.dart';

class BoardNoisePaperWidget extends StatelessWidget {
  /// 纸张上的内容
  final Widget? child;

  /// 横线间距 默认51.wMin
  final double? lineSpacing;

  /// 是否显示横线
  final bool showRuleLines;
  
  /// 是否显示图钉
  final bool showPin;

  /// 噪点纸张背景
  const BoardNoisePaperWidget({
    super.key,
    this.child,
    this.lineSpacing,
    this.showRuleLines = false,
    this.showPin = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
              showRuleLines: showRuleLines,
              lineColor: Colors.black.withValues(alpha: 0.05),
            ),
            child: Container(
              width: double.infinity,
              color: const Color(0x00000000),
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                children: [
                  Visibility(
                    visible: showPin,
                    child: Container(
                      margin: EdgeInsets.only(top: 20.wMin),
                      child: Image.asset(
                        "assets/images/public/icon_thumbtack.png",
                        width: 66.wMin,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 50.wMin, vertical: 32.wMin),
                    child: child,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      },
    );
  }

}

