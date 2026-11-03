import 'package:bot_toast/bot_toast.dart';
import 'package:bubble_box/bubble_box.dart';
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../theme/theme.dart';

class MemoryRecorderTip{

  static void show({
    required BuildContext context,
    required Offset offset,
  }){
    BotToast.showAttachedWidget(
      target: offset,
      backgroundColor: Colors.transparent,
      onlyOne: true,
      preferDirection:PreferDirection.topCenter,
      attachedBuilder: (cancelFunc) {
        return BubbleBox(
          backgroundColor: AppTheme.cBgTertiary.color,
          padding: EdgeInsets.all(2.wMin),
          shape: BubbleShapeBorder(
            direction: BubbleDirection.bottom,
            arrowQuadraticBezierLength: 1,
            radius: BorderRadius.circular(9.wMin),
            arrowHeight: 10.wMin,
            arrowAngle: 10.wMin,
            smooth: 0,
          ),
          child: const MemoryRecorderTipWidget(),
        );
      },
    );
  }

}


class MemoryRecorderTipWidget extends StatefulWidget {
  const MemoryRecorderTipWidget({super.key});

  @override
  State<MemoryRecorderTipWidget> createState() => _MemoryRecorderTipWidgetState();
}

class _MemoryRecorderTipWidgetState extends State<MemoryRecorderTipWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfacePrimary.color,
        borderRadius: BorderRadius.circular(9.wMin),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "97.5分",
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            "第1次学习",
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}