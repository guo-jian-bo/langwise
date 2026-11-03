import 'package:get/get.dart';

import '../controllers/manage_sentence_pattern_compare_details_controller.dart';

class ManageSentencePatternCompareDetailsBinding extends Bindings {
  final String tag;
  ManageSentencePatternCompareDetailsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageSentencePatternCompareDetailsController>(
      () => ManageSentencePatternCompareDetailsController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
