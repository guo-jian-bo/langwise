class MilestoneChallengeMetaEntity {
  int? activeLimit;
  int? maxSubtaskCount;
  List<MilestoneChallengeMetricOption>? metrics;
  List<String>? promiserOptions;
  MilestoneChallengeRuleInfoEntity? ruleInfo;

  MilestoneChallengeMetaEntity({
    this.activeLimit,
    this.maxSubtaskCount,
    this.metrics,
    this.promiserOptions,
    this.ruleInfo,
  });

  MilestoneChallengeMetaEntity.fromJson(Map<String, dynamic> json) {
    activeLimit = json['activeLimit']?.toInt();
    maxSubtaskCount = json['maxSubtaskCount']?.toInt();
    if (json['metrics'] is List) {
      metrics = (json['metrics'] as List)
          .whereType<Map<String, dynamic>>()
          .map(MilestoneChallengeMetricOption.fromJson)
          .toList();
    }
    if (json['promiserOptions'] is List) {
      promiserOptions =
          (json['promiserOptions'] as List).map((item) => item.toString()).toList();
    }
    if (json['ruleInfo'] is Map<String, dynamic>) {
      ruleInfo = MilestoneChallengeRuleInfoEntity.fromJson(
        json['ruleInfo'] as Map<String, dynamic>,
      );
    }
  }
}

class MilestoneChallengeRuleInfoEntity {
  String? title;
  List<MilestoneChallengeRuleInfoItemEntity>? items;

  MilestoneChallengeRuleInfoEntity({
    this.title,
    this.items,
  });

  MilestoneChallengeRuleInfoEntity.fromJson(Map<String, dynamic> json) {
    title = json['title']?.toString();
    if (json['items'] is List) {
      items = (json['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map(MilestoneChallengeRuleInfoItemEntity.fromJson)
          .toList();
    }
  }
}

class MilestoneChallengeRuleInfoItemEntity {
  String? subTile;
  List<String>? texts;

  MilestoneChallengeRuleInfoItemEntity({
    this.subTile,
    this.texts,
  });

  MilestoneChallengeRuleInfoItemEntity.fromJson(Map<String, dynamic> json) {
    subTile = json['subTile']?.toString();
    if (json['texts'] is List) {
      texts = (json['texts'] as List).map((item) => item.toString()).toList();
    }
  }
}

class MilestoneChallengeMetricOption {
  String? metric;
  String? title;
  List<String>? allowedKinds;

  MilestoneChallengeMetricOption({
    this.metric,
    this.title,
    this.allowedKinds,
  });

  MilestoneChallengeMetricOption.fromJson(Map<String, dynamic> json) {
    metric = json['metric']?.toString();
    title = json['title']?.toString();
    if (json['allowedKinds'] is List) {
      allowedKinds =
          (json['allowedKinds'] as List).map((item) => item.toString()).toList();
    }
  }
}

class MilestoneChallengeAnalyseEntity {
  int? activeLimit;
  int? activeCount;
  bool? canCreate;
  int? spanDays;
  int? planBaselineMinutes;
  int? dailyMaxStars;
  int? dailyMaxGems;
  List<MilestoneChallengeNormalizedSubtask>? normalizedSubtasks;

  MilestoneChallengeAnalyseEntity({
    this.activeLimit,
    this.activeCount,
    this.canCreate,
    this.spanDays,
    this.planBaselineMinutes,
    this.dailyMaxStars,
    this.dailyMaxGems,
    this.normalizedSubtasks,
  });

  MilestoneChallengeAnalyseEntity.fromJson(Map<String, dynamic> json) {
    activeLimit = json['activeLimit']?.toInt();
    activeCount = json['activeCount']?.toInt();
    canCreate = json['canCreate'] == true;
    spanDays = json['spanDays']?.toInt();
    planBaselineMinutes = json['planBaselineMinutes']?.toInt();
    dailyMaxStars = json['dailyMaxStars']?.toInt();
    dailyMaxGems = json['dailyMaxGems']?.toInt();
    if (json['normalizedSubtasks'] is List) {
      normalizedSubtasks = (json['normalizedSubtasks'] as List)
          .whereType<Map<String, dynamic>>()
          .map(MilestoneChallengeNormalizedSubtask.fromJson)
          .toList();
    }
  }
}

class MilestoneChallengeNormalizedSubtask {
  String? metric;
  String? kind;
  String? unit;
  int? maxTargetValue;
  int? dailyThresholdMinutes;

  MilestoneChallengeNormalizedSubtask({
    this.metric,
    this.kind,
    this.unit,
    this.maxTargetValue,
    this.dailyThresholdMinutes,
  });

  MilestoneChallengeNormalizedSubtask.fromJson(Map<String, dynamic> json) {
    metric = json['metric']?.toString();
    kind = json['kind']?.toString();
    unit = json['unit']?.toString();
    maxTargetValue = json['maxTargetValue']?.toInt();
    dailyThresholdMinutes = json['dailyThresholdMinutes']?.toInt();
  }
}

class MilestoneChallengeOverviewEntity {
  int? activeLimit;
  int? activeCount;
  bool? canCreate;
  List<MilestoneChallengeItemEntity>? activeGoals;

  MilestoneChallengeOverviewEntity({
    this.activeLimit,
    this.activeCount,
    this.canCreate,
    this.activeGoals,
  });

  MilestoneChallengeOverviewEntity.fromJson(Map<String, dynamic> json) {
    activeLimit = json['activeLimit']?.toInt();
    activeCount = json['activeCount']?.toInt();
    canCreate = json['canCreate'] == true;
    if (json['activeGoals'] is List) {
      activeGoals = (json['activeGoals'] as List)
          .whereType<Map<String, dynamic>>()
          .map(MilestoneChallengeItemEntity.fromJson)
          .toList();
    }
  }
}

class MilestoneChallengeHistoryEntity {
  int? claimedCount;
  int? voidedCount;
  int? expiredCount;
  List<MilestoneChallengeItemEntity>? list;

  MilestoneChallengeHistoryEntity({
    this.claimedCount,
    this.voidedCount,
    this.expiredCount,
    this.list,
  });

  MilestoneChallengeHistoryEntity.fromJson(Map<String, dynamic> json) {
    claimedCount = json['claimedCount']?.toInt();
    voidedCount = json['voidedCount']?.toInt();
    expiredCount = json['expiredCount']?.toInt();
    if (json['list'] is List) {
      list = (json['list'] as List)
          .whereType<Map<String, dynamic>>()
          .map(MilestoneChallengeItemEntity.fromJson)
          .toList();
    }
  }
}

class MilestoneChallengeItemEntity {
  int? uid;
  String? name;
  String? status;
  String? statusTitle;
  String? tone;
  String? startDate;
  String? endDate;
  int? spanDays;
  int? remainingDays;
  int? planBaselineMinutes;
  int? completedSubtasks;
  double? progressPct;
  bool? allSubtasksCompleted;
  String? rewardName;
  String? rewardIcon;
  String? promiserName;
  String? rewardStatus;
  List<MilestoneChallengeSubtaskEntity>? subtasks;
  String? claimableAt;
  String? claimedAt;
  String? expiredAt;
  String? voidedAt;
  String? updated;
  String? created;

  MilestoneChallengeItemEntity({
    this.uid,
    this.name,
    this.status,
    this.statusTitle,
    this.tone,
    this.startDate,
    this.endDate,
    this.spanDays,
    this.remainingDays,
    this.planBaselineMinutes,
    this.completedSubtasks,
    this.progressPct,
    this.allSubtasksCompleted,
    this.rewardName,
    this.rewardIcon,
    this.promiserName,
    this.rewardStatus,
    this.subtasks,
    this.claimableAt,
    this.claimedAt,
    this.expiredAt,
    this.voidedAt,
    this.updated,
    this.created,
  });

  bool get isActive => status == 'ACTIVE';
  bool get isClaimable => status == 'CLAIMABLE';
  bool get isClaimed => status == 'CLAIMED';
  bool get isExpired => status == 'EXPIRED';
  bool get isVoided => status == 'VOIDED';
  bool get canClaim => isClaimable;
  bool get canVoid => !isClaimed && !isVoided;
  String get statusText {
    if (statusTitle?.isNotEmpty ?? false) {
      return statusTitle!;
    }
    switch (status) {
      case 'CLAIMABLE':
        return '待兑现';
      case 'CLAIMED':
        return '已兑现';
      case 'EXPIRED':
        return '已过期';
      case 'VOIDED':
        return '已作废';
      case 'ACTIVE':
      default:
        return '进行中';
    }
  }

  MilestoneChallengeItemEntity.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    name = json['name']?.toString();
    status = json['status']?.toString();
    statusTitle = json['statusTitle']?.toString();
    tone = json['tone']?.toString();
    startDate = json['startDate']?.toString();
    endDate = json['endDate']?.toString();
    spanDays = json['spanDays']?.toInt();
    remainingDays = json['remainingDays']?.toInt();
    planBaselineMinutes = json['planBaselineMinutes']?.toInt();
    completedSubtasks = json['completedSubtasks']?.toInt();
    progressPct = (json['progressPct'] as num?)?.toDouble();
    allSubtasksCompleted = json['allSubtasksCompleted'] == true;
    rewardName = json['rewardName']?.toString();
    rewardIcon = json['rewardIcon']?.toString();
    promiserName = json['promiserName']?.toString();
    rewardStatus = json['rewardStatus']?.toString();
    if (json['subtasks'] is List) {
      subtasks = (json['subtasks'] as List)
          .whereType<Map<String, dynamic>>()
          .map(MilestoneChallengeSubtaskEntity.fromJson)
          .toList();
    }
    claimableAt = json['claimableAt']?.toString();
    claimedAt = json['claimedAt']?.toString();
    expiredAt = json['expiredAt']?.toString();
    voidedAt = json['voidedAt']?.toString();
    updated = json['updated']?.toString();
    created = json['created']?.toString();
  }
}

class MilestoneChallengeSubtaskEntity {
  String? subtaskId;
  String? metric;
  String? kind;
  int? targetValue;
  int? currentValue;
  double? progressPct;
  bool? completed;
  String? unit;
  int? dailyThresholdMinutes;
  int? targetDays;

  MilestoneChallengeSubtaskEntity({
    this.subtaskId,
    this.metric,
    this.kind,
    this.targetValue,
    this.currentValue,
    this.progressPct,
    this.completed,
    this.unit,
    this.dailyThresholdMinutes,
    this.targetDays,
  });

  bool get isCompleted => completed == true;

  MilestoneChallengeSubtaskEntity.fromJson(Map<String, dynamic> json) {
    subtaskId = json['subtaskId']?.toString();
    metric = json['metric']?.toString();
    kind = json['kind']?.toString();
    targetValue = json['targetValue']?.toInt();
    currentValue = json['currentValue']?.toInt();
    progressPct = (json['progressPct'] as num?)?.toDouble();
    completed = json['completed'] == true;
    unit = json['unit']?.toString();
    dailyThresholdMinutes = json['dailyThresholdMinutes']?.toInt();
    targetDays = json['targetDays']?.toInt();
  }
}

class MilestoneChallengeDraftSubtaskRequest {
  String? metric;
  String? kind;
  int? targetValue;
  int? dailyThresholdMinutes;
  int? targetDays;

  MilestoneChallengeDraftSubtaskRequest({
    this.metric,
    this.kind,
    this.targetValue,
    this.dailyThresholdMinutes,
    this.targetDays,
  });

  Map<String, dynamic> toJson({bool includeTargetValue = true}) {
    final data = <String, dynamic>{};
    data['metric'] = metric;
    data['kind'] = kind;
    if (includeTargetValue && targetValue != null) {
      data['targetValue'] = targetValue;
    }
    if (dailyThresholdMinutes != null) {
      data['dailyThresholdMinutes'] = dailyThresholdMinutes;
    }
    if (targetDays != null) {
      data['targetDays'] = targetDays;
    }
    return data;
  }
}

class MilestoneChallengeCreateRequest {
  String? name;
  String? startDate;
  String? endDate;
  String? rewardName;
  String? promiserName;
  List<MilestoneChallengeDraftSubtaskRequest>? subtasks;

  MilestoneChallengeCreateRequest({
    this.name,
    this.startDate,
    this.endDate,
    this.rewardName,
    this.promiserName,
    this.subtasks,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
      'rewardName': rewardName,
      'promiserName': promiserName,
      'subtasks': subtasks?.map((item) => item.toJson()).toList() ?? [],
    };
  }
}
