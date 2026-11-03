

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../theme/theme.dart';
import '../list_animation_widget.dart';
import '../platform_backdrop_filter_widget.dart';
import '../tap_scale_widget.dart';

class PricureActionButtonWidget extends StatelessWidget {
  final String title;

  final Color color;

  final void Function()? onTap;
  final int iconQuarterTurns;
  const PricureActionButtonWidget({
    super.key,
    required this.title,
    required this.color,

    this.onTap,
    this.iconQuarterTurns = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ListAnimationWidget(

      horizontalOffset: 70.wMin,
      delay: const Duration(milliseconds: 100),
      child: TapScaleWidget(

        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.wMin),
          child: PlatformBackdropFilterWidget(
            sigmaX: 10.wMin,
            sigmaY: 10.wMin,
            child: Container(
              // width: width,
              height: 48.wMin,
              padding: EdgeInsets.only(left: 16.wMin, right: 8.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: color.withValues(alpha: 0.15),
                border: Border.all(
                  color: color.withValues(alpha: 0.2),
                  width: 1.wMin,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 4.wMin,
                children: [

                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.cTextPrimary.color,
                      fontSize: 22.wMin,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  RotatedBox(
                    quarterTurns: iconQuarterTurns,
                    child: SvgPicture.asset(
                      'assets/svg/user_center/icon_chevron_right1.svg',
                      width: 20.wMin,
                      height: 20.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
