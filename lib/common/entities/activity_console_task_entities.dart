class ActivityConsoleTaskListEntity {
/*
{
  "list": [
    {
      "uid": 6,
      "taskCode": "TASK_COMPLETE_PROFILE_202510",
      "name": "完成学员信息填写",
      "taskType": "STEP",
      "groupCode": "GROUP_PROFILE",
      "groupMode": "SEQUENTIAL",
      "sequenceOrder": 1,
      "triggerEvents": [],
      "ruleKeys": [],
      "steps": []
    }
  ]
}
*/

  List<ActivityConsoleTaskItem>? list;
  List<ActivityConsoleTaskGroup>? groups;

  ActivityConsoleTaskListEntity({
    this.list,
    this.groups,
  });

  ActivityConsoleTaskListEntity.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      final v = json['list'];
      final arr0 = <ActivityConsoleTaskItem>[];
      final arr1 = <ActivityConsoleTaskGroup>[];
      if (v is List) {
        for (final e in v) {
          Map<String, dynamic>? map;
          if (e is Map<String, dynamic>) {
            map = e;
          } else if (e is Map) {
            map = e.cast<String, dynamic>();
          }
          if (map == null) continue;

          if (map['userTasks'] is List) {
            arr1.add(ActivityConsoleTaskGroup.fromJson(map));
            continue;
          }

          arr0.add(ActivityConsoleTaskItem.fromJson(map));
        }
      }
      list = arr0;
      groups = arr1;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (list != null) {
      data['list'] = list!.map((e) => e.toJson()).toList();
    }
    if (groups != null) {
      data['groups'] = groups!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class ActivityConsoleTaskGroup {
  String? group;
  String? name;
  int? order;
  String? description;
  List<ActivityConsoleTaskItem>? userTasks;

  ActivityConsoleTaskGroup({
    this.group,
    this.name,
    this.order,
    this.description,
    this.userTasks,
  });

  ActivityConsoleTaskGroup.fromJson(Map<String, dynamic> json) {
    group = json['group']?.toString();
    name = json['name']?.toString();
    order = json['order'] is num ? (json['order'] as num).toInt() : int.tryParse(json['order']?.toString() ?? '');
    description = json['description']?.toString();

    if (json['userTasks'] != null) {
      final v = json['userTasks'];
      final arr0 = <ActivityConsoleTaskItem>[];
      if (v is List) {
        for (final e in v) {
          if (e is Map<String, dynamic>) {
            arr0.add(ActivityConsoleTaskItem.fromJson(e));
          } else if (e is Map) {
            arr0.add(ActivityConsoleTaskItem.fromJson(e.cast<String, dynamic>()));
          }
        }
      }
      userTasks = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['group'] = group;
    data['name'] = name;
    data['order'] = order;
    data['description'] = description;
    if (userTasks != null) {
      data['userTasks'] = userTasks!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class ActivityConsoleTaskItem {
  int? uid;
  String? taskCode;
  String? name;
  String? executePeriodType;
  String? deputyDescription;
  String? banTitle;
  String? taskType;
  String? groupCode;
  String? groupMode;
  int? sequenceOrder;
  List<String>? triggerEvents;
  List<String>? ruleKeys;
  dynamic progressTarget;
  List<ActivityConsoleTaskPrizeConfig>? taskPrizeConfigs;
  List<ActivityConsoleTaskPrizeConfig>? taskPrizes;
  List<dynamic>? dependsOn;
  List<ActivityConsoleTaskStep>? steps;
  String? stepMode;
  dynamic stepGroups;
  dynamic completionPolicy;
  dynamic displayConfig;
  dynamic participateConfig;
  int? priority;
  bool? isStrongHint;
  String? status;
  String? startDate;
  String? endDate;
  String? created;
  String? updated;
  String? access;

  ActivityConsoleTaskItem({
    this.uid,
    this.taskCode,
    this.name,
    this.executePeriodType,
    this.deputyDescription,
    this.banTitle,
    this.taskType,
    this.groupCode,
    this.groupMode,
    this.sequenceOrder,
    this.triggerEvents,
    this.ruleKeys,
    this.progressTarget,
    this.taskPrizeConfigs,
    this.taskPrizes,
    this.dependsOn,
    this.steps,
    this.stepMode,
    this.stepGroups,
    this.completionPolicy,
    this.displayConfig,
    this.participateConfig,
    this.priority,
    this.isStrongHint,
    this.status,
    this.startDate,
    this.endDate,
    this.created,
    this.updated,
    this.access,
  });

  ActivityConsoleTaskItem.fromJson(Map<String, dynamic> json) {
    uid = json['uid'] is num ? (json['uid'] as num).toInt() : int.tryParse(json['uid']?.toString() ?? '');
    taskCode = json['taskCode']?.toString();
    name = json['name']?.toString();
    executePeriodType = json['executePeriodType']?.toString();
    deputyDescription = json['deputyDescription']?.toString();
    banTitle = json['banTitle']?.toString();
    taskType = json['taskType']?.toString();
    groupCode = json['groupCode']?.toString();
    groupMode = json['groupMode']?.toString();
    sequenceOrder = json['sequenceOrder'] is num ? (json['sequenceOrder'] as num).toInt() : int.tryParse(json['sequenceOrder']?.toString() ?? '');

    if (json['triggerEvents'] != null) {
      final v = json['triggerEvents'];
      final arr0 = <String>[];
      if (v is List) {
        for (final e in v) {
          arr0.add(e.toString());
        }
      }
      triggerEvents = arr0;
    }

    if (json['ruleKeys'] != null) {
      final v = json['ruleKeys'];
      final arr0 = <String>[];
      if (v is List) {
        for (final e in v) {
          arr0.add(e.toString());
        }
      }
      ruleKeys = arr0;
    }

    progressTarget = json['progressTarget'];

    if (json['taskPrizeConfigs'] != null) {
      final v = json['taskPrizeConfigs'];
      final arr0 = <ActivityConsoleTaskPrizeConfig>[];
      if (v is List) {
        for (final e in v) {
          if (e is Map<String, dynamic>) {
            arr0.add(ActivityConsoleTaskPrizeConfig.fromJson(e));
          } else if (e is Map) {
            arr0.add(ActivityConsoleTaskPrizeConfig.fromJson(e.cast<String, dynamic>()));
          }
        }
      }
      taskPrizeConfigs = arr0;
    }

        if (json['taskPrizes'] != null) {
      final v = json['taskPrizes'];
      final arr1 = <ActivityConsoleTaskPrizeConfig>[];
      if (v is List) {
        for (final e in v) {
          if (e is Map<String, dynamic>) {
            arr1.add(ActivityConsoleTaskPrizeConfig.fromJson(e));
          } else if (e is Map) {
            arr1.add(ActivityConsoleTaskPrizeConfig.fromJson(e.cast<String, dynamic>()));
          }
        }
      }
      taskPrizes = arr1;
    }

    dependsOn = json['dependsOn'] is List ? (json['dependsOn'] as List).toList() : null;

    if (json['steps'] != null) {
      final v = json['steps'];
      final arr0 = <ActivityConsoleTaskStep>[];
      if (v is List) {
        for (final e in v) {
          if (e is Map<String, dynamic>) {
            arr0.add(ActivityConsoleTaskStep.fromJson(e));
          } else if (e is Map) {
            arr0.add(ActivityConsoleTaskStep.fromJson(e.cast<String, dynamic>()));
          }
        }
      }
      steps = arr0;
    }

    stepMode = json['stepMode']?.toString();
    stepGroups = json['stepGroups'];
    completionPolicy = json['completionPolicy'];
    deputyDescription = json['deputyDescription']?.toString();
    displayConfig = json['displayConfig'];
    participateConfig = json['participateConfig'];
    priority = json['priority'] is num ? (json['priority'] as num).toInt() : int.tryParse(json['priority']?.toString() ?? '');
    isStrongHint = json['isStrongHint'] is bool ? json['isStrongHint'] : bool.tryParse(json['isStrongHint']?.toString() ?? '');
    status = json['status']?.toString();
    startDate = json['startDate']?.toString();
    endDate = json['endDate']?.toString();
    created = json['created']?.toString();
    updated = json['updated']?.toString();
    access = json['access']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['taskCode'] = taskCode;
    data['name'] = name;
    data['executePeriodType'] = executePeriodType;
    data['taskType'] = taskType;
    data['groupCode'] = groupCode;
    data['groupMode'] = groupMode;
    data['sequenceOrder'] = sequenceOrder;
    if (triggerEvents != null) {
      data['triggerEvents'] = triggerEvents;
    }
    if (ruleKeys != null) {
      data['ruleKeys'] = ruleKeys;
    }
    data['progressTarget'] = progressTarget;
    if (taskPrizeConfigs != null) {
      data['taskPrizeConfigs'] = taskPrizeConfigs!.map((e) => e.toJson()).toList();
    }
    if (dependsOn != null) {
      data['dependsOn'] = dependsOn;
    }
    if (steps != null) {
      data['steps'] = steps!.map((e) => e.toJson()).toList();
    }
    data['stepMode'] = stepMode;
    data['stepGroups'] = stepGroups;
    data['completionPolicy'] = completionPolicy;
    data['displayConfig'] = displayConfig;
    data['participateConfig'] = participateConfig;
    data['priority'] = priority;
    data['isStrongHint'] = isStrongHint;
    data['status'] = status;
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    data['created'] = created;
    data['updated'] = updated;
    data['access'] = access;
    return data;
  }

  ActivityConsoleTaskStatus get statusEnum => ActivityConsoleTaskStatusX.fromRaw(status);

  bool get shouldTrigger {
    final s = statusEnum;
    return s == ActivityConsoleTaskStatus.NOT_STARTED || s == ActivityConsoleTaskStatus.IN_PROGRESS;
  }
}

class ActivityConsoleTaskPrizeConfig {
  int? prizeId;
  int? count;
  String? title;
  String? description;
  String? priceName;
  String? priceTitle;
  List<String>? values;
  bool? isSend;
  dynamic duration;
  dynamic durationType;
  String? type;
  int? value;

  ActivityConsoleTaskPrizeConfig({
    this.prizeId,
    this.count,
    this.title,
    this.description,
    this.priceName,
    this.priceTitle,
    this.values,
    this.isSend,
    this.duration,
    this.durationType,
    this.type,
    this.value
  });

  ActivityConsoleTaskPrizeConfig.fromJson(Map<String, dynamic> json) {
    var arr = json['values'] ?? [];
    var mVal = List<String>.from(arr);
    prizeId = json['prizeId'] is num ? (json['prizeId'] as num).toInt() : int.tryParse(json['prizeId']?.toString() ?? '');
    count = json['count'] is num ? (json['count'] as num).toInt() : int.tryParse(json['count']?.toString() ?? '');
    title = json['title']?.toString();
    description = json['description']?.toString();
    priceName = json['priceName']?.toString();
    priceTitle = json['priceTitle']?.toString();
    values = mVal;
    isSend = json['isSend'] is bool ? json['isSend'] : bool.tryParse(json['isSend']?.toString() ?? '');
    duration = json['duration'];
    durationType = json['durationType'];
    type = json['type']?.toString();
    value = json['value']??0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['prizeId'] = prizeId;
    data['count'] = count;
    data['title'] = title;
    data['description'] = description;
    data['duration'] = duration;
    data['durationType'] = durationType;
    return data;
  }
}

class ActivityConsoleTaskStep {
  String? stepCode;
  String? name;
  int? order;
  String? guideText;
  String? ruleKey;
  String? groupCode;
  String? widgetId;
  String? path;
  List<dynamic>? dependsOn;
  List<ActivityConsoleTaskPrizeConfig>? rewards;
  dynamic config;
  String? status;
  bool? tipOnly;
  bool? autoComplete;
  bool? deferComplete;
  Map<String, dynamic>? pathParams;

  ActivityConsoleTaskStep({
    this.stepCode,
    this.name,
    this.order,
    this.guideText,
    this.ruleKey,
    this.groupCode,
    this.widgetId,
    this.path,
    this.dependsOn,
    this.rewards,
    this.config,
    this.status,
    this.tipOnly,
    this.autoComplete,
    this.deferComplete,
    this.pathParams,
  });

  ActivityConsoleTaskStep.fromJson(Map<String, dynamic> json) {
    stepCode = json['stepCode']?.toString();
    name = json['name']?.toString();
    order = json['order'] is num ? (json['order'] as num).toInt() : int.tryParse(json['order']?.toString() ?? '');
    guideText = json['guideText']?.toString();
    ruleKey = json['ruleKey']?.toString();
    groupCode = json['groupCode']?.toString();
    widgetId = json['widgetId']?.toString();
    path = json['path']?.toString();
    dependsOn = json['dependsOn'] is List ? (json['dependsOn'] as List).toList() : null;
    

    if (json['rewards'] != null) {
      final v = json['rewards'];
      final arr0 = <ActivityConsoleTaskPrizeConfig>[];
      if (v is List) {
        for (final e in v) {
          if (e is Map<String, dynamic>) {
            arr0.add(ActivityConsoleTaskPrizeConfig.fromJson(e));
          } else if (e is Map) {
            arr0.add(ActivityConsoleTaskPrizeConfig.fromJson(e.cast<String, dynamic>()));
          }
        }
      }
      rewards = arr0;
    }

    config = json['config'];
    status = json['status']?.toString();
    tipOnly = json['tipOnly'] ?? false;
    autoComplete = json['autoComplete'] ?? false;
    deferComplete = json['deferComplete'] ?? false;
    if(json['pathParams'] != null) {
      pathParams = Map<String, dynamic>.from(json['pathParams']);
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['stepCode'] = stepCode;
    data['name'] = name;
    data['order'] = order;
    data['guideText'] = guideText;
    data['ruleKey'] = ruleKey;
    data['groupCode'] = groupCode;
    data['widgetId'] = widgetId;
    data['path'] = path;
    if (dependsOn != null) {
      data['dependsOn'] = dependsOn;
    }
    if (rewards != null) {
      data['rewards'] = rewards!.map((e) => e.toJson()).toList();
    }
    data['config'] = config;
    data['status'] = status;
    data['tipOnly'] = tipOnly;
    data['autoComplete'] = autoComplete;
    data['deferComplete'] = deferComplete;
    if (pathParams != null) {
      data['pathParams'] = pathParams;
    }
    return data;
  }

  ActivityConsoleTaskStepStatus get statusEnum => ActivityConsoleTaskStepStatusX.fromRaw(status);
}

enum ActivityConsoleTaskStatus {
  NOT_STARTED,
  IN_CLAIMED,
  IN_PROGRESS,
  COMPLETED,
  EXPIRED,
  BAN,
  unknown,
}

enum ActivityConsoleTaskStepStatus {
  NOT_STARTED,
  IN_CLAIMED,
  IN_PROGRESS,
  COMPLETED,
  EXPIRED,
  unknown,
}

extension ActivityConsoleTaskStatusX on ActivityConsoleTaskStatus {
  static ActivityConsoleTaskStatus fromRaw(String? raw) {
    final v = raw?.trim();
    if (v == null || v.isEmpty) return ActivityConsoleTaskStatus.unknown;
    switch (v.toUpperCase()) {
      case 'NOT_STARTED':
        return ActivityConsoleTaskStatus.NOT_STARTED;
      case 'IN_CLAIMED':
        return ActivityConsoleTaskStatus.IN_CLAIMED;
      case 'IN_PROGRESS':
        return ActivityConsoleTaskStatus.IN_PROGRESS;
      case 'COMPLETED':
        return ActivityConsoleTaskStatus.COMPLETED;
      case 'EXPIRED':
        return ActivityConsoleTaskStatus.EXPIRED;
      case 'BAN':
        return ActivityConsoleTaskStatus.BAN;
      default:
        return ActivityConsoleTaskStatus.unknown;
    }
  }
}

extension ActivityConsoleTaskStepStatusX on ActivityConsoleTaskStepStatus {
  static ActivityConsoleTaskStepStatus fromRaw(String? raw) {
    final v = raw?.trim();
    if (v == null || v.isEmpty) return ActivityConsoleTaskStepStatus.NOT_STARTED;
    switch (v.toUpperCase()) {
      case 'NOT_STARTED':
        return ActivityConsoleTaskStepStatus.NOT_STARTED;
      case 'IN_CLAIMED':
        return ActivityConsoleTaskStepStatus.IN_CLAIMED;
      case 'IN_PROGRESS':
        return ActivityConsoleTaskStepStatus.IN_PROGRESS;
      case 'COMPLETED':
        return ActivityConsoleTaskStepStatus.COMPLETED;
      case 'EXPIRED':
        return ActivityConsoleTaskStepStatus.EXPIRED;
      default:
        return ActivityConsoleTaskStepStatus.NOT_STARTED;
    }
  }
}

/// 数据包装类 (对应 data 层)
class TaskGroupList {
  final List<TaskGroupItem> list;

  TaskGroupList({
    required this.list,
  });

  factory TaskGroupList.fromJson(Map<String, dynamic> json) {
    return TaskGroupList(
      list: (json['list'] as List<dynamic>).map((e) => TaskGroupItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'list': list.map((e) => e.toJson()).toList(),
    };
  }
}

/// 核心实体类 (对应 list 中的每一项)
class TaskGroupItem {
  final int uid;
  final String group; // 使用枚举
  final String name;
  final String description;
  final String access; // 使用枚举
  final DateTime created;
  final DateTime updated;

  TaskGroupItem({
    required this.uid,
    required this.group,
    required this.name,
    required this.description,
    required this.access,
    required this.created,
    required this.updated,
  });

  factory TaskGroupItem.fromJson(Map<String, dynamic> json) {
    return TaskGroupItem(
      uid: json['uid'] as int,
      group: json['group'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      access: json['access'] as String,
      created: DateTime.parse(json['created'] as String),
      updated: DateTime.parse(json['updated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'group': group,
      'name': name,
      'description': description,
      'access': access,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }
}
