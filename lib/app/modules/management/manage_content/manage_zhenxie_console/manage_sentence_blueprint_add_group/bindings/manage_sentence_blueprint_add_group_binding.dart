import 'package:get/get.dart';

import '../controllers/manage_sentence_blueprint_add_group_controller.dart';

class ManageSentenceBlueprintAddGroupBinding extends Bindings {
  final String tag;
  ManageSentenceBlueprintAddGroupBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageSentenceBlueprintAddGroupController>(
      () => ManageSentenceBlueprintAddGroupController(tag: tag),
      tag: tag,
    );
  }
}
