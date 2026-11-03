import 'package:get/get.dart';

import '../controllers/manage_word_morphology_controller.dart';

class ManageWordMorphologyBinding extends Bindings {
  final String tag;
  ManageWordMorphologyBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageWordMorphologyController>(
      () => ManageWordMorphologyController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
