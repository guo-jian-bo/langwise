import 'package:get/get.dart';

import '../controllers/manage_sentence_pair_details_controller.dart';

class ManageSentencePairDetailsBinding extends Bindings {
  final String tag;
  ManageSentencePairDetailsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageSentencePairDetailsController>(
      () => ManageSentencePairDetailsController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
