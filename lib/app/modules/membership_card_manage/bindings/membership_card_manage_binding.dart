import 'package:get/get.dart';
import '../../../../common/public_controller/manage_admin_auth_controller.dart';
import '../controllers/membership_card_manage_controller.dart';
import '../membership_card_manage_code_manage/controllers/membership_card_manage_code_manage_controller.dart';
import '../membership_card_manage_generate_code/controllers/membership_card_manage_generate_code_controller.dart';
import '../membership_card_manage_rebate_statistics/controllers/membership_card_manage_rebate_statistics_controller.dart';
import '../membership_card_manage_recharge_center/controllers/membership_card_manage_recharge_center_controller.dart';

class MembershipCardManageBinding extends Bindings {
  final String tagText;
  MembershipCardManageBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<MembershipCardManageController>(
      () => MembershipCardManageController(tagText: tagText),
      tag: tagText,
    );
    Get.lazyPut<MembershipCardManageGenerateCodeController>(
      () => MembershipCardManageGenerateCodeController(tagText: tagText),
      tag: tagText,
    );
    Get.lazyPut<MembershipCardManageCodeManageController>(
      () => MembershipCardManageCodeManageController(tagText: tagText),
      tag: tagText,
    );
    Get.lazyPut<MembershipCardManageRechargeCenterController>(
      () => MembershipCardManageRechargeCenterController(tagText: tagText),
      tag: tagText,
    );
    Get.lazyPut<MembershipCardManageRebateStatisticsController>(
      () => MembershipCardManageRebateStatisticsController(tagText: tagText),
      tag: tagText,
    );

    Get.lazyPut<ManageAuthController>(
      () => ManageAuthController(),
    );
  }
}
