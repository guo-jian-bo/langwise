import 'package:get/get.dart';

enum PairOrderConstraintEnum {
  from_before_to("from_before_to", "先左后右"),
  to_before_from("to_before_from", "先右后左");
  
  final String value;
  final String label;

  const PairOrderConstraintEnum(this.value, this.label);

  static PairOrderConstraintEnum? fromValue(String? value) {
    return PairOrderConstraintEnum.values.firstWhereOrNull((element) => element.value == value);
  }
}
