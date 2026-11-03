import 'package:uuid/uuid.dart';

class WordImageEntity {
  // final 确保不可变性
  final String uniqueId;
  final String? key;
  final String? url;
  final int? index;
  final int? size;
  final String? access;
  final int? uid;

  WordImageEntity({
    String? uniqueId, // 改为可选参数
    this.key,
    this.url,
    this.index,
    this.size,
    this.access,
    this.uid,
  }) : uniqueId = uniqueId ?? _generateUniqueId(); // 生成逻辑抽离

  /// JSON反序列化优化
  factory WordImageEntity.fromJson(Map<String, dynamic> json) => WordImageEntity(
        uniqueId: json["uniqueId"],
        // 保留服务端可能返回的ID
        key: json["key"],
        url: json["url"],
        index: json["index"],
        size: json["size"],
        access: json["access"],
        uid: json["uid"],
      );

  /// 唯一ID生成策略
  static String _generateUniqueId() {
    return const Uuid().v6();
  }

  /// 深度拷贝优化
  WordImageEntity copyWith({
    String? uniqueId, // 允许覆盖唯一ID
    String? key,
    String? url,
    int? index,
    int? size,
    String? access,
    int? uid,
  }) {
    return WordImageEntity(
      uniqueId: uniqueId ?? this.uniqueId,
      // 默认继承原ID
      key: key ?? this.key,
      url: url ?? this.url,
      // index不沿用旧的
      index: index,
      size: size ?? this.size,
      access: access ?? this.access,
      uid: uid ?? this.uid,
    );
  }

  bool get isUrl => (url != null && url!.startsWith("http"));

  bool get hasUid => (uid != null);

  @override
  String toString() => '{WordImageEntity: uniqueId:$uniqueId, uid:$uid, index:$index}';

  /// 相等性判断优化
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is WordImageEntity && uniqueId == other.uniqueId);

  @override
  int get hashCode => uniqueId.hashCode;
}
