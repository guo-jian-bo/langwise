
import 'package:flutter/material.dart';

import 'knowledge_type_enum.dart';

enum CourseUnitTargetEnum {
  /// 总览
  overview(
    rawValue: 'overview',
    title: '总览',
    primaryColor: Color(0xff22D3EE),
    primaryColor1: Color(0xff14B8A6),
    knowledgeTypes: [],
  ),

  /// 词汇
  vocabulary(
    rawValue: 'vocabulary',
    title: '词汇',
    primaryColor: Color(0xff0EA5E9),
    primaryColor1: Color(0xff2DD4BF),
    knowledgeTypes: [KnowledgeTypeEnum.EN_WORD, KnowledgeTypeEnum.EN_PHRASE],
  ),

  /// 句法
  syntax(
    rawValue: 'syntax',
    title: '句法',
    primaryColor: Color(0xffFBBF24),
    primaryColor1: Color(0xffF97316),
    knowledgeTypes: [KnowledgeTypeEnum.EN_SENTENCE],
  ),

  /// 听力
  listening(
    rawValue: 'listening',
    title: '听力',
    primaryColor: Color(0xff0EA5E9),
    primaryColor1: Color(0xffE879F9),
    knowledgeTypes: [KnowledgeTypeEnum.EN_SONG],
  ),

  /// 阅读
  reading(
    rawValue: 'reading',
    title: '阅读',
    primaryColor: Color(0xff4ADE80),
    primaryColor1: Color(0xff00D492),
    knowledgeTypes: [KnowledgeTypeEnum.EN_TEXT, KnowledgeTypeEnum.EN_REVEAL],
  ),

  /// 写作
  writing(
    rawValue: 'writing',
    title: '写作',
    primaryColor: Color(0xffF472B6),
    primaryColor1: Color(0xffF43F5E),
    knowledgeTypes: [KnowledgeTypeEnum.EN_COMPOSITION],
  ),

  /// 综合
  comprehensive(
    rawValue: 'comprehensive',
    title: '综合',
    primaryColor: Color(0xff6366F1),
    primaryColor1: Color(0xff06B6D4),
    knowledgeTypes: [KnowledgeTypeEnum.SCRIPT],
  );

  final String rawValue;
  final String title;
  final Color primaryColor;
  final Color primaryColor1;
  final List<KnowledgeTypeEnum> knowledgeTypes;

  const CourseUnitTargetEnum({
    required this.rawValue,
    required this.title,
    required this.primaryColor,
    required this.primaryColor1,
    required this.knowledgeTypes,
  });

  /// 兼容页面枚举值和旧知识点类型值的解析。
  static CourseUnitTargetEnum? fromRawValue(String rawValue) {
    for (final item in CourseUnitTargetEnum.values) {
      if (item.rawValue == rawValue) return item;
    }
    return fromKnowledgeType(KnowledgeTypeEnum.fromRawValue(rawValue));
  }

  /// 将知识点类型映射为课程目标页分类。
  static CourseUnitTargetEnum? fromKnowledgeType(KnowledgeTypeEnum? type) {
    if (type == null) return null;
    for (final item in CourseUnitTargetEnum.values) {
      if (item.knowledgeTypes.contains(type)) return item;
    }
    return null;
  }
}
