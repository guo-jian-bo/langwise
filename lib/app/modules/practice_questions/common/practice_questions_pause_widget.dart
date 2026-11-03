
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';

class PracticeQuestionsPauseWidget extends StatelessWidget {
  final bool isPause;
  final VoidCallback onTap;
  const PracticeQuestionsPauseWidget({super.key, required this.isPause, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
        onTap: onTap,
        sclae: 1.1,
        child: Container(
          width: 70.wMin,
          height: 70.wMin,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.cSurfaceBrand,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isPause
                ? Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    key: const ValueKey(false),
                    size: 45.wMin,
                  )
                : Icon(
                    Icons.pause_rounded,
                    key: const ValueKey(true),
                    color: Colors.white,
                    size: 45.wMin,
                  ),
          ),
        ),
      );
  }
}