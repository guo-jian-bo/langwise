import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'board_stick_in_animation.dart';

class BoardMessageNotePaperWidget extends StatelessWidget {
  final Widget? child;

  /// 是否显示入场动画
  final bool showAnimation;
  const BoardMessageNotePaperWidget({super.key, this.child, this.showAnimation = true});

  @override
  Widget build(BuildContext context) {
    return BoardStickInAnimation(
      showAnimation: showAnimation,
      beginOffsetY: -24.wMin,
      beginScale: 1.04,
      middleScale: 0.985,
      beginRotationAngle: 3.2 * pi / 180,
      endRotationAngle: 1.0 * pi / 180,
      builder: (context, rotationAngle) {
        return Container(
          padding: EdgeInsets.only(top: 24.wMin, bottom: 24.wMin, left: 24.wMin, right: 24.wMin),
          child: Transform.rotate(
            angle: rotationAngle,
            child: Container(
              color: Color(0xfffff1f2),
              padding: EdgeInsets.symmetric(vertical: 7.wMin),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDivWidget(),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 50.wMin, vertical: 32.wMin),
                        child: child,
                      ),
                    ],
                  ),
                  _buildDivWidget(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDivWidget() {
    return DottedBorder(
      borderType: BorderType.RRect,
      padding: EdgeInsets.zero,
      strokeWidth: 14.wMin,
      color: const Color(0xfffb7185),
      dashPattern: [24.wMin, 10.wMin],
      customPath: (size) => Path()
        ..moveTo(0, size.height)
        ..relativeLineTo(size.width, 0),
      child: Container(),
    );
  }
}
