import 'package:get/get.dart';

import '../controllers/membership_card_manage_rebate_record_controller.dart';

class MembershipCardManageRebateRecordBinding extends Bindings {
  final String tagText;
  MembershipCardManageRebateRecordBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<MembershipCardManageRebateRecordController>(
      () => MembershipCardManageRebateRecordController(tagText: tagText),
      tag: tagText,
    );
  }
}
