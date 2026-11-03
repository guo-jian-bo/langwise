import 'package:get/get.dart';

import '../controllers/manage_sentence_paradigm_add_group_controller.dart';

class ManageSentenceParadigmAddGroupBinding extends Bindings {
  final String tag;
  ManageSentenceParadigmAddGroupBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageSentenceParadigmAddGroupController>(
      () => ManageSentenceParadigmAddGroupController(tag: tag),
      tag: tag,
    );
  }
}
