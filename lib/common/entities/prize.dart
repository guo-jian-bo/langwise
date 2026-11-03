enum PrizeType {
  CREDIT("CREDIT", "乃币"),
  POINTS("POINTS", "学点"),
  COUPON("COUPON", "优惠卷"),
  PLUSVIP("PLUS_VIP", "plusVIP"),
  PROVIP("PRO_VIP", "proVIP"),
  MAXVIP("MAX_VIP", "maxVIP");

  final String value;
  final String name;

  const PrizeType(this.value, this.name);

  // 辅助方法：通过字符串查找枚举（反序列化用）
  static PrizeType fromString(String? val) {
    return PrizeType.values.firstWhere(
      (e) => e.value == val,
      orElse: () => PrizeType.CREDIT
    );
  }

  static bool isReturnVal(String? val) {
    return val == 'CREDIT' || val == 'POINTS' || val == 'COUPON';
  }
}

enum DurationType {
  DAY("DAY", "天"),
  WEEK("WEEK", "周"),
  MONTH("MONTH", "月"),
  QUARTER("QUARTER", "季度"),
  YEAR("YOUR", "年");

  final String value;
  final String name;
  const DurationType(this.value, this.name);

    static DurationType fromString(String? val) {
    return DurationType.values.firstWhere(
      (e) => e.value == val,
      orElse: () => DurationType.DAY
    );
  }
}

class PrizeData {
  final List<PrizeItem> list;

  PrizeData({
    required this.list,
  });

  factory PrizeData.fromJson(Map<String, dynamic> json) {
    return PrizeData(
      list: (json['list'] as List<dynamic>).map((e) => PrizeItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'list': list.map((e) => e.toJson()).toList(),
    };
  }
}

class PrizeItem {
  final int uid;
  final String name;
  final PrizeType type; // 如果类型固定，建议后续转为 enum
  final int? value; // 可能为null，必须声明为可空类型 int?
  final int? duration; // 可能为null
  final String? durationType; // 可能为null
  final DateTime created;
  final DateTime updated;
  final String access;

  PrizeItem({
    required this.uid,
    required this.name,
    required this.type,
    this.value,
    this.duration,
    this.durationType,
    required this.created,
    required this.updated,
    required this.access,
  });

  factory PrizeItem.fromJson(Map<String, dynamic> json) {
    return PrizeItem(
      uid: json['uid'] as int,
      name: json['name'] as String,
      type: PrizeType.fromString(json['type'] as String?),
      value: json['value'] as int?,
      duration: json['duration'] as int?,
      durationType: json['durationType'] as String?,
      // 解析 ISO8601 时间字符串
      created: DateTime.parse(json['created'] as String),
      updated: DateTime.parse(json['updated'] as String),
      access: json['access'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'type': type.value,
      'value': value,
      'duration': duration,
      'durationType': durationType,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
      'access': access,
    };
  }
}
