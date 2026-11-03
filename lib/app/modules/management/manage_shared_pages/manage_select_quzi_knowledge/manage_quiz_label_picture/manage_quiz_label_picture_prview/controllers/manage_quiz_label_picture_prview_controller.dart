import 'package:get/get.dart';
import 'package:quiz_play/quiz_play.dart';

import '../../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../../common/https/https.dart';
import '../../../../../../../../../utils/utils.dart';
import '../../../../../../../routes/routes.dart';
import '../../../../manage_select_quzi_knowledge/controllers/manage_select_quzi_knowledge_controller.dart';
import '../../../../../utils/manage_breadcrumb_utils.dart';

class ManageQuizLabelPicturePrviewController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageQuizLabelPicturePrviewController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_QUIZ_LABEL_PICTURE_PRVIEW;

  @override
  String get breadcrumbTitle => '标注图片-预览';

  List<ManageUnitKnowledgeEntity>? unitKnowledgeList;
  int? unitId;
  int? difficultyMin;
  int? difficultyMax;
  String? language;
  int? lessonId;
  int? aiRecordId;
  String? aiCode;
  int? configId;

  RxList<QuizModel> quizList = <QuizModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    if (Get.arguments != null) {
      Map argumentsMap = Get.arguments;

      List<QuizModel>? quList = argumentsMap["quizList"];
      if (quList != null) {
        quizList.value = quList;
      }
      List<Map<String, dynamic>>? argumentsKnowledgeList = argumentsMap["knowledgeList"];
      if (argumentsKnowledgeList != null) {
        unitKnowledgeList = argumentsKnowledgeList.map((e) => ManageUnitKnowledgeEntity.fromJson(e)).toList();
      }
      unitId = argumentsMap["unitId"];
      difficultyMin = argumentsMap["difficultyMin"];
      difficultyMax = argumentsMap["difficultyMax"];
      aiRecordId = argumentsMap["aiRecordId"];
      language = argumentsMap["language"];
      aiCode = argumentsMap["aiCode"];
      configId = argumentsMap["configId"];
      lessonId = argumentsMap["lessonId"];
    }
  }

  Future<void> toDemonstrate() async {
    if ((quizList).isEmpty) return;
    Get.toNamed(
      Routes.PRACTICE_QUESTIONS,
      preventDuplicates: false,
      arguments: {
        "quizDatas": quizList.toList(),
      },
    );
  }

  Future<void> addQuiz() async {
    if (unitKnowledgeList == null) return;
    if (quizList.isEmpty) return;

    try {
      ToastUtils.showLoading();

      QuizModel saveQuiz = QuizModel();
      saveQuiz.type = quizList.first.type;
      saveQuiz.uid = quizList.first.uid;
      saveQuiz.purpose = quizList.first.purpose;
      saveQuiz.estimatedTime = quizList.first.estimatedTime;
      saveQuiz.reason = quizList.first.reason;
      saveQuiz.config = quizList.first.config;
      saveQuiz.questions = quizList.first.questions;
      saveQuiz.stems = [];
      saveQuiz.options = [];
      for (int i = 0; i < quizList.length; i++) {
        if (quizList[i].stems == null) continue;
        if (quizList[i].options == null) continue;
        saveQuiz.stems!.addAll(quizList[i].stems!);
        saveQuiz.options!.addAll(quizList[i].options!);
      }

      bool res = await ManageSelectQuziKnowledge.addRequest(
        quiz: saveQuiz,
        unitKnowledgeList: unitKnowledgeList,
        aiCode: aiCode,
        difficultyMin: difficultyMin,
        difficultyMax: difficultyMax,
        language: language,
        lessonId: lessonId,
        recordId: aiRecordId,
        configId: configId,
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

    ToastUtils.showManageToast(text: "保存成功");

    Get.back(result: {'action': 'saved'});
  }

  @override
  void onClose() {
    super.onClose();
  }
}
