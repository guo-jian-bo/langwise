import 'package:get/get.dart';

import '../controllers/manage_quiz_general_ai_controller.dart';

class ManageQuizGeneralAiBinding extends Bindings {
  final String tag;
  ManageQuizGeneralAiBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageQuizGeneralAiController>(
      () => ManageQuizGeneralAiController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
