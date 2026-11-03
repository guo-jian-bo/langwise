import 'package:get/get.dart';

import '../controllers/manage_channel_create_controller.dart';

class ManageChannelCreateBinding extends Bindings {
  final String tag;
  ManageChannelCreateBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageChannelCreateController>(
      () => ManageChannelCreateController(tag: tag),
      tag: tag,
    );
  }
}
