import 'package:get/get.dart';

import '../controllers/manage_quiz_template_controller.dart';

class ManageQuizTemplateBinding implements Bindings {
  final String tag;
  ManageQuizTemplateBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageQuizTemplateController>(
      () => ManageQuizTemplateController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
