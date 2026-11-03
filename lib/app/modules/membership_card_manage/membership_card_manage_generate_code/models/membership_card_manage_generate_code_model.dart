class MembershipCardManageGenerateCodeVIPListEntity {
  List<MembershipCardManageGenerateCodeVIPListModel>? list;

  MembershipCardManageGenerateCodeVIPListEntity({this.list});

  factory MembershipCardManageGenerateCodeVIPListEntity.fromJson(Map<String, dynamic> json) {
    return MembershipCardManageGenerateCodeVIPListEntity(
      list: (json['list'] as List<dynamic>?)?.map((e) => MembershipCardManageGenerateCodeVIPListModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'list': list?.map((e) => e.toJson()).toList(),
    };
  }
}

class MembershipCardManageGenerateCodeVIPListModel {
  final String? vipType;
  final int? servicePackageId;
  final int? version;
  final double? price;
  final bool? isSeatService;
  get priceStr => price?.toStringAsFixed(2) ?? '0.00';

  MembershipCardManageGenerateCodeVIPListModel({
    this.vipType,
    this.servicePackageId,
    this.version,
    this.price,
    this.isSeatService,
  });

  // 从JSON解析
  factory MembershipCardManageGenerateCodeVIPListModel.fromJson(Map<String, dynamic> json) {
    return MembershipCardManageGenerateCodeVIPListModel(
      vipType: json['vipType'],
      servicePackageId: json['servicePackageId']?.toInt(),
      version: json['version']?.toInt(),
      price: json['price']?.toDouble(),
      isSeatService: json['isSeatService'],
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'vipType': vipType,
      'servicePackageId': servicePackageId,
      'version': version,
      'price': price,
      'isSeatService': isSeatService,
    };
  }
}

class MembershipCardManageGenerateCodeCouponSupplyListEntity {
  List<MembershipCardManageGenerateCodeCouponSupplyListModel>? list;

  MembershipCardManageGenerateCodeCouponSupplyListEntity({this.list});

  factory MembershipCardManageGenerateCodeCouponSupplyListEntity.fromJson(Map<String, dynamic> json) {
    return MembershipCardManageGenerateCodeCouponSupplyListEntity(
      list: (json['list'] as List<dynamic>?)?.map((e) => MembershipCardManageGenerateCodeCouponSupplyListModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'list': list?.map((e) => e.toJson()).toList(),
    };
  }
}

class MembershipCardManageGenerateCodeCouponSupplyListModel {
  final int? couponSupplyId;
  final int? couponSupplyConfigId;
  final String? name;
  final String? description;
  final int? usageMonths;
  final int? priceMonths;
  final String? durationType;

  MembershipCardManageGenerateCodeCouponSupplyListModel({
    this.couponSupplyId,
    this.couponSupplyConfigId,
    this.name,
    this.description,
    this.usageMonths,
    this.priceMonths,
    this.durationType,
  });

  // 从JSON解析
  factory MembershipCardManageGenerateCodeCouponSupplyListModel.fromJson(Map<String, dynamic> json) {
    return MembershipCardManageGenerateCodeCouponSupplyListModel(
      couponSupplyId: json['couponSupplyId']?.toInt(),
      couponSupplyConfigId: json['couponSupplyConfigId']?.toInt(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      usageMonths: json['usageMonths']?.toInt(),
      priceMonths: json['priceMonths']?.toInt(),
      durationType: json['durationType'] as String?,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'couponSupplyId': couponSupplyId,
      'couponSupplyConfigId': couponSupplyConfigId,
      'name': name,
      'description': description,
      'usageMonths': usageMonths,
      'priceMonths': priceMonths,
      'durationType': durationType,
    };
  }
}

class MembershipCardManageGenerateCodeSettlementEntity {
  final int? couponSupplyId;
  final int? couponSupplyConfigId;
  final double? price;
  final double? discountPrice;
  final double? discountProportion;
  get priceStr => price?.toStringAsFixed(2) ?? '0.00';
  get discountPriceStr => discountPrice?.toStringAsFixed(2) ?? '0.00';
  get discountProportionStr => discountProportion?.toStringAsFixed(2) ?? '0.00';

  MembershipCardManageGenerateCodeSettlementEntity({
    this.couponSupplyId,
    this.couponSupplyConfigId,
    this.price,
    this.discountPrice,
    this.discountProportion,
  });

  // 从JSON解析
  factory MembershipCardManageGenerateCodeSettlementEntity.fromJson(Map<String, dynamic> json) {
    return MembershipCardManageGenerateCodeSettlementEntity(
      couponSupplyId: json['couponSupplyId']?.toInt(),
      couponSupplyConfigId: json['couponSupplyConfigId']?.toInt(),
      price: json['price']?.toDouble(),
      discountPrice: json['discountPrice']?.toDouble(),
      discountProportion: json['discountProportion']?.toDouble(),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'couponSupplyId': couponSupplyId,
      'couponSupplyConfigId': couponSupplyConfigId,
      'price': price,
      'discountPrice': discountPrice,
      'discountProportion': discountProportion,
    };
  }
}
