import 'package:get/get.dart';

import '../controllers/manage_script_genre_controller.dart';

class ManageScriptGenreBinding extends Bindings {
  final String tag;
  ManageScriptGenreBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageScriptGenreController>(
      () => ManageScriptGenreController(tag: tag),
      tag: tag,
    );
  }
}
