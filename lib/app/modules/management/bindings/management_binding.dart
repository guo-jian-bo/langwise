import 'package:get/get.dart';

import '../../../../common/public_controller/manage_admin_auth_controller.dart';
import '../controllers/manage_setting_controller.dart';
import '../controllers/management_breadcrumb_controller.dart';
import '../controllers/management_controller.dart';
import '../controllers/management_message_controller.dart';

class ManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageAuthController>(
      () => ManageAuthController(),
    );
    Get.lazyPut<ManagementController>(
      () => ManagementController(),
    );
    Get.lazyPut<ManagementBreadcrumbController>(
      () => ManagementBreadcrumbController(),
    );
    Get.lazyPut<ManageMessageController>(
      () => ManageMessageController(),
    );
    Get.put<ManageSettingController>(
      ManageSettingController(),
      permanent: true,
    );
  }
}
