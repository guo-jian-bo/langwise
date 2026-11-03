import 'package:get/get.dart';

import '../controllers/zhenxie_task_details_board_controller.dart';
import '../controllers/zhenxie_task_details_correction_controller.dart';
import '../controllers/zhenxie_task_details_controller.dart';
import '../controllers/zhenxie_task_exercise_controller.dart';
import '../controllers/zhenxie_task_details_exemplar_controller.dart';
import '../controllers/zhenxie_task_details_task_controller.dart';

class ZhenxieTaskDetailsBinding extends Bindings {
  final String tagText;
  ZhenxieTaskDetailsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieTaskDetailsTaskController>(
      () => ZhenxieTaskDetailsTaskController(tagText: tagText),
      tag: tagText,
    );
    Get.lazyPut<ZhenxieTaskDetailsExemplarController>(
      () => ZhenxieTaskDetailsExemplarController(tagText: tagText),
      tag: tagText,
    );
    Get.lazyPut<ZhenxieTaskDetailsCorrectionController>(
      () => ZhenxieTaskDetailsCorrectionController(tagText: tagText),
      tag: tagText,
    );
    Get.lazyPut<ZhenxieTaskDetailsBoardController>(
      () => ZhenxieTaskDetailsBoardController(tagText: tagText),
      tag: tagText,
    );
    Get.lazyPut<ZhenxieTaskExerciseController>(
      () => ZhenxieTaskExerciseController(tagText: tagText),
      tag: tagText,
    );
    Get.lazyPut<ZhenxieTaskDetailsController>(
      () => ZhenxieTaskDetailsController(tagText: tagText),
      tag: tagText,
    );
  }
}
