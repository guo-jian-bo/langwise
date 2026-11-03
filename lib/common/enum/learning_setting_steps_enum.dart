// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

enum LearningSettingStepsEnum {
  /// 填写个人信息
  MEMBER_INFO("MEMBER_INFO"),
  /// 开始评测
  ASSESSMENT("ASSESSMENT"),
  /// 继续评测
  CONTINUE_ASSESSMENT("CONTINUE_ASSESSMENT"),
  /// 等待 AI 规划
  AI_PLAN("AI_PLAN"),
  /// 设定学习计划
  EDIT_PLAN("EDIT_PLAN"),
  /// 开始学习
  START_LEARNING("START_LEARNING");

  const LearningSettingStepsEnum(this.value);

  final String value;

  static LearningSettingStepsEnum? fromValue(String? value) {
    if (value == null) return null;
    return LearningSettingStepsEnum.values.firstWhereOrNull((item) => item.value == value);
  }
}