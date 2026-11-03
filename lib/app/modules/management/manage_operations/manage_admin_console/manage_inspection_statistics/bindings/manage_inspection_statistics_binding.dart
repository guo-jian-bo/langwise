import 'package:get/get.dart';

import '../controllers/manage_inspection_statistics_controller.dart';

class ManageInspectionStatisticsBinding extends Bindings {
  final String tag;
  ManageInspectionStatisticsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageInspectionStatisticsController>(
      () => ManageInspectionStatisticsController(tag: tag),
      tag: tag,
    );
  }
}

