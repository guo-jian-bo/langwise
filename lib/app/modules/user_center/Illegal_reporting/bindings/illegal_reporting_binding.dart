import 'package:get/get.dart';

import '../controllers/illegal_reporting_controller.dart';

class IllegalReportingBinding extends Bindings {
  final String tagText;
  IllegalReportingBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<IllegalReportingController>(
      () => IllegalReportingController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
