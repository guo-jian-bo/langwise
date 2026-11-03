class MembershipCardManageCodeManageModelEntity {
  int? count;
  List<MembershipCardManageCodeManageModel>? datas;

  MembershipCardManageCodeManageModelEntity({this.count, this.datas});

  factory MembershipCardManageCodeManageModelEntity.fromJson(Map<String, dynamic> json) {
    return MembershipCardManageCodeManageModelEntity(
      count: json['count']?.toInt(),
      datas: (json['datas'] as List<dynamic>?)?.map((e) => MembershipCardManageCodeManageModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'datas': datas?.map((e) => e.toJson()).toList(),
    };
  }
}

class MembershipCardManageCodeManageModel {
  final int? uid;
  final int? userId;
  final int? couponId;
  final int? agentId;
  final double? price;
  final double? originalPrice;
  final String? description;
  final String? vipType;
  final int? usageMonths;
  final int? priceMonths;
  final String? durationType;
  final int? quantity;
  final bool? isActivate;
  final DateTime? activated;
  final bool? isExpired;
  final bool? isFailure;
  final bool? isRefund;
  final String? orderNo;
  final String? appId;
  final DateTime? created;
  final DateTime? updated;
  final String? code;
  final String? activateUserName;
  final String? couponName;
  final int? refundExpirationDate;
  final bool? isSendCoupon;
  final String? activateUserPhone;
  String? remarks;
  String? revokeOrderPrompt;
  List<String>? revokeOrderPromptList;
  bool? isFailureRefund;

  get priceStr => price?.toStringAsFixed(2) ?? '0.00';
  get originalPriceStr => originalPrice?.toStringAsFixed(2) ?? '0.00';

  get refundStatus {
    if (isSendCoupon == true) {
      return false;
    } else {
      if (isActivate == true && isRefund != true) {
        if (refundExpirationDate != null && refundExpirationDate! > 0) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    }
  }

  MembershipCardManageCodeManageModel({
    this.uid,
    this.userId,
    this.couponId,
    this.agentId,
    this.price,
    this.originalPrice,
    this.description,
    this.vipType,
    this.usageMonths,
    this.priceMonths,
    this.durationType,
    this.quantity,
    this.isActivate,
    this.activated,
    this.isExpired,
    this.isFailure,
    this.isRefund,
    this.orderNo,
    this.appId,
    this.created,
    this.updated,
    this.code,
    this.activateUserName,
    this.couponName,
    this.refundExpirationDate,
    this.isSendCoupon,
    this.activateUserPhone,
    this.remarks,
    this.revokeOrderPrompt,
    this.revokeOrderPromptList,
    this.isFailureRefund,
  });

  factory MembershipCardManageCodeManageModel.fromJson(Map<String, dynamic> json) {
    return MembershipCardManageCodeManageModel(
      uid: json['uid']?.toInt(),
      userId: json['userId']?.toInt(),
      couponId: json['couponId']?.toInt(),
      agentId: json['agentId']?.toInt(),
      price: json['price']?.toDouble(),
      originalPrice: json['originalPrice']?.toDouble(),
      description: json['description'] as String?,
      vipType: json['vipType'] as String?,
      usageMonths: json['usageMonths']?.toInt(),
      priceMonths: json['priceMonths']?.toInt(),
      durationType: json['durationType'] as String?,
      quantity: json['quantity']?.toInt(),
      isActivate: json['isActivate'] as bool?,
      isExpired: json['isExpired'] as bool?,
      isFailure: json['isFailure'] as bool?,
      activated: json['activated'] != null ? DateTime.parse(json['activated']) : null,
      isRefund: json['isRefund'] as bool?,
      orderNo: json['orderNo'] as String?,
      appId: json['appId'] as String?,
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      updated: json['updated'] != null ? DateTime.parse(json['updated']) : null,
      code: json['code'] as String?,
      activateUserName: json['activateUserName'] as String?,
      couponName: json['couponName'] as String?,
      refundExpirationDate: json['refundExpirationDate']?.toInt(),
      isSendCoupon: json['isSendCoupon'] as bool?,
      activateUserPhone: json['activateUserPhone'] as String?,
      remarks: json['remarks'] as String?,
      revokeOrderPrompt: json['revokeOrderPrompt'] as String?,
      revokeOrderPromptList: (json['revokeOrderPromptList'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      isFailureRefund: json['isFailureRefund'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'userId': userId,
      'couponId': couponId,
      'agentId': agentId,
      'price': price,
      'originalPrice': originalPrice,
      'description': description,
      'vipType': vipType,
      'usageMonths': usageMonths,
      'priceMonths': priceMonths,
      'durationType': durationType,
      'quantity': quantity,
      'isActivate': isActivate,
      'activated': activated?.toIso8601String(),
      'isExpired': isExpired,
      'isFailure': isFailure,
      'isRefund': isRefund,
      'orderNo': orderNo,
      'appId': appId,
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
      'code': code,
      'activateUserName': activateUserName,
      'couponName': couponName,
      'refundExpirationDate': refundExpirationDate,
      'isSendCoupon': isSendCoupon,
      'activateUserPhone': activateUserPhone,
      'remarks': remarks,
      'revokeOrderPrompt': revokeOrderPrompt,
      'revokeOrderPromptList': revokeOrderPromptList,
      'isFailureRefund': isFailureRefund,
    };
  }
}
