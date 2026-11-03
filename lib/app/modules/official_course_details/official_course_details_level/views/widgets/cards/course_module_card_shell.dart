import 'package:flutter/material.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class CourseModuleCardShell extends StatelessWidget {
  final double? width;
  final double? height;
  final double mainContentHeight;
  final Widget mainContent;
  final Widget footer;
  final BorderSide? borderSide;
  final Color? backgroundColor;
  final Color? dividerColor;
  final EdgeInsetsGeometry? padding;
  final double radius;

  const CourseModuleCardShell({
    super.key,
    this.width,
    this.height,
    required this.mainContentHeight,
    required this.mainContent,
    required this.footer,
    this.borderSide,
    this.backgroundColor,
    this.dividerColor,
    this.padding,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.cSurfaceLayerBase2,
        borderRadius: BorderRadius.circular(radius.wMin),
        border: Border.fromBorderSide(
          borderSide ??
              BorderSide(
                color: AppTheme.cBorderSecondary,
                width: 1.wMin,
              ),
        ),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(16.wMin),
        child: Column(
          children: [
            SizedBox(
              height: mainContentHeight,
              child: mainContent,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.wMin),
              child: Divider(
                height: 1,
                thickness: 1,
                color: dividerColor ?? AppTheme.cBorderSubtle,
              ),
            ),
            footer,
          ],
        ),
      ),
    );

    if (width == null && height == null) {
      return child;
    }
    return SizedBox(
      width: width,
      height: height,
      child: child,
    );
  }
}
