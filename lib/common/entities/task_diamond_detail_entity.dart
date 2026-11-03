class TaskDiamondDetailItem {
  int? uid;
  String? day;
  String? timezone;
  String? type;
  int? diamondIndex;
  int? diamondCount;
  String? content;
  bool? read;
  String? created;

  TaskDiamondDetailItem({
    this.uid,
    this.day,
    this.timezone,
    this.type,
    this.diamondIndex,
    this.diamondCount,
    this.content,
    this.read,
    this.created,
  });

  TaskDiamondDetailItem.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    day = json['day']?.toString();
    timezone = json['timezone']?.toString();
    type = json['type']?.toString();
    diamondIndex = json['diamondIndex']?.toInt();
    diamondCount = json['diamondCount']?.toInt();
    content = json['content']?.toString();
    read = json['read'];
    created = json['created']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['day'] = day;
    data['timezone'] = timezone;
    data['type'] = type;
    data['diamondIndex'] = diamondIndex;
    data['diamondCount'] = diamondCount;
    data['content'] = content;
    data['read'] = read;
    data['created'] = created;
    return data;
  }
}

class TaskDiamondDetailEntity {
  List<TaskDiamondDetailItem?>? list;

  TaskDiamondDetailEntity({
    this.list,
  });

  TaskDiamondDetailEntity.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      final arr0 = <TaskDiamondDetailItem>[];
      json['list'].forEach((v) {
        arr0.add(TaskDiamondDetailItem.fromJson(v));
      });
      list = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (list != null) {
      final arr0 = [];
      for (final v in list!) {
        arr0.add(v!.toJson());
      }
      data['list'] = arr0;
    }
    return data;
  }
}
