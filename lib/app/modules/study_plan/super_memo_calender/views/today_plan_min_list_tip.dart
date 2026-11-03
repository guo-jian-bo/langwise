import 'package:bot_toast/bot_toast.dart';
import 'package:bubble_box/bubble_box.dart';
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../theme/theme.dart';

class TodayPlanMinListTip{

  static void show({
    required BuildContext context,
    required List<StudyPlanEntityPlanCourses> planCoursesList,
  }){
    BotToast.showAttachedWidget(
      targetContext: context,
      backgroundColor: Colors.transparent,
      onlyOne: true,
      preferDirection:PreferDirection.bottomCenter,
      verticalOffset: 16.wMin,
      attachedBuilder: (cancelFunc) {
        return SizedBox(
          width: 400.wMin,
          child: BubbleBox(
            backgroundColor: AppTheme.cBgTertiary,
            padding: EdgeInsets.symmetric(horizontal: 24.wMin),
            elevation: 1,
            shadowColor: AppTheme.cOverlayBackground.color,
            shape: BubbleShapeBorder(
              direction: BubbleDirection.top,
              arrowQuadraticBezierLength: 1,
              radius: BorderRadius.circular(6.wMin),
              arrowHeight: 10.wMin,
              arrowAngle: 10.wMin,
              smooth: 0,
            ),
            child: TodayPlanMinListTipWidget(planCoursesList: planCoursesList),
          ),
        );
      },
    );
  }

}

class TodayPlanMinListTipWidget extends StatefulWidget {
  final List<StudyPlanEntityPlanCourses> planCoursesList;
  const TodayPlanMinListTipWidget({super.key, required this.planCoursesList});

  @override
  State<TodayPlanMinListTipWidget> createState() => _TodayPlanMinListTipWidgetState();
}

class _TodayPlanMinListTipWidgetState extends State<TodayPlanMinListTipWidget> {

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: widget.planCoursesList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) {
        return Container(height: 1.wMin, color: AppTheme.cBorderSecondary.color);
      },
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 16.wMin),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 10.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.planCoursesList[index].courseName??"",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text.rich(TextSpan(
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  const TextSpan(text: "计划时长 "),
                  TextSpan(
                    text: "${((widget.planCoursesList[index].dailyStudyDuration??0) / 60).toInt()}",
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w600,
                    )
                  ),
                  const TextSpan(text: " 分钟"),
                ],
              )),
            ],
          ),
        );
      },
    );
  }

}