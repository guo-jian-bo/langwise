import 'package:get/get.dart';

import '../controllers/zhendu_show_detail_controller.dart';

class ZhenduShowDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ZhenduShowDetailController>(
      () => ZhenduShowDetailController(),
    );
  }
}
