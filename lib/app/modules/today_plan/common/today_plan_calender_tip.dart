import 'package:bot_toast/bot_toast.dart';
import 'package:bubble_box/bubble_box.dart';
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';

/// 计划日历说明
class TodayPlanCalenderTip{

  static void show({BuildContext? context}){
    BotToast.showAttachedWidget(
      targetContext: context,
      backgroundColor: Colors.transparent,
      onlyOne: true,
      preferDirection:PreferDirection.bottomCenter,
      verticalOffset: 10.wMin,
      attachedBuilder: (cancelFunc) {
        return TodayPlanCalenderTipWidget(cancelFunc: cancelFunc);
      },
    );
  }

}

class TodayPlanCalenderTipWidget extends StatefulWidget {
  final void Function() cancelFunc;
  const TodayPlanCalenderTipWidget({super.key, required this.cancelFunc});

  @override
  State<TodayPlanCalenderTipWidget> createState() => _TodayPlanCalenderTipWidgetState();
}

class _TodayPlanCalenderTipWidgetState extends State<TodayPlanCalenderTipWidget> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 592.wMin,
      child: BubbleBox(
        backgroundColor: AppTheme.cBgQuaternary.color,
        padding: EdgeInsets.all(16.wMin),
        elevation: 1,
        shadowColor: AppTheme.cOverlayBackground.color,
        shape: BubbleShapeBorder(
          direction: BubbleDirection.top,
          arrowQuadraticBezierLength: 1,
          radius: BorderRadius.circular(16.wMin),
          arrowHeight: 10.wMin,
          arrowAngle: 10.wMin,
          smooth: 0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8.wMin,
          children: [

            _buildTextRowWidget(
              "绿色数字：", 
              "表示当天已学习的知识点数量。", 
              AppTheme.cFeedbackSuccessText.color,
            ),
            _buildTextRowWidget(
              "橙色数字：", 
              "表示当天已经完成的题目数量。", 
              AppTheme.cFeedbackWarningText.color,
            ),
            _buildTextRowWidget(
              "红色叉号：", 
              "表示当天未学习。", 
              AppTheme.cFeedbackErrorText.color,
            ),
            _buildTextRowWidget(
              "白色数字（浅色模式下为黑色）：", 
              "表示当天系统下发的题目总数。", 
              AppTheme.cTextPrimary.color,
            ),
            _buildTextRowWidget(
              "灰色数字：", 
              "表示预计需要复习的知识点数量，会根据学习情况动态调整。", 
              AppTheme.cTextTertiary.color,
            ),

            Container(
              alignment: Alignment.centerRight,
              child: TapScaleWidget(
                onTap: () {
                  widget.cancelFunc();
                },
                sclae: 1.05,
                child: Text(
                  "我知道了",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextBrand.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTextRowWidget(String name, String value, Color color){
    return Text.rich(TextSpan(
      style: TextStyle(
        fontSize: 24.wMin,
        color: AppTheme.cTextPrimary.color,
        fontWeight: FontWeight.w600,
      ),
      children: [
        TextSpan(
          text: name,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 24.wMin,
          ),
        ),
        TextSpan(text: value),
      ],
    ));
  }

}