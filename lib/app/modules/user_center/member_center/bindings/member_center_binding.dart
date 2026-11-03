import 'package:get/get.dart';

import '../controllers/member_center_controller.dart';

class MemberCenterBinding extends Bindings {
  final String tagText;
  MemberCenterBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<MemberCenterController>(
      () => MemberCenterController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
