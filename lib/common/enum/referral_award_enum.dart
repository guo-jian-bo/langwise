
// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

enum ReferralAwardStatusEnum {
  /// 起点
  START("START", "起点"),
  INACTIVE("INACTIVE", "未激活"),
  ACTIVE("ACTIVE", "待领取"),
  CLAIMABLE("CLAIMABLE", "待领取"),
  PENDING("PENDING", "等待发放"),
  CLAIMED("CLAIMED", "已领取"),
  ISSUED("ISSUED", "已发放");

  final String value;
  final String name;
  const ReferralAwardStatusEnum(this.value, this.name);

  factory ReferralAwardStatusEnum.fromValue(String? value) {
    return values.firstWhereOrNull((e) => e.value == value)?? INACTIVE;
  }

}

enum ReferralAwardListTypeEnum {
  REFERRAL("REFERRAL", "邀请注册奖励"),
  VIP("VIP", "VIP购买奖励");

  final String value;
  final String name;
  const ReferralAwardListTypeEnum(this.value, this.name);
}


/// 奖励类型
enum ReferralAwardTypeEnum {
  NONE("NONE", ""),
  COUPON("COUPON", "优惠券"),
  CREDIT("CREDIT", "乃币"),
  POINTS("POINTS", "学点"),
  PLUS_VIP("PLUS_VIP", "Plus"),
  PRO_VIP("PRO_VIP", "Pro"),
  MAX_VIP("MAX_VIP", "Max"),
  GIFT("GIFT", "礼包");

  final String value;
  final String name;
  const ReferralAwardTypeEnum(this.value, this.name);

  factory ReferralAwardTypeEnum.fromValue(String? value) {
    return values.firstWhereOrNull((e) => e.value == value)?? NONE;
  }
}

enum ReferralAwardClaimEnum {
  UNCLAIMED(0, "未领取"),
  CLAIMED(1, "已领取"),
  CANCELLED(2, "已取消");

  final int value;
  final String name;
  const ReferralAwardClaimEnum(this.value, this.name);
}