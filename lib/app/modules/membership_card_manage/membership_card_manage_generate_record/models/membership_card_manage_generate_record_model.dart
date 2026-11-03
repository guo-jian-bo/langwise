class MembershipCardManageGenerateRecordListEntity {
  final int count;
  final List<MembershipCardManageGenerateRecordModel> list;

  MembershipCardManageGenerateRecordListEntity({
    required this.count,
    required this.list,
  });

  factory MembershipCardManageGenerateRecordListEntity.fromDynamic(dynamic json) {
    if (json is List) {
      final list = json
          .whereType<Map<String, dynamic>>()
          .map(MembershipCardManageGenerateRecordModel.fromJson)
          .toList();
      return MembershipCardManageGenerateRecordListEntity(
        count: list.length,
        list: list,
      );
    }

    if (json is! Map<String, dynamic>) {
      return MembershipCardManageGenerateRecordListEntity(
        count: 0,
        list: const [],
      );
    }

    final dynamic rawList = json['list'] ??
        json['datas'] ??
        json['records'] ??
        json['rows'] ??
        json['items'] ??
        json['data'];

    final list = (rawList is List ? rawList : const [])
        .whereType<Map<String, dynamic>>()
        .map(MembershipCardManageGenerateRecordModel.fromJson)
        .toList();

    return MembershipCardManageGenerateRecordListEntity(
      count: (json['count'] as num?)?.toInt() ?? list.length,
      list: list,
    );
  }
}

class MembershipCardManageGenerateRecordModel {
  final String? cardName;
  final double? cardAmount;
  final double? balance;
  final String? activateUserName;
  final String? activateUserPhone;
  final DateTime? created;
  final DateTime? activated;
  final String? status;

  const MembershipCardManageGenerateRecordModel({
    this.cardName,
    this.cardAmount,
    this.balance,
    this.activateUserName,
    this.activateUserPhone,
    this.created,
    this.activated,
    this.status,
  });

  String get amountStr => cardAmount?.toStringAsFixed(2) ?? '--';
  String get balanceStr => balance?.toStringAsFixed(2) ?? '--';

  String get cardDetail => cardName?.trim().isNotEmpty == true ? cardName!.trim() : '--';

  String get statusText {
    if ((status ?? '').isNotEmpty) {
      return status!;
    }
    return activated != null ? '已激活' : '未激活';
  }

  factory MembershipCardManageGenerateRecordModel.fromJson(Map<String, dynamic> json) {
    return MembershipCardManageGenerateRecordModel(
      cardName: json['cardName']?.toString(),
      cardAmount: (json['cardAmount'] as num?)?.toDouble(),
      balance: (json['balance'] as num?)?.toDouble(),
      activateUserName: json['activateUserName']?.toString(),
      activateUserPhone: json['activateUserPhone']?.toString(),
      created: _parseDateTime(
        json['created'] ?? json['createTime'] ?? json['createdAt'],
      ),
      activated: _parseDateTime(
        json['activated'] ?? json['activateTime'] ?? json['activatedAt'],
      ),
      status: json['status']?.toString(),
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
}
