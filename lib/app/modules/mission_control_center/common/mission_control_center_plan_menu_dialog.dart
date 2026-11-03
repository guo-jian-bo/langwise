import 'package:bot_toast/bot_toast.dart';
import 'package:bubble_box/bubble_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';

class MissionControlCenterPlanMenuDialog{

  static void show({
    required BuildContext ctx,
    void Function()? onPreview,
    void Function()? onDictation,
    void Function()? onBrowseCourse,
  }){

    BotToast.showAttachedWidget(
      targetContext: ctx,
      backgroundColor: AppTheme.cBlackAlpha50.color,
      onlyOne: true,
      allowClick: false,
      preferDirection: PreferDirection.topCenter,
      attachedBuilder: (cancelFunc) {
        return BubbleBox(
          backgroundColor: AppTheme.cSurfaceSecondary.color,
          padding: EdgeInsets.all(16.wMin),
          shape: BubbleShapeBorder(
            direction: BubbleDirection.bottom,
            arrowQuadraticBezierLength: 2.wMin,
            radius: BorderRadius.circular(8.wMin),
            arrowHeight: 8.wMin,
            arrowAngle: 10.wMin,
            smooth: 1.wMin,
          ),
          child: MissionControlCenterPlanMenuDialogWidget(
            cancelFunc: cancelFunc,
            onPreview: onPreview,
            onDictation: onDictation,
            onBrowseCourse: onBrowseCourse,
          ),
        );
      },
    );

  }

}

class MissionControlCenterPlanMenuDialogWidget extends StatefulWidget {
  final void Function() cancelFunc;
  final void Function()? onPreview;
  final void Function()? onDictation;
  final void Function()? onBrowseCourse;
  
  const MissionControlCenterPlanMenuDialogWidget({super.key, required this.cancelFunc, this.onPreview, this.onDictation, this.onBrowseCourse});

  @override
  State<MissionControlCenterPlanMenuDialogWidget> createState() => _MissionControlCenterPlanMenuDialogWidgetState();
}

class _MissionControlCenterPlanMenuDialogWidgetState extends State<MissionControlCenterPlanMenuDialogWidget> {
  
  
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 36.wMin,
      mainAxisSize: MainAxisSize.min,
      children: [
        TapScaleWidget(
          onTap: () {
            widget.cancelFunc();
            widget.onPreview?.call();
          },
          sclae: 1.03,
          child: _buildButtonItemWidget(
            color: const Color(0xffA855F7),
            svg: "assets/svg/public/icons_eye.svg",
            name: "去预习",
          ),
        ),
        TapScaleWidget(
          onTap: () {
            widget.cancelFunc();
            widget.onDictation?.call();
          },
          sclae: 1.03,
          child: _buildButtonItemWidget(
            color: AppTheme.cSurfaceInfo.color,
            svg: "assets/svg/public/icon_earphones.svg",
            name: "去听写",
          ),
        ),
        TapScaleWidget(
          onTap: () {
            widget.cancelFunc();
            widget.onBrowseCourse?.call();
            
            
          },
          sclae: 1.03,
          child: _buildButtonItemWidget(
            color: const Color(0xffF472B6),
            svg: "assets/svg/mission/icon_browse_courses.svg",
            name: "浏览课程",
          ),
        ),
      ],
    );
  }


  Widget _buildButtonItemWidget({
    required Color color,
    required String svg,
    required String name,
  }){
    return SizedBox(
      width: 100.wMin,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          SizedBox(
            width: 100.wMin,
            height: 90.wMin,
          ),
          Container(
            width: 72.wMin,
            height: 72.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.4),
              border: Border.all(
                color: color,
                width: 4.wMin,
              ),
            ),
            child: SvgPicture.asset(
              svg,
              width: 40.wMin,
            ),
          ),
      
          Positioned(
            bottom: 0,
            child: Container(
              width: 100.wMin,
              height: 32.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.wMin),
                color: color,
              ),
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cStaticWhite.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      
      
      
        ],
      ),
    );
  }

}