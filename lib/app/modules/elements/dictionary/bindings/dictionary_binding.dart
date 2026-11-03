import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../controllers/dictionary_controller.dart';

class DictionaryBinding extends Bindings {
  final String tagText;
  DictionaryBinding({
    this.tagText = Routes.DICTIONARY,
  });

  @override
  void dependencies() {
    Get.lazyPut<DictionaryController>(
      () => DictionaryController(tagText: tagText),
      tag: tagText,
    );
  }
}
