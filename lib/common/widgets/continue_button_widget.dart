import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ContinueButtonWidget extends StatelessWidget {
  final String text;
  final double? width;
  final double? height;
  final double sclae;
  final bool buttonDisable;
  final double? fontSize;
  final Color? fontColor;
  final void Function()? onTap;
  const ContinueButtonWidget({
    super.key, 
    this.text = "继续", 
    this.width, 
    this.height, 
    this.sclae = 1.01, 
    this.onTap, 
    this.fontColor = AppTheme.cStaticWhite,
    this.buttonDisable = false,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      sclae: sclae,
      onTap: buttonDisable ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: width,
        height: height??64.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: buttonDisable ? AppTheme.cBorderDisabled : AppTheme.cBgBrand,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 5.wMin,
              offset: Offset(0, 4.wMin),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize??20.wMin,
            color: buttonDisable ? AppTheme.cTextDisabled : fontColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
