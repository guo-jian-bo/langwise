import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../theme/theme.dart';

enum TicketRecordStatusEnum {
  pending("pending", "待处理", AppTheme.cSurfaceError),
  completed("completed", "已完成", AppTheme.cSurfaceSuccess),
  revision_required("revision_required", "需修改", AppTheme.cSurfaceWarning),
  no_submit("no_submit", "未提交", AppTheme.cSurfaceWarning),
  ;

  final String value;
  final String text;
  final Color color;

  const TicketRecordStatusEnum(this.value, this.text, this.color);


  static TicketRecordStatusEnum? fromValue(String? value){
    return TicketRecordStatusEnum.values.firstWhereOrNull((element) => element.value == value);
  }

}