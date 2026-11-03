// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 工作人员操作台风险等级筛选枚举。
///
/// - [value]：接口 `riskLevels` 使用的枚举值。
/// - [name]：筛选组件展示文案。
/// - [label]：完整标签文案，便于和原型及协议字段对照。
enum ManageEmployeeConsoleRiskLevelEnum {

  /// 风险: 红色警觉
  RED(value: "red", name: "红色警觉", color: Color(0xffEF4444)),

  /// 风险: 橙色跟进
  ORANGE(value: "orange", name: "橙色跟进", color: Color(0xffF97316)),

  /// 风险: 黄色关注
  YELLOW(value: "yellow", name: "黄色关注", color: Color(0xffEAB308)),

  /// 风险: 绿色稳定
  GREEN(value: "green", name: "绿色稳定", color: Color(0xff22C55E));


  final String value;
  final String name;
  final Color color;

  const ManageEmployeeConsoleRiskLevelEnum({
    required this.value,
    required this.name,
    required this.color,
  });

  static ManageEmployeeConsoleRiskLevelEnum? fromValue(String? value){
    return values.firstWhereOrNull((element) => element.value == value);
  }

}
