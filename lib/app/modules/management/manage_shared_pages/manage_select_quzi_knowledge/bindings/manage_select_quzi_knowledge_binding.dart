import 'package:get/get.dart';

import '../controllers/manage_select_quzi_knowledge_controller.dart';

class ManageSelectQuziKnowledgeBinding extends Bindings {
  final String tag;
  ManageSelectQuziKnowledgeBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageSelectQuziKnowledgeController>(
      () => ManageSelectQuziKnowledgeController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
