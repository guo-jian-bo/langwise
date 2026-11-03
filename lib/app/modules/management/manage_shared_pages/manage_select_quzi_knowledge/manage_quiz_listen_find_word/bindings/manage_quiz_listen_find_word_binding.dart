import 'package:get/get.dart';

import '../controllers/manage_quiz_listen_find_word_controller.dart';

class ManageQuizListenFindWordBinding extends Bindings {
  final String tag;
  ManageQuizListenFindWordBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageQuizListenFindWordController>(
      () => ManageQuizListenFindWordController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
