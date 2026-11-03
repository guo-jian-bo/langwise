class ManageUnitGrammarHubEntity {
  final int? unitId;
  final int? moduleId;
  final String? unitName;
  final String? moduleNameCn;
  final ManageUnitGrammarHeaderEntity? header;
  final ManageUnitGrammarReviewEntryEntity? reviewEntry;
  final ManageUnitGrammarOutlineEntity? outline;
  final ManageUnitGrammarPipelineEntity? pipeline;
  final List<ManageUnitGrammarTargetTabEntity>? targetTabs;

  const ManageUnitGrammarHubEntity({
    this.unitId,
    this.moduleId,
    this.unitName,
    this.moduleNameCn,
    this.header,
    this.reviewEntry,
    this.outline,
    this.pipeline,
    this.targetTabs,
  });

  factory ManageUnitGrammarHubEntity.fromJson(Map<String, dynamic> json) {
    return ManageUnitGrammarHubEntity(
      unitId: json['unitId'],
      moduleId: json['moduleId'],
      unitName: json['unitName'],
      moduleNameCn: json['moduleNameCn'],
      header: json['header'] != null
          ? ManageUnitGrammarHeaderEntity.fromJson(
              Map<String, dynamic>.from(json['header']),
            )
          : null,
      reviewEntry: json['reviewEntry'] != null
          ? ManageUnitGrammarReviewEntryEntity.fromJson(
              Map<String, dynamic>.from(json['reviewEntry']),
            )
          : null,
      outline: json['outline'] != null
          ? ManageUnitGrammarOutlineEntity.fromJson(
              Map<String, dynamic>.from(json['outline']),
            )
          : null,
      pipeline: json['pipeline'] != null
          ? ManageUnitGrammarPipelineEntity.fromJson(
              Map<String, dynamic>.from(json['pipeline']),
            )
          : null,
      targetTabs: (json['targetTabs'] as List?)
          ?.map(
            (e) => ManageUnitGrammarTargetTabEntity.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'unitId': unitId,
        'moduleId': moduleId,
        'unitName': unitName,
        'moduleNameCn': moduleNameCn,
        'header': header?.toJson(),
        'reviewEntry': reviewEntry?.toJson(),
        'outline': outline?.toJson(),
        'pipeline': pipeline?.toJson(),
        'targetTabs': targetTabs?.map((e) => e.toJson()).toList(),
      };
}

class ManageUnitGrammarHeaderEntity {
  final int? targetTotalCount;
  final int? candidateCount;
  final int? boundSentenceCount;
  final int? sentenceTotalCount;

  const ManageUnitGrammarHeaderEntity({
    this.targetTotalCount,
    this.candidateCount,
    this.boundSentenceCount,
    this.sentenceTotalCount,
  });

  factory ManageUnitGrammarHeaderEntity.fromJson(Map<String, dynamic> json) {
    return ManageUnitGrammarHeaderEntity(
      targetTotalCount: json['targetTotalCount'],
      candidateCount: json['candidateCount'],
      boundSentenceCount: json['boundSentenceCount'],
      sentenceTotalCount: json['sentenceTotalCount'],
    );
  }

  Map<String, dynamic> toJson() => {
        'targetTotalCount': targetTotalCount,
        'candidateCount': candidateCount,
        'boundSentenceCount': boundSentenceCount,
        'sentenceTotalCount': sentenceTotalCount,
      };
}

class ManageUnitGrammarReviewEntryEntity {
  final bool? hasCandidate;
  final int? firstCandidateTargetUid;
  final int? candidateTotalCount;

  const ManageUnitGrammarReviewEntryEntity({
    this.hasCandidate,
    this.firstCandidateTargetUid,
    this.candidateTotalCount,
  });

  factory ManageUnitGrammarReviewEntryEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    return ManageUnitGrammarReviewEntryEntity(
      hasCandidate: json['hasCandidate'],
      firstCandidateTargetUid: json['firstCandidateTargetUid'],
      candidateTotalCount: json['candidateTotalCount'],
    );
  }

  Map<String, dynamic> toJson() => {
        'hasCandidate': hasCandidate,
        'firstCandidateTargetUid': firstCandidateTargetUid,
        'candidateTotalCount': candidateTotalCount,
      };
}

class ManageUnitGrammarOutlineEntity {
  final int? outlineId;
  final String? summary;
  final List<ManageUnitGrammarPointEntity>? points;

  const ManageUnitGrammarOutlineEntity({
    this.outlineId,
    this.summary,
    this.points,
  });

  factory ManageUnitGrammarOutlineEntity.fromJson(Map<String, dynamic> json) {
    return ManageUnitGrammarOutlineEntity(
      outlineId: json['outlineId'],
      summary: json['summary'],
      points: (json['points'] as List?)
          ?.map(
            (e) => ManageUnitGrammarPointEntity.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'outlineId': outlineId,
        'summary': summary,
        'points': points?.map((e) => e.toJson()).toList(),
      };
}

class ManageUnitGrammarPointEntity {
  final int? pointOrder;
  final String? title;
  final String? description;
  final String? objective;
  final int? candidateCount;
  final int? patternDeficitCount;
  final List<ManageUnitGrammarTargetEntity> targets;

  const ManageUnitGrammarPointEntity({
    this.pointOrder,
    this.title,
    this.description,
    this.objective,
    this.candidateCount,
    this.patternDeficitCount,
    this.targets = const [],
  });

  factory ManageUnitGrammarPointEntity.fromJson(Map<String, dynamic> json) {
    final int? pointOrder = json['pointOrder'];
    return ManageUnitGrammarPointEntity(
      pointOrder: pointOrder,
      title: json['title'],
      description: json['description'],
      objective: json['objective'],
      candidateCount: json['candidateCount'],
      patternDeficitCount: json['patternDeficitCount'],
      targets: (json['targets'] as List?)
              ?.map(
                (e) => ManageUnitGrammarTargetEntity.fromJson(
                  Map<String, dynamic>.from(e),
                  pointOrder: pointOrder,
                ),
              )
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'pointOrder': pointOrder,
        'title': title,
        'description': description,
        'objective': objective,
        'candidateCount': candidateCount,
        'patternDeficitCount': patternDeficitCount,
        'targets': targets.map((e) => e.toJson()).toList(),
      };
}

class ManageUnitGrammarTargetEntity {
  final int? uid;
  final int? pointOrder;
  final int? order;
  final String? status;
  final String? statusLabel;
  final String? assetKind;
  final String? assetLabel;
  final String? assetNid;
  final String? title;
  final String? description;
  final String? objective;
  final int? instanceCount;
  final int? boundCount;
  final int? needCount;
  final int? deficitCount;
  final num? reviewScore;

  const ManageUnitGrammarTargetEntity({
    this.uid,
    this.pointOrder,
    this.order,
    this.status,
    this.statusLabel,
    this.assetKind,
    this.assetLabel,
    this.assetNid,
    this.title,
    this.description,
    this.objective,
    this.instanceCount,
    this.boundCount,
    this.needCount,
    this.deficitCount,
    this.reviewScore,
  });

  factory ManageUnitGrammarTargetEntity.fromJson(
    Map<String, dynamic> json, {
    int? pointOrder,
  }) {
    return ManageUnitGrammarTargetEntity(
      uid: json['uid'],
      pointOrder: pointOrder ?? json['pointOrder'],
      order: json['order'],
      status: json['status'],
      statusLabel: json['statusLabel'],
      assetKind: json['assetKind'],
      assetLabel: json['assetLabel'],
      assetNid: json['assetNid'],
      title: json['title'],
      description: json['description'],
      objective: json['objective'],
        instanceCount: json['instanceCount'],
      boundCount: json['boundCount'],
      needCount: json['needCount'],
      deficitCount: json['deficitCount'],
      reviewScore: json['reviewScore'],
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'pointOrder': pointOrder,
        'order': order,
        'status': status,
        'statusLabel': statusLabel,
        'assetKind': assetKind,
        'assetLabel': assetLabel,
        'assetNid': assetNid,
        'title': title,
        'description': description,
        'objective': objective,
          'instanceCount': instanceCount,
        'boundCount': boundCount,
        'needCount': needCount,
        'deficitCount': deficitCount,
        'reviewScore': reviewScore,
      };
}

class ManageUnitGrammarPipelineEntity {
  final List<ManageUnitGrammarPipelineStepEntity>? steps;

  const ManageUnitGrammarPipelineEntity({this.steps});

  factory ManageUnitGrammarPipelineEntity.fromJson(Map<String, dynamic> json) {
    return ManageUnitGrammarPipelineEntity(
      steps: (json['steps'] as List?)
          ?.map(
            (e) => ManageUnitGrammarPipelineStepEntity.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'steps': steps?.map((e) => e.toJson()).toList(),
      };
}

class ManageUnitGrammarPipelineStepEntity {
  final int? step;
  final String? code;
  final String? name;
  final String? status;
  final bool? locked;
  final bool? running;
  final bool? done;
  final String? summary;
  final String? actionText;

  const ManageUnitGrammarPipelineStepEntity({
    this.step,
    this.code,
    this.name,
    this.status,
    this.locked,
    this.running,
    this.done,
    this.summary,
    this.actionText,
  });

  factory ManageUnitGrammarPipelineStepEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    return ManageUnitGrammarPipelineStepEntity(
      step: json['step'],
      code: json['code'],
      name: json['name'],
      status: json['status'],
      locked: json['locked'],
      running: json['running'],
      done: json['done'],
      summary: json['summary'],
      actionText: json['actionText'],
    );
  }

  Map<String, dynamic> toJson() => {
        'step': step,
        'code': code,
        'name': name,
        'status': status,
        'locked': locked,
        'running': running,
        'done': done,
        'summary': summary,
        'actionText': actionText,
      };
}

class ManageUnitGrammarTargetTabEntity {
  final String? code;
  final String? label;
  final int? count;

  const ManageUnitGrammarTargetTabEntity({
    this.code,
    this.label,
    this.count,
  });

  factory ManageUnitGrammarTargetTabEntity.fromJson(Map<String, dynamic> json) {
    return ManageUnitGrammarTargetTabEntity(
      code: json['code'],
      label: json['label'],
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'label': label,
        'count': count,
      };
}

class ManageUnitGrammarSentenceListEntity {
  final List<ManageUnitGrammarSentenceTabEntity>? sentenceTabs;
  final ManageUnitGrammarSentenceViewEntity? sentenceView;

  const ManageUnitGrammarSentenceListEntity({
    this.sentenceTabs,
    this.sentenceView,
  });

  factory ManageUnitGrammarSentenceListEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    return ManageUnitGrammarSentenceListEntity(
      sentenceTabs: (json['sentenceTabs'] as List?)
          ?.map(
            (e) => ManageUnitGrammarSentenceTabEntity.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
      sentenceView: json['sentenceView'] != null
          ? ManageUnitGrammarSentenceViewEntity.fromJson(
              Map<String, dynamic>.from(json['sentenceView']),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'sentenceTabs': sentenceTabs?.map((e) => e.toJson()).toList(),
        'sentenceView': sentenceView?.toJson(),
      };
}

class ManageUnitGrammarSentenceTabEntity {
  final String? code;
  final String? label;
  final int? count;

  const ManageUnitGrammarSentenceTabEntity({
    this.code,
    this.label,
    this.count,
  });

  factory ManageUnitGrammarSentenceTabEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    return ManageUnitGrammarSentenceTabEntity(
      code: json['code'],
      label: json['label'],
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'label': label,
        'count': count,
      };
}

class ManageUnitGrammarSentenceViewEntity {
  final List<ManageUnitGrammarSentenceEntity>? sentences;

  const ManageUnitGrammarSentenceViewEntity({this.sentences});

  factory ManageUnitGrammarSentenceViewEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    return ManageUnitGrammarSentenceViewEntity(
      sentences: (json['sentences'] as List?)
          ?.map(
            (e) => ManageUnitGrammarSentenceEntity.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'sentences': sentences?.map((e) => e.toJson()).toList(),
      };
}

class ManageUnitGrammarSentenceEntity {
  final int? uid;
  final String? content;
  final int? contentId;
  final int? semanticId;
  final String? patternNid;
  final String? source;
  final String? sourceLabel;
  final String? access;
  final bool? hasStructure;
  final String? grammarBindStatus;
  final List<ManageUnitGrammarTargetBadgeEntity>? targetBadges;

  const ManageUnitGrammarSentenceEntity({
    this.uid,
    this.content,
    this.contentId,
    this.semanticId,
    this.patternNid,
    this.source,
    this.sourceLabel,
    this.access,
    this.hasStructure,
    this.grammarBindStatus,
    this.targetBadges,
  });

  factory ManageUnitGrammarSentenceEntity.fromJson(Map<String, dynamic> json) {
    return ManageUnitGrammarSentenceEntity(
      uid: json['uid'],
      content: json['content'],
      contentId: json['contentId'],
      semanticId: json['semanticId'],
      patternNid: json['patternNid'],
      source: json['source'],
      sourceLabel: json['sourceLabel'],
      access: json['access'],
      hasStructure: json['hasStructure'],
      grammarBindStatus: json['grammarBindStatus'],
      targetBadges: (json['targetBadges'] as List?)
          ?.map(
            (e) => ManageUnitGrammarTargetBadgeEntity.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'content': content,
        'contentId': contentId,
        'semanticId': semanticId,
        'patternNid': patternNid,
        'source': source,
        'sourceLabel': sourceLabel,
        'access': access,
        'hasStructure': hasStructure,
        'grammarBindStatus': grammarBindStatus,
        'targetBadges': targetBadges?.map((e) => e.toJson()).toList(),
      };
}

class ManageUnitGrammarTargetBadgeEntity {
  final int? targetUid;
  final String? title;
  final String? status;
  final String? statusLabel;

  const ManageUnitGrammarTargetBadgeEntity({
    this.targetUid,
    this.title,
    this.status,
    this.statusLabel,
  });

  factory ManageUnitGrammarTargetBadgeEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    return ManageUnitGrammarTargetBadgeEntity(
      targetUid: json['targetUid'],
      title: json['title'],
      status: json['status'],
      statusLabel: json['statusLabel'],
    );
  }

  Map<String, dynamic> toJson() => {
        'targetUid': targetUid,
        'title': title,
        'status': status,
        'statusLabel': statusLabel,
      };
}
