import 'package:get/get.dart';

import '../../../../routes/routes.dart';

class MemoryCardListController extends GetxController {
  String? dayDate;

  @override
  void onInit() {
    super.onInit();
    if(Get.arguments != null){
      dayDate = Get.arguments['dayDate']??"";
    }
  }

  Future<void> toCardMemoryDetil() async{
    Get.toNamed(Routes.MEMORY_RECORDER_CHART);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
