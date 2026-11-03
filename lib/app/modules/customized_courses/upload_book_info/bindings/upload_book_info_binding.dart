import 'package:get/get.dart';

import '../controllers/upload_book_info_controller.dart';

class UploadBookInfoBinding extends Bindings {
  final String tagText;
  UploadBookInfoBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<UploadBookInfoController>(
      () => UploadBookInfoController(tagText: tagText),
      tag: tagText,
    );
  }
}
