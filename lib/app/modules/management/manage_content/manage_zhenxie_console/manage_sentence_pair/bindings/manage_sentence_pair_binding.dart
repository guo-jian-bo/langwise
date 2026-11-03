import 'package:get/get.dart';

import '../controllers/manage_sentence_pair_controller.dart';

class ManageSentencePairBinding extends Bindings {
  final String tag;
  ManageSentencePairBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageSentencePairController>(
      () => ManageSentencePairController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
