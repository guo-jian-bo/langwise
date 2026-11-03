// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

enum TaskTypeEnum {

  INSTANT("INSTANT", "即时任务"),
  ACCUMULATION("ACCUMULATION", "累计任务"),
  STEP("STEP", "步骤任务");   

  final String value;
  final String name;

  const TaskTypeEnum(this.value, this.name);

  factory TaskTypeEnum.fromValue(String? value) {
    return TaskTypeEnum.values.firstWhereOrNull((e) => e.value == value) ?? TaskTypeEnum.INSTANT;
  }

}