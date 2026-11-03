/// Pattern add-set 整组门禁校验结果。
class PatternRealizationSetPatternMatchCheckEntity {
  /// 当前整组盘面是否通过门禁校验。
  bool? ok;

  /// 未通过时的失败原因列表。
  List<PatternRealizationSetPatternMatchFailureEntity>? failures;

  PatternRealizationSetPatternMatchCheckEntity({
    this.ok,
    this.failures,
  });

  PatternRealizationSetPatternMatchCheckEntity.fromJson(Map<String, dynamic> json) {
    ok = json['ok'];
    failures = (json['failures'] as List?)
        ?.whereType<Map<String, dynamic>>()
        .map((item) => PatternRealizationSetPatternMatchFailureEntity.fromJson(item))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ok'] = ok;
    data['failures'] = failures?.map((item) => item.toJson()).toList();
    return data;
  }
}

/// Pattern add-set 整组门禁失败项。
class PatternRealizationSetPatternMatchFailureEntity {
  /// 失败原因码。
  String? code;

  PatternRealizationSetPatternMatchFailureEntity({
    this.code,
  });

  PatternRealizationSetPatternMatchFailureEntity.fromJson(Map<String, dynamic> json) {
    code = json['code']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['code'] = code;
    return data;
  }
}
