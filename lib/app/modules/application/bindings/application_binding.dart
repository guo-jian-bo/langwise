import 'package:get/get.dart';
import 'package:langwise/app/modules/home/bindings/home_binding.dart';
import 'package:langwise/app/modules/home/controllers/home_controller.dart';
import '../controllers/application_controller.dart';
import '../controllers/message_controller.dart';
import '../controllers/work_order_list_controller.dart';
class ApplicationBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut<ApplicationController>(
      () => ApplicationController(),
      fenix: true,
    );
    Get.lazyPut<MessageController>(
      () => MessageController(),
      fenix: true,
    );
    Get.lazyPut<WorkOrderListController>(
      () => WorkOrderListController(),
      fenix: true,
    );
    if (!Get.isRegistered<HomeController>()) {
      HomeBinding().dependencies();
    }
  }
}
