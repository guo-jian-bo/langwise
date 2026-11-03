import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class BackWidget extends StatelessWidget {
  final String? title;
  final Color? fontColor;
  final double? fontSize;
  final String? fontFamily;
  final double? titleMaxWidth;
  final Color? backIconColor;
  final void Function()? onTap;
  const BackWidget({
    super.key, 
    this.title, 
    this.fontColor,
    this.fontSize,
    this.titleMaxWidth,
    this.fontFamily,
    this.backIconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TapScaleWidget(
          onTap: onTap ?? () => Get.back(),
          sclae: 1.1,
          child: Container(
            width: 64.wMin,
            height: 64.wMin,
            color: Colors.transparent,
            alignment: Alignment.center,
            child: SvgPicture.asset(
              "assets/svg/public/icon_arrow_back.svg",
              width: 40.wMin,
              height: 40.wMin,
              colorFilter: backIconColor != null ? ColorFilter.mode(backIconColor!, BlendMode.srcIn) : null,
            ),
          ),
        ),
        Visibility(
          visible: title != null && title != "",
          child: Container(
            margin: EdgeInsets.only(left: 8.wMin),
            constraints: BoxConstraints(
              maxWidth: titleMaxWidth?? double.infinity,
            ),
            child: Text(
              title??"",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize??28.wMin,
                color: fontColor??AppTheme.cTextPrimary,
                fontWeight: FontWeight.w600,
                fontFamily: fontFamily,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
