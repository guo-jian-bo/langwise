import 'package:get/get.dart';

import '../controllers/zhenxie_syntax_controller.dart';

class ZhenxieSyntaxBinding extends Bindings {
  final String tagText;
  ZhenxieSyntaxBinding({required this.tagText});

  @override
  void dependencies() {
    Get.put<ZhenxieSyntaxController>(
      ZhenxieSyntaxController(tagText: tagText),
      tag: tagText,
    );
  }
}
