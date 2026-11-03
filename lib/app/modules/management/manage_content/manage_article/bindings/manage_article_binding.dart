import 'package:get/get.dart';

import '../controllers/manage_article_controller.dart';

class ManageArticleBinding extends Bindings {
  final String tag;
  ManageArticleBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageArticleController>(
      () => ManageArticleController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
