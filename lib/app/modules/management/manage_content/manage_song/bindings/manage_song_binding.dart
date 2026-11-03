import 'package:get/get.dart';

import '../controllers/manage_song_controller.dart';

class ManageSongBinding extends Bindings {
  final String tag;
  ManageSongBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageSongController>(
      () => ManageSongController(tag: tag),
      tag: tag,
    );
  }
}
