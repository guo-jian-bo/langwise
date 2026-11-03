
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:marquee/marquee.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../painter/gradient_border_painter.dart';

/// 公告轮播
class AnnouncementRotationWidgetDialog{

  static void show({
    required String text,
  }){

    BotToast.showCustomText(
      onlyOne: true,
      duration: null,
      align: const Alignment(0, -0.7),
      useSafeArea: true,
      crossPage: false,
      toastBuilder: (cancelFunc) {
        return AnnouncementRotationWidget(text: text);
      },
    );

  }

}

class AnnouncementRotationWidget extends StatefulWidget {
  /// 公告内容
  final String text;
  final void Function()? onClose;

  /// 公告轮播
  const AnnouncementRotationWidget({super.key, required this.text, this.onClose});

  @override
  State<AnnouncementRotationWidget> createState() => _AnnouncementRotationWidgetState();
}

class _AnnouncementRotationWidgetState extends State<AnnouncementRotationWidget> {

  @override
  Widget build(BuildContext context) {

    TextStyle style = TextStyle(
      color: AppTheme.cInverseTextLight.color,
      fontSize: 24.wMin,
      fontWeight: FontWeight.w400,
    );

    Widget marqueeWidget = Container();
    if(isTextOverflow(widget.text, style, 800.wMin - 44.wMin - 44.wMin)){
      marqueeWidget = Marquee(
        text: widget.text,
        startAfter: const Duration(seconds: 2),
        startPadding: 10.wMin,
        style: style,
        blankSpace: 100.wMin,
      );
    }else{
      marqueeWidget = Padding(
        padding: EdgeInsets.only(left: 10.wMin),
        child: Text(
          widget.text,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return Stack(
      children: [
        IgnorePointer(
          child: CustomPaint(
            painter: GradientBorderPainter(
              strokeWidth: 0.8.wMin,
              radius: BorderRadius.circular(999),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppTheme.cBorderBrand.color,
                  AppTheme.cBorderBrand.color.withValues(alpha: 0),
                ],
              ),
            ),
            child: Container(
              height: 44.wMin,
              width: 1000.wMin,
              padding: EdgeInsets.only(right: 60.wMin),
              decoration: BoxDecoration(
                color: AppTheme.cBgBrand.color.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44.wMin,
                    height: 44.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cBorderBrand.color,
                    ),
                    child: SvgPicture.asset(
                      "assets/svg/public/icon_megaphone.svg",
                      width: 32.wMin,
                    ),
                  ),
                  Expanded(
                    child: marqueeWidget,
                  ),
                  
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          child: TapScaleWidget(
            onTap: widget.onClose,
            sclae: 1.1,
            child: Container(
              width: 60.wMin,
              height: 44.wMin,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: SvgPicture.asset(
                "assets/svg/public/x.svg",
                width: 24.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cInverseTextLight.color, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ],
    );
  }


  /// 获取文字的长度是否超出父容器
  bool isTextOverflow(String text, TextStyle style, double width) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: width);
    return textPainter.didExceedMaxLines;
  }

}