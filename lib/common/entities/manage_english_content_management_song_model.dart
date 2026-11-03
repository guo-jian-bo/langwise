import 'package:langwise/app/modules/management/models/manage_english_content_management_sentence_model.dart';
import 'package:langwise/common/widgets/data_table_widget/data_sources.dart';

class ManageEnglishContentManagementSongModel extends Dessert {
  final String? title;
  final String? prompt;
  final String? lyrics;
  final String? content;
  final String? contentType;
  final ManageEnglishContentManagementSongDifficulty? difficulty;
  final List<ManageEnglishContentManagementSongSubContentId>? subContentIds;
  final ManageEnglishContentManagementSongKnowledgeStatisticsModel? contentKnowledgeStatistics;
  final List<ManageEnglishContentManagementSentenceIpaAudioModel>? audioExpressionList;
  final bool? inCourse;
  final int? inCourseCnt;
  final String? genre;
  final String? theme;
  final int? wordCount;
  final String? access;
  final String? updated;
  final String? created;

  ManageEnglishContentManagementSongModel({
    required int uid,
    this.title,
    this.prompt,
    this.lyrics,
    this.content,
    this.contentType,
    this.difficulty,
    this.subContentIds,
    this.contentKnowledgeStatistics,
    this.audioExpressionList,
    this.inCourse,
    this.inCourseCnt,
    this.genre,
    this.theme,
    this.wordCount,
    this.access,
    this.updated,
    this.created,
  }) : super(uid: uid);

  factory ManageEnglishContentManagementSongModel.fromJson(Map<String, dynamic> json) {
    return ManageEnglishContentManagementSongModel(
      uid: json['uid']?.toInt(),
      title: json['title']?.toString(),
      prompt: json['prompt']?.toString(),
      lyrics: json['lyrics']?.toString(),
      content: json['content']?.toString(),
      contentType: json['contentType']?.toString(),
      difficulty: json['difficulty'] != null ? ManageEnglishContentManagementSongDifficulty.fromJson(json['difficulty'] as Map<String, dynamic>) : null,
      subContentIds: json['subContentIds'] != null
          ? (json['subContentIds'] as List).map((e) => ManageEnglishContentManagementSongSubContentId.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      contentKnowledgeStatistics: json['contentKnowledgeStatistics'] != null
          ? ManageEnglishContentManagementSongKnowledgeStatisticsModel.fromJson(json['contentKnowledgeStatistics'] as Map<String, dynamic>)
          : null,
      audioExpressionList: json['audioExpressionList'] != null
          ? (json['audioExpressionList'] as List).map((e) => ManageEnglishContentManagementSentenceIpaAudioModel.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      inCourse: json['in_course'],
      inCourseCnt: json['in_course_cnt']?.toInt(),
      genre: json['genre']?.toString(),
      theme: json['theme']?.toString(),
      wordCount: json['wordCount']?.toInt(),
      access: json['access']?.toString(),
      updated: json['updated']?.toString(),
      created: json['created']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'title': title,
      'prompt': prompt,
      'lyrics': lyrics,
      'content': content,
      'contentType': contentType,
      'difficulty': difficulty?.toJson(),
      'subContentIds': subContentIds?.map((e) => e.toJson()).toList(),
      'contentKnowledgeStatistics': contentKnowledgeStatistics?.toJson(),
      'audioExpressionList': audioExpressionList?.map((e) => e.toJson()).toList(),
      'in_course': inCourse,
      'in_course_cnt': inCourseCnt,
      'genre': genre,
      'theme': theme,
      'wordCount': wordCount,
      'access': access,
      'updated': updated,
      'created': created,
    };
  }
}

class ManageEnglishContentManagementSongDifficulty {
  final int? max;
  final int? min;

  ManageEnglishContentManagementSongDifficulty({this.max, this.min});

  factory ManageEnglishContentManagementSongDifficulty.fromJson(Map<String, dynamic> json) {
    return ManageEnglishContentManagementSongDifficulty(
      max: json['max']?.toInt(),
      min: json['min']?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'max': max,
      'min': min,
    };
  }
}

class ManageEnglishContentManagementSongSubContentId {
  final String? type;
  final int? uid;
  final int? semanticId;

  ManageEnglishContentManagementSongSubContentId({this.type, this.uid, this.semanticId});

  factory ManageEnglishContentManagementSongSubContentId.fromJson(Map<String, dynamic> json) {
    return ManageEnglishContentManagementSongSubContentId(
      type: json['type']?.toString(),
      uid: json['uid']?.toInt(),
      semanticId: json['semanticId']?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'uid': uid,
      'semanticId': semanticId,
    };
  }
}

class ManageEnglishContentManagementSongKnowledgeStatisticsModel {
  final int? uid;
  final String? type;
  final String? content;
  final String? title;
  final int? total;
  final List<ManageEnglishContentManagementSongContentKnowledgeModel>? contentKnowledge;

  ManageEnglishContentManagementSongKnowledgeStatisticsModel({
    this.uid,
    this.type,
    this.content,
    this.title,
    this.total,
    this.contentKnowledge,
  });

  factory ManageEnglishContentManagementSongKnowledgeStatisticsModel.fromJson(Map<String, dynamic> json) {
    return ManageEnglishContentManagementSongKnowledgeStatisticsModel(
      uid: json['uid']?.toInt(),
      type: json['type']?.toString(),
      content: json['content']?.toString(),
      title: json['title']?.toString(),
      total: json['total']?.toInt(),
      contentKnowledge:
          json['contentKnowledge'] != null ? (json['contentKnowledge'] as List).map((e) => ManageEnglishContentManagementSongContentKnowledgeModel.fromJson(e)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'type': type,
      'content': content,
      'title': title,
      'total': total,
      'contentKnowledge': contentKnowledge?.map((e) => e.toJson()).toList(),
    };
  }
}

class ManageEnglishContentManagementSongContentKnowledgeModel {
  final int? total;
  final String? contentType;
  final String? contentTypeTitle;
  final List<ManageEnglishContentManagementSongKnowledgeModel>? contentSimpleList;

  ManageEnglishContentManagementSongContentKnowledgeModel({
    this.total,
    this.contentType,
    this.contentTypeTitle,
    this.contentSimpleList,
  });

  factory ManageEnglishContentManagementSongContentKnowledgeModel.fromJson(Map<String, dynamic> json) {
    return ManageEnglishContentManagementSongContentKnowledgeModel(
      total: json['total']?.toInt(),
      contentType: json['contentType']?.toString(),
      contentTypeTitle: json['contentTypeTitle']?.toString(),
      contentSimpleList:
          json['contentSimpleList'] != null ? (json['contentSimpleList'] as List).map((e) => ManageEnglishContentManagementSongKnowledgeModel.fromJson(e)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'contentType': contentType,
      'contentTypeTitle': contentTypeTitle,
      'contentSimpleList': contentSimpleList?.map((e) => e.toJson()).toList(),
    };
  }
}

class ManageEnglishContentManagementSongKnowledgeModel {
  final String? contentType;
  final int? contentId;
  final String? content;
  final int? semanticId;
  final String? definition;
  final List<ManageEnglishContentManagementSongGloss>? gloss;
  final String? imageUrl;
  final int? matchSign;

  ManageEnglishContentManagementSongKnowledgeModel({
    this.contentType,
    this.contentId,
    this.content,
    this.semanticId,
    this.definition,
    this.gloss,
    this.imageUrl,
    this.matchSign,
  });

  factory ManageEnglishContentManagementSongKnowledgeModel.fromJson(Map<String, dynamic> json) {
    return ManageEnglishContentManagementSongKnowledgeModel(
      contentType: json['contentType']?.toString(),
      contentId: json['contentId']?.toInt(),
      content: json['content']?.toString(),
      semanticId: json['semanticId']?.toInt(),
      definition: json['definition']?.toString(),
      gloss: json['gloss'] != null ? (json['gloss'] as List).map((e) => ManageEnglishContentManagementSongGloss.fromJson(e)).toList() : null,
      imageUrl: json['imageUrl']?.toString(),
      matchSign: json['matchSign']?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contentType': contentType,
      'contentId': contentId,
      'content': content,
      'semanticId': semanticId,
      'definition': definition,
      'gloss': gloss?.map((e) => e.toJson()).toList(),
      'imageUrl': imageUrl,
      'matchSign': matchSign,
    };
  }
}

class ManageEnglishContentManagementSongGloss {
  final String? lang;
  final String? text;

  ManageEnglishContentManagementSongGloss({this.lang, this.text});

  factory ManageEnglishContentManagementSongGloss.fromJson(Map<String, dynamic> json) {
    return ManageEnglishContentManagementSongGloss(
      lang: json['lang']?.toString(),
      text: json['text']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lang': lang,
      'text': text,
    };
  }
}
