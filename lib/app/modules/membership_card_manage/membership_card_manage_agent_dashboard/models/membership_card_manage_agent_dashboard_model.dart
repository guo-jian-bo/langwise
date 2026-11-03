import 'package:intl/intl.dart';

class MembershipCardManageAgentDashboardEntity {
  final int? count;
  final num? createPrice;
  final num? activatePrice;
  final num? topUpPrice;
  final num? surplusPrice;
  final num? rebatePrice;
  final int? createCards;
  final int? activateCards;
  final num? refundPrice;
  final int? salesAgentId;
  final String? agentNo;
  final num? totalAmount;
  final num? donateAmount;
  final int? totalGeneratedCards;
  final int? totalActivatedCards;
  final String? monthDate;
  final String? quarterDate;
  final String? yourDate;
  final List<MembershipCardManageAgentDashboardItemModel> salesAgentDetails;

  const MembershipCardManageAgentDashboardEntity({
    this.count,
    this.createPrice,
    this.activatePrice,
    this.topUpPrice,
    this.surplusPrice,
    this.rebatePrice,
    this.createCards,
    this.activateCards,
    this.refundPrice,
    this.salesAgentId,
    this.agentNo,
    this.totalAmount,
    this.donateAmount,
    this.totalGeneratedCards,
    this.totalActivatedCards,
    this.monthDate,
    this.quarterDate,
    this.yourDate,
    this.salesAgentDetails = const [],
  });

  factory MembershipCardManageAgentDashboardEntity.fromDynamic(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return const MembershipCardManageAgentDashboardEntity();
    }

    final dynamic rawList = json['salesAgentDetails'] ?? json['datas'] ?? json['list'];
    final list = (rawList is List ? rawList : const [])
        .whereType<Map<String, dynamic>>()
        .map(MembershipCardManageAgentDashboardItemModel.fromJson)
        .toList();

    return MembershipCardManageAgentDashboardEntity(
      count: _parseInt(json['count']),
      createPrice: _parseNum(json['createPrice']),
      activatePrice: _parseNum(json['activatePrice']),
      topUpPrice: _parseNum(json['topUpPrice']),
      surplusPrice: _parseNum(json['surplusPrice']),
      rebatePrice: _parseNum(json['rebatePrice']),
      createCards: _parseInt(json['createCards']),
      activateCards: _parseInt(json['activateCards']),
      refundPrice: _parseNum(json['refundPrice']),
      salesAgentId: _parseInt(json['salesAgentId']),
      agentNo: json['agentNo']?.toString(),
      totalAmount: _parseNum(json['totalAmount']),
      donateAmount: _parseNum(json['donateAmount']),
      totalGeneratedCards: _parseInt(json['totalGeneratedCards']),
      totalActivatedCards: _parseInt(json['totalActivatedCards']),
      monthDate: json['monthDate']?.toString(),
      quarterDate: json['quarterDate']?.toString(),
      yourDate: json['yourDate']?.toString(),
      salesAgentDetails: list,
    );
  }

  static num? _parseNum(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value;
    }
    if (value is String && value.trim().isNotEmpty) {
      return num.tryParse(value.trim());
    }
    return null;
  }

  static int? _parseInt(dynamic value) {
    final numValue = _parseNum(value);
    return numValue?.toInt();
  }
}

class MembershipCardManageAgentDashboardItemModel {
  final int? salesAgentId;
  final int? userId;
  final String? agentNo;
  final String? agentName;
  final String? realName;
  final num? createPrice;
  final num? activatePrice;
  final num? refundPrice;
  final int? createCards;
  final int? activateCards;
  final num? topUpPrice;
  final num? rebatePrice;
  final num? totalAmount;
  final num? donateAmount;
  final num? surplusPrice;
  final int? totalGeneratedCards;
  final int? totalActivatedCards;

  const MembershipCardManageAgentDashboardItemModel({
    this.salesAgentId,
    this.userId,
    this.agentNo,
    this.agentName,
    this.realName,
    this.createPrice,
    this.activatePrice,
    this.refundPrice,
    this.createCards,
    this.activateCards,
    this.topUpPrice,
    this.rebatePrice,
    this.totalAmount,
    this.donateAmount,
    this.surplusPrice,
    this.totalGeneratedCards,
    this.totalActivatedCards,
  });

  String get titleText {
    final name = realName?.trim();
    final agent = agentName?.trim();
    if ((name?.isNotEmpty ?? false) && (agent?.isNotEmpty ?? false)) {
      return '$agent（$name）';
    }
    if (name?.isNotEmpty ?? false) {
      return name!;
    }
    if (agent?.isNotEmpty ?? false) {
      return agent!;
    }
    return '--';
  }

  String get subTitleText {
    final userIdText = userId?.toString();
    if (userIdText == null || userIdText.isEmpty) {
      return '--';
    }
    return '用户ID:$userIdText';
  }

  String get rightTitleText {
    final left = salesAgentId == null ? '--' : '代理商ID:$salesAgentId';
    final right = (agentNo?.trim().isNotEmpty ?? false) ? '账号:$agentNo' : '账号:--';
    return '$left    $right';
  }

  String get createPriceText => formatMoney(createPrice);
  String get activatePriceText => formatMoney(activatePrice);
  String get topUpPriceText => formatMoney(topUpPrice);
  String get refundPriceText => formatMoney(refundPrice);
  String get rebatePriceText => formatMoney(rebatePrice);
  String get donateAmountText => formatMoney(donateAmount);
  String get surplusPriceText => formatMoney(surplusPrice);
  String get totalAmountText => formatMoney(totalAmount);

  factory MembershipCardManageAgentDashboardItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MembershipCardManageAgentDashboardItemModel(
      salesAgentId: MembershipCardManageAgentDashboardEntity._parseInt(json['salesAgentId']),
      userId: MembershipCardManageAgentDashboardEntity._parseInt(json['userId']),
      agentNo: json['agentNo']?.toString(),
      agentName: json['agentName']?.toString(),
      realName: json['realName']?.toString(),
      createPrice: MembershipCardManageAgentDashboardEntity._parseNum(json['createPrice']),
      activatePrice: MembershipCardManageAgentDashboardEntity._parseNum(json['activatePrice']),
      refundPrice: MembershipCardManageAgentDashboardEntity._parseNum(json['refundPrice']),
      createCards: MembershipCardManageAgentDashboardEntity._parseInt(json['createCards']),
      activateCards: MembershipCardManageAgentDashboardEntity._parseInt(json['activateCards']),
      topUpPrice: MembershipCardManageAgentDashboardEntity._parseNum(json['topUpPrice']),
      rebatePrice: MembershipCardManageAgentDashboardEntity._parseNum(json['rebatePrice']),
      totalAmount: MembershipCardManageAgentDashboardEntity._parseNum(json['totalAmount']),
      donateAmount: MembershipCardManageAgentDashboardEntity._parseNum(json['donateAmount']),
      surplusPrice: MembershipCardManageAgentDashboardEntity._parseNum(json['surplusPrice']),
      totalGeneratedCards: MembershipCardManageAgentDashboardEntity._parseInt(json['totalGeneratedCards']),
      totalActivatedCards: MembershipCardManageAgentDashboardEntity._parseInt(json['totalActivatedCards']),
    );
  }

  static String formatMoney(num? value) {
    final target = value ?? 0;
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(target);
  }
}
