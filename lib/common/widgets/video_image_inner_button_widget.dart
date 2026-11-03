import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'platform_backdrop_filter_widget.dart';

class VideoImageInnerButtonWidget extends StatelessWidget {
  final String? text;
  final Widget? child;
  final Widget? leading;
  final Widget? trailing;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final String? leadingAssetPath;
  final String? trailingAssetPath;
  final double? iconSize;
  final double? iconWidth;
  final double? iconHeight;
  final BoxFit iconFit;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? shadowColor;
  final double? fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderWidth;
  final double? borderRadius;
  final double? blurSigma;
  final double? shadowBlurRadius;
  final Offset? shadowOffset;
  final double spacing;
  final int maxLines;
  final TextOverflow overflow;
  final TextAlign textAlign;
  final AlignmentGeometry alignment;
  final BoxConstraints? constraints;
  final TextStyle? textStyle;
  final List<BoxShadow>? boxShadow;

  const VideoImageInnerButtonWidget({
    super.key,
    this.text,
    this.child,
    this.leading,
    this.trailing,
    this.leadingIcon,
    this.trailingIcon,
    this.leadingAssetPath,
    this.trailingAssetPath,
    this.iconSize,
    this.iconWidth,
    this.iconHeight,
    this.iconFit = BoxFit.contain,
    this.iconColor,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.shadowColor,
    this.fontSize,
    this.fontWeight = FontWeight.w500,
    this.padding,
    this.margin,
    this.borderWidth,
    this.borderRadius,
    this.blurSigma = 8,
    this.shadowBlurRadius,
    this.shadowOffset,
    this.spacing = 4,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign = TextAlign.center,
    this.alignment = Alignment.center,
    this.constraints,
    this.textStyle,
    this.boxShadow,
  }) : assert(text != null || child != null,
            'Either text or child must be provided.');

  @override
  Widget build(BuildContext context) {
    final resolvedBackgroundColor =
        backgroundColor ?? AppTheme.cStaticDeprecatedBlack60.color;
    final resolvedBorderColor =
        borderColor ?? AppTheme.cStaticDeprecatedWhite50.color;
    final resolvedTextColor = textColor ?? AppTheme.cTextInverse.color;
    final resolvedBorderWidth = borderWidth ?? 0.8;
    final resolvedBorderRadius = borderRadius ?? 8.wMin;
    final resolvedBlurSigma = blurSigma ?? 8;
    final resolvedPadding =
        padding ?? EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin);
    final resolvedFontSize = fontSize ?? 20.wMin;
    // final resolvedBoxShadow = boxShadow ??
    //     <BoxShadow>[
    //       BoxShadow(
    //         color: shadowColor ?? AppTheme.cStaticDeprecatedBlack60.color,
    //         blurRadius: shadowBlurRadius ?? 8.wMin,
    //         offset: shadowOffset ?? Offset(0, 2.wMin),
    //       ),
    //     ];

    final content = Container(
      margin: margin,
      constraints: constraints,
      padding: resolvedPadding,
      decoration: BoxDecoration(
        color: resolvedBackgroundColor,
        borderRadius: BorderRadius.circular(resolvedBorderRadius),
        border: resolvedBorderWidth > 0
            ? Border.all(color: resolvedBorderColor, width: resolvedBorderWidth)
            : null,
        // boxShadow: resolvedBoxShadow,
      ),
      child: Align(
        alignment: alignment,
        widthFactor: 1,
        heightFactor: 1,
        child: child ?? _buildTextContent(resolvedTextColor, resolvedFontSize),
      ),
    );

    final clippedContent = ClipRRect(
      borderRadius: BorderRadius.circular(resolvedBorderRadius),
      child: resolvedBlurSigma > 0
          ? PlatformBackdropFilterWidget(
              sigmaX: resolvedBlurSigma,
              sigmaY: resolvedBlurSigma,
              child: content,
            )
          : content,
    );

    if (onTap == null) return clippedContent;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: clippedContent,
    );
  }

  Widget _buildTextContent(Color resolvedTextColor, double resolvedFontSize) {
    final resolvedIconColor = iconColor ?? resolvedTextColor;
    final Widget? resolvedLeading = leading ??
        _buildIconData(leadingIcon, resolvedIconColor, resolvedFontSize) ??
        _buildAssetIcon(leadingAssetPath);
    final Widget? resolvedTrailing = trailing ??
        _buildIconData(trailingIcon, resolvedIconColor, resolvedFontSize) ??
        _buildAssetIcon(trailingAssetPath);
    final widgets = <Widget>[
      if (resolvedLeading != null) resolvedLeading,
      if (resolvedLeading != null && text != null && text!.trim().isNotEmpty)
        SizedBox(width: spacing.wMin),
      if (text != null && text!.trim().isNotEmpty)
        Flexible(
          child: Text(
            text!,
            maxLines: maxLines,
            overflow: overflow,
            textAlign: textAlign,
            style: textStyle ??
                TextStyle(
                  color: resolvedTextColor,
                  fontSize: resolvedFontSize,
                  fontWeight: fontWeight,
                ),
          ),
        ),
      if (resolvedTrailing != null && text != null && text!.trim().isNotEmpty)
        SizedBox(width: spacing.wMin),
      if (resolvedTrailing != null) resolvedTrailing,
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  Widget? _buildIconData(
      IconData? iconData, Color resolvedIconColor, double resolvedFontSize) {
    if (iconData == null) return null;
    final resolvedIconSize =
        iconSize ?? iconWidth ?? iconHeight ?? resolvedFontSize;
    return Icon(
      iconData,
      size: resolvedIconSize,
      color: resolvedIconColor,
    );
  }

  Widget? _buildAssetIcon(String? assetPath) {
    if (assetPath == null || assetPath.trim().isEmpty) return null;
    final resolvedWidth = iconWidth ?? 20.wMin;
    final resolvedHeight = iconHeight ?? resolvedWidth;
    if (assetPath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        width: resolvedWidth,
        height: resolvedHeight,
        fit: iconFit,
      );
    }
    return Image.asset(
      assetPath,
      width: resolvedWidth,
      height: resolvedHeight,
      fit: iconFit,
    );
  }
}
