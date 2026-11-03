import 'package:get/get.dart';

import '../controllers/favourite_controller.dart';

class FavouriteBinding extends Bindings {
  final String tagText;
  FavouriteBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<FavouriteController>(
      () => FavouriteController(tagText: tagText),
      tag: tagText,
    );
  }
}
