import 'package:get/get.dart';

import '../controllers/manage_word_inflection_details_controller.dart';

class ManageWordInflectionDetailsBinding extends Bindings {
  final String tag;
  ManageWordInflectionDetailsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageWordInflectionDetailsController>(
      () => ManageWordInflectionDetailsController(tag: tag),
      tag: tag,
    );
  }
}
