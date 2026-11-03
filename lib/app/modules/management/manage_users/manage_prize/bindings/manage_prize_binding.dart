import 'package:get/get.dart';

import '../controllers/manage_prize_controller.dart';

class ManagePrizeBinding extends Bindings {
  final String tag;
  ManagePrizeBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManagePrizeController>(
      () => ManagePrizeController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
