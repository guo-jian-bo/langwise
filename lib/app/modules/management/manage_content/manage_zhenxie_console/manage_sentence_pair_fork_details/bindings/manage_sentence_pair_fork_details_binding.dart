import 'package:get/get.dart';

import '../controllers/manage_sentence_pair_fork_details_controller.dart';

class ManageSentencePairForkDetailsBinding extends Bindings {
  final String tag;
  ManageSentencePairForkDetailsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageSentencePairForkDetailsController>(
      () => ManageSentencePairForkDetailsController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
