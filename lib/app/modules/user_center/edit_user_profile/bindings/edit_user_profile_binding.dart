import 'package:get/get.dart';

import '../controllers/edit_user_profile_controller.dart';

class EditUserProfileBinding extends Bindings {
  final String tagText;
  EditUserProfileBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<EditUserProfileController>(
      () => EditUserProfileController(tagText: tagText),
      tag: tagText,
    );
  }
}
