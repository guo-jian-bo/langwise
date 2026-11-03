abstract class JsonSerializable {
  Map<String, dynamic> toJson();
}

// 序列化Mixin（可为空实现）
mixin JsonSerializableMixin implements JsonSerializable {
  @override
  Map<String, dynamic> toJson() => {};
}