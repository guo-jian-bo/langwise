import 'package:get/get.dart';

import '../controllers/manage_check_image_audit_statistics_controller.dart';

class ManageCheckImageAuditStatisticsBinding extends Bindings {
  final String tag;
  ManageCheckImageAuditStatisticsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageCheckImageAuditStatisticsController>(
      () => ManageCheckImageAuditStatisticsController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
