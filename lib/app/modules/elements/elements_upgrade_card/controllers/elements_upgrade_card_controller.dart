import 'package:get/get.dart';

class ElementsUpgradeCardController extends GetxController {
  String? knowledge;
  
  final RxBool aiRunCompleted = false.obs;

  @override
  void onInit() {
    super.onInit();
    if(Get.arguments != null){
      knowledge = Get.arguments["knowledge"];
    }
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
