import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// 图片筛选选项实体类
///
/// 用于存储图片的风格、地区等筛选信息
class ImageFilterOption {
  /// 唯一标识符
  final String uniqueId;

  /// UI关联的全局键
  final GlobalKey globalKey;

  /// 风格代码
  final String? style;

  /// 风格名称
  final String? styleTitle;

  /// 地区代码
  final String? locale;

  /// 地区名称
  final String? localeTitle;

  /// 唯一ID
  final int uid;

  /// 构造函数
  ImageFilterOption({
    String? uniqueId,
    required this.uid,
    this.style,
    this.styleTitle,
    this.locale,
    this.localeTitle,
  })  : uniqueId = uniqueId ?? _generateUniqueId(),
        globalKey = GlobalKey(debugLabel: uid.toString());

  /// 从JSON创建实例
  factory ImageFilterOption.fromJson(Map<String, dynamic> json) {
    return ImageFilterOption(
      uid: json['uid'] ?? 0,
      style: json['style'],
      styleTitle: json['styleTitle'],
      locale: json['locale'],
      localeTitle: json['localeTitle'],
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'uniqueId': uniqueId,
      'style': style,
      'styleTitle': styleTitle,
      'locale': locale,
      'localeTitle': localeTitle,
    };
  }

  /// 创建副本并更新属性
  ImageFilterOption copyWith({
    int? uid,
    String? style,
    String? styleTitle,
    String? locale,
    String? localeTitle,
  }) {
    return ImageFilterOption(
      uid: uid ?? this.uid,
      uniqueId: uniqueId,
      style: style ?? this.style,
      styleTitle: styleTitle ?? this.styleTitle,
      locale: locale ?? this.locale,
      localeTitle: localeTitle ?? this.localeTitle,
    );
  }

  /// 判断是否有风格信息
  bool get hasStyle => style != null && styleTitle != null;

  /// 判断是否有地区信息
  bool get hasLocale => locale != null && localeTitle != null;

  /// 唯一ID生成策略
  static String _generateUniqueId() {
    return const Uuid().v6();
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ImageFilterOption && other.uid == uid;
  }

  @override
  int get hashCode => Object.hash(runtimeType, uid);

  /// 字符串表示
  ///
  /// 返回包含关键筛选信息的字符串描述
  @override
  String toString() {
    return 'ImageFilterOption(uid: $uid, locale: $locale, localeTitle: $localeTitle, style: $style, styleTitle: $styleTitle)';
  }
}
