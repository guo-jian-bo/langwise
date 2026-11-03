
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';
import 'widgets.dart';

class CardLearningButtonsWidget extends StatefulWidget {
  final bool showPreview;
  final void Function()? onPreview;
  
  final bool showFlash;
  final void Function()? onFlash;
  
  final bool showDictation;
  final void Function()? onDictation;
  
  final bool showDownload;
  final void Function()? onDownload;
  

  /// 预习 闪卡 听写 下载 按钮
  const CardLearningButtonsWidget({
    super.key,
    this.showPreview = true,
    this.onPreview,
    this.showFlash = true,
    this.onFlash,
    this.showDictation = true,
    this.onDictation,
    this.showDownload = true,
    this.onDownload,

  });

  @override
  State<CardLearningButtonsWidget> createState() => _CardLearningButtonsWidgetState();
}

class _CardLearningButtonsWidgetState extends State<CardLearningButtonsWidget> {

  @override
  Widget build(BuildContext context) {

    List<Widget> widgetList = [];
    if(widget.showPreview){
      widgetList.add(_buildFloatButtonItemWidget(
        title: '预习',
        svg: 'assets/svg/public/icons_eye.svg',
        color: const Color(0xffA855F7),
        index: 0,
        onTap: widget.onPreview,
      ));
    }

    if(widget.showDictation){
      widgetList.add(_buildFloatButtonItemWidget(
        title: '听写',
        svg: 'assets/svg/public/icon_earphones.svg',
        color: AppTheme.cSurfaceInfo.color,
        index: widgetList.length,
        onTap: widget.onDictation,
      ));
    }

    if(widget.showFlash){
      widgetList.add(_buildFloatButtonItemWidget(
        title: '闪记',
        svg: 'assets/svg/public/icon_lightning.svg',
        color: const Color(0xffEC4899),
        index: widgetList.length,
        onTap: widget.onFlash,
      ));
    }

    if(widget.showDownload){
      widgetList.add(_buildFloatButtonItemWidget(
        title: '下载',
        svg: 'assets/svg/public/icon_download.svg',
        color: const Color(0xff4ADE80),
        index: widgetList.length,
        onTap: widget.onDownload,
      ));
    }


    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16.wMin,
      children: widgetList,
    );
  }

  Widget _buildFloatButtonItemWidget({
    required String title,
    required String svg,
    required Color color,
    required int index,
    void Function()? onTap,
  }) {
    return ListAnimationWidget(
      index: index,
      horizontalOffset: 70.wMin,
      delay: const Duration(milliseconds: 100),
      child: TapScaleWidget(
        sclae: 1.05,
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10.wMin,
              sigmaY: 10.wMin,
            ),
            child: Container(
              width: 128.wMin,
              height: 64.wMin,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: color.withValues(alpha: 0.2),
                border: Border.all(
                  color: color,
                  width: 3.wMin,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 4.wMin,
                children: [
                  SvgPicture.asset(
                    svg,
                    width: 32.wMin,
                    colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.cTextPrimary.color,
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}