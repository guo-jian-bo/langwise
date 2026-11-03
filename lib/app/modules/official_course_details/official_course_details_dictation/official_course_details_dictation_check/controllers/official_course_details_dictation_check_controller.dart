
import 'package:get/get.dart';

import '../../../../../../common/entities/entities.dart';

class OfficialCourseDetailsDictationCheckController extends GetxController {

  /// 知识点列表
  final RxList<UnitKnowledgePointsEntityKnowledgeList> knowledgeList = <UnitKnowledgePointsEntityKnowledgeList>[].obs;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      try {
        knowledgeList.value = Get.arguments["knowledgeList"];
      } catch (_) {
        
      }
    }

  }

}
