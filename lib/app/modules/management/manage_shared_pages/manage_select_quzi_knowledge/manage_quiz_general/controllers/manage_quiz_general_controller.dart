import 'package:get/get.dart';
import 'package:quiz_play/models/models.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/https/https.dart';
import '../../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../routes/tag_routes.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';
import '../../controllers/manage_select_quzi_knowledge_controller.dart';

class ManageQuizGeneralController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageQuizGeneralController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_QUIZ_GENERAL;

  @override
  String get breadcrumbTitle => '题目预览';

  /// 上个页面传进来的知识点
  List<ManageUnitKnowledgeEntity>? unitKnowledgeList;

  /// 上个页面传进来的题目模版
  ManageLessonQuizTemplateEntity? lessonQuizTemplate;
  int? unitId;
  String? aiCode;
  int? difficultyMin;
  int? difficultyMax;
  String? language;
  int? lessonId;
  bool isManualCreation = false;
  int? quizId;

  final RxList<QuizModel> quizList = <QuizModel>[].obs;

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
      aiCode = argumentsMap["code"];
      difficultyMin = argumentsMap["difficultyMin"];
      difficultyMax = argumentsMap["difficultyMax"];
      language = argumentsMap["language"];
      lessonId = argumentsMap["lessonId"];
      quizId = argumentsMap["quizId"];
      isManualCreation = argumentsMap["isManualCreation"] ?? false;
      if (isManualCreation) {
        Map<String, dynamic>? argumentsManualQuizData = argumentsMap['manualQuizData'];
        if (argumentsManualQuizData != null) {
          QuizModel manualQuizData = QuizModel.fromJson(argumentsManualQuizData);
          quizList.add(manualQuizData);
        }
      } else {
        getQuizList();
      }
    }
  }

  Future<void> getQuizList() async {
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
      "difficulty": {
        "min": difficultyMin,
        "max": difficultyMax,
      },
      "unitId": unitId,
      "lessonId": lessonId,
    };
    try {
      ToastUtils.showLoading();
      PreviewQuizEntity? previewQuizEntity = await ManageSelectQuziKnowledge.getAiPreviewQuizList(reqData);
      if (previewQuizEntity == null) return;
      List<QuizModel?>? resList = previewQuizEntity.list;
      if (resList == null) return;
      List<QuizModel> resQuizList = [];
      for (int i = 0; i < resList.length; i++) {
        if (resList[i] == null) continue;
        resQuizList.add(resList[i]!);
      }
      quizList.value = resQuizList;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 体验本题
  Future<void> toDemonstrate() async {
    if (quizList.isEmpty) return;
    TagRoutes.toNamed(
      Routes.PRACTICE_QUESTIONS,
      arguments: {
        "quizDatas": quizList.toList(),
      },
    );
  }

  /// 保存
  Future<void> addQuiz([bool isContinue = false]) async {
    if (unitKnowledgeList == null) return;
    if (quizList.isEmpty) return;
    QuizModel quiz = quizList.first;

    try {
      ToastUtils.showLoading();
      bool res = await ManageSelectQuziKnowledge.addRequest(
        quiz: quiz,
        unitKnowledgeList: unitKnowledgeList,
        aiCode: aiCode,
        difficultyMin: difficultyMin,
        difficultyMax: difficultyMax,
        language: language,
        lessonId: lessonId,
        quizId: quizId,
        configId: lessonQuizTemplate?.config?.uid,
      );
      if (!res) return;

      bool initialized = Get.isRegistered<ManageSelectQuziKnowledgeController>();
      if (!initialized) return;
      Get.find<ManageSelectQuziKnowledgeController>().getLessonQuizList();
    } catch (e) {
      return;
    } finally {
      ToastUtils.hideLoading();
    }

    await Future.delayed(const Duration(milliseconds: 150));

    if (isContinue) {
      // 返回到选择知识点页面继续创建
      Get.back(result: {'action': 'continue'});
    } else {
      // 返回到题目列表页面
      Get.back(result: {'action': 'finish', 'lessonId': lessonId});
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
