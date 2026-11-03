import 'package:flutter/material.dart';
import 'package:langwise/common/entities/card_public_entity.dart';

import '../zhenxie_composition_instances/models/zhenxie_composition_instances_models.dart';
import '../zhenxie_composition_stages/models/zhenxie_composition_stages_models.dart';
import '../zhenxie_composition_writing/models/zhenxie_composition_writing_models.dart';

class StageCardSlotData {
  final int? order;
  final String? beatNid;
  final String? paragraphTypeNid;
  final Map<String, dynamic>? paragraphType;
  final List<LanguageText> paragraphTypeName;
  final String? fill;

  const StageCardSlotData({
    this.order,
    this.beatNid,
    this.paragraphTypeNid,
    this.paragraphType,
    this.paragraphTypeName = const <LanguageText>[],
    this.fill,
  });

  factory StageCardSlotData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? paragraphType = json['paragraphType'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['paragraphType'] as Map<String, dynamic>)
        : null;
    final List<LanguageText> paragraphTypeName = _parseLanguageTexts(
      json['paragraphTypeName'] is List<dynamic> ? json['paragraphTypeName'] : paragraphType?['name'],
    );
    return StageCardSlotData(
      order: (json['order'] as num?)?.toInt(),
      beatNid: json['beatNid']?.toString(),
      paragraphTypeNid: json['paragraphTypeNid']?.toString(),
      paragraphType: paragraphType,
      paragraphTypeName: paragraphTypeName,
      fill: json['fill']?.toString(),
    );
  }

  CompositionStageSlotModel toCompositionStageSlotModel() {
    return CompositionStageSlotModel(
      order: order,
      beatNid: beatNid,
      paragraphTypeNid: paragraphTypeNid,
      paragraphTypeName: paragraphTypeName,
      fill: fill,
    );
  }

  Map<String, dynamic> toJson() => {
        'order': order,
        'beatNid': beatNid,
        'paragraphTypeNid': paragraphTypeNid,
        'paragraphType': paragraphType,
        'paragraphTypeName': paragraphTypeName.map((item) => item.toJson()).toList(),
        'fill': fill,
      };
}

class StageCardData {
  String? nid;
  String? cover;
  String? coverUrl;
  String? coverMd5;
  String? compositionBlueprintNid;
  String? genreNid;
  Map<String, dynamic>? compositionBlueprint;
  CardContentDifficulty? difficulty;
  String? answerKind;
  int? answerMinCount;
  int? answerMaxCount;
  bool? lockBlueprintTab;
  bool? lockExemplarView;
  List<StageCardSlotData> slots;
  String? headFill;
  String? tailFill;
  int? order;
  List<String> milestones;
  List<dynamic> milestoneList;
  List<LanguageText> name;
  List<LanguageText> description;
  bool? system;
  bool? enabled;
  int? learnedCount;
  int? taskCount;
  bool? hasHead;
  bool? hasTail;
  List<LanguageText> headName;
  List<LanguageText> tailName;
  String? genreLabel;
  Color? genreColorValue;

  StageCardData({
    this.nid,
    this.cover,
    this.coverUrl,
    this.coverMd5,
    this.compositionBlueprintNid,
    this.genreNid,
    this.compositionBlueprint,
    this.difficulty,
    this.answerKind,
    this.answerMinCount,
    this.answerMaxCount,
    this.lockBlueprintTab,
    this.lockExemplarView,
    this.slots = const <StageCardSlotData>[],
    this.headFill,
    this.tailFill,
    this.order,
    this.milestones = const <String>[],
    this.milestoneList = const <dynamic>[],
    this.name = const <LanguageText>[],
    this.description = const <LanguageText>[],
    this.system,
    this.enabled,
    this.learnedCount,
    this.taskCount,
    this.hasHead,
    this.hasTail,
    this.headName = const <LanguageText>[],
    this.tailName = const <LanguageText>[],
    this.genreLabel,
    this.genreColorValue,
  });

  factory StageCardData.fromJson(
    Map<String, dynamic> json, {
    String? coverUrl,
    String? genreLabel,
    Color? genreColorValue,
  }) {
    final Map<String, dynamic>? compositionBlueprint = json['compositionBlueprint'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['compositionBlueprint'] as Map<String, dynamic>)
        : null;
    final Map<String, dynamic>? frame = compositionBlueprint?['frame'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(compositionBlueprint!['frame'] as Map<String, dynamic>)
        : null;
    return StageCardData(
      nid: json['nid']?.toString(),
      cover: json['cover']?.toString(),
      coverUrl: coverUrl ?? json['coverUrl']?.toString(),
      coverMd5: json['coverMd5']?.toString(),
      compositionBlueprintNid: json['compositionBlueprintNid']?.toString(),
      genreNid: json['genreNid']?.toString(),
      compositionBlueprint: compositionBlueprint,
      difficulty: json['difficulty'] is Map<String, dynamic> ? CardContentDifficulty.fromJson(json['difficulty']) : null,
      answerKind: json['answerKind']?.toString(),
      answerMinCount: (json['answerMinCount'] as num?)?.toInt(),
      answerMaxCount: (json['answerMaxCount'] as num?)?.toInt(),
      lockBlueprintTab: json['lockBlueprintTab'] as bool?,
      lockExemplarView: json['lockExemplarView'] as bool?,
      slots: (json['slots'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(StageCardSlotData.fromJson)
          .toList(),
      headFill: json['headFill']?.toString(),
      tailFill: json['tailFill']?.toString(),
      order: (json['order'] as num?)?.toInt(),
      milestones: (json['milestones'] as List<dynamic>? ?? const <dynamic>[]).map((item) => item.toString()).toList(),
      milestoneList: json['milestoneList'] is List<dynamic> ? List<dynamic>.from(json['milestoneList']) : const <dynamic>[],
      name: _parseLanguageTexts(json['name']),
      description: _parseLanguageTexts(json['description']),
      system: json['system'] as bool?,
      enabled: json['enabled'] as bool?,
      learnedCount: (json['learnedCount'] as num?)?.toInt(),
      taskCount: (json['taskCount'] as num?)?.toInt(),
      hasHead: (json['hasHead'] as bool?) ?? (frame?['hasHead'] as bool?),
      hasTail: (json['hasTail'] as bool?) ?? (frame?['hasTail'] as bool?),
      headName: _parseLanguageTexts(json['headName'] ?? frame?['headName']),
      tailName: _parseLanguageTexts(json['tailName'] ?? frame?['tailName']),
      genreLabel: genreLabel,
      genreColorValue: genreColorValue,
    );
  }

  factory StageCardData.fromCompositionStageModel(
    CompositionStageModel stage, {
    String? coverUrl,
    String? genreLabel,
    Color? genreColorValue,
  }) {
    return StageCardData.fromJson(
      stage.toJson(),
      coverUrl: coverUrl,
      genreLabel: genreLabel,
      genreColorValue: genreColorValue,
    );
  }

  CompositionStageModel toCompositionStageModel() {
    return CompositionStageModel(
      nid: nid,
      cover: cover,
      coverUrl: coverUrl,
      coverMd5: coverMd5,
      compositionBlueprintNid: compositionBlueprintNid,
      genreNid: genreNid,
      compositionBlueprint: compositionBlueprint == null ? null : CompositionBlueprintModel.fromJson(compositionBlueprint!),
      difficulty: difficulty,
      answerKind: answerKind,
      answerMinCount: answerMinCount,
      answerMaxCount: answerMaxCount,
      lockBlueprintTab: lockBlueprintTab,
      lockExemplarView: lockExemplarView,
      slots: slots.map((item) => item.toCompositionStageSlotModel()).toList(),
      headFill: headFill,
      tailFill: tailFill,
      order: order,
      milestones: milestones,
      milestoneList: const <CompositionStageMilestoneLiteModel>[],
      name: name,
      description: description,
      system: system,
      enabled: enabled,
      learnedCount: learnedCount,
      taskCount: taskCount,
      hasHead: hasHead,
      hasTail: hasTail,
      headName: headName,
      tailName: tailName,
    );
  }

  Map<String, dynamic> toJson() => {
        'nid': nid,
        'cover': cover,
        'coverUrl': coverUrl,
        'coverMd5': coverMd5,
        'compositionBlueprintNid': compositionBlueprintNid,
        'genreNid': genreNid,
        'compositionBlueprint': compositionBlueprint,
        'difficulty': difficulty?.toJson(),
        'answerKind': answerKind,
        'answerMinCount': answerMinCount,
        'answerMaxCount': answerMaxCount,
        'lockBlueprintTab': lockBlueprintTab,
        'lockExemplarView': lockExemplarView,
        'slots': slots.map((item) => item.toJson()).toList(),
        'headFill': headFill,
        'tailFill': tailFill,
        'order': order,
        'milestones': milestones,
        'milestoneList': milestoneList,
        'name': name.map((item) => item.toJson()).toList(),
        'description': description.map((item) => item.toJson()).toList(),
        'system': system,
        'enabled': enabled,
        'learnedCount': learnedCount,
        'taskCount': taskCount,
        'hasHead': hasHead,
        'hasTail': hasTail,
        'headName': headName.map((item) => item.toJson()).toList(),
        'tailName': tailName.map((item) => item.toJson()).toList(),
        'genreLabel': genreLabel,
      };
}

class ContentCardData {
  int? uid;
  int? taskId;
  int? compositionId;
  int? givenCompositionId;
  num? order;
  String? cover;
  String? coverUrl;
  String? coverMd5;
  List<LanguageText> name;
  List<LanguageText> title;
  List<LanguageText> stem;
  String? stageNid;
  StageCardData? stage;
  Map<String, dynamic>? blueprint;
  String? compositionBlueprintNid;
  String? compositionFamilyNid;
  String? genreNid;
  CardContentDifficulty? difficulty;
  int? exemplarCompositionId;
  String? role;
  String? status;
  String? access;
  String? updated;
  CompositionTaskMemberWritingStatusModel? memberWritingStatus;
  String? answerKind;
  String? answerKindLable;
  int? answerMinCount;
  int? answerMaxCount;
  int? answerCount;
  Map<String, dynamic>? imageReview;
  bool? inCourse;
  int? inCourseCnt;
  List<dynamic> audioList;
  List<String> stemImages;
  List<String> stemImageUrls;
  List<String> stemAudios;
  List<String> stemAudioUrls;
  List<String> stemVideos;
  List<String> stemVideoUrls;
  List<dynamic> knowledgePoints;
  List<int> grammarTargetUids;
  String? genreLabel;
  Color? genreColorValue;

  /// 是否上架
  bool get isNormal => access == "NORMAL";

  ContentCardData({
    this.uid,
    this.taskId,
    this.compositionId,
    this.givenCompositionId,
    this.order,
    this.cover,
    this.coverUrl,
    this.coverMd5,
    this.name = const <LanguageText>[],
    this.title = const <LanguageText>[],
    this.stem = const <LanguageText>[],
    this.stageNid,
    this.stage,
    this.blueprint,
    this.compositionBlueprintNid,
    this.compositionFamilyNid,
    this.genreNid,
    this.difficulty,
    this.exemplarCompositionId,
    this.role,
    this.status,
    this.access,
    this.updated,
    this.memberWritingStatus,
    this.answerKind,
    this.answerKindLable,
    this.answerMinCount,
    this.answerMaxCount,
    this.answerCount,
    this.imageReview,
    this.inCourse,
    this.inCourseCnt,
    this.audioList = const <dynamic>[],
    this.stemImages = const <String>[],
    this.stemImageUrls = const <String>[],
    this.stemAudios = const <String>[],
    this.stemAudioUrls = const <String>[],
    this.stemVideos = const <String>[],
    this.stemVideoUrls = const <String>[],
    this.knowledgePoints = const <dynamic>[],
    this.grammarTargetUids = const <int>[],
    this.genreLabel,
    this.genreColorValue,
  });

  factory ContentCardData.fromJson(
    Map<String, dynamic> json, {
    String? coverUrl,
    String? genreLabel,
    Color? genreColorValue,
  }) {
    return ContentCardData(
      uid: (json['uid'] as num?)?.toInt(),
      taskId: (json['taskId'] as num?)?.toInt(),
      compositionId: (json['compositionId'] as num?)?.toInt(),
      givenCompositionId: (json['givenCompositionId'] as num?)?.toInt(),
      order: json['order'] as num?,
      cover: json['cover']?.toString(),
      coverUrl: coverUrl ?? json['coverUrl']?.toString(),
      coverMd5: json['coverMd5']?.toString(),
      name: _parseLanguageTexts(json['name']),
      title: _parseLanguageTexts(json['title']),
      stem: _parseLanguageTexts(json['stem']),
      stageNid: json['stageNid']?.toString(),
      stage: json['stage'] is Map<String, dynamic> ? StageCardData.fromJson(json['stage']) : null,
      blueprint: json['blueprint'] is Map<String, dynamic> ? Map<String, dynamic>.from(json['blueprint'] as Map<String, dynamic>) : null,
      compositionBlueprintNid: json['compositionBlueprintNid']?.toString(),
      compositionFamilyNid: json['compositionFamilyNid']?.toString(),
      genreNid: json['genreNid']?.toString(),
      difficulty: json['difficulty'] is Map<String, dynamic> ? CardContentDifficulty.fromJson(json['difficulty']) : null,
      exemplarCompositionId: (json['exemplarCompositionId'] as num?)?.toInt(),
      role: json['role']?.toString(),
      status: json['status']?.toString(),
      access: json['access']?.toString(),
      updated: json['updated']?.toString(),
      memberWritingStatus: json['memberWritingStatus'] is Map<String, dynamic>
          ? CompositionTaskMemberWritingStatusModel.fromJson(json['memberWritingStatus'])
          : null,
      answerKind: json['answerKind']?.toString(),
      answerKindLable: json['answerKindLable']?.toString(),
      answerMinCount: (json['answerMinCount'] as num?)?.toInt(),
      answerMaxCount: (json['answerMaxCount'] as num?)?.toInt(),
      answerCount: (json['answerCount'] as num?)?.toInt(),
      imageReview: json['imageReview'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['imageReview'] as Map<String, dynamic>)
          : null,
      inCourse: json['in_course'] as bool?,
      inCourseCnt: (json['in_course_cnt'] as num?)?.toInt(),
      audioList: json['audioList'] is List<dynamic> ? List<dynamic>.from(json['audioList']) : const <dynamic>[],
      stemImages: _parseStringList(json['stemImages']),
      stemImageUrls: _parseStringList(json['stemImageUrls']),
      stemAudios: _parseStringList(json['stemAudios']),
      stemAudioUrls: _parseStringList(json['stemAudioUrls']),
      stemVideos: _parseStringList(json['stemVideos']),
      stemVideoUrls: _parseStringList(json['stemVideoUrls']),
      knowledgePoints: json['knowledgePoints'] is List<dynamic> ? List<dynamic>.from(json['knowledgePoints']) : const <dynamic>[],
      grammarTargetUids: (json['grammarTargetUids'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<num>()
          .map((item) => item.toInt())
          .toList(),
      genreLabel: genreLabel,
      genreColorValue: genreColorValue,
    );
  }

  factory ContentCardData.fromCompositionTaskModel(
    CompositionTaskModel task, {
    String? coverUrl,
    String? genreLabel,
    Color? genreColorValue,
  }) {
    return ContentCardData.fromJson(
      task.toJson(),
      coverUrl: coverUrl,
      genreLabel: genreLabel,
      genreColorValue: genreColorValue,
    );
  }

  factory ContentCardData.fromCompositionInstanceModel(
    CompositionInstanceModel instance, {
    String? coverUrl,
    String? genreLabel,
    Color? genreColorValue,
  }) {
    return ContentCardData.fromJson(
      instance.toJson(),
      coverUrl: coverUrl,
      genreLabel: genreLabel,
      genreColorValue: genreColorValue,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'taskId': taskId,
        'compositionId': compositionId,
        'givenCompositionId': givenCompositionId,
        'order': order,
        'cover': cover,
        'coverUrl': coverUrl,
        'coverMd5': coverMd5,
        'name': name.map((item) => item.toJson()).toList(),
        'title': title.map((item) => item.toJson()).toList(),
        'stem': stem.map((item) => item.toJson()).toList(),
        'stageNid': stageNid,
        'stage': stage?.toJson(),
        'blueprint': blueprint,
        'compositionBlueprintNid': compositionBlueprintNid,
        'compositionFamilyNid': compositionFamilyNid,
        'genreNid': genreNid,
        'difficulty': difficulty?.toJson(),
        'exemplarCompositionId': exemplarCompositionId,
        'role': role,
        'status': status,
        'access': access,
        'updated': updated,
        'memberWritingStatus': memberWritingStatus?.toJson(),
        'answerKind': answerKind,
        'answerKindLable': answerKindLable,
        'answerMinCount': answerMinCount,
        'answerMaxCount': answerMaxCount,
        'answerCount': answerCount,
        'imageReview': imageReview,
        'in_course': inCourse,
        'in_course_cnt': inCourseCnt,
        'audioList': audioList,
        'stemImages': stemImages,
        'stemImageUrls': stemImageUrls,
        'stemAudios': stemAudios,
        'stemAudioUrls': stemAudioUrls,
        'stemVideos': stemVideos,
        'stemVideoUrls': stemVideoUrls,
        'knowledgePoints': knowledgePoints,
        'grammarTargetUids': grammarTargetUids,
        'genreLabel': genreLabel,
      };
}

List<LanguageText> _parseLanguageTexts(dynamic values) {
  return (values as List<dynamic>? ?? const <dynamic>[])
      .whereType<Map<String, dynamic>>()
      .map(LanguageText.fromJson)
      .toList();
}

List<String> _parseStringList(dynamic values) {
  return (values as List<dynamic>? ?? const <dynamic>[]).map((item) => item.toString()).toList();
}
