import 'package:get/get.dart';

import '../controllers/membership_card_manage_agent_dashboard_controller.dart';

class MembershipCardManageAgentDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MembershipCardManageAgentDashboardController>(
      () => MembershipCardManageAgentDashboardController(),
      fenix: true,
    );
  }
}
