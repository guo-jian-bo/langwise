import 'package:get/get.dart';
import 'package:langwise/common/https/manage_exercise_request.dart';
import 'package:langwise/app/modules/management/models/manage_exercise_quiz_model.dart';
import 'package:langwise/common/entities/list.dart';
import 'package:langwise/common/https/manage_select_quzi_knowledge.dart';
import 'package:langwise/common/stores/base_controller.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/common/widgets/data_table_widget/data_sources.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../../../../../routes/routes.dart';
import '../../../models/manage_exercise_course_affiliation_model.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';

class ManageExerciseCourseAffiliationController extends BaseController with ManageBreadcrumbMixin {
  final String tag;
  ManageExerciseCourseAffiliationController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_EXERCISE_COURSE_AFFILIATION;

  @override
  String get breadcrumbTitle => '课程归属';

  bool disabledButton = false;
  ManageExerciseQuizModel? quizModel;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if (Get.arguments != null) {
      quizModel = Get.arguments['quizModel'];
      disabledButton = Get.arguments['disabledButton'] ?? false;
    }
  }

  Future<DesertsFakeWebServiceResponse<ManageExerciseCourseAffiliationModel>> onFetchPages(
      int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData) async {
    try {
      final ListResponseEntity<ManageExerciseCourseAffiliationModel>? res =
          await ManageExerciseRequest.getQuizCourseList(parameters: {
        'offset': 0,
        'limit': 100,
        'exerciseIds': quizModel?.uid,
      }, data: {});
      if (res == null) {
        return DesertsFakeWebServiceResponse<ManageExerciseCourseAffiliationModel>(0, []);
      }

      return DesertsFakeWebServiceResponse<ManageExerciseCourseAffiliationModel>(res.count!, (res.datas ?? []));
    } catch (e) {
      return DesertsFakeWebServiceResponse<ManageExerciseCourseAffiliationModel>(0, []);
    }
  }

  void viewUnit(context, ManageExerciseCourseAffiliationModel item) {
    int? moduleId = int.tryParse(item.courseModuleId!);

    ManagePageRegistry.jumpTo(
      Routes.MANAGE_MODULE_DETILS,
      arguments: {
        "moduleId": moduleId,
        "moduleName": item.courseModuleName,
        "language": 'en',
        'unitId': item.courseUnitId,
      },
    );
  }

  void viewLesson(context, ManageExerciseCourseAffiliationModel item) {
    int? lessonId = int.tryParse(item.courseLessonId!);

    ManagePageRegistry.jumpTo(
      Routes.MANAGE_QUIZ_LIST,
      arguments: {
        "lessonId": lessonId,
        "quizId": quizModel?.uid,
      },
    ).then((_) {
      onRefresh();
    });
  }

  Future<void> deleteQuiz(context, ManageExerciseCourseAffiliationModel item) async {
    final askRes = await AskDialog.showUserAsk(
      context: context,
      content: "您确定要删除吗？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) {
      return;
    }

    quizOperation(item.courseLessonId, 'course_delete', [quizModel?.uid ?? 0], "删除");
  }

  void accessQuiz(context, ManageExerciseCourseAffiliationModel item) async {
    final askRes = await AskDialog.showUserAsk(
      context: context,
      content: "您确定要${item.access == 'NORMAL' ? '下架' : '上架'}此题目吗？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) {
      return;
    }

    quizOperation(item.courseLessonId, item.access == 'NORMAL' ? 'batch_shelf_off' : 'batch_shelf_on',
        [quizModel?.uid ?? 0], item.access == 'NORMAL' ? '下架' : '上架');
  }

  Future<void> quizOperation(String? lessonId, String method, List<int> ids, String text) async {
    if (lessonId == null) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> data = {
        "exerciseIds": ids,
        "lessonId": int.tryParse(lessonId),
      };
      bool res = await ManageSelectQuziKnowledge.quizOperation(data, method);
      if (!res) return;
      ToastUtils.showManageToast(text: "$text成功");
      onRefresh();
    } finally {
      ToastUtils.hideLoading();
    }
  }
}
