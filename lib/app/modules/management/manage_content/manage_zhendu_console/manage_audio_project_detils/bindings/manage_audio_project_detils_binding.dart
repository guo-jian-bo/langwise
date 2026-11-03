import 'package:get/get.dart';

import '../controllers/manage_audio_project_detils_controller.dart';

class ManageAudioProjectDetilsBinding extends Bindings {
  final String tag;
  ManageAudioProjectDetilsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageAudioProjectDetilsController>(
      () => ManageAudioProjectDetilsController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
