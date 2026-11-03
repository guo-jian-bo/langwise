class MembershipCardManageRebateRecordListEntity {
  final int count;
  final List<MembershipCardManageRebateRecordModel> list;

  const MembershipCardManageRebateRecordListEntity({
    required this.count,
    required this.list,
  });

  factory MembershipCardManageRebateRecordListEntity.fromDynamic(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return const MembershipCardManageRebateRecordListEntity(
        count: 0,
        list: [],
      );
    }

    final dynamic rawList = json['datas'] ?? json['list'] ?? json['records'];
    final list = (rawList is List ? rawList : const [])
        .whereType<Map<String, dynamic>>()
        .map(MembershipCardManageRebateRecordModel.fromJson)
        .toList();

    return MembershipCardManageRebateRecordListEntity(
      count: (json['count'] as num?)?.toInt() ?? list.length,
      list: list,
    );
  }
}

class MembershipCardManageRebateRecordModel {
  final String? periodType;
  final String? periodKey;
  final dynamic distPrice;
  final dynamic ratio;
  final num? distributionPrice;
  final DateTime? distributionTime;

  const MembershipCardManageRebateRecordModel({
    this.periodType,
    this.periodKey,
    this.distPrice,
    this.ratio,
    this.distributionPrice,
    this.distributionTime,
  });

  String get periodText {
    final value = periodKey?.trim();
    if (value == null || value.isEmpty) {
      return '--';
    }
    if (value.length == 6) {
      return '${value.substring(0, 4)}.${value.substring(4, 6)}';
    }
    if (value.length == 4) {
      return value;
    }
    return value;
  }

  String get typeText {
    switch (periodType?.trim()) {
      case '月':
      case 'MONTH':
        return '月度';
      case '季':
      case '季度':
      case 'QUARTER':
        return '季度';
      case '年':
      case '年度':
      case 'YEAR':
      case 'YOUR':
        return '年度';
      default:
        final value = periodType?.trim();
        return value == null || value.isEmpty ? '--' : value;
    }
  }

  String get distributionPriceText {
    final value = distributionPrice;
    if (value == null) {
      return '0.00';
    }
    return value.toStringAsFixed(2);
  }

  String get distPriceText {
    final value = _parseNum(distPrice);
    if (value == null) {
      return '0.00';
    }
    return value.toStringAsFixed(2);
  }

  String get ratioText {
    final value = _parseNum(ratio);
    if (value == null) {
      return '--';
    }
    return '${(value * 100).toStringAsFixed(_percentFractionDigits(value))}%';
  }

  String get rebateWithRatioText {
    final ratioValue = ratioText;
    if (ratioValue == '--') {
      return '返点';
    }
    return '返点($ratioValue)';
  }

  factory MembershipCardManageRebateRecordModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MembershipCardManageRebateRecordModel(
      periodType: json['periodType']?.toString(),
      periodKey: json['periodKey']?.toString(),
      distPrice: json['distPrice'],
      ratio: json['ratio'],
      distributionPrice: json['distributionPrice'] as num?,
      distributionTime: _parseDateTime(json['distributionTime']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
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

  static int _percentFractionDigits(num value) {
    final percent = value * 100;
    return percent % 1 == 0 ? 0 : 2;
  }
}
