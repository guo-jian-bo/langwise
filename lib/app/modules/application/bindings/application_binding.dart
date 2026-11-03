import 'package:get/get.dart';
import 'package:langwise/app/modules/home/bindings/home_binding.dart';
import 'package:langwise/app/modules/home/controllers/home_controller.dart';
import '../controllers/application_controller.dart';
import '../controllers/message_controller.dart';
class ApplicationBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut<ApplicationController>(
      () => ApplicationController(),
    );
    if (!Get.isRegistered<HomeController>()) {
      HomeBinding().dependencies();
    }
    Get.lazyPut<MessageController>(
      () => MessageController(),
    );
  }
}
