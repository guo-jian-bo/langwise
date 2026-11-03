import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/data_table_widget/data_table.dart';

class SentencePatternEntity<T> extends Dessert with JsonSerializableMixin {
  final String? name;
  final String? pattern;
  final List<T>? components;
  final String? access;
  final String? updated;
  final String? created;

  SentencePatternEntity({
    this.name,
    this.pattern,
    this.components,
    this.access,
    this.created,
    this.updated,
    required int uid,
  }) : super(uid: uid);

  factory SentencePatternEntity.fromJson(
    Map<String, dynamic> json, {
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    List<T>? components;
    if (json['components'] != null) {
      if (fromJson != null) {
        components = (json['components'] as List).map((e) => fromJson(e as Map<String, dynamic>)).toList();
      } else {
        components = json['components'] as List<T>?;
      }
    }

    return SentencePatternEntity<T>(
      uid: json['uid'],
      name: json['name'],
      pattern: json['pattern'],
      components: components,
      access: json['access'],
      created: json['created'],
      updated: json['updated'],
    );
  }

  @override
  Map<String, dynamic> toJson({Function(T)? toJson}) => {
        'uid': uid,
        'name': name,
        'pattern': pattern,
        'components': components?.map((e) => toJson?.call(e) ?? e).toList(),
        'access': access,
        'created': created,
        'updated': updated,
      };

  // 更新时间格式化
  String get newUpdate {
    if (updated == null) return '';
    return DateUtil.formatDateStr(updated!, format: "yyyy/MM/dd");
  }

  // 创建时间
  String get newCreate {
    if (created == null) {
      return '';
    }

    return DateUtil.formatDateStr(created!, format: "yyyy/MM/dd");
  }

  // 上下架状态
  String get newAccess => StaticData.getOnOffShelfName(access) ?? '';

  // 是否上架
  bool get isAccess => StaticData.isOnOffShelfNormal(access);

  // 状态
  UnmountType get unmountType => UnmountType.fromValue(access ?? '');

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SentencePatternEntity && other.uid == uid;
  }

  @override
  int get hashCode => Object.hash(runtimeType, uid);
}

class ComponentEntity {
  // 保持原始结构不变
  final bool? core;
  final int? contentId;
  final int? semanticId;
  final String? contentType;
  final String? content;
  final String? component;
  final String? grammaticalTitle;
  final String? grammaticalEnglishName;

  ComponentEntity(
      {this.core,
      this.contentId,
      this.semanticId,
      this.contentType,
      this.content,
      this.component,
      this.grammaticalTitle,
      this.grammaticalEnglishName})
      : globalKey = GlobalKey();

  final GlobalKey globalKey;

  factory ComponentEntity.fromJson(Map<String, dynamic> json) {
    return ComponentEntity(
        core: json['core'],
        contentId: json['contentId'],
        semanticId: json['semanticId'],
        contentType: json['contentType'],
        content: json['content'],
        component: json['component'],
        grammaticalTitle: json['grammaticalTitle'],
        grammaticalEnglishName: json['grammaticalEnglishName']);
  }

  Map<String, dynamic> toJson() => {
        'core': core,
        'contentId': contentId,
        'semanticId': semanticId,
        'contentType': contentType,
        'content': content,
        'component': component,
      };

  String get newTitle {
    if (core ?? true) {
      return "$content";
    }

    return "${component ?? ''}(${grammaticalTitle ?? ''})";
  }
}
