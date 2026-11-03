import 'package:get/get.dart';

import '../controllers/become_inviter_controller.dart';

class BecomeInviterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BecomeInviterController>(
      () => BecomeInviterController(),
    );
  }
}
