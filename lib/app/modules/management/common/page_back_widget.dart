import 'dart:ui';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:flutter/material.dart';

class PageBackWidget extends StatelessWidget {
  final Widget child;

  const PageBackWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // todo 圆角暂时为0 / 24.wMin
      borderRadius: BorderRadius.circular(0),
      child: Stack(
        children: [
          Positioned.fill(
            bottom: -1000.ww / 1.8,
            left: 0,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 206, sigmaY: 206),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xff050916),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomLeft,
                    margin: EdgeInsets.only(left: 50.ww),
                    child: Container(
                      width: 1000.ww,
                      height: 1000.ww,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        // UI要求暂时透明
                        color: Colors.transparent,
                        // color: const Color(0xff2388FF).withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            child: child,
          ),
        ],
      ),
    );
  }
}
