import 'package:get/get.dart';

import '../controllers/invitation_list_controller.dart';

class InvitationListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvitationListController>(
      () => InvitationListController(),
    );
  }
}
