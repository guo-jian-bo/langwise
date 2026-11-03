import 'entities.dart';

class CardContentEtymologyDetailEntity {
  String? contentType;
  int? contentId;
  int? semanticId;
  String? content;
  String? contentKey;
  int? activeTreeUid;
  String? activeNodeId;
  int? unassignedCount;
  List<CardContentEtymologySemanticItem?>? semanticItems;
  List<CardContentEtymologyTree?>? trees;

  CardContentEtymologyDetailEntity({
    this.contentType,
    this.contentId,
    this.semanticId,
    this.content,
    this.contentKey,
    this.activeTreeUid,
    this.activeNodeId,
    this.unassignedCount,
    this.semanticItems,
    this.trees,
  });

  CardContentEtymologyDetailEntity.fromJson(Map<String, dynamic> json) {
    contentType = json['contentType']?.toString();
    contentId = json['contentId']?.toInt();
    semanticId = json['semanticId']?.toInt();
    content = json['content']?.toString();
    contentKey = json['contentKey']?.toString();
    activeTreeUid = json['activeTreeUid']?.toInt();
    activeNodeId = json['activeNodeId']?.toString();
    unassignedCount = json['unassignedCount']?.toInt();
    semanticItems = _parseSemanticItems(json['semanticItems']);
    trees = _parseTrees(json['trees']);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'contentType': contentType,
      'contentId': contentId,
      'semanticId': semanticId,
      'content': content,
      'contentKey': contentKey,
      'activeTreeUid': activeTreeUid,
      'activeNodeId': activeNodeId,
      'unassignedCount': unassignedCount,
      'semanticItems': semanticItems
          ?.whereType<CardContentEtymologySemanticItem>()
          .map((CardContentEtymologySemanticItem item) => item.toJson())
          .toList(),
      'trees': trees
          ?.whereType<CardContentEtymologyTree>()
          .map((CardContentEtymologyTree item) => item.toJson())
          .toList(),
    };
  }
}

class CardContentEtymologySemanticItem {
  String? contentType;
  int? contentId;
  int? semanticId;
  String? pos;
  String? posAddr;
  List<LanguageText?>? posTitle;
  String? translate;

  CardContentEtymologySemanticItem({
    this.contentType,
    this.contentId,
    this.semanticId,
    this.pos,
    this.posAddr,
    this.posTitle,
    this.translate,
  });

  CardContentEtymologySemanticItem.fromJson(Map<String, dynamic> json) {
    contentType = json['contentType']?.toString();
    contentId = json['contentId']?.toInt();
    semanticId = json['semanticId']?.toInt();
    pos = json['pos']?.toString();
    posAddr = json['posAddr']?.toString();
    posTitle = _parseLanguageTextList(json['posTitle']);
    translate = json['translate']?.toString();
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'contentType': contentType,
      'contentId': contentId,
      'semanticId': semanticId,
      'pos': pos,
      'posAddr': posAddr,
      'posTitle': posTitle?.map((item) => item?.toJson()).toList(),
      'translate': translate,
    };
  }
}

class CardContentEtymologyTree {
  int? uid;
  List<LanguageText?>? title;
  List<LanguageText?>? descriptions;
  int? order;
  List<CardContentEtymologyNode?>? nodes;

  CardContentEtymologyTree({
    this.uid,
    this.title,
    this.descriptions,
    this.order,
    this.nodes,
  });

  CardContentEtymologyTree.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    title = _parseLanguageTextList(json['title']);
    descriptions = _parseLanguageTextList(json['descriptions']);
    order = json['order']?.toInt();
    nodes = _parseNodes(json['nodes']);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'title': title?.map((item) => item?.toJson()).toList(),
      'descriptions': descriptions?.map((item) => item?.toJson()).toList(),
      'order': order,
      'nodes': nodes
          ?.whereType<CardContentEtymologyNode>()
          .map((CardContentEtymologyNode item) => item.toJson())
          .toList(),
    };
  }
}

class CardContentEtymologyNode {
  String? nodeId;
  List<LanguageText?>? label;
  List<LanguageText?>? bubble;
  List<LanguageText?>? forkNote;
  List<CardContentEtymologyBinding?>? bindings;
  List<ElementsCardEntityDatas?>? senseCards;

  CardContentEtymologyNode({
    this.nodeId,
    this.label,
    this.bubble,
    this.forkNote,
    this.bindings,
    this.senseCards,
  });

  CardContentEtymologyNode.fromJson(Map<String, dynamic> json) {
    nodeId = json['nodeId']?.toString();
    label = _parseLanguageTextList(json['label']);
    bubble = _parseLanguageTextList(json['bubble']);
    forkNote = _parseLanguageTextList(json['forkNote']);
    bindings = _parseBindings(json['bindings']);
    senseCards = _parseSenseCards(json['senseCards']);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'nodeId': nodeId,
      'label': label?.map((item) => item?.toJson()).toList(),
      'bubble': bubble?.map((item) => item?.toJson()).toList(),
      'forkNote': forkNote?.map((item) => item?.toJson()).toList(),
      'bindings': bindings
          ?.whereType<CardContentEtymologyBinding>()
          .map((CardContentEtymologyBinding item) => item.toJson())
          .toList(),
      'senseCards': senseCards
          ?.whereType<ElementsCardEntityDatas>()
          .map((ElementsCardEntityDatas item) => item.toJson())
          .toList(),
    };
  }
}

class CardContentEtymologyBinding {
  int? contentId;
  List<int?>? semanticIds;

  CardContentEtymologyBinding({
    this.contentId,
    this.semanticIds,
  });

  CardContentEtymologyBinding.fromJson(Map<String, dynamic> json) {
    contentId = json['contentId']?.toInt();
    semanticIds = _parseIntList(json['semanticIds']);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'contentId': contentId,
      'semanticIds': semanticIds,
    };
  }
}

List<CardContentEtymologySemanticItem?>? _parseSemanticItems(dynamic value) {
  if (value is! List) return null;
  return value
      .whereType<Map<String, dynamic>>()
      .map((Map<String, dynamic> item) => CardContentEtymologySemanticItem.fromJson(item))
      .toList();
}

List<CardContentEtymologyTree?>? _parseTrees(dynamic value) {
  if (value is! List) return null;
  return value
      .whereType<Map<String, dynamic>>()
      .map((Map<String, dynamic> item) => CardContentEtymologyTree.fromJson(item))
      .toList();
}

List<CardContentEtymologyNode?>? _parseNodes(dynamic value) {
  if (value is! List) return null;
  return value
      .whereType<Map<String, dynamic>>()
      .map((Map<String, dynamic> item) => CardContentEtymologyNode.fromJson(item))
      .toList();
}

List<CardContentEtymologyBinding?>? _parseBindings(dynamic value) {
  if (value is! List) return null;
  return value
      .whereType<Map<String, dynamic>>()
      .map((Map<String, dynamic> item) => CardContentEtymologyBinding.fromJson(item))
      .toList();
}

List<ElementsCardEntityDatas?>? _parseSenseCards(dynamic value) {
  if (value is! List) return null;
  return value
      .whereType<Map<String, dynamic>>()
      .map((Map<String, dynamic> item) => ElementsCardEntityDatas.fromJson(item))
      .toList();
}

List<LanguageText?>? _parseLanguageTextList(dynamic value) {
  if (value is! List) return null;
  return value
      .whereType<Map<String, dynamic>>()
      .map((Map<String, dynamic> item) => LanguageText.fromJson(item))
      .toList();
}

List<int?>? _parseIntList(dynamic value) {
  if (value is! List) return null;
  return value.map<int?>((item) => item?.toInt()).toList();
}
