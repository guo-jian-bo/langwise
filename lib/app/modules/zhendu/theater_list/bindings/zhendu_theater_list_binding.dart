import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';

import '../controllers/zhendu_theater_list_controller.dart';

class ZhenduTheaterListBinding extends Bindings {
  final String tagText;
  final ZhenduTheaterEntity theater;

  ZhenduTheaterListBinding({
    required this.tagText,
    required this.theater,
  });

  @override
  void dependencies() {
    Get.lazyPut<ZhenduTheaterListController>(
      () => ZhenduTheaterListController(
        tagText: tagText,
        theater: theater,
      ),
      tag: tagText,
    );
  }
}
