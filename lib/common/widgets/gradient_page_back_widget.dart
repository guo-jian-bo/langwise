import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

class GradientPageBackWidget extends StatelessWidget {
  final Widget child;
  final double opacity;
  const GradientPageBackWidget({super.key, required this.child, this.opacity = 1});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Positioned(
            top: 150.wMin,
            left: 50.wMin,
            child: Transform.rotate(
              angle: -0.2,
              child: Container(
                width: 1000.wMin,
                height: 300.wMin,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(400),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff2D57ED).withValues(alpha: opacity),
                      blurRadius: 1000.wMin,
                      spreadRadius: 60.wMin,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100.wMin,
            right: 100.wMin,
            child: Transform.rotate(
              angle: -0.1,
              child: Container(
                width: 1000.wMin,
                height: 400.wMin,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(400),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xffE44A00).withValues(alpha: 0.32 * opacity),
                      blurRadius: 1000.wMin,
                      spreadRadius: 10.wMin,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(),
            ),
          ),
          child,
        ],
      ),
    );
  }
}