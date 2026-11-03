import 'package:get/get.dart';

import '../controllers/manage_grammar_panorama_controller.dart';

class ManageGrammarPanoramaBinding extends Bindings {
  final String tag;
  ManageGrammarPanoramaBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageGrammarPanoramaController>(
      () => ManageGrammarPanoramaController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
