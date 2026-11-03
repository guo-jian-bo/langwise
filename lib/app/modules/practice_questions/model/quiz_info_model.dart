

import 'package:flutter/material.dart';
import 'package:quiz_play/models/models.dart';
import 'package:quiz_play/models/quiz_operation_steps_model.dart';

class QuizDataInfoModel{
  QuizModel data;
  QuizLogModel? log;
  int? errorCount;
  GlobalKey key;


  QuizDataInfoModel({
    required this.data,
    this.log,
    required this.key,
    this.errorCount,
  });
}