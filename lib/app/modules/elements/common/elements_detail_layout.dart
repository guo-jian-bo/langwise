import 'package:flutter/material.dart';
import 'package:themed/themed.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../theme/theme.dart';

class ElementsDetailLayout extends StatelessWidget {
  final Widget leftPanel;
  final Widget rightContent;
  final Widget? title;
  final Widget? bottomBar;
  final Widget? rightRail;
  final double dividerWidth;
  final double contentTopPadding;
  final EdgeInsetsGeometry contentPadding;

  const ElementsDetailLayout({
    super.key,
    required this.leftPanel,
    required this.rightContent,
    this.title,
    this.bottomBar,
    this.rightRail,
    this.dividerWidth = 32,
    this.contentTopPadding = 48,
    this.contentPadding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: contentPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leftPanel,
              VerticalDivider(
                width: dividerWidth.wMin,
                color: AppTheme.cBorderPrimary,
              ),
              Expanded(
                child: rightContent,
              ),
            ],
          ),
        ),
        if (rightRail != null)
          Positioned(
            right: 24.wMin,
            bottom: bottomInset + 90.wMin,
            child: Align(
              alignment: Alignment.centerRight,
              child: rightRail!,
            ),
          ),
        if (bottomBar != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: Padding(
                padding: contentPadding,
                child: bottomBar!,
              ),
            ),
          ),
      ],
    );
  }
}
