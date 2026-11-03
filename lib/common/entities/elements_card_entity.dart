
import 'entities.dart';

class ElementsCardEntity {
/*
{
  "offset": 0,
  "limit": 20,
  "count": 10216,
  "datas": [
    {
      "contentType": "EN_WORD",
      "contentTypeTitle": "英语单词",
      "contentId": 143500,
      "content": "the",
      "definition": "用于特指或泛指名词的定冠词，表示特定、已知或唯一的事物，或用于强调、计量单位等特定语境",
      "difficulty": {
        "max": 1,
        "min": 1
      },
      "imageUrl": "http://img.timelywise.cn/knowledge/semantic/FE4E50E6DD6C1D9B0911F4A6348B6444.webp?auth_key=1748960416-0kq6dg4dt20g-0-87769d8b7f073a85d279a815a1360f8d",
      "phonetic": "ðə",
      "audioUrl": null,
      "star": 1,
      "rights": "NORMAL",
      "jump": null
    }
  ]
} 
*/

  int? offset;
  int? limit;
  int? count;
  int? total;
  List<ElementsCardEntityDatas?>? datas;
  LockEntity? rights;

  ElementsCardEntity({
    this.offset,
    this.limit,
    this.count,
    this.total,
    this.datas,
    this.rights,
  });
  ElementsCardEntity.fromJson(Map<String, dynamic> json) {
    offset = json['offset']?.toInt();
    limit = json['limit']?.toInt();
    count = json['count']?.toInt();
    total = json['total']?.toInt();
    if (json['datas'] != null) {
      final v = json['datas'];
      final arr0 = <ElementsCardEntityDatas>[];
      v.forEach((v) {
        arr0.add(ElementsCardEntityDatas.fromJson(v));
      });
      datas = arr0;
    }
    if(json['rights'] != null) {
      rights = LockEntity.fromJson(json['rights']);
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['offset'] = offset;
    data['limit'] = limit;
    data['count'] = count;
    data['total'] = total;
    if (datas != null) {
      final v = datas;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['datas'] = arr0;
    }
    if(rights != null) {
      data['rights'] = rights!.toJson();
    }
    return data;
  }
}
