import 'package:get/get.dart';

import '../controllers/manage_general_song_controller.dart';

class ManageGeneralSongBinding extends Bindings {
  final String tag;
  ManageGeneralSongBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageGeneralSongController>(
      () => ManageGeneralSongController(tag: tag),
      tag: tag,
    );
  }
}
