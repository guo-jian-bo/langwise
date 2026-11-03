import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../theme/theme.dart';


class PracticeQuestionsPauseDialog{
  static Future<void> show({
    void Function()? onStart,
    void Function()? onStop,
  }) async{
    if(Get.context == null) return;
    return await showCupertinoDialog(
      context: Get.context!, 
      builder: (context) {
        return PracticeQuestionsPauseDialogWidget(
          onStart: onStart,
          onStop: onStop,
        );
      },
    );
  }
}

class PracticeQuestionsPauseDialogWidget extends StatelessWidget {
  final void Function()? onStart;
  final void Function()? onStop;
  const PracticeQuestionsPauseDialogWidget({super.key, this.onStart, this.onStop});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground,
      child: Center(
        child: Container(
          width: 720.wMin,
          height: 760.wMin,
          margin: EdgeInsets.all(1.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.wMin),
            color: AppTheme.cBgSecondary,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: SizedBox(
                  width: 200.wMin,
                  height: 200.wMin,
                  child: SvgPicture.asset(
                    "assets/svg/practice_questions/icon_pause.svg",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16.wMin),
              Text(
                "计时已暂停",
                style: TextStyle(
                  fontSize: 36.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 80.wMin),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      TapScaleWidget(
                        onTap: onStop,
                        sclae: 1.1,
                        child: ClipOval(
                          child: SizedBox(
                            width: 89.wMin,
                            height: 89.wMin,
                            child: SvgPicture.asset(
                              "assets/svg/practice_questions/icon_stop.svg",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 7.4.wMin),
                      Text(
                        "停止",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      TapScaleWidget(
                        onTap: onStart,
                        sclae: 1.1,
                        child: ClipOval(
                          child: SizedBox(
                            width: 89.wMin,
                            height: 89.wMin,
                            child: SvgPicture.asset(
                              "assets/svg/practice_questions/icon_play.svg",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 7.4.wMin),
                      Text(
                        "继续",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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