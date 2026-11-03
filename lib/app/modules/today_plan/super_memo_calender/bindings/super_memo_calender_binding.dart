import 'package:get/get.dart';

import '../controllers/super_memo_calender_controller.dart';

class SuperMemoCalenderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SuperMemoCalenderController>(() => SuperMemoCalenderController());
  }
}
