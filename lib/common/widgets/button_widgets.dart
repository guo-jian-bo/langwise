import 'package:flutter/material.dart';
import 'tap_scale_widget.dart';

class ButtonWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final double sclae;
  final double borderRadius;
  final Color color;
  final double fontSize;
  final Color fontColor;
  final FontWeight fontWeight;
  final String text;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final void Function()? onTap;
  final Color? tapColor;
  const ButtonWidget({
    super.key, 
    this.width, 
    this.height, 
    this.sclae = 1.1, 
    this.borderRadius = 30, 
    this.color = const Color(0xff1AA6F3), 
    this.fontSize = 16, 
    this.fontColor = Colors.white, 
    this.fontWeight = FontWeight.w400, 
    required this.text, 
    this.alignment = Alignment.center,
    this.onTap, 
    this.border, 
    this.padding,
    this.leftIcon,
    this.rightIcon,
    this.tapColor,
  });

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      sclae: sclae,
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      backColor: tapColor,
      borderRadius: borderRadius,
      child: AnimatedContainer(
        width: width,
        height: height,
        padding: padding,
        duration: const Duration(milliseconds: 200),
        alignment: alignment,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if(leftIcon != null) leftIcon!,
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                color: fontColor,
                fontWeight: fontWeight,
              ),
            ),
            if(rightIcon != null) rightIcon!,
          ],
        ),
      ),
    );
  }
}



