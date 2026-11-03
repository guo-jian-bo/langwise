import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'board_paper_noise_layer.dart';

class BoardTablePaperWidget extends StatelessWidget {
  final Widget? child;

  /// 表格纸张
  const BoardTablePaperWidget({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        child: BoardPaperNoiseLayer(
          darkColor: const Color(0xff6B7280),
          lightColor: const Color(0xffffffff),
          darkAlpha: 0.022,
          lightAlpha: 0.018,
          density: 420,
          minRadius: 0.22,
          maxRadius: 0.72,
          seedSalt: 19,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: 50.wMin,
              left: 50.wMin,
              right: 50.wMin,
              bottom: 50.wMin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTitleWidget(),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 32.wMin),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWidget() {
    return Column(
      spacing: 16.wMin,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          spacing: 16.wMin,
          children: [
            _buildTitleItemWidget("Name"),
            _buildTitleItemWidget("Date"),
          ],
        ),
        Row(
          spacing: 16.wMin,
          children: [
            _buildTitleItemWidget("Class"),
            _buildTitleItemWidget("No."),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleItemWidget(String name) {
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 14.wMin,
                fontWeight: FontWeight.w400,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 6.wMin),
            DottedBorder(
              borderType: BorderType.RRect,
              dashPattern: [3.wMin, 3.wMin],
              color: Colors.black.withValues(alpha: 0.2),
              strokeWidth: 1.wMin,
              customPath: (size) => Path()
                ..moveTo(0, size.height)
                ..relativeLineTo(size.width, 0),
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: 1.wMin,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
