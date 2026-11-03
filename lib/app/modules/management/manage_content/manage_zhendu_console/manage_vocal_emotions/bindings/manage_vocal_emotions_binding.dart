import 'package:get/get.dart';

import '../controllers/manage_vocal_emotions_controller.dart';

class ManageVocalEmotionsBinding extends Bindings {
  final String tag;
  ManageVocalEmotionsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageVocalEmotionsController>(
      () => ManageVocalEmotionsController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
