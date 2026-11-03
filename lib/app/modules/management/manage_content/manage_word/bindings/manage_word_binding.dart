import 'package:get/get.dart';

import '../controllers/manage_word_controller.dart';

class ManageWordBinding extends Bindings {
  final String tag;
  ManageWordBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageWordController>(
      () => ManageWordController(tag: tag),
      tag: tag,
    );
  }
}
