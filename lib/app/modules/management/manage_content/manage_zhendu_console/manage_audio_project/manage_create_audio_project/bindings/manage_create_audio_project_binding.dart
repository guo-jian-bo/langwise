import 'package:get/get.dart';

import '../controllers/manage_create_audio_project_controller.dart';

class ManageCreateAudioProjectBinding extends Bindings {
  final String tag;
  ManageCreateAudioProjectBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageCreateAudioProjectController>(
      () => ManageCreateAudioProjectController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
