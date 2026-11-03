import 'package:get/get.dart';

import '../controllers/manage_sentence_grammar_add_group_controller.dart';

class ManageSentenceGrammarAddGroupBinding extends Bindings {
  final String tag;
  ManageSentenceGrammarAddGroupBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageSentenceGrammarAddGroupController>(
      () => ManageSentenceGrammarAddGroupController(tag: tag),
      tag: tag,
    );
  }
}
