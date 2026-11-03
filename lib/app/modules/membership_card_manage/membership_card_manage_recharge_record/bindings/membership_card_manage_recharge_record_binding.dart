import 'package:get/get.dart';

import '../controllers/membership_card_manage_recharge_record_controller.dart';

class MembershipCardManageRechargeRecordBinding extends Bindings {
  final String tagText;
  MembershipCardManageRechargeRecordBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<MembershipCardManageRechargeRecordController>(
      () => MembershipCardManageRechargeRecordController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
