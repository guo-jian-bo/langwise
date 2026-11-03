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

  const ElementsDetailLayout({
    super.key,
    required this.leftPanel,
    required this.rightContent,
    this.title,
    this.bottomBar,
    this.rightRail,
    this.dividerWidth = 32,
    this.contentTopPadding = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            leftPanel,
            VerticalDivider(
              width: dividerWidth.wMin,
              color: AppTheme.cBorderPrimary,
            ),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: contentTopPadding.wMin),
                    child: rightContent,
                  ),
                  if (title != null)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: title!,
                    ),
                ],
              ),
            ),
          ],
        ),
        if (rightRail != null)
          Positioned(
            top: 88.wMin,
            right: -28.wMin,
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
              child: bottomBar!,
            ),
          ),
      ],
    );
  }
}
