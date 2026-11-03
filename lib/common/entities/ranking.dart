import 'package:flutter/material.dart';

/// 排行榜数据项
class RankingResponseEntity {
  /// 排名
  final int? rank;

  /// 审核员ID
  final int userId;

  /// 审核员名称
  final String? name;

  /// 审核图片数量
  final int? imageCount;

  /// 审核单词数量
  final int? wordCount;

  /// 审核员标识
  final String? inspector;

  /// UI关联的全局键
  final GlobalKey globalKey;

  RankingResponseEntity({
    this.rank,
    required this.userId,
    this.name,
    this.imageCount,
    this.wordCount,
    this.inspector,
  }) : globalKey = GlobalKey(debugLabel: userId.toString());

  /// 从服务器响应数据创建实体
  factory RankingResponseEntity.fromJson(Map<String, dynamic> json, {int? rank}) {
    return RankingResponseEntity(
      rank: (json['rank']),
      userId: json['userId'] ?? 0,
      name: json['inspector'],
      imageCount: json['imageCount'],
      wordCount: json['wordCount'],
      inspector: json['inspector'],
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'userId': userId,
      'inspector': inspector,
      'imageCount': imageCount,
      'wordCount': wordCount,
    };
  }

  bool get hasRank => rank != null;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is RankingResponseEntity && other.userId == userId;
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId);
}
