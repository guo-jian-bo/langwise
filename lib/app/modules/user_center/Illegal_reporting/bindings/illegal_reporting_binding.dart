import 'package:get/get.dart';

import '../controllers/illegal_reporting_controller.dart';

class IllegalReportingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IllegalReportingController>(
      () => IllegalReportingController(),
    );
  }
}
