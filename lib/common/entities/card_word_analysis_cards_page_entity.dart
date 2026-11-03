import 'entities.dart';

class CardWordAnalysisCardsPageEntity {
  int? offset;
  int? limit;
  int? count;
  int? total;
  List<KnowledgeCommonEntityList?>? datas;
  LockEntity? rights;
  int? semanticId;
  String? pos;
  List<String?>? previewForms;

  CardWordAnalysisCardsPageEntity({
    this.offset,
    this.limit,
    this.count,
    this.total,
    this.datas,
    this.rights,
    this.semanticId,
    this.pos,
    this.previewForms,
  });

  CardWordAnalysisCardsPageEntity.fromJson(Map<String, dynamic> json) {
    offset = json['offset']?.toInt();
    limit = json['limit']?.toInt();
    count = json['count']?.toInt();
    total = json['total']?.toInt();
    if (json['datas'] != null) {
      final List<KnowledgeCommonEntityList> items = <KnowledgeCommonEntityList>[];
      for (final dynamic item in json['datas']) {
        items.add(KnowledgeCommonEntityList.fromJson(item));
      }
      datas = items;
    }
    if (json['rights'] != null) {
      rights = LockEntity.fromJson(json['rights']);
    }
    semanticId = json['semanticId']?.toInt();
    pos = json['pos']?.toString();
    previewForms = json['previewForms']?.cast<String?>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['offset'] = offset;
    data['limit'] = limit;
    data['count'] = count;
    data['total'] = total;
    if (datas != null) {
      final List<Map<String, dynamic>> items = <Map<String, dynamic>>[];
      for (final KnowledgeCommonEntityList? item in datas!) {
        if (item == null) continue;
        items.add(item.toJson());
      }
      data['datas'] = items;
    }
    if (rights != null) {
      data['rights'] = rights!.toJson();
    }
    data['semanticId'] = semanticId;
    data['pos'] = pos;
    data['previewForms'] = previewForms;
    return data;
  }
}
