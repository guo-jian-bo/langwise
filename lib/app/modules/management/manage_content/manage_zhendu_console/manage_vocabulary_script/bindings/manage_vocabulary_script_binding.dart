import 'package:get/get.dart';

import '../controllers/manage_vocabulary_script_controller.dart';

class ManageVocabularyScriptBinding extends Bindings {
  final String tag;
  ManageVocabularyScriptBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageVocabularyScriptController>(
      () => ManageVocabularyScriptController(tag: tag),
      tag: tag,
    );
  }
}
