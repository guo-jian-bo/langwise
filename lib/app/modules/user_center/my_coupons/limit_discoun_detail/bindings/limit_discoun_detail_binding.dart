import 'package:get/get.dart';

import '../controllers/limit_discoun_detail_controller.dart';

class LimitDiscounDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LimitDiscounDetailController>(
      () => LimitDiscounDetailController(),
    );
  }
}
