import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class AccessActionButtonWidget extends StatelessWidget {
  static const String defaultIconAsset = 'assets/svg/user_center/icon_chevron_right1.svg';

  final String text;
  final bool isUnlocked;
  final bool showIcon;
  final String iconAsset;
  final Widget? icon;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? iconSize;
  final double? iconSpacing;
  final double? borderRadius;
  final double? borderWidth;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? iconColor;
  final FontWeight? fontWeight;
  final double? fontSize;

  const AccessActionButtonWidget({
    super.key,
    required this.text,
    this.isUnlocked = true,
    this.showIcon = false,
    this.iconAsset = defaultIconAsset,
    this.icon,
    this.onTap,
    this.margin,
    this.padding,
    this.height,
    this.iconSize,
    this.iconSpacing,
    this.borderRadius,
    this.borderWidth,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.iconColor,
    this.fontWeight,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedBackgroundColor = backgroundColor ??
        (isUnlocked ? AppTheme.cSurfaceQuaternary.color : AppTheme.cFeedbackWarningBackground.color);
    final resolvedBorderColor = borderColor ??
        (isUnlocked ? AppTheme.cBorderTertiary.color : AppTheme.cFeedbackWarningBackground.color);
    final resolvedTextColor = textColor ??
        (isUnlocked ? AppTheme.cTextPrimary.color : AppTheme.cFeedbackWarningText.color);
    final resolvedIconColor = iconColor ??
        (isUnlocked ? AppTheme.cTextPrimary.color : AppTheme.cFeedbackWarningIcon.color);
    final resolvedFontWeight = fontWeight ?? (isUnlocked ? FontWeight.w400 : FontWeight.w600);
    final resolvedFontSize = fontSize ?? 22.wMin;
    final content = Container(
      margin: margin ?? EdgeInsets.only(bottom: 8.wMin),
      height: height ?? 48.wMin,
      padding: padding ?? EdgeInsets.only(left: 16.wMin, right: 8.wMin,top: 8.wMin,bottom: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 8.wMin),
        color: resolvedBackgroundColor,
        border: Border.all(
          color: resolvedBorderColor,
          width: borderWidth ?? 0.6.wMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: resolvedFontSize,
              fontWeight: resolvedFontWeight,
              color: resolvedTextColor,
            ),
          ),
          if (showIcon) SizedBox(width: iconSpacing ?? 2.wMin),
          if (showIcon)
            icon ??
                SvgPicture.asset(
                  iconAsset,
                  width: iconSize ?? 20.wMin,
                  height: iconSize ?? 20.wMin,
                  colorFilter: ColorFilter.mode(resolvedIconColor, BlendMode.srcIn),
                ),

          if (!showIcon) SizedBox(width: 8.wMin),
        ],
      ),
    );

    if (onTap == null) return content;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: content,
    );
  }
}
