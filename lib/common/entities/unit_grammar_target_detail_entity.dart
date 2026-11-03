import 'entities.dart';

class ManageUnitGrammarTargetDetailEntity {
  final int? uid;
  final int? pointOrder;
  final int? order;
  final String? status;
  final List<LanguageText?>? title;
  final List<LanguageText?>? description;
  final ManageUnitGrammarTargetDetailObjectiveEntity? objective;
  final ManageUnitGrammarStructInfoEntity? grammarUnifiedInfo;

  const ManageUnitGrammarTargetDetailEntity({
    this.uid,
    this.pointOrder,
    this.order,
    this.status,
    this.title,
    this.description,
    this.objective,
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

class ManageUnitGrammarTargetSentenceSetPageEntity {
  final int? uid;
  final String? assetType;
  final String? assetNid;
  final bool? isSet;
  final int? order;
  final String? access;
  final List<String>? baseSlotKeys;
  final List<String>? dialSlotKeys;
  final List<String>? growthSlotKeys;
  final ManageUnitGrammarTargetSentenceSetAssetEntity? asset;
  final List<ManageUnitGrammarTargetSentenceSetMemberEntity>? members;
  final List<PatternBlueprintSentenceBriefEntity?>? contents;

  const ManageUnitGrammarTargetSentenceSetPageEntity({
    this.uid,
    this.assetType,
    this.assetNid,
    this.isSet,
    this.order,
    this.access,
    this.baseSlotKeys,
    this.dialSlotKeys,
    this.growthSlotKeys,
    this.asset,
    this.members,
    this.contents,
  });

  factory ManageUnitGrammarTargetSentenceSetPageEntity.fromJson(Map<String, dynamic> json) {
    return ManageUnitGrammarTargetSentenceSetPageEntity(
      uid: json['uid'] is num ? (json['uid'] as num).toInt() : int.tryParse(json['uid']?.toString() ?? ''),
      assetType: json['assetType']?.toString(),
      assetNid: json['assetNid']?.toString(),
      isSet: json['isSet'] == true,
      order: json['order'] is num ? (json['order'] as num).toInt() : int.tryParse(json['order']?.toString() ?? ''),
      access: json['access']?.toString(),
      baseSlotKeys: (json['baseSlotKeys'] as List?)?.map((e) => e.toString()).toList(),
      dialSlotKeys: (json['dialSlotKeys'] as List?)?.map((e) => e.toString()).toList(),
      growthSlotKeys: (json['growthSlotKeys'] as List?)?.map((e) => e.toString()).toList(),
      asset: json['asset'] != null
          ? ManageUnitGrammarTargetSentenceSetAssetEntity.fromJson(
              Map<String, dynamic>.from(json['asset']),
            )
          : null,
      members: (json['members'] as List?)
          ?.map(
            (e) => ManageUnitGrammarTargetSentenceSetMemberEntity.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
      contents: (json['contents'] as List?)
          ?.map(
            (e) => PatternBlueprintSentenceBriefEntity.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'assetType': assetType,
        'assetNid': assetNid,
        'isSet': isSet,
        'order': order,
        'access': access,
        'baseSlotKeys': baseSlotKeys,
        'dialSlotKeys': dialSlotKeys,
        'growthSlotKeys': growthSlotKeys,
        'asset': asset?.toJson(),
        'members': members?.map((e) => e.toJson()).toList(),
        'contents': contents?.map((e) => e?.toJson()).toList(),
      };
}

class ManageUnitGrammarTargetSentenceSetAssetEntity {
  final String? nid;
  final List<LanguageText?>? name;
  final List<LanguageText?>? description;

  const ManageUnitGrammarTargetSentenceSetAssetEntity({
    this.nid,
    this.name,
    this.description,
  });

  factory ManageUnitGrammarTargetSentenceSetAssetEntity.fromJson(Map<String, dynamic> json) {
    return ManageUnitGrammarTargetSentenceSetAssetEntity(
      nid: json['nid']?.toString(),
      name: _parseLanguageTextList(json['name']),
      description: _parseLanguageTextList(json['description']),
    );
  }

  Map<String, dynamic> toJson() => {
        'nid': nid,
        'name': name?.map((e) => e?.toJson()).toList(),
        'description': description?.map((e) => e?.toJson()).toList(),
      };
}

class ManageUnitGrammarTargetSentenceSetMemberEntity {
  final int? sentenceId;
  final String? role;
  final int? order;
  final List<String>? addedSlotKeys;

  const ManageUnitGrammarTargetSentenceSetMemberEntity({
    this.sentenceId,
    this.role,
    this.order,
    this.addedSlotKeys,
  });

  factory ManageUnitGrammarTargetSentenceSetMemberEntity.fromJson(Map<String, dynamic> json) {
    return ManageUnitGrammarTargetSentenceSetMemberEntity(
      sentenceId: json['sentenceId'] is num
          ? (json['sentenceId'] as num).toInt()
          : int.tryParse(json['sentenceId']?.toString() ?? ''),
      role: json['role']?.toString(),
      order: json['order'] is num ? (json['order'] as num).toInt() : int.tryParse(json['order']?.toString() ?? ''),
      addedSlotKeys: (json['addedSlotKeys'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'sentenceId': sentenceId,
        'role': role,
        'order': order,
        'addedSlotKeys': addedSlotKeys,
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
