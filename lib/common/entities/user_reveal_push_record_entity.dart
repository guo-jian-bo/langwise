class UserRevealPushReadDetailEntity {
  String? dateTime;
  String? week;
  bool? isToday;
  int? pushNum;
  int? pushMaxNum;
  int? readNum;
  double? readRate;
  bool? isDataLack;
  bool? isReadFinish;

  UserRevealPushReadDetailEntity({
    this.dateTime,
    this.week,
    this.isToday,
    this.pushNum,
    this.pushMaxNum,
    this.readNum,
    this.readRate,
    this.isDataLack,
    this.isReadFinish,
  });

  UserRevealPushReadDetailEntity.fromJson(Map<String, dynamic> json) {
    dateTime = json['dateTime']?.toString();
    week = json['week']?.toString();
    isToday = json['isToday'] as bool?;
    pushNum = json['pushNum']?.toInt();
    pushMaxNum = json['pushMaxNum']?.toInt();
    readNum = json['readNum']?.toInt();
    readRate = json['readRate'] == null ? null : (json['readRate'] as num).toDouble();
    isDataLack = json['isDataLack'] as bool?;
    isReadFinish = json['isReadFinish'] as bool?;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['dateTime'] = dateTime;
    data['week'] = week;
    data['isToday'] = isToday;
    data['pushNum'] = pushNum;
    data['pushMaxNum'] = pushMaxNum;
    data['readNum'] = readNum;
    data['readRate'] = readRate;
    data['isDataLack'] = isDataLack;
    data['isReadFinish'] = isReadFinish;
    return data;
  }
}

class UserRevealPushRecordEntity {
  int? pushNum;
  double? averagePush;
  int? readNum;
  double? averageRead;
  double? readRate;
  List<UserRevealPushReadDetailEntity>? readDetails;

  UserRevealPushRecordEntity({
    this.pushNum,
    this.averagePush,
    this.readNum,
    this.averageRead,
    this.readRate,
    this.readDetails,
  });

  UserRevealPushRecordEntity.fromJson(Map<String, dynamic> json) {
    pushNum = json['pushNum']?.toInt()??0;
    averagePush = json['averagePush'] == 0 ? null : (json['averagePush'] as num).toDouble();
    readNum = json['readNum']?.toInt()??0;
    averageRead = json['averageRead'] == 0 ? null : (json['averageRead'] as num).toDouble();
    readRate = json['readRate'] == 0 ? null : (json['readRate'] as num).toDouble();

    if (json['readDetails'] != null) {
      final list = json['readDetails'] as List;
      final arr = <UserRevealPushReadDetailEntity>[];
      for (final e in list) {
        arr.add(UserRevealPushReadDetailEntity.fromJson(e as Map<String, dynamic>));
      }
      readDetails = arr;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['pushNum'] = pushNum;
    data['averagePush'] = averagePush;
    data['readNum'] = readNum;
    data['averageRead'] = averageRead;
    data['readRate'] = readRate;
    if (readDetails != null) {
      data['readDetails'] = readDetails!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}
