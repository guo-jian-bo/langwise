import 'package:get/get.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:quiz_play/quiz_play.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/https/https.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../routes/tag_routes.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';
import '../../controllers/manage_select_quzi_knowledge_controller.dart';

class ManageQuizImmersiveChainController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageQuizImmersiveChainController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_QUIZ_IMMERSIVE_CHAIN;

  @override
  String get breadcrumbTitle => '沉浸式链条';

  List<ManageUnitKnowledgeEntity>? unitKnowledgeList;
  ManageLessonQuizTemplateEntity? lessonQuizTemplate;
  int? unitId;
  int? difficultyMin;
  int? difficultyMax;
  String? language;
  int? lessonId;

  List<QuizModel> quizList = [];
  final RxList<QuizModel> showQuizList = <QuizModel>[].obs;
  final RxInt rotationNumber = 1.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    if (Get.arguments != null) {
      Map argumentsMap = Get.arguments;
      Map<String, dynamic>? argumentsLessonQuizTemplate = argumentsMap["lessonQuizTemplate"];
      if (argumentsLessonQuizTemplate != null) {
        lessonQuizTemplate = ManageLessonQuizTemplateEntity.fromJson(argumentsLessonQuizTemplate);
      }
      List<Map<String, dynamic>>? argumentsKnowledgeList = argumentsMap["knowledgeList"];
      if (argumentsKnowledgeList != null) {
        unitKnowledgeList = argumentsKnowledgeList.map((e) => ManageUnitKnowledgeEntity.fromJson(e)).toList();
      }
      unitId = argumentsMap["unitId"];
      difficultyMin = argumentsMap["difficultyMin"];
      difficultyMax = argumentsMap["difficultyMax"];
      language = argumentsMap["language"];
      lessonId = argumentsMap["lessonId"];
      getQuizList();
    }
  }

  Future<void> getQuizList() async {
    try {
      ToastUtils.showLoading();
      if (unitKnowledgeList!.isEmpty) return;
      if (lessonQuizTemplate?.exerciseType == null) return;
      if (lessonQuizTemplate?.config == null) return;

      List<Map<String, dynamic>> contents = [];

      for (int i = 0; i < unitKnowledgeList!.length; i++) {
        contents.add({
          "contentType": unitKnowledgeList![i].contentType,
          "contentId": unitKnowledgeList![i].contentId,
          "semanticId": unitKnowledgeList![i].semanticId,
        });
      }
      Map<String, dynamic> reqData = {
        "type": lessonQuizTemplate?.exerciseType,
        "config": lessonQuizTemplate?.config?.toJson(),
        "contents": contents,
        "sceneCount": 3,
        "difficulty": {
          "min": difficultyMin,
          "max": difficultyMax,
        },
        "unitId": unitId,
        "lessonId": lessonId,
      };
      PreviewQuizEntity? previewQuizEntity = await ManageSelectQuziKnowledge.getAiPreviewQuizList(reqData);
      if (previewQuizEntity == null) return;
      List<QuizModel?>? resList = previewQuizEntity.list;
      if (resList == null) return;
      List<QuizModel> resQuizList = [];
      for (int i = 0; i < resList.length; i++) {
        if (resList[i] == null) continue;
        if (resList[i]!.reason != null) break;
        resList[i]!.reason = "场景${i + 1}";
        resQuizList.add(resList[i]!);
      }

      quizList = resQuizList;
      if (quizList.isNotEmpty) {
        showQuizList.add(quizList.first);
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void changeRotationNumber(int value) {
    if (quizList.length < value) {
      return;
    }
    rotationNumber.value = value;
    showQuizList.value = quizList.sublist(0, quizList.length > value ? value : quizList.length);
  }

  Future<void> toDemonstrate() async {
    if (showQuizList.isEmpty) return;
    TagRoutes.toNamed(
      Routes.PRACTICE_QUESTIONS,
      arguments: {
        "quizDatas": showQuizList.toList(),
      },
    );
  }

  Future<void> addQuiz([bool isContinue = false]) async {
    if (unitKnowledgeList == null) return;
    if (showQuizList.isEmpty) return;

    try {
      ToastUtils.showLoading();
      for (int i = 0; i < showQuizList.length; i++) {
        await ManageSelectQuziKnowledge.addRequest(
          quiz: showQuizList[i],
          unitKnowledgeList: unitKnowledgeList,
          difficultyMin: difficultyMin,
          difficultyMax: difficultyMax,
          language: language,
          lessonId: lessonId,
          configId: lessonQuizTemplate?.config?.uid,
        );
      }

      bool initialized = Get.isRegistered<ManageSelectQuziKnowledgeController>();
      if (!initialized) return;
    } finally {
      ToastUtils.hideLoading();
    }

    await Future.delayed(const Duration(milliseconds: 150));

    if (isContinue) {
      Get.back(result: {'action': 'continue'});
    } else {
      Get.back(result: {'action': 'finish', 'lessonId': lessonId});
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
