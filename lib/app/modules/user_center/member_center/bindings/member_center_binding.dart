import 'package:get/get.dart';

import '../controllers/member_center_controller.dart';

class MemberCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MemberCenterController>(
      () => MemberCenterController(),
    );
  }
}
