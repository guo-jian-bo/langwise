import 'package:get/get.dart';

import '../controllers/manage_script_grouping_controller.dart';

class ManageScriptGroupingBinding extends Bindings {
  final String tag;
  ManageScriptGroupingBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageScriptGroupingController>(
      () => ManageScriptGroupingController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
