import 'package:get/get.dart';

import '../controllers/memory_card_list_controller.dart';

class MemoryCardListBinding extends Bindings {
  final String tagText;
  MemoryCardListBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<MemoryCardListController>(
      () => MemoryCardListController(tagText: tagText),
      tag: tagText,
    );
  }
}
