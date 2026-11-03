import 'package:get/get.dart';

import '../controllers/manage_visual_project_synthesis_video_controller.dart';

class ManageVisualProjectSynthesisVideoBinding extends Bindings {
  final String tag;
  ManageVisualProjectSynthesisVideoBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageVisualProjectSynthesisVideoController>(
      () => ManageVisualProjectSynthesisVideoController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
