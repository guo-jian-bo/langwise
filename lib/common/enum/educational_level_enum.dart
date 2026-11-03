
// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/theme.dart';

enum EducationalLevelEnum {

  GENERAL("GENERAL", "常用", AppTheme.cSurfaceSuccess),
  UNCOMMON("UNCOMMON", "罕见，扩展", AppTheme.cSurfaceWarning),
  SENSITIVE("SENSITIVE", "不合符规范", AppTheme.cSurfaceError);

  const EducationalLevelEnum(this.value, this.name, this.color);

  final String value;
  final String name;
  final Color color;

  static EducationalLevelEnum? fromRawValue(String? value) {
    EducationalLevelEnum? res = values.firstWhereOrNull(
      (element) => element.value == value,
    );
    return res;

  }

}