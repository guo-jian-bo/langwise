import 'package:get/get.dart';

import '../controllers/become_inviter_controller.dart';

class BecomeInviterBinding extends Bindings {
  final String tagText;
  BecomeInviterBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<BecomeInviterController>(
      () => BecomeInviterController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
