import 'package:get/get.dart';

import '../controllers/etymology_memory_controller.dart';

class EtymologyMemoryBinding extends Bindings {
  final String tagText;
  EtymologyMemoryBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<EtymologyMemoryController>(
      () => EtymologyMemoryController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
