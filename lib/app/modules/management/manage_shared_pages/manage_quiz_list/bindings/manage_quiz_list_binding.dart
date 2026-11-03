import 'package:get/get.dart';

import '../controllers/manage_quiz_list_controller.dart';

class ManageQuizListBinding extends Bindings {
  final String tag;
  ManageQuizListBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageQuizListController>(
      () => ManageQuizListController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
