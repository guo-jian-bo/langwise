class ManageEnglishContentManagementSentenceIpaAudioModel {
  int? uid;
  int? accentId;
  String? accent;
  String? name;
  bool? published;
  int? contentId;
  int? assPublished;

  ManageEnglishContentManagementSentenceIpaAudioModel({
    this.uid,
    this.accentId,
    this.accent,
    this.name,
    this.published,
    this.contentId,
    this.assPublished,
  });

  factory ManageEnglishContentManagementSentenceIpaAudioModel.fromJson(Map<String, dynamic> json) {
    return ManageEnglishContentManagementSentenceIpaAudioModel(
      uid: json['uid'] as int?,
      accentId: json['accentId'] as int?,
      accent: json['accent'] as String?,
      name: json['name'] as String?,
      published: json['published'] as bool?,
      contentId: json['contentId'] as int?,
      assPublished: json['assPublished'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['accentId'] = accentId;
    data['accent'] = accent;
    data['name'] = name;
    data['published'] = published;
    data['contentId'] = contentId;
    data['assPublished'] = assPublished;
    return data;
  }
}
