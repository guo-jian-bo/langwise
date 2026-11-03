import 'entities.dart';

class WordMorphologyPageEntity {
/*
{
  "offset": 0,
  "limit": 30,
  "count": 122,
  "datas": [],
  "types": [
    {
      "nid": "prefix",
      "name": "前缀",
      "count": 60
    }
  ]
}
*/

  int? offset;
  int? limit;
  int? count;

  /// 当前页词素列表
  List<WordMorphologyListItemEntity>? datas;

  /// 词素类型统计，随列表接口一起返回，用于顶部预览
  List<WordMorphologySummaryTypeEntity>? types;

  WordMorphologyPageEntity({
    this.offset,
    this.limit,
    this.count,
    this.datas,
    this.types,
  });

  WordMorphologyPageEntity.fromJson(Map<String, dynamic> json) {
    offset = json['offset']?.toInt();
    limit = json['limit']?.toInt();
    count = json['count']?.toInt();
    if (json['datas'] != null) {
      final v = json['datas'];
      final arr0 = <WordMorphologyListItemEntity>[];
      v.forEach((v) {
        arr0.add(WordMorphologyListItemEntity.fromJson(v));
      });
      datas = arr0;
    }
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
    data['offset'] = offset;
    data['limit'] = limit;
    data['count'] = count;
    if (datas != null) {
      data['datas'] = datas!.map((e) => e.toJson()).toList();
    }
    if (types != null) {
      data['types'] = types!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}
