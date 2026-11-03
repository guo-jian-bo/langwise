import 'entities.dart';

class CardPhraseRelationItem {
  String? type;
  String? nid;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  double? order;
  String? created;
  String? updated;
  Map<String, dynamic>? payload;

  CardPhraseRelationItem({
    this.type,
    this.nid,
    this.name,
    this.description,
    this.order,
    this.created,
    this.updated,
    this.payload,
  });

  CardPhraseRelationItem.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toString();
    nid = json['nid']?.toString();
    if (json['name'] != null) {
      final List<LanguageText> values = <LanguageText>[];
      for (final dynamic item in json['name']) {
        values.add(LanguageText.fromJson(item));
      }
      name = values;
    }
    if (json['description'] != null) {
      final List<LanguageText> values = <LanguageText>[];
      for (final dynamic item in json['description']) {
        values.add(LanguageText.fromJson(item));
      }
      description = values;
    }
    order = json['order']?.toDouble();
    created = json['created']?.toString();
    updated = json['updated']?.toString();
    if (json['payload'] is Map) {
      payload = Map<String, dynamic>.from(json['payload']);
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'nid': nid,
      'name': name
          ?.whereType<LanguageText>()
          .map((LanguageText item) => item.toJson())
          .toList(),
      'description': description
          ?.whereType<LanguageText>()
          .map((LanguageText item) => item.toJson())
          .toList(),
      'order': order,
      'created': created,
      'updated': updated,
      'payload': payload,
    };
  }
}

class CardPhraseRelationGroup {
  String? type;
  String? title;
  String? code;
  String? color;
  List<CardPhraseRelationItem?>? items;

  CardPhraseRelationGroup({
    this.type,
    this.title,
    this.code,
    this.color,
    this.items,
  });

  CardPhraseRelationGroup.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toString();
    title = json['title']?.toString();
    code = json['code']?.toString();
    color = json['color']?.toString();
    if (json['items'] != null) {
      final List<CardPhraseRelationItem> values = <CardPhraseRelationItem>[];
      for (final dynamic item in json['items']) {
        values.add(CardPhraseRelationItem.fromJson(item));
      }
      items = values;
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'title': title,
      'code': code,
      'color': color,
      'items': items
          ?.whereType<CardPhraseRelationItem>()
          .map((CardPhraseRelationItem item) => item.toJson())
          .toList(),
    };
  }
}

class CardPhraseRelationDetailEntity {
  List<CardPhraseRelationGroup?>? relations;

  CardPhraseRelationDetailEntity({
    this.relations,
  });

  CardPhraseRelationDetailEntity.fromJson(Map<String, dynamic> json) {
    if (json['relations'] != null) {
      final List<CardPhraseRelationGroup> values = <CardPhraseRelationGroup>[];
      for (final dynamic item in json['relations']) {
        values.add(CardPhraseRelationGroup.fromJson(item));
      }
      relations = values;
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'relations': relations
          ?.whereType<CardPhraseRelationGroup>()
          .map((CardPhraseRelationGroup item) => item.toJson())
          .toList(),
    };
  }
}
