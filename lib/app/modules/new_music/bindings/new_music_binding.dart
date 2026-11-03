import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../controllers/new_music_controller.dart';

class NewMusicBinding extends Bindings {
  final String tagText;
  NewMusicBinding({this.tagText = Routes.MUSIC});

  @override
  void dependencies() {
    Get.lazyPut<NewMusicController>(
      () => NewMusicController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
