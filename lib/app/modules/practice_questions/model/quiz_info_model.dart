import 'package:flutter/material.dart';
import 'package:quiz_play/models/models.dart';
import 'package:quiz_play/models/quiz_operation_steps_model.dart';

class QuizDataInfoModel {
  QuizModel data;
  QuizLogModel? log;
  int? errorCount;
  GlobalKey key;

  /// 当前题目本轮开始时间
  DateTime? quizStartTime;

  /// 当前题目本轮结束时间/上报前快照时间
  DateTime? quizEndTime;

  /// 当前题目本轮累计暂停时长（秒）
  int pauseDurationSecond;

  QuizDataInfoModel({
    required this.data,
    this.log,
    required this.key,
    this.errorCount,
    this.quizStartTime,
    this.quizEndTime,
    this.pauseDurationSecond = 0,
  });
}
