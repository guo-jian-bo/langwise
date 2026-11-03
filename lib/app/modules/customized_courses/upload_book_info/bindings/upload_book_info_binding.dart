import 'package:get/get.dart';

import '../controllers/upload_book_info_controller.dart';

class UploadBookInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UploadBookInfoController>(
      () => UploadBookInfoController(),
    );
  }
}
