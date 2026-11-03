import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../theme/theme.dart';

/// 句子分析详情弹窗内容区
class ElementsSentenceDialogBodyWidget extends StatelessWidget {
  final String chipText;
  final Color chipTextColor;
  final Color chipBackground;
  final Color chipBorderColor;
  final String zhText;
  final String enText;
  final String titleText;

  const ElementsSentenceDialogBodyWidget({
    super.key,
    required this.chipText,
    required this.chipTextColor,
    required this.chipBackground,
    required this.chipBorderColor,
    required this.zhText,
    required this.enText,
    this.titleText = '',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.fromLTRB(32.wMin, 0, 32.wMin, 32.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 12.wMin,
              runSpacing: 12.wMin,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 10.wMin),
                  decoration: BoxDecoration(
                    color: chipBackground,
                    borderRadius: BorderRadius.circular(6.wMin),
                    border: Border.all(color: chipBorderColor, width: 1.wMin),
                  ),
                  child: Text(
                    chipText,
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w600,
                      color: chipTextColor,
                    ),
                  ),
                ),
                if (titleText.isNotEmpty)
                  Text(
                    titleText,
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cTextPrimary,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 24.wMin),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.wMin),
              decoration: BoxDecoration(
                color: AppTheme.cSurfaceTranslucentBase.color,
                borderRadius: BorderRadius.circular(12.wMin),
                border: Border.all(
                  color: AppTheme.cBorderTranslucentThin.color,
                  width: 1.wMin,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SelectableText(
                    zhText,
                    style: TextStyle(
                      fontSize: 28.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cTextPrimary,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: 18.wMin),
                  Divider(
                    height: 1.wMin,
                    thickness: 1.wMin,
                    color: AppTheme.cBorderTranslucentThin.color,
                  ),
                  SizedBox(height: 18.wMin),
                  SelectableText(
                    enText,
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
