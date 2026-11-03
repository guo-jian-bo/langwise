import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_play/quiz_play.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/https/https.dart';
import '../../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/manage_ai_queue_controller.dart';
import '../../../../common/manage_quiz_create_type.dart';
import '../../../../dialog/manage_quiz_contrast_cloze_manual_dialog.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';
import '../../../../utils/manage_page_registry.dart';

class ManageQuizContrastClozeController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageQuizContrastClozeController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_QUIZ_CONTRAST_CLOZE;

  @override
  String get breadcrumbTitle => '对比填空';

  List<ManageUnitKnowledgeEntity>? unitKnowledgeList;
  ManageLessonQuizTemplateEntity? lessonQuizTemplate;
  int? unitId;
  int? difficultyMin;
  int? difficultyMax;
  String? language;
  int? lessonId;

  final RxList<CreateQuizAiTypeEntity> createTypeList = <CreateQuizAiTypeEntity>[].obs;
  final RxList<QuizModel> quizList = <QuizModel>[].obs;
  final RxInt selectQuizIndex = (-1).obs;
  final RxInt selectCreateTypeIndex = (-1).obs;

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
      getCreateTypeList();
    }
  }

  Future<void> getQuizList() async {
    List<Map<String, dynamic>> contentInfo = [];
    if (unitKnowledgeList != null) {
      for (int i = 0; i < unitKnowledgeList!.length; i++) {
        contentInfo.add({
          "contentType": unitKnowledgeList![i].contentType,
          "contentId": unitKnowledgeList![i].contentId,
          "semanticId": unitKnowledgeList![i].semanticId,
          "content": unitKnowledgeList![i].content,
        });
      }
    }

    Map<String, dynamic> data = {
      "contentInfos": contentInfo,
      "type": lessonQuizTemplate?.exerciseType,
      "config": lessonQuizTemplate?.config?.toJson(),
    };
    List<QuizModel>? resQuizList = await ManageSelectQuziKnowledge.getExerciseList(data);
    if (resQuizList == null) return;
    quizList.value = resQuizList;
  }

  Future<void> getCreateTypeList() async {
    if (lessonQuizTemplate?.exerciseType == null) return;
    List<CreateQuizAiTypeEntity>? res = await ManageSelectQuziKnowledge.getCreateQuizAiTypeList(lessonQuizTemplate!.exerciseType!);
    if (res == null) return;
    createTypeList.value = res;
  }

  void selectQuiz(int index) {
    if (selectCreateTypeIndex.value != -1) {
      selectCreateTypeIndex.value = -1;
    }
    selectQuizIndex.value = index;
  }

  void selectCreateType(int index) {
    if (selectQuizIndex.value != -1) {
      selectQuizIndex.value = -1;
    }
    selectCreateTypeIndex.value = index;
  }

  Future<void> nextButton(BuildContext context) async {
    if (unitKnowledgeList == null) return;
    if (selectCreateTypeIndex.value == -1 && selectQuizIndex.value == -1) {
      return ToastUtils.showManageToast(text: "请选择已有题目或新建题目方式");
    }
    List<Map<String, dynamic>> argumentsKnowledgeList = [];
    for (int i = 0; i < unitKnowledgeList!.length; i++) {
      argumentsKnowledgeList.add(unitKnowledgeList![i].toJson());
    }

    if (selectQuizIndex.value != -1) {
      await ManagePageRegistry.jumpTo(
        Routes.MANAGE_QUIZ_GENERAL,
        arguments: {
          "quizId": quizList[selectQuizIndex.value].uid,
          "isManualCreation": true,
          "manualQuizData": quizList[selectQuizIndex.value].toJson(),
          "lessonQuizTemplate": lessonQuizTemplate?.toJson(),
          "unitId": unitId,
          "knowledgeList": argumentsKnowledgeList,
          "difficultyMin": difficultyMin,
          "difficultyMax": difficultyMax,
          "language": language,
          "lessonId": lessonId,
        },
      );
      return;
    }

    String code = createTypeList[selectCreateTypeIndex.value].code ?? "";

    if (code == ManageQuizCreateType.CONTRAST_CLOZE_manual_creation ||
        code == ManageQuizCreateType.SENTENCE_CLOZE_manual_creation) {
      List<int?> quantityScope = lessonQuizTemplate?.template?.optionQuantityScope ?? [];
      quantityScope.removeWhere((e) => e == null);
      int minOption = quantityScope.reduce((a, b) => a! < b! ? a : b) ?? 2;
      int maxOption = quantityScope.reduce((a, b) => a! > b! ? a : b) ?? 4;
      List<QuizContrastClozeManualResult>? res = await ManageQuizContrastClozeManualDialog.show(
        context: context,
        knowledgeList: unitKnowledgeList!,
        minOption: minOption,
        maxOption: maxOption,
      );
      if (res == null) return;
      QuizModel manualQuizData = QuizModel.fromJson(lessonQuizTemplate!.exercise!.toJson());
      List<QuizModelStems> stems = [];
      List<QuizModelOptions> options = [];
      for (int i = 0; i < res.length; i++) {
        stems.add(QuizModelStems(
          text: res[i].text,
          imageUrl: res[i].image,
          audioUrl: res[i].audio,
          textAss: res[i].textAss,
        ));
        options.addAll(res[i].options);
      }
      manualQuizData.stems = stems;
      manualQuizData.options = options;

      await ManagePageRegistry.jumpTo(
        Routes.MANAGE_QUIZ_GENERAL,
        arguments: {
          "isManualCreation": true,
          "manualQuizData": manualQuizData.toJson(),
          "lessonQuizTemplate": lessonQuizTemplate?.toJson(),
          "unitId": unitId,
          "knowledgeList": argumentsKnowledgeList,
          "difficultyMin": difficultyMin,
          "difficultyMax": difficultyMax,
          "language": language,
          "lessonId": lessonId,
        },
      );
    } else if (code == ManageQuizCreateType.CONTRAST_CLOZE_automatically_generate ||
        code == ManageQuizCreateType.SENTENCE_CLOZE_automatically_generate) {
      try {
        ToastUtils.showLoading();
        bool res = await ManageSelectQuziKnowledge.requestAiPreviewQuizList(
          unitKnowledgeList,
          lessonQuizTemplate?.config,
          lessonQuizTemplate?.exerciseType,
          difficultyMin,
          difficultyMax,
          code,
          unitId,
          lessonId,
          lessonQuizTemplate?.template?.uid,
        );
        if (!res) return;
        ToastUtils.showManageToast(text: "提交成功");
        Get.find<ManageAiQueueController>().getQueueList(lessonId);
        Get.back();
      } finally {
        ToastUtils.hideLoading();
      }
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
