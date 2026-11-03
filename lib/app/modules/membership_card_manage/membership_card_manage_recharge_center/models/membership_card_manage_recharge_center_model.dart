class MembershipCardManageRechargeCenterEntity {
  List<MembershipCardManageRechargeCenterModel>? list;

  MembershipCardManageRechargeCenterEntity({
    this.list,
  });

  /// 从 JSON 构造对象
  factory MembershipCardManageRechargeCenterEntity.fromJson(
      Map<String, dynamic> json) {
    return MembershipCardManageRechargeCenterEntity(
      list: json['list'] != null
          ? (json['list'] as List)
              .map((e) => MembershipCardManageRechargeCenterModel.fromJson(e))
              .toList()
          : null,
    );
  }

  /// 转换对象为 JSON
  Map<String, dynamic> toJson() {
    return {
      'list': list?.map((e) => e.toJson()).toList(),
    };
  }
}

class MembershipCardManageRechargeCenterModel {
  final int? uid;
  final int? minAmount;
  final int? bonusRate;
  final int? version;
  final int? servicePackageId;
  final String? description;
  final int? serviceId;
  final String? appId;
  final DateTime? created;
  final DateTime? updated;
  final bool? isSendCoupon;
  final String? sendCouponDescription;

  MembershipCardManageRechargeCenterModel({
    this.uid,
    this.minAmount,
    this.bonusRate,
    this.version,
    this.servicePackageId,
    this.description,
    this.serviceId,
    this.appId,
    this.created,
    this.updated,
    this.isSendCoupon,
    this.sendCouponDescription,
  });

  /// 从 JSON 构造对象
  factory MembershipCardManageRechargeCenterModel.fromJson(
      Map<String, dynamic> json) {
    return MembershipCardManageRechargeCenterModel(
      uid: json['uid']?.toInt(),
      minAmount: json['minAmount']?.toInt(),
      bonusRate: json['bonusRate']?.toInt(),
      version: json['version']?.toInt(),
      servicePackageId: json['servicePackageId']?.toInt(),
      description: json['description'] as String?,
      serviceId: json['serviceId']?.toInt(),
      appId: json['appId'] as String?,
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      updated: json['updated'] != null ? DateTime.parse(json['updated']) : null,
      isSendCoupon: json['isSendCoupon'] as bool?,
      sendCouponDescription: json['sendCouponDescription'] as String?,
    );
  }

  /// 转换对象为 JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'minAmount': minAmount,
      'bonusRate': bonusRate,
      'version': version,
      'servicePackageId': servicePackageId,
      'description': description,
      'serviceId': serviceId,
      'appId': appId,
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
      'isSendCoupon': isSendCoupon,
      'sendCouponDescription': sendCouponDescription,
    };
  }
}
