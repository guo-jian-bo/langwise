
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';

class ManageCrossFadeWidget extends StatelessWidget {
  final bool isExpanded;
  final String? title;
  final Widget firstChild;
  final String? buttonText;
  final String? buttonText1;
  final void Function()? onButton;
  final void Function()? onButton1;
  final void Function()? onToggleExpand;
  final Widget? centerWidget;
  const ManageCrossFadeWidget({
    super.key, 
    this.onToggleExpand, 
    this.isExpanded = false, 
    this.title, 
    required this.firstChild,
    this.onButton,
    this.onButton1,
    this.buttonText,
    this.buttonText1,
    this.centerWidget,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.wMin)),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cBgSecondary.color,
          border: Border(
            top: BorderSide(
              color: AppTheme.cBorderPrimary.color,
              width: 1.wMin,
            ),
          ),
        ),
        child: Column(
          children: [
            TapScaleWidget(
              onTap: onToggleExpand,
              sclae: 1,
              child: Container(
                width: double.infinity,
                color: Colors.transparent,
                padding: EdgeInsets.all(16.wMin),
                child: Row(
                  children: [
                    SizedBox(height: 40.wMin),
                    
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: isExpanded ? 1 : 0),
                      duration: const Duration(milliseconds: 200),
                      builder: (context, value, child) {
                        return Transform.rotate(
                          angle: value * pi / 2,
                          child: child,
                        );
                      },
                      child: SvgPicture.asset(
                        "assets/svg/public/icon_w_arrow_right.svg",
                        key: ValueKey(isExpanded),
                        height: 24.wMin,
                        colorFilter: ColorFilter.mode(
                          AppTheme.cTextSecondary.color,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    
                    Text(
                      title??"",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.cTextSecondary.color,
                      ),
                    ),
              
                    Expanded(
                      child: SizedBox(child: centerWidget),
                    ),
              
                    Visibility(
                      visible: onButton != null,
                      child: ButtonWidget(
                        text: buttonText??"",
                        padding: EdgeInsets.symmetric(horizontal: 10.wMin),
                        height: 40.wMin,
                        borderRadius: 8.wMin,
                        color: AppTheme.cSurfaceTertiary.color,
                        fontColor: AppTheme.cTextTertiary.color,
                        tapColor: AppTheme.cTextTertiary.color.withValues(alpha: 0.1),
                        sclae: 1.05,
                        fontSize: 18.wMin,
                        leftIcon: Container(
                          margin: EdgeInsets.only(right: 4.wMin),
                          child: SvgPicture.asset(
                            "assets/svg/public/icon_add.svg",
                            width: 24.wMin,
                            height: 24.wMin,
                            colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
                          ),
                        ),
                        onTap: onButton,
                      ),
                    ),

                    Visibility(
                      visible: onButton1 != null,
                      child: Container(
                        margin: EdgeInsets.only(left: 16.wMin),
                        child: ButtonWidget(
                          text: buttonText1??"",
                          padding: EdgeInsets.symmetric(horizontal: 10.wMin),
                          height: 40.wMin,
                          borderRadius: 8.wMin,
                          color: AppTheme.cSurfaceTertiary.color,
                          fontColor: AppTheme.cTextTertiary.color,
                          tapColor: AppTheme.cTextTertiary.color.withValues(alpha: 0.1),
                          sclae: 1.05,
                          fontSize: 18.wMin,
                          leftIcon: Container(
                            margin: EdgeInsets.only(right: 4.wMin),
                            child: SvgPicture.asset(
                              "assets/svg/public/icon_add.svg",
                              width: 24.wMin,
                              height: 24.wMin,
                              colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
                            ),
                          ),
                          onTap: onButton1,
                        ),
                      ),
                    ),
              
              
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              firstChild: firstChild, 
              secondChild: Container(width: double.infinity), 
              crossFadeState: isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond, 
            ),
          ],
        ),
      ),
    );
  }
}

class ManageCrossFadeTitleWidget extends StatelessWidget {
  final bool isExpanded;
  final String? title;
  final Widget? titleIcon;
  final Widget firstChild;
  final void Function()? onToggleExpand;
  const ManageCrossFadeTitleWidget({
    super.key, 
    this.isExpanded = false, 
    this.title, 
    this.titleIcon, 
    required this.firstChild, 
    this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        TapScaleWidget(
          onTap: onToggleExpand,
          sclae: 1,
          child: Container(
            width: double.infinity,
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 12.wMin),
            child: Row(
              children: [
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: isExpanded ? 1 : 0),
                  duration: const Duration(milliseconds: 200),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value * pi / 2,
                      child: child,
                    );
                  },
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_w_arrow_right.svg",
                    key: ValueKey(isExpanded),
                    height: 24.wMin,
                    colorFilter: ColorFilter.mode(
                      AppTheme.cTextSecondary.color,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                
                Text(
                  title??"",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),

                if(titleIcon != null) titleIcon!,
          
              ],
            ),
          ),
        ),

        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond, 
          secondChild: Container(width: double.infinity), 
          firstChild: firstChild, 
        ),
      ],
    );
  }
}