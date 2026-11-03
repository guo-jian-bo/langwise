

import '../../../../../../common/entities/entities.dart';
import 'manage_english_content_management_sentence_audio_model.dart';

class AudioSubtitleEditorModel {
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
  AudioSubtitleEditorAccentModel? accent;
  List<LanguageText>? translate;
  String? status;
  String? errMsg;

  AudioSubtitleEditorModel(
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

  factory AudioSubtitleEditorModel.fromJson(Map<String, dynamic> json) {
    return AudioSubtitleEditorModel(
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
      json['accent'] != null ? AudioSubtitleEditorAccentModel.fromJson(json['accent']) : null,
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

  /// 从原始模型构建
  factory AudioSubtitleEditorModel.fromOriginalModel(ManageEnglishContentManagementSentenceAudioModel model) {
    return AudioSubtitleEditorModel(
      model.uid,
      model.type,
      model.contentId,
      model.content,
      model.accentId,
      model.fileKey,
      model.prompt,
      model.url,
      model.size,
      model.duration,
      model.ass,
      model.published,
      model.assPublished,
      model.updated,
      model.accent != null ? AudioSubtitleEditorAccentModel.fromOriginalModel(model.accent!) : null,
      model.translate,
      model.status,
      model.errMsg,
    );
  }
}

class AudioSubtitleEditorAccentModel {
  int? uid;
  String? name;
  String? national;
  String? description;
  String? gender;

  AudioSubtitleEditorAccentModel(
    this.uid,
    this.name,
    this.national,
    this.description,
    this.gender,
  );

  factory AudioSubtitleEditorAccentModel.fromJson(Map<String, dynamic> json) {
    return AudioSubtitleEditorAccentModel(
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

  /// 从原始模型构建
  factory AudioSubtitleEditorAccentModel.fromOriginalModel(ManageEnglishContentManagementSentenceAudioAccentModel model) {
    return AudioSubtitleEditorAccentModel(
      model.uid,
      model.name,
      model.national,
      model.description,
      model.gender,
    );
  }
}
