class CourseUnitTargetAddGrammarSelectedEntity {
  List<int?>? knowledgeUids;
  List<int?>? setUids;

  CourseUnitTargetAddGrammarSelectedEntity({
    this.knowledgeUids,
    this.setUids,
  });

  CourseUnitTargetAddGrammarSelectedEntity.fromJson(Map<String, dynamic> json) {
    knowledgeUids = _parseIntList(json['knowledgeUids']);
    setUids = _parseIntList(json['setUids']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['knowledgeUids'] = knowledgeUids;
    data['setUids'] = setUids;
    return data;
  }
}

class CourseUnitTargetAddGrammarRecallAssetEntity {
  String? kind;
  String? nid;
  String? name;
  List<int?>? hitSentenceIds;
  bool? alreadyPresent;

  CourseUnitTargetAddGrammarRecallAssetEntity({
    this.kind,
    this.nid,
    this.name,
    this.hitSentenceIds,
    this.alreadyPresent,
  });

  CourseUnitTargetAddGrammarRecallAssetEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    kind = json['kind']?.toString();
    nid = json['nid']?.toString();
    name = json['name']?.toString();
    hitSentenceIds = _parseIntList(json['hitSentenceIds']);
    alreadyPresent = json['alreadyPresent'] == true;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['kind'] = kind;
    data['nid'] = nid;
    data['name'] = name;
    data['hitSentenceIds'] = hitSentenceIds;
    data['alreadyPresent'] = alreadyPresent;
    return data;
  }
}

class CourseUnitTargetAddGrammarRecallEntity {
  int? unitId;
  CourseUnitTargetAddGrammarSelectedEntity? selected;
  List<int?>? sentenceIds;
  List<CourseUnitTargetAddGrammarRecallAssetEntity?>? assets;

  CourseUnitTargetAddGrammarRecallEntity({
    this.unitId,
    this.selected,
    this.sentenceIds,
    this.assets,
  });

  CourseUnitTargetAddGrammarRecallEntity.fromJson(Map<String, dynamic> json) {
    unitId = json['unitId']?.toInt();
    selected = json['selected'] == null
        ? null
        : CourseUnitTargetAddGrammarSelectedEntity.fromJson(
            Map<String, dynamic>.from(json['selected']),
          );
    sentenceIds = _parseIntList(json['sentenceIds']);
    assets = _parseObjectList(
      json['assets'],
      CourseUnitTargetAddGrammarRecallAssetEntity.fromJson,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['unitId'] = unitId;
    data['selected'] = selected?.toJson();
    data['sentenceIds'] = sentenceIds;
    data['assets'] = assets?.map((e) => e?.toJson()).toList();
    return data;
  }
}

class CourseUnitTargetAddGrammarTaskStartEntity {
  int? taskId;
  String? taskName;
  String? status;
  String? message;

  CourseUnitTargetAddGrammarTaskStartEntity({
    this.taskId,
    this.taskName,
    this.status,
    this.message,
  });

  CourseUnitTargetAddGrammarTaskStartEntity.fromJson(Map<String, dynamic> json) {
    taskId = json['task_id']?.toInt();
    taskName = json['task_name']?.toString();
    status = json['status']?.toString();
    message = json['message']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['task_id'] = taskId;
    data['task_name'] = taskName;
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class CourseUnitTargetAddGrammarTaskStatusEntity {
  int? uid;
  String? taskName;
  String? status;
  String? startedAt;
  String? finishedAt;
  String? errorMessage;
  Map<String, int>? taskStatus;

  CourseUnitTargetAddGrammarTaskStatusEntity({
    this.uid,
    this.taskName,
    this.status,
    this.startedAt,
    this.finishedAt,
    this.errorMessage,
    this.taskStatus,
  });

  CourseUnitTargetAddGrammarTaskStatusEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    uid = json['uid']?.toInt();
    taskName = json['task_name']?.toString();
    status = json['status']?.toString();
    startedAt = json['started_at']?.toString();
    finishedAt = json['finished_at']?.toString();
    errorMessage = json['error_message']?.toString();
    taskStatus = _parseIntMap(json['task_status']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['task_name'] = taskName;
    data['status'] = status;
    data['started_at'] = startedAt;
    data['finished_at'] = finishedAt;
    data['error_message'] = errorMessage;
    data['task_status'] = taskStatus;
    return data;
  }
}

List<int?>? _parseIntList(dynamic json) {
  if (json == null || json is! List) return null;
  final List<int?> list = [];
  for (final item in json) {
    list.add(item?.toInt());
  }
  return list;
}

List<T?>? _parseObjectList<T>(
  dynamic json,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (json == null || json is! List) return null;
  final List<T?> list = [];
  for (final item in json) {
    if (item is! Map) {
      list.add(null);
      continue;
    }
    list.add(fromJson(Map<String, dynamic>.from(item)));
  }
  return list;
}

Map<String, int>? _parseIntMap(dynamic json) {
  if (json == null || json is! Map) return null;
  final Map<String, int> data = {};
  json.forEach((key, value) {
    if (key == null) return;
    data[key.toString()] = value?.toInt() ?? 0;
  });
  return data;
}
