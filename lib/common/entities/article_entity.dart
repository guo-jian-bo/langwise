import 'package:langwise/app/modules/management/models/manage_english_content_management_sentence_model.dart';
import 'package:langwise/common/entities/knowledge.dart';

/// 单篇甄听文章（前台展示用）
class ArticleEntity extends BaseKnowledge {
  int contentId;
  String? group;
  String? title;
  String? content;
  dynamic difficulty;
  bool? isLaunch;
  String? sourceUrl;
  String? sourceContent;
  bool? isAudioStart;
  String? audioStatus;
  String? imageUrl;
  String? calendarType;
  String? publishedDate;
  int? normalExerciseNum;
  List<ManageEnglishContentManagementSentenceIpaAudioModel>? audioExpressionList;
  Map<String, dynamic>? contentKnowledgeStatistics;
  int? wordCount;
  String? theme;
  String? genre;
  String? lyrics;
  ArticleEntityRelationImage? relationImage;
  ArticleEntityRelationVideo? relationVideo;

  ArticleEntity({
    required int uid,
    required this.contentId,
    this.group,
    this.title,
    this.content,
    this.difficulty,
    this.isLaunch,
    this.sourceUrl,
    this.sourceContent,
    this.isAudioStart,
    this.audioStatus,
    this.imageUrl,
    this.calendarType,
    this.publishedDate,
    this.normalExerciseNum,
    this.audioExpressionList,
    this.contentKnowledgeStatistics,
    this.wordCount,
    this.theme,
    this.genre,
    this.lyrics,
    this.relationImage,
    this.relationVideo,
  }) : super(
          uid: uid,
          contentId: contentId,
          content: content,
          difficulty: difficulty,
        );

  factory ArticleEntity.fromJson(Map<String, dynamic> json) {
    final int cid = (json['contentId'] ?? 0) as int;

    List<ManageEnglishContentManagementSentenceIpaAudioModel>? audios;
    if (json['audioExpressionList'] != null) {
      final list = json['audioExpressionList'] as List<dynamic>;
      audios = list.map((e) => ManageEnglishContentManagementSentenceIpaAudioModel.fromJson(e)).toList();
    }

    return ArticleEntity(
      uid: cid,
      contentId: cid,
      title: json['title'] as String?,
      group: json['group'] as String?,
      content: json['content'] as String?,
      difficulty: json['difficulty'],
      isLaunch: json['isLaunch'] as bool?,
      sourceUrl: json['sourceUrl'] as String?,
      sourceContent: json['sourceContent'] as String?,
      isAudioStart: json['isAudioStart'] as bool?,
      audioStatus: json['audioStatus'] as String?,
      imageUrl: json['imageUrl'] as String?,
      calendarType: json['calendarType'] as String?,
      publishedDate: json['publishedDate'] as String?,
      normalExerciseNum: json['normalExerciseNum']?.toInt(),
      audioExpressionList: audios,
      contentKnowledgeStatistics: json['contentKnowledgeStatistics'] as Map<String, dynamic>?,
      wordCount: json['wordCount']?.toInt(),
      theme: json['theme'] as String?,
      genre: json['genre'] as String?,
      lyrics: json['lyrics'] as String?,
      relationImage: json['relationImage'] != null ? ArticleEntityRelationImage.fromJson(json['relationImage']) : null,
      relationVideo: json['relationVideo'] != null ? ArticleEntityRelationVideo.fromJson(json['relationVideo']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['contentId'] = contentId;
    data['group'] = group;
    data['title'] = title;
    data['content'] = content;
    data['difficulty'] = difficulty;
    data['isLaunch'] = isLaunch;
    data['sourceUrl'] = sourceUrl;
    data['sourceContent'] = sourceContent;
    data['isAudioStart'] = isAudioStart;
    data['audioStatus'] = audioStatus;
    data['imageUrl'] = imageUrl;
    data['calendarType'] = calendarType;
    data['publishedDate'] = publishedDate;
    data['normalExerciseNum'] = normalExerciseNum;
    if (audioExpressionList != null) {
      data['audioExpressionList'] = audioExpressionList!.map((e) => e.toJson()).toList();
    }

    if (contentKnowledgeStatistics != null) {
      data['contentKnowledgeStatistics'] = contentKnowledgeStatistics;
    }

    data['theme'] = theme;
    data['genre'] = genre;

    data['wordCount'] = wordCount;
    data['lyrics'] = lyrics;
    if (relationImage != null) {
      data['relationImage'] = relationImage!.toJson();
    }
    if (relationVideo != null) {
      data['relationVideo'] = relationVideo!.toJson();
    }
    return data;
  }
}


class ArticleEntityRelationVideo {
/*
{
  "uid": 9,
  "type": "EN_WORD",
  "contentId": 103518,
  "semanticId": 681404,
  "videoUrl": "https://video.timelywise.cn/video/generated/C4C1FDB0358E046FEB6732C94B80C882.mp4?auth_key=1772729791-dgngp31vhy6e-0-39cbf44f10ad388b236a03a45726d92d",
  "videoKey": "video/generated/C4C1FDB0358E046FEB6732C94B80C882.mp4",
  "duration": 3,
  "startSeconds": 0,
  "endSeconds": 3,
  "firstImageUrl": "https://img.timelywise.cn/knowledge/semantic/DB0287261378C9B4A3A27620FD27FAD5.webp?auth_key=1772729791-a6v44ad10u0v-0-125e0a2f8f986a4decbbf0c5c195b13c",
  "lines": [
    "Hmm, that's it!"
  ],
  "locked": false
} 
*/

  int? uid;
  String? type;
  int? contentId;
  int? semanticId;
  String? videoUrl;
  String? videoKey;
  int? duration;
  int? startSeconds;
  int? endSeconds;
  String? firstImageUrl;
  List<String?>? lines;
  bool? locked;

  ArticleEntityRelationVideo({
    this.uid,
    this.type,
    this.contentId,
    this.semanticId,
    this.videoUrl,
    this.videoKey,
    this.duration,
    this.startSeconds,
    this.endSeconds,
    this.firstImageUrl,
    this.lines,
    this.locked,
  });
  ArticleEntityRelationVideo.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    type = json['type']?.toString();
    contentId = json['contentId']?.toInt();
    semanticId = json['semanticId']?.toInt();
    videoUrl = json['videoUrl']?.toString();
    videoKey = json['videoKey']?.toString();
    duration = json['duration']?.toInt();
    startSeconds = json['startSeconds']?.toInt();
    endSeconds = json['endSeconds']?.toInt();
    firstImageUrl = json['firstImageUrl']?.toString();
  if (json['lines'] != null) {
  final v = json['lines'];
  final arr0 = <String>[];
  v.forEach((v) {
  arr0.add(v.toString());
  });
    lines = arr0;
    }
    locked = json['locked'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['type'] = type;
    data['contentId'] = contentId;
    data['semanticId'] = semanticId;
    data['videoUrl'] = videoUrl;
    data['videoKey'] = videoKey;
    data['duration'] = duration;
    data['startSeconds'] = startSeconds;
    data['endSeconds'] = endSeconds;
    data['firstImageUrl'] = firstImageUrl;
    if (lines != null) {
      final v = lines;
      final arr0 = [];
  v!.forEach((v) {
  arr0.add(v);
  });
      data['lines'] = arr0;
    }
    data['locked'] = locked;
    return data;
  }
}


///
/// Code generated by jsonToDartModel https://ashamp.github.io/jsonToDartModel/
///
class ArticleEntityRelationImage {
/*
{
  "uid": 5373522,
  "type": "EN_REVEAL",
  "contentId": 1220,
  "semanticId": 0,
  "imageKey": "knowledge/semantic/7691DF0F6AFFE6D6BD4B07E541B5EABC.webp",
  "imageUrl": "https://img.timelywise.cn/knowledge/semantic/7691DF0F6AFFE6D6BD4B07E541B5EABC.webp?auth_key=1772268188-2hpb9mqqq1x9-0-a7412ff036b2717675f404672521a7a0",
  "locked": null
} 
*/

  int? uid;
  String? type;
  int? contentId;
  int? semanticId;
  String? imageKey;
  String? imageUrl;
  bool? locked;

  ArticleEntityRelationImage({
    this.uid,
    this.type,
    this.contentId,
    this.semanticId,
    this.imageKey,
    this.imageUrl,
    this.locked,
  });
  ArticleEntityRelationImage.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    type = json['type']?.toString();
    contentId = json['contentId']?.toInt();
    semanticId = json['semanticId']?.toInt();
    imageKey = json['imageKey']?.toString();
    imageUrl = json['imageUrl']?.toString();
    locked = json['locked'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['type'] = type;
    data['contentId'] = contentId;
    data['semanticId'] = semanticId;
    data['imageKey'] = imageKey;
    data['imageUrl'] = imageUrl;
    data['locked'] = locked;
    return data;
  }
}
