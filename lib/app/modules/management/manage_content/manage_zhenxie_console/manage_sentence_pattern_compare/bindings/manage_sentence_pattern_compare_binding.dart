import 'package:get/get.dart';

import '../controllers/manage_sentence_pattern_compare_controller.dart';

class ManageSentencePatternCompareBinding extends Bindings {
  final String tag;
  ManageSentencePatternCompareBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageSentencePatternCompareController>(
      () => ManageSentencePatternCompareController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
