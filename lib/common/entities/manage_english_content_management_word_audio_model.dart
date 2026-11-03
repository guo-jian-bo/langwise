import 'package:quiz_play/models/quiz_model.dart';

class ManageEnglishContentManagementWordAudioModel {
  int? uid;
  String? contentType;
  int? contentId;
  String? content;
  String? ipa;
  bool? wordPublished;
  bool? noNeedSyllables;
  ManageEnglishContentManagementWordAudioAccentModel? accent;
  List<String>? websters;
  String? audioUrl;
  ManageEnglishContentManagementWordAudioWordIpaModel? wordIpa;
  ManageEnglishContentManagementWordAudioSoundBlockDTOModel? soundBlockDTO;
  bool? syllablesPublished;
  String? updated;
  String? created;
  List<QuizModel>? exerciseDTO;

  get soundBlocks {
    for (var element in exerciseDTO ?? []) {
      if (element.type == 'SOUND_BLOCKS') {
        return true;
      }
    }
    return false;
  }

  get pronunciationBreakdown {
    for (var element in exerciseDTO ?? []) {
      if (element.type == 'PRONUNCIATION_BREAKDOWN') {
        return true;
      }
    }
    return false;
  }

  ManageEnglishContentManagementWordAudioModel({
    this.uid,
    this.contentType,
    this.contentId,
    this.content,
    this.ipa,
    this.wordPublished,
    this.noNeedSyllables,
    this.accent,
    this.websters,
    this.audioUrl,
    this.wordIpa,
    this.soundBlockDTO,
    this.syllablesPublished,
    this.updated,
    this.created,
    this.exerciseDTO,
  });

  factory ManageEnglishContentManagementWordAudioModel.fromJson(Map<String, dynamic> json) {
    return ManageEnglishContentManagementWordAudioModel(
      uid: json['uid'],
      contentType: json['contentType'],
      contentId: json['contentId'],
      content: json['content'],
      ipa: json['ipa'],
      wordPublished: json['wordPublished'],
      noNeedSyllables: json['noNeedSyllables'],
      accent: json['accent'] != null ? ManageEnglishContentManagementWordAudioAccentModel.fromJson(json['accent']) : null,
      websters: json['websters'] != null ? List<String>.from(json['websters']) : null,
      audioUrl: json['audioUrl'],
      wordIpa: json['wordIpa'] != null ? ManageEnglishContentManagementWordAudioWordIpaModel.fromJson(json['wordIpa']) : null,
      soundBlockDTO: json['soundBlockDTO'] != null ? ManageEnglishContentManagementWordAudioSoundBlockDTOModel.fromJson(json['soundBlockDTO']) : null,
      syllablesPublished: json['syllablesPublished'],
      updated: json['updated'],
      created: json['created'],
      exerciseDTO: json['exerciseDTO'] != null ? List<QuizModel>.from((json['exerciseDTO'] as List).map((x) => QuizModel.fromJson(x))) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['contentType'] = contentType;
    data['contentId'] = contentId;
    data['content'] = content;
    data['ipa'] = ipa;
    data['wordPublished'] = wordPublished;
    data['noNeedSyllables'] = noNeedSyllables;
    data['accent'] = accent?.toJson();
    data['websters'] = websters;
    data['audioUrl'] = audioUrl;
    data['wordIpa'] = wordIpa?.toJson();
    data['soundBlockDTO'] = soundBlockDTO?.toJson();
    data['syllablesPublished'] = syllablesPublished;
    data['updated'] = updated;
    data['created'] = created;
    data['exerciseDTO'] = exerciseDTO?.toList();
    return data;
  }
}

class ManageEnglishContentManagementWordAudioSoundBlockDTOModel {
  int? uid;
  bool? published;
  List<ManageEnglishContentManagementWordAudioSoundBlockDTOSyllableModel>? syllables;

  ManageEnglishContentManagementWordAudioSoundBlockDTOModel({
    this.uid,
    this.published,
    this.syllables,
  });

  factory ManageEnglishContentManagementWordAudioSoundBlockDTOModel.fromJson(Map<String, dynamic> json) {
    return ManageEnglishContentManagementWordAudioSoundBlockDTOModel(
      uid: json['uid'],
      published: json['published'],
      syllables: json["syllables"] != null
          ? List<ManageEnglishContentManagementWordAudioSoundBlockDTOSyllableModel>.from(
              (json["syllables"] as List).map((x) => ManageEnglishContentManagementWordAudioSoundBlockDTOSyllableModel.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['published'] = published;
    data['syllables'] = syllables?.map((e) => e.toJson()).toList();
    return data;
  }
}

class ManageEnglishContentManagementWordAudioSoundBlockDTOSyllableModel {
  String? ipa;
  String? graphemes;
  ManageEnglishContentManagementWordAudioWordIpaModel? phoneme;
  List<int>? positions;
  List<int>? ipaPositions;
  List<ManageEnglishContentManagementWordAudioSoundBlockDTOSyllablePhonicModel>? phonics;
  String? url;
  bool? published;
  String? variant;

  ManageEnglishContentManagementWordAudioSoundBlockDTOSyllableModel({
    this.ipa,
    this.graphemes,
    this.phoneme,
    this.positions,
    this.ipaPositions,
    this.phonics,
    this.url,
    this.published,
    this.variant,
  });

  factory ManageEnglishContentManagementWordAudioSoundBlockDTOSyllableModel.fromJson(Map<String, dynamic> json) {
    return ManageEnglishContentManagementWordAudioSoundBlockDTOSyllableModel(
      ipa: json['ipa'],
      graphemes: json['graphemes'],
      phoneme: json['phoneme'] != null ? ManageEnglishContentManagementWordAudioWordIpaModel.fromJson(json['phoneme']) : null,
      positions: json['positions'] != null ? List<int>.from(json['positions']) : null,
      ipaPositions: json['ipaPositions'] != null ? List<int>.from(json['ipaPositions']) : null,
      phonics: json['phonics'] != null
          ? List<ManageEnglishContentManagementWordAudioSoundBlockDTOSyllablePhonicModel>.from(
              (json['phonics'] as List).map((x) => ManageEnglishContentManagementWordAudioSoundBlockDTOSyllablePhonicModel.fromJson(x)))
          : null,
      url: json['url'],
      published: json['published'],
      variant: json['variant'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ipa'] = ipa;
    data['graphemes'] = graphemes;
    data['phoneme'] = phoneme?.toJson();
    data['positions'] = positions;
    data['ipaPositions'] = ipaPositions;
    data['phonics'] = phonics?.map((e) => e.toJson()).toList();
    data['url'] = url;
    data['published'] = published;
    data['variant'] = variant;
    return data;
  }
}

class ManageEnglishContentManagementWordAudioSoundBlockDTOSyllablePhonicModel {
  String? ipa;
  String? graphemes;
  ManageEnglishContentManagementWordAudioWordIpaModel? phoneme;
  List<int>? positions;
  List<int>? ipaPositions;
  String? url;
  bool? published;
  String? variant;

  ManageEnglishContentManagementWordAudioSoundBlockDTOSyllablePhonicModel({
    this.ipa,
    this.graphemes,
    this.phoneme,
    this.positions,
    this.ipaPositions,
    this.url,
    this.published,
    this.variant,
  });

  factory ManageEnglishContentManagementWordAudioSoundBlockDTOSyllablePhonicModel.fromJson(Map<String, dynamic> json) {
    return ManageEnglishContentManagementWordAudioSoundBlockDTOSyllablePhonicModel(
      ipa: json['ipa'],
      graphemes: json['graphemes'],
      phoneme: json['phoneme'] != null ? ManageEnglishContentManagementWordAudioWordIpaModel.fromJson(json['phoneme']) : null,
      positions: json['positions'] != null ? List<int>.from(json['positions']) : null,
      ipaPositions: json['ipaPositions'] != null ? List<int>.from(json['ipaPositions']) : null,
      url: json['url'],
      published: json['published'],
      variant: json['variant'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ipa'] = ipa;
    data['graphemes'] = graphemes;
    data['phoneme'] = phoneme?.toJson();
    data['positions'] = positions;
    data['ipaPositions'] = ipaPositions;
    data['url'] = url;
    data['published'] = published;
    data['variant'] = variant;
    return data;
  }
}

class ManageEnglishContentManagementWordAudioWordIpaModel {
  double? duration;
  int? size;
  String? fileKey;

  ManageEnglishContentManagementWordAudioWordIpaModel({
    this.duration,
    this.size,
    this.fileKey,
  });

  factory ManageEnglishContentManagementWordAudioWordIpaModel.fromJson(Map<String, dynamic> json) {
    return ManageEnglishContentManagementWordAudioWordIpaModel(
      duration: json['duration'],
      size: json['size'],
      fileKey: json['fileKey'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['duration'] = duration;
    data['size'] = size;
    data['fileKey'] = fileKey;
    return data;
  }
}

class ManageEnglishContentManagementWordAudioWordSimpleModel {
  int? uid;
  String? type;

  ManageEnglishContentManagementWordAudioWordSimpleModel({
    this.uid,
    this.type,
  });

  factory ManageEnglishContentManagementWordAudioWordSimpleModel.fromJson(Map<String, dynamic> json) {
    return ManageEnglishContentManagementWordAudioWordSimpleModel(
      uid: json['uid'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['type'] = type;
    return data;
  }
}

class ManageEnglishContentManagementWordAudioAccentModel {
  int? uid;
  String? name;
  String? national;
  String? description;
  String? gender;

  ManageEnglishContentManagementWordAudioAccentModel({
    this.uid,
    this.name,
    this.national,
    this.description,
    this.gender,
  });

  factory ManageEnglishContentManagementWordAudioAccentModel.fromJson(Map<String, dynamic> json) {
    return ManageEnglishContentManagementWordAudioAccentModel(
      uid: json['uid'],
      name: json['name'],
      national: json['national'],
      description: json['description'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['national'] = national;
    data['description'] = description;
    data['gender'] = gender;
    return data;
  }
}
