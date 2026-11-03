import 'package:get/get.dart';

import '../controllers/open_source_license_controller.dart';

class OpenSourceLicenseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OpenSourceLicenseController>(
      () => OpenSourceLicenseController(),
    );
  }
}
