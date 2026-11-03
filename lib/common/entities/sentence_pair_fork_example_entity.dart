import 'entities.dart';

/// 句对分叉例句成员，描述当前分叉组内的句子角色与附加槽位。
class SentencePairForkExampleMemberEntity {
  int? sentenceId;
  String? role;
  String? valueNid;
  List<String?>? addedSlotKeys;
  List<SentencePairForkExampleFocusEntity?>? foci;
  int? order;

  SentencePairForkExampleMemberEntity({
    this.sentenceId,
    this.role,
    this.valueNid,
    this.addedSlotKeys,
    this.foci,
    this.order,
  });

  SentencePairForkExampleMemberEntity.fromJson(Map<String, dynamic> json) {
    sentenceId = json['sentenceId']?.toInt();
    role = json['role']?.toString();
    valueNid = json['valueNid']?.toString();
    if (json['addedSlotKeys'] is List) {
      addedSlotKeys = (json['addedSlotKeys'] as List).map((item) => item?.toString()).toList();
    }
    if (json['foci'] is List) {
      foci = (json['foci'] as List).map((item) {
        if (item == null || item is! Map) return null;
        return SentencePairForkExampleFocusEntity.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    }
    order = json['order']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['sentenceId'] = sentenceId;
    data['role'] = role;
    data['valueNid'] = valueNid;
    data['addedSlotKeys'] = addedSlotKeys;
    data['foci'] = foci?.map((item) => item?.toJson()).toList();
    data['order'] = order;
    return data;
  }
}

/// 句对分叉例句焦点定义，标记当前句子需要高亮的语法片段。
class SentencePairForkExampleFocusEntity {
  String? focusKey;
  List<SentencePairForkExampleFocusRangeEntity?>? ranges;

  SentencePairForkExampleFocusEntity({
    this.focusKey,
    this.ranges,
  });

  SentencePairForkExampleFocusEntity.fromJson(Map<String, dynamic> json) {
    focusKey = json['focusKey']?.toString();
    if (json['ranges'] is List) {
      ranges = (json['ranges'] as List).map((item) {
        if (item == null || item is! Map) return null;
        return SentencePairForkExampleFocusRangeEntity.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['focusKey'] = focusKey;
    data['ranges'] = ranges?.map((item) => item?.toJson()).toList();
    return data;
  }
}

/// 句对分叉例句焦点高亮范围，承接 start/end/text/key。
class SentencePairForkExampleFocusRangeEntity {
  int? start;
  int? end;
  String? text;
  String? key;

  SentencePairForkExampleFocusRangeEntity({
    this.start,
    this.end,
    this.text,
    this.key,
  });

  SentencePairForkExampleFocusRangeEntity.fromJson(Map<String, dynamic> json) {
    start = json['start']?.toInt();
    end = json['end']?.toInt();
    text = json['text']?.toString();
    key = json['key']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['start'] = start;
    data['end'] = end;
    data['text'] = text;
    data['key'] = key;
    return data;
  }
}

/// 句对分叉例句分页项，realizationSet 字段复用分叉详情里的 realizationSet 结构。
class SentencePairForkExampleEntity {
  int? uid;
  String? assetType;
  String? assetNid;
  SentenceForkEntity? fork;
  int? order;
  List<SentencePairForkExampleMemberEntity?>? members;
  SentenceForkSentenceRealizationEntity? realizationSet;
  String? access;
  String? created;
  String? updated;

  bool get isNormal => access == "NORMAL";

  SentencePairForkExampleEntity({
    this.uid,
    this.assetType,
    this.assetNid,
    this.fork,
    this.order,
    this.members,
    this.realizationSet,
    this.access,
    this.created,
    this.updated,
  });

  SentencePairForkExampleEntity.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    assetType = json['assetType']?.toString();
    assetNid = json['assetNid']?.toString();
    if (json['fork'] is Map) {
      fork = SentenceForkEntity.fromJson(Map<String, dynamic>.from(json['fork']));
    }
    order = json['order']?.toInt();
    if (json['members'] is List) {
      members = (json['members'] as List).map((item) {
        if (item == null || item is! Map) return null;
        return SentencePairForkExampleMemberEntity.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    }
    if (json['realizationSet'] is Map) {
      realizationSet = SentenceForkSentenceRealizationEntity.fromJson(Map<String, dynamic>.from(json['realizationSet']));
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
    data['fork'] = fork?.toJson();
    data['order'] = order;
    data['members'] = members?.map((item) => item?.toJson()).toList();
    data['realizationSet'] = realizationSet?.toJson();
    data['access'] = access;
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }
}
