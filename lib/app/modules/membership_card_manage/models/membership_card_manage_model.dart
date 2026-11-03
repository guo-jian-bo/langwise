class MembershipCardManageModel {
  final int? uid;
  final double? price;
  final double? topUpPrice;
  final int? totalGeneratedCards;
  final int? totalActivatedCards;
  final int? sendCouponNum;
  final String? agentName;
  final String? agentNo;
  final String? password;

  get priceStr => price?.toStringAsFixed(2) ?? '0.00';
  get topUpPriceStr => topUpPrice?.toStringAsFixed(2) ?? '0.00';

  MembershipCardManageModel({
    this.uid,
    this.price,
    this.topUpPrice,
    this.totalGeneratedCards,
    this.totalActivatedCards,
    this.sendCouponNum,
    this.agentName,
    this.agentNo,
    this.password,
  });

  factory MembershipCardManageModel.fromJson(Map<String, dynamic> json) {
    return MembershipCardManageModel(
      uid: json['uid']?.toInt(),
      totalGeneratedCards: json['totalGeneratedCards']?.toInt(),
      totalActivatedCards: json['totalActivatedCards']?.toInt(),
      price: json['price']?.toDouble(),
      topUpPrice: json['topUpPrice']?.toDouble(),
      sendCouponNum: json['sendCouponNum']?.toInt(),
      agentName: json['agentName'],
      agentNo: json['agentNo'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['price'] = price;
    data['topUpPrice'] = topUpPrice;
    data['totalGeneratedCards'] = totalGeneratedCards;
    data['totalActivatedCards'] = totalActivatedCards;
    data['sendCouponNum'] = sendCouponNum;
    data['agentName'] = agentName;
    data['agentNo'] = agentNo;
    data['password'] = password;
    return data;
  }
}
