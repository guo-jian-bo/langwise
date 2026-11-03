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

class WordMorphologySummaryEntity {
  List<WordMorphologySummaryTypeEntity?>? types;

  WordMorphologySummaryEntity({
    this.types,
  });

  WordMorphologySummaryEntity.fromJson(Map<String, dynamic> json) {
    if (json['types'] != null) {
      final v = json['types'];
      final arr0 = <WordMorphologySummaryTypeEntity>[];
      v.forEach((v) {
        arr0.add(WordMorphologySummaryTypeEntity.fromJson(v));
      });
      types = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (types != null) {
      final arr0 = [];
      for (final item in types!) {
        arr0.add(item!.toJson());
      }
      data['types'] = arr0;
    }
    return data;
  }
}
