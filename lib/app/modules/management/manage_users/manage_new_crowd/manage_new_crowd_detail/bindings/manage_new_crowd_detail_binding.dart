import 'package:get/get.dart';

import '../controllers/manage_new_crowd_detail_controller.dart';

class ManageNewCrowdDetailBinding extends Bindings {
  final String tag;
  ManageNewCrowdDetailBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageNewCrowdDetailController>(
      () => ManageNewCrowdDetailController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
