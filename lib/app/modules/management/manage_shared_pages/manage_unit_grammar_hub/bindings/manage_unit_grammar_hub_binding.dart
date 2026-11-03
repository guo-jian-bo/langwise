import 'package:get/get.dart';

import '../controllers/manage_unit_grammar_hub_controller.dart';

class ManageUnitGrammarHubBinding extends Bindings {
  final String tag;
  ManageUnitGrammarHubBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageUnitGrammarHubController>(
      () => ManageUnitGrammarHubController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
