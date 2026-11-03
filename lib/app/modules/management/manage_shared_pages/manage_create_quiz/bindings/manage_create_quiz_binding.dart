import 'package:get/get.dart';

import '../controllers/manage_create_quiz_controller.dart';

class ManageCreateQuizBinding extends Bindings {
  final String tag;
  ManageCreateQuizBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageCreateQuizController>(
      () => ManageCreateQuizController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
