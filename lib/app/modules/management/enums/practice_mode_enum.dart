import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum PracticeModeEnum {
  solo("solo", "只能配对", Color(0xff22C55E)),
  fork("fork", "必须走分叉", Color(0xffF43F5E)),
  both("both", "可配对也可分叉", Color(0xffF59E0B));

  const PracticeModeEnum(this.value, this.description, this.color);

  final String value;
  final String description;
  final Color color;

  static PracticeModeEnum? fromValue(String? value){
    return PracticeModeEnum.values.firstWhereOrNull((element) => element.value == value);
  }
}
