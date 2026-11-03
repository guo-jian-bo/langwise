import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ElementsAnalysisCardLayoutItem {
  final int flex;
  final Widget child;

  const ElementsAnalysisCardLayoutItem({
    required this.flex,
    required this.child,
  });
}

class ElementsAnalysisCardRow extends StatelessWidget {
  final List<ElementsAnalysisCardLayoutItem> items;

  const ElementsAnalysisCardRow({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    if (items.length == 1) return items.first.child;

    final List<Widget> children = [];
    for (int index = 0; index < items.length; index++) {
      final ElementsAnalysisCardLayoutItem item = items[index];
      children.add(
        Expanded(
          flex: item.flex,
          child: item.child,
        ),
      );
      if (index < items.length - 1) {
        children.add(SizedBox(width: 16.wMin));
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class ElementsAnalysisEmptyState extends StatelessWidget {
  final String text;

  const ElementsAnalysisEmptyState({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.wMin),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class ElementsAnalysisCardWidget extends StatelessWidget {
  final String chineseTitle;
  final String englishTitle;
  final int? index;
  final Color fromColor;
  final Color toColor;
  final Widget child;
  final VoidCallback? onTap;

  const ElementsAnalysisCardWidget({
    super.key,
    required this.chineseTitle,
    required this.englishTitle,
    required this.index,
    required this.fromColor,
    required this.toColor,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.01,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceTranslucentBase.color,
          borderRadius: BorderRadius.circular(18.wMin),
          border: Border.all(
            color: AppTheme.cBorderTranslucentThin.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 58.wMin,
              padding: EdgeInsets.only(right: 20.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.wMin),
                  topRight: Radius.circular(18.wMin),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [fromColor.withValues(alpha: 0.12), Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 40.wMin,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 8.wMin,
                          height: 40.wMin,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(18.wMin),
                              bottomRight: Radius.circular(18.wMin),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [fromColor, toColor],
                            ),
                          ),
                        ),
                        SizedBox(width: 8.wMin),
                        Text(
                          chineseTitle,
                          style: TextStyle(
                            fontSize: 30.wMin,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.cTextPrimary,
                          ),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              englishTitle.toUpperCase(),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.wMin,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.cTextTertiary,
                              ),
                            ),
                            Text(
                              (index ?? 0).toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: 14.wMin,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.cTextTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: child),
            Row(
              children: [
                const Spacer(),
                Container(
                  width: 48.wMin,
                  height: 48.wMin,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.wMin),
                      bottomRight: Radius.circular(18.wMin),
                    ),
                    color: fromColor.withValues(alpha: 0.12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24.wMin,
                        height: 24.wMin,
                        child: SvgPicture.asset(
                          "assets/svg/public/Icons_dictionary_right.svg",
                          height: 24.wMin,
                          colorFilter: ColorFilter.mode(fromColor, BlendMode.srcIn),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
