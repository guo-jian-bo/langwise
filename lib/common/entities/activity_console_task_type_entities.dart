class ActivityConsoleTaskTypeListEntity {
/*
{
  "executePeriodType": {
    "EVERYDAY": "每日任务",
    "EXECUTEMANYTIMES": "执行多次",
    "EXECUTEONCE": "执行一次"
  },
  "taskType": {
    "INSTANT": "即时任务",
    "STEP": "步骤任务",
    "ACCUMULATION": "累计任务"
  },
  "groupMode": {
    "SEQUENTIAL": "串行",
    "PARALLEL": "并行"
  },
  "cooldownTimeType": {
    "HOUR": "时",
    "MINUTE": "分",
    "WEEK": "周",
    "DAY": "日"
  }
}
*/

  Map<String, String>? executePeriodType;
  Map<String, String>? taskType;
  Map<String, String>? groupMode;
  Map<String, String>? cooldownTimeType;

  ActivityConsoleTaskTypeListEntity({
    this.executePeriodType,
    this.taskType,
    this.groupMode,
    this.cooldownTimeType,
  });

  ActivityConsoleTaskTypeListEntity.fromJson(Map<String, dynamic> json) {
    executePeriodType = _parseStringMap(json['executePeriodType']);
    taskType = _parseStringMap(json['taskType']);
    groupMode = _parseStringMap(json['groupMode']);
    cooldownTimeType = _parseStringMap(json['cooldownTimeType']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (executePeriodType != null) {
      data['executePeriodType'] = executePeriodType;
    }
    if (taskType != null) {
      data['taskType'] = taskType;
    }
    if (groupMode != null) {
      data['groupMode'] = groupMode;
    }
    if (cooldownTimeType != null) {
      data['cooldownTimeType'] = cooldownTimeType;
    }
    return data;
  }

  static Map<String, String>? _parseStringMap(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map<String, dynamic>) {
      return raw.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    if (raw is Map) {
      return raw.cast<dynamic, dynamic>().map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    return null;
  }
}
