class UserCollectionSubscribeEntity {
  int? collectionId;
  String? themeZhName;
  int? collectionPushNum;

  UserCollectionSubscribeEntity({
    this.collectionId,
    this.themeZhName,
    this.collectionPushNum,
  });

  UserCollectionSubscribeEntity.fromJson(Map<String, dynamic> json) {
    collectionId = json['collectionId']?.toInt();
    themeZhName = json['themeZhName']?.toString();
    collectionPushNum = json['collectionPushNum']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['collectionId'] = collectionId;
    data['themeZhName'] = themeZhName;
    data['collectionPushNum'] = collectionPushNum;
    return data;
  }
}

class UserSubscribeConfigEntity {
  int? pushSubscribeNum;
  int? pushSum;
  int? maxPushNum;
  bool? isOnceMorePush;
  List<UserCollectionSubscribeEntity>? collectionSubscribe;

  UserSubscribeConfigEntity({
    this.pushSubscribeNum,
    this.pushSum,
    this.maxPushNum,
    this.isOnceMorePush,
    this.collectionSubscribe,
  });

  UserSubscribeConfigEntity.fromJson(Map<String, dynamic> json) {
    pushSubscribeNum = json['pushSubscribeNum']?.toInt();
    pushSum = json['pushSum']?.toInt();
    maxPushNum = json['maxPushNum']?.toInt();
    isOnceMorePush = json['isOnceMorePush'] as bool?;

    if (json['collectionSubscribe'] != null) {
      final list = json['collectionSubscribe'] as List;
      final arr = <UserCollectionSubscribeEntity>[];
      for (final e in list) {
        arr.add(UserCollectionSubscribeEntity.fromJson(e as Map<String, dynamic>));
      }
      collectionSubscribe = arr;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['pushSubscribeNum'] = pushSubscribeNum;
    data['pushSum'] = pushSum;
    data['maxPushNum'] = maxPushNum;
    data['isOnceMorePush'] = isOnceMorePush;
    if (collectionSubscribe != null) {
      data['collectionSubscribe'] = collectionSubscribe!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}
