
import 'package:get/get.dart';

enum BeatNidEnum{
  opening("opening", "起"),
  develop("develop", "承"),
  turn("turn", "转"),
  close("close", "合");

  final String value;
  final String text;

  const BeatNidEnum(this.value, this.text);

  static BeatNidEnum fromValue(String? value) {
    if(value == null) return opening;
    return values.firstWhereOrNull((element) => element.value == value)??opening;
  }
}