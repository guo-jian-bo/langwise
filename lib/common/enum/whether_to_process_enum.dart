import 'dart:ui';

import '../../theme/theme.dart';

enum WhetherToProcessEnum{

  /// 已经处理
  processed(true, "已处理", AppTheme.cSurfaceSuccess),

  /// 未处理
  unprocessed(false, "未处理", AppTheme.cSurfaceError);

  final bool value;
  final String label;
  final Color color;

  const WhetherToProcessEnum(this.value, this.label, this.color);

    factory WhetherToProcessEnum.fromRawValue(bool value) {

    return values.firstWhere(
      (element) => element.value == value,
      orElse: () => unprocessed,
    );
  }

}