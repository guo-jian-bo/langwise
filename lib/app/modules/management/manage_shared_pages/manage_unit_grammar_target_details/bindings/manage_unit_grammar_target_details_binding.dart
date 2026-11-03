import 'package:get/get.dart';

import '../controllers/manage_unit_grammar_target_details_controller.dart';

class ManageUnitGrammarTargetDetailsBinding extends Bindings {
  final String tag;
  ManageUnitGrammarTargetDetailsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageUnitGrammarTargetDetailsController>(
      () => ManageUnitGrammarTargetDetailsController(tag: tag),
      tag: tag,
    );
  }
}
