// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../theme/theme.dart';

enum ManageVisualImageStatusEnum{
  image_checking("image_checking", "待审核", AppTheme.cSurfaceWarning, AppTheme.cInverseTextLight),
  image_checked("image_checked", "已审核", AppTheme.cSurfaceSuccess, AppTheme.cInverseTextLight),
  finished("finished", "待审核", AppTheme.cSurfaceWarning, AppTheme.cInverseTextLight),
  checked("checked", "已审核", AppTheme.cSurfaceSuccess, AppTheme.cInverseTextLight);

  final String value;
  final String name;
  final Color bg;
  final Color font;

  const ManageVisualImageStatusEnum(this.value, this.name, this.bg, this.font);

  static ManageVisualImageStatusEnum? fromValue(String? value) {
    if (value == null) return null;
    return ManageVisualImageStatusEnum.values.firstWhereOrNull((e) => e.value == value);
  }
}