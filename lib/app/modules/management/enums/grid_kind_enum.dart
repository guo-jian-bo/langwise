import 'package:get/get.dart';

enum GridKindEnum {
  time_aspect("time_aspect", "时×体"),
  polarity_question_mode("polarity_question_mode", "极性×问句"),
  voice_time("voice_time", "语态×时"),
  time_polarity("time_polarity", "时×极性");

  const GridKindEnum(this.value, this.name);

  final String value;
  final String name;

  static GridKindEnum? fromValue(String? value) {
    return GridKindEnum.values.firstWhereOrNull((element) => element.value == value);
  }
}
