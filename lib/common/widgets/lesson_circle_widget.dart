
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
  const LessonCircleWidget({
    super.key, 
    this.child, 
    this.progress = 0, 
    this.selected = false, 
    this.showProgess = true, 
    this.borderColor = AppTheme.cBorderSecondary,
    this.isComplete = false,
    this.showNew = false,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: 240.wMin,
      height: 240.wMin,
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
              width: showProgess ? 190.wMin : null,
              height: showProgess ? 190.wMin : null,
              alignment: Alignment.center,
              child: ClipOval(
                child: child,
              ),
            ),
          ),
          Visibility(
            visible: progress == 1,
            child: Positioned(
              bottom: -20.wMin,
              child: Container(
                width: 61.wMin,
                height: 61.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cBgBrand,
                  border: Border.all(width: 4.wMin, color: Colors.white),
                ),
                child: Icon(Icons.check_sharp, color: Colors.white, size: 32.wMin),
              ),
            ),
          ),
          Visibility(
            visible: selected,
            child: Positioned(
              bottom: -45.wMin,
              child: SizedBox(
                width: 128.wMin,
                height: 54.wMin,
                child: BubbleBox(
                  backgroundColor: AppTheme.cFeedbackWarningBorder.color,
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.all(2.wMin),
                  shape: BubbleShapeBorder(
                    direction: BubbleDirection.top,
                    arrowQuadraticBezierLength: 4,
                    radius: BorderRadius.circular(10.wMin),
                    arrowHeight: 8.wMin,
                    arrowAngle: 8.wMin,
                    smooth: 0,
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.cSurfaceSecondary.color,
                      borderRadius: BorderRadius.circular(6.5.wMin),
                    ),
                    child: Text(
                      "当前位置",
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cFeedbackWarningText.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: showNew,
            child: Positioned(
              top: 0,
              right: -10.wMin,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: ShimmerWidget(
                  colorOpacity: 0.2,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 4.wMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(width: 2.wMin, color: AppTheme.cFeedbackErrorBorder),
                      color: AppTheme.cBgSecondary,
                    ),
                    child: Text(
                      "新增题目",
                      style: TextStyle(
                        fontSize: 20.wMin,
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

  Widget _buildSegmentPor(){
    if(isComplete){
      return Container(
        width: 190.wMin,
        height: 190.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 10.wMin, color: borderColor),
        ),
      );
    }

    int occupiedScore = (progress * 20).floor();
    if(progress != 0 && occupiedScore < 1){
      occupiedScore = 1;
    }
    

    return AnimatedCircleView(
      key: ValueKey(progress),
      duration: Duration.zero,
      fadeInDuration: Duration.zero,
      curve: Curves.easeInOutCubic,
      borderWidth: 10.wMin,
      strokeWidth: 10.wMin,
      circlePainterConfig: CirclePainterConfig.segmented(
        baseColor: Colors.transparent,
        segments: List.generate(20, (index){
          Color segmentColor;
          if(index < occupiedScore){
            segmentColor = borderColor;
          }else{
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