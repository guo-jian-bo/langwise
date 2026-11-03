
import 'dart:ui';

import 'package:get/get.dart';

enum KindEnum{
  theme("theme", Color(0xff2563EB)),
  grammar("grammar", Color(0xff7C3AED)),
  vocabulary("vocabulary", Color(0xff00BC7D)),
  expression("expression", Color(0xffF97316));

  const KindEnum(this.value, this.color);
  final String value;
  final Color color;

  static KindEnum? fromValue(String? value){
    return KindEnum.values.firstWhereOrNull((element) => element.value == value);
  }
}