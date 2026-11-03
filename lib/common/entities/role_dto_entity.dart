class RoleDtoEntity {
  int? uid;
  String? name;
  String? code;
  List<int>? apiIds;
  List<int>? adminApiIds;
  String? remark;
  String? access;
  String? created;

  RoleDtoEntity({
    this.uid,
    this.name,
    this.code,
    this.apiIds,
    this.adminApiIds,
    this.remark,
    this.access,
    this.created,
  });

  RoleDtoEntity.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    name = json['name']?.toString();
    code = json['code']?.toString();
    if (json['apiIds'] is List) {
      apiIds = (json['apiIds'] as List).map((e) => (e as num).toInt()).toList();
    }
    if (json['adminApiIds'] is List) {
      adminApiIds = (json['adminApiIds'] as List).map((e) => (e as num).toInt()).toList();
    }
    remark = json['remark']?.toString();
    access = json['access']?.toString();
    created = json['created']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['name'] = name;
    data['code'] = code;
    data['apiIds'] = apiIds;
    data['adminApiIds'] = adminApiIds;
    data['remark'] = remark;
    data['access'] = access;
    data['created'] = created;
    return data;
  }
}
