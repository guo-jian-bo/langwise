import 'package:get/get.dart';

import '../controllers/manage_phrase_controller.dart';

class ManagePhraseBinding extends Bindings {
  final String tag;
  ManagePhraseBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManagePhraseController>(
      () => ManagePhraseController(tag: tag),
      tag: tag,
    );
  }
}
