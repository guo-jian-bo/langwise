enum ZhenduPageTypeEnum {
  listen("listen", "听"),
  read("read", "读"),
  watch("watch", "看"),
  perform("perform", "演"),
  practice("practice", "练");

  const ZhenduPageTypeEnum(this.value, this.label);

  final String value;
  final String label;

  static ZhenduPageTypeEnum? fromValue(String? value) {
    if (value == null) return null;
    for (final type in ZhenduPageTypeEnum.values) {
      if (type.value == value) {
        return type;
      }
    }
    return null;
  }

}
