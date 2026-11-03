import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../controllers/morpheme_controller.dart';

class MorphemeBinding extends Bindings {
  final String tagText;
  MorphemeBinding({this.tagText = Routes.DICTIONARY_MORPHEME});

  @override
  void dependencies() {
    Get.lazyPut<MorphemeController>(
      () => MorphemeController(tagText: tagText),
      tag: tagText,
    );
  }
}
