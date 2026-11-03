import 'package:get/get.dart';

import '../controllers/manage_create_quiz_listen_find_word_controller.dart';

class ManageCreateQuizListenFindWordBinding extends Bindings {
  final String tag;
  ManageCreateQuizListenFindWordBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageCreateQuizListenFindWordController>(
      () => ManageCreateQuizListenFindWordController(tag: tag),
      tag: tag,
    );
  }
}
