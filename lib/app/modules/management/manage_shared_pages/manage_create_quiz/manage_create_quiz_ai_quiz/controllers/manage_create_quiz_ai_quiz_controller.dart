import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_create_quiz_request.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/entities/quiz_ai_queue_entity.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../../../../../../routes/routes.dart';
import '../../../../../../routes/tag_routes.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';
import '../../../../utils/manage_page_registry.dart';

class ManageCreateQuizAiQuizController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageCreateQuizAiQuizController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_CREATE_QUIZ_AI_QUIZ;

  @override
  String get breadcrumbTitle => 'AI题目预览';

  AiQuizModel? aiQuizModel;
  int? lessonId;
  int? unitId;
  String? language;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    if (Get.arguments != null) {
      lessonId = Get.arguments["lessonId"];
      unitId = Get.arguments["unitId"];
      language = Get.arguments["language"];
      aiQuizModel = Get.arguments["aiQuizModel"];
    }
  }

  Future<void> toDemonstrate() async {
    if (aiQuizModel?.exerciseDTO == null) return;

    await TagRoutes.toNamed(
      Routes.PRACTICE_QUESTIONS,
      arguments: {
        "currentQuizId": aiQuizModel?.exerciseDTO?.uid,
        "quizDatas": [aiQuizModel?.exerciseDTO],
      },
    );
  }

  Future<void> giveUp() async {
    if (aiQuizModel?.exerciseDTO == null) return;
    Map<String, dynamic> reqData = {
      "exerciseIds": [aiQuizModel?.exerciseId],
      "recordId": aiQuizModel?.uid,
    };
    bool isSuccess = await ManageCreateQuizRequest.giveUpAiQuiz(reqData);
    if (isSuccess) {
      ToastUtils.showManageToast(text: "已放弃生成");
      Get.back(result: {'refresh': true});
    }
  }

  Future<void> edit() async {
    if (aiQuizModel?.exerciseDTO == null) return;
    String? editRoute = _getEditRouteByType(aiQuizModel?.template?.type);
    if (editRoute == null || editRoute.isEmpty) return;
    
    ManagePageRegistry.jumpTo(
      editRoute,
      arguments: {
        "quizId": aiQuizModel?.exerciseDTO?.uid,
        "needBack": true,
      },
    );
  }

  String? _getEditRouteByType(String? type) {
    switch (type) {
      case 'WORD_COMPLETION':
        return Routes.MANAGE_EDIT_QUIZ_WORD_COMPLETION;
      case 'LISTEN_FIND_WORD':
        return Routes.MANAGE_EDIT_QUIZ_LISTEN_FIND_WORD;
      case 'CLASSIFY_CHALLENGE':
        return Routes.MANAGE_EDIT_QUIZ_CLASSIFY_CHALLENGE;
      case 'CONTRAST_CLOZE':
        return Routes.MANAGE_EDIT_QUIZ_CONTRAST_CLOZE;
      case 'SENTENCE_CLOZE':
        return Routes.MANAGE_EDIT_QUIZ_SENTENCE_CLOZE;
      default:
        return null;
    }
  }

  Future<void> confirm() async {
    if (aiQuizModel?.exerciseDTO == null) return;
    Map<String, dynamic> reqData = {
      "exerciseIds": [aiQuizModel?.exerciseId],
      "recordId": aiQuizModel?.uid,
      "lessonId": lessonId,
    };

    try {
      ToastUtils.showLoading();

      bool isSuccess = await ManageCreateQuizRequest.confirmAiQuiz(reqData);
      if (isSuccess) {
        ToastUtils.showManageToast(text: "已确认生成");
        Get.back(result: {'refresh': true});
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }
}
