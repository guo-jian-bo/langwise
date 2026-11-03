import 'package:get/get.dart';

import '../controllers/manage_notice_temp_controller.dart';

class ManageNoticeTempBinding extends Bindings {
  final String tag;
  ManageNoticeTempBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageNoticeTempController>(
      () => ManageNoticeTempController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
