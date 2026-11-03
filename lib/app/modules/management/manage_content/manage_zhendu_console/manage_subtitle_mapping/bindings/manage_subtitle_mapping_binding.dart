import 'package:get/get.dart';

import '../controllers/manage_subtitle_mapping_controller.dart';

class ManageSubtitleMappingBinding extends Bindings {
  final String tag;
  ManageSubtitleMappingBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageSubtitleMappingController>(
      () => ManageSubtitleMappingController(tag: tag),
      tag: tag,
    );
  }
}
