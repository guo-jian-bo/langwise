import 'package:get/get.dart';

import '../controllers/open_member_settlement_controller.dart';

class OpenMemberSettlementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OpenMemberSettlementController>(
      () => OpenMemberSettlementController(),
    );
  }
}
