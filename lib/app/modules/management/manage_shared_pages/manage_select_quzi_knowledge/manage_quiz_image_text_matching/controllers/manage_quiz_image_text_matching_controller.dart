import 'package:get/get.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:quiz_play/quiz_play.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/https/https.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../routes/tag_routes.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';
import '../../controllers/manage_select_quzi_knowledge_controller.dart';

class ManageQuizImageTextMatchingController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageQuizImageTextMatchingController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_QUIZ_IMAGE_TEXT_MATCHING;

  @override
  String get breadcrumbTitle => '图文匹配';

  List<ManageUnitKnowledgeEntity>? unitKnowledgeList;
  ManageLessonQuizTemplateEntity? lessonQuizTemplate;
  int? unitId;
  int? difficultyMin;
  int? difficultyMax;
  String? language;
  int? lessonId;

  final RxList<QuizModel> quizList = <QuizModel>[].obs;
  final RxList<QuizModel> showQuizList = <QuizModel>[].obs;
  final RxInt errorCountNumber = 1.obs;

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
      getQuizList(1);
    }
  }

  Future<bool> getQuizList(int errorCount) async {
    if (unitKnowledgeList!.isEmpty) return false;
    if (lessonQuizTemplate?.exerciseType == null) return false;
    if (lessonQuizTemplate?.config == null) return false;

    List<Map<String, dynamic>> contents = [];

    for (int i = 0; i < unitKnowledgeList!.length; i++) {
      contents.add({
        "contentType": unitKnowledgeList![i].contentType,
        "contentId": unitKnowledgeList![i].contentId,
        "semanticId": unitKnowledgeList![i].semanticId,
      });
    }
    ManageLessonTemplateEntityDatasExerciseConfigs? config = lessonQuizTemplate?.config;
    config?.errorCount = errorCount;
    Map<String, dynamic> reqData = {
      "type": lessonQuizTemplate?.exerciseType,
      "config": config?.toJson(),
      "contents": contents,
      "difficulty": {
        "min": difficultyMin,
        "max": difficultyMax,
      },
      "unitId": unitId,
      "lessonId": lessonId,
    };
    PreviewQuizEntity? previewQuizEntity = await ManageSelectQuziKnowledge.getAiPreviewQuizList(reqData);
    if (previewQuizEntity == null) return false;
    List<QuizModel?>? resList = previewQuizEntity.list;
    if (resList == null) return false;
    List<QuizModel> resQuizList = [];
    for (int i = 0; i < resList.length; i++) {
      if (resList[i] == null) continue;
      resQuizList.add(resList[i]!);
    }
    quizList.value = resQuizList;

    if (quizList.isEmpty) return false;
    QuizModel quiz = quizList[0];
    List<QuizModelStems?> stems = quiz.stems ?? [];
    List<QuizModelOptions?> options = quiz.options ?? [];
    showQuizList.clear();
    if (stems.length != options.length) {
      showQuizList.add(quiz);
      return false;
    }
    for (int i = 0; i < stems.length; i++) {
      if (stems[i] == null || options[i] == null) continue;
      QuizModelStems stem = stems[i]!;
      QuizModelOptions option = options[i]!;
      String reason = "";
      if (quiz.reason != null && quiz.reason!.isNotEmpty) {
        reason = quiz.reason ?? "";
      } else {
        if (option.isAnswer ?? true) {
          reason = "正确";
        } else {
          reason = "错误";
        }
      }

      showQuizList.add(QuizModel(
        reason: reason,
        uid: quiz.uid,
        type: quiz.type,
        config: quiz.config,
        purpose: quiz.purpose,
        estimatedTime: quiz.estimatedTime,
        stems: [stem],
        options: [option],
      ));
    }

    return true;
  }

  Future<void> changeErrorCount(int value) async {
    try {
      ToastUtils.showLoading();
      bool res = await getQuizList(value);
      if (res) {
        errorCountNumber.value = value;
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> toDemonstrate() async {
    if (quizList.isEmpty) return;
    TagRoutes.toNamed(
      Routes.PRACTICE_QUESTIONS,
      arguments: {
        "quizDatas": quizList.toList(),
      },
    );
  }

  Future<void> addQuiz([bool isContinue = false]) async {
    if (unitKnowledgeList == null) return;
    if (quizList.isEmpty) return;

    try {
      ToastUtils.showLoading();
      for (int i = 0; i < quizList.length; i++) {
        await ManageSelectQuziKnowledge.addRequest(
          quiz: quizList[i],
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
      Get.find<ManageSelectQuziKnowledgeController>().getLessonQuizList();
    } finally {
      ToastUtils.hideLoading();
    }

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
