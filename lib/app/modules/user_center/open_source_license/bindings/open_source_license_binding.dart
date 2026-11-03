import 'package:get/get.dart';

import '../controllers/open_source_license_controller.dart';

class OpenSourceLicenseBinding extends Bindings {
  final String tagText;
  OpenSourceLicenseBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<OpenSourceLicenseController>(
      () => OpenSourceLicenseController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
