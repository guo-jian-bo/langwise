import 'package:get/get.dart';

import '../controllers/manage_new_crowd_controller.dart';

class ManageNewCrowdBinding extends Bindings {
  final String tag;
  ManageNewCrowdBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageNewCrowdController>(
      () => ManageNewCrowdController(tag: tag),
      tag: tag,
    );
  }
}
