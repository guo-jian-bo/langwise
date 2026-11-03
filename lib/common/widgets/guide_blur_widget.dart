import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

class GuideBlurWidget extends StatelessWidget {
  final bool isBlurred;
  final Widget child;
  final double height;
  final double radius;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GuideBlurWidget({
    super.key,
    this.isBlurred = false,
    required this.height,
    required this.radius,
    required this.child,
    this.width,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    if (isBlurred) {
      return Stack(
        clipBehavior: Clip.none,
        alignment: const Alignment(0, 0),
        children: [
          Positioned(
            right: 40.ww,
            child: buildImage("", width: 80.ww, height: 80.ww),
          ),
          Container(
            height: height,
            width: width,
            padding: padding,
            margin: margin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius), // radius
              border: Border.all(
                color: const Color(0xFF007BC5),
                width: 1,
              ),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0x9F1AA6F3), // rgba(26, 166, 243, 0.62)
                  Color(0x821AA6F3), // rgba(26, 166, 243, 0.51)
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25), // 阴影颜色
                  offset: const Offset(0, 12), // 阴影偏移
                  blurRadius: 12, // 模糊半径
                  spreadRadius: -4.3, // 阴影向内扩散
                ),
              ],
            ),
            child: child,
          ),
        ],
      );
    }

    return Container(
      height: height,
      width: width,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: const Color(0xFF007BC5),
          width: 1,
        ),
        color: const Color.fromRGBO(9, 12, 28, 0.40),
      ),
      child: child,
    );
  }
}

class GuideStyleBlurWidget extends StatelessWidget {
  final bool isBlurred;
  final Widget child;
  final double height;
  final double radius;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GuideStyleBlurWidget({
    super.key,
    this.isBlurred = false,
    required this.height,
    required this.radius,
    required this.child,
    this.width,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    if (isBlurred) {
      return Container(
        height: height,
        width: width,
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius), // radius
          border: Border.all(
            color: const Color(0xFF007BC5),
            width: 1,
          ),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0x9F1AA6F3),
              Color(0x821AA6F3),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25), // 阴影颜色
              offset: const Offset(0, 12), // 阴影偏移
              blurRadius: 12, // 模糊半径
              spreadRadius: -4.3, // 阴影向内扩散
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -5.ww,
              right: -10.ww,
              child: buildImage("", width: 80.ww, height: 80.ww),
            ),
            Positioned(left: 0, right: 0, top: 0, bottom: 0, child: child)
          ],
        ),
      );
    }

    return Container(
      height: height,
      width: width,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: const Color(0xFF007BC5),
          width: 1,
        ),
        color: const Color.fromRGBO(9, 12, 28, 0.40),
      ),
      child: child,
    );
  }
}
