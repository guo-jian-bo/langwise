import '../enum/enum.dart';
import 'entities.dart';

/// 语法全景示例实体，对齐 zhenxie_grammar_panorama_example.json 结构。
class GrammarPanoramaExampleEntity {
  int? uid;
  String? assetType;
  String? assetNid;
  GrammarPanoramaExampleGridEntity? grid;
  int? order;
  int? tier;
  List<GrammarPanoramaExampleMemberEntity?>? members;
  List<GrammarPanoramaExampleMemberListItemEntity?>? memberList;
  int? cellCount;
  int? filledCellCount;
  List<String?>? missingCellKeys;
  String? access;
  String? created;
  String? updated;

  /// 是否上架
  bool get isNormal => access == AccessEnum.NORMAL.value;

  GrammarPanoramaExampleEntity({
    this.uid,
    this.assetType,
    this.assetNid,
    this.grid,
    this.order,
    this.tier,
    this.members,
    this.memberList,
    this.cellCount,
    this.filledCellCount,
    this.missingCellKeys,
    this.access,
    this.created,
    this.updated,
  });

  GrammarPanoramaExampleEntity.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    assetType = json['assetType']?.toString();
    assetNid = json['assetNid']?.toString();
    grid = _parseObject(json['grid'], GrammarPanoramaExampleGridEntity.fromJson);
    order = json['order']?.toInt();
    tier = json['tier']?.toInt();
    members = _parseObjectList(json['members'], GrammarPanoramaExampleMemberEntity.fromJson);
    memberList = _parseObjectList(
      json['memberList'],
      GrammarPanoramaExampleMemberListItemEntity.fromJson,
    );
    cellCount = json['cellCount']?.toInt();
    filledCellCount = json['filledCellCount']?.toInt();
    missingCellKeys = _parseStringList(json['missingCellKeys']);
    access = json['access']?.toString();
    created = json['created']?.toString();
    updated = json['updated']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['assetType'] = assetType;
    data['assetNid'] = assetNid;
    data['grid'] = grid?.toJson();
    data['order'] = order;
    data['tier'] = tier;
    data['members'] = members?.map((e) => e?.toJson()).toList();
    data['memberList'] = memberList?.map((e) => e?.toJson()).toList();
    data['cellCount'] = cellCount;
    data['filledCellCount'] = filledCellCount;
    data['missingCellKeys'] = missingCellKeys;
    data['access'] = access;
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }
}

/// 全景示例绑定的宫格资产基础信息。
class GrammarPanoramaExampleGridEntity {
  String? nid;
  List<LanguageText?>? name;
  List<LanguageText?>? description;

  GrammarPanoramaExampleGridEntity({
    this.nid,
    this.name,
    this.description,
  });

  GrammarPanoramaExampleGridEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    name = _parseLanguageTextList(json['name']);
    description = _parseLanguageTextList(json['description']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['name'] = name?.map((e) => e?.toJson()).toList();
    data['description'] = description?.map((e) => e?.toJson()).toList();
    return data;
  }
}

/// 宫格成员简表，对应未展开 sentence 的成员列表。
class GrammarPanoramaExampleMemberEntity {
  int? sentenceId;
  String? role;
  String? valueNid;
  List<String?>? addedSlotKeys;
  List<GrammarPanoramaExampleFocusEntity?>? foci;
  int? order;

  GrammarPanoramaExampleMemberEntity({
    this.sentenceId,
    this.role,
    this.valueNid,
    this.addedSlotKeys,
    this.foci,
    this.order,
  });

  GrammarPanoramaExampleMemberEntity.fromJson(Map<String, dynamic> json) {
    sentenceId = json['sentenceId']?.toInt();
    role = json['role']?.toString();
    valueNid = json['valueNid']?.toString();
    addedSlotKeys = _parseStringList(json['addedSlotKeys']);
    foci = _parseObjectList(json['foci'], GrammarPanoramaExampleFocusEntity.fromJson);
    order = json['order']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['sentenceId'] = sentenceId;
    data['role'] = role;
    data['valueNid'] = valueNid;
    data['addedSlotKeys'] = addedSlotKeys;
    data['foci'] = foci?.map((e) => e?.toJson()).toList();
    data['order'] = order;
    return data;
  }
}

/// 宫格成员明细，包含 cell 信息与展开后的 sentence。
class GrammarPanoramaExampleMemberListItemEntity {
  int? sentenceId;
  String? valueNid;
  GrammarPanoramaExampleCellEntity? cell;
  String? role;
  int? order;
  PatternBlueprintSentenceBriefEntity? sentence;
  List<GrammarPanoramaExampleFocusEntity?>? foci;

  GrammarPanoramaExampleMemberListItemEntity({
    this.sentenceId,
    this.valueNid,
    this.cell,
    this.role,
    this.order,
    this.sentence,
    this.foci,
  });

  GrammarPanoramaExampleMemberListItemEntity.fromJson(Map<String, dynamic> json) {
    sentenceId = json['sentenceId']?.toInt();
    valueNid = json['valueNid']?.toString();
    cell = _parseObject(json['cell'], GrammarPanoramaExampleCellEntity.fromJson);
    role = json['role']?.toString();
    order = json['order']?.toInt();
    sentence = _parseObject(
      json['sentence'],
      PatternBlueprintSentenceBriefEntity.fromJson,
    );
    foci = _parseObjectList(json['foci'], GrammarPanoramaExampleFocusEntity.fromJson);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['sentenceId'] = sentenceId;
    data['valueNid'] = valueNid;
    data['cell'] = cell?.toJson();
    data['role'] = role;
    data['order'] = order;
    data['sentence'] = sentence?.toJson();
    data['foci'] = foci?.map((e) => e?.toJson()).toList();
    return data;
  }
}

/// 宫格 cell 定义，描述当前成员落在哪个时体格子里。
class GrammarPanoramaExampleCellEntity {
  String? rowValue;
  String? colValue;
  String? key;
  List<LanguageText?>? label;
  GrammarPanoramaExampleAxisValuesEntity? axisValues;

  GrammarPanoramaExampleCellEntity({
    this.rowValue,
    this.colValue,
    this.key,
    this.label,
    this.axisValues,
  });

  GrammarPanoramaExampleCellEntity.fromJson(Map<String, dynamic> json) {
    rowValue = json['rowValue']?.toString();
    colValue = json['colValue']?.toString();
    key = json['key']?.toString();
    label = _parseLanguageTextList(json['label']);
    axisValues = _parseObject(
      json['axisValues'],
      GrammarPanoramaExampleAxisValuesEntity.fromJson,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['rowValue'] = rowValue;
    data['colValue'] = colValue;
    data['key'] = key;
    data['label'] = label?.map((e) => e?.toJson()).toList();
    data['axisValues'] = axisValues?.toJson();
    return data;
  }
}

/// 当前 grammar panorama example 使用的轴值组合。
class GrammarPanoramaExampleAxisValuesEntity {
  String? time;
  String? aspect;

  GrammarPanoramaExampleAxisValuesEntity({
    this.time,
    this.aspect,
  });

  GrammarPanoramaExampleAxisValuesEntity.fromJson(Map<String, dynamic> json) {
    time = json['time']?.toString();
    aspect = json['aspect']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['time'] = time;
    data['aspect'] = aspect;
    return data;
  }
}

/// 对照焦点定义，标记当前句子里需要高亮的语法部分。
class GrammarPanoramaExampleFocusEntity {
  String? focusKey;
  List<GrammarPanoramaExampleRangeEntity?>? ranges;

  FocusKeyEnum? get focusKeyEnum => FocusKeyEnum.fromValue(focusKey);

  GrammarPanoramaExampleFocusEntity({
    this.focusKey,
    this.ranges,
  });

  GrammarPanoramaExampleFocusEntity.fromJson(Map<String, dynamic> json) {
    focusKey = json['focusKey']?.toString();
    ranges = _parseObjectList(json['ranges'], GrammarPanoramaExampleRangeEntity.fromJson);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['focusKey'] = focusKey;
    data['ranges'] = ranges?.map((e) => e?.toJson()).toList();
    return data;
  }
}

/// 高亮范围定义，直接承接服务端返回的 start / end 区间。
class GrammarPanoramaExampleRangeEntity {
  int? start;
  int? end;
  String? text;
  String? key;

  GrammarPanoramaExampleRangeEntity({
    this.start,
    this.end,
    this.text,
    this.key,
  });

  GrammarPanoramaExampleRangeEntity.fromJson(Map<String, dynamic> json) {
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

/// 解析多语言文案列表。
List<LanguageText?>? _parseLanguageTextList(dynamic value) {
  if (value is! List) return null;
  return value.map((item) {
    if (item == null) return null;
    return LanguageText.fromJson(Map<String, dynamic>.from(item as Map));
  }).toList();
}

/// 解析字符串列表。
List<String?>? _parseStringList(dynamic value) {
  if (value is! List) return null;
  return value.map((item) => item?.toString()).toList();
}

/// 解析单个对象。
T? _parseObject<T>(dynamic value, T Function(Map<String, dynamic> json) parser) {
  if (value is! Map) return null;
  return parser(Map<String, dynamic>.from(value));
}

/// 解析对象列表。
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
