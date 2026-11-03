enum JumpTypeEnum {
  all("all", "全部"),
  none("none", "无跳转"),
  h5Link("h5_link", "H5链接"),
  deepLink("IN_APP", "DeepLink");

  const JumpTypeEnum(this.value, this.name);

  final String value;
  final String name;
}