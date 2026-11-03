import 'package:get/get.dart';

import '../controllers/listen_and_read_controller.dart';
import '../controllers/listen_and_read_practice_controller.dart';
import '../controllers/listen_and_read_reading_controller.dart';
import '../controllers/listen_and_read_shadowing_controller.dart';

class ListenAndReadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListenAndReadController>(
      () => ListenAndReadController(),
    );
    Get.lazyPut<ListenAndReadReadingController>(
      () => ListenAndReadReadingController(),
    );
    Get.lazyPut<ListenAndReadShadowingController>(
      () => ListenAndReadShadowingController(),
    );
    Get.lazyPut<ListenAndReadPracticeController>(
      () => ListenAndReadPracticeController(),
    );
  }
}
