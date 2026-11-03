import 'entities.dart';

/// Pattern add-set 手输 uid 校验结果。
class PatternRealizationSetPatternBindCheckEntity {
  /// 当前句子是否能绑到目标格位。
  bool? ok;

  /// 校验失败原因码。
  String? reason;

  /// 服务端返回的句面。
  String? text;
  String? contentType;

  /// 当前句子命中的占槽结果。
  List<String?>? occupancy;

  /// 服务端确认的句子 id。
  int? sentenceId;

  /// 服务端若回传完整句子结构，优先用于回填和高亮。
  PatternBlueprintSentenceBriefEntity? sentenceStruct;

  PatternRealizationSetPatternBindCheckEntity({
    this.ok,
    this.reason,
    this.text,
    this.contentType,
    this.occupancy,
    this.sentenceId,
    this.sentenceStruct,
  });

  PatternRealizationSetPatternBindCheckEntity.fromJson(Map<String, dynamic> json) {
    ok = json['ok'];
    reason = json['reason']?.toString();
    text = json['text']?.toString();
    contentType = json['contentType']?.toString();
    occupancy = (json['occupancy'] as List?)?.map((item) => item?.toString()).toList();
    sentenceId = json['sentenceId']?.toInt() ?? json['sentence_id']?.toInt();
    sentenceStruct = json['sentenceStruct'] is Map
        ? PatternBlueprintSentenceBriefEntity.fromJson(Map<String, dynamic>.from(json['sentenceStruct']))
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ok'] = ok;
    data['reason'] = reason;
    data['text'] = text;
    data['contentType'] = contentType;
    data['occupancy'] = occupancy;
    data['sentenceId'] = sentenceId;
    data['sentenceStruct'] = sentenceStruct?.toJson();
    return data;
  }
}
