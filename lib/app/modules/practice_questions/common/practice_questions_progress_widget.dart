

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../model/quiz_info_model.dart';


class PracticeQuestionsProgressWidget extends StatelessWidget {
  final RxList<QuizDataInfoModel> questionDataList;
  /// 做题进度
  const PracticeQuestionsProgressWidget({
    super.key, 
    required this.questionDataList, 
  });

  @override
  Widget build(BuildContext context) {
    int length = questionDataList.length;

    int completedCount = questionDataList.where((element) => element.data.result != null).length;

    double value = (completedCount) / length * 100;

    return IgnorePointer(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          SizedBox(
            width: 240.wMin,
            height: 8.wMin,
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: AppTheme.cTextPrimary.color.withValues(alpha: 0.1),
              color: AppTheme.cTextPrimary.color,
              borderRadius: BorderRadius.circular(999),
              minHeight: 8.wMin,
              valueColor: AlwaysStoppedAnimation(AppTheme.cTextPrimary.color),
            ),
          ),
      
          SizedBox(width: 8.wMin),
      
          Text(
            "${value.round()}%",
            style: TextStyle(
              fontSize: 22.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
      
      
        ],
      ),
    );
  }
}