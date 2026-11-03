class MembershipCardManageRechargeRecordListEntity {
  final int count;
  final List<MembershipCardManageRechargeRecordModel> list;

  const MembershipCardManageRechargeRecordListEntity({
    required this.count,
    required this.list,
  });

  factory MembershipCardManageRechargeRecordListEntity.fromDynamic(
    dynamic json,
  ) {
    if (json is! Map<String, dynamic>) {
      return const MembershipCardManageRechargeRecordListEntity(
        count: 0,
        list: [],
      );
    }

    final rawList = json['datas'] ?? json['list'] ?? json['records'] ?? [];
    final list = (rawList is List ? rawList : const [])
        .whereType<Map<String, dynamic>>()
        .map(MembershipCardManageRechargeRecordModel.fromJson)
        .toList();

    return MembershipCardManageRechargeRecordListEntity(
      count: (json['count'] as num?)?.toInt() ?? list.length,
      list: list,
    );
  }
}

class MembershipCardManageRechargeRecordModel {
  final num? amount;
  final num? totalAmount;
  final num? bonusAmount;
  final String? remark;
  final String? status;
  final DateTime? created;

  const MembershipCardManageRechargeRecordModel({
    this.amount,
    this.totalAmount,
    this.bonusAmount,
    this.remark,
    this.status,
    this.created,
  });

  String get amountText => _formatAmount(amount);

  String get totalAmountText => _formatAmount(totalAmount);

  String get bonusAmountText => _formatAmount(bonusAmount);

  String get remarkText {
    final value = remark?.trim();
    return value == null || value.isEmpty ? '--' : value;
  }

  String get statusText {
    final value = status?.trim();
    return value == null || value.isEmpty ? '--' : value;
  }

  factory MembershipCardManageRechargeRecordModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MembershipCardManageRechargeRecordModel(
      amount: json['amount'] as num?,
      totalAmount: json['totalAmount'] as num?,
      bonusAmount: json['bonusAmount'] as num?,
      remark: json['remark']?.toString(),
      status: json['status']?.toString(),
      created: _parseDateTime(json['created']),
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

  static String _formatAmount(num? value) {
    if (value == null) {
      return '0';
    }
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value.toString();
  }
}
