import 'package:get/get.dart';

import '../controllers/manage_unit_writing_pipeline_controller.dart';

class ManageUnitWritingPipelineBinding extends Bindings {
  final String tagText;
  ManageUnitWritingPipelineBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut(
      () => ManageUnitWritingPipelineController(tagText: tagText),
      tag: tagText,
    );
  }
}
