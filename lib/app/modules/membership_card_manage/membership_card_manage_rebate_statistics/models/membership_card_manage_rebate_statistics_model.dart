class MembershipCardManageRebateStatisticsEntity {
  MembershipCardManageRebateStatisticsModel? month;
  MembershipCardManageRebateStatisticsModel? quarter;
  MembershipCardManageRebateStatisticsModel? your;

  MembershipCardManageRebateStatisticsEntity({
    this.month,
    this.quarter,
    this.your,
  });

  /// 从 JSON 构造对象
  factory MembershipCardManageRebateStatisticsEntity.fromJson(
      Map<String, dynamic> json) {
    return MembershipCardManageRebateStatisticsEntity(
      month: json['month'] != null
          ? MembershipCardManageRebateStatisticsModel.fromJson(json['month'])
          : null,
      quarter: json['quarter'] != null
          ? MembershipCardManageRebateStatisticsModel.fromJson(json['quarter'])
          : null,
      your: json['your'] != null
          ? MembershipCardManageRebateStatisticsModel.fromJson(json['your'])
          : null,
    );
  }

  /// 转换为 JSON 格式
  Map<String, dynamic> toJson() {
    return {
      'month': month?.toJson(),
      'quarter': quarter?.toJson(),
      'your': your?.toJson(),
    };
  }
}

class MembershipCardManageRebateStatisticsModel {
  /// 周期类型
  final String? periodType;

  /// 当前已激活金额
  final double? currentActivatedAmount;

  /// 当前已建卡金额
  final double? currentCreatedAmount;

  /// 当前预计返点
  final double? currentEstimatedRebate;

  /// 当前退款金额
  final double? currentRefundAmount;

  /// 实际金额
  final double? currentActualAmount;

  /// 当前档位
  final int? currentTierLevel;

  /// 当前档位百分比
  final double? currentTierRate;

  /// 距下一档相差金额
  final double? amountToNextTier;

  /// 上个阶段已激活金额
  final double? lastActivatedAmount;

  /// 上个阶段已退款金额
  final double? lastRefundAmount;

  /// 上个阶段实际金额
  final double? lastActualAmount;

  /// 上个阶段返点金额
  final double? lastRebateAmount;

  /// 上个阶段发放状态
  final bool? lastRebateStatus;

  /// 上个阶段档位
  final int? lastTierLevel;

  /// 上个阶段返点百分比
  final double? lastTierRate;

  /// 返点档位列表
  final List<MembershipCardManageRebateStatisticsLevelModel>? configData;

  /// 距下一档相差金额
  get currentActivatedAmountStr =>
      currentActivatedAmount?.toStringAsFixed(2) ?? '0.00';
  get currentCreatedAmountStr => currentCreatedAmount?.toStringAsFixed(2) ?? '0.00';
  get currentEstimatedRebateStr =>
      currentEstimatedRebate?.toStringAsFixed(2) ?? '0.00';
  get currentRefundAmountStr =>
      currentRefundAmount?.toStringAsFixed(2) ?? '0.00';
  get currentActualAmountStr =>
      currentActualAmount?.toStringAsFixed(2) ?? '0.00';
  get amountToNextTierStr => amountToNextTier?.toStringAsFixed(2) ?? '0.00';

  get lastActivatedAmountStr =>
      lastActivatedAmount?.toStringAsFixed(2) ?? '0.00';
  get lastRefundAmountStr => lastRefundAmount?.toStringAsFixed(2) ?? '0.00';
  get lastActualAmountStr => lastActualAmount?.toStringAsFixed(2) ?? '0.00';
  get lastRebateAmountStr => lastRebateAmount?.toStringAsFixed(2) ?? '0.00';

  MembershipCardManageRebateStatisticsModel({
    this.currentCreatedAmount,
    this.currentActivatedAmount,
    this.currentEstimatedRebate,
    this.currentRefundAmount,
    this.currentActualAmount,
    this.currentTierLevel,
    this.currentTierRate,
    this.amountToNextTier,
    this.lastActivatedAmount,
    this.lastRefundAmount,
    this.lastActualAmount,
    this.lastRebateAmount,
    this.lastRebateStatus,
    this.periodType,
    this.lastTierLevel,
    this.lastTierRate,
    this.configData,
  });

  /// 从 JSON 构造对象
  factory MembershipCardManageRebateStatisticsModel.fromJson(
      Map<String, dynamic> json) {
    return MembershipCardManageRebateStatisticsModel(
      currentActivatedAmount: json['currentActivatedAmount']?.toDouble(),
      currentCreatedAmount: json['currentCreatedAmount']?.toDouble(),
      currentEstimatedRebate: json['currentEstimatedRebate']?.toDouble(),
      currentRefundAmount: json['currentRefundAmount']?.toDouble(),
      currentActualAmount: json['currentActualAmount']?.toDouble(),
      currentTierLevel: json['currentTierLevel']?.toInt(),
      currentTierRate: json['currentTierRate']?.toDouble(),
      amountToNextTier: json['amountToNextTier']?.toDouble(),
      lastActivatedAmount: json['lastActivatedAmount']?.toDouble(),
      lastRefundAmount: json['lastRefundAmount']?.toDouble(),
      lastActualAmount: json['lastActualAmount']?.toDouble(),
      lastRebateAmount: json['lastRebateAmount']?.toDouble(),
      lastRebateStatus: json['lastRebateStatus'] as bool?,
      periodType: json['periodType'] as String?,
      lastTierLevel: json['lastTierLevel']?.toInt(),
      lastTierRate: json['lastTierRate']?.toDouble(),
      configData: json['configData'] != null
          ? (json['configData'] as List)
              .map((e) =>
                  MembershipCardManageRebateStatisticsLevelModel.fromJson(e))
              .toList()
          : null,
    );
  }

  /// 转换对象为 JSON
  Map<String, dynamic> toJson() {
    return {
      'currentActivatedAmount': currentActivatedAmount,
      'currentEstimatedRebate': currentEstimatedRebate,
      'currentRefundAmount': currentRefundAmount,
      'currentActualAmount': currentActualAmount,
      'currentTierLevel': currentTierLevel,
      'currentTierRate': currentTierRate,
      'amountToNextTier': amountToNextTier,
      'lastActivatedAmount': lastActivatedAmount,
      'lastRefundAmount': lastRefundAmount,
      'lastActualAmount': lastActualAmount,
      'lastRebateAmount': lastRebateAmount,
      'lastRebateStatus': lastRebateStatus,
      'periodType': periodType,
      'lastTierLevel': lastTierLevel,
      'lastTierRate': lastTierRate,
      'configData': configData?.map((e) => e.toJson()).toList(),
    };
  }
}

class MembershipCardManageRebateStatisticsLevelModel {
  final int? gear;
  final double? minAmount;
  final double? bonusRate;
  final String? description;
  get minAmountStr => minAmount?.toStringAsFixed(2) ?? '0.00';

  MembershipCardManageRebateStatisticsLevelModel({
    this.gear,
    this.minAmount,
    this.bonusRate,
    this.description,
  });

  /// 从 JSON 构造对象
  factory MembershipCardManageRebateStatisticsLevelModel.fromJson(
      Map<String, dynamic> json) {
    return MembershipCardManageRebateStatisticsLevelModel(
      gear: json['gear']?.toInt(),
      minAmount: json['minAmount']?.toDouble(),
      bonusRate: json['bonusRate']?.toDouble(),
      description: json['description'] as String?,
    );
  }

  /// 转换对象为 JSON
  Map<String, dynamic> toJson() {
    return {
      'gear': gear,
      'minAmount': minAmount,
      'bonusRate': bonusRate,
      'description': description,
    };
  }
}
