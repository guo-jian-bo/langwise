import 'entities.dart';

/// Pattern add-set 某个句位的候选句结果。
class PatternRealizationSetPatternCellCandidatesEntity {
  /// 候选为空时的原因码。
  String? emptyReason;

  /// 当前格位的候选句列表。
  List<PatternBlueprintSentenceBriefEntity?>? candidates;

  PatternRealizationSetPatternCellCandidatesEntity({
    this.emptyReason,
    this.candidates,
  });

  PatternRealizationSetPatternCellCandidatesEntity.fromJson(Map<String, dynamic> json) {
    emptyReason = json['emptyReason']?.toString() ?? json['empty_reason']?.toString();
    final dynamic rawList = json['candidates'] ?? json['candidateList'] ?? json['datas'] ?? json['rows'] ?? json['list'];
    if (rawList is List) {
      final List<PatternBlueprintSentenceBriefEntity> resp = <PatternBlueprintSentenceBriefEntity>[];
      for (final dynamic item in rawList) {
        final PatternBlueprintSentenceBriefEntity? sentence = _parseSentenceBrief(item);
        if (sentence != null) {
          resp.add(sentence);
        }
      }
      candidates = resp;
    }
  }

  /// 弹窗直接使用的候选句列表。
  List<PatternBlueprintSentenceBriefEntity> get candidateList {
    return candidates?.whereType<PatternBlueprintSentenceBriefEntity>().toList() ?? const [];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['emptyReason'] = emptyReason;
    data['candidates'] = candidates?.map((e) => e?.toJson()).toList();
    return data;
  }

  /// 把候选接口里的动态对象转成句子摘要实体。
  PatternBlueprintSentenceBriefEntity? _parseSentenceBrief(dynamic raw) {
    if (raw is! Map) {
      return null;
    }

    final Map<String, dynamic> json = Map<String, dynamic>.from(raw);
    final Map<String, dynamic>? sentenceStruct = json['sentenceStruct'] is Map ? Map<String, dynamic>.from(json['sentenceStruct']) : null;
    if (sentenceStruct != null) {
      sentenceStruct.forEach((key, value) {
        json.putIfAbsent(key, () => value);
      });
    }
    if (json['sentenceId'] == null && json['uid'] != null) {
      json['sentenceId'] = json['uid'];
    }
    if (json['content'] == null && json['text'] != null) {
      json['content'] = json['text'];
    }
    if (json['definition'] == null && json['translationZh'] != null) {
      json['definition'] = json['translationZh'];
    }
    if (json['access'] == null && json['status'] != null) {
      json['access'] = json['status'];
    }
    if (json['sentenceId'] == null) {
      return null;
    }
    return PatternBlueprintSentenceBriefEntity.fromJson(json);
  }
}
