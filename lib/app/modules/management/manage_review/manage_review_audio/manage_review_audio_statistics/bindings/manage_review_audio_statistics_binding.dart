import 'package:get/get.dart';

import '../controllers/manage_review_audio_statistics_controller.dart';

class ManageReviewAudioStatisticsBinding extends Bindings {
  final String tag;
  ManageReviewAudioStatisticsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageReviewAudioStatisticsController>(
      () => ManageReviewAudioStatisticsController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
