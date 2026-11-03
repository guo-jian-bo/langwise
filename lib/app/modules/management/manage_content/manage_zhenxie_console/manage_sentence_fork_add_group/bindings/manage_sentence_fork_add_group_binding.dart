import 'package:get/get.dart';

import '../controllers/manage_sentence_fork_add_group_controller.dart';

class ManageSentenceForkAddGroupBinding extends Bindings {
  final String tag;
  ManageSentenceForkAddGroupBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageSentenceForkAddGroupController>(
      () => ManageSentenceForkAddGroupController(tag: tag),
      tag: tag,
    );
  }
}
