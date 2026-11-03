import 'package:get/get.dart';

import '../controllers/manage_inspection_statistics_record_controller.dart';

class ManageInspectionStatisticsRecordBinding extends Bindings {
  final String tag;
  ManageInspectionStatisticsRecordBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageInspectionStatisticsRecordController>(
      () => ManageInspectionStatisticsRecordController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}

