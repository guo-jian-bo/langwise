import 'package:get/get.dart';

import '../controllers/membership_card_manage_generate_record_controller.dart';

class MembershipCardManageGenerateRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MembershipCardManageGenerateRecordController>(
      () => MembershipCardManageGenerateRecordController(),
      fenix: true,
    );
  }
}
