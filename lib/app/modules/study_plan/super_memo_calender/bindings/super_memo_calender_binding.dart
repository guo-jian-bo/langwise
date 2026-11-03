import 'package:get/get.dart';

import '../controllers/super_memo_calender_controller.dart';

class SuperMemoCalenderBinding extends Bindings {
  final String tagText;
  SuperMemoCalenderBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<SuperMemoCalenderController>(
      () => SuperMemoCalenderController(tagText: tagText),
      tag: tagText,
    );
  }
}
