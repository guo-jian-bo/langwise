import 'package:get/get.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/https/manage_course_console_knowledge.dart';
import '../../../../../../common/widgets/data_table_widget/data_table.dart';
import '../../../../../routes/routes.dart';
import '../../../models/manage_english_word_course_usage_model.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';

class ManageEnglishCourseUsageController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageEnglishCourseUsageController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_ENGLISH_COURSE_USAGE;

  @override
  String get breadcrumbTitle => '课程归属列表';

  String? type;
  int? uid;
  int? semanticId;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if (Get.arguments != null) {
      type = Get.arguments['type'];
      uid = Get.arguments['uid'];
      semanticId = Get.arguments['semanticId'];
    }
  }

  Future<DesertsFakeWebServiceResponse<ManageEnglishWordCourseUsageModel>> onFetchPages(
    int currentPage,
    int startingAt,
    int count,
    String sortedBy,
    bool sortedAsc,
    bool noData,
  ) async {
    try {
      if (uid == null || type == null) {
        return DesertsFakeWebServiceResponse<ManageEnglishWordCourseUsageModel>(0, []);
      }

      final ListResponseEntity<ManageEnglishWordCourseUsageModel>? res = await ManageCourseConsoleKnowledgeRequest.getKnowledgeCourseInfos<ManageEnglishWordCourseUsageModel>(
        uid: uid!,
        type: type!,
        semanticId: semanticId,
        fromJson: (json) => ManageEnglishWordCourseUsageModel.fromJson(json),
      );

      if (res == null) {
        return DesertsFakeWebServiceResponse<ManageEnglishWordCourseUsageModel>(0, []);
      }

      return DesertsFakeWebServiceResponse<ManageEnglishWordCourseUsageModel>(res.count ?? 0, res.datas ?? []);
    } catch (_) {
      return DesertsFakeWebServiceResponse<ManageEnglishWordCourseUsageModel>(0, []);
    }
  }

  void viewUnit(context, ManageEnglishWordCourseUsageModel item) {
    int? moduleId = int.tryParse(item.courseModuleId!);

    ManagePageRegistry.jumpTo(
      Routes.MANAGE_MODULE_DETILS,
      arguments: {
        "moduleId": moduleId,
        "moduleName": item.courseModuleName,
        "language": 'en',
        "unitId": item.courseUnitId,
      },
    );
  }
}
