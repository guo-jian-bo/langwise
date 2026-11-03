import 'package:get/get.dart';

import '../controllers/membership_card_manage_generate_record_controller.dart';

class MembershipCardManageGenerateRecordBinding extends Bindings {
  final String tagText;
  MembershipCardManageGenerateRecordBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<MembershipCardManageGenerateRecordController>(
      () => MembershipCardManageGenerateRecordController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
