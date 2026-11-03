import 'package:get/get.dart';

import '../controllers/manage_sentence_controller.dart';

class ManageSentenceBinding extends Bindings {
  final String tag;
  ManageSentenceBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageSentenceController>(
      () => ManageSentenceController(tag: tag),
      tag: tag,
    );
  }
}
