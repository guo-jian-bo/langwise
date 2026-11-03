import 'package:get/get.dart';

import '../controllers/elements_sentence_analysis_controller.dart';

class ElementsSentenceAnalysisBinding extends Bindings {
  final String tagText;
  ElementsSentenceAnalysisBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ElementsSentenceAnalysisController>(
      () => ElementsSentenceAnalysisController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
