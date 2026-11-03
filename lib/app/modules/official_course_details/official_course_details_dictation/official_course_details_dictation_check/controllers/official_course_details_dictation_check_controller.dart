import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';

import '../../../../../../common/entities/entities.dart';

class OfficialCourseDetailsDictationCheckController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  OfficialCourseDetailsDictationCheckController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.OFFICIAL_COURSE_DETAILS_DICTATION_CHECK;

  @override
  String get breadcrumbTitle => "核对答案";

  /// 知识点列表
  final RxList<UnitKnowledgePointsEntityKnowledgeList> knowledgeList = <UnitKnowledgePointsEntityKnowledgeList>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);

    if (Get.arguments != null) {
      try {
        knowledgeList.value = Get.arguments["knowledgeList"];
      } catch (_) {
        
      }
    }

  }

}
