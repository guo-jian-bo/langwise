import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// 知识点项目实体类
///
/// 用于表示审核系统中的知识点项目数据
class KnowledgePointItem {
  /// 唯一ID
  final String uniqueId;

  /// 知识点ID
  final String id;

  /// 单词
  final String word;

  /// 类型
  final String type;

  /// 知识点状态
  final String status;

  /// 更新时间
  final String updatedAt;

  /// 审核日期
  final String reviewDate;

  /// 语言区域
  final String locale;

  /// 图片数量
  final int imageCount;

  /// 已审核数量
  final int reviewedCount;

  /// 内容预览
  final String contentPreview;

  /// UI关联的全局键
  final GlobalKey globalKey;

  /// 构造函数
  KnowledgePointItem({
    String? uniqueId,
    required this.id,
    required this.word,
    required this.type,
    required this.status,
    required this.updatedAt,
    required this.reviewDate,
    required this.locale,
    required this.imageCount,
    required this.reviewedCount,
    this.contentPreview = '知识点内容预览...',
  })  : uniqueId = uniqueId ?? _generateUniqueId(),
        globalKey = GlobalKey(debugLabel: id);

  /// 唯一ID生成策略
  static String _generateUniqueId() {
    return const Uuid().v6();
  }

  /// 从JSON创建实例
  factory KnowledgePointItem.fromJson(Map<String, dynamic> json) {
    return KnowledgePointItem(
      id: json['id'] ?? '',
      word: json['word'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 'pending',
      updatedAt: json['updatedAt'] ?? '',
      reviewDate: json['reviewDate'] ?? '',
      locale: json['locale'] ?? 'zh_CN',
      imageCount: json['imageCount'] ?? 0,
      reviewedCount: json['reviewedCount'] ?? 0,
      contentPreview: json['contentPreview'] ?? '知识点内容预览...',
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'type': type,
      'status': status,
      'updatedAt': updatedAt,
      'reviewDate': reviewDate,
      'locale': locale,
      'imageCount': imageCount,
      'reviewedCount': reviewedCount,
      'contentPreview': contentPreview,
    };
  }

  /// 相等性比较
  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is KnowledgePointItem && other.id == id;
  }

  /// 哈希码
  @override
  int get hashCode => Object.hash(runtimeType, id);
}
