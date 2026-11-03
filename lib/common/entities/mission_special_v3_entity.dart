import 'package:langwise/common/entities/entities.dart';

class MissionSpecialV3Entity {
  String? iconUrl;
  String? title;
  String? description;
  String? direction;
  List<String>? learnDirections;
  String? color;
  int? allCount;
  int? unlockCount;
  int? diamondCount;
  int? diamondMax;
  int? nextDiamondNeedSec;
  List<TaskMissionEntityMissionKnowledgeItem?>? knowledgeList;
  List<KnowledgeCommonEntityList?>? list;

  MissionSpecialV3Entity({
    this.iconUrl,
    this.title,
    this.description,
    this.direction,
    this.learnDirections,
    this.color,
    this.allCount,
    this.unlockCount,
    this.diamondCount,
    this.diamondMax,
    this.nextDiamondNeedSec,
    this.knowledgeList,
    this.list,
  });

  MissionSpecialV3Entity.fromJson(Map<String, dynamic> json) {
    iconUrl = json['iconUrl']?.toString();
    title = json['title']?.toString();
    description = json['description']?.toString();
    direction = json['direction']?.toString();
    learnDirections = _parseLearnDirections(json['learnDirections']);
    color = json['color']?.toString();
    allCount = json['allCount']?.toInt();
    unlockCount = json['unlockCount']?.toInt();
    diamondCount = json['diamondCount']?.toInt();
    diamondMax = json['diamondMax']?.toInt();
    nextDiamondNeedSec = json['nextDiamondNeedSec']?.toInt();
    if (json['knowledgeList'] != null) {
      final v = json['knowledgeList'];
      final arr0 = <TaskMissionEntityMissionKnowledgeItem>[];
      v.forEach((v) {
        arr0.add(TaskMissionEntityMissionKnowledgeItem.fromJson(v));
      });
      knowledgeList = arr0;
    }
    if (json['list'] != null) {
      final v = json['list'];
      final arr0 = <KnowledgeCommonEntityList>[];
      v.forEach((v) {
        arr0.add(KnowledgeCommonEntityList.fromJson(v));
      });
      list = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['iconUrl'] = iconUrl;
    data['title'] = title;
    data['description'] = description;
    data['direction'] = direction;
    data['learnDirections'] = learnDirections;
    data['color'] = color;
    data['allCount'] = allCount;
    data['unlockCount'] = unlockCount;
    data['diamondCount'] = diamondCount;
    data['diamondMax'] = diamondMax;
    data['nextDiamondNeedSec'] = nextDiamondNeedSec;
    if (knowledgeList != null) {
      final v = knowledgeList;
      final arr0 = [];
      for (final v in v!) {
        arr0.add(v!.toJson());
      }
      data['knowledgeList'] = arr0;
    }
    if (list != null) {
      final v = list;
      final arr0 = [];
      for (final v in v!) {
        arr0.add(v!.toJson());
      }
      data['list'] = arr0;
    }
    return data;
  }

  static List<String>? _parseLearnDirections(dynamic raw) {
    if (raw is! List) {
      return null;
    }
    final result = raw
        .map(_extractLearnDirectionText)
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    return result.isEmpty ? null : result;
  }

  static String? _extractLearnDirectionText(dynamic item) {
    if (item == null) {
      return null;
    }
    if (item is String) {
      return item;
    }
    if (item is Map) {
      final candidates = [
        item['text'],
        item['content'],
        item['title'],
        item['direction'],
        item['learnDirection'],
      ];
      for (final candidate in candidates) {
        if (candidate != null) {
          return candidate.toString();
        }
      }
    }
    return item.toString();
  }
}
