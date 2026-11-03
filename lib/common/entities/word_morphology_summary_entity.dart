class WordMorphologySummaryTypeEntity {
  String? nid;
  String? name;
  int? count;

  WordMorphologySummaryTypeEntity({
    this.nid,
    this.name,
    this.count,
  });

  WordMorphologySummaryTypeEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    name = json['name']?.toString();
    count = json['count']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['name'] = name;
    data['count'] = count;
    return data;
  }
}
