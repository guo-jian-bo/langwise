import 'package:flutter/material.dart';

enum CourseConditionType {
  // 完整上架
  allPut('FULL_PUBLISH', "完整上架", Color(0xff44AF5C)),
  // 部分上架
  partPut('PARTIAL_PUBLISH', "部分上架", Color(0xffFF781F)),
  // 已下架
  out('UNPUBLISH', "已下架", Color(0xff465070));

  final String value;
  final String title;
  final Color color;

  const CourseConditionType(this.value, this.title, this.color);

  // 工厂方法
  factory CourseConditionType.fromTitle(String value) {
    return CourseConditionType.values.firstWhere(
      (type) => type.value == value,
      // 默认值
      orElse: () => CourseConditionType.allPut,
    );
  }
}

extension CourseConditionTypeExtension on CourseConditionType {
  bool get isAllPut => this == CourseConditionType.allPut;

  bool get isPartPut => this == CourseConditionType.partPut;

  bool get isOut => this == CourseConditionType.out;
}
