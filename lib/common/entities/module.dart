import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/utils/utils.dart';
import 'package:uuid/uuid.dart';

import '../widgets/data_table_widget/data_table.dart';

// Module Response
class ModuleResponseEntity<T> extends Dessert with JsonSerializableMixin {
  final String? name;
  final String? cover;
  final String? coverUrl;
  final ModuleImageInfoEntity? image;
  final List<int>? imageTaskIds;
  final int? levelId;
  final List<dynamic>? unitIds;
  final List<T>? unitList;
  final String? language;
  final String? locale;
  final String? description;
  final String? scope;
  final String? scopeName;
  final String? topic;
  final String? specialty; // 专项课
  final String? vendor;
  final String? vendorName;
  final String? access;
  final String? status;
  final int? unitNormalCnt;
  final int? unitTotal;
  final num? order;
  final String? updated;
  final String? created;
  final int? minDifficulty;
  final int? maxDifficulty;
  final int? pageCount;
  final int? estimatedTime;
  final int? analysisCount;
  final int? bookId;
  final String? publisher;
  final String? isbn;
  final List<ThemeTextEntity?>? tierMappings;
  final List<CourseLevelEntityLevelListModuleListKnowledgeCounts?>? knowledgeCounts;
  final Difficulty? difficulty;
  final int? operation;
  final int? useCount;

  ModuleResponseEntity(
      {this.name,
      this.cover,
      this.coverUrl,
      this.image,
      this.imageTaskIds,
      this.levelId,
      this.unitIds,
      this.unitList,
      this.language,
      this.locale,
      this.description,
      this.scope,
      this.scopeName,
      this.topic,
      this.specialty,
      this.vendor,
      this.vendorName,
      this.access,
      this.status,
      this.unitNormalCnt,
      this.unitTotal,
      this.order,
      this.updated,
      this.created,
      this.minDifficulty,
      this.maxDifficulty,
      this.pageCount,
      this.estimatedTime,
      this.analysisCount,
      this.bookId,
      this.publisher,
      this.isbn,
      this.tierMappings,
      this.knowledgeCounts,
      this.difficulty,
      this.operation,
      this.useCount,
      required uid})
      : globalKey = GlobalKey(debugLabel: uid.toString()),
        super(uid: uid ?? 0);

  final GlobalKey globalKey;

  factory ModuleResponseEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    List<T>? unitList = [];
    if (json['unitList'] != null && json['unitList'].isNotEmpty) {
      if (fromJson != null) {
        unitList = json['unitList'].map((e) => fromJson(e)).cast<T>().toList();
      } else {
        unitList = json['unitList'] as List<T>?;
      }
    }
    List<ThemeTextEntity>? tierMappings = [];
    if (json['tierMappings'] != null) {
      final v = json['tierMappings'];
      v.forEach((v) {
        tierMappings.add(ThemeTextEntity.fromJson(v));
      });
    }
    List<CourseLevelEntityLevelListModuleListKnowledgeCounts>? knowledgeCounts = [];
    if (json['knowledgeCounts'] != null) {
      final v = json['knowledgeCounts'];
      v.forEach((v) {
        knowledgeCounts.add(CourseLevelEntityLevelListModuleListKnowledgeCounts.fromJson(v));
      });
    }

    return ModuleResponseEntity(
      uid: json["uid"],
      name: json["name"],
      cover: json["cover"],
      coverUrl: json["coverUrl"],
      image: json["image"] is Map<String, dynamic> ? ModuleImageInfoEntity.fromJson(json["image"]) : null,
      imageTaskIds: _parseIntList(json["imageTaskIds"]),
      levelId: json["levelId"],
      unitIds: json["unitIds"],
      unitList: unitList,
      language: json["language"],
      locale: json["locale"],
      description: json["description"],
      scope: json["scope"],
      scopeName: json["scopeName"],
      topic: json["topic"],
      specialty: json["specialty"],
      vendor: json["vendor"],
      vendorName: json["vendorName"],
      access: json["access"],
      status: json["status"],
      unitNormalCnt: json["unitNormalCnt"],
      unitTotal: json["unitTotal"],
      order: json["order"],
      updated: json["updated"],
      created: json["created"],
      minDifficulty: json["minDifficulty"],
      maxDifficulty: json["maxDifficulty"],
      pageCount: json["pageCount"],
      estimatedTime: json["estimatedTime"],
      analysisCount: json["analysisCount"],
      bookId: json["bookId"],
      publisher: json["publisher"],
      difficulty: json["difficulty"] != null ? Difficulty.fromJson(json["difficulty"]) : null,
      isbn: json["isbn"],
      tierMappings: tierMappings,
      knowledgeCounts: knowledgeCounts,
      operation: json['operation'],
      useCount: json['useCount'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "cover": cover,
        "coverUrl": coverUrl,
        "image": image?.toJson(),
        "imageTaskIds": imageTaskIds,
        "levelId": levelId,
        "unitIds": unitIds,
        "language": language,
        "locale": locale,
        "description": description,
        "scope": scope,
        "scopeName": scopeName,
        "topic": topic,
        "specialty": specialty,
        "vendor": vendor,
        "vendorName": vendorName,
        "access": access,
        "unitNormalCnt": unitNormalCnt,
        "unitTotal": unitTotal,
        "order": order,
        "updated": updated,
        "created": created,
        "pageCount": pageCount,
        "estimatedTime": estimatedTime,
        "analysisCount": analysisCount,
        "bookId": bookId,
        "publisher": publisher,
        "isbn": isbn,
        "tierMappings": tierMappings?.map((e) => e?.toJson()).toList(),
        "knowledgeCounts": knowledgeCounts?.map((e) => e?.toJson()).toList(),
        "difficulty": difficulty?.toJson(),
        "operation": operation,
        "useCount": useCount,
      };

  // 课程上下架状态
  CourseConditionType get newStatus => CourseConditionType.fromTitle(status ?? '');

  // 书籍状态
  BookAnalysisStatus get bookAnalysisStatus => BookAnalysisStatus.fromValue(status ?? '');

  // 更新时间
  String get newUpdate {
    if (updated == null) {
      return '';
    }

    return DateUtil.formatDateStr(updated!, format: "yyyy/MM/dd");
  }

  // 创建时间
  String get newCreate {
    if (created == null) {
      return '';
    }

    return DateUtil.formatDateStr(created!, format: "yyyy/MM/dd");
  }

  // 语言
  String get newLanguage {
    String? s;
    try {
      s = CommonUtil.language.map((element) => element[language]).toList().where((element) => element != null).toList().first;
    } catch (e) {
      if (kDebugMode) {
        // print('语言e:$e');
      }
    }
    return s ?? '';
  }

  // 上下架状态
  String get newAccess => StaticData.getOnOffShelfName(access) ?? '';

  // 是否上架
  bool get isAccess => StaticData.isOnOffShelfNormal(access);

  int get realEstimatedTime => estimatedTime != null ? (estimatedTime! % 60) : 0;

  @override
  int get hashCode => uid.hashCode;

  /// 创建当前对象的副本，允许覆盖特定字段的值
  ///
  /// 返回一个新的 [ModuleResponseEntity] 实例，包含原始对象的值，
  /// 除了被明确指定的参数会被替换为新值
  ModuleResponseEntity<T> copyWith(
      {String? name,
      String? cover,
      String? coverUrl,
      ModuleImageInfoEntity? image,
      List<int>? imageTaskIds,
      int? levelId,
      List<dynamic>? unitIds,
      List<T>? unitList,
      String? language,
      String? locale,
      String? description,
      String? scope,
      String? scopeName,
      String? vendor,
      String? vendorName,
      String? access,
      String? status,
      int? unitNormalCnt,
      int? unitTotal,
      num? order,
      String? updated,
      String? created,
      int? minDifficulty,
      int? maxDifficulty,
      int? uid,
      int? pageCount,
      int? estimatedTime,
      int? analysisCount,
      int? bookId,
      String? publisher,
      String? isbn,
      List<ThemeTextEntity?>? tierMappings,
      List<CourseLevelEntityLevelListModuleListKnowledgeCounts?>? knowledgeCounts,
      Difficulty? difficulty,
      int? operation}) {
    return ModuleResponseEntity<T>(
        name: name ?? this.name,
        cover: cover ?? this.cover,
        coverUrl: coverUrl ?? this.coverUrl,
        image: image ?? this.image,
        imageTaskIds: imageTaskIds ?? this.imageTaskIds,
        levelId: levelId ?? this.levelId,
        unitIds: unitIds ?? this.unitIds,
        unitList: unitList ?? this.unitList,
        language: language ?? this.language,
        locale: locale ?? this.locale,
        description: description ?? this.description,
        scope: scope ?? this.scope,
        scopeName: scopeName ?? this.scopeName,
        vendor: vendor ?? this.vendor,
        vendorName: vendorName ?? this.vendorName,
        access: access ?? this.access,
        status: status ?? this.status,
        unitNormalCnt: unitNormalCnt ?? this.unitNormalCnt,
        unitTotal: unitTotal ?? this.unitTotal,
        order: order ?? this.order,
        updated: updated ?? this.updated,
        created: created ?? this.created,
        minDifficulty: minDifficulty ?? this.minDifficulty,
        maxDifficulty: maxDifficulty ?? this.maxDifficulty,
        uid: uid ?? this.uid,
        pageCount: pageCount ?? this.pageCount,
        estimatedTime: estimatedTime ?? this.estimatedTime,
        analysisCount: analysisCount ?? this.analysisCount,
        bookId: bookId ?? this.bookId,
        publisher: publisher ?? this.publisher,
        isbn: isbn ?? this.isbn,
        tierMappings: tierMappings ?? this.tierMappings,
        knowledgeCounts: knowledgeCounts ?? this.knowledgeCounts,
        difficulty: difficulty ?? this.difficulty,
        operation: operation ?? this.operation);
  }

  @override
  bool operator ==(Object other) => other.runtimeType == runtimeType && other is ModuleResponseEntity && uid == other.uid;

  @override
  String toString() {
    return 'ModuleResponseEntity('
        'uid: $uid, '
        'name: $name, '
        'cover: $cover, '
        'coverUrl: $coverUrl, '
        'image: $image, '
        'imageTaskIds: $imageTaskIds, '
        'description: $description, '
        'levelId: $levelId, '
        'language: $language, '
        'locale: $locale, '
        'description: $description, '
        'scope: $scope, '
        'scopeName: $scopeName, '
        'vendor: $vendor, '
        'vendorName: $vendorName, '
        'access: $access, '
        'status: $status, '
        'unitNormalCnt: $unitNormalCnt, '
        'unitTotal: $unitTotal, '
        'order: $order, '
        'publisher: $publisher, '
        'tierMappings: $tierMappings, '
        'knowledgeCounts: $knowledgeCounts, '
        'difficulty: $difficulty, '
        'updated: $updated, '
        'created: $created,'
        ' operation: $operation)';
  }
}

List<int>? _parseIntList(dynamic value) {
  if (value is! List) return null;
  final List<int> result = <int>[];
  for (final item in value) {
    if (item is num) {
      result.add(item.toInt());
      continue;
    }
    final int? parsed = int.tryParse(item?.toString() ?? '');
    if (parsed != null) {
      result.add(parsed);
    }
  }
  return result;
}

class ModuleImageInfoEntity with JsonSerializableMixin {
  final int? imageId;
  final String? type;
  final int? contentId;
  final int? semanticId;
  final String? imageKey;
  final String? imageUrl;
  final String? md5;
  final int? styleId;
  final String? styleTitle;
  final String? localeTitle;
  final String? updated;

  const ModuleImageInfoEntity({
    this.imageId,
    this.type,
    this.contentId,
    this.semanticId,
    this.imageKey,
    this.imageUrl,
    this.md5,
    this.styleId,
    this.styleTitle,
    this.localeTitle,
    this.updated,
  });

  factory ModuleImageInfoEntity.fromJson(Map<String, dynamic> json) {
    return ModuleImageInfoEntity(
      imageId: json['imageId'] is num ? (json['imageId'] as num).toInt() : int.tryParse(json['imageId']?.toString() ?? ''),
      type: json['type']?.toString(),
      contentId: json['contentId'] is num ? (json['contentId'] as num).toInt() : int.tryParse(json['contentId']?.toString() ?? ''),
      semanticId: json['semanticId'] is num ? (json['semanticId'] as num).toInt() : int.tryParse(json['semanticId']?.toString() ?? ''),
      imageKey: json['imageKey']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      md5: json['md5']?.toString(),
      styleId: json['styleId'] is num ? (json['styleId'] as num).toInt() : int.tryParse(json['styleId']?.toString() ?? ''),
      styleTitle: json['styleTitle']?.toString(),
      localeTitle: json['localeTitle']?.toString(),
      updated: json['updated']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'imageId': imageId,
        'type': type,
        'contentId': contentId,
        'semanticId': semanticId,
        'imageKey': imageKey,
        'imageUrl': imageUrl,
        'md5': md5,
        'styleId': styleId,
        'styleTitle': styleTitle,
        'localeTitle': localeTitle,
        'updated': updated,
      };

  @override
  String toString() {
    return 'ModuleImageInfoEntity(imageId: $imageId, type: $type, contentId: $contentId, semanticId: $semanticId, styleId: $styleId)';
  }
}

class AppCourseModuleResponseEntity<T> extends Dessert with JsonSerializableMixin {
  final String? name;
  final String? cover;
  final String? coverUrl;
  final int? levelId;
  final List<dynamic>? unitIds;
  final List<T>? unitList;
  final String? language;
  final String? locale;
  final String? description;
  final String? scope;
  final String? scopeName;
  final String? vendor;
  final String? vendorName;
  final String? access;
  final String? status;
  final int? unitNormalCnt;
  final int? unitTotal;
  final num? order;
  final String? updated;
  final String? created;
  final int? minDifficulty;
  final int? maxDifficulty;
  final int? pageCount;
  final int? estimatedTime;
  final int? analysisCount;
  final int? bookId;
  final String? isbn;
  final int? difficulty;
  final int? operation;

  AppCourseModuleResponseEntity(
      {this.name,
      this.cover,
      this.coverUrl,
      this.levelId,
      this.unitIds,
      this.unitList,
      this.language,
      this.locale,
      this.description,
      this.scope,
      this.scopeName,
      this.vendor,
      this.vendorName,
      this.access,
      this.status,
      this.unitNormalCnt,
      this.unitTotal,
      this.order,
      this.updated,
      this.created,
      this.minDifficulty,
      this.maxDifficulty,
      this.pageCount,
      this.estimatedTime,
      this.analysisCount,
      this.bookId,
      this.isbn,
      this.difficulty,
      this.operation,
      required uid})
      : globalKey = GlobalKey(debugLabel: uid.toString()),
        super(uid: uid ?? 0);

  final GlobalKey globalKey;

  factory AppCourseModuleResponseEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    List<T>? unitList = [];
    if (json['unitList'] != null && json['unitList'].isNotEmpty) {
      if (fromJson != null) {
        unitList = json['unitList'].map((e) => fromJson(e)).cast<T>().toList();
      } else {
        unitList = json['unitList'] as List<T>?;
      }
    }

    return AppCourseModuleResponseEntity(
        uid: json["uid"],
        name: json["name"],
        cover: json["cover"],
        coverUrl: json["coverUrl"],
        levelId: json["levelId"],
        unitIds: json["unitIds"],
        unitList: unitList,
        language: json["language"],
        locale: json["locale"],
        description: json["description"],
        scope: json["scope"],
        scopeName: json["scopeName"],
        vendor: json["vendor"],
        vendorName: json["vendorName"],
        access: json["access"],
        status: json["status"],
        unitNormalCnt: json["unitNormalCnt"],
        unitTotal: json["unitTotal"],
        order: json["order"],
        updated: json["updated"],
        created: json["created"],
        minDifficulty: json["minDifficulty"],
        maxDifficulty: json["maxDifficulty"],
        pageCount: json["pageCount"],
        estimatedTime: json["estimatedTime"],
        analysisCount: json["analysisCount"],
        bookId: json["bookId"],
        difficulty: json["difficulty"],
        isbn: json["isbn"],
        operation: json['operation']);
  }

  @override
  Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "cover": cover,
        "coverUrl": coverUrl,
        "levelId": levelId,
        "unitIds": unitIds,
        "language": language,
        "locale": locale,
        "description": description,
        "scope": scope,
        "scopeName": scopeName,
        "vendor": vendor,
        "vendorName": vendorName,
        "access": access,
        "unitNormalCnt": unitNormalCnt,
        "unitTotal": unitTotal,
        "order": order,
        "updated": updated,
        "created": created,
        "pageCount": pageCount,
        "estimatedTime": estimatedTime,
        "analysisCount": analysisCount,
        "bookId": bookId,
        "isbn": isbn,
        "difficulty": difficulty,
        "operation": operation
      };

  // 课程上下架状态
  CourseConditionType get newStatus => CourseConditionType.fromTitle(status ?? '');

  // 书籍状态
  BookAnalysisStatus get bookAnalysisStatus => BookAnalysisStatus.fromValue(status ?? '');

  // 更新时间
  String get newUpdate {
    if (updated == null) {
      return '';
    }

    return DateUtil.formatDateStr(updated!, format: "yyyy/MM/dd");
  }

  // 创建时间
  String get newCreate {
    if (created == null) {
      return '';
    }

    return DateUtil.formatDateStr(created!, format: "yyyy/MM/dd");
  }

  // 语言
  String get newLanguage {
    String? s;
    try {
      s = CommonUtil.language.map((element) => element[language]).toList().where((element) => element != null).toList().first;
    } catch (e) {
      if (kDebugMode) {
        // print('语言e:$e');
      }
    }
    return s ?? '';
  }

  // 上下架状态
  String get newAccess => StaticData.getOnOffShelfName(access) ?? '';

  // 是否上架
  bool get isAccess => StaticData.isOnOffShelfNormal(access);

  int get realEstimatedTime => estimatedTime != null ? (estimatedTime! % 60) : 0;

  // 是否ai
  bool get isAi => operation != null && operation! >= 1;

  @override
  int get hashCode => uid.hashCode;

  /// 创建当前对象的副本，允许覆盖特定字段的值
  ///
  /// 返回一个新的 [AppCourseModuleResponseEntity] 实例，包含原始对象的值，
  /// 除了被明确指定的参数会被替换为新值
  AppCourseModuleResponseEntity<T> copyWith(
      {String? name,
      String? cover,
      String? coverUrl,
      int? levelId,
      List<dynamic>? unitIds,
      List<T>? unitList,
      String? language,
      String? locale,
      String? description,
      String? scope,
      String? scopeName,
      String? vendor,
      String? vendorName,
      String? access,
      String? status,
      int? unitNormalCnt,
      int? unitTotal,
      num? order,
      String? updated,
      String? created,
      int? minDifficulty,
      int? maxDifficulty,
      int? uid,
      int? pageCount,
      int? estimatedTime,
      int? analysisCount,
      int? bookId,
      String? isbn,
      int? difficulty,
      int? operation}) {
    return AppCourseModuleResponseEntity<T>(
        name: name ?? this.name,
        cover: cover ?? this.cover,
        coverUrl: coverUrl ?? this.coverUrl,
        levelId: levelId ?? this.levelId,
        unitIds: unitIds ?? this.unitIds,
        unitList: unitList ?? this.unitList,
        language: language ?? this.language,
        locale: locale ?? this.locale,
        description: description ?? this.description,
        scope: scope ?? this.scope,
        scopeName: scopeName ?? this.scopeName,
        vendor: vendor ?? this.vendor,
        vendorName: vendorName ?? this.vendorName,
        access: access ?? this.access,
        status: status ?? this.status,
        unitNormalCnt: unitNormalCnt ?? this.unitNormalCnt,
        unitTotal: unitTotal ?? this.unitTotal,
        order: order ?? this.order,
        updated: updated ?? this.updated,
        created: created ?? this.created,
        minDifficulty: minDifficulty ?? this.minDifficulty,
        maxDifficulty: maxDifficulty ?? this.maxDifficulty,
        uid: uid ?? this.uid,
        pageCount: pageCount ?? this.pageCount,
        estimatedTime: estimatedTime ?? this.estimatedTime,
        analysisCount: analysisCount ?? this.analysisCount,
        bookId: bookId ?? this.bookId,
        isbn: isbn ?? this.isbn,
        difficulty: difficulty,
        operation: operation ?? this.operation);
  }

  @override
  bool operator ==(Object other) => other.runtimeType == runtimeType && other is AppCourseModuleResponseEntity && uid == other.uid;

  @override
  String toString() {
    return 'AppCourseModuleResponseEntity('
        'uid: $uid, '
        'name: $name, '
        'cover: $cover, '
        'coverUrl: $coverUrl, '
        'description: $description, '
        'levelId: $levelId, '
        'language: $language, '
        'locale: $locale, '
        'description: $description, '
        'scope: $scope, '
        'scopeName: $scopeName, '
        'vendor: $vendor, '
        'vendorName: $vendorName, '
        'access: $access, '
        'status: $status, '
        'unitNormalCnt: $unitNormalCnt, '
        'unitTotal: $unitTotal, '
        'order: $order, '
        'difficulty: $difficulty, '
        'updated: $updated, '
        'created: $created,'
        ' operation: $operation)';
  }
}

class MiniUnitResponseEntity {
  final int? uid;
  final String? name;

  MiniUnitResponseEntity({this.uid, this.name}) : globalKey = GlobalKey(debugLabel: uid.toString());

  final GlobalKey globalKey;

  factory MiniUnitResponseEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return MiniUnitResponseEntity(uid: json["uid"], name: json["name"]);
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
      };

  @override
  String toString() {
    return 'MiniUnitResponseEntity('
        'uid: $uid, '
        'name: $name, '
        'cover: $globalKey, )';
  }
}

class UnitResponseEntity extends Dessert {
  // final 确保不可变性
  final String uniqueId;
  final int? unitId;
  final String? unitName;
  final String? contentType;
  final String? content;
  final int? semanticId;
  final String? definition;
  final String? imageUrl;
  final String? audioUrl;
  final String? inventory;
  final String? sourceModule;
  final String? sourceUnit;
  final String? sourceLesson;
  final int? pageIdx;
  final bool isMatched;
  final String? target;
  final double? similarity;

  UnitResponseEntity(
      {String? uniqueId,
      this.unitId,
      this.unitName,
      this.contentType,
      this.content,
      this.semanticId,
      this.definition,
      this.imageUrl,
      this.audioUrl,
      this.inventory,
      this.sourceModule,
      this.sourceUnit,
      this.sourceLesson,
      this.pageIdx,
      this.isMatched = false,
      this.target,
      this.similarity,
      required super.uid,
      super.calories})
      : uniqueId = uniqueId ?? _generateUniqueId(); // 生成逻辑抽离

  factory UnitResponseEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) => UnitResponseEntity(
      uniqueId: json["uniqueId"],
      uid: json["uid"] ?? 0,
      unitId: json["unitId"],
      unitName: json["unitName"],
      contentType: json["contentType"],
      content: json["content"],
      semanticId: json["semanticId"],
      definition: json["definition"],
      imageUrl: json["imageUrl"],
      audioUrl: json["audioUrl"],
      calories: 0,
      inventory: json["inventory"],
      sourceModule: json["sourceModule"],
      sourceUnit: json["sourceUnit"],
      sourceLesson: json["sourceLesson"],
      pageIdx: json["pageIdx"],
      isMatched: json["isMatched"] ?? false,
      target: json["target"],
      similarity: json["similarity"] != null ? (json["similarity"] as num).toDouble() : null);

  Map<String, dynamic> toJson() => {
        "uniqueId": uniqueId,
        "uid": uid,
        "unitId": unitId,
        "unitName": unitName,
        "contentType": contentType,
        "content": content,
        "semanticId": semanticId,
        "definition": definition,
        "imageUrl": imageUrl,
        "audioUrl": audioUrl,
        "inventory": inventory,
        "sourceModule": sourceModule,
        "sourceUnit": sourceUnit,
        "sourceLesson": sourceLesson,
        "pageIdx": pageIdx,
        "isMatched": isMatched,
        "target": target,
        "similarity": similarity
      };

  // 实现 copyWith 方法
  UnitResponseEntity copyWith({
    String? uniqueId,
    int? unitId,
    String? unitName,
    String? contentType,
    String? content,
    int? semanticId,
    String? definition,
    String? imageUrl,
    String? audioUrl,
    String? inventory,
    String? sourceModule,
    String? sourceUnit,
    String? sourceLesson,
    int? pageIdx,
    bool? isMatched,
    String? target,
    double? similarity,
    int? uid,
    int? calories,
  }) {
    return UnitResponseEntity(
      uniqueId: uniqueId ?? this.uniqueId,
      unitId: unitId ?? this.unitId,
      unitName: unitName ?? this.unitName,
      contentType: contentType ?? this.contentType,
      content: content ?? this.content,
      semanticId: semanticId ?? this.semanticId,
      definition: definition ?? this.definition,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      inventory: inventory ?? this.inventory,
      sourceModule: sourceModule ?? this.sourceModule,
      sourceUnit: sourceUnit ?? this.sourceUnit,
      sourceLesson: sourceLesson ?? this.sourceLesson,
      pageIdx: pageIdx ?? this.pageIdx,
      isMatched: isMatched ?? this.isMatched,
      target: target ?? this.target,
      similarity: similarity ?? this.similarity,
      uid: uid ?? this.uid,
      calories: calories ?? this.calories,
    );
  }

  /// 唯一ID生成策略
  static String _generateUniqueId() {
    return const Uuid().v6();
  }

  KnowledgeType get newKnowledgeType => KnowledgeType.fromValue(contentType ?? '');

  InventoryType get newInventory => InventoryType.fromValue(inventory ?? '');

  /// 判断是否匹配的getter方法
  bool get hasMatch => isMatched;

  /// 相等性判断优化
  @override
  bool operator ==(Object other) => identical(this, other) || (other is UnitResponseEntity && uniqueId == other.uniqueId);

  @override
  int get hashCode => uniqueId.hashCode;
}

// module详情
class CourseModuleInfoResponseEntity<T extends JsonSerializable, U extends JsonSerializable> with JsonSerializableMixin {
  final T? courseModuleInfo;
  final List<U>? courseUnitList;

  CourseModuleInfoResponseEntity({
    this.courseModuleInfo,
    this.courseUnitList,
  });

  factory CourseModuleInfoResponseEntity.fromJson(
    Map<String, dynamic> json, {
    required T Function(Map<String, dynamic>) buildCourseInfo,
    required U Function(Map<String, dynamic>) buildCourseLevel,
  }) {
    return CourseModuleInfoResponseEntity(
      courseModuleInfo: json['courseModuleInfo'] != null ? buildCourseInfo(json['courseModuleInfo']) : null,
      courseUnitList: json['courseUnitList'] != null ? (json['courseUnitList'] as List).map((e) => buildCourseLevel(e)).toList() : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        "courseModuleInfo": courseModuleInfo?.toJson(),
        "courseUnitList": courseUnitList?.map((e) => e.toJson()).toList(),
      };
}

class AppModuleResponseEntity<T, U> extends Dessert with JsonSerializableMixin {
  final String? name;
  final String? cover;
  final String? coverUrl;
  final List<T>? unitList;
  final List<U>? unGrouped;
  final String? description;
  final String? status;
  final String? language;
  final int? pageCount;
  final int? estimatedTime;
  final int? analysisCount;

  AppModuleResponseEntity(
      {this.name,
      this.cover,
      this.coverUrl,
      this.unitList,
      this.unGrouped,
      this.description,
      this.status,
      this.language,
      this.pageCount,
      this.estimatedTime,
      this.analysisCount,
      required uid})
      : globalKey = GlobalKey(debugLabel: uid.toString()),
        super(uid: uid ?? 0);

  final GlobalKey globalKey;

  factory AppModuleResponseEntity.fromJson(
    Map<String, dynamic> json, {
    Function? fromJson,
    Function? fromUnGroupedJson,
  }) {
    List<T>? unitList = [];
    if (json['unitList'] != null && json['unitList'].isNotEmpty) {
      if (fromJson != null) {
        unitList = json['unitList'].map((e) => fromJson(e)).cast<T>().toList();
      } else {
        unitList = json['unitList'] as List<T>?;
      }
    }

    List<U>? unGrouped = [];
    if (json['unGrouped'] != null && json['unGrouped'].isNotEmpty) {
      if (fromUnGroupedJson != null) {
        unGrouped = json['unGrouped'].map((e) => fromUnGroupedJson(e)).cast<U>().toList();
      } else {
        unGrouped = json['unGrouped'] as List<U>?;
      }
    }

    return AppModuleResponseEntity(
      uid: json["uid"],
      name: json["name"],
      cover: json["cover"],
      coverUrl: json["coverUrl"],
      unitList: unitList,
      unGrouped: unGrouped,
      description: json["description"],
      status: json["status"],
      language: json["language"],
      pageCount: json["pageCount"],
      estimatedTime: json["estimatedTime"],
      analysisCount: json["analysisCount"],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "cover": cover,
        "coverUrl": coverUrl,
        "description": description,
        "language": language,
        "pageCount": pageCount,
        "estimatedTime": estimatedTime,
        "analysisCount": analysisCount,
      };

  // 书籍状态
  BookAnalysisStatus get bookAnalysisStatus => BookAnalysisStatus.fromValue(status ?? '');

  // 语言
  String get newLanguage {
    String? s;
    try {
      s = CommonUtil.language.map((element) => element[language]).toList().where((element) => element != null).toList().first;
    } catch (e) {
      if (kDebugMode) {
        // print('语言e:$e');
      }
    }
    return s ?? '';
  }

  int get realEstimatedTime => estimatedTime != null ? (estimatedTime! % 60) : 0;

  @override
  int get hashCode => uid.hashCode;

  /// 创建当前对象的副本，允许覆盖特定字段的值
  ///
  /// 返回一个新的 [ModuleResponseEntity] 实例，包含原始对象的值，
  /// 除了被明确指定的参数会被替换为新值
  AppModuleResponseEntity<T, U> copyWith({
    int? uid,
    String? name,
    String? cover,
    String? coverUrl,
    List<T>? unitList,
    List<U>? unGrouped,
    String? language,
    String? description,
    String? status,
    int? pageCount,
    int? estimatedTime,
    int? analysisCount,
  }) {
    return AppModuleResponseEntity<T, U>(
      name: name ?? this.name,
      cover: cover ?? this.cover,
      coverUrl: coverUrl ?? this.coverUrl,
      unitList: unitList ?? this.unitList,
      unGrouped: unGrouped ?? this.unGrouped,
      language: language ?? this.language,
      description: description ?? this.description,
      status: status ?? this.status,
      uid: uid ?? this.uid,
      pageCount: pageCount ?? this.pageCount,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      analysisCount: analysisCount ?? this.analysisCount,
    );
  }

  @override
  bool operator ==(Object other) => other.runtimeType == runtimeType && other is ModuleResponseEntity && uid == other.uid;

  @override
  String toString() {
    return 'AppModuleResponseEntity('
        'uid: $uid, '
        'name: $name, '
        'cover: $cover, '
        'coverUrl: $coverUrl, '
        'description: $description, '
        'language: $language, '
        'description: $description, '
        'status: $status)';
  }
}

class AppUnitResponseEntity<T> with JsonSerializableMixin {
  final int uid;
  final String? name;
  final List<T>? knowledgeList;
  final String? language;
  final String? description;

  AppUnitResponseEntity({
    required this.uid,
    this.name,
    this.knowledgeList,
    this.language,
    this.description,
  }) : globalKey = GlobalKey(debugLabel: uid.toString());

  final GlobalKey globalKey;

  factory AppUnitResponseEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    List<T>? knowledgeList = [];
    if (json['knowledgeList'] != null && json['knowledgeList'].isNotEmpty) {
      if (fromJson != null) {
        knowledgeList = json['knowledgeList'].map((e) => fromJson(e)).cast<T>().toList();
      } else {
        knowledgeList = json['knowledgeList'] as List<T>?;
      }
    }

    return AppUnitResponseEntity(
      uid: json["uid"],
      name: json["name"],
      language: json["language"],
      description: json["description"],
      knowledgeList: knowledgeList,
    );
  }

  @override
  Map<String, dynamic> toJson() => {"uid": uid, "name": name, "language": language, "description": description, "knowledgeList": knowledgeList};

  // 语言
  String get newLanguage {
    String? s;
    try {
      s = CommonUtil.language.map((element) => element[language]).toList().where((element) => element != null).toList().first;
    } catch (e) {
      if (kDebugMode) {
        // print('语言e:$e');
      }
    }
    return s ?? '';
  }

  bool get hasKnowledgeList => knowledgeList != null && knowledgeList!.isNotEmpty;

  // 是添加按钮
  bool get isAddUnit => uid == -1;

  @override
  int get hashCode => uid.hashCode;

  /// 创建当前对象的副本，允许覆盖特定字段的值
  ///
  /// 返回一个新的 [AppUnitResponseEntity] 实例，包含原始对象的值，
  /// 除了被明确指定的参数会被替换为新值
  AppUnitResponseEntity<T> copyWith({int? uid, String? name, List<T>? knowledgeList, String? language, String? description}) {
    return AppUnitResponseEntity<T>(
      name: name ?? this.name,
      knowledgeList: knowledgeList ?? this.knowledgeList,
      language: language ?? this.language,
      description: description ?? this.description,
      uid: uid ?? this.uid,
    );
  }

  @override
  bool operator ==(Object other) => other.runtimeType == runtimeType && other is AppUnitResponseEntity && uid == other.uid;

  @override
  String toString() {
    return 'AppUnitResponseEntity('
        'uid: $uid, '
        'name: $name, '
        'knowledgeList: $knowledgeList, '
        'description: $description, '
        'language: $language, '
        'description: $description, )';
  }
}

class Difficulty {
/*
{
  "max": 3,
  "min": 3
}
*/

  int? max;
  int? min;

  Difficulty({
    this.max,
    this.min,
  });

  Difficulty.fromJson(Map<String, dynamic> json) {
    max = json['max']?.toInt();
    min = json['min']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['max'] = max;
    data['min'] = min;
    return data;
  }
}
