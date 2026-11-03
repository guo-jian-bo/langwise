import 'package:get/get.dart';

import '../controllers/subscribe_listening_listcard_controller.dart';

class SubscribeListeningListcardBinding extends Bindings {
  final String tag;
  SubscribeListeningListcardBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<SubscribeListeningListcardController>(
      () => SubscribeListeningListcardController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
