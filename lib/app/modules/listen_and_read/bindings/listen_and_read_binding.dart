import 'package:get/get.dart';

import '../controllers/listen_and_read_controller.dart';
import '../controllers/listen_and_read_reading_controller.dart';
import '../controllers/listen_and_read_shadowing_controller.dart';

class ListenAndReadBinding extends Bindings {
  final String tagText;
  ListenAndReadBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ListenAndReadController>(
      () => ListenAndReadController(tagText: tagText),
      tag: tagText,
    );
    Get.lazyPut<ListenAndReadReadingController>(
      () => ListenAndReadReadingController(tagText: tagText),
      tag: tagText,
    );
    Get.lazyPut<ListenAndReadShadowingController>(
      () => ListenAndReadShadowingController(tagText: tagText),
      tag: tagText,
    );
  }
}
