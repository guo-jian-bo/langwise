// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

enum SceneTypeEnum {
  start_frame("start_frame", "起始帧"),
  highlight_frame("highlight_frame", "高光帧"),
  end_frame("end_frame", "结束帧");

  const SceneTypeEnum(this.value, this.label);

  final String value;
  final String label;

  static SceneTypeEnum? fromValue(String? value) {
    return SceneTypeEnum.values.firstWhereOrNull((element) => element.value == value);
  }
}
