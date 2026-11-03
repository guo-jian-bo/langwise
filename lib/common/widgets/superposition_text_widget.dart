
import 'package:flutter/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';


class SuperpositionTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? foregroundColor;
  const SuperpositionTextWidget({
    super.key, 
    required this.text,
    this.style,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: style,
        ),
        if (foregroundColor != null)
          Text(
            text,
            style: style?.copyWith(color: foregroundColor),
          ),
      ],
    );
  }
}

class SuperpositionTextSpanWidget extends WidgetSpan {
  final Color? backgroundColor;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;
  SuperpositionTextSpanWidget({
    required String text,
    super.style,
    Color? foregroundColor,
    super.alignment = PlaceholderAlignment.middle,
    TextBaseline baseline = TextBaseline.alphabetic,
    this.backgroundColor,
    this.border,
    this.borderRadius,
  }) : super(
         baseline: baseline,
         child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.wMin),
            decoration: BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.circular(4.wMin),
              color: backgroundColor,
              border: border,
            ),
            child: SuperpositionTextWidget(
              text: text,
              style: style,
              foregroundColor: foregroundColor,
            ),
         ),
       );
}

class SuperpositionContainerWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? color;
  final Color? foregroundColor;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;
  final BoxShape shape;
  final EdgeInsetsGeometry? margin;
  const SuperpositionContainerWidget({
    super.key, 
    this.width,
    this.height,
    this.color,
    this.foregroundColor,
    this.border,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Stack(
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              shape: shape,
              color: color,
              border: border,
              borderRadius: borderRadius,
            ),
          ),
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              shape: shape,
              color: foregroundColor,
              border: border,
              borderRadius: borderRadius,
            ),
          ),
        ],
      ),
    );
  }
}

