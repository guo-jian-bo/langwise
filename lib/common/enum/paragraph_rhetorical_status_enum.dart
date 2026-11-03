enum ParagraphRhetoricalStatusEnum {
  required("要写"),
  optional("可写"),
  empty("空着");

  const ParagraphRhetoricalStatusEnum(this.name);

  final String name;
}