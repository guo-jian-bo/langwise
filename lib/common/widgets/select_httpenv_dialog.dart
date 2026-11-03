import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/common.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../values/values.dart';
import 'widgets.dart';

class SelectHttpenvDialog{
  static Future<String?> show({
    required BuildContext context,
  }) async{
    return await showCupertinoDialog<String?>(
      context: context,
      builder: (context) {
        return const SelectHttpenvDialogWidget();
      },
    );
  }
}

class SelectHttpenvDialogWidget extends StatefulWidget {
  const SelectHttpenvDialogWidget({super.key});

  @override
  State<SelectHttpenvDialogWidget> createState() => _SelectHttpenvDialogWidgetState();
}

class _SelectHttpenvDialogWidgetState extends State<SelectHttpenvDialogWidget> {

  final List<String> httpEnvList = [
    HttpEnvKey.pro,
    HttpEnvKey.beta,
    HttpEnvKey.dev,
  ];
  int selectIndex = 0;

  String buildType = "";

  @override
  void initState() {
    super.initState();
    buildType = StorageUtil().getString(STORAGE_HTTP_ENV_KEY);
    for(int i = 0; i < httpEnvList.length; i++){
      if(httpEnvList[i] == buildType){
        selectIndex = i;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground,
      child: Center(
        child: Container(
          width: 640.wMin,
          padding: EdgeInsets.all(40.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cBgSecondary,
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "选择环境",
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.wMin),
              Column(
                children: List.generate(httpEnvList.length, (index){
                  return TapScaleWidget(
                    onTap: () {
                      setState(() {
                        selectIndex = index;
                      });
                    },
                    sclae: 1.01,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.wMin),
                        color: selectIndex == index ? AppTheme.cBgTertiary : Colors.transparent,
                      ),
                      child: Text(
                        httpEnvList[index],
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 32.wMin),
              Row(
                spacing: 18.wMin,
                children: [
                  Expanded(
                    child: ButtonWidget(
                      text: "取消",
                      sclae: 1.03,
                      color: AppTheme.cBgTertiary,
                      borderRadius: 8.wMin,
                      height: 56.wMin,
                      fontSize: 24.wMin,
                      fontColor: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w500,
                      onTap: () => Get.back(),
                    ),
                  ),
                  Expanded(
                    child: ButtonWidget(
                      text: "确定",
                      sclae: 1.03,
                      color: buildType == httpEnvList[selectIndex] ? AppTheme.cBgQuaternary : AppTheme.cSurfaceBrand,
                      borderRadius: 8.wMin,
                      height: 56.wMin,
                      fontSize: 24.wMin,
                      fontColor: buildType == httpEnvList[selectIndex] ? AppTheme.cTextPrimary : AppTheme.cStaticWhite,
                      fontWeight: FontWeight.w500,
                      onTap: buildType == httpEnvList[selectIndex] ? null : () {
                        Get.back(result: httpEnvList[selectIndex]);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}