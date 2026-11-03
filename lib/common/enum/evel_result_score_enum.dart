import 'package:flutter/material.dart';
import 'package:langwise/theme/theme.dart';

class EvelResultScoreEnum{
  /// 混淆
  static const String confuse = '混淆';
  /// 漏读
  static const String miss = '漏读';
  /// 多读
  static const String extra = '多读';
  /// 正确
  static const String correct = '正确';


  static String getJudgmentStr(double? score, double passScore, int? readType){
    if(readType == 0 || readType == null){
      if(score == 0){
        return miss;
      }else if((score??0) < passScore){
        return confuse;
      }else{
        return correct;
      }
    }else if(readType == 3){
      return miss;
    }else if(readType == 4){
      return extra;
    }
    return confuse;
  }

  static Color getJudgmentColor(String evelResultScoreEnum){
    Color color = AppTheme.cTextPrimary.color;
    if(evelResultScoreEnum == EvelResultScoreEnum.correct){
      color = AppTheme.cFeedbackSuccessText.color;
    }else if(evelResultScoreEnum == EvelResultScoreEnum.miss){
      color = AppTheme.cFeedbackErrorText.color;
    }else if(evelResultScoreEnum == EvelResultScoreEnum.confuse || evelResultScoreEnum == EvelResultScoreEnum.extra){
      color = AppTheme.cFeedbackWarningText.color;
    } 
    return color;
  }

}