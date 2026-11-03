import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_data.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/widgets/data_table_widget/data_table.dart';
import 'package:langwise/utils/utils.dart';

import '../public_controller/config_controller.dart';

class NewUnitResponseEntity<T> extends Dessert with JsonSerializableMixin {
  final int? moduleId;
  final String? name;
  final String? description;
  final List<int>? lessonIds;
  final List<T>? lessonList;
  final List<T>? lessonDTOList;
  final List<int>? templateIds;
  final String? cefr;
  final int? level;
  final String? scope;
  final String? scopeName;
  final String? vendor;
  final String? vendorName;
  final String? access;
  final String? coverUrl;
  final num? order;
  final String? language;
  final String? updated;
  final String? created;
  final bool? planned;
  final bool? unitPlan;
  final bool? sentenceGenerated;
  final int? grammarAnalyzed;
  final int? songGenerateType;
  final int? remixTextGenerateType;
  final List<UnitLessonPlanStatisticEntity>? lessonPlanList;
  final UnitResourceStatisticEntity? articleStatistic;
  final UnitResourceStatisticEntity? songStatistic;
  final UnitGrammarStatisticEntity? grammarStatistic;
  final CourseUnitWritingPipelineEntity? writingPipeline;
  final CourseUnitWritingTaskCardEntity? writingTaskCard;
  final List<UnitKnowledgeTypeCountEntity>? knowledgeTypeCountList;

  // 知识点数量
  final int? knowledgeCount;

  // // 难度等级
  final int? difficultyLevel;

  final NewUnitResponseEntityDifficulty? difficulty;

  /// 单元封面待审核数量
  int coverReviewImageCount;

  NewUnitResponseEntity(
      {this.moduleId,
      this.name,
      this.description,
      this.lessonIds,
      this.lessonList,
      this.lessonDTOList,
      this.templateIds,
      this.cefr,
      this.level,
      this.scope,
      this.scopeName,
      this.vendor,
      this.vendorName,
      this.access,
      this.coverUrl,
      this.order,
      this.language,
      this.updated,
      this.created,
      this.planned,
      this.unitPlan,
      this.sentenceGenerated,
      this.grammarAnalyzed,
      this.songGenerateType,
      this.remixTextGenerateType,
      this.lessonPlanList,
      this.articleStatistic,
      this.songStatistic,
      this.grammarStatistic,
      this.writingPipeline,
      this.writingTaskCard,
      this.knowledgeTypeCountList,
      required int? uid,
      this.knowledgeCount,
      this.difficultyLevel,
      this.difficulty,
      this.coverReviewImageCount = 0,
    })
      : globalKey = GlobalKey(debugLabel: uid.toString()),
        super(uid: uid ?? 0);

  final GlobalKey globalKey;

  factory NewUnitResponseEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    List<T>? lessonList = [];
    if (json['lessonList'] != null) {
      if (fromJson != null) {
        lessonList = json['lessonList'].map((e) => fromJson(e)).cast<T>().toList();
      } else {
        lessonList = json['lessonList'] as List<T>?;
      }
    }

    List<T>? lessonDTOList = [];
    if (json['lessonDTOList'] != null) {
      if (fromJson != null) {
        lessonDTOList = json['lessonDTOList'].map((e) => fromJson(e)).cast<T>().toList();
      } else {
        lessonDTOList = json['lessonDTOList'] as List<T>?;
      }
    }

    return NewUnitResponseEntity(
      uid: json["uid"],
      moduleId: json["moduleId"],
      name: json["name"],
      description: json["description"],
      lessonIds: json["lessonIds"] != null ? List<int>.from(json["lessonIds"]) : null,
      lessonList: lessonList,
      lessonDTOList: lessonDTOList,
      templateIds: json["templateIds"] != null ? List<int>.from(json["templateIds"]) : null,
      cefr: json["cefr"],
      level: json["level"],
      scope: json["scope"],
      scopeName: json["scopeName"],
      vendor: json["vendor"],
      vendorName: json["vendorName"],
      access: json["access"],
      coverUrl: json["coverUrl"],
      order: json["order"],
      language: json["language"],
      updated: json["updated"],
      created: json["created"],
      planned: json["planned"],
      unitPlan: json["unitPlan"],
      sentenceGenerated: json["sentenceGenerated"],
      grammarAnalyzed: json["grammarAnalyzed"],
      songGenerateType: json["songGenerateType"],
      remixTextGenerateType: json["remixTextGenerateType"],
      lessonPlanList: json["lessonPlanList"] != null
          ? (json["lessonPlanList"] as List)
              .map((e) => UnitLessonPlanStatisticEntity.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,
      articleStatistic: json["articleStatistic"] != null
          ? UnitResourceStatisticEntity.fromJson(Map<String, dynamic>.from(json["articleStatistic"]))
          : null,
      songStatistic: json["songStatistic"] != null
          ? UnitResourceStatisticEntity.fromJson(Map<String, dynamic>.from(json["songStatistic"]))
          : null,
      grammarStatistic: json["grammarStatistic"] != null
          ? UnitGrammarStatisticEntity.fromJson(Map<String, dynamic>.from(json["grammarStatistic"]))
          : null,
      writingPipeline: json["writingPipeline"] != null
          ? CourseUnitWritingPipelineEntity.fromJson(Map<String, dynamic>.from(json["writingPipeline"]))
          : null,
      writingTaskCard: json["writingTaskCard"] != null
          ? CourseUnitWritingTaskCardEntity.fromJson(Map<String, dynamic>.from(json["writingTaskCard"]))
          : null,
      knowledgeTypeCountList: json["knowledgeTypeCountList"] != null
          ? (json["knowledgeTypeCountList"] as List)
              .map((e) => UnitKnowledgeTypeCountEntity.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,
      knowledgeCount: json["knowledgeCount"],
      difficultyLevel: json["difficultyLevel"],
      difficulty: json['difficulty'] != null ? NewUnitResponseEntityDifficulty.fromJson(json['difficulty']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        "uid": uid,
        "moduleId": moduleId,
        "name": name,
        "description": description,
        "lessonIds": lessonIds,
        "templateIds": templateIds,
        "cefr": cefr,
        "level": level,
        "scope": scope,
        "scopeName": scopeName,
        "vendor": vendor,
        "vendorName": vendorName,
        "access": access,
        "coverUrl": coverUrl,
        "order": order,
        "updated": updated,
        "planned": planned,
        "unitPlan": unitPlan,
        "sentenceGenerated": sentenceGenerated,
        "grammarAnalyzed": grammarAnalyzed,
        "songGenerateType": songGenerateType,
        "remixTextGenerateType": remixTextGenerateType,
        "lessonPlanList": lessonPlanList?.map((e) => e.toJson()).toList(),
        "articleStatistic": articleStatistic?.toJson(),
        "songStatistic": songStatistic?.toJson(),
        "grammarStatistic": grammarStatistic?.toJson(),
        "writingPipeline": writingPipeline?.toJson(),
        "writingTaskCard": writingTaskCard?.toJson(),
        "knowledgeTypeCountList": knowledgeTypeCountList?.map((e) => e.toJson()).toList(),
        "created": created,
        "knowledgeCount": knowledgeCount,
        "difficultyLevel": difficultyLevel,
      };

  // 更新时间格式化
  String get newUpdate {
    if (updated == null) return '';
    return DateUtil.formatDateStr(updated!, format: "yyyy/MM/dd");
  }

  // 创建时间
  String get newCreate {
    if (created == null) {
      return '';
    }

    return DateUtil.formatDateStr(created!, format: "yyyy/MM/dd");
  }

  // 语言显示名称
  String get newLanguage {
    try {
      return CommonUtil.language.map((e) => e[language]).firstWhere((e) => e != null, orElse: () => null) ?? '';
    } catch (e) {
      if (kDebugMode) print('语言转换异常: $e');
      return '';
    }
  }

  List<DifficultieEntity> getConfig() {
    final int selectLanguageIndex = StaticData.getLanguageIndex(language) ?? 0;
    final ConfigEntity configData = Get.find<ConfigController>().appConfig.value;
    final String languageCode = StaticData.languageList[selectLanguageIndex].value;
    final List<DifficultieEntity>? diffList = DifficultieUtils.getDifficultieList(configData, languageCode);
    if (diffList == null) return [];
    return diffList;
  }

  // 难度等级显示名称
  // String get newDifficulty {
  //   String difficulty = "";
  //   try {
  //     final List<DifficultieEntity> difficultieList = getConfig();
  //     if (difficultieList.isNotEmpty) {
  //       if (difficultyLevel != null) {
  //         difficulty = difficultieList[difficultyLevel!].name?.text ?? '';
  //       }
  //     }
  //   } catch (e) {
  //     if (kDebugMode) print('难度等级显示名称转换异常: $e');
  //   }
  //   return difficulty;
  // }

  int? get minDifficulty => difficulty?.min;

  int? get maxDifficulty => difficulty?.max;

  // 上下架状态
  String get newAccess => StaticData.getOnOffShelfName(access) ?? '';

  // 是否上架
  bool get isAccess => StaticData.isOnOffShelfNormal(access);

  // 单元是否包含知识点
  bool get hasKnowledgeCount => knowledgeCount != null && knowledgeCount! > 0;

  NewUnitResponseEntity<T> copyWith(
      {int? moduleId,
      String? name,
      String? description,
      List<int>? lessonIds,
      List<T>? lessonList,
      List<T>? lessonDTOList,
      List<int>? templateIds,
      String? cefr,
      int? level,
      String? scope,
      String? scopeName,
      String? vendor,
      String? vendorName,
      String? access,
      num? order,
      String? language,
      String? updated,
      bool? planned,
      bool? unitPlan,
      bool? sentenceGenerated,
      int? grammarAnalyzed,
      String? created,
      int? uid,
      int? difficultyLevel,
      NewUnitResponseEntityDifficulty? difficulty,
      List<UnitLessonPlanStatisticEntity>? lessonPlanList,
      UnitResourceStatisticEntity? articleStatistic,
      UnitResourceStatisticEntity? songStatistic,
      UnitGrammarStatisticEntity? grammarStatistic,
      CourseUnitWritingPipelineEntity? writingPipeline,
      CourseUnitWritingTaskCardEntity? writingTaskCard,
      List<UnitKnowledgeTypeCountEntity>? knowledgeTypeCountList}) {
    return NewUnitResponseEntity<T>(
        moduleId: moduleId ?? this.moduleId,
        name: name ?? this.name,
        description: description ?? this.description,
        lessonIds: lessonIds ?? this.lessonIds,
        lessonList: lessonList ?? this.lessonList,
        lessonDTOList: lessonDTOList ?? this.lessonDTOList,
        templateIds: templateIds ?? this.templateIds,
        cefr: cefr ?? this.cefr,
        level: level ?? this.level,
        scope: scope ?? this.scope,
        scopeName: scopeName ?? this.scopeName,
        vendor: vendor ?? this.vendor,
        vendorName: vendorName ?? this.vendorName,
        access: access ?? this.access,
        order: order ?? this.order,
        language: language ?? this.language,
        updated: updated ?? this.updated,
        planned: planned ?? this.planned,
        unitPlan: unitPlan ?? this.unitPlan,
        sentenceGenerated: sentenceGenerated ?? this.sentenceGenerated,
        grammarAnalyzed: grammarAnalyzed ?? this.grammarAnalyzed,
        created: created ?? this.created,
        lessonPlanList: lessonPlanList ?? this.lessonPlanList,
        articleStatistic: articleStatistic ?? this.articleStatistic,
        songStatistic: songStatistic ?? this.songStatistic,
        grammarStatistic: grammarStatistic ?? this.grammarStatistic,
        writingPipeline: writingPipeline ?? this.writingPipeline,
        writingTaskCard: writingTaskCard ?? this.writingTaskCard,
        knowledgeTypeCountList: knowledgeTypeCountList ?? this.knowledgeTypeCountList,
        uid: uid ?? this.uid,
        difficultyLevel: difficultyLevel ?? this.difficultyLevel,
        difficulty: difficulty ?? this.difficulty);
  }

  @override
  String toString() {
    return 'UnitResponseEntity('
        'uid: $uid, '
        'moduleId: $moduleId, '
        'name: $name, '
        'description: $description, '
        'lessonIds: $lessonIds, '
        'lessonList: $lessonList, '
        'templateIds: $templateIds, '
        'cefr: $cefr, '
        'level: $level, '
        'scope: $scope, '
        'scopeName: $scopeName, '
        'vendor: $vendor, '
        'vendorName: $vendorName, '
        'access: $access, '
        'order: $order, '
        'language: $language, '
        'updated: $updated, '
        'planned: $planned, '
        'unitPlan: $unitPlan, '
        'sentenceGenerated: $sentenceGenerated, '
        'grammarAnalyzed: $grammarAnalyzed, '
        'created: $created, difficultyLevel: $difficultyLevel, difficulty: $difficulty)';
  }
}

class UnitLessonPlanStatisticEntity {
  final int? lessonId;
  final String? lessonName;
  final bool? lessonPlan;
  final bool? exercise;

  UnitLessonPlanStatisticEntity({
    this.lessonId,
    this.lessonName,
    this.lessonPlan,
    this.exercise,
  });

  factory UnitLessonPlanStatisticEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return UnitLessonPlanStatisticEntity(
      lessonId: json["lessonId"],
        lessonName: json["lessonName"],
      lessonPlan: json["lessonPlan"],
      exercise: json["exercise"],
    );
  }

  Map<String, dynamic> toJson() => {
        "lessonId": lessonId,
          "lessonName": lessonName,
        "lessonPlan": lessonPlan,
        "exercise": exercise,
      };
}

class UnitResourceStatisticEntity {
  final int? totalCount;
  final int? normalCount;

  UnitResourceStatisticEntity({
    this.totalCount,
    this.normalCount,
  });

  factory UnitResourceStatisticEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return UnitResourceStatisticEntity(
      totalCount: json["totalCount"],
      normalCount: json["normalCount"],
    );
  }

  Map<String, dynamic> toJson() => {
        "totalCount": totalCount,
        "normalCount": normalCount,
      };
}

class UnitGrammarStatisticEntity {
  final int? totalStepCount;
  final int? finishedStepCount;
  final bool? grammarAnalyze;
  final int? targetTotalCount;
  final int? candidateTargetCount;
  final int? sentenceTotalCount;
  final int? boundSentenceCount;

  UnitGrammarStatisticEntity({
    this.totalStepCount,
    this.finishedStepCount,
    this.grammarAnalyze,
    this.targetTotalCount,
    this.candidateTargetCount,
    this.sentenceTotalCount,
    this.boundSentenceCount,
  });

  factory UnitGrammarStatisticEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return UnitGrammarStatisticEntity(
      totalStepCount: json["totalStepCount"],
      finishedStepCount: json["finishedStepCount"],
      grammarAnalyze: json["grammarAnalyze"],
      targetTotalCount: json["targetTotalCount"],
      candidateTargetCount: json["candidateTargetCount"],
      sentenceTotalCount: json["sentenceTotalCount"],
      boundSentenceCount: json["boundSentenceCount"],
    );
  }

  Map<String, dynamic> toJson() => {
          "totalStepCount": totalStepCount,
          "finishedStepCount": finishedStepCount,
        "grammarAnalyze": grammarAnalyze,
        "targetTotalCount": targetTotalCount,
        "candidateTargetCount": candidateTargetCount,
        "sentenceTotalCount": sentenceTotalCount,
        "boundSentenceCount": boundSentenceCount,
      };
}

class CourseUnitWritingPipelineEntity {
  final int? taskCount;
  final int? compositionTaskCount;

  CourseUnitWritingPipelineEntity({
    this.taskCount,
    this.compositionTaskCount,
  });

  factory CourseUnitWritingPipelineEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingPipelineEntity(
      taskCount: json["taskCount"],
      compositionTaskCount: json["compositionTaskCount"],
    );
  }

  Map<String, dynamic> toJson() => {
        "taskCount": taskCount,
        "compositionTaskCount": compositionTaskCount,
      };
}

class CourseUnitWritingTaskCardEntity {
  final int? lessonId;
  final String? lessonName;
  final String? type;
  final String? title;
  final int? taskId;
  final String? stageNid;
  final List<LanguageText>? stageName;
  final List<LanguageText>? stem;
  final String? answerKind;
  final String? answerKindLable;
  final int? answerMinCount;
  final int? answerMaxCount;
  final String? cover;
  final String? coverUrl;
  final String? coverMd5;
  final int? taskCount;
  final int? compositionTaskCount;

  CourseUnitWritingTaskCardEntity({
    this.lessonId,
    this.lessonName,
    this.type,
    this.title,
    this.taskId,
    this.stageNid,
    this.stageName,
    this.stem,
    this.answerKind,
    this.answerKindLable,
    this.answerMinCount,
    this.answerMaxCount,
    this.cover,
    this.coverUrl,
    this.coverMd5,
    this.taskCount,
    this.compositionTaskCount,
  });

  factory CourseUnitWritingTaskCardEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingTaskCardEntity(
      lessonId: json["lessonId"],
      lessonName: json["lessonName"]?.toString(),
      type: json["type"],
      title: json["title"]?.toString(),
      taskId: json["taskId"],
      stageNid: json["stageNid"]?.toString(),
      stageName: json["stageName"] != null
          ? (json["stageName"] as List).map((e) => LanguageText.fromJson(Map<String, dynamic>.from(e))).toList()
          : null,
      stem: json["stem"] != null
          ? (json["stem"] as List).map((e) => LanguageText.fromJson(Map<String, dynamic>.from(e))).toList()
          : null,
      answerKind: json["answerKind"]?.toString(),
      answerKindLable: json["answerKindLable"]?.toString(),
      answerMinCount: json["answerMinCount"],
      answerMaxCount: json["answerMaxCount"],
      cover: json["cover"]?.toString(),
      coverUrl: json["coverUrl"]?.toString(),
      coverMd5: json["coverMd5"]?.toString(),
      taskCount: json["taskCount"],
      compositionTaskCount: json["compositionTaskCount"],
    );
  }

  Map<String, dynamic> toJson() => {
        "lessonId": lessonId,
        "lessonName": lessonName,
        "type": type,
        "title": title,
        "taskId": taskId,
        "stageNid": stageNid,
        "stageName": stageName?.map((e) => e.toJson()).toList(),
        "stem": stem?.map((e) => e.toJson()).toList(),
        "answerKind": answerKind,
        "answerKindLable": answerKindLable,
        "answerMinCount": answerMinCount,
        "answerMaxCount": answerMaxCount,
        "cover": cover,
        "coverUrl": coverUrl,
        "coverMd5": coverMd5,
        "taskCount": taskCount,
        "compositionTaskCount": compositionTaskCount,
      };
}


class CourseUnitWritingTaskListEntity {
  final int? unitId;
  final int? writingId;
  final int? taskCount;
  final int? compositionTaskCount;
  final List<ContentCardData>? taskList;

  CourseUnitWritingTaskListEntity({
    this.unitId,
    this.writingId,
    this.taskCount,
    this.compositionTaskCount,
    this.taskList,
  });

  factory CourseUnitWritingTaskListEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingTaskListEntity(
      unitId: json["unitId"],
      writingId: json["writingId"],
      taskCount: json["taskCount"],
      compositionTaskCount: json["compositionTaskCount"],
      taskList: json["taskList"] != null
          ? (json["taskList"] as List).map((e) => ContentCardData.fromJson(Map<String, dynamic>.from(e))).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "unitId": unitId,
        "writingId": writingId,
        "taskCount": taskCount,
        "compositionTaskCount": compositionTaskCount,
        "taskList": taskList?.map((e) => e.toJson()).toList(),
      };
}

class CourseUnitWritingTaskItemEntity {
  final int? uid;
  final int? taskId;
  final int? compositionId;
  final num? order;
  final String? cover;
  final String? coverUrl;
  final String? coverMd5;
  final List<LanguageText>? name;
  final List<LanguageText>? stem;
  final String? stageNid;
  final CourseUnitWritingTaskStageEntity? stage;
  final CourseUnitWritingTaskBlueprintEntity? blueprint;
  final String? genreNid;
  final int? exemplarCompositionId;
  final CardContentDifficulty? difficulty;
  final String? answerKind;
  final String? answerKindLable;
  final int? answerMinCount;
  final int? answerMaxCount;
  final String? status;
  final String? access;
  final String? updated;
  final int? answerCount;
  final List<String>? stemImages;
  final List<String>? stemImageUrls;
  final List<String>? stemAudios;
  final List<String>? stemAudioUrls;
  final List<String>? stemVideos;
  final List<String>? stemVideoUrls;
  final List<CourseUnitWritingKnowledgePointEntity>? knowledgePoints;
  final List<int>? grammarTargetUids;

  CourseUnitWritingTaskItemEntity({
    this.uid,
    this.taskId,
    this.compositionId,
    this.order,
    this.cover,
    this.coverUrl,
    this.coverMd5,
    this.name,
    this.stem,
    this.stageNid,
    this.stage,
    this.blueprint,
    this.genreNid,
    this.exemplarCompositionId,
    this.difficulty,
    this.answerKind,
    this.answerKindLable,
    this.answerMinCount,
    this.answerMaxCount,
    this.status,
    this.access,
    this.updated,
    this.answerCount,
    this.stemImages,
    this.stemImageUrls,
    this.stemAudios,
    this.stemAudioUrls,
    this.stemVideos,
    this.stemVideoUrls,
    this.knowledgePoints,
    this.grammarTargetUids,
  });

  factory CourseUnitWritingTaskItemEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingTaskItemEntity(
      uid: json["uid"],
      taskId: json["taskId"],
      compositionId: json["compositionId"],
      order: json["order"],
      cover: json["cover"]?.toString(),
      coverUrl: json["coverUrl"]?.toString(),
      coverMd5: json["coverMd5"]?.toString(),
      name: json["name"] != null ? (json["name"] as List).map((e) => LanguageText.fromJson(Map<String, dynamic>.from(e))).toList() : null,
      stem: json["stem"] != null ? (json["stem"] as List).map((e) => LanguageText.fromJson(Map<String, dynamic>.from(e))).toList() : null,
      stageNid: json["stageNid"]?.toString(),
      stage: json["stage"] is Map<String, dynamic> ? CourseUnitWritingTaskStageEntity.fromJson(json["stage"]) : null,
      blueprint: json["blueprint"] is Map<String, dynamic> ? CourseUnitWritingTaskBlueprintEntity.fromJson(json["blueprint"]) : null,
      genreNid: json["genreNid"]?.toString(),
      exemplarCompositionId: json["exemplarCompositionId"],
      difficulty: json["difficulty"] is Map<String, dynamic> ? CardContentDifficulty.fromJson(json["difficulty"]) : null,
      answerKind: json["answerKind"]?.toString(),
      answerKindLable: json["answerKindLable"]?.toString(),
      answerMinCount: json["answerMinCount"],
      answerMaxCount: json["answerMaxCount"],
      status: json["status"]?.toString(),
      access: json["access"]?.toString(),
      updated: json["updated"]?.toString(),
      answerCount: json["answerCount"],
      stemImages: json["stemImages"] != null ? List<String>.from(json["stemImages"]) : null,
      stemImageUrls: json["stemImageUrls"] != null ? List<String>.from(json["stemImageUrls"]) : null,
      stemAudios: json["stemAudios"] != null ? List<String>.from(json["stemAudios"]) : null,
      stemAudioUrls: json["stemAudioUrls"] != null ? List<String>.from(json["stemAudioUrls"]) : null,
      stemVideos: json["stemVideos"] != null ? List<String>.from(json["stemVideos"]) : null,
      stemVideoUrls: json["stemVideoUrls"] != null ? List<String>.from(json["stemVideoUrls"]) : null,
      knowledgePoints: json["knowledgePoints"] != null
          ? (json["knowledgePoints"] as List).map((e) => CourseUnitWritingKnowledgePointEntity.fromJson(Map<String, dynamic>.from(e))).toList()
          : null,
      grammarTargetUids: json["grammarTargetUids"] != null ? List<int>.from(json["grammarTargetUids"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "taskId": taskId,
        "compositionId": compositionId,
        "order": order,
        "cover": cover,
        "coverUrl": coverUrl,
        "coverMd5": coverMd5,
        "name": name?.map((e) => e.toJson()).toList(),
        "stem": stem?.map((e) => e.toJson()).toList(),
        "stageNid": stageNid,
        "stage": stage?.toJson(),
        "blueprint": blueprint?.toJson(),
        "genreNid": genreNid,
        "exemplarCompositionId": exemplarCompositionId,
        "difficulty": difficulty?.toJson(),
        "answerKind": answerKind,
        "answerKindLable": answerKindLable,
        "answerMinCount": answerMinCount,
        "answerMaxCount": answerMaxCount,
        "status": status,
        "access": access,
        "updated": updated,
        "answerCount": answerCount,
        "stemImages": stemImages,
        "stemImageUrls": stemImageUrls,
        "stemAudios": stemAudios,
        "stemAudioUrls": stemAudioUrls,
        "stemVideos": stemVideos,
        "stemVideoUrls": stemVideoUrls,
        "knowledgePoints": knowledgePoints?.map((e) => e.toJson()).toList(),
        "grammarTargetUids": grammarTargetUids,
      };
}

class CourseUnitWritingTaskStageEntity {
  final String? nid;
  final List<LanguageText>? name;
  final String? compositionBlueprintNid;
  final CardContentDifficulty? difficulty;
    final String? answerKind;
    final int? answerMinCount;
    final int? answerMaxCount;
  final String? headFill;
  final String? tailFill;
  final bool? hasHead;
  final List<LanguageText>? headName;
  final bool? hasTail;
  final List<LanguageText>? tailName;
  final List<CourseUnitWritingTaskStageSlotEntity>? slots;

  CourseUnitWritingTaskStageEntity({
    this.nid,
    this.name,
    this.compositionBlueprintNid,
    this.difficulty,
      this.answerKind,
      this.answerMinCount,
      this.answerMaxCount,
    this.headFill,
    this.tailFill,
    this.hasHead,
    this.headName,
    this.hasTail,
    this.tailName,
    this.slots,
  });

  factory CourseUnitWritingTaskStageEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingTaskStageEntity(
      nid: json["nid"]?.toString(),
      name: json["name"] != null ? (json["name"] as List).map((e) => LanguageText.fromJson(Map<String, dynamic>.from(e))).toList() : null,
      compositionBlueprintNid: json["compositionBlueprintNid"]?.toString(),
      difficulty: json["difficulty"] is Map<String, dynamic> ? CardContentDifficulty.fromJson(json["difficulty"]) : null,
        answerKind: json["answerKind"]?.toString(),
        answerMinCount: json["answerMinCount"],
        answerMaxCount: json["answerMaxCount"],
      headFill: json["headFill"]?.toString(),
      tailFill: json["tailFill"]?.toString(),
      hasHead: json["hasHead"],
      headName: json["headName"] != null ? (json["headName"] as List).map((e) => LanguageText.fromJson(Map<String, dynamic>.from(e))).toList() : null,
      hasTail: json["hasTail"],
      tailName: json["tailName"] != null ? (json["tailName"] as List).map((e) => LanguageText.fromJson(Map<String, dynamic>.from(e))).toList() : null,
      slots: json["slots"] != null
          ? (json["slots"] as List).map((e) => CourseUnitWritingTaskStageSlotEntity.fromJson(Map<String, dynamic>.from(e))).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "nid": nid,
        "name": name?.map((e) => e.toJson()).toList(),
        "compositionBlueprintNid": compositionBlueprintNid,
        "difficulty": difficulty?.toJson(),
          "answerKind": answerKind,
          "answerMinCount": answerMinCount,
          "answerMaxCount": answerMaxCount,
        "headFill": headFill,
        "tailFill": tailFill,
        "hasHead": hasHead,
        "headName": headName?.map((e) => e.toJson()).toList(),
        "hasTail": hasTail,
        "tailName": tailName?.map((e) => e.toJson()).toList(),
        "slots": slots?.map((e) => e.toJson()).toList(),
      };
}

class CourseUnitWritingTaskStageSlotEntity {
  final int? order;
  final String? beatNid;
  final String? paragraphTypeNid;
  final CourseUnitWritingParagraphTypeEntity? paragraphType;
  final String? fill;

  CourseUnitWritingTaskStageSlotEntity({
    this.order,
    this.beatNid,
    this.paragraphTypeNid,
    this.paragraphType,
    this.fill,
  });

  factory CourseUnitWritingTaskStageSlotEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingTaskStageSlotEntity(
      order: json["order"],
      beatNid: json["beatNid"]?.toString(),
      paragraphTypeNid: json["paragraphTypeNid"]?.toString(),
      paragraphType: json["paragraphType"] is Map<String, dynamic> ? CourseUnitWritingParagraphTypeEntity.fromJson(json["paragraphType"]) : null,
      fill: json["fill"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "order": order,
        "beatNid": beatNid,
        "paragraphTypeNid": paragraphTypeNid,
        "paragraphType": paragraphType?.toJson(),
        "fill": fill,
      };
}

class CourseUnitWritingParagraphTypeEntity {
  final String? nid;
  final List<LanguageText>? name;
  final List<LanguageText>? description;

  CourseUnitWritingParagraphTypeEntity({
    this.nid,
    this.name,
    this.description,
  });

  factory CourseUnitWritingParagraphTypeEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingParagraphTypeEntity(
      nid: json["nid"]?.toString(),
      name: json["name"] != null ? (json["name"] as List).map((e) => LanguageText.fromJson(Map<String, dynamic>.from(e))).toList() : null,
      description: json["description"] != null
          ? (json["description"] as List).map((e) => LanguageText.fromJson(Map<String, dynamic>.from(e))).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "nid": nid,
        "name": name?.map((e) => e.toJson()).toList(),
        "description": description?.map((e) => e.toJson()).toList(),
      };
}

class CourseUnitWritingTaskBlueprintEntity {
  final String? nid;
  final List<LanguageText>? name;
  final List<LanguageText>? description;

  CourseUnitWritingTaskBlueprintEntity({
    this.nid,
    this.name,
    this.description,
  });

  factory CourseUnitWritingTaskBlueprintEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingTaskBlueprintEntity(
      nid: json["nid"]?.toString(),
      name: json["name"] != null ? (json["name"] as List).map((e) => LanguageText.fromJson(Map<String, dynamic>.from(e))).toList() : null,
      description: json["description"] != null
          ? (json["description"] as List).map((e) => LanguageText.fromJson(Map<String, dynamic>.from(e))).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "nid": nid,
        "name": name?.map((e) => e.toJson()).toList(),
        "description": description?.map((e) => e.toJson()).toList(),
      };
}

class CourseUnitWritingKnowledgePointEntity {
  final String? contentType;
  final int? uid;
  final int? semanticId;

  CourseUnitWritingKnowledgePointEntity({
    this.contentType,
    this.uid,
    this.semanticId,
  });

  factory CourseUnitWritingKnowledgePointEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingKnowledgePointEntity(
      contentType: json["contentType"]?.toString(),
      uid: json["uid"],
      semanticId: json["semanticId"],
    );
  }

  Map<String, dynamic> toJson() => {
        "contentType": contentType,
        "uid": uid,
        "semanticId": semanticId,
      };
}

class CourseUnitWritingTaskEditorPageEntity {
  final int? unitId;
  final int? writingId;
  final StageCardData? stage;
  final int? pendingTargetCount;
  final CourseUnitWritingEditorTaskEntity? task;
  final List<CourseUnitWritingEditorKnowledgeItemEntity>? knowledgeList;
  final List<CourseUnitWritingGrammarTargetItemEntity>? grammarTargetList;
  final CourseUnitWritingDetailEntity? unitWriting;

  CourseUnitWritingTaskEditorPageEntity({
    this.unitId,
    this.writingId,
    this.stage,
    this.pendingTargetCount,
    this.task,
    this.knowledgeList,
    this.grammarTargetList,
    this.unitWriting,
  });

  factory CourseUnitWritingTaskEditorPageEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingTaskEditorPageEntity(
      unitId: json["unitId"],
      writingId: json["writingId"],
      stage: json["stage"] is Map<String, dynamic> ? StageCardData.fromJson(json["stage"]) : null,
      pendingTargetCount: json["pendingTargetCount"],
      task: json["task"] is Map<String, dynamic> ? CourseUnitWritingEditorTaskEntity.fromJson(json["task"]) : null,
      knowledgeList: json["knowledgeList"] != null
          ? (json["knowledgeList"] as List)
              .map((e) => CourseUnitWritingEditorKnowledgeItemEntity.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,
      grammarTargetList: json["grammarTargetList"] != null
          ? (json["grammarTargetList"] as List)
              .map((e) => CourseUnitWritingGrammarTargetItemEntity.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,
      unitWriting: json["unitWriting"] is Map<String, dynamic> ? CourseUnitWritingDetailEntity.fromJson(json["unitWriting"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "unitId": unitId,
        "writingId": writingId,
        "stage": stage?.toJson(),
        "pendingTargetCount": pendingTargetCount,
        "task": task?.toJson(),
        "knowledgeList": knowledgeList?.map((e) => e.toJson()).toList(),
        "grammarTargetList": grammarTargetList?.map((e) => e.toJson()).toList(),
        "unitWriting": unitWriting?.toJson(),
      };
}

class CourseUnitWritingExemplarEditorPageEntity {
  final int? unitId;
  final int? taskId;
  final ZhenxieTaskDetailsEntity? data;
  final List<CourseUnitWritingEditorKnowledgeItemEntity>? knowledgeList;
  final List<CourseUnitWritingGrammarTargetItemEntity>? grammarTargetList;
  final CourseUnitWritingDetailEntity? unitWriting;

  CourseUnitWritingExemplarEditorPageEntity({
    this.unitId,
    this.taskId,
    this.data,
    this.knowledgeList,
    this.grammarTargetList,
    this.unitWriting,
  });

  factory CourseUnitWritingExemplarEditorPageEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingExemplarEditorPageEntity(
      unitId: json["unitId"],
      taskId: json["taskId"],
      data: json["data"] is Map<String, dynamic> ? ZhenxieTaskDetailsEntity.fromJson(json["data"]) : null,
      knowledgeList: json["knowledgeList"] != null
          ? (json["knowledgeList"] as List)
              .map((e) => CourseUnitWritingEditorKnowledgeItemEntity.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,
      grammarTargetList: json["grammarTargetList"] != null
          ? (json["grammarTargetList"] as List)
              .map((e) => CourseUnitWritingGrammarTargetItemEntity.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,
      unitWriting: json["unitWriting"] is Map<String, dynamic> ? CourseUnitWritingDetailEntity.fromJson(json["unitWriting"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "unitId": unitId,
        "taskId": taskId,
        "data": data?.toJson(),
        "knowledgeList": knowledgeList?.map((e) => e.toJson()).toList(),
        "grammarTargetList": grammarTargetList?.map((e) => e.toJson()).toList(),
        "unitWriting": unitWriting?.toJson(),
      };
}

class CourseUnitWritingEditorTaskEntity {
  final int? uid;
  final int? taskId;
  final int? compositionId;
  final num? order;
  final List<LanguageText>? name;
  final List<LanguageText>? stem;
  final int? answerCount;
  final List<String>? stemImages;
  final List<String>? stemImageUrls;
  final List<String>? stemAudios;
  final List<String>? stemAudioUrls;
  final List<String>? stemVideos;
  final List<String>? stemVideoUrls;
  final List<CourseUnitWritingKnowledgePointEntity>? knowledgePoints;
  final List<int>? grammarTargetUids;

  CourseUnitWritingEditorTaskEntity({
    this.uid,
    this.taskId,
    this.compositionId,
    this.order,
    this.name,
    this.stem,
    this.answerCount,
    this.stemImages,
    this.stemImageUrls,
    this.stemAudios,
    this.stemAudioUrls,
    this.stemVideos,
    this.stemVideoUrls,
    this.knowledgePoints,
    this.grammarTargetUids,
  });

  factory CourseUnitWritingEditorTaskEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingEditorTaskEntity(
      uid: json["uid"],
      taskId: json["taskId"],
      compositionId: json["compositionId"],
      order: json["order"],
      name: json["name"] != null ? (json["name"] as List).map((e) => LanguageText.fromJson(Map<String, dynamic>.from(e))).toList() : null,
      stem: json["stem"] != null ? (json["stem"] as List).map((e) => LanguageText.fromJson(Map<String, dynamic>.from(e))).toList() : null,
      answerCount: json["answerCount"],
      stemImages: json["stemImages"] != null ? List<String>.from(json["stemImages"]) : null,
      stemImageUrls: json["stemImageUrls"] != null ? List<String>.from(json["stemImageUrls"]) : null,
      stemAudios: json["stemAudios"] != null ? List<String>.from(json["stemAudios"]) : null,
      stemAudioUrls: json["stemAudioUrls"] != null ? List<String>.from(json["stemAudioUrls"]) : null,
      stemVideos: json["stemVideos"] != null ? List<String>.from(json["stemVideos"]) : null,
      stemVideoUrls: json["stemVideoUrls"] != null ? List<String>.from(json["stemVideoUrls"]) : null,
      knowledgePoints: json["knowledgePoints"] != null
          ? (json["knowledgePoints"] as List).map((e) => CourseUnitWritingKnowledgePointEntity.fromJson(Map<String, dynamic>.from(e))).toList()
          : null,
      grammarTargetUids: json["grammarTargetUids"] != null ? List<int>.from(json["grammarTargetUids"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "taskId": taskId,
        "compositionId": compositionId,
        "order": order,
        "name": name?.map((e) => e.toJson()).toList(),
        "stem": stem?.map((e) => e.toJson()).toList(),
        "answerCount": answerCount,
        "stemImages": stemImages,
        "stemImageUrls": stemImageUrls,
        "stemAudios": stemAudios,
        "stemAudioUrls": stemAudioUrls,
        "stemVideos": stemVideos,
        "stemVideoUrls": stemVideoUrls,
        "knowledgePoints": knowledgePoints?.map((e) => e.toJson()).toList(),
        "grammarTargetUids": grammarTargetUids,
      };
}

class CourseUnitWritingEditorStageEntity {
  final String? nid;
  final String? cover;
  final String? coverUrl;
  final String? coverMd5;
  final List<LanguageText>? name;
  final List<LanguageText>? description;
  final String? compositionBlueprintNid;
  final String? genreNid;
  final CourseUnitWritingEditorBlueprintEntity? compositionBlueprint;
  final CardContentDifficulty? difficulty;
  final String? answerKind;
  final int? answerMinCount;
  final int? answerMaxCount;
  final bool? lockBlueprintTab;
  final bool? lockExemplarView;
  final List<CourseUnitWritingEditorStageSlotEntity>? slots;
  final num? order;
  final List<dynamic>? milestoneList;
  final bool? system;
  final bool? enabled;
  final String? created;
  final String? updated;

  CourseUnitWritingEditorStageEntity({
    this.nid,
    this.cover,
    this.coverUrl,
    this.coverMd5,
    this.name,
    this.description,
    this.compositionBlueprintNid,
    this.genreNid,
    this.compositionBlueprint,
    this.difficulty,
    this.answerKind,
    this.answerMinCount,
    this.answerMaxCount,
    this.lockBlueprintTab,
    this.lockExemplarView,
    this.slots,
    this.order,
    this.milestoneList,
    this.system,
    this.enabled,
    this.created,
    this.updated,
  });

  factory CourseUnitWritingEditorStageEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingEditorStageEntity(
      nid: json["nid"]?.toString(),
      cover: json["cover"]?.toString(),
      coverUrl: json["coverUrl"]?.toString(),
      coverMd5: json["coverMd5"]?.toString(),
      name: json["name"] != null ? (json["name"] as List).map((e) => LanguageText.fromJson(Map<String, dynamic>.from(e))).toList() : null,
      description: json["description"] != null
          ? (json["description"] as List).map((e) => LanguageText.fromJson(Map<String, dynamic>.from(e))).toList()
          : null,
      compositionBlueprintNid: json["compositionBlueprintNid"]?.toString(),
      genreNid: json["genreNid"]?.toString(),
      compositionBlueprint: json["compositionBlueprint"] is Map<String, dynamic>
          ? CourseUnitWritingEditorBlueprintEntity.fromJson(json["compositionBlueprint"])
          : null,
      difficulty: json["difficulty"] is Map<String, dynamic> ? CardContentDifficulty.fromJson(json["difficulty"]) : null,
      answerKind: json["answerKind"]?.toString(),
      answerMinCount: json["answerMinCount"],
      answerMaxCount: json["answerMaxCount"],
      lockBlueprintTab: json["lockBlueprintTab"],
      lockExemplarView: json["lockExemplarView"],
      slots: json["slots"] != null
          ? (json["slots"] as List).map((e) => CourseUnitWritingEditorStageSlotEntity.fromJson(Map<String, dynamic>.from(e))).toList()
          : null,
      order: json["order"],
      milestoneList: json["milestoneList"] != null ? List<dynamic>.from(json["milestoneList"]) : null,
      system: json["system"],
      enabled: json["enabled"],
      created: json["created"]?.toString(),
      updated: json["updated"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "nid": nid,
        "cover": cover,
        "coverUrl": coverUrl,
        "coverMd5": coverMd5,
        "name": name?.map((e) => e.toJson()).toList(),
        "description": description?.map((e) => e.toJson()).toList(),
        "compositionBlueprintNid": compositionBlueprintNid,
        "genreNid": genreNid,
        "compositionBlueprint": compositionBlueprint?.toJson(),
        "difficulty": difficulty?.toJson(),
        "answerKind": answerKind,
        "answerMinCount": answerMinCount,
        "answerMaxCount": answerMaxCount,
        "lockBlueprintTab": lockBlueprintTab,
        "lockExemplarView": lockExemplarView,
        "slots": slots?.map((e) => e.toJson()).toList(),
        "order": order,
        "milestoneList": milestoneList,
        "system": system,
        "enabled": enabled,
        "created": created,
        "updated": updated,
      };
}

class CourseUnitWritingEditorBlueprintEntity {
  final String? nid;
  final String? coverUrl;
  final List<LanguageText>? name;
  final List<LanguageText>? description;
  final String? compositionFamilyNid;
  final String? frameworkNid;
  final CourseUnitWritingEditorMetaEntity? framework;
  final String? skinNid;
  final CourseUnitWritingEditorMetaEntity? skin;
  final CardContentDifficulty? difficulty;
  final num? order;
  final int? minParagraphCount;
  final int? maxParagraphCount;
  final List<CourseUnitWritingEditorBlueprintSlotEntity>? slots;
  final bool? system;
  final bool? enabled;
  final String? created;
  final String? updated;

  CourseUnitWritingEditorBlueprintEntity({
    this.nid,
    this.coverUrl,
    this.name,
    this.description,
    this.compositionFamilyNid,
    this.frameworkNid,
    this.framework,
    this.skinNid,
    this.skin,
    this.difficulty,
    this.order,
    this.minParagraphCount,
    this.maxParagraphCount,
    this.slots,
    this.system,
    this.enabled,
    this.created,
    this.updated,
  });

  factory CourseUnitWritingEditorBlueprintEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingEditorBlueprintEntity(
      nid: json["nid"]?.toString(),
      coverUrl: json["coverUrl"]?.toString(),
      name: json["name"] != null ? (json["name"] as List).map((e) => LanguageText.fromJson(Map<String, dynamic>.from(e))).toList() : null,
      description: json["description"] != null
          ? (json["description"] as List).map((e) => LanguageText.fromJson(Map<String, dynamic>.from(e))).toList()
          : null,
      compositionFamilyNid: json["compositionFamilyNid"]?.toString(),
      frameworkNid: json["frameworkNid"]?.toString(),
      framework: json["framework"] is Map<String, dynamic> ? CourseUnitWritingEditorMetaEntity.fromJson(json["framework"]) : null,
      skinNid: json["skinNid"]?.toString(),
      skin: json["skin"] is Map<String, dynamic> ? CourseUnitWritingEditorMetaEntity.fromJson(json["skin"]) : null,
      difficulty: json["difficulty"] is Map<String, dynamic> ? CardContentDifficulty.fromJson(json["difficulty"]) : null,
      order: json["order"],
      minParagraphCount: json["minParagraphCount"],
      maxParagraphCount: json["maxParagraphCount"],
      slots: json["slots"] != null
          ? (json["slots"] as List).map((e) => CourseUnitWritingEditorBlueprintSlotEntity.fromJson(Map<String, dynamic>.from(e))).toList()
          : null,
      system: json["system"],
      enabled: json["enabled"],
      created: json["created"]?.toString(),
      updated: json["updated"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "nid": nid,
        "coverUrl": coverUrl,
        "name": name?.map((e) => e.toJson()).toList(),
        "description": description?.map((e) => e.toJson()).toList(),
        "compositionFamilyNid": compositionFamilyNid,
        "frameworkNid": frameworkNid,
        "framework": framework?.toJson(),
        "skinNid": skinNid,
        "skin": skin?.toJson(),
        "difficulty": difficulty?.toJson(),
        "order": order,
        "minParagraphCount": minParagraphCount,
        "maxParagraphCount": maxParagraphCount,
        "slots": slots?.map((e) => e.toJson()).toList(),
        "system": system,
        "enabled": enabled,
        "created": created,
        "updated": updated,
      };
}

class CourseUnitWritingEditorMetaEntity {
  final String? nid;
  final List<LanguageText>? name;
  final List<LanguageText>? description;

  CourseUnitWritingEditorMetaEntity({
    this.nid,
    this.name,
    this.description,
  });

  factory CourseUnitWritingEditorMetaEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingEditorMetaEntity(
      nid: json["nid"]?.toString(),
      name: json["name"] != null ? (json["name"] as List).map((e) => LanguageText.fromJson(Map<String, dynamic>.from(e))).toList() : null,
      description: json["description"] != null
          ? (json["description"] as List).map((e) => LanguageText.fromJson(Map<String, dynamic>.from(e))).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "nid": nid,
        "name": name?.map((e) => e.toJson()).toList(),
        "description": description?.map((e) => e.toJson()).toList(),
      };
}

class CourseUnitWritingEditorBlueprintSlotEntity {
  final int? order;
  final String? beatNid;
  final bool? required;
  final int? repeatMin;
  final int? repeatMax;
  final List<CourseUnitWritingEditorAllowedParagraphEntity>? allowedParagraphs;

  CourseUnitWritingEditorBlueprintSlotEntity({
    this.order,
    this.beatNid,
    this.required,
    this.repeatMin,
    this.repeatMax,
    this.allowedParagraphs,
  });

  factory CourseUnitWritingEditorBlueprintSlotEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingEditorBlueprintSlotEntity(
      order: json["order"],
      beatNid: json["beatNid"]?.toString(),
      required: json["required"],
      repeatMin: json["repeatMin"],
      repeatMax: json["repeatMax"],
      allowedParagraphs: json["allowedParagraphs"] != null
          ? (json["allowedParagraphs"] as List)
              .map((e) => CourseUnitWritingEditorAllowedParagraphEntity.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "order": order,
        "beatNid": beatNid,
        "required": required,
        "repeatMin": repeatMin,
        "repeatMax": repeatMax,
        "allowedParagraphs": allowedParagraphs?.map((e) => e.toJson()).toList(),
      };
}

class CourseUnitWritingEditorAllowedParagraphEntity {
  final String? paragraphTypeNid;
  final CourseUnitWritingParagraphTypeEntity? paragraphType;
  final List<LanguageText>? usageName;
  final List<LanguageText>? usageDescription;

  CourseUnitWritingEditorAllowedParagraphEntity({
    this.paragraphTypeNid,
    this.paragraphType,
    this.usageName,
    this.usageDescription,
  });

  factory CourseUnitWritingEditorAllowedParagraphEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingEditorAllowedParagraphEntity(
      paragraphTypeNid: json["paragraphTypeNid"]?.toString(),
      paragraphType: json["paragraphType"] is Map<String, dynamic> ? CourseUnitWritingParagraphTypeEntity.fromJson(json["paragraphType"]) : null,
      usageName: json["usageName"] != null ? (json["usageName"] as List).map((e) => LanguageText.fromJson(Map<String, dynamic>.from(e))).toList() : null,
      usageDescription: json["usageDescription"] != null
          ? (json["usageDescription"] as List).map((e) => LanguageText.fromJson(Map<String, dynamic>.from(e))).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "paragraphTypeNid": paragraphTypeNid,
        "paragraphType": paragraphType?.toJson(),
        "usageName": usageName?.map((e) => e.toJson()).toList(),
        "usageDescription": usageDescription?.map((e) => e.toJson()).toList(),
      };
}

class CourseUnitWritingEditorStageSlotEntity {
  final int? order;
  final String? beatNid;
  final String? paragraphTypeNid;
  final String? fill;

  CourseUnitWritingEditorStageSlotEntity({
    this.order,
    this.beatNid,
    this.paragraphTypeNid,
    this.fill,
  });

  factory CourseUnitWritingEditorStageSlotEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingEditorStageSlotEntity(
      order: json["order"],
      beatNid: json["beatNid"]?.toString(),
      paragraphTypeNid: json["paragraphTypeNid"]?.toString(),
      fill: json["fill"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "order": order,
        "beatNid": beatNid,
        "paragraphTypeNid": paragraphTypeNid,
        "fill": fill,
      };
}

class CourseUnitWritingEditorKnowledgeItemEntity {
  final int? uid;
  final String? contentType;
  final int? contentId;
  final int? semanticId;
  final String? content;
  final String? definition;

  CourseUnitWritingEditorKnowledgeItemEntity({
    this.uid,
    this.contentType,
    this.contentId,
    this.semanticId,
    this.content,
    this.definition,
  });

  factory CourseUnitWritingEditorKnowledgeItemEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingEditorKnowledgeItemEntity(
      uid: json["uid"],
      contentType: json["contentType"]?.toString(),
      contentId: json["contentId"],
      semanticId: json["semanticId"],
      content: json["content"]?.toString(),
      definition: json["definition"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "contentType": contentType,
        "contentId": contentId,
        "semanticId": semanticId,
        "content": content,
        "definition": definition,
      };
}

class CourseUnitWritingGrammarTargetItemEntity {
  final int? uid;
  final List<LanguageText>? title;
  final String? kindTitle;

  CourseUnitWritingGrammarTargetItemEntity({
    this.uid,
    this.title,
    this.kindTitle,
  });

  factory CourseUnitWritingGrammarTargetItemEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingGrammarTargetItemEntity(
      uid: json["uid"],
      title: json["title"] != null ? (json["title"] as List).map((e) => LanguageText.fromJson(Map<String, dynamic>.from(e))).toList() : null,
      kindTitle: json["kindTitle"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "title": title?.map((e) => e.toJson()).toList(),
        "kindTitle": kindTitle,
      };
}

class CourseUnitWritingDetailEntity {
  final int? unitId;
  final int? writingId;
  final int? lessonId;
  final String? lessonType;
  final StageCardData? stage;
  final int? taskCount;
  final int? compositionTaskCount;
  final CourseUnitWritingGrammarScopeEntity? grammarScope;
  final CourseUnitWritingGrammarScopeMetaEntity? grammarScopeMeta;
  final CourseUnitWritingSourceEntity? source;

  CourseUnitWritingDetailEntity({
    this.unitId,
    this.writingId,
    this.lessonId,
    this.lessonType,
    this.stage,
    this.taskCount,
    this.compositionTaskCount,
    this.grammarScope,
    this.grammarScopeMeta,
    this.source,
  });

  factory CourseUnitWritingDetailEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingDetailEntity(
      unitId: json["unitId"],
      writingId: json["writingId"],
      lessonId: json["lessonId"],
      lessonType: json["lessonType"]?.toString(),
      stage: json["stage"] is Map<String, dynamic> ? StageCardData.fromJson(json["stage"]) : null,
      taskCount: json["taskCount"],
      compositionTaskCount: json["compositionTaskCount"],
      grammarScope: json["grammarScope"] is Map<String, dynamic> ? CourseUnitWritingGrammarScopeEntity.fromJson(json["grammarScope"]) : null,
      grammarScopeMeta: json["grammarScopeMeta"] is Map<String, dynamic>
          ? CourseUnitWritingGrammarScopeMetaEntity.fromJson(json["grammarScopeMeta"])
          : null,
      source: json["source"] is Map<String, dynamic> ? CourseUnitWritingSourceEntity.fromJson(json["source"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "unitId": unitId,
        "writingId": writingId,
        "lessonId": lessonId,
        "lessonType": lessonType,
        "stage": stage?.toJson(),
        "taskCount": taskCount,
        "compositionTaskCount": compositionTaskCount,
        "grammarScope": grammarScope?.toJson(),
        "grammarScopeMeta": grammarScopeMeta?.toJson(),
        "source": source?.toJson(),
      };
}

class CourseUnitWritingGrammarScopeEntity {
  final List<String>? time;
  final List<String>? aspect;
  final List<String>? voice;

  CourseUnitWritingGrammarScopeEntity({
    this.time,
    this.aspect,
    this.voice,
  });

  factory CourseUnitWritingGrammarScopeEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingGrammarScopeEntity(
      time: json["time"] != null ? List<String>.from(json["time"]) : null,
      aspect: json["aspect"] != null ? List<String>.from(json["aspect"]) : null,
      voice: json["voice"] != null ? List<String>.from(json["voice"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "time": time,
        "aspect": aspect,
        "voice": voice,
      };
}

class CourseUnitWritingGrammarScopeMetaEntity {
  final CourseUnitWritingGrammarScopeMetaAxisEntity? time;
  final CourseUnitWritingGrammarScopeMetaAxisEntity? aspect;
  final CourseUnitWritingGrammarScopeMetaAxisEntity? voice;

  CourseUnitWritingGrammarScopeMetaEntity({
    this.time,
    this.aspect,
    this.voice,
  });

  factory CourseUnitWritingGrammarScopeMetaEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingGrammarScopeMetaEntity(
      time: json["time"] is Map<String, dynamic> ? CourseUnitWritingGrammarScopeMetaAxisEntity.fromJson(json["time"]) : null,
      aspect: json["aspect"] is Map<String, dynamic> ? CourseUnitWritingGrammarScopeMetaAxisEntity.fromJson(json["aspect"]) : null,
      voice: json["voice"] is Map<String, dynamic> ? CourseUnitWritingGrammarScopeMetaAxisEntity.fromJson(json["voice"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "time": time?.toJson(),
        "aspect": aspect?.toJson(),
        "voice": voice?.toJson(),
      };
}

class CourseUnitWritingGrammarScopeMetaAxisEntity {
  final String? code;
  final String? name;
  final List<CourseUnitWritingGrammarScopeMetaOptionEntity>? options;

  CourseUnitWritingGrammarScopeMetaAxisEntity({
    this.code,
    this.name,
    this.options,
  });

  factory CourseUnitWritingGrammarScopeMetaAxisEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingGrammarScopeMetaAxisEntity(
      code: json["code"]?.toString(),
      name: json["name"]?.toString(),
      options: json["options"] != null
          ? (json["options"] as List)
              .map((e) => CourseUnitWritingGrammarScopeMetaOptionEntity.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "options": options?.map((e) => e.toJson()).toList(),
      };
}

class CourseUnitWritingGrammarScopeMetaOptionEntity {
  final String? code;
  final String? name;

  CourseUnitWritingGrammarScopeMetaOptionEntity({
    this.code,
    this.name,
  });

  factory CourseUnitWritingGrammarScopeMetaOptionEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingGrammarScopeMetaOptionEntity(
      code: json["code"]?.toString(),
      name: json["name"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
      };
}

class CourseUnitWritingSourceEntity {
  final String? level;
  final String? project;
  final String? theme;
  final String? topic;
  final String? subTopic;

  CourseUnitWritingSourceEntity({
    this.level,
    this.project,
    this.theme,
    this.topic,
    this.subTopic,
  });

  factory CourseUnitWritingSourceEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return CourseUnitWritingSourceEntity(
      level: json["level"]?.toString(),
      project: json["project"]?.toString(),
      theme: json["theme"]?.toString(),
      topic: json["topic"]?.toString(),
      subTopic: json["subTopic"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "level": level,
        "project": project,
        "theme": theme,
        "topic": topic,
        "subTopic": subTopic,
      };
}
class UnitKnowledgeTypeCountEntity {
  final String? contentType;
  final String? name;
  final int? count;

  UnitKnowledgeTypeCountEntity({
    this.contentType,
    this.name,
    this.count,
  });

  factory UnitKnowledgeTypeCountEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return UnitKnowledgeTypeCountEntity(
      contentType: json["contentType"],
      name: json["name"],
      count: json["count"],
    );
  }

  Map<String, dynamic> toJson() => {
        "contentType": contentType,
        "name": name,
        "count": count,
      };
}

class MiniLessonResponseEntity {
  final int? uid;
  final String? name;
  final String? coverUrl;

  MiniLessonResponseEntity({this.uid, this.name, this.coverUrl}) : globalKey = GlobalKey(debugLabel: uid.toString());

  final GlobalKey globalKey;

  factory MiniLessonResponseEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return MiniLessonResponseEntity(uid: json["uid"], name: json["name"], coverUrl: json["coverUrl"]);
  }

  Map<String, dynamic> toJson() => {"uid": uid, "name": name, "coverUrl": coverUrl};

  @override
  String toString() {
    return 'MiniLessonResponseEntity('
        'uid: $uid, '
        'name: $name, '
        'coverUrl: $coverUrl, '
        'globalKey: $globalKey, )';
  }
}

class NewUnitResponseEntityDifficulty {
  int? min;
  int? max;

  NewUnitResponseEntityDifficulty({
    this.min,
    this.max,
  });

  factory NewUnitResponseEntityDifficulty.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return NewUnitResponseEntityDifficulty(min: json["min"], max: json["max"]);
  }

  Map<String, dynamic> toJson() => {"min": min, "name": max};

  @override
  String toString() {
    return 'NewUnitResponseEntityDifficulty('
        'min: $min, '
        'max: $max)';
  }
}
