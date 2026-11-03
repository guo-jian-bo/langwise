import 'package:get/get.dart';
import 'package:langwise/app/modules/home/bindings/home_binding.dart';
import 'package:langwise/app/modules/home/controllers/home_controller.dart';
import 'package:langwise/app/modules/music/bindings/music_binding.dart';
import 'package:langwise/app/modules/music/controllers/music_controller.dart';
import 'package:langwise/app/modules/subscribe_and_listening/bindings.dart';
import 'package:langwise/app/modules/subscribe_and_listening/controller.dart';
import 'package:langwise/app/modules/zhendu/bindings.dart';
import 'package:langwise/app/modules/zhendu/home/controllers/zhendu_home_controller.dart';

import '../../../routes/routes.dart';
import '../../elements/elements_detils/bindings/elements_detils_binding.dart';
import '../../elements/elements_detils/controllers/elements_detils_controller.dart';
import '../../specialty/bindings/specialty_binding.dart';
import '../../specialty/controllers/specialty_controller.dart';
import '../controllers/application_controller.dart';

class ApplicationBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut<ApplicationController>(
      () => ApplicationController(),
      tag: Routes.APPLICATION,
      fenix: true,
    );
    if (!Get.isRegistered<HomeController>()) {
      HomeBinding().dependencies();
    }
    if (!Get.isRegistered<SubListenController>()) {
      SubListenBinding().dependencies();
    }
    if (!Get.isRegistered<ZhenduHomeController>()) {
      ZhenduBinding().dependencies();
    }
    if (!Get.isRegistered<ElementsDetilsController>()) {
      ElementsDetilsBinding().dependencies();
    }
    if (!Get.isRegistered<SpecialtyController>()) {
      SpecialtyBinding().dependencies();
    }
    if (!Get.isRegistered<MusicController>()) {
      MusicBinding().dependencies();
    }
  }
}
