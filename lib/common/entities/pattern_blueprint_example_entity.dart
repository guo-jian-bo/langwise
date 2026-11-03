import 'entities.dart';

class PatternBlueprintExampleEntity {
/*
{
  "uid": 8861,
  "assetType": "pattern",
  "assetNid": "location_entity_be_place_adv",
  "order": 1000,
  "members": [
    {
      "sentenceId": 566442,
      "role": "exemplar",
      "valueNid": "",
      "addedSlotKeys": [
        ""
      ],
      "order": 0
    }
  ],
  "memberList": [
    {
      "sentenceId": 566442,
      "content": "The red stool is here.",
      "definition": "这个红色的凳子在这里。",
      "patternNid": "location_entity_be_place_adv",
      "patternTemplate": "{located_entity} {be_marking} {place_adv} {context_phrase} {place_phrase} {time_expression}.",
      "patternName": [
        {
          "lang": "zh",
          "text": "说明在这里 / 那里"
        }
      ],
      "patternDescription": [
        {
          "lang": "zh",
          "text": "用 here / there 这类地点副词，快速说明在不在附近。"
        }
      ],
      "blueprintScope": "clause",
      "blueprintScopeName": [
        {
          "lang": "en",
          "text": "Clause Scope"
        }
      ],
      "segmentList": [
        {
          "slotKey": "located_entity",
          "slot": {
            "nid": "located_entity",
            "name": [
              {
                "lang": "zh",
                "text": "位于某处的对象"
              }
            ],
            "description": [
              {
                "lang": "zh",
                "text": "表示和“位于某处的”有关的人、事物或名词性内容。"
              }
            ],
            "categoryNid": "subject_entity",
            "color": "rgba(14,165,233,1)"
          },
          "required": true,
          "grammarControlling": true,
          "dependsOn": [
            ""
          ],
          "text": "The red stool",
          "renderSlotKey": "located_entity",
          "sourceSlotKey": "located_entity",
          "sourceSlot": {
            "nid": "located_entity",
            "name": [
              {
                "lang": "zh",
                "text": "位于某处的对象"
              }
            ],
            "description": [
              {
                "lang": "zh",
                "text": "表示和“位于某处的”有关的人、事物或名词性内容。"
              }
            ],
            "categoryNid": "subject_entity",
            "color": "rgba(14,165,233,1)"
          },
          "slotUid": 239476,
          "semanticIds": [
            32423
          ],
          "literal": false,
          "hasChildStruct": false
        }
      ],
      "access": "NORMAL"
    }
  ],
  "access": "INTERNAL",
  "created": "2026-09-01T10:27:59.604+00:00",
  "updated": "2026-09-01T10:27:59.604+00:00"
} 
*/

  int? uid;
  String? assetType;
  String? assetNid;
  int? order;
  List<ZhenxieSentenceMemberEntity?>? members;
  List<PatternBlueprintSentenceBriefEntity?>? memberList;
  String? access;
  String? created;
  String? updated;

  /// 是否上架
  bool get isNormal => access == "NORMAL";

  PatternBlueprintExampleEntity({
    this.uid,
    this.assetType,
    this.assetNid,
    this.order,
    this.members,
    this.memberList,
    this.access,
    this.created,
    this.updated,
  });
  PatternBlueprintExampleEntity.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    assetType = json['assetType']?.toString();
    assetNid = json['assetNid']?.toString();
    order = json['order']?.toInt();
    if (json['members'] is List) {
      final arr0 = <ZhenxieSentenceMemberEntity>[];
      for (final item in json['members']) {
        if (item == null || item is! Map) continue;
        arr0.add(ZhenxieSentenceMemberEntity.fromJson(Map<String, dynamic>.from(item)));
      }
      members = arr0;
    }
    if (json['memberList'] is List) {
      final arr0 = <PatternBlueprintSentenceBriefEntity>[];
      for (final item in json['memberList']) {
        if (item == null || item is! Map) continue;
        arr0.add(PatternBlueprintSentenceBriefEntity.fromJson(Map<String, dynamic>.from(item)));
      }
      memberList = arr0;
    }
    access = json['access']?.toString();
    created = json['created']?.toString();
    updated = json['updated']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['assetType'] = assetType;
    data['assetNid'] = assetNid;
    data['order'] = order;
    if (members != null) {
      final arr0 = [];
      for (final item in members!) {
        if (item == null) continue;
        arr0.add(item.toJson());
      }
      data['members'] = arr0;
    }
    if (memberList != null) {
      final arr0 = [];
      for (final item in memberList!) {
        if (item == null) continue;
        arr0.add(item.toJson());
      }
      data['memberList'] = arr0;
    }
    data['access'] = access;
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }
}
