class FavouriteListenEntity {
  int? uid;
  String? name;
  String? description;
  String? cover;
  bool? isDefault;
  double? order;
  int? contentCount;
  int? maxContentCount;
  String? created;
  String? updated;

  FavouriteListenEntity({
    this.uid,
    this.name,
    this.description,
    this.cover,
    this.isDefault,
    this.order,
    this.contentCount,
    this.maxContentCount,
    this.created,
    this.updated,
  });

  FavouriteListenEntity.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    name = json['name']?.toString();
    description = json['description']?.toString();
    cover = json['cover']?.toString();
    isDefault = json['isDefault'] as bool?;
    order = json['order']?.toDouble();
    contentCount = json['contentCount']?.toInt();
    maxContentCount = json['maxContentCount']?.toInt();
    created = json['created']?.toString();
    updated = json['updated']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['name'] = name;
    data['description'] = description;
    data['cover'] = cover;
    data['isDefault'] = isDefault;
    data['order'] = order;
    data['contentCount'] = contentCount;
    data['maxContentCount'] = maxContentCount;
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }
}
