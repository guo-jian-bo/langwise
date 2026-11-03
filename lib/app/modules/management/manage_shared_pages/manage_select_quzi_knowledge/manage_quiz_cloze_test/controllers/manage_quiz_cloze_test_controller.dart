import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_play/models/models.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/https/https.dart';
import '../../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/manage_ai_queue_controller.dart';
import '../../../../common/manage_quiz_create_type.dart';
import '../../../../dialog/manage_quiz_cloze_test_manual_dialog.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';
import '../../../../utils/manage_page_registry.dart';

class ManageQuizClozeTestController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageQuizClozeTestController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_QUIZ_CLOZE_TEST;

  @override
  String get breadcrumbTitle => '完形填空';

  /// 上个页面传进来的知识点
  List<ManageUnitKnowledgeEntity>? unitKnowledgeList;

  /// 上个页面传进来的题目模版
  ManageLessonQuizTemplateEntity? lessonQuizTemplate;
  int? unitId;
  int? difficultyMin;
  int? difficultyMax;
  String? language;
  int? lessonId;

  final RxList<CreateQuizAiTypeEntity> createTypeList = <CreateQuizAiTypeEntity>[].obs;

  /// 选择的题目
  final RxInt selectQuizIndex = (-1).obs;

  /// 选择新建题目
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
    if (code == ManageQuizCreateType.CLOZE_TEST_article_generation) {
      if (unitKnowledgeList!.length != 1 && !(unitKnowledgeList!.first.isEnText)) {
        return ToastUtils.showManageToast(text: "此方式只支持文章");
      }
    }
    if (code == ManageQuizCreateType.CLOZE_TEST_knowledge_generation) {
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
      //选择的已有题目
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
    // 选择的新建
    if (code == ManageQuizCreateType.CLOZE_TEST_manual_creation) {
      if (unitKnowledgeList!.length != 1) {
        ToastUtils.showManageToast(text: " ${createTypeList[selectCreateTypeIndex.value].name} 只支持一个知识点");
        return;
      }
      if (!unitKnowledgeList!.first.isEnSentence && !unitKnowledgeList!.first.isEnText) {
        ToastUtils.showManageToast(text: " ${createTypeList[selectCreateTypeIndex.value].name} 只支持文本和句子");
        return;
      }

      List<int?> quantityScope = lessonQuizTemplate?.template?.optionQuantityScope ?? [];
      quantityScope.removeWhere((e) => e == null);
      int minOption = quantityScope.reduce((a, b) => a! < b! ? a : b) ?? 2;
      int maxOption = quantityScope.reduce((a, b) => a! > b! ? a : b) ?? 4;

      // 手动创建
      QuizClozeTestManualResult? res = await ManageQuizClozeTestManualDialog.show(
        context: context,
        content: unitKnowledgeList!.first.content!,
        minOption: minOption,
        maxOption: maxOption,
      );
      if (res == null) return;
      if (lessonQuizTemplate?.exercise == null) return;
      QuizModel manualQuizData = QuizModel.fromJson(lessonQuizTemplate!.exercise!.toJson());
      manualQuizData.stems?.first?.text = res.text;
      manualQuizData.stems?.first?.imageUrl = unitKnowledgeList!.first.imageUrl;
      manualQuizData.stems?.first?.audioUrl = unitKnowledgeList!.first.audioUrl;
      manualQuizData.stems?.first?.textAss = unitKnowledgeList!.first.sentenceAssList?.first;

      manualQuizData.options = res.options;

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
    } else if (code == ManageQuizCreateType.CLOZE_TEST_article_generation || code == ManageQuizCreateType.CLOZE_TEST_knowledge_generation) {
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
