import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../controllers/specialty_controller.dart';

class SpecialtyBinding extends Bindings {
  final String tagText;
  SpecialtyBinding({this.tagText = Routes.SPECIALTY});

  @override
  void dependencies() {
    Get.lazyPut<SpecialtyController>(
      () => SpecialtyController(tagText: tagText),
      tag: tagText,
    );
  }
}
