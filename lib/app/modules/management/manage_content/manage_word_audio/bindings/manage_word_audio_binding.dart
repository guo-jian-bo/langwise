import 'package:get/get.dart';

import '../controllers/manage_word_audio_controller.dart';

class ManageWordAudioBinding extends Bindings {
  final String tag;
  ManageWordAudioBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageWordAudioController>(
      () => ManageWordAudioController(tag: tag),
      tag: tag,
    );
  }
}
