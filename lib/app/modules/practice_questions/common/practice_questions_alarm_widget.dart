import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import 'practice_questions_painter.dart';

class PracticeQuestionsAlarmWidget extends StatelessWidget {
  final bool isPause;
  final bool isCountdown;
  final double countdownSecondProgress;
  final void Function()? onTap;
  /// 闹钟图标
  const PracticeQuestionsAlarmWidget({
    super.key, 
    required this.isPause, 
    this.isCountdown = false, 
    this.countdownSecondProgress = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color = AppTheme.cTextPrimary.color;
    return IgnorePointer(
      ignoring: isPause,
      child: TapScaleWidget(
        onTap: onTap,
        sclae: 1.02,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            key: ValueKey(isCountdown),
            width: 70.wMin,
            height: 70.wMin,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 70.wMin,
                  height: 70.wMin,
                  padding: EdgeInsets.all(5.wMin),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 10.wMin, color: color),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cFeedbackInfoBackground,
                    ),
                    child: CustomPaint(
                      painter: CountdownProgressCirclePainter(
                        progress: countdownSecondProgress,
                        color: color,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8.wMin,
                  left: 0,
                  child: Transform.rotate(
                    angle: -0.8,
                    child: Container(
                      width: 15.wMin,
                      height: 10.wMin,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3.wMin),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 7.wMin,
                  child: Transform.rotate(
                    angle: 0.9,
                    child: Container(
                      width: 15.wMin,
                      height: 10.wMin,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3.wMin),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -10.wMin,
                  child: Container(
                    width: 15.wMin,
                    height: 15.wMin,
                    color: color,
                  ),
                ),
                Positioned(
                  top: -12.wMin,
                  child: Container(
                    width: 30.wMin,
                    height: 8.wMin,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3.wMin),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}