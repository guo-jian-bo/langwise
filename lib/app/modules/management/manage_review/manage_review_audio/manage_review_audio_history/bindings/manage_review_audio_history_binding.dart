import 'package:get/get.dart';

import '../controllers/manage_review_audio_history_controller.dart';



class ManageReviewAudioHistoryBinding extends Bindings {
  final String tag;
  ManageReviewAudioHistoryBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageReviewAudioHistoryController>(
      () => ManageReviewAudioHistoryController(tag: tag),
      tag: tag,
    );
  }
}
