

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import '../controllers/user_evaluation_level_controller.dart';

class UserEvaluationLevelOverallWidget extends GetView<UserEvaluationLevelController> {
  /// 总体评价
  const UserEvaluationLevelOverallWidget({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Container(
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cBgSecondary.color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(40.wMin),
      ),
      child: Column(
        children: [
          const EvaluationTitleWidget(title: "本次评测得分"),

          Obx((){
            return Text.rich(TextSpan(
              style: TextStyle(
                fontSize: 100.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cFeedbackWarningText.color,
                height: 1.25,
              ),
              children: [
                TextSpan(text: controller.resultDetail.value.overall?.toString()??""),
                TextSpan(
                  text: "分",
                  style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cFeedbackWarningText.color,
                  ),
                ),
              ],
            ));
          }),
          
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 32.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.wMin),
              color: AppTheme.cBgQuaternary.color,
            ),
            child: Obx((){
              LanguageText? tierComment = LearningLangUtils.getLocalLang(controller.resultDetail.value.tierComment);
          
              return Text(
                tierComment?.text??"",
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}