import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/widgets/data_table_widget/data_table.dart';
import 'package:langwise/utils/utils.dart';
import 'package:uuid/uuid.dart';

import '../public_controller/config_controller.dart';

class LessonResponseEntity<T> extends Dessert {
  final String uniqueId;
  final int? unitId;
  final int? lessonTemplateId;
  final String? name;
  final String? cover;
  final String? coverUrl;
  final String? description;
  final String? type;
  final String? language;
  final List<T>? knowledgePointList;
  final String? scope;
  final String? scopeName;
  final String? vendor;
  final String? vendorName;
  final num? order;
  final String? access;
  final String? updated;
  final String? created;
  final String flag;
  final bool? ableEdit;
  final int? unConfirm;
  final int? pending;
  final int? exerciseCount;
  final int? exerciseNormalCount;
  final bool? planned;
  final int? exerciseGenerateType;
  final int? remixTextGenerateType;
  final int? songGenerateType;
  LessonResponseEntity(
      {String? uniqueId,
      this.unitId,
      this.lessonTemplateId,
      this.name,
      this.cover,
      this.coverUrl,
      this.description,
      this.type,
      this.language,
      this.knowledgePointList,
      this.scope,
      this.scopeName,
      this.vendor,
      this.vendorName,
      this.order,
      this.access,
      this.updated,
      this.created,
      this.unConfirm,
      this.pending,
      this.exerciseCount,
      this.exerciseNormalCount,
      required int uid,
      this.flag = "LessonResponseEntity",
      this.ableEdit,
      this.planned,
      this.exerciseGenerateType,
      this.remixTextGenerateType,
      this.songGenerateType})
      : uniqueId = uniqueId ?? _generateUniqueId(),
        globalKey = GlobalKey(debugLabel: uid.toString()),
        super(uid: uid);

  /// 唯一ID生成策略
  static String _generateUniqueId() {
    return const Uuid().v6();
  }

  final GlobalKey globalKey;

  factory LessonResponseEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    List<T>? knowledgePointList = [];
    if (json['knowledgePointList'] != null) {
      if (fromJson != null) {
        knowledgePointList = json['knowledgePointList'].map((e) => fromJson(e)).cast<T>().toList();
      } else {
        knowledgePointList = json['knowledgePointList'] as List<T>?;
      }
    }

    return LessonResponseEntity(
      uniqueId: json["uniqueId"],
      uid: json["uid"] ?? 0,
      lessonTemplateId: json["lessonTemplateId"],
      unitId: json["unitId"],
      name: json["name"],
      cover: json["cover"],
      coverUrl: json["coverUrl"],
      description: json["description"],
      type: json["type"],
      language: json["language"],
      knowledgePointList: knowledgePointList,
      scope: json["scope"],
      scopeName: json["scopeName"],
      vendor: json["vendor"],
      vendorName: json["vendorName"],
      order: json["order"],
      access: json["access"],
      updated: json["updated"],
      created: json["created"],
      ableEdit: json["ableEdit"],
      unConfirm: json["unConfirm"],
      pending: json["pending"],
      exerciseCount: json["exerciseCount"],
      exerciseNormalCount: json["exerciseNormalCount"],
      planned: json["planned"],
      exerciseGenerateType: json["exerciseGenerateType"],
      remixTextGenerateType: json["remixTextGenerateType"],
      songGenerateType: json["songGenerateType"],
    );
  }

  LessonResponseEntity<T> copyWith(
      {String? uniqueId,
      int? uid,
      int? unitId,
      int? lessonTemplateId,
      String? name,
      String? cover,
      String? coverUrl,
      String? description,
      String? type,
      String? language,
      List<T>? knowledgePointList,
      String? scope,
      String? scopeName,
      String? vendor,
      String? vendorName,
      num? order,
      String? access,
      String? updated,
      String? created,
      String? flag,
      bool? ableEdit,
      int? unConfirm,
      int? pending,
      int? exerciseCount,
      int? exerciseNormalCount,
      bool? planned,
      int? exerciseGenerateType,
      int? remixTextGenerateType,
      int? songGenerateType}) {
    return LessonResponseEntity<T>(
      uniqueId: uniqueId ?? this.uniqueId,
      uid: uid ?? this.uid,
      unitId: unitId ?? this.unitId,
      lessonTemplateId: lessonTemplateId ?? this.lessonTemplateId,
      name: name ?? this.name,
      cover: cover ?? this.cover,
      coverUrl: coverUrl ?? this.coverUrl,
      description: description ?? this.description,
      type: type ?? this.type,
      language: language ?? this.language,
      knowledgePointList: knowledgePointList ?? this.knowledgePointList,
      scope: scope ?? this.scope,
      scopeName: scopeName ?? this.scopeName,
      vendor: vendor ?? this.vendor,
      vendorName: vendorName ?? this.vendorName,
      order: order ?? this.order,
      access: access ?? this.access,
      updated: updated ?? this.updated,
      created: created ?? this.created,
      flag: flag ?? this.flag,
      ableEdit: ableEdit ?? this.ableEdit,
      unConfirm: unConfirm ?? this.unConfirm,
      pending: pending ?? this.pending,
      exerciseCount: exerciseCount ?? this.exerciseCount,
      exerciseNormalCount: exerciseNormalCount ?? this.exerciseNormalCount,
      planned: planned ?? this.planned,
      exerciseGenerateType: exerciseGenerateType ?? this.exerciseGenerateType,
      remixTextGenerateType: remixTextGenerateType ?? this.remixTextGenerateType,
      songGenerateType: songGenerateType ?? this.songGenerateType,
    );
  }

  Map<String, dynamic> toJson() => {
        "uniqueId": uniqueId,
        "uid": uid,
        "lessonTemplateId": lessonTemplateId,
        "unitId": unitId,
        "name": name,
        "cover": cover,
        "coverUrl": coverUrl,
        "description": description,
        "type": type,
        "language": language,
        "scope": scope,
        "scopeName": scopeName,
        "vendor": vendor,
        "vendorName": vendorName,
        "order": order,
        "access": access,
        "updated": updated,
        "created": created,
        "ableEdit": ableEdit,
        "unConfirm": unConfirm,
        "pending": pending,
        "exerciseCount": exerciseCount,
        "exerciseNormalCount": exerciseNormalCount,
        "planned": planned,
        "exerciseGenerateType": exerciseGenerateType,
        "remixTextGenerateType": remixTextGenerateType,
        "songGenerateType": songGenerateType,
      };

  // 封面URL优先使用coverUrl
  String get effectiveCoverUrl => coverUrl ?? cover ?? '';

  // 格式化更新时间
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

  // 语言显示优化
  String get newLanguage {
    try {
      return CommonUtil.language.map((e) => e[language]).firstWhere((e) => e != null, orElse: () => null) ?? '';
    } catch (e) {
      if (kDebugMode) print('语言转换异常: $e');
      return '';
    }
  }

  // 是否可以编辑
  bool get isAbleEdit => ableEdit != null && ableEdit!;

  // 单元目标(知识点)
  bool get isUnitTARGET => type != null && type == "TARGET";

  // 单元测试(知识点)
  bool get isUnitTEST => type != null && type == "TEST";

  // 添加按钮(知识点)
  bool get isAddButton => type != null && type == "ADD_BUTTON";

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is LessonResponseEntity && uid == other.uid && flag == other.flag;
  }

  @override
  int get hashCode => Object.hash(uid, flag);

  @override
  String toString() {
    return 'LessonResponseEntity('
        'uid: $uid, '
        'lessonTemplateId: $lessonTemplateId, '
        'unitId: $unitId, '
        'name: $name, '
        'cover: $cover, '
        'coverUrl: $coverUrl, '
        'description: $description, '
        'type: $type, '
        'language: $language, '
        'knowledgePointList: $knowledgePointList, '
        'scope: $scope, '
        'scopeName: $scopeName, '
        'vendor: $vendor, '
        'vendorName: $vendorName, '
        'order: $order, '
        'access: $access, '
        'updated: $updated, '
        'created: $created, '
        'ableEdit: $ableEdit, '
        'unConfirm: $unConfirm, '
        'pending: $pending, '
        'exerciseCount: $exerciseCount, '
        'planned: $planned, '
        'exerciseGenerateType: $exerciseGenerateType, '
        'remixTextGenerateType: $remixTextGenerateType, '
        'songGenerateType: $songGenerateType)';
  }
}

class LessonTemplateResponseEntity<T> extends Dessert {
  final String? name;
  final String? code;
  final String? description;
  final String? purpose;
  final String? minCode;
  final int? minDifficulty;
  final int? maxDifficulty;
  final int? minLevel;
  final String? maxCode;
  final int? maxLevel;
  final List<T>? exerciseConfigs;
  final String? language;
  final String? scope;
  final String? scopeName;
  final String? vendor;
  final String? vendorName;
  final String? access;
  final String? direction;
  final String? updated;
  final String? created;
  final String? type;


  LessonTemplateResponseEntity({
    this.name,
    this.code,
    this.description,
    this.purpose,
    this.minDifficulty,
    this.maxDifficulty,
    this.minCode,
    this.minLevel,
    this.maxCode,
    this.maxLevel,
    this.exerciseConfigs,
    this.language,
    this.scope,
    this.scopeName,
    this.vendor,
    this.vendorName,
    this.access,
    this.direction,
    this.updated,
    this.created,
    this.type,
    required int? uid,
  })  : globalKey = GlobalKey(debugLabel: uid.toString()),
        super(uid: uid ?? 0);

  final GlobalKey globalKey;

  factory LessonTemplateResponseEntity.fromJson(
    Map<String, dynamic> json, {
    Function? fromJson,
  }) {
    List<T>? exerciseConfigs = [];
    if (json['exerciseConfigs'] != null) {
      if (fromJson != null) {
        exerciseConfigs = json['exerciseConfigs'].map((e) => fromJson(e)).cast<T>().toList();
      } else {
        exerciseConfigs = json['exerciseConfigs'] as List<T>?;
      }
    }

    return LessonTemplateResponseEntity(
      uid: json["uid"],
      name: json["name"],
      code: json["code"],
      description: json["description"],
      purpose: json["purpose"],
      minDifficulty: json["minDifficulty"],
      maxDifficulty: json["maxDifficulty"],
      minCode: json["minCode"],
      minLevel: json["minLevel"],
      maxCode: json["maxCode"],
      maxLevel: json["maxLevel"],
      exerciseConfigs: exerciseConfigs,
      language: json["language"],
      scope: json["scope"],
      scopeName: json["scopeName"],
      vendor: json["vendor"],
      vendorName: json["vendorName"],
      access: json["access"],
      direction: json["direction"],
      updated: json["updated"],
      created: json["created"],
      type: json["type"],
    );
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "code": code,
        "description": description,
        "purpose": purpose,
        "minDifficulty": minDifficulty,
        "maxDifficulty": maxDifficulty,
        "minCode": minCode,
        "minLevel": minLevel,
        "maxCode": maxCode,
        "maxLevel": maxLevel,
        "language": language,
        "scope": scope,
        "scopeName": scopeName,
        "vendor": vendor,
        "vendorName": vendorName,
        "access": access,
        "direction": direction,
        "updated": updated,
        "created": created,
        "type": type,
      };

  List<DifficultieEntity> getConfig() {
    final int selectLanguageIndex = StaticData.getLanguageIndex(language) ?? 0;
    final ConfigEntity configData = Get.find<ConfigController>().appConfig.value;
    final String languageCode = StaticData.languageList[selectLanguageIndex].value;
    final List<DifficultieEntity>? diffList = DifficultieUtils.getDifficultieList(configData, languageCode);
    if (diffList == null) return [];
    return diffList;
  }

  // 最小难度等级显示名称
  String get newMinDifficulty {
    String difficulty = "";
    try {
      final List<DifficultieEntity> difficultieList = getConfig();
      if (difficultieList.isNotEmpty) {
        if (minDifficulty != null) {
          difficulty = difficultieList[minDifficulty!].name?.text ?? '';
        }
      }
    } catch (e) {
      if (kDebugMode) print('最小难度等级显示名称转换异常: $e');
    }
    return difficulty;
  }

  // 最大难度等级显示名称
  String get newMaxDifficulty {
    String difficulty = "";
    try {
      final List<DifficultieEntity> difficultieList = getConfig();
      if (difficultieList.isNotEmpty) {
        if (maxDifficulty != null) {
          difficulty = difficultieList[maxDifficulty!].name?.text ?? '';
        }
      }
    } catch (e) {
      if (kDebugMode) print('最大难度等级显示名称转换异常: $e');
    }
    return difficulty;
  }

  // 考核方向显示名称
  String get newPurpose {
    final ConfigEntity configData = Get.find<ConfigController>().appConfig.value;
    final ConfigEntityAbilities? configEntityAbility = AbilitieUtils.getAbilitieName(configData, direction);
    return configEntityAbility?.title ?? '';
  }

  // 语言显示优化
  String get newLanguage {
    try {
      return CommonUtil.language.map((e) => e[language]).firstWhere((e) => e != null, orElse: () => null) ?? '';
    } catch (e) {
      if (kDebugMode) print('语言转换异常: $e');
      return '';
    }
  }

  // 时间格式化（复用相同逻辑）
  String get newUpdate => _formatDate(updated);

  String get newCreate => _formatDate(created);

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    return DateUtil.formatDateStr(dateStr, format: "yyyy/MM/dd");
  }

  @override
  String toString() {
    return 'LessonTemplateResponseEntity('
        'uid: $uid, '
        'name: $name, '
        'code: $code, '
        'description: $description, '
        'purpose: $purpose, '
        'minCode: $minCode, '
        'minLevel: $minLevel, '
        'maxCode: $maxCode, '
        'maxLevel: $maxLevel, '
        'exerciseConfigs: $exerciseConfigs, '
        'language: $language, '
        'scope: $scope, '
        'scopeName: $scopeName, '
        'vendor: $vendor, '
        'vendorName: $vendorName, '
        'access: $access, '
        'updated: $updated, '
        'created: $created, '
        'type: $type)';
  }
}
