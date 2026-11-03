import 'package:get/get.dart';

import '../controllers/manage_script_details_controller.dart';

class ManageScriptDetailsBinding extends Bindings {
  final String tag;
  ManageScriptDetailsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageScriptDetailsController>(
      () => ManageScriptDetailsController(tag: tag),
      tag: tag,
    );
  }
}
