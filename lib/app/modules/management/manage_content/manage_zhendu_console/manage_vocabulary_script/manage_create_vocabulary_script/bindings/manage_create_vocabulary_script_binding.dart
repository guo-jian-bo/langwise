import 'package:get/get.dart';

import '../controllers/manage_create_vocabulary_script_controller.dart';

class ManageCreateVocabularyScriptBinding extends Bindings {
  final String tag;
  ManageCreateVocabularyScriptBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageCreateVocabularyScriptController>(
      () => ManageCreateVocabularyScriptController(tag: tag),
      tag: tag,
    );
  }
}
