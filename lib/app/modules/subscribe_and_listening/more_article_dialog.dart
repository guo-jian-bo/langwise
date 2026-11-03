import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/subscribe.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';

class MoreArticleDialog {
  static Future<bool> show(BuildContext context, double sliderValue) async {
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return MoreArticleDialogWidget(num: sliderValue);
      },
    );
    return res ?? false;
  }
}

class MoreArticleDialogWidget extends StatefulWidget {
  const MoreArticleDialogWidget({super.key, required this.num});
  final double num;

  @override
  State<MoreArticleDialogWidget> createState() => _MoreArticleDialogWidgetState();
}

class _MoreArticleDialogWidgetState extends State<MoreArticleDialogWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground,
      child: Center(
        child: Container(
            width: 716.wMin,
            height: 552.wMin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.wMin),
              color: AppTheme.cSurfaceSecondary.color,
            ),
            child: Stack(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(height: 32.wMin),
                Padding(
                  padding: EdgeInsets.only(left: 32.wMin),
                  child: Text('推送新文章', style: TextStyle(fontSize: 32.wMin, color: AppTheme.cTextPrimary.color)),
                ),
                SizedBox(height: 24.wMin),
                Padding(
                  padding: EdgeInsets.only(left: 40.wMin),
                  child: _card(),
                ),
                SizedBox(height: 24.wMin),
                Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 40.wMin),
                    padding: EdgeInsets.all(12.wMin),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.wMin), color: AppTheme.cFeedbackInfoBackground.color, border: Border.all(color: AppTheme.cFeedbackInfoBorder.color)),
                    child: Row(children: [
                      SvgPicture.asset('assets/svg/manage/icon_info_circle.svg', width: 24.wMin, height: 24.wMin),
                      SizedBox(width: 8.wMin),
                      Text('推送不扣费，阅读时每篇100学点', style: TextStyle(fontSize: 18.wMin, color: AppTheme.cTextPrimary.color)),
                    ])),
                Spacer(),
                _bottomBtn(),
                SizedBox(height: 48.wMin)
              ]),
              Positioned(top: 10.wMin, right: 10.wMin, child: _backIcon()),
            ])),
      ),
    );
  }

  List<String> intro = ["这是额外推送，不受今日上限限制", "推送后可立即在任务列表中查看", "当前待推送内容池还有 12 篇可用"];

  Widget _card() {
    return Container(
      width: 636.wMin,
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceTertiary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
              TextSpan(children: [
                TextSpan(text: '将额外推送'),
                TextSpan(text: '${widget.num.ceil()}', style: TextStyle(fontSize: 28.wMin, color: AppTheme.cTextBrand.color)),
                TextSpan(text: '篇文章到任务列表'),
              ]),
              style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextPrimary.color)),
          SizedBox(height: 16.wMin),
          Text('说明:', style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextSecondary.color)),
          SizedBox(height: 8.wMin),
          Column(
              children: List.generate(intro.length, (e) {
            return Row(
              children: [
                Container(width: 8.wMin, height: 8.wMin, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.cTextTertiary.color)),
                SizedBox(width: 8.wMin),
                Text(intro[e], style: TextStyle(fontSize: 22.wMin, color: AppTheme.cTextTertiary.color)),
              ],
            );
          }))
        ],
      ),
    );
  }

  Widget _bottomBtn() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      GestureDetector(
        onTap: () {
          Get.back(result: false);
        },
        child: Container(
            width: 315.wMin,
            height: 72.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppTheme.cSurfaceQuaternary.color, borderRadius: BorderRadius.circular(12.wMin)),
            child: Text('取消', style: TextStyle(fontSize: 28.wMin, color: AppTheme.cTextPrimary.color))),
      ),
      SizedBox(width: 10.wMin),
      GestureDetector(
        onTap: () async {
          var res = await SubscribeRequest.userOnceMorePush(number: widget.num.ceil());
          if (res?.code == HttpStatus.ok) {
            Get.back(result: true);
          }
        },
        child: Container(
            width: 315.wMin,
            height: 72.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppTheme.cSurfaceInfo.color, borderRadius: BorderRadius.circular(12.wMin)),
            child: Text('确认推送', style: TextStyle(fontSize: 28.wMin, color: AppTheme.cInverseTextLight.color))),
      )
    ]);
  }

  Widget _backIcon() {
    return TapScaleWidget(
      sclae: 1.05,
      onTap: () => Get.back(),
      child: Container(
        width: 42.wMin,
        height: 42.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.cSurfaceTertiary.color,
        ),
        child: SvgPicture.asset(
          "assets/svg/public/x.svg",
          width: 24.wMin,
          height: 24.wMin,
        ),
      ),
    );
  }
}
