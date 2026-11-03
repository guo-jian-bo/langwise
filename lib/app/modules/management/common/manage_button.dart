import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ManageButton extends StatefulWidget {
  final double? width;
  final double? height;
  final double? radius;
  final double sclae;
  final Color? color;
  final Color? borderColor;
  final String text;
  final TextStyle? style;
  final EdgeInsetsGeometry? padding;
  final void Function()? onTap;

  const ManageButton(
      {super.key,
      this.width,
      this.height,
      this.radius,
      this.color,
      this.borderColor,
      required this.text,
      this.style,
      this.onTap,
      this.sclae = 1.1,
      this.padding});

  @override
  State<ManageButton> createState() => _ManageButtonState();
}

class _ManageButtonState extends State<ManageButton> {
  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: widget.onTap,
      sclae: widget.sclae,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.radius ?? 8.wMin),
          border: Border.all(
            width: 2.wMin,
            color: widget.borderColor ?? const Color(0xff4B5268),
          ),
        ),
        child: Text(
          widget.text,
          style: widget.style ??
              TextStyle(
                fontSize: 14.wMin,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
        ),
      ),
    );
  }
}
