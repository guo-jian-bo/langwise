import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'board_paper_noise_layer.dart';

class BoardReportPaperWidget extends StatelessWidget {
  final Widget? child;

  /// 报告纸张
  const BoardReportPaperWidget({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: BoardPaperNoiseLayer(
          darkColor: const Color(0xff6B7280),
          lightColor: const Color(0xffffffff),
          darkAlpha: 0.022,
          lightAlpha: 0.018,
          density: 420,
          minRadius: 0.22,
          maxRadius: 0.72,
          seedSalt: 19,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: false, // 隐藏滚动条
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: 70.wMin,
                left: 120.wMin,
                right: 50.wMin,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleWidget(),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 32.wMin),
                    child: child
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "REPORT",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: Colors.black.withValues(alpha: 0.5),
            letterSpacing: 8.wMin,
          ),
        ),
        SizedBox(height: 8.wMin),
        Container(
          height: 4.wMin,
          color: Color(0xff0EA5E9),
        ),
      ],
    );
  }
}
