import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_play/models/models.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/https/https.dart';
import '../../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/manage_quiz_create_type.dart';
import '../../../../dialog/manage_quiz_classify_challenge_manual_dialog.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';
import '../../../../utils/manage_page_registry.dart';

class ManageQuizClassifyChallengeController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageQuizClassifyChallengeController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_QUIZ_CLASSIFY_CHALLENGE;

  @override
  String get breadcrumbTitle => '分类挑战';

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
    if (unitId == null) return;

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

    if (code == ManageQuizCreateType.CLASSIFY_CHALLENGE_manual_creation) {
      List<int?> quantityScope = lessonQuizTemplate?.template?.optionQuantityScope ?? [];
      quantityScope.removeWhere((e) => e == null);
      int minClass = quantityScope.reduce((a, b) => a! < b! ? a : b) ?? 2;
      int maxClass = quantityScope.reduce((a, b) => a! > b! ? a : b) ?? 4;

      List<QuizClassifyChallengRespData>? resKnows = await ManageQuizClassifyChallengeManualDialog.show(
        context: context,
        unitKnowledgeList: unitKnowledgeList!,
        minClass: minClass,
        maxClass: maxClass,
        unitId: unitId!,
        contentScope: lessonQuizTemplate?.template?.contentScope,
        language: language,
      );
      if (resKnows == null) return;

      QuizModel manualQuizData = QuizModel.fromJson(lessonQuizTemplate!.exercise!.toJson());
      List<QuizModelStems> stems = [];
      List<QuizModelOptions> options = [];
      for (int i = 0; i < resKnows.length; i++) {
        for (int j = 0; j < resKnows[i].classKnowList.length; j++) {
          stems.add(QuizModelStems(
            text: resKnows[i].classKnowList[j].content,
            imageUrl: resKnows[i].classKnowList[j].imageUrl,
            audioUrl: resKnows[i].classKnowList[j].audioUrl,
            category: resKnows[i].clessData.content,
            textAss: resKnows[i].clessData.sentenceAssList?.first,
          ));
        }
        options.add(QuizModelOptions(
          text: resKnows[i].clessData.content,
          imageUrl: resKnows[i].clessData.imageUrl,
          audioUrl: resKnows[i].clessData.audioUrl,
        ));
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
    } else if (code == ManageQuizCreateType.CLASSIFY_CHALLENGE_automatic_classification) {
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
