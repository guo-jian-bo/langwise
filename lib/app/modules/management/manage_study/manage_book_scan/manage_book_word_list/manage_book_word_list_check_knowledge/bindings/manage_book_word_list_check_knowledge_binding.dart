import 'package:get/get.dart';
import '../controllers/manage_book_word_list_check_knowledge_controller.dart';

class ManageBookWordListCheckKnowledgeBinding extends Bindings {
  final String tag;
  ManageBookWordListCheckKnowledgeBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageBookWordListCheckKnowledgeController>(
      () => ManageBookWordListCheckKnowledgeController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}