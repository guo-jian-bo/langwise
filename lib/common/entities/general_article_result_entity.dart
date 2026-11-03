class GeneralArticleResultEntity {
  final bool? isRepeat;
  final String? content;
  final bool success;

  const GeneralArticleResultEntity({
    required this.success,
    this.isRepeat,
    this.content,
  });

  factory GeneralArticleResultEntity.fromJson(Map<String, dynamic> json) {
    return GeneralArticleResultEntity(
      success: true,
      isRepeat: json['isRepeat'] as bool?,
      content: json['content']?.toString(),
    );
  }
}
