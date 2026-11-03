import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ShadowStarWidget extends StatelessWidget {
  final double? size;
  const ShadowStarWidget({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          bottom: -2.5.wMin,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 1.5.wMin, sigmaY: 1.5.wMin),
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                "assets/images/elements/icon_star.webp", 
                width: size ?? 20.wMin,

              ),
            ),
          ),
        ),

        Image.asset(
          "assets/images/elements/icon_star.webp", 
          width: size ?? 20.wMin,
        ),
      ],
    );
  }
}