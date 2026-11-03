import 'package:get/get.dart';

import 'controller.dart';

class SubListenDetailsBinding implements Bindings {
  final String tagText;
  SubListenDetailsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<SubListenDetailsController>(
      () => SubListenDetailsController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
