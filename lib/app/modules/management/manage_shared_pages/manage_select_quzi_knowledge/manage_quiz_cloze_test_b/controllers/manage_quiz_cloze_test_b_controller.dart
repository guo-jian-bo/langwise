import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_play/models/models.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/https/https.dart';
import '../../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/manage_quiz_create_type.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';
import '../../../../utils/manage_page_registry.dart';

class ManageQuizClozeTestBController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageQuizClozeTestBController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_QUIZ_CLOZE_TEST_B;

  @override
  String get breadcrumbTitle => '完形填空B';

  List<ManageUnitKnowledgeEntity>? unitKnowledgeList;
  ManageLessonQuizTemplateEntity? lessonQuizTemplate;
  int? unitId;
  int? difficultyMin;
  int? difficultyMax;
  String? language;
  int? lessonId;

  final RxList<CreateQuizAiTypeEntity> createTypeList = <CreateQuizAiTypeEntity>[].obs;
  final RxInt selectQuizIndex = (-1).obs;
  final RxInt selectCreateTypeIndex = (-1).obs;
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

    if (unitKnowledgeList == null || unitKnowledgeList!.isEmpty) {
      return ToastUtils.showManageToast(text: "知识点为空");
    }
    String code = createTypeList[index].code ?? "";
    if (code == ManageQuizCreateType.CLOZE_TEST_B_cloze_test_b_text) {
      if (unitKnowledgeList!.length != 1 && !(unitKnowledgeList!.first.isEnText)) {
        return ToastUtils.showManageToast(text: "此方式只支持文章");
      }
    }
    if (code == ManageQuizCreateType.CLOZE_TEST_B_knowledge_generation) {
      if ((unitKnowledgeList!.first.isEnText)) {
        return ToastUtils.showManageToast(text: "此方式不支持文章");
      }
    }

    selectCreateTypeIndex.value = index;
  }

  Future<void> nextButton(BuildContext context) async {
    if (unitKnowledgeList?.first.content == null || unitKnowledgeList?.first.content == "") return;
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
    if (unitKnowledgeList == null || unitKnowledgeList!.isEmpty) return;
    if (code == ManageQuizCreateType.CLOZE_TEST_B_knowledge_generation || code == ManageQuizCreateType.CLOZE_TEST_B_cloze_test_b_text) {
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
