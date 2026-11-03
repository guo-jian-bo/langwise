import 'package:get/get.dart';
import '../controllers/zhenxie_exam_compare_controller.dart';

class ZhenxieExamCompareBinding extends Bindings {
  final String tagText;

  ZhenxieExamCompareBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieExamCompareController>(
      () => ZhenxieExamCompareController(tagText: tagText),
      tag: tagText,
    );
  }
}
