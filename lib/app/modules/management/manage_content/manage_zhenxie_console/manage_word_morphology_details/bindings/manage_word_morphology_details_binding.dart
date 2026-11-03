import 'package:get/get.dart';

import '../controllers/manage_word_morphology_details_controller.dart';

class ManageWordMorphologyDetailsBinding extends Bindings {
  final String tag;
  ManageWordMorphologyDetailsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageWordMorphologyDetailsController>(
      () => ManageWordMorphologyDetailsController(tag: tag),
      tag: tag,
    );
  }
}
