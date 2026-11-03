class ActivityTagParamValueEntity {
  final String? value;
  final String? description;
  final int? sortOrder;
  final num? min;
  final num? max;

  const ActivityTagParamValueEntity({
    this.value,
    this.description,
    this.sortOrder,
    this.min,
    this.max,
  });

  factory ActivityTagParamValueEntity.fromJson(Map<String, dynamic> json) {
    return ActivityTagParamValueEntity(
      value: json['value']?.toString(),
      description: json['description']?.toString(),
      sortOrder: json['sortOrder'] is num ? (json['sortOrder'] as num).toInt() : int.tryParse(json['sortOrder']?.toString() ?? ''),
      min: json['min'] is num ? json['min'] as num : num.tryParse(json['min']?.toString() ?? ''),
      max: json['max'] is num ? json['max'] as num : num.tryParse(json['max']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'description': description,
      'sortOrder': sortOrder,
      'min': min,
      'max': max,
    };
  }
}

class ActivityTagParamEntity {
  final int? uid;
  final String? code;
  final String? name;
  final String? description;
  final String? paramType;
  final String? dataType;
  final List<ActivityTagParamValueEntity>? values;
  final int? duration;
  final String? durationType;
  final int? sortOrder;
  final String? created;
  final String? updated;

  const ActivityTagParamEntity({
    this.uid,
    this.code,
    this.name,
    this.description,
    this.paramType,
    this.dataType,
    this.values,
    this.duration,
    this.durationType,
    this.sortOrder,
    this.created,
    this.updated,
  });

  factory ActivityTagParamEntity.fromJson(Map<String, dynamic> json) {
    final list = <ActivityTagParamValueEntity>[];
    final raw = json['values'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          list.add(ActivityTagParamValueEntity.fromJson(e));
        }
      }
    }

    return ActivityTagParamEntity(
      uid: json['uid'] is num ? (json['uid'] as num).toInt() : int.tryParse(json['uid']?.toString() ?? ''),
      code: json['code']?.toString(),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      paramType: json['paramType']?.toString(),
      dataType: json['dataType']?.toString(),
      values: list,
      duration: json['duration'] is num ? (json['duration'] as num).toInt() : int.tryParse(json['duration']?.toString() ?? ''),
      durationType: json['durationType']?.toString(),
      sortOrder: json['sortOrder'] is num ? (json['sortOrder'] as num).toInt() : int.tryParse(json['sortOrder']?.toString() ?? ''),
      created: json['created']?.toString(),
      updated: json['updated']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'code': code,
      'name': name,
      'description': description,
      'paramType': paramType,
      'dataType': dataType,
      'values': values?.map((e) => e.toJson()).toList(),
      'duration': duration,
      'durationType': durationType,
      'sortOrder': sortOrder,
      'created': created,
      'updated': updated,
    };
  }
}

class ActivityTagItemEntity {
  final int? uid;
  final String? code;
  final String? name;
  final String? tagTriggerType;
  final String? activateType;
  final String? cron;
  final String? remark;
  final Map<String, dynamic>? tagCondition;
  final int? duration;
  final String? durationType;
  final String? created;
  final String? updated;
  final String? access;

  const ActivityTagItemEntity({
    this.uid,
    this.code,
    this.name,
    this.tagTriggerType,
    this.activateType,
    this.cron,
    this.remark,
    this.tagCondition,
    this.duration,
    this.durationType,
    this.created,
    this.updated,
    this.access,
  });

  factory ActivityTagItemEntity.fromJson(Map<String, dynamic> json) {
    return ActivityTagItemEntity(
      uid: json['uid'] is num ? (json['uid'] as num).toInt() : int.tryParse(json['uid']?.toString() ?? ''),
      code: json['code']?.toString(),
      name: json['name']?.toString(),
      tagTriggerType: json['tagTriggerType']?.toString(),
      activateType: json['activateType']?.toString(),
      cron: json['cron']?.toString(),
      remark: json['remark']?.toString(),
      tagCondition: json['tagCondition'] is Map<String, dynamic> ? (json['tagCondition'] as Map<String, dynamic>) : null,
      duration: json['duration'] is num ? (json['duration'] as num).toInt() : int.tryParse(json['duration']?.toString() ?? ''),
      durationType: json['durationType']?.toString(),
      created: json['created']?.toString(),
      updated: json['updated']?.toString(),
      access: json['access']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'code': code,
      'name': name,
      'tagTriggerType': tagTriggerType,
      'activateType': activateType,
      'cron': cron,
      'remark': remark,
      'tagCondition': tagCondition,
      'duration': duration,
      'durationType': durationType,
      'created': created,
      'updated': updated,
      'access': access,
    };
  }
}

class ActivityTagPageDataEntity {
  final int? count;
  final List<ActivityTagItemEntity>? datas;

  const ActivityTagPageDataEntity({
    this.count,
    this.datas,
  });

  factory ActivityTagPageDataEntity.fromJson(Map<String, dynamic> json) {
    final list = <ActivityTagItemEntity>[];
    final raw = json['datas'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          list.add(ActivityTagItemEntity.fromJson(e));
        }
      }
    }

    return ActivityTagPageDataEntity(
      count: json['count'] is num ? (json['count'] as num).toInt() : int.tryParse(json['count']?.toString() ?? ''),
      datas: list,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'datas': datas?.map((e) => e.toJson()).toList(),
    };
  }
}
