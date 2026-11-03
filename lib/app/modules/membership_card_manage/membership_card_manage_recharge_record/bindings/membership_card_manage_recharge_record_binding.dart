import 'package:get/get.dart';

import '../controllers/membership_card_manage_recharge_record_controller.dart';

class MembershipCardManageRechargeRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MembershipCardManageRechargeRecordController>(
      () => MembershipCardManageRechargeRecordController(),
      fenix: true,
    );
  }
}
