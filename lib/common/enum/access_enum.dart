// ignore_for_file: constant_identifier_names

import 'dart:ui';

import '../../theme/theme.dart';

enum AccessEnum{

  NORMAL("NORMAL", "上架", AppTheme.cSurfaceSuccess),
  INTERNAL("INTERNAL", "下架", AppTheme.cSurfaceError),
  DELETED("DELETED", "删除", AppTheme.cSurfaceError),
  NORDELETEMAL("DELETE", "删除", AppTheme.cSurfaceError);

  final String value;
  final String label;
  final Color color;

  const AccessEnum(this.value, this.label, this.color);

  factory AccessEnum.fromRawValue(String value) {

    return values.firstWhere(
      (element) => element.value == value,
      orElse: () => INTERNAL,
    );
  }

}
