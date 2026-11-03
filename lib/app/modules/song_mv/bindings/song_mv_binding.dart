import 'package:get/get.dart';

import '../controllers/song_mv_controller.dart';

class SongMvBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SongMvController>(
      () => SongMvController(),
    );
  }
}
