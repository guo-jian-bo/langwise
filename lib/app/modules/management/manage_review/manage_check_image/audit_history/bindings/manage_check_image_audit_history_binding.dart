import 'package:get/get.dart';

import '../controllers/manage_check_image_audit_history_controller.dart';

class ManageCheckImageAuditHistoryBinding extends Bindings {
  final String tag;
  ManageCheckImageAuditHistoryBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageCheckImageAuditHistoryController>(
      () => ManageCheckImageAuditHistoryController(tag: tag),
      tag: tag,
    );
  }
}
