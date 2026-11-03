import 'package:get/get.dart';

import '../controllers/about_us_controller.dart';

class AboutUsBinding extends Bindings {
  final String tagText;
  AboutUsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<AboutUsController>(
      () => AboutUsController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
