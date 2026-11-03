import 'package:get/get.dart';

import '../controllers/manage_module_detils_generate_article_controller.dart';

class ManageModuleDetilsGenerateArticleBinding extends Bindings {
  final String tag;
  ManageModuleDetilsGenerateArticleBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageModuleDetilsGenerateArticleController>(
      () => ManageModuleDetilsGenerateArticleController(tag: tag),
      tag: tag,
    );
  }
}
