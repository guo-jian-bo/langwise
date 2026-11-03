import 'package:get/get.dart';

import '../controllers/manage_persona_controller.dart';

class ManagePersonaBinding extends Bindings {
  final String tag;
  ManagePersonaBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManagePersonaController>(
      () => ManagePersonaController(tag: tag),
      tag: tag,
    );
  }
}
