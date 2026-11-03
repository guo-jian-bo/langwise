import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum GridKindEnum {
  time_aspect("time_aspect", "时×体", Color(0xffF59E0B)),
  polarity_question_mode("polarity_question_mode", "极性×问句", Color(0xff00BC7D)),
  voice_time("voice_time", "语态×时", Color(0xffEC4899)),
  time_polarity("time_polarity", "时×极性", Color(0xff3B82F6));

  const GridKindEnum(this.value, this.name, this.color);

  final String value;
  final String name;
  final Color color;

  static GridKindEnum? fromValue(String? value) {
    return GridKindEnum.values.firstWhereOrNull((element) => element.value == value);
  }
}
