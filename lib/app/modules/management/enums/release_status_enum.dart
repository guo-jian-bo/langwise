
// ignore_for_file: constant_identifier_names

enum ReleaseStatusEnum{

  PUBLISHED("PUBLISHED", "已发布"),
  UNPUBLISHED("UNPUBLISHED", "未发布");

  final String value;
  final String name;
  const ReleaseStatusEnum(this.value, this.name);

}