import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/theme.dart';

enum UserWordOrderStatusEnum {
  /// 待填写
  no_submit("no_submit", "待填写", AppTheme.cSurfaceError),
  /// 待处理
  pending("pending", "已提交", AppTheme.cSurfaceSuccess),
  /// 需要修改
  revision_required("revision_required", "需要修改", AppTheme.cSurfaceWarning),
  /// 已完成
  completed("completed", "处理完成", AppTheme.cSurfaceSuccess);



  final String value;
  final String label;
  final Color color;

  const UserWordOrderStatusEnum(this.value, this.label, this.color);


  static UserWordOrderStatusEnum? fromValue(String value){
    return UserWordOrderStatusEnum.values.firstWhereOrNull((element) => element.value == value);
  }
}
