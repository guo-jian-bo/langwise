
import 'package:bot_toast/bot_toast.dart';
import 'package:bubble_box/bubble_box.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/static/static_data.dart';

/// 学习计划介绍 黄金学练 超级记忆
class TodayPlanIntroductionTip{

  static void show({BuildContext?context}){
    BotToast.showAttachedWidget(
      targetContext: context,
      backgroundColor: Colors.transparent,
      onlyOne: true,
      preferDirection:PreferDirection.bottomRight,
      verticalOffset: 10.wMin,
      attachedBuilder: (cancelFunc) {
        return TodayPlanIntroductionTipWidget(cancelFunc: cancelFunc);
      },
    );
  }

}

class TodayPlanIntroductionTipWidget extends StatefulWidget {
  final void Function() cancelFunc;
  const TodayPlanIntroductionTipWidget({super.key, required this.cancelFunc});

  @override
  State<TodayPlanIntroductionTipWidget> createState() => _TodayPlanIntroductionTipWidgetState();
}

class _TodayPlanIntroductionTipWidgetState extends State<TodayPlanIntroductionTipWidget> {

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
          position: BubblePosition.end(12.wMin),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 24.wMin,
          children: [
            _buildTextWidget("黄金学练", StaticData.goldRatioDesc),
            _buildTextWidget("超级记忆", StaticData.superMemoDesc),
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

  Widget _buildTextWidget(String name, String value){
    return Column(
      spacing: 6.wMin,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

}