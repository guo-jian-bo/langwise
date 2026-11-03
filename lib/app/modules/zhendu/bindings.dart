import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import 'home/controllers/zhendu_home_controller.dart';

class ZhenduBinding extends Bindings {
  final String tagText;
  ZhenduBinding({this.tagText = Routes.ZHENDU_HOME});

  @override
  void dependencies() {
    Get.lazyPut<ZhenduHomeController>(
      () => ZhenduHomeController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
