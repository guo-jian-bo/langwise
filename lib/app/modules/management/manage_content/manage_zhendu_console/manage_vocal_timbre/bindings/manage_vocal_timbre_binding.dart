import 'package:get/get.dart';

import '../controllers/manage_vocal_timbre_controller.dart';

class ManageVocalTimbreBinding extends Bindings {
  final String tag;
  ManageVocalTimbreBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageVocalTimbreController>(
      () => ManageVocalTimbreController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
