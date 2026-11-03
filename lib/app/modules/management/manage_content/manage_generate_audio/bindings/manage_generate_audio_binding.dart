import 'package:get/get.dart';

import '../controllers/manage_generate_audio_controller.dart';

class ManageGenerateAudioBinding extends Bindings {
  final String tag;
  ManageGenerateAudioBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageGenerateAudioController>(
      () => ManageGenerateAudioController(tag: tag),
      tag: tag,
    );
  }
}
