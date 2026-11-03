import 'package:get/get.dart';

import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';
import '../../../../routes/tag_routes.dart';

class MemoryCardListController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  MemoryCardListController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.MEMORY_CARD_LIST;

  @override
  String get breadcrumbTitle => '超记记录';

  String? dayDate;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if(Get.arguments != null){
      dayDate = Get.arguments['dayDate']??"";
    }
  }

  Future<void> toCardMemoryDetil() async{
    await TagRoutes.toNamed(Routes.MEMORY_RECORDER_CHART);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
