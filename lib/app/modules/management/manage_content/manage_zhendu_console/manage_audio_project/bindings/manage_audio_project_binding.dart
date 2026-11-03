import 'package:get/get.dart';

import '../controllers/manage_audio_project_controller.dart';

class ManageAudioProjectBinding extends Bindings {
  final String tag;
  ManageAudioProjectBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageAudioProjectController>(
      () => ManageAudioProjectController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
