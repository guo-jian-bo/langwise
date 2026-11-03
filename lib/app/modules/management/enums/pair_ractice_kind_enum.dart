import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum PairRacticeKindEnum{
  polarity("polarity", "肯否对照", Color(0xffEAB308)),
  packaging("packaging", "换种答法", Color(0xff14B8A6));

  const PairRacticeKindEnum(this.value, this.description, this.color);
  final String value;
  final String description;
  final Color color;

  static PairRacticeKindEnum? fromValue(String? value){
    return PairRacticeKindEnum.values.firstWhereOrNull((element) => element.value == value);
  }
}