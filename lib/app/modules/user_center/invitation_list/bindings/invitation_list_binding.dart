import 'package:get/get.dart';

import '../controllers/invitation_list_controller.dart';

class InvitationListBinding extends Bindings {
  final String tagText;
  InvitationListBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<InvitationListController>(
      () => InvitationListController(tagText: tagText),
      tag: tagText,
    );
  }
}
