import 'package:get/get.dart';

import '../controllers/manage_unit_grammar_add_controller.dart';

class ManageUnitGrammarAddBinding extends Bindings {
  final String tag;
  ManageUnitGrammarAddBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageUnitGrammarAddController>(
      () => ManageUnitGrammarAddController(tag: tag),
      tag: tag,
    );
  }
}
