import 'package:get/get.dart';

import '../controllers/manage_word_inflection_controller.dart';

class ManageWordInflectionBinding extends Bindings {
  final String tag;
  ManageWordInflectionBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageWordInflectionController>(
      () => ManageWordInflectionController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
