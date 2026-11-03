import 'package:get/get.dart';

import '../controllers/video_task_player_controller.dart';

class VideoTaskPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoTaskPlayerController>(
      () => VideoTaskPlayerController(),
    );
  }
}
