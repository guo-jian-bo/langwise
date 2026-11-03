import 'package:get/get.dart';

import '../controllers/open_member_settlement_controller.dart';

class OpenMemberSettlementBinding extends Bindings {
  final String tagText;
  OpenMemberSettlementBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<OpenMemberSettlementController>(
      () => OpenMemberSettlementController(tagText: tagText),
      tag: tagText,
    );
  }
}
