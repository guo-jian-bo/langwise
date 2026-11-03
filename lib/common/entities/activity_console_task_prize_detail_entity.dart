class TaskResponse {
  final int? code;
  final TaskData? data;

  TaskResponse({
    this.code,
    this.data,
  });

  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    return TaskResponse(
      code: json['code'] as int?,
      data: json['data'] != null ? TaskData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'data': data?.toJson(),
    };
  }
}

class TaskData {
  final List<TaskItem>? list;

  TaskData({
    this.list,
  });

  factory TaskData.fromJson(Map<String, dynamic> json) {
    return TaskData(
      list: (json['list'] as List<dynamic>?)
          ?.map((e) => TaskItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'list': list?.map((e) => e.toJson()).toList(),
    };
  }
}

class TaskItem {
  final int? uid;
  final int? userId;
  final String? taskCode;
  final String? stepCode;
  final int? prizeId;
  final String? type;
  final int? value; // 如果可能是小数，建议改为 num? 或 double?
  final int? num;
  final int? duration; // 根据 null 推测是 int，如果是时间字符串请改为 String?
  final String? durationType; // 推测是 String
  final List<String>? values;
  final DateTime? created;
  final DateTime? updated;
  final dynamic access; // 类型未知，使用 dynamic
  final DateTime? grantedAt;
  final DateTime? pushDate;

  TaskItem({
    this.uid,
    this.userId,
    this.taskCode,
    this.stepCode,
    this.prizeId,
    this.type,
    this.value,
    this.num,
    this.duration,
    this.durationType,
    this.values,
    this.created,
    this.updated,
    this.access,
    this.grantedAt,
    this.pushDate,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      uid: json['uid'] as int?,
      userId: json['userId'] as int?,
      taskCode: json['taskCode'] as String?,
      stepCode: json['stepCode'] as String?,
      prizeId: json['prizeId'] as int?,
      type: json['type'] as String?,
      value: json['value'] as int?,
      num: json['num'] as int?,
      duration: json['duration'] as int?,
      durationType: json['durationType'] as String?,
      values: (json['values'] as List<dynamic>?)?.map((e) => e as String).toList(),
      created: json['created'] != null ? DateTime.tryParse(json['created']) : null,
      updated: json['updated'] != null ? DateTime.tryParse(json['updated']) : null,
      access: json['access'],
      grantedAt: json['grantedAt'] != null ? DateTime.tryParse(json['grantedAt']) : null,
      pushDate: json['pushDate'] != null ? DateTime.tryParse(json['pushDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'userId': userId,
      'taskCode': taskCode,
      'stepCode': stepCode,
      'prizeId': prizeId,
      'type': type,
      'value': value,
      'num': num,
      'duration': duration,
      'durationType': durationType,
      'values': values,
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
      'access': access,
      'grantedAt': grantedAt?.toIso8601String(),
      'pushDate': pushDate?.toIso8601String(),
    };
  }
}