import 'package:flutter/material.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class TagButtonWidget extends StatelessWidget {
  final String? text;
  final Widget? child;
  final Widget? leading;
  final Widget? trailing;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderWidth;
  final double? borderRadius;
  final double spacing;
  final int maxLines;
  final TextOverflow overflow;
  final TextAlign textAlign;
  final AlignmentGeometry alignment;
  final BoxConstraints? constraints;
  final TextStyle? textStyle;

  const TagButtonWidget({
    super.key,
    this.text,
    this.child,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.fontSize,
    this.fontWeight = FontWeight.w500,
    this.padding,
    this.margin,
    this.borderWidth,
    this.borderRadius,
    this.spacing = 4,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign = TextAlign.center,
    this.alignment = Alignment.center,
    this.constraints,
    this.textStyle,
  }) : assert(text != null || child != null, 'Either text or child must be provided.');

  @override
  Widget build(BuildContext context) {
    final resolvedTextStyle = textStyle ??
        TextStyle(
          color: textColor ?? AppTheme.cTextPrimary.color,
          fontSize: fontSize ?? 16.wMin,
          fontWeight: fontWeight,
        );

    return Container(
      margin: margin,
      constraints: constraints,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.cSurfaceGhostBgSubtle.color,
        borderRadius: BorderRadius.circular(borderRadius ?? 6.wMin),
        border: Border.all(
          color: borderColor ?? AppTheme.cBorderSubtle.color,
          width: borderWidth ?? 0.8,
        ),
      ),
      child: Align(
        alignment: alignment,
        widthFactor: 1,
        heightFactor: 1,
        child: child ?? _buildDefaultContent(resolvedTextStyle),
      ),
    );
  }

  Widget _buildDefaultContent(TextStyle resolvedTextStyle) {
    return DefaultTextStyle(
      style: resolvedTextStyle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) leading!,
          if (leading != null && text != null && text!.trim().isNotEmpty) SizedBox(width: spacing.wMin),
          if (text != null && text!.trim().isNotEmpty)
            Text(
              text!,
              maxLines: maxLines,
              overflow: overflow,
              textAlign: textAlign,
            ),
          if (trailing != null && text != null && text!.trim().isNotEmpty) SizedBox(width: spacing.wMin),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
