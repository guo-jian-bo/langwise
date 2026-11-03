
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../theme/theme.dart';
import '../widgets.dart';

class PlayTitleWidget extends StatelessWidget {
  final String? title;
  final String? titleFontFamily;
  final void Function()? onFeedbackError;
  const PlayTitleWidget({super.key, this.title, this.titleFontFamily, this.onFeedbackError});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 60.wMin),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: PlatformBackdropFilterWidget(
          sigmaX: 5.wMin,
          sigmaY: 5.wMin,
          child: Container(
            height: 72.wMin,
            decoration: BoxDecoration(
              color: AppTheme.cSurfacePlayerBackground.color,
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderDark.color),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [

                TapScaleWidget(
                  onTap: () {
                    Get.back();
                  },
                  sclae: 1.05,
                  child: Container(
                    height: 72.wMin,
                    width: 72.wMin,
                    alignment: Alignment.center,
                    child: Container(
                      width: 48.wMin,
                      height: 48.wMin,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.cSurfaceGhostBgSubtle.color,
                        shape: BoxShape.circle,
                        border: Border.all(width: 0.8.wMin, color: AppTheme.cBorderSubtle.color),
                      ),
                      child: SvgPicture.asset(
                        "assets/svg/public/icon_arrow_back.svg",
                        width: 32.wMin,
                        colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12.wMin),

                Text(
                  title ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                    fontFamily: titleFontFamily,
                  ),
                ),

                const Spacer(),

                _buildFeedbackErrorWidget(context),

                SizedBox(width: 24.wMin),

              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 反馈错误按钮
  Widget _buildFeedbackErrorWidget(BuildContext context){
    if(onFeedbackError == null) return Container();
    return FeedbackErrorContentButtonWidget(
      fontColor: AppTheme.cTextSecondary.color,
      onTap: onFeedbackError,
    );
  }

}