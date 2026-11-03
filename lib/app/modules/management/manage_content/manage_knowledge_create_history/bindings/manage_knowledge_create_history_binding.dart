import 'package:get/get.dart';

import '../controllers/manage_knowledge_create_history_controller.dart';

class ManageKnowledgeCreateHistoryBinding extends Bindings {
  final String tag;
  ManageKnowledgeCreateHistoryBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageKnowledgeCreateHistoryController>(
      () => ManageKnowledgeCreateHistoryController(tag: tag),
      tag: tag,
    );
  }
}
