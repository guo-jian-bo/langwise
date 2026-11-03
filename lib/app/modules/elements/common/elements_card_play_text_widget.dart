import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ElementsCardPlayTextWidget extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final double? fontSize;
  final Color? textColor;
  final FontWeight? fontWeight;
  final int? maxLines;
  final double? maxWidth;
  final CrossAxisAlignment crossAxisAlignment;
  const ElementsCardPlayTextWidget({
    super.key, 
    required this.text, 
    this.padding, 
    this.borderRadius, 
    this.backgroundColor, 
    this.fontSize,
    this.textColor,
    this.fontWeight,
    this.maxLines,
    this.maxWidth,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 0.wMin),
        color: backgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          SvgPicture.asset("assets/svg/public/icon_primary_speaker.svg", width: 24.wMin),
          SizedBox(width: 8.wMin),
          Container(
            constraints: BoxConstraints(
              maxWidth: maxWidth??double.infinity,
            ),
            child: AutoSizeText(
              text,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              minFontSize: 16,
              style: TextStyle(
                fontSize: fontSize ?? 20.wMin,
                color: textColor ?? AppTheme.cTextSecondary,
                fontWeight: fontWeight ?? FontWeight.w500,
                height: 1,
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}