import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';
import 'button_widgets.dart';
import 'tap_scale_widget.dart';

class DialogBoxWidget extends StatelessWidget {
  final String? title;
  final String cancel;
  final String define;
  final String other;
  final Widget child;
  final double width;
  final Widget? subTitle;
  final bool showCancel;
  final bool isEnabled;
  final bool showOther;
  final void Function()? onCancel;
  final void Function()? onDefine;
  final void Function()? onOther;
  const DialogBoxWidget({
    super.key,
    this.cancel = "取消",
    this.define = "确定",
    required this.child,
    this.subTitle,
    this.onCancel,
    this.onDefine,
    this.title,
    this.showCancel = true,
    this.showOther = false,
    required this.width,
    this.other = "",
    this.onOther,
    this.isEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildTitleWidget() {
      return Container(
        padding: EdgeInsets.only(left: 24.wMin),
        child: Row(
          children: [
            Text(
              title ?? "",
              style: TextStyle(
                fontSize: 22.wMin,
                color: const Color(0xffEBEEF3),
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            SizedBox(
              child: subTitle,
            ),
            TapScaleWidget(
              onTap: onCancel,
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.all(24.wMin),
                child: Icon(Icons.clear, color: const Color(0xffBAC0CC), size: 26.wMin),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Material(
        color: const Color(0xff040712).withValues(alpha: 0.8),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: width,
              decoration: BoxDecoration(
                color: const Color(0xff181B25),
                borderRadius: BorderRadius.circular(16.wMin),
                border: Border.all(width: 1.wMin, color: const Color(0xff444B5F)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildTitleWidget(),
                  child,
                  SizedBox(height: 10.wMin),
                  Container(
                    padding: EdgeInsets.all(24.wMin),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Visibility(
                          visible: showOther,
                          child: Container(
                            margin: EdgeInsets.only(right: 13.wMin),
                            child: ButtonWidget(
                              text: other,
                              borderRadius: 6.wMin,
                              border: Border.all(width: 0.5.wMin, color: const Color(0xff767E95)),
                              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                              height: 40.wMin,
                              color: Colors.transparent,
                              fontSize: 14.wMin,
                              fontColor: const Color(0xffEBEEF3),
                              onTap: onOther,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: showCancel,
                          child: Container(
                            margin: EdgeInsets.only(right: 13.wMin),
                            child: ButtonWidget(
                              text: cancel,
                              borderRadius: 6.wMin,
                              border: Border.all(width: 0.5.wMin, color: const Color(0xff767E95)),
                              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                              height: 40.wMin,
                              color: Colors.transparent,
                              fontSize: 14.wMin,
                              fontColor: const Color(0xffEBEEF3),
                              onTap: onCancel,
                            ),
                          ),
                        ),
                        ButtonWidget(
                          text: define,
                          borderRadius: 6.wMin,
                          height: 40.wMin,
                          padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                          color: isEnabled ? const Color(0xFF2388FF) : const Color(0xff353E5C),
                          fontSize: 14.wMin,
                          fontColor: isEnabled ? Colors.white : const Color(0xffACB4C0),
                          onTap: onDefine,
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(height: 24.wMin),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class DialogUserWidget extends StatelessWidget {
  final Widget? child;
  final String? title;
  final double? width;
  final ScrollPhysics physics;
  final EdgeInsetsGeometry? titlePadding;
  const DialogUserWidget({
    super.key, 
    this.child, 
    this.title, 
    this.width,
    this.titlePadding,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cOverlayBackground.color,
      body: Center(
        child: SingleChildScrollView(
          physics: physics,
          child: Container(
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.wMin),
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
              color: AppTheme.cSurfaceSecondary.color,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: titlePadding ?? EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 24.wMin),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Visibility(
                          visible: title != null,
                          child: Text(
                            title ?? '',
                            style: TextStyle(
                              fontSize: 32.wMin,
                              color: AppTheme.cTextPrimary.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      TapScaleWidget(
                        sclae: 1.05,
                        onTap: () => Get.back(),
                        child: Container(
                          width: 48.wMin,
                          height: 48.wMin,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.cSurfaceTertiary.color,
                            border: Border.all(width: 1.wMin, color: AppTheme.cBorderDefault.color),
                          ),
                          child: SvgPicture.asset(
                            "assets/svg/public/x.svg",
                            width: 24.wMin,
                            height: 24.wMin,
                            colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                          ),
                        ),
                      ),
                  
                    ],
                  ),
                ),
          
                SizedBox(child: child),
          
          
              ],
            ),
          ),
        ),
      ),
    );
  }
}