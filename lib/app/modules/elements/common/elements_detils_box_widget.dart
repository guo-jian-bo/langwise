import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ElementsDetilsBoxWidget extends StatefulWidget {
  final Widget? child;
  final int pageIndex;
  final double currentPageIndex;
  final EdgeInsetsGeometry? padding;
  const ElementsDetilsBoxWidget({
    super.key,
    this.child,
    this.pageIndex = 0,
    this.currentPageIndex = 0, 
    this.padding,
  });

  @override
  State<ElementsDetilsBoxWidget> createState() => _ElementsDetilsBoxWidgetState();
}

class _ElementsDetilsBoxWidgetState extends State<ElementsDetilsBoxWidget> {
  @override
  Widget build(BuildContext context) {
    double difference = (widget.currentPageIndex - widget.pageIndex).abs();
    double alpha = 1;
    double opacity = 1;
    if (difference == 0) {
      alpha = 1.0;
      opacity = 1.0;
    } else if (difference <= 1) {
      alpha = 1 - difference;
      opacity = 1 - difference * 0.4;
    } else {
      alpha = 0;
      opacity = 0.6;
    }

    return IgnorePointer(
      ignoring: widget.pageIndex != widget.currentPageIndex,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 1678.wMin,
          height: 884.wMin,
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32.wMin),
            border: Border.all(
              width: 2.wMin, color: const Color(0xff027611).withValues(alpha: alpha), // 颜色和掌握程度改变
            ),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(28, 43, 41, 1),
                Color.fromRGBO(21, 23, 27, 1),
                Color.fromRGBO(21, 23, 27, 1),
              ],
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}