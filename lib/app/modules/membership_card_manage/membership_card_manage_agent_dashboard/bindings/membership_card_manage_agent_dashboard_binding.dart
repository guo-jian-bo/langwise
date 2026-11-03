import 'package:get/get.dart';

import '../controllers/membership_card_manage_agent_dashboard_controller.dart';

class MembershipCardManageAgentDashboardBinding extends Bindings {
  final String tagText;
  MembershipCardManageAgentDashboardBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<MembershipCardManageAgentDashboardController>(
      () => MembershipCardManageAgentDashboardController(tagText: tagText),
      tag: tagText,
    );
  }
}
