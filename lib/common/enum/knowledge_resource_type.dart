 
/// 知识点资源类型
enum KnowledgeResourceType { 
  audio("audio"),
  image("image"), 
  lrc("lrc");

  const KnowledgeResourceType(this.value);

  final String value;

  factory KnowledgeResourceType.fromRawValue(String value) {
    return values.firstWhere(
      (element) => element.value == value,
    );
  }

}