import 'package:get/get.dart';

import '../controllers/elements_collect_card_controller.dart';

class ElementsCollectCardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ElementsCollectCardController>(
      () => ElementsCollectCardController(),
    );
  }
}
