import 'package:get/get.dart';

import '../controllers/manage_quiz_immersive_chain_controller.dart';

class ManageQuizImmersiveChainBinding extends Bindings {
  final String tag;
  ManageQuizImmersiveChainBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageQuizImmersiveChainController>(
      () => ManageQuizImmersiveChainController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
