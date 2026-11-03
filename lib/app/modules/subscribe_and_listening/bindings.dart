import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import 'controller.dart';

class SubListenBinding implements Bindings {
  final String tagText;
  SubListenBinding({this.tagText = Routes.APP_SUBSCRIBE_LISTENING});

  @override
  void dependencies() {
    Get.lazyPut<SubListenController>(
      () => SubListenController(tagText: tagText),
      tag: tagText,
    );
  }
}
