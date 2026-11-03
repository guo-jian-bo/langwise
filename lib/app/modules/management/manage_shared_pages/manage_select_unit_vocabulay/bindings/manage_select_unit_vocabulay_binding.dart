import 'package:get/get.dart';

import '../controllers/manage_select_unit_vocabulay_controller.dart';

class ManageSelectUnitVocabulayBinding extends Bindings {
  final String tag;
  ManageSelectUnitVocabulayBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageSelectUnitVocabulayController>(
      () => ManageSelectUnitVocabulayController(tag: tag),
      tag: tag,
    );
  }
}
