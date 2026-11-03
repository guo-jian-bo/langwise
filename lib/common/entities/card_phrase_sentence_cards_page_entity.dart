import 'entities.dart';

class CardPhraseSentenceCardsRange {
  int? start;
  int? end;
  String? text;
  String? key;

  CardPhraseSentenceCardsRange({
    this.start,
    this.end,
    this.text,
    this.key,
  });

  CardPhraseSentenceCardsRange.fromJson(Map<String, dynamic> json) {
    start = json['start']?.toInt();
    end = json['end']?.toInt();
    text = json['text']?.toString();
    key = json['key']?.toString();
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'start': start,
      'end': end,
      'text': text,
      'key': key,
    };
  }
}

class CardPhraseSentenceCardsData {
  KnowledgeCommonEntityList? contentCard;
  List<CardPhraseSentenceCardsRange?>? ranges;

  CardPhraseSentenceCardsData({
    this.contentCard,
    this.ranges,
  });

  CardPhraseSentenceCardsData.fromJson(Map<String, dynamic> json) {
    if (json['contentCard'] != null) {
      contentCard = KnowledgeCommonEntityList.fromJson(json['contentCard']);
    }
    if (json['ranges'] != null) {
      final List<CardPhraseSentenceCardsRange> values =
          <CardPhraseSentenceCardsRange>[];
      for (final dynamic item in json['ranges']) {
        values.add(CardPhraseSentenceCardsRange.fromJson(item));
      }
      ranges = values;
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'contentCard': contentCard?.toJson(),
      'ranges': ranges
          ?.whereType<CardPhraseSentenceCardsRange>()
          .map((CardPhraseSentenceCardsRange item) => item.toJson())
          .toList(),
    };
  }
}

class CardPhraseSentenceCardsPageEntity {
  int? offset;
  int? limit;
  int? count;
  List<CardPhraseSentenceCardsData?>? datas;

  CardPhraseSentenceCardsPageEntity({
    this.offset,
    this.limit,
    this.count,
    this.datas,
  });

  CardPhraseSentenceCardsPageEntity.fromJson(Map<String, dynamic> json) {
    offset = json['offset']?.toInt();
    limit = json['limit']?.toInt();
    count = json['count']?.toInt();
    if (json['datas'] != null) {
      final List<CardPhraseSentenceCardsData> values =
          <CardPhraseSentenceCardsData>[];
      for (final dynamic item in json['datas']) {
        values.add(CardPhraseSentenceCardsData.fromJson(item));
      }
      datas = values;
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'offset': offset,
      'limit': limit,
      'count': count,
      'datas': datas
          ?.whereType<CardPhraseSentenceCardsData>()
          .map((CardPhraseSentenceCardsData item) => item.toJson())
          .toList(),
    };
  }
}
