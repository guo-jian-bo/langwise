import 'package:get/get.dart';
import '../controllers/membership_card_manage_controller.dart';

class MembershipCardManageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MembershipCardManageController());
  }
}
