import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/common.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/values/values.dart';

class AskingForTasksDialog{

  static Future<int?> show({
    required BuildContext context,
  }) async{
    
    return showCupertinoDialog<int?>(
      context: context, 
      builder: (context) {
        return const AskingForTasksDialogWidget();
      },
    );

  }

}

class AskingForTasksDialogWidget extends StatefulWidget {
  const AskingForTasksDialogWidget({super.key});

  @override
  State<AskingForTasksDialogWidget> createState() => _AskingForTasksDialogWidgetState();
}

class _AskingForTasksDialogWidgetState extends State<AskingForTasksDialogWidget> {

  bool isChecked = true;

  Future<void> setNotRemindCourse() async{
    if(!isChecked) return;

    DateTime now = DateTime.now().toLocal();
    await StorageUtil().setString(NOT_REMIND_COURSE_KEY, "${now.year}${now.month}${now.day}");
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground,
      child: Center(
        child: Container(
          width: 841.wMin,
          padding: EdgeInsets.all(32.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.wMin),
            color: AppTheme.cSurfaceSecondary,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Text(
                "已为您规划好今天的学习之旅",
                style: TextStyle(
                  color: AppTheme.cTextPrimary,
                  fontSize: 32.wMin,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 24.wMin),
              Text(
                "建议跟随计划学习，\n以确保所有内容都能进入后续的自动复习环节哦。",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.cTextPrimary,
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 24.wMin),

              Row(
                children: [
                  Expanded(
                    child: TapScaleWidget(
                      onTap: () {
                        setNotRemindCourse();
                        Get.back(result: 0);
                      },
                      sclae: 1.01,
                      child: Container(
                        height: 242.wMin,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(18.wMin),
                          border: Border.all(width: 2.wMin, color: AppTheme.cSurfaceTertiary),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 72.wMin,
                              height: 72.wMin,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.wMin),
                                color: AppTheme.cSurfaceTertiary,
                              ),
                              child: SvgPicture.asset(
                                "assets/svg/official_course_details/icon_compass.svg",
                                width: 56.wMin,
                                height: 56.wMin,
                              ),
                            ),
                            SizedBox(height: 12.wMin),
                            Text(
                              "我先逛逛看看",
                              style: TextStyle(
                                color: AppTheme.cTextPrimary,
                                fontSize: 28.wMin,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 24.wMin),
                  Expanded(
                    child: TapScaleWidget(
                      onTap: () {
                        setNotRemindCourse();
                        Get.back(result: 1);
                      },
                      sclae: 1.01,
                      child: Container(
                        height: 242.wMin,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(18.wMin),
                          border: Border.all(width: 2.wMin, color: AppTheme.cFeedbackWarningBorder),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 72.wMin,
                              height: 72.wMin,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.wMin),
                                color: AppTheme.cFeedbackWarningBackground,
                              ),
                              child: SvgPicture.asset(
                                "assets/svg/official_course_details/icon_target.svg",
                                width: 56.wMin,
                                height: 56.wMin,
                              ),
                            ),
                            SizedBox(height: 12.wMin),
                            Text(
                              "继续我的计划",
                              style: TextStyle(
                                color: AppTheme.cFeedbackWarningText,
                                fontSize: 28.wMin,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.wMin),
              Container(
                alignment: Alignment.centerLeft,
                child: TapScaleWidget(
                  onTap: () {
                    isChecked = !isChecked;
                    if(mounted) setState(() {});
                  },
                  sclae: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        isChecked ? "assets/svg/public/icon_check_box.svg" : "assets/svg/public/icon_uncheck_box.svg",
                        width: 24.wMin,
                        height: 24.wMin,
                      ),
                      SizedBox(width: 8.wMin),
                      Text(
                        "今日不再提醒",
                        style: TextStyle(
                          color: AppTheme.cTextSecondary,
                          fontSize: 20.wMin,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }




}