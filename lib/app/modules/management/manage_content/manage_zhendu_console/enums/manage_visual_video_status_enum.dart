// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';

/// 视觉项目视频类型
enum ManageVisualVideoStatusEnum{
  video_generating("video_generating", "生成中", AppTheme.cSurfaceBrand),
  finished("finished", "待审核", AppTheme.cSurfaceWarning),
  checking("checking", "待审核", AppTheme.cSurfaceWarning),
  checked("checked", "已审核", AppTheme.cSurfaceSuccess),
  failed("failed", "失败", AppTheme.cSurfaceError);

  final String value;
  final String label;
  final Color color;

  const ManageVisualVideoStatusEnum(this.value, this.label, this.color);

  static ManageVisualVideoStatusEnum? fromValue(String? value){
    return ManageVisualVideoStatusEnum.values.firstWhereOrNull((element) => element.value == value);
  }
}