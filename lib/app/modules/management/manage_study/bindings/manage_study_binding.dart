import 'package:get/get.dart';

import '../controllers/manage_study_controller.dart';

class ManageStudyBinding extends Bindings {
  final String tag;
  ManageStudyBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageStudyController>(
      () => ManageStudyController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
