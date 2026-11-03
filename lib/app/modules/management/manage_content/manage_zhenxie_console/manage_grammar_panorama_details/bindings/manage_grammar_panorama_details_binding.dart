import 'package:get/get.dart';

import '../controllers/manage_grammar_panorama_details_controller.dart';

class ManageGrammarPanoramaDetailsBinding extends Bindings {
  final String tag;
  ManageGrammarPanoramaDetailsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageGrammarPanoramaDetailsController>(
      () => ManageGrammarPanoramaDetailsController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
