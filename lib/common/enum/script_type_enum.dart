enum ScriptTypeEnum{
  /// 单元剧本
  unit("unit", "单元"),
  vocabulary("vocabulary", "词汇");

  const ScriptTypeEnum(this.value, this.name);

  /// 后端存储值。
  final String value;
  final String name;

    /// 通过存储值反查枚举。
  static ScriptTypeEnum? fromValue(String? value) {
    if (value == null) return null;
    for (final item in ScriptTypeEnum.values) {
      if (item.value == value) {
        return item;
      }
    }
    return null;
  }
}