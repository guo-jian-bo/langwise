import 'package:get/get.dart';

import '../controllers/web_page_controller.dart';

class WebPageBinding extends Bindings {
  final String tagText;
  WebPageBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<WebPageController>(
      () => WebPageController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
