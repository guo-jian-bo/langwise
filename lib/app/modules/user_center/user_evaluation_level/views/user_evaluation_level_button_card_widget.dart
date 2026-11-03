import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/widgets/widgets.dart';

class UserEvaluationLevelButtonCardWidget extends StatelessWidget {
  final Color color;
  final String svg;
  final String title;
  final String subTitle;
  final String buttonText;
  final void Function()? onTap;
  /// 按钮卡片
  const UserEvaluationLevelButtonCardWidget({
    super.key,
    required this.color,
    required this.svg,
    required this.title,
    required this.subTitle,
    required this.buttonText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(32.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32.wMin),
          color: AppTheme.cBgSecondary.color,
        ),
        child: Column(
          children: [
            Container(
              width: 94.wMin,
              height: 94.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
                color: color.withValues(alpha: 0.3),
              ),
              child: SvgPicture.asset(svg, width: 48.wMin),
            ),
            SizedBox(height: 44.wMin),
            Text(
              title,
              style: TextStyle(
                fontSize: 36.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 24.wMin),
            const Spacer(),
            ButtonWidget(
              text: buttonText,
              onTap: onTap,
              sclae: 1.01,
              height: 80.wMin,
              borderRadius: 12.wMin,
              color: color,
              fontColor: AppTheme.cStaticWhite.color,
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
}