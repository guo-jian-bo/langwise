import 'package:get/get.dart';

import '../controllers/manage_core_knowledge_controller.dart';

class ManageCoreKnowledgeBinding extends Bindings {
  final String tag;
  ManageCoreKnowledgeBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageCoreKnowledgeController>(
      () => ManageCoreKnowledgeController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
