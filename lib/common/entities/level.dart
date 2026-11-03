import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/values/app_constant.dart';
import 'package:langwise/common/widgets/data_table_widget/data_table.dart';
import 'package:langwise/utils/utils.dart';

import 'json.dart';

class LevelResponseEntity<T> extends Dessert with JsonSerializableMixin {
  final int? courseId;
  final String? name;
  final String? description;
  final String? language;
  final String? coverUrl;
  final List<int?>? moduleIds;
  final List<T>? moduleList;
  final List<T>? moduleDTOList;
  final String? scope;
  final String? scopeName;
  final String? vendor;
  final String? vendorName;
  final String? access;
  final int? unitNormalCnt;
  final int? unitTotal;
  final num? order;
  final String? updated;
  final String? created;
  final int? tier;

  LevelResponseEntity({
    this.courseId,
    this.name,
    this.description,
    this.language,
    this.coverUrl,
    this.moduleIds,
    this.moduleList,
    this.moduleDTOList,
    this.scope,
    this.scopeName,
    this.vendor,
    this.vendorName,
    this.access,
    this.unitNormalCnt,
    this.unitTotal,
    this.order,
    this.updated,
    this.created,
    this.tier,
    required int uid,
  })  : globalKey = GlobalKey(debugLabel: uid.toString()),
        super(uid: uid);

  final GlobalKey globalKey;

  factory LevelResponseEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    List<T>? moduleList = [];
    if (json['moduleList'] != null && json['moduleList'].isNotEmpty) {
      if (fromJson != null) {
        moduleList = json['moduleList'].map((e) => fromJson(e)).cast<T>().toList();
      } else {
        moduleList = json['moduleList'] as List<T>?;
      }
    }

    List<T>? moduleDTOList = [];
    if (json['moduleDTOList'] != null && json['moduleDTOList'].isNotEmpty) {
      if (fromJson != null) {
        moduleDTOList = json['moduleDTOList'].map((e) => fromJson(e)).cast<T>().toList();
      } else {
        moduleDTOList = json['moduleDTOList'] as List<T>?;
      }
    }

    return LevelResponseEntity(
      uid: json["uid"],
      courseId: json["courseId"],
      name: json["name"],
      description: json["description"],
      language: json["language"],
      coverUrl: json["coverUrl"],
      moduleIds: json["moduleIds"] != null ? List<int>.from(json["moduleIds"]) : null,
      moduleList: moduleList,
      moduleDTOList: moduleDTOList,
      scope: json["scope"],
      scopeName: json["scopeName"],
      vendor: json["vendor"],
      vendorName: json["vendorName"],
      access: json["access"],
      unitNormalCnt: json["unitNormalCnt"],
      unitTotal: json["unitTotal"],
      order: json["order"],
      updated: json["updated"],
      created: json["created"],
      tier: json["tier"],
    );
  }

  @override
  // 在 LevelResponseEntity 类中扩展 toJson 方法
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      "uid": uid,
      "courseId": courseId,
      "name": name,
      "description": description,
      "language": language,
      "coverUrl": coverUrl,
      "moduleIds": moduleIds,
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
      "tier": tier,
    };

    // 安全地处理可能没有 toJson 方法的泛型类型
    if (moduleList != null) {
      try {
        // 尝试调用 toJson，如果支持的话
        json["moduleList"] = moduleList!.map((m) {
          if (m is JsonSerializable) {
            return m.toJson();
          } else {
            return m; // 如果不支持 toJson，则直接使用原始对象
          }
        }).toList();
      } catch (e) {
        // 如果出错，则跳过这个字段
        print("Warning: Could not serialize moduleList: $e");
      }
    }

    if (moduleDTOList != null) {
      try {
        json["moduleDTOList"] = moduleDTOList!.map((m) {
          if (m is JsonSerializable) {
            return m.toJson();
          } else {
            return m;
          }
        }).toList();
      } catch (e) {
        print("Warning: Could not serialize moduleDTOList: $e");
      }
    }

    return json;
  }

  LevelResponseEntity<T> copyWith({
    int? courseId,
    String? name,
    String? description,
    String? language,
    String? coverUrl,
    List<int?>? moduleIds,
    List<T>? moduleList,
    List<T>? moduleDTOList,
    String? scope,
    String? scopeName,
    String? vendor,
    String? vendorName,
    String? access,
    int? unitNormalCnt,
    int? unitTotal,
    num? order,
    String? updated,
    String? created,
    int? uid,
  }) {
    return LevelResponseEntity<T>(
        courseId: courseId ?? this.courseId,
        name: name ?? this.name,
        description: description ?? this.description,
        language: language ?? this.language,
        coverUrl: coverUrl ?? this.coverUrl,
        moduleIds: moduleIds ?? this.moduleIds,
        moduleList: moduleList ?? this.moduleList,
        moduleDTOList: moduleDTOList ?? this.moduleDTOList,
        scope: scope ?? this.scope,
        scopeName: scopeName ?? this.scopeName,
        vendor: vendor ?? this.vendor,
        vendorName: vendorName ?? this.vendorName,
        access: access ?? this.access,
        unitNormalCnt: unitNormalCnt ?? this.unitNormalCnt,
        unitTotal: unitTotal ?? this.unitTotal,
        order: order ?? this.order,
        updated: updated ?? this.updated,
        created: created ?? this.created,
        uid: uid ?? this.uid);
  }

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

  bool get hasModuleList => moduleList != null && moduleList!.isNotEmpty;

  // 上下架状态
  String get newAccess => StaticData.getOnOffShelfName(access) ?? '';

  // 是否上架
  bool get isAccess => StaticData.isOnOffShelfNormal(access);

  // app编辑课程信息,每个level的高度
  double get appEditLevelHeight {
    if (ObjectUtil.isNotEmpty(moduleList)) {
      // module的高度+level输入框标题的高度+level的内边距
      return AppConstant.appEditModuleHeight * moduleList!.length + AppConstant.appEditLevelModuleTextFieldHeight + AppConstant.appEditLevelTop * 2 + AppConstant.appExtraHeight;
    }

    return AppConstant.appEditLevelModuleTextFieldHeight + AppConstant.appEditLevelTop * 2 + AppConstant.appEditLevelGapHeight;
  }

  /// 相等性比较
  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is LevelResponseEntity && other.uid == uid;
  }

  /// 哈希值
  @override
  int get hashCode => Object.hash(runtimeType, uid);

  @override
  String toString() {
    return 'LevelResponseEntity('
        'uid: $uid, '
        'courseId: $courseId, '
        'name: $name, '
        'description: $description, '
        'language: $language, '
        'moduleIds: $moduleIds, '
        'moduleList: $moduleList, '
        'scope: $scope, '
        'scopeName: $scopeName, '
        'vendor: $vendor, '
        'vendorName: $vendorName, '
        'access: $access, '
        'unitNormalCnt: $unitNormalCnt, '
        'unitTotal: $unitTotal, '
        'order: $order, '
        'updated: $updated, '
        'created: $created)';
  }
}

class MiniModuleResponseEntity extends JsonSerializable {
  final int? uid;
  final String? name;
  final String? coverUrl;

  MiniModuleResponseEntity({this.uid, this.name, this.coverUrl}) : globalKey = GlobalKey(debugLabel: uid.toString());

  final GlobalKey globalKey;

  factory MiniModuleResponseEntity.fromJson(Map<String, dynamic> json, {Function? fromJson}) {
    return MiniModuleResponseEntity(uid: json["uid"], name: json["name"], coverUrl: json["coverUrl"]);
  }

  @override
  Map<String, dynamic> toJson() => {"uid": uid, "name": name, "coverUrl": coverUrl};

  @override
  String toString() {
    return 'MiniUnitResponseEntity('
        'uid: $uid, '
        'name: $name, '
        'coverUrl: $coverUrl, '
        'globalKey: $globalKey, )';
  }
}
