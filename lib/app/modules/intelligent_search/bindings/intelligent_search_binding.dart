import 'package:get/get.dart';

import '../controllers/intelligent_search_controller.dart';

class IntelligentSearchBinding extends Bindings {
  final String tagText;
  IntelligentSearchBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<IntelligentSearchController>(
      () => IntelligentSearchController(tagText: tagText),
      tag: tagText,
    );
  }
}
