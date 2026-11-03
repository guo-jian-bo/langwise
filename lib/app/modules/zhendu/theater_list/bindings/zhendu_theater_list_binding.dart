import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';

import '../controllers/zhendu_theater_list_controller.dart';

class ZhenduTheaterListBinding extends Bindings {
  final ZhenduTheaterEntity theater;

  ZhenduTheaterListBinding({required this.theater});

  @override
  void dependencies() {
    Get.put<ZhenduTheaterListController>(ZhenduTheaterListController(theater: theater));
  }
}

