import 'package:get/get.dart';

import '../controllers/manage_review_audio_controller.dart';

class ManageReviewAudioBinding extends Bindings {
  final String tag;
  ManageReviewAudioBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageReviewAudioController>(
      () => ManageReviewAudioController(tag: tag),
      tag: tag,
    );
  }
}
