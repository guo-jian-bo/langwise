import 'package:get/get.dart';

import '../controllers/my_coupons_controller.dart';

class MyCouponsBinding extends Bindings {
  final String tagText;
  MyCouponsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<MyCouponsController>(
      () => MyCouponsController(tagText: tagText),
      tag: tagText,
    );
  }
}
