import 'package:flutter/material.dart';

/// 批改稿纸和顶部说明共用的颜色口径。
class ReviewBoardStyleHelper {
  /// 批注模式错误线颜色，对齐 Web `ERROR_LINE`。
  static const Color annotationErrorColor = Color(0xffDC2626);

  /// 批注模式建议线颜色，对齐 Web `SUGGEST_LINE`。
  static const Color annotationSuggestionColor = Color(0xffD97706);

  /// 批注模式亮点背景色，对齐 Web `HIGHLIGHT_BG`。
  static const Color annotationHighlightBackgroundColor = Color(0xffA7F3D0);

  /// 稿纸选中态描边色，对齐 Web `ACTIVE`。
  static const Color activeBorderColor = Color(0xffB45309);

  /// 订正模式删除文本色，对齐 Web `DEL`。
  static const Color correctDeleteTextColor = Color(0xffE11D48);

  /// 订正模式删除线颜色，对齐 Web `DEL`。
  static const Color correctDeleteDecorationColor = Color(0xffF43F5E);

  /// 订正模式补写文本色，对齐 Web `INS`。
  static const Color correctInsertTextColor = Color(0xff047857);

  /// 订正模式补写背景色，对齐 Web `INS`。
  static const Color correctInsertBackgroundColor = Color(0xffD1FAE5);

  /// 升格模式新增文本色，对齐 Web `IMPROVED_INS`。
  static const Color upgradeInsertTextColor = Color(0xff065F46);

  /// 升格模式新增背景色，对齐 Web `IMPROVED_INS`。
  static const Color upgradeInsertBackgroundColor = Color(0xffD1FAE5);

  /// 升格模式删除文本色，对齐 Web `IMPROVED_DEL`。
  static const Color upgradeDeleteTextColor = Color(0xff94A3B8);

  /// 升格模式删除线颜色，对齐 Web `IMPROVED_DEL`。
  static const Color upgradeDeleteDecorationColor = Color(0xff94A3B8);
}
