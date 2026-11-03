import 'package:get/get.dart';

import '../controllers/manage_sentence_pyramid_add_group_controller.dart';

class ManageSentencePyramidAddGroupBinding extends Bindings {
  final String tag;
  ManageSentencePyramidAddGroupBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageSentencePyramidAddGroupController>(
      () => ManageSentencePyramidAddGroupController(tag: tag),
      tag: tag,
    );
  }
}
