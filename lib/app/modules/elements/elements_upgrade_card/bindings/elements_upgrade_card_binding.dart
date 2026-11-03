import 'package:get/get.dart';

import '../controllers/elements_upgrade_card_controller.dart';

class ElementsUpgradeCardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ElementsUpgradeCardController>(
      () => ElementsUpgradeCardController(),
    );
  }
}
