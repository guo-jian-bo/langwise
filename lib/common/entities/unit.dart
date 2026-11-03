import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final bool? sentenceGenerated;
  final int? songGenerateType;
  final int? remixTextGenerateType;

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
      this.sentenceGenerated,
      this.songGenerateType,
      this.remixTextGenerateType,
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
      sentenceGenerated: json["sentenceGenerated"],
      songGenerateType: json["songGenerateType"],
      remixTextGenerateType:json["remixTextGenerateType"]??0,
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
        "sentenceGenerated": sentenceGenerated,
        "songGenerateType": songGenerateType,
        "remixTextGenerateType": remixTextGenerateType,
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
      bool? sentenceGenerated,
      String? created,
      int? uid,
      int? difficultyLevel,
      NewUnitResponseEntityDifficulty? difficulty}) {
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
        sentenceGenerated: sentenceGenerated ?? this.sentenceGenerated,
        created: created ?? this.created,
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
        'sentenceGenerated: $sentenceGenerated, '
        'created: $created, difficultyLevel: $difficultyLevel, difficulty: $difficulty)';
  }
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
