import 'package:get/get.dart';

import '../controllers/memory_card_list_controller.dart';

class MemoryCardListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MemoryCardListController>(
      () => MemoryCardListController(),
    );
  }
}
