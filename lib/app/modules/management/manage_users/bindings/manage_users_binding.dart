import 'package:get/get.dart';

import '../controllers/manage_users_controller.dart';

class ManageUsersBinding extends Bindings {
  final String tag;
  ManageUsersBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageUsersController>(
      () => ManageUsersController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
