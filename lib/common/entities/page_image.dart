import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// 书页图片模型，存储裁剪后的书页图片信息
class PageImage {
  /// 唯一标识符
  final String uuid;

  /// 关联的UI组件Key
  final ValueKey globalKey;

  /// 页面位置（当前页数）
  /// 默认为空，在编辑页面由用户手动填充
  final int? index;
  final String? key;

  /// 图片文件路径
  final String? imageUrl;

  // 图片原始字节大小
  final int? size;
  final String? access;
  final int? uid;

  /// 从JSON创建PageImage实例
  factory PageImage.fromJson(Map<String, dynamic> json) {
    // 提取uuid，如果没有则生成新的
    final String uuid = json['uuid'] as String? ?? const Uuid().v6();

    // 创建ValueKey，保持与工厂构造函数相同的逻辑
    final ValueKey globalKey = ValueKey(uuid);

    return PageImage._internal(
      uuid: uuid,
      index: json['index'],
      globalKey: globalKey,
      key: json['key'],
      imageUrl: json['imageUrl'],
      size: json['size'],
      access: json['access'],
      uid: json['uid'],
    );
  }

  /// 构造函数
  ///
  /// [uuid] 唯一标识符，如不提供则自动生成
  /// [filePath] 图片文件路径
  /// [pageNumber] 页面位置（当前页数）
  /// [width] 图片宽度
  /// [height] 图片高度
  /// [fileSize] 图片文件大小
  /// [globalKey] UI关联的Key，如不提供则自动生成
  /// 工厂构造函数，确保正确初始化uuid和key
  factory PageImage({
    String? uuid,
    ValueKey? globalKey,
    int? index,
    String? key,
    String? imageUrl,
    int? size,
    String? access,
    int? uid,
  }) {
    // 先初始化uuid
    final String finalUuid = uuid ?? const Uuid().v6();
    // 使用正确的uuid初始化key
    final ValueKey finalKey = globalKey ?? ValueKey(finalUuid);

    // 调用原始构造函数
    return PageImage._internal(
        uuid: finalUuid,
        index: index,
        globalKey: finalKey,
        key: key,
        imageUrl: imageUrl,
        size: size,
        access: access,
        uid: uid);
  }

  /// 内部构造函数，直接设置所有属性
  PageImage._internal({
    required this.uuid,
    this.index,
    required this.globalKey,
    this.key,
    this.imageUrl,
    this.size,
    this.access,
    this.uid,
  });

  /// 获取图片字节大小
  int get bytes => size ?? 0;

  /// 检查页码是否已设置
  bool get hasPageNumber => index != null;

  bool get isNetImageUrl => (hasUrl && imageUrl!.startsWith("http"));

  bool get hasUid => (uid != null);

  bool get hasUrl => (imageUrl != null);

  // 检查文件是否存在
  bool get isUrlExists => hasUrl && File(imageUrl!).existsSync();

  /// 创建副本
  PageImage copyWith({
    int? index,
    String? key,
    String? imageUrl,
    int? size,
    String? access,
    int? uid,
  }) {
    // 直接使用内部构造函数，保留原有uuid和globalKey
    return PageImage._internal(
        // 保留原始 uuid
        uuid: uuid,
        // 保留原始 globalKey
        globalKey: globalKey,
        index: index ?? this.index,
        key: key ?? this.key,
        imageUrl: imageUrl ?? this.imageUrl,
        size: size ?? this.size,
        access: access ?? this.access,
        uid: uid ?? this.uid);
  }

  // 上传json-有uid
  Map<String, dynamic> toJsonWithUid() => {
        "uid": uid,
        "key": key,
        "index": index,
        "size": size,
        "imageUrl": imageUrl,
        "access": access,
      };

  // 上传json
  Map<String, dynamic> toJsonWithoutUid() => {
        "key": key,
        "index": index,
        "size": size,
        "imageUrl": imageUrl,
        "access": access,
      };

  /// 转换为JSON，包含所有字段
  Map<String, dynamic> toJson() =>
      {"uid": uid, "key": key, "index": index, "size": size, "imageUrl": imageUrl, "access": access, "uuid": uuid};

  /// 判断相等性
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PageImage && other.uuid == uuid;
  }

  /// 计算哈希码
  @override
  int get hashCode => uuid.hashCode;

  /// 转换为字符串表示
  @override
  String toString() => 'PageImage(uuid: $uuid, index: $index, imageUrl: $imageUrl)';
}
