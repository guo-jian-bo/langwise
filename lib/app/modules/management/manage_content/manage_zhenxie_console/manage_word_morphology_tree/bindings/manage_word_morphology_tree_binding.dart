import 'package:get/get.dart';

import '../controllers/manage_word_morphology_tree_controller.dart';

class ManageWordMorphologyTreeBinding extends Bindings {
  final String tag;
  ManageWordMorphologyTreeBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageWordMorphologyTreeController>(
      () => ManageWordMorphologyTreeController(tag: tag),
      tag: tag,
    );
  }
}
