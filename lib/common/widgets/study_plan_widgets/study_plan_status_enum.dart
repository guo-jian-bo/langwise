
// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

enum StudyPlanStatusEnum {
  /// 表示资源已就绪，随时可以触发学习 可执行
  READY("READY"),
  /// 表示已进入队列，正在排队等待 等待中
  PENDING("PENDING"),
  /// 表示任务当前活跃 进行中
  RUNNING("RUNNING"),
  /// 表示已执行完成 已完成
  EXECUTED("EXECUTED");

  const StudyPlanStatusEnum(this.value);
  final String value;

  static StudyPlanStatusEnum? fromValue(String? value) {
    if (value == null) {
      return null;
    }
    return StudyPlanStatusEnum.values.firstWhereOrNull((element) => element.value == value);
  }
}


enum StudyCourseStatusEnum {
  /// 进行中
  RUNNING,
  /// 已完成
  EXECUTED,
  /// 未开始
  PENDING,
  /// 待解锁
  UNLOCKED,
  /// 已暂停
  PAUSED,
}