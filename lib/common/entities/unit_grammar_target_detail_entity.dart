import 'entities.dart';

class ManageUnitGrammarTargetDetailEntity {
  final ManageUnitGrammarTargetDetailTargetEntity? target;
  final ManageUnitGrammarTargetDetailAssetViewEntity? assetView;
  final ManageUnitGrammarStructInfoEntity? grammarStructInfo;
  final ManageUnitGrammarTargetDetailQuotaEntity? quota;
  final List<ManageUnitGrammarTargetDetailLexicalAnchorEntity>? lexicalAnchors;
  final List<ManageUnitGrammarTargetDetailSentenceEntity>? sentences;
  final ManageUnitGrammarTargetDetailReviewEntity? review;

  const ManageUnitGrammarTargetDetailEntity({
    this.target,
    this.assetView,
    this.grammarStructInfo,
    this.quota,
    this.lexicalAnchors,
    this.sentences,
    this.review,
  });

  factory ManageUnitGrammarTargetDetailEntity.fromJson(Map<String, dynamic> json) {
    return ManageUnitGrammarTargetDetailEntity(
      target: json['target'] != null
          ? ManageUnitGrammarTargetDetailTargetEntity.fromJson(
              Map<String, dynamic>.from(json['target']),
            )
          : null,
      assetView: json['assetView'] != null
          ? ManageUnitGrammarTargetDetailAssetViewEntity.fromJson(
              Map<String, dynamic>.from(json['assetView']),
            )
          : null,
        grammarStructInfo: json['grammarStructInfo'] != null
            ? ManageUnitGrammarStructInfoEntity.fromJson(
                Map<String, dynamic>.from(json['grammarStructInfo']),
              )
            : null,
      quota: json['quota'] != null
          ? ManageUnitGrammarTargetDetailQuotaEntity.fromJson(
              Map<String, dynamic>.from(json['quota']),
            )
          : null,
      lexicalAnchors: (json['lexicalAnchors'] as List?)
          ?.map(
            (e) => ManageUnitGrammarTargetDetailLexicalAnchorEntity.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
      sentences: (json['sentences'] as List?)
          ?.map(
            (e) => ManageUnitGrammarTargetDetailSentenceEntity.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
      review: json['review'] != null
          ? ManageUnitGrammarTargetDetailReviewEntity.fromJson(
              Map<String, dynamic>.from(json['review']),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'target': target?.toJson(),
        'assetView': assetView?.toJson(),
          'grammarStructInfo': grammarStructInfo?.toJson(),
        'quota': quota?.toJson(),
        'lexicalAnchors': lexicalAnchors?.map((e) => e.toJson()).toList(),
        'sentences': sentences?.map((e) => e.toJson()).toList(),
        'review': review?.toJson(),
      };
}

class ManageUnitGrammarStructInfoEntity {
  final String? type;
  final String? nid;
  final PatternBlueprintEntity? payload;
  final Map<String, dynamic>? payloadRaw;

  const ManageUnitGrammarStructInfoEntity({
    this.type,
    this.nid,
    this.payload,
    this.payloadRaw,
  });

  factory ManageUnitGrammarStructInfoEntity.fromJson(Map<String, dynamic> json) {
    return ManageUnitGrammarStructInfoEntity(
      type: json['type'],
      nid: json['nid'],
      payload: json['payload'] != null
          ? PatternBlueprintEntity.fromJson(
              Map<String, dynamic>.from(json['payload']),
            )
          : null,
      payloadRaw: json['payload'] != null
          ? Map<String, dynamic>.from(json['payload'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'nid': nid,
        'payload': payloadRaw ?? payload?.toJson(),
      };
}

class ManageUnitGrammarTargetDetailTargetEntity {
  final int? uid;
  final int? pointOrder;
  final int? order;
  final String? status;
  final String? statusLabel;
  final String? assetKind;
  final String? assetNid;
  final String? title;
  final String? description;
  final String? objective;
  final int? instanceCount;

  const ManageUnitGrammarTargetDetailTargetEntity({
    this.uid,
    this.pointOrder,
    this.order,
    this.status,
    this.statusLabel,
    this.assetKind,
    this.assetNid,
    this.title,
    this.description,
    this.objective,
    this.instanceCount,
  });

  factory ManageUnitGrammarTargetDetailTargetEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    return ManageUnitGrammarTargetDetailTargetEntity(
      uid: json['uid'],
      pointOrder: json['pointOrder'],
      order: json['order'],
      status: json['status'],
      statusLabel: json['statusLabel'],
      assetKind: json['assetKind'],
      assetNid: json['assetNid'],
      title: json['title'],
      description: json['description'],
      objective: json['objective'],
      instanceCount: json['instanceCount'],
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'pointOrder': pointOrder,
        'order': order,
        'status': status,
        'statusLabel': statusLabel,
        'assetKind': assetKind,
        'assetNid': assetNid,
        'title': title,
        'description': description,
        'objective': objective,
        'instanceCount': instanceCount,
      };
}

class ManageUnitGrammarTargetDetailAssetViewEntity {
  final String? kind;
  final String? nameZh;
  final String? descriptionZh;
  final String? template;
  final List<String>? skeletonChips;
  final Map<String, dynamic>? pairChain;
  final Map<String, dynamic>? paradigmBlocks;
  final Map<String, dynamic>? gridView;

  const ManageUnitGrammarTargetDetailAssetViewEntity({
    this.kind,
    this.nameZh,
    this.descriptionZh,
    this.template,
    this.skeletonChips,
    this.pairChain,
    this.paradigmBlocks,
    this.gridView,
  });

  factory ManageUnitGrammarTargetDetailAssetViewEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    return ManageUnitGrammarTargetDetailAssetViewEntity(
      kind: json['kind'],
      nameZh: json['nameZh'],
      descriptionZh: json['descriptionZh'],
      template: json['template'],
      skeletonChips: (json['skeletonChips'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      pairChain: json['pairChain'] != null
          ? Map<String, dynamic>.from(json['pairChain'])
          : null,
      paradigmBlocks: json['paradigmBlocks'] != null
          ? Map<String, dynamic>.from(json['paradigmBlocks'])
          : null,
      gridView: json['gridView'] != null
          ? Map<String, dynamic>.from(json['gridView'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'kind': kind,
        'nameZh': nameZh,
        'descriptionZh': descriptionZh,
        'template': template,
        'skeletonChips': skeletonChips,
        'pairChain': pairChain,
        'paradigmBlocks': paradigmBlocks,
        'gridView': gridView,
      };
}

class ManageUnitGrammarTargetDetailQuotaEntity {
  final bool? showQuota;
  final int? boundCount;
  final int? needCount;
  final bool? isEnough;

  const ManageUnitGrammarTargetDetailQuotaEntity({
    this.showQuota,
    this.boundCount,
    this.needCount,
    this.isEnough,
  });

  factory ManageUnitGrammarTargetDetailQuotaEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    return ManageUnitGrammarTargetDetailQuotaEntity(
      showQuota: json['showQuota'],
      boundCount: json['boundCount'],
      needCount: json['needCount'],
      isEnough: json['isEnough'],
    );
  }

  Map<String, dynamic> toJson() => {
        'showQuota': showQuota,
        'boundCount': boundCount,
        'needCount': needCount,
        'isEnough': isEnough,
      };
}

class ManageUnitGrammarTargetDetailLexicalAnchorEntity {
  final String? anchorKey;
  final String? content;
  final String? bindingMode;
  final String? bindingModeLabel;

  const ManageUnitGrammarTargetDetailLexicalAnchorEntity({
    this.anchorKey,
    this.content,
    this.bindingMode,
    this.bindingModeLabel,
  });

  factory ManageUnitGrammarTargetDetailLexicalAnchorEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    return ManageUnitGrammarTargetDetailLexicalAnchorEntity(
      anchorKey: json['anchorKey'],
      content: json['content'],
      bindingMode: json['bindingMode'],
      bindingModeLabel: json['bindingModeLabel'],
    );
  }

  Map<String, dynamic> toJson() => {
        'anchorKey': anchorKey,
        'content': content,
        'bindingMode': bindingMode,
        'bindingModeLabel': bindingModeLabel,
      };
}

class ManageUnitGrammarTargetDetailSentenceEntity {
  final int? uid;
  final String? content;
  final int? contentId;
  final int? semanticId;
  final String? access;
  final bool? hasStructure;
  final List<String>? structureChips;
  final bool? removeFromTargetAllowed;
  final bool? removeFromUnitAllowed;

  const ManageUnitGrammarTargetDetailSentenceEntity({
    this.uid,
    this.content,
    this.contentId,
    this.semanticId,
    this.access,
    this.hasStructure,
    this.structureChips,
    this.removeFromTargetAllowed,
    this.removeFromUnitAllowed,
  });

  factory ManageUnitGrammarTargetDetailSentenceEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    return ManageUnitGrammarTargetDetailSentenceEntity(
      uid: json['uid'],
      content: json['content'],
      contentId: json['contentId'],
      semanticId: json['semanticId'],
      access: json['access'],
      hasStructure: json['hasStructure'],
      structureChips: (json['structureChips'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      removeFromTargetAllowed: json['removeFromTargetAllowed'],
      removeFromUnitAllowed: json['removeFromUnitAllowed'],
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'content': content,
        'contentId': contentId,
        'semanticId': semanticId,
        'access': access,
        'hasStructure': hasStructure,
        'structureChips': structureChips,
        'removeFromTargetAllowed': removeFromTargetAllowed,
        'removeFromUnitAllowed': removeFromUnitAllowed,
      };
}

class ManageUnitGrammarTargetDetailReviewEntity {
  final List<String>? evidences;
  final num? reviewScore;
  final String? evidenceFit;
  final String? reviewNotes;

  const ManageUnitGrammarTargetDetailReviewEntity({
    this.evidences,
    this.reviewScore,
    this.evidenceFit,
    this.reviewNotes,
  });

  factory ManageUnitGrammarTargetDetailReviewEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    return ManageUnitGrammarTargetDetailReviewEntity(
      evidences: (json['evidences'] as List?)?.map((e) => e.toString()).toList(),
      reviewScore: json['reviewScore'],
      evidenceFit: json['evidenceFit'],
      reviewNotes: json['reviewNotes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'evidences': evidences,
        'reviewScore': reviewScore,
        'evidenceFit': evidenceFit,
        'reviewNotes': reviewNotes,
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

  factory ManageUnitGrammarTargetStatusUpdateEntity.fromJson(
    Map<String, dynamic> json,
  ) {
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

  factory ManageUnitGrammarMatchPreviewEntity.fromJson(
    Map<String, dynamic> json,
  ) {
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
      failureCounts: json['failureCounts'] != null
          ? Map<String, dynamic>.from(json['failureCounts'])
          : null,
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

  factory ManageUnitGrammarMatchCandidateEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic rawScore = json['score'];
    return ManageUnitGrammarMatchCandidateEntity(
      sentenceUid: json['sentenceUid'],
      content: json['content'],
      score: rawScore is num ? rawScore.toDouble() : null,
      scoreDetail: json['scoreDetail'] != null
          ? Map<String, dynamic>.from(json['scoreDetail'])
          : null,
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

  factory ManageUnitGrammarAppendSelectedEntity.fromJson(
    Map<String, dynamic> json,
  ) {
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
