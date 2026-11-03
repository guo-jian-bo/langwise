import 'package:get/get.dart';

import '../controllers/series_of_pictures_controller.dart';

class SeriesOfPicturesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SeriesOfPicturesController>(
      () => SeriesOfPicturesController(),
    );
  }
}
