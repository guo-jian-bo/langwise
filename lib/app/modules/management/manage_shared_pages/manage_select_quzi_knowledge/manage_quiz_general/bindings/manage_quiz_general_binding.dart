import 'package:get/get.dart';

import '../controllers/manage_quiz_general_controller.dart';

class ManageQuizGeneralBinding extends Bindings {
  final String tag;
  ManageQuizGeneralBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageQuizGeneralController>(
      () => ManageQuizGeneralController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
