import 'entities.dart';

class ManageUnitGrammarTargetDetailEntity {
  final int? uid;
  final int? pointOrder;
  final int? order;
  final String? status;
  final List<LanguageText?>? title;
  final List<LanguageText?>? description;
  final ManageUnitGrammarTargetDetailObjectiveEntity? objective;
  /// 金字塔匹配规格。
  final ManageUnitGrammarPyramidMatchSpecEntity? pyramidMatchSpec;
  final ManageUnitGrammarStructInfoEntity? grammarUnifiedInfo;

  const ManageUnitGrammarTargetDetailEntity({
    this.uid,
    this.pointOrder,
    this.order,
    this.status,
    this.title,
    this.description,
    this.objective,
    this.pyramidMatchSpec,
    this.grammarUnifiedInfo,
  });

  factory ManageUnitGrammarTargetDetailEntity.fromJson(Map<String, dynamic> json) {
    return ManageUnitGrammarTargetDetailEntity(
      uid: json['uid'] is num ? (json['uid'] as num).toInt() : int.tryParse(json['uid']?.toString() ?? ''),
      pointOrder: json['pointOrder'] is num
          ? (json['pointOrder'] as num).toInt()
          : int.tryParse(json['pointOrder']?.toString() ?? ''),
      order: json['order'] is num ? (json['order'] as num).toInt() : int.tryParse(json['order']?.toString() ?? ''),
      status: json['status']?.toString(),
      title: _parseLanguageTextList(json['title']),
      description: _parseLanguageTextList(json['description']),
      objective: json['objective'] != null
          ? ManageUnitGrammarTargetDetailObjectiveEntity.fromJson(
              Map<String, dynamic>.from(json['objective']),
            )
          : null,
      pyramidMatchSpec: json['pyramidMatchSpec'] != null
          ? ManageUnitGrammarPyramidMatchSpecEntity.fromJson(
              Map<String, dynamic>.from(json['pyramidMatchSpec']),
            )
          : null,
      grammarUnifiedInfo: json['grammarUnifiedInfo'] != null
          ? ManageUnitGrammarStructInfoEntity.fromJson(
              Map<String, dynamic>.from(json['grammarUnifiedInfo']),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'pointOrder': pointOrder,
        'order': order,
        'status': status,
        'title': title?.map((e) => e?.toJson()).toList(),
        'description': description?.map((e) => e?.toJson()).toList(),
        'objective': objective?.toJson(),
        'pyramidMatchSpec': pyramidMatchSpec?.toJson(),
        'grammarUnifiedInfo': grammarUnifiedInfo?.toJson(),
      };
}

class ManageUnitGrammarTargetDetailObjectiveEntity {
  final String? outcome;
  final List<String>? dimensionNids;

  const ManageUnitGrammarTargetDetailObjectiveEntity({
    this.outcome,
    this.dimensionNids,
  });

  factory ManageUnitGrammarTargetDetailObjectiveEntity.fromJson(Map<String, dynamic> json) {
    return ManageUnitGrammarTargetDetailObjectiveEntity(
      outcome: json['outcome']?.toString(),
      dimensionNids: (json['dimensionNids'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'outcome': outcome,
        'dimensionNids': dimensionNids,
      };
}

class ManageUnitGrammarStructInfoEntity {
  final String? type;
  final String? nid;
  final Map<String, dynamic>? payload;

  const ManageUnitGrammarStructInfoEntity({
    this.type,
    this.nid,
    this.payload,
  });

  factory ManageUnitGrammarStructInfoEntity.fromJson(Map<String, dynamic> json) {
    return ManageUnitGrammarStructInfoEntity(
      type: json['type']?.toString(),
      nid: json['nid']?.toString(),
      payload: json['payload'] != null ? Map<String, dynamic>.from(json['payload']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'nid': nid,
        'payload': payload,
      };
}

/// 金字塔匹配规则主体。
class ManageUnitGrammarPyramidMatchSpecEntity {
  final String? matchScope;
  final ManageUnitGrammarPyramidSentenceConstraintsEntity? sentenceConstraints;
  final ManageUnitGrammarPyramidTargetClauseSelectorEntity? targetClauseSelector;
  final ManageUnitGrammarPyramidClauseConstraintsEntity? clauseConstraints;
  final List<dynamic>? lexicalConstraints;

  const ManageUnitGrammarPyramidMatchSpecEntity({
    this.matchScope,
    this.sentenceConstraints,
    this.targetClauseSelector,
    this.clauseConstraints,
    this.lexicalConstraints,
  });

  factory ManageUnitGrammarPyramidMatchSpecEntity.fromJson(Map<String, dynamic> json) {
    return ManageUnitGrammarPyramidMatchSpecEntity(
      matchScope: json['matchScope']?.toString(),
      sentenceConstraints: json['sentenceConstraints'] != null
          ? ManageUnitGrammarPyramidSentenceConstraintsEntity.fromJson(
              Map<String, dynamic>.from(json['sentenceConstraints']),
            )
          : null,
      targetClauseSelector: json['targetClauseSelector'] != null
          ? ManageUnitGrammarPyramidTargetClauseSelectorEntity.fromJson(
              Map<String, dynamic>.from(json['targetClauseSelector']),
            )
          : null,
      clauseConstraints: json['clauseConstraints'] != null
          ? ManageUnitGrammarPyramidClauseConstraintsEntity.fromJson(
              Map<String, dynamic>.from(json['clauseConstraints']),
            )
          : null,
      lexicalConstraints: (json['lexicalConstraints'] as List?)?.toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'matchScope': matchScope,
        'sentenceConstraints': sentenceConstraints?.toJson(),
        'targetClauseSelector': targetClauseSelector?.toJson(),
        'clauseConstraints': clauseConstraints?.toJson(),
        'lexicalConstraints': lexicalConstraints,
      };
}

/// 句子层面的约束条件。
class ManageUnitGrammarPyramidSentenceConstraintsEntity {
  final List<String>? basicTypeNids;
  final List<String>? functionalTypeNids;
  final List<String>? sentencePatternNids;
  final int? clauseCount;

  const ManageUnitGrammarPyramidSentenceConstraintsEntity({
    this.basicTypeNids,
    this.functionalTypeNids,
    this.sentencePatternNids,
    this.clauseCount,
  });

  factory ManageUnitGrammarPyramidSentenceConstraintsEntity.fromJson(Map<String, dynamic> json) {
    return ManageUnitGrammarPyramidSentenceConstraintsEntity(
      basicTypeNids: _parseStringList(json['basicTypeNids']),
      functionalTypeNids: _parseStringList(json['functionalTypeNids']),
      sentencePatternNids: _parseStringList(json['sentencePatternNids']),
      clauseCount: json['clauseCount'] is num
          ? (json['clauseCount'] as num).toInt()
          : int.tryParse(json['clauseCount']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'basicTypeNids': basicTypeNids,
        'functionalTypeNids': functionalTypeNids,
        'sentencePatternNids': sentencePatternNids,
        'clauseCount': clauseCount,
      };
}

/// 目标子句选择规则。
class ManageUnitGrammarPyramidTargetClauseSelectorEntity {
  final String? clauseType;
  final String? roleInParent;
  final int? orderInSentence;
  final bool? parentClauseRequired;

  const ManageUnitGrammarPyramidTargetClauseSelectorEntity({
    this.clauseType,
    this.roleInParent,
    this.orderInSentence,
    this.parentClauseRequired,
  });

  factory ManageUnitGrammarPyramidTargetClauseSelectorEntity.fromJson(Map<String, dynamic> json) {
    return ManageUnitGrammarPyramidTargetClauseSelectorEntity(
      clauseType: json['clauseType']?.toString(),
      roleInParent: json['roleInParent']?.toString(),
      orderInSentence: json['orderInSentence'] is num
          ? (json['orderInSentence'] as num).toInt()
          : int.tryParse(json['orderInSentence']?.toString() ?? ''),
      parentClauseRequired: json['parentClauseRequired'] is bool ? json['parentClauseRequired'] : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'clauseType': clauseType,
        'roleInParent': roleInParent,
        'orderInSentence': orderInSentence,
        'parentClauseRequired': parentClauseRequired,
      };
}

/// 子句层面的约束条件。
class ManageUnitGrammarPyramidClauseConstraintsEntity {
  final List<String>? patternNids;
  final List<String>? svocaCodeNids;
  final List<String>? grammarFeatures;
  final ManageUnitGrammarPyramidSpecialFeaturesEntity? specialFeatures;
  final ManageUnitGrammarPyramidSlotsEntity? slots;

  const ManageUnitGrammarPyramidClauseConstraintsEntity({
    this.patternNids,
    this.svocaCodeNids,
    this.grammarFeatures,
    this.specialFeatures,
    this.slots,
  });

  factory ManageUnitGrammarPyramidClauseConstraintsEntity.fromJson(Map<String, dynamic> json) {
    return ManageUnitGrammarPyramidClauseConstraintsEntity(
      patternNids: _parseStringList(json['patternNids']),
      svocaCodeNids: _parseStringList(json['svocaCodeNids']),
      grammarFeatures: _parseStringList(json['grammarFeatures']),
      specialFeatures: json['specialFeatures'] is Map
          ? ManageUnitGrammarPyramidSpecialFeaturesEntity.fromJson(
              Map<String, dynamic>.from(json['specialFeatures']),
            )
          : null,
      slots: json['slots'] != null
          ? ManageUnitGrammarPyramidSlotsEntity.fromJson(
              Map<String, dynamic>.from(json['slots']),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'patternNids': patternNids,
        'svocaCodeNids': svocaCodeNids,
        'grammarFeatures': grammarFeatures,
        'specialFeatures': specialFeatures?.toJson(),
        'slots': slots?.toJson(),
      };
}

/// 特殊语法特征约束。
class ManageUnitGrammarPyramidSpecialFeaturesEntity {
  final List<String>? requiredCodeNids;
  final List<String>? forbiddenCodeNids;
  final bool? allowAdditional;

  const ManageUnitGrammarPyramidSpecialFeaturesEntity({
    this.requiredCodeNids,
    this.forbiddenCodeNids,
    this.allowAdditional,
  });

  factory ManageUnitGrammarPyramidSpecialFeaturesEntity.fromJson(Map<String, dynamic> json) {
    return ManageUnitGrammarPyramidSpecialFeaturesEntity(
      requiredCodeNids: _parseStringList(json['requiredCodeNids']),
      forbiddenCodeNids: _parseStringList(json['forbiddenCodeNids']),
      allowAdditional: json['allowAdditional'] is bool ? json['allowAdditional'] : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'requiredCodeNids': requiredCodeNids,
        'forbiddenCodeNids': forbiddenCodeNids,
        'allowAdditional': allowAdditional,
      };
}

/// 槽位约束配置。
class ManageUnitGrammarPyramidSlotsEntity {
  final List<String>? patternRequiredSlotKeys;
  final List<String>? activatedOptionalSlotKeys;
  final List<String>? forbiddenSlotKeys;
  final bool? allowAdditionalOptionalSlots;

  const ManageUnitGrammarPyramidSlotsEntity({
    this.patternRequiredSlotKeys,
    this.activatedOptionalSlotKeys,
    this.forbiddenSlotKeys,
    this.allowAdditionalOptionalSlots,
  });

  factory ManageUnitGrammarPyramidSlotsEntity.fromJson(Map<String, dynamic> json) {
    return ManageUnitGrammarPyramidSlotsEntity(
      patternRequiredSlotKeys: _parseStringList(json['patternRequiredSlotKeys']),
      activatedOptionalSlotKeys: _parseStringList(json['activatedOptionalSlotKeys']),
      forbiddenSlotKeys: _parseStringList(json['forbiddenSlotKeys']),
      allowAdditionalOptionalSlots: json['allowAdditionalOptionalSlots'] is bool
          ? json['allowAdditionalOptionalSlots']
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'patternRequiredSlotKeys': patternRequiredSlotKeys,
        'activatedOptionalSlotKeys': activatedOptionalSlotKeys,
        'forbiddenSlotKeys': forbiddenSlotKeys,
        'allowAdditionalOptionalSlots': allowAdditionalOptionalSlots,
      };
}

class ManageUnitGrammarTargetStatusUpdateEntity {
  final int? targetUid;
  final String? status;
  final int? remainingCandidateCount;
  final int? nextCandidateTargetUid;
  final bool? reviewCompleted;

  const ManageUnitGrammarTargetStatusUpdateEntity({
    this.targetUid,
    this.status,
    this.remainingCandidateCount,
    this.nextCandidateTargetUid,
    this.reviewCompleted,
  });

  factory ManageUnitGrammarTargetStatusUpdateEntity.fromJson(Map<String, dynamic> json) {
    return ManageUnitGrammarTargetStatusUpdateEntity(
      targetUid: json['targetUid'],
      status: json['status'],
      remainingCandidateCount: json['remainingCandidateCount'],
      nextCandidateTargetUid: json['nextCandidateTargetUid'],
      reviewCompleted: json['reviewCompleted'],
    );
  }

  Map<String, dynamic> toJson() => {
        'targetUid': targetUid,
        'status': status,
        'remainingCandidateCount': remainingCandidateCount,
        'nextCandidateTargetUid': nextCandidateTargetUid,
        'reviewCompleted': reviewCompleted,
      };
}

class ManageUnitGrammarMatchPreviewEntity {
  final String? mode;
  final int? targetUid;
  final int? need;
  final int? bound;
  final int? deficit;
  final List<ManageUnitGrammarMatchCandidateEntity>? matches;
  final Map<String, dynamic>? failureCounts;

  const ManageUnitGrammarMatchPreviewEntity({
    this.mode,
    this.targetUid,
    this.need,
    this.bound,
    this.deficit,
    this.matches,
    this.failureCounts,
  });

  factory ManageUnitGrammarMatchPreviewEntity.fromJson(Map<String, dynamic> json) {
    return ManageUnitGrammarMatchPreviewEntity(
      mode: json['mode'],
      targetUid: json['targetUid'],
      need: json['need'],
      bound: json['bound'],
      deficit: json['deficit'],
      matches: (json['matches'] as List?)
          ?.map(
            (e) => ManageUnitGrammarMatchCandidateEntity.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
      failureCounts: json['failureCounts'] != null ? Map<String, dynamic>.from(json['failureCounts']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'mode': mode,
        'targetUid': targetUid,
        'need': need,
        'bound': bound,
        'deficit': deficit,
        'matches': matches?.map((e) => e.toJson()).toList(),
        'failureCounts': failureCounts,
      };
}

class ManageUnitGrammarMatchCandidateEntity {
  final int? sentenceUid;
  final String? content;
  final double? score;
  final Map<String, dynamic>? scoreDetail;
  final String? patternNid;

  const ManageUnitGrammarMatchCandidateEntity({
    this.sentenceUid,
    this.content,
    this.score,
    this.scoreDetail,
    this.patternNid,
  });

  factory ManageUnitGrammarMatchCandidateEntity.fromJson(Map<String, dynamic> json) {
    final dynamic rawScore = json['score'];
    return ManageUnitGrammarMatchCandidateEntity(
      sentenceUid: json['sentenceUid'],
      content: json['content'],
      score: rawScore is num ? rawScore.toDouble() : null,
      scoreDetail: json['scoreDetail'] != null ? Map<String, dynamic>.from(json['scoreDetail']) : null,
      patternNid: json['patternNid'],
    );
  }

  Map<String, dynamic> toJson() => {
        'sentenceUid': sentenceUid,
        'content': content,
        'score': score,
        'scoreDetail': scoreDetail,
        'patternNid': patternNid,
      };
}

class ManageUnitGrammarAppendSelectedEntity {
  final int? targetUid;
  final int? writtenCount;
  final int? boundCount;
  final int? needCount;
  final int? deficitCount;

  const ManageUnitGrammarAppendSelectedEntity({
    this.targetUid,
    this.writtenCount,
    this.boundCount,
    this.needCount,
    this.deficitCount,
  });

  factory ManageUnitGrammarAppendSelectedEntity.fromJson(Map<String, dynamic> json) {
    return ManageUnitGrammarAppendSelectedEntity(
      targetUid: json['targetUid'],
      writtenCount: json['writtenCount'],
      boundCount: json['boundCount'],
      needCount: json['needCount'],
      deficitCount: json['deficitCount'],
    );
  }

  Map<String, dynamic> toJson() => {
        'targetUid': targetUid,
        'writtenCount': writtenCount,
        'boundCount': boundCount,
        'needCount': needCount,
        'deficitCount': deficitCount,
      };
}

List<LanguageText?>? _parseLanguageTextList(dynamic value) {
  if (value is! List) return null;
  return value
      .whereType<Map>()
      .map((e) => LanguageText.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

List<String>? _parseStringList(dynamic value) {
  if (value is! List) return null;
  return value.map((e) => e.toString()).toList();
}
