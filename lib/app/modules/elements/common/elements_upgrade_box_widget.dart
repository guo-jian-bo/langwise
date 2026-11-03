import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ElementsUpgradeBoxWidget extends StatelessWidget {
  final Widget? child;
  final int pageIndex;
  final double currentPageIndex;
  final EdgeInsetsGeometry? padding;
  const ElementsUpgradeBoxWidget({
    super.key,
    this.child,
    this.pageIndex = 0,
    this.currentPageIndex = 0, 
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    double difference = (currentPageIndex - pageIndex).abs();
    double alpha = 1;
    if (difference == 0) {
      alpha = 1.0;
    } else if (difference <= 1) {
      alpha = 1 - difference;
    } else {
      alpha = 0;
    }

    return Center(
      child: IgnorePointer(
        ignoring: pageIndex != currentPageIndex,
        child: AspectRatio(
          aspectRatio: 1120 / 690,
          child: Container(
            width: 1120.wMin,
            height: 690.wMin,
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40.wMin),
              color: const Color(0xff1A1C20),
              border: Border.all(
                width: 2.wMin, color: const Color(0xff027611).withValues(alpha: alpha), // 颜色和掌握程度改变
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}