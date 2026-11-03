import 'package:get/get.dart';

import '../controllers/manage_knowledge_related_details_controller.dart';

class ManageKnowledgeRelatedDetailsBinding extends Bindings {
  final String tag;
  ManageKnowledgeRelatedDetailsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageKnowledgeRelatedDetailsController>(
      () => ManageKnowledgeRelatedDetailsController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
