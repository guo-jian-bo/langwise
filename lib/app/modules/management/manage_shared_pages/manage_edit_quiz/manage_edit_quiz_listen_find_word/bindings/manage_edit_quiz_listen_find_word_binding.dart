import 'package:get/get.dart';

import '../controllers/manage_edit_quiz_listen_find_word_controller.dart';

class ManageEditQuizListenFindWordBinding extends Bindings {
  final String tag;
  ManageEditQuizListenFindWordBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageEditQuizListenFindWordController>(
      () => ManageEditQuizListenFindWordController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
