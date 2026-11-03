import 'package:get/get.dart';

import '../controllers/video_task_player_controller.dart';

class VideoTaskPlayerBinding extends Bindings {
  final String tagText;
  VideoTaskPlayerBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<VideoTaskPlayerController>(
      () => VideoTaskPlayerController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
