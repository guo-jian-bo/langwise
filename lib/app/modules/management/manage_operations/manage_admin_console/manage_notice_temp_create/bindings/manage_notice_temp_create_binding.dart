import 'package:get/get.dart';

import '../controllers/manage_notice_temp_create_controller.dart';

class ManageNoticeTempCreateBinding extends Bindings {
  final String tag;
  ManageNoticeTempCreateBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageNoticeTempCreateController>(
      () => ManageNoticeTempCreateController(tag: tag),
      tag: tag,
    );
  }
}
