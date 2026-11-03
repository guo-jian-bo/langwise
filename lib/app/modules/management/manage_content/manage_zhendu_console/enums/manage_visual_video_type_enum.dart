
// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 视觉项目视频类型
enum ManageVisualVideoTypeEnum{
  between_scenes("between_scenes", "过渡", Color(0xff0092b8)),
  scene("scene", "场景", Color(0xffc800de));

  final String value;
  final String label;
  final Color color;

  const ManageVisualVideoTypeEnum(this.value, this.label, this.color);

  static ManageVisualVideoTypeEnum? fromValue(String? value){
    return ManageVisualVideoTypeEnum.values.firstWhereOrNull((element) => element.value == value);
  }
}