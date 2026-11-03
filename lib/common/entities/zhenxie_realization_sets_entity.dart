import 'entities.dart';

/// 句型蓝图详情里的 realizationSets 容器，兼容 pattern、compare、pair、fork、grid 等资产形态。
class ZhenxieRealizationSetsEntity {
  int? uid;
  String? contentType;
  String? assetType;
  String? assetNid;
  bool? isSet;
  ZhenxieRealizationSetsNamedInfoEntity? asset;
  int? order;
  String? topicNid;
  ZhenxieRealizationSetsDifficultyEntity? difficulty;
  int? tier;
  String? access;
  List<String?>? baseSlotKeys;
  List<String?>? dialSlotKeys;
  List<String?>? growthSlotKeys;
  List<ZhenxieSentenceMemberEntity?>? members;
  List<ZhenxieSentenceMemberSentenceEntity?>? memberList;
  List<SentencePatternCompareSentenceBindingEntity?>? bindingList;
  String? created;
  String? updated;

  /// 是否上架
  bool get isNormal => access == "NORMAL";

  /// 配对 from 句子成员。
  ZhenxieSentenceMemberEntity? get pairFromMember => _findMemberByRole('from');

  /// 配对 to 句子成员。
  ZhenxieSentenceMemberEntity? get pairToMember => _findMemberByRole('to');

  /// 分叉 fork_from 句子成员。
  ZhenxieSentenceMemberEntity? get forkFromMember => _findMemberByRole('fork_from');

  /// 分叉 fork_to 句子成员列表。
  List<ZhenxieSentenceMemberEntity?> get forkToMembers => _findMembersByRole('fork_to');

  ZhenxieRealizationSetsEntity({
    this.uid,
    this.contentType,
    this.assetType,
    this.assetNid,
    this.isSet,
    this.asset,
    this.order,
    this.topicNid,
    this.difficulty,
    this.tier,
    this.access,
    this.baseSlotKeys,
    this.dialSlotKeys,
    this.growthSlotKeys,
    this.members,
    this.memberList,
    this.bindingList,
    this.created,
    this.updated,
  });

  ZhenxieRealizationSetsEntity.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    contentType = json['contentType']?.toString();
    assetType = json['assetType']?.toString();
    assetNid = json['assetNid']?.toString();
    isSet = json['isSet'];
    asset = _parseObject(
      json['asset'],
      ZhenxieRealizationSetsNamedInfoEntity.fromJson,
    );
    order = json['order']?.toInt();
    topicNid = json['topicNid']?.toString();
    difficulty = _parseObject(
      json['difficulty'],
      ZhenxieRealizationSetsDifficultyEntity.fromJson,
    );
    tier = json['tier']?.toInt();
    access = json['access']?.toString();
    baseSlotKeys = _parseStringList(json['baseSlotKeys']);
    dialSlotKeys = _parseStringList(json['dialSlotKeys']);
    growthSlotKeys = _parseStringList(json['growthSlotKeys']);
    members = _parseObjectList(
      json['members'],
      ZhenxieSentenceMemberEntity.fromJson,
    );
    memberList = _parseObjectList(
      json['memberList'],
      ZhenxieSentenceMemberSentenceEntity.fromJson,
    );
    bindingList = _parseObjectList(
      json['bindingList'],
      SentencePatternCompareSentenceBindingEntity.fromJson,
    );
    created = json['created']?.toString();
    updated = json['updated']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['contentType'] = contentType;
    data['assetType'] = assetType;
    data['assetNid'] = assetNid;
    data['isSet'] = isSet;
    data['asset'] = asset?.toJson();
    data['order'] = order;
    data['topicNid'] = topicNid;
    data['difficulty'] = difficulty?.toJson();
    data['tier'] = tier;
    data['access'] = access;
    data['baseSlotKeys'] = baseSlotKeys;
    data['dialSlotKeys'] = dialSlotKeys;
    data['growthSlotKeys'] = growthSlotKeys;
    data['members'] = members?.map((item) => item?.toJson()).toList();
    data['memberList'] = memberList?.map((item) => item?.toJson()).toList();
    data['bindingList'] = bindingList?.map((item) => item?.toJson()).toList();
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }

  /// 按角色取单个成员，兼容 pair / fork 的成员映射。
  ZhenxieSentenceMemberEntity? _findMemberByRole(String role) {
    final List<ZhenxieSentenceMemberEntity?> memberItems = members ?? const <ZhenxieSentenceMemberEntity?>[];
    for (final ZhenxieSentenceMemberEntity? item in memberItems) {
      if (item?.role == role) {
        return item;
      }
    }
    return null;
  }

  /// 按角色取成员列表，主要用于 fork_to 多分支场景。
  List<ZhenxieSentenceMemberEntity?> _findMembersByRole(String role) {
    final List<ZhenxieSentenceMemberEntity?> memberItems = members ?? const <ZhenxieSentenceMemberEntity?>[];
    return memberItems.where((item) => item?.role == role).toList();
  }
}

/// realizationSets 里的轻量命名信息。
class ZhenxieRealizationSetsNamedInfoEntity {
  String? nid;
  List<LanguageText?>? name;
  List<LanguageText?>? description;

  ZhenxieRealizationSetsNamedInfoEntity({
    this.nid,
    this.name,
    this.description,
  });

  ZhenxieRealizationSetsNamedInfoEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    name = _parseLanguageTextList(json['name']);
    description = _parseLanguageTextList(json['description']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['name'] = name?.map((item) => item?.toJson()).toList();
    data['description'] = description?.map((item) => item?.toJson()).toList();
    return data;
  }
}

/// realizationSets 使用的难度范围。
class ZhenxieRealizationSetsDifficultyEntity {
  int? max;
  int? min;

  ZhenxieRealizationSetsDifficultyEntity({
    this.max,
    this.min,
  });

  ZhenxieRealizationSetsDifficultyEntity.fromJson(Map<String, dynamic> json) {
    max = json['max']?.toInt();
    min = json['min']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['max'] = max;
    data['min'] = min;
    return data;
  }
}

T? _parseObject<T>(dynamic value, T Function(Map<String, dynamic> json) parser) {
  if (value is! Map) return null;
  return parser(Map<String, dynamic>.from(value));
}

List<T?>? _parseObjectList<T>(
  dynamic value,
  T Function(Map<String, dynamic> json) parser,
) {
  if (value is! List) return null;
  return value.map((item) {
    if (item == null || item is! Map) return null;
    return parser(Map<String, dynamic>.from(item));
  }).toList();
}

List<String?>? _parseStringList(dynamic value) {
  if (value is! List) return null;
  return value.map((item) => item?.toString()).toList();
}

List<LanguageText?>? _parseLanguageTextList(dynamic value) {
  if (value is! List) return null;
  return value.map((item) {
    if (item == null || item is! Map) return null;
    return LanguageText.fromJson(Map<String, dynamic>.from(item));
  }).toList();
}
