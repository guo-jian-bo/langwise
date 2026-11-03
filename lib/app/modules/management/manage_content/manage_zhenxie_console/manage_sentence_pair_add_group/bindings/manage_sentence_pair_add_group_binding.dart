import 'package:get/get.dart';

import '../controllers/manage_sentence_pair_add_group_controller.dart';

class ManageSentencePairAddGroupBinding extends Bindings {
  final String tag;
  ManageSentencePairAddGroupBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageSentencePairAddGroupController>(
      () => ManageSentencePairAddGroupController(tag: tag),
      tag: tag,
    );
  }
}
