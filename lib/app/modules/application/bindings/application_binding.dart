import 'package:get/get.dart';
import 'package:langwise/app/modules/home/bindings/home_binding.dart';
import 'package:langwise/app/modules/image_moderation/index.dart';
import 'package:langwise/app/modules/music/bindings/music_binding.dart';
import 'package:langwise/app/modules/subscribe_and_listening/bindings.dart';

import '../../elements/elements_detils/bindings/elements_detils_binding.dart';
import '../../specialty/bindings/specialty_binding.dart';
import '../controllers/application_controller.dart';

class ApplicationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApplicationController>(
      () => ApplicationController(),
    );
    HomeBinding().dependencies();
    SubListenBinding().dependencies();
    ElementsDetilsBinding().dependencies();
    SpecialtyBinding().dependencies();
    MusicBinding().dependencies();
    Get.lazyPut<ImageModerationController>(
      () => ImageModerationController(),
      fenix: true, 
    );
  }
}
