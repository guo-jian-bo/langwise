import 'entities.dart';

/// 句对例句成员，描述句组内每个句子的角色与附加槽位。
class SentencePairExampleMemberEntity {
  int? sentenceId;
  String? role;
  String? valueNid;
  List<String?>? addedSlotKeys;
  List<SentencePairExampleFocusEntity?>? foci;
  int? order;

  SentencePairExampleMemberEntity({
    this.sentenceId,
    this.role,
    this.valueNid,
    this.addedSlotKeys,
    this.foci,
    this.order,
  });

  SentencePairExampleMemberEntity.fromJson(Map<String, dynamic> json) {
    sentenceId = json['sentenceId']?.toInt();
    role = json['role']?.toString();
    valueNid = json['valueNid']?.toString();
    if (json['addedSlotKeys'] is List) {
      addedSlotKeys = (json['addedSlotKeys'] as List).map((item) => item?.toString()).toList();
    }
    if (json['foci'] is List) {
      foci = (json['foci'] as List).map((item) {
        if (item == null || item is! Map) return null;
        return SentencePairExampleFocusEntity.fromJson(Map<String, dynamic>.from(item));
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
    data['foci'] = foci;
    data['order'] = order;
    return data;
  }
}

/// 句对例句焦点定义，标记当前句子需要高亮的语法片段。
class SentencePairExampleFocusEntity {
  String? focusKey;
  List<SentencePairExampleFocusRangeEntity?>? ranges;

  SentencePairExampleFocusEntity({
    this.focusKey,
    this.ranges,
  });

  SentencePairExampleFocusEntity.fromJson(Map<String, dynamic> json) {
    focusKey = json['focusKey']?.toString();
    if (json['ranges'] is List) {
      ranges = (json['ranges'] as List).map((item) {
        if (item == null || item is! Map) return null;
        return SentencePairExampleFocusRangeEntity.fromJson(Map<String, dynamic>.from(item));
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

/// 句对例句焦点高亮范围，承接 start/end/text/key。
class SentencePairExampleFocusRangeEntity {
  int? start;
  int? end;
  String? text;
  String? key;

  SentencePairExampleFocusRangeEntity({
    this.start,
    this.end,
    this.text,
    this.key,
  });

  SentencePairExampleFocusRangeEntity.fromJson(Map<String, dynamic> json) {
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

/// 句对例句分页项，realization 字段复用句对详情里的 realization 结构。
class SentencePairExampleEntity {
  int? uid;
  String? assetType;
  String? assetNid;
  SentencePairEntity? pair;
  int? order;
  List<SentencePairExampleMemberEntity?>? members;
  SentencePairSentenceRealizationEntity? realization;
  String? access;
  String? created;
  String? updated;

  /// 是否上架
  bool get isNormal => access == "NORMAL";

  SentencePairExampleEntity({
    this.uid,
    this.assetType,
    this.assetNid,
    this.pair,
    this.order,
    this.members,
    this.realization,
    this.access,
    this.created,
    this.updated,
  });

  SentencePairExampleEntity.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    assetType = json['assetType']?.toString();
    assetNid = json['assetNid']?.toString();
    if (json['pair'] is Map) {
      pair = SentencePairEntity.fromJson(Map<String, dynamic>.from(json['pair']));
    }
    order = json['order']?.toInt();
    if (json['members'] is List) {
      members = (json['members'] as List).map((item) {
        if (item == null || item is! Map) return null;
        return SentencePairExampleMemberEntity.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    }
    if (json['realization'] is Map) {
      realization = SentencePairSentenceRealizationEntity.fromJson(Map<String, dynamic>.from(json['realization']));
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
    data['pair'] = pair?.toJson();
    data['order'] = order;
    data['members'] = members?.map((item) => item?.toJson()).toList();
    data['realization'] = realization?.toJson();
    data['access'] = access;
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }
}
