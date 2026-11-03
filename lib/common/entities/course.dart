// 课程Response

import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/utils/utils.dart';
import 'package:uuid/uuid.dart';

import 'json.dart';

class CourseResponseEntity with JsonSerializableMixin {
  final int? uid;
  final String? name;
  final String? cover;
  final String? coverUrl;
  final String? description;
  final String? specialty;
  final List<dynamic>? levelIds;
  final String? language;
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

  CourseResponseEntity(
      {this.uid,
      this.name,
      this.cover,
      this.coverUrl,
      this.description,
      this.specialty,
      this.levelIds,
      this.language,
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
      this.maxDifficulty})
      : globalKey = GlobalKey(debugLabel: uid.toString());

  final GlobalKey globalKey;

  factory CourseResponseEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) => CourseResponseEntity(
      uid: json["uid"],
      name: json["name"],
      cover: json["cover"],
      coverUrl: json["coverUrl"],
      description: json["description"],
      specialty: json["specialty"],
      levelIds: json["levelIds"],
      language: json["language"],
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
      maxDifficulty: json["maxDifficulty"]);

  @override
  Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "cover": cover,
        "coverUrl": coverUrl,
        "description": description,
        "specialty": specialty,
        "levelIds": levelIds,
        "language": language,
        "scope": scope,
        "scopeName": scopeName,
        "vendor": vendor,
        "vendorName": vendorName,
        "access": access,
        "unitNormalCnt": unitNormalCnt,
        "unitTotal": unitTotal,
        "order": order,
        "updated": updated,
        "created": created
      };

  // 课程上下架状态
  CourseConditionType get newStatus => CourseConditionType.fromTitle(status ?? '');

  // 更新时间
  String get newUpdate {
    if (updated == null) {
      return '';
    }

    return DateUtil.formatDateStr(updated!, format: "yyyy/MM/dd");
  }

  // 语言
  String get newLanguage {
    String? s;
    try {
      s = CommonUtil.language
          .map((element) => element[language])
          .toList()
          .where((element) => element != null)
          .toList()
          .first;
    } catch (e) {
      if (kDebugMode) {
        // print('语言e:$e');
      }
    }
    return s ?? '';
  }

  @override
  String toString() {
    return 'CourseResponseEntity('
        'uid: $uid, '
        'name: $name, '
        'cover: $cover, '
        'coverUrl: $coverUrl, '
        'description: $description, '
        'specialty: $specialty, '
        'levelIds: $levelIds, '
        'language: $language, '
        'scope: $scope, '
        'scopeName: $scopeName, '
        'vendor: $vendor, '
        'vendorName: $vendorName, '
        'access: $access, '
        'status: $status, '
        'unitNormalCnt: $unitNormalCnt, '
        'unitTotal: $unitTotal, '
        'order: $order, '
        'updated: $updated, '
        'created: $created)';
  }
}

// 课程详情
class CourseInfoResponseEntity<T extends JsonSerializable, U extends JsonSerializable> {
  final T? courseInfo;
  final List<U>? courseLevelList;

  CourseInfoResponseEntity({
    this.courseInfo,
    this.courseLevelList,
  });

  factory CourseInfoResponseEntity.fromJson(
    Map<String, dynamic> json, {
    required T Function(Map<String, dynamic>) buildCourseInfo,
    required U Function(Map<String, dynamic>) buildCourseLevel,
  }) {
    return CourseInfoResponseEntity(
      courseInfo: json['courseInfo'] != null ? buildCourseInfo(json['courseInfo']) : null,
      courseLevelList: json['courseLevelList'] != null
          ? (json['courseLevelList'] as List).map((e) => buildCourseLevel(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "courseInfo": courseInfo?.toJson(),
        "courseLevelList": courseLevelList?.map((e) => e.toJson()).toList(),
      };
}

/// 课程信息响应实体类
class AppCourseInfoResponseEntity<T> with JsonSerializableMixin {
  final int? uid;
  final String? name;
  final String? cover;
  final String? coverUrl;
  final String? description;
  final String? language;
  final List<T>? levelList;
  final String uniqueId;
  final GlobalKey globalKey;

  AppCourseInfoResponseEntity({
    String? uniqueId,
    this.uid,
    this.name,
    this.cover,
    this.coverUrl,
    this.description,
    this.language,
    this.levelList,
  })  : uniqueId = uniqueId ?? _generateUniqueId(),
        globalKey = GlobalKey(debugLabel: uid.toString());

  /// 唯一ID生成策略
  static String _generateUniqueId() {
    return const Uuid().v6();
  }

  /// JSON序列化
  @override
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'cover': cover,
      'coverUrl': coverUrl,
      'description': description,
      'language': language,
      'levelList': levelList is List<JsonSerializable>
          ? (levelList as List<JsonSerializable>).map((e) => e.toJson()).toList()
          : levelList,
    };
  }

  /// 创建一个具有新值的拷贝
  AppCourseInfoResponseEntity<T> copyWith({
    String? uniqueId,
    int? uid,
    String? name,
    String? cover,
    String? coverUrl,
    String? description,
    String? language,
    List<T>? levelList,
  }) {
    return AppCourseInfoResponseEntity<T>(
      uniqueId: uniqueId ?? this.uniqueId,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      cover: cover ?? this.cover,
      coverUrl: coverUrl ?? this.coverUrl,
      description: description ?? this.description,
      language: language ?? this.language,
      levelList: levelList ?? this.levelList,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is AppCourseInfoResponseEntity && other.uid == uid;
  }

  @override
  int get hashCode => Object.hash(runtimeType, uid);

  /// 从JSON创建实例，支持泛型模块列表
  factory AppCourseInfoResponseEntity.fromJson(
    Map<String, dynamic> json, {
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    List<T>? levelList;
    if (json['levelList'] != null) {
      levelList = (json['levelList'] as List)
          .map((item) {
            if (fromJson != null) {
              return fromJson(item as Map<String, dynamic>);
            } else {
              return item;
            }
          })
          .cast<T>()
          .toList();
    }

    return AppCourseInfoResponseEntity<T>(
      uid: json['uid'],
      name: json['name'],
      cover: json['cover'],
      coverUrl: json['coverUrl'],
      description: json['description'],
      language: json['language'],
      levelList: levelList,
    );
  }
}

/// 课程状态响应实体
///
/// 用于封装课程创建状态的API响应数据
class CourseStatusResponseEntity with JsonSerializableMixin {
  /// 是否完成
  final bool? finished;

  /// 状态列表
  final List<CourseStatusItemEntity>? statuses;

  CourseStatusResponseEntity({
    this.finished,
    this.statuses,
  });

  /// 获取课程是否完成状态
  ///
  /// 返回课程创建是否已完成，如果为null则返回false
  bool get isFinished => finished ?? false;

  /// 从JSON创建实体
  ///
  /// [json] JSON数据
  factory CourseStatusResponseEntity.fromJson(Map<String, dynamic> json) {
    List<CourseStatusItemEntity>? statusList;
    if (json['statuses'] != null) {
      statusList = (json['statuses'] as List).map((item) => CourseStatusItemEntity.fromJson(item)).toList();
    }

    return CourseStatusResponseEntity(
      finished: json['finished'],
      statuses: statusList,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'finished': finished,
      'statuses': statuses?.map((item) => item.toJson()).toList(),
    };
  }
}

/// 课程状态项实体
///
/// 表示课程创建过程中的单个状态项
class CourseStatusItemEntity with JsonSerializableMixin {
  /// 状态代码
  final String? code;

  /// 状态标题
  final String? title;

  /// 是否为当前状态
  final bool? current;

  /// 是否已完成
  final bool? completed;

  final int? operation;

  CourseStatusItemEntity({this.code, this.title, this.current, this.completed, this.operation});

  /// 获取是否为当前状态
  ///
  /// 返回该状态项是否为当前状态，如果为null则返回false
  bool get isCurrent => current ?? false;

  /// 获取是否已完成状态
  ///
  /// 返回该状态项是否已完成，如果为null则返回false
  bool get isCompleted => completed ?? false;

  /// 是否ai
  bool get isAi => operation != null && operation! >= 1;

  /// 从JSON创建实体
  ///
  /// [json] JSON数据
  factory CourseStatusItemEntity.fromJson(Map<String, dynamic> json) {
    return CourseStatusItemEntity(
      code: json['code'],
      title: json['title'],
      current: json['current'],
      completed: json['completed'],
      operation: json['operation'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'code': code, 'title': title, 'current': current, 'completed': completed, 'operation': operation};
  }
}

/// 课程生成状态信息响应实体
///
/// 用于封装课程生成过程中各个步骤的详细状态信息
class CourseGenerateStatusResponseEntity with JsonSerializableMixin {
  /// 课程标题
  final String? courseTitle;

  /*
    * 1. 正在进行
    * 2. 全部生成完成
    * 3. 生成失败
    */
  final int? generateStatus;

  /// 每个ai步骤是否执行过动画
  final List? notDisplayed;

  /// 课程描述
  final String? courseDescription;

  /// 课程模块框架构建状态
  final CourseGenerateStepEntity? moduleFramework;

  /// 单元学习计划规划状态
  final CourseGenerateStepEntity? unitPlan;

  /// 句子生成状态
  final CourseGenerateStepEntity? sentenceGeneration;

  /// 课时生成状态
  final CourseGenerateStepEntity? lessonGeneration;

  /// 具体教学内容生成状态
  final CourseGenerateStepEntity? contentGeneration;

  CourseGenerateStatusResponseEntity({
    this.courseTitle,
    this.generateStatus,
    this.notDisplayed,
    this.courseDescription,
    this.moduleFramework,
    this.unitPlan,
    this.sentenceGeneration,
    this.lessonGeneration,
    this.contentGeneration,
  });

  /// 检查所有步骤是否已完成
  ///
  /// 返回true如果所有步骤都已完成，否则返回false
  bool get isAllStepsCompleted {
    return (moduleFramework?.isCompleted ?? false) &&
        (unitPlan?.isCompleted ?? false) &&
        (sentenceGeneration?.isCompleted ?? false) &&
        (lessonGeneration?.isCompleted ?? false) &&
        (contentGeneration?.isCompleted ?? false);
  }

  /// 获取已完成的步骤数量
  ///
  /// 返回已完成步骤的数量
  int get completedStepsCount {
    int count = 0;
    if (moduleFramework?.isCompleted ?? false) count++;
    if (unitPlan?.isCompleted ?? false) count++;
    if (sentenceGeneration?.isCompleted ?? false) count++;
    if (lessonGeneration?.isCompleted ?? false) count++;
    if (contentGeneration?.isCompleted ?? false) count++;
    return count;
  }

  /// 从JSON创建实体
  ///
  /// [json] JSON数据
  factory CourseGenerateStatusResponseEntity.fromJson(Map<String, dynamic> json) {
    return CourseGenerateStatusResponseEntity(
      courseTitle: json['courseTitle'],
      generateStatus: json['generateStatus'],
      notDisplayed: json['notDisplayed'] ?? [],
      courseDescription: json['courseDescription'],
      moduleFramework:
          json['moduleFramework'] != null ? CourseGenerateStepEntity.fromJson(json['moduleFramework']) : null,
      unitPlan: json['unitPlan'] != null ? CourseGenerateStepEntity.fromJson(json['unitPlan']) : null,
      sentenceGeneration:
          json['sentenceGeneration'] != null ? CourseGenerateStepEntity.fromJson(json['sentenceGeneration']) : null,
      lessonGeneration:
          json['lessonGeneration'] != null ? CourseGenerateStepEntity.fromJson(json['lessonGeneration']) : null,
      contentGeneration:
          json['contentGeneration'] != null ? CourseGenerateStepEntity.fromJson(json['contentGeneration']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'courseTitle': courseTitle,
      'generateStatus': generateStatus,
      'notDisplayed': notDisplayed,
      'courseDescription': courseDescription,
      'moduleFramework': moduleFramework?.toJson(),
      'unitPlan': unitPlan?.toJson(),
      'sentenceGeneration': sentenceGeneration?.toJson(),
      'lessonGeneration': lessonGeneration?.toJson(),
      'contentGeneration': contentGeneration?.toJson(),
    };
  }
}

/// 课程生成步骤状态实体
///
/// 表示课程生成过程中单个步骤的详细状态信息
class CourseGenerateStepEntity with JsonSerializableMixin {
  /// 步骤名称
  final String? stepName;

  /// 状态描述
  final String? statusDescription;

  /// 统计信息
  final String? statisticsInfo;

  /// 是否已完成
  final bool? completed;

  /// 完成时间
  final String? completedTime;

  final bool? isFailed;

  CourseGenerateStepEntity({
    this.stepName,
    this.statusDescription,
    this.statisticsInfo,
    this.completed,
    this.completedTime,
    this.isFailed,
  });

  /// 获取是否已完成状态
  ///
  /// 返回该步骤是否已完成，如果为null则返回false
  bool get isCompleted => completed ?? false;

  /// 获取格式化的完成时间
  ///
  /// 返回格式化后的完成时间字符串，如果为null则返回空字符串
  String get formattedCompletedTime => completedTime ?? '';

  /// 从JSON创建实体
  ///
  /// [json] JSON数据
  factory CourseGenerateStepEntity.fromJson(Map<String, dynamic> json) {
    return CourseGenerateStepEntity(
      stepName: json['stepName'],
      statusDescription: json['statusDescription'],
      statisticsInfo: json['statisticsInfo'],
      completed: json['completed'],
      completedTime: json['completedTime'],
      isFailed: json['isFailed'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'stepName': stepName,
      'statusDescription': statusDescription,
      'statisticsInfo': statisticsInfo,
      'completed': completed,
      'completedTime': completedTime,
      'isFailed': isFailed,
    };
  }
}
