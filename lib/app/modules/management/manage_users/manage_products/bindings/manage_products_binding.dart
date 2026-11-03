import 'package:get/get.dart';

import '../controllers/manage_products_controller.dart';

class ManageProductsBinding extends Bindings {
  final String tag;
  ManageProductsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageProductsController>(
      () => ManageProductsController(tag: tag),
      tag: tag,
    );
  }
}
