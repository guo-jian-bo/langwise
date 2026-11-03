import 'package:get/get.dart';

import '../controllers/membership_card_manage_rebate_record_controller.dart';

class MembershipCardManageRebateRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MembershipCardManageRebateRecordController>(
      () => MembershipCardManageRebateRecordController(),
      fenix: true,
    );
  }
}
