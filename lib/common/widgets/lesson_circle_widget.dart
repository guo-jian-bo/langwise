import 'package:bubble_box/bubble_box.dart';
import 'package:flutter/material.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'segmented_circular_progress/animated_circle_view.dart';
import 'segmented_circular_progress/circle_painter.dart';
import 'segmented_circular_progress/circle_segment.dart';
import 'widgets.dart';

class LessonCircleWidget extends StatelessWidget {
  final Widget? child;
  final bool selected;
  final Color borderColor;
  // 0- 1
  final double progress;
  final bool showProgess;
  final bool isComplete;
  final bool showNew;
  final bool continuousProgress;
  final double? size;
  final double? innerSize;
  const LessonCircleWidget({
    super.key,
    this.child,
    this.progress = 0,
    this.selected = false,
    this.showProgess = true,
    this.borderColor = AppTheme.cBorderSecondary,
    this.isComplete = false,
    this.showNew = false,
    this.continuousProgress = false,
    this.size,
    this.innerSize,
  });

  @override
  Widget build(BuildContext context) {
    final baseSize = 240.wMin;
    final outer = size ?? baseSize;
    final scale = outer / baseSize;
    final inner = innerSize ?? (showProgess ? 200.wMin * scale : null);
    return SizedBox(
      width: outer,
      height: outer,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          Visibility(
            visible: showProgess,
            child: _buildSegmentPor(),
          ),
          Center(
            child: Container(
              width: inner,
              height: inner,
              alignment: Alignment.center,
              child: ClipOval(
                child: child,
              ),
            ),
          ),
          Visibility(
            visible: progress == 1,
            child: Positioned(
              right: 24.wMin * scale,
              bottom: 0.wMin,
              child: Container(
                width: 61.wMin * scale,
                height: 61.wMin * scale,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: borderColor,
                ),
                child: Icon(Icons.check_sharp, color: Colors.white, size: 32.wMin * scale),
              ),
            ),
          ),
          Visibility(
            visible: selected,
            child: Positioned(
              right: 24.wMin * scale,
              bottom: 0.wMin,
              child: Container(
                width: 61.wMin * scale,
                height: 61.wMin * scale,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: borderColor,
                ),
                child: Icon(Icons.play_arrow_sharp, color: Colors.white, size: 32.wMin * scale),
              ),
            ),
          ),
          Visibility(
            visible: showNew,
            child: Positioned(
              top: 0,
              right: -10.wMin * scale,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: ShimmerWidget(
                  colorOpacity: 0.2,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.wMin * scale, vertical: 4.wMin * scale),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(width: 2.wMin * scale, color: AppTheme.cFeedbackErrorBorder),
                      color: AppTheme.cBgSecondary,
                    ),
                    child: Text(
                      "新增题目",
                      style: TextStyle(
                        fontSize: 20.wMin * scale,
                        color: AppTheme.cFeedbackErrorText,
                        fontWeight: FontWeight.w500,
                        height: 1.05,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentPor() {
    final baseSize = 240.wMin;
    final outer = size ?? baseSize;
    final scale = outer / baseSize;
    if (isComplete) {
      return Container(
        width: 190.wMin * scale,
        height: 190.wMin * scale,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 10.wMin * scale, color: borderColor),
        ),
      );
    }

    int occupiedScore = (progress * 20).floor();
    if (progress != 0 && occupiedScore < 1) {
      occupiedScore = 1;
    }

    return AnimatedCircleView(
      key: ValueKey(progress),
      duration: Duration.zero,
      fadeInDuration: Duration.zero,
      curve: Curves.easeInOutCubic,
      borderWidth: 10.wMin * scale,
      strokeWidth: 10.wMin * scale,
      isContinuous: continuousProgress,
      progressValue: continuousProgress ? progress : null,
      circlePainterConfig: CirclePainterConfig.segmented(
        baseColor: Colors.transparent,
        segments: List.generate(20, (index) {
          Color segmentColor;
          if (index < occupiedScore) {
            segmentColor = borderColor;
          } else {
            segmentColor = borderColor.withValues(alpha: 0.1);
          }
          return CircleSegment(
            fillColor: segmentColor,
            borderColor: segmentColor,
            ratio: 0.05,
          );
        }),
      ),
    );
  }
}
