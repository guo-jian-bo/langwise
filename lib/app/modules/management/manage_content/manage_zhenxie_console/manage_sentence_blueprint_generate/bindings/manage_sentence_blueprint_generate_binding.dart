import 'package:get/get.dart';

import '../controllers/manage_sentence_blueprint_generate_controller.dart';

class ManageSentenceBlueprintGenerateBinding extends Bindings {
  final String tag;
  ManageSentenceBlueprintGenerateBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageSentenceBlueprintGenerateController>(
      () => ManageSentenceBlueprintGenerateController(tag: tag),
      tag: tag,
    );
  }
}
