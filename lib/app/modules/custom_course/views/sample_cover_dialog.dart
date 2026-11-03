import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class SampleCoverDialog {
  static Future<void> show({
    required BuildContext context,
  }) async {
    return await showCupertinoDialog(
      context: context,
      builder: (context) => SampleCoverDialogWidget(),
    );
  }
}

class SampleCoverDialogWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 1006.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.wMin),
            color: AppTheme.cSurfacePrimary,
            border: Border.all(color: AppTheme.cBorderPrimary),
          ),
          child: Stack(children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                Text('拍摄要求',style: TextStyle(fontSize: 32.wMin,color: AppTheme.cTextPrimary,fontWeight: FontWeight.w600),),
                SizedBox(height: 24.wMin),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Image.asset('assets/images/custom_course/sample_cover.png',width: 450.wMin,fit: BoxFit.fitWidth),
                        SizedBox(height: 12.wMin),
                        Text('封面样图',style: TextStyle(fontSize: 22.wMin,color: AppTheme.cTextSecondary,fontWeight: FontWeight.w400),),
                      ],
                    ),
                    SizedBox(width: 24.wMin),
                    Column(
                      children: [
                        Image.asset('assets/images/custom_course/sample_backcover.png',width: 450.wMin,fit: BoxFit.fitWidth),
                        SizedBox(height: 12.wMin),
                        Text('封底样图',style: TextStyle(fontSize: 22.wMin,color: AppTheme.cTextSecondary,fontWeight: FontWeight.w400),),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24.wMin),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfaceSecondary,
                    borderRadius: BorderRadius.circular(12.wMin),
                  ),
                  padding: EdgeInsets.all(24.wMin),
                  margin: EdgeInsets.symmetric(horizontal: 40.wMin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8.wMin,
                    children: [
                      Text('拍摄要求',style: TextStyle(fontSize: 24.wMin,color: AppTheme.cTextPrimary,fontWeight: FontWeight.w600),),
                      Row(
                        children: [
                          pointTxtWidget('拍摄教材的封面封底，'),
                          Text('整页，',style: TextStyle(fontSize: 22.wMin,color: AppTheme.cTextBrand,fontWeight: FontWeight.w400),),
                          Text('不要有遮挡',style: TextStyle(fontSize: 22.wMin,color: AppTheme.cTextSecondary,fontWeight: FontWeight.w400),),
                        ],
                      ),
                      pointTxtWidget('光线充足，避免反光'),
                      pointTxtWidget('画面平稳，文字清晰可见'),
                      Row(
                        children: [
                          pointTxtWidget('封底下方的'),
                          Text('ISBN码需清晰无反光',style: TextStyle(fontSize: 22.wMin,color: AppTheme.cTextBrand,fontWeight: FontWeight.w400),),
                        ],
                      ),
                    ],
                  )),
                  SizedBox(height: 40.wMin)
              ]),
            ),
            Positioned(
              top: 10.wMin,
              right: 10.wMin,
              child: GestureDetector(
                onTap: () {
                  Get.back();
                },child: SvgPicture.asset('assets/svg/public/x.svg',width: 32.wMin,height: 32.wMin),
                ),
            )
          ])
        )));
  }

  Widget pointTxtWidget(String txt){
    return Row(children: [
      Container(decoration: const BoxDecoration(
        color: AppTheme.cSurfaceInfo,
        shape: BoxShape.circle
      ),width: 8.wMin,height: 8.wMin),
      SizedBox(width: 8.wMin),
      Text(txt,style: TextStyle(fontSize: 22.wMin,color: AppTheme.cTextSecondary,fontWeight: FontWeight.w400),),
    ]);
  }
}