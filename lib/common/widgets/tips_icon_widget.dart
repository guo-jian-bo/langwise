import 'package:bot_toast/bot_toast.dart';
import 'package:bubble_box/bubble_box.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';


class TipsIconWidget extends StatefulWidget {
  final Widget? icon;
  final String? tipsText;
  /// 气泡提示
  const TipsIconWidget({super.key, this.icon, this.tipsText});

  @override
  State<TipsIconWidget> createState() => _TipsIconWidgetState();
}

class _TipsIconWidgetState extends State<TipsIconWidget> {

  void showTips(){
    BotToast.showAttachedWidget(
      targetContext: context,
      backgroundColor: Colors.transparent,
      onlyOne: true,
      preferDirection:PreferDirection.bottomCenter,
      attachedBuilder: (cancelFunc) {
        return Container(
          constraints: BoxConstraints(
            minWidth: 200.wMin,
            maxWidth: 300.wMin,
          ),
          child: BubbleBox(
            backgroundColor: AppTheme.cBgQuaternary,
            padding: EdgeInsets.all(15.wMin),
            shape: BubbleShapeBorder(
              direction: BubbleDirection.top,
              arrowQuadraticBezierLength: 1,
              radius: BorderRadius.circular(20.wMin),
              arrowHeight: 20.wMin,
              arrowAngle: 13.wMin,
              smooth: 0,
              border: BubbleBoxBorder(width: 1.wMin, color: AppTheme.cBgBrand),
            ),
            child: Text(
              widget.tipsText??"",
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget? body = widget.icon;
    if(widget.icon == null) {
      // body = Image.asset(
      //   Assets.createStudyPlanIconHelp,
      //   width: 20.wh,
      // );
    }
    return TapScaleWidget(
      behavior: HitTestBehavior.opaque,
      sclae: 1.05,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.all(10.wMin),
        child: body,
      ),
      onTap: widget.tipsText == null || widget.tipsText == "" ? null : () {
        showTips();
      },
    );
  }
}