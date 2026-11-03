import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SoloPairPracticeEnum{
  forbidden('forbidden', "几种接法要一起看", Color(0xffF59E0B)),

  allowed('allowed', "也可以只练其中一条", Color(0xff22C55E));

  const SoloPairPracticeEnum(this.value, this.description, this.color);
  final String value;
  final String description;
  final Color color;

  static SoloPairPracticeEnum? fromValue(String? value){
    return SoloPairPracticeEnum.values.firstWhereOrNull((element) => element.value == value);
  }
}
