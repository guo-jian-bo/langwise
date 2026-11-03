import '../../../../../common/entities/entities.dart';
import '../../zhenxie_composition_stages/models/zhenxie_composition_stages_models.dart';

class CompositionInstanceImageReviewModel {
  ModuleImageInfoEntity? image;
  List<int>? imageTaskIds;

  CompositionInstanceImageReviewModel({this.image, this.imageTaskIds});

  factory CompositionInstanceImageReviewModel.fromJson(Map<String, dynamic> json) {
    return CompositionInstanceImageReviewModel(
      image: json['image'] is Map<String, dynamic>
          ? ModuleImageInfoEntity.fromJson(json['image'])
          : null,
      imageTaskIds: (json['imageTaskIds'] as List<dynamic>? ?? <dynamic>[])
          .whereType<num>()
          .map((item) => item.toInt())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'image': image?.toJson(),
      'imageTaskIds': imageTaskIds,
    };
  }
}

class CompositionInstanceModel {
  int? uid;
  String? cover;
  String? coverUrl;
  String? coverMd5;
  CompositionInstanceImageReviewModel? imageReview;
  List<LanguageText> title;
  String? compositionBlueprintNid;
  CompositionBlueprintModel? blueprint;
  String? compositionFamilyNid;
  String? genreNid;
  CardContentDifficulty? difficulty;
  int? taskId;
  String? stageNid;
  CompositionStageModel? stage;
  String? access;
  bool? inCourse;
  int? inCourseCnt;
  String? updated;
  List<EnKnowledgeEntityAudioList?>? audioList;

  CompositionInstanceModel({
    this.uid,
    this.cover,
    this.coverUrl,
    this.coverMd5,
    this.imageReview,
    this.title = const <LanguageText>[],
    this.compositionBlueprintNid,
    this.blueprint,
    this.compositionFamilyNid,
    this.genreNid,
    this.difficulty,
    this.taskId,
    this.stageNid,
    this.stage,
    this.access,
    this.inCourse,
    this.inCourseCnt,
    this.updated,
    this.audioList,
  });

  factory CompositionInstanceModel.fromJson(Map<String, dynamic> json) {
    return CompositionInstanceModel(
      uid: json['uid']?.toInt(),
      cover: json['cover']?.toString(),
      coverUrl: json['coverUrl']?.toString(),
      coverMd5: json['coverMd5']?.toString(),
      imageReview: json['imageReview'] is Map<String, dynamic>
          ? CompositionInstanceImageReviewModel.fromJson(json['imageReview'])
          : null,
      title: (json['title'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LanguageText.fromJson)
          .toList(),
      compositionBlueprintNid: json['compositionBlueprintNid']?.toString(),
      blueprint: json['blueprint'] is Map<String, dynamic>
          ? CompositionBlueprintModel.fromJson(json['blueprint'])
          : null,
      compositionFamilyNid: json['compositionFamilyNid']?.toString(),
      genreNid: json['genreNid']?.toString(),
      difficulty: json['difficulty'] is Map<String, dynamic>
          ? CardContentDifficulty.fromJson(json['difficulty'])
          : null,
      taskId: json['taskId']?.toInt(),
      stageNid: json['stageNid']?.toString(),
      stage: json['stage'] is Map<String, dynamic>
          ? CompositionStageModel.fromJson(json['stage'])
          : null,
      access: json['access']?.toString(),
      inCourse: json['in_course'] == null ? null : json['in_course'] == true,
      inCourseCnt: json['in_course_cnt']?.toInt(),
      updated: json['updated']?.toString(),
      audioList: (json['audioList'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => EnKnowledgeEntityAudioList.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'cover': cover,
      'coverUrl': coverUrl,
      'coverMd5': coverMd5,
      'imageReview': imageReview?.toJson(),
      'title': title.map((item) => item.toJson()).toList(),
      'compositionBlueprintNid': compositionBlueprintNid,
      'blueprint': blueprint?.toJson(),
      'compositionFamilyNid': compositionFamilyNid,
      'genreNid': genreNid,
      'difficulty': difficulty?.toJson(),
      'taskId': taskId,
      'stageNid': stageNid,
      'stage': stage?.toJson(),
      'access': access,
      'in_course': inCourse,
      'in_course_cnt': inCourseCnt,
      'updated': updated,
      'audioList': audioList?.map((item) => item?.toJson()).toList(),
    };
  }
}
