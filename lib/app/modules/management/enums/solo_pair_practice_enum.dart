import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SoloPairPracticeEnum{
  forbidden('forbidden', "必须整组分叉出题", Color(0xffF59E0B)),

  allowed('allowed', "可分叉也可抽一条", Color(0xff22C55E));

  const SoloPairPracticeEnum(this.value, this.description, this.color);
  final String value;
  final String description;
  final Color color;

  static SoloPairPracticeEnum? fromValue(String? value){
    return SoloPairPracticeEnum.values.firstWhereOrNull((element) => element.value == value);
  }
}
