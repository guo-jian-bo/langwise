import 'package:get/get.dart';

import '../controllers/manage_users_table_controller.dart';

class ManageUsersTableBinding extends Bindings {
  final String tag;
  ManageUsersTableBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageUsersTableController>(
      () => ManageUsersTableController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
