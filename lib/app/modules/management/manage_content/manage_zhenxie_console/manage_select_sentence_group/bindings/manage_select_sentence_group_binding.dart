import 'package:get/get.dart';

import '../controllers/manage_select_sentence_group_controller.dart';

class ManageSelectSentenceGroupBinding extends Bindings {
  final String tag;
  ManageSelectSentenceGroupBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageSelectSentenceGroupController>(
      () => ManageSelectSentenceGroupController(tag: tag),
      tag: tag,
    );
  }
}
