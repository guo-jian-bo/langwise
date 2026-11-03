

import '../../../../../../../../../../common/entities/entities.dart';

class ManageEnglishContentManagementSentenceAudioModel {
  int? uid;
  String? type;
  int? contentId;
  String? content;
  int? accentId;
  String? fileKey;
  String? prompt;

  String? url;
  int? size;
  double? duration;
  String? ass;
  bool? published;
  int? assPublished;
  String? updated;
  ManageEnglishContentManagementSentenceAudioAccentModel? accent;
  List<LanguageText>? translate;
  String? status;
  String? errMsg;

  ManageEnglishContentManagementSentenceAudioModel(
    this.uid,
    this.type,
    this.contentId,
    this.content,
    this.accentId,
    this.fileKey,
    this.prompt,
    this.url,
    this.size,
    this.duration,
    this.ass,
    this.published,
    this.assPublished,
    this.updated,
    this.accent,
    this.translate,
    this.status,
    this.errMsg,
  );

  factory ManageEnglishContentManagementSentenceAudioModel.fromJson(Map<String, dynamic> json) {
    return ManageEnglishContentManagementSentenceAudioModel(
      json['uid'],
      json['type'],
      json['contentId'],
      json['content'],
      json['accentId'],
      json['fileKey'],
      json['prompt'],
      json['url'],
      json['size'],
      json['duration'],
      json['ass'],
      json['published'],
      json['assPublished'],
      json['updated'],
      json['accent'] != null ? ManageEnglishContentManagementSentenceAudioAccentModel.fromJson(json['accent']) : null,
      json['translate'] != null ? (json['translate'] as List).map((e) => LanguageText.fromJson(e)).toList() : null,
      json['status'],
      json['errMsg'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'type': type,
      'contentId': contentId,
      'content': content,
      'accentId': accentId,
      'fileKey': fileKey,
      'prompt': prompt,
      'url': url,
      'size': size,
      'duration': duration,
      'ass': ass,
      'published': published,
      'assPublished': assPublished,
      'updated': updated,
      'accent': accent,
      'translate': translate,
      'status':status
    };
  }
}

class ManageEnglishContentManagementSentenceAudioAccentModel {
  int? uid;
  String? name;
  String? national;
  String? description;
  String? gender;

  ManageEnglishContentManagementSentenceAudioAccentModel(
    this.uid,
    this.name,
    this.national,
    this.description,
    this.gender,
  );

  factory ManageEnglishContentManagementSentenceAudioAccentModel.fromJson(Map<String, dynamic> json) {
    return ManageEnglishContentManagementSentenceAudioAccentModel(
      json['uid'],
      json['name'],
      json['national'],
      json['description'],
      json['gender'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'national': national,
      'description': description,
      'gender': gender,
    };
  }
}
