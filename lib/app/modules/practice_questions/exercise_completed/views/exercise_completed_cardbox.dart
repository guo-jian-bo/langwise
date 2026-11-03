import 'package:flutter/material.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ExerciseCompletedCardbox extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool show;
  const ExerciseCompletedCardbox({super.key, required this.child, this.padding, this.show = true});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: show ? 1 : 0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.wMin),
          child: Container(
            width: 720.wMin,
            height: 760.wMin,
            padding: padding??EdgeInsets.symmetric(horizontal: 80.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.wMin),
              color: AppTheme.cBgSecondary,
            ),
            child: Visibility(
              visible: show,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}