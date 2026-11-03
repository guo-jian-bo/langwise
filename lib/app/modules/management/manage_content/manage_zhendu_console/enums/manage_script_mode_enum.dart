
// ignore_for_file: constant_identifier_names

enum ManageScriptModeEnum {
  /// 自动选择
  auto("auto", "自动选择"),
  /// 聚焦单个义项
  single_semantic("single_semantic", "聚焦单个义项"),
  /// 融合多个义项
  multi_semantic("multi_semantic", "融合多个义项"),
  /// 习语专属路径
  idiom("idiom", "习语专属路径");

  const ManageScriptModeEnum(this.value, this.label);

  final String value;
  final String label;

  static ManageScriptModeEnum? fromValue(String? value) {
    if(value == null) return null;
    for (final item in ManageScriptModeEnum.values) {
      if (item.value == value) {
        return item;
      }
    }
    return null;
  }

}