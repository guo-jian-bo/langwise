import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_play/models/models.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/https/https.dart';
import '../../../../../../../../utils/toast_utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/manage_quiz_create_type.dart';
import '../../../../dialog/manage_select_knowledge_dialog.dart';
import '../../../../dialog/manage_quiz_single_choice_manual_dialog.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';
import '../../../../utils/manage_page_registry.dart';

class ManageQuizSingleChoiceController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageQuizSingleChoiceController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_QUIZ_SINGLE_CHOICE;

  @override
  String get breadcrumbTitle => '单项选择';

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

  final RxList<QuizModel> quizList = <QuizModel>[].obs;

  /// 选择的题目
  final RxInt selectQuizIndex = (-1).obs;

  /// 选择新建题目
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
    if ((unitKnowledgeList ?? []).isEmpty) return;
    if (unitKnowledgeList!.first.content == null) return;
    if (lessonQuizTemplate?.exerciseType == null) return;
    createTypeList.clear();
    List<CreateQuizAiTypeEntity>? res = await ManageSelectQuziKnowledge.getCreateQuizAiTypeList(lessonQuizTemplate!.exerciseType!);
    if (res == null) return;
    String contentScope = unitKnowledgeList?.first.contentType ?? "";
    for (int i = 0; i < res.length; i++) {
      if (res[i].contentScopes == null) continue;
      if (res[i].contentScopes!.contains(contentScope)) {
        createTypeList.add(res[i]);
      }
    }
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
    if ((unitKnowledgeList ?? []).isEmpty) return;
    if (unitKnowledgeList!.first.content == null) return;
    if (lessonQuizTemplate == null) return;
    if (lessonQuizTemplate!.exercise == null) return;
    if (unitId == null) return;
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

    // 选择的新建
    if (code == ManageQuizCreateType.SINGLE_CHOICE_EN_WORD_related_knowledge_points ||
        code == ManageQuizCreateType.SINGLE_CHOICE_EN_SENTENCE_related_knowledge_points) {
      // 选择的关联知识点
      List<int?> quantityScope = lessonQuizTemplate?.template?.optionQuantityScope ?? [];
      quantityScope.removeWhere((e) => e == null);
      int minOption = quantityScope.reduce((a, b) => a! < b! ? a : b) ?? 2;
      int maxOption = quantityScope.reduce((a, b) => a! > b! ? a : b) ?? 4;
      List<ManageUnitKnowledgeEntity>? res = await ManageSelectKnowledgeDialog.show(
        context: context,
        unitId: unitId!,
        knowledgeSingle: false,
        knowledgeMinSelect: minOption - 1,
        knowledgeMaxSelect: maxOption - 1,
        contentScope: lessonQuizTemplate?.template?.contentScope,
        unKnowledgeList: unitKnowledgeList,
        language: language,
      );
      if (res == null) return;

      QuizModel manualQuizData = QuizModel.fromJson(lessonQuizTemplate!.exercise!.toJson());
      manualQuizData.stems?.first?.text = unitKnowledgeList!.first.content;
      manualQuizData.stems?.first?.imageUrl = unitKnowledgeList!.first.imageUrl;
      manualQuizData.stems?.first?.audioUrl = unitKnowledgeList!.first.audioUrl;
      manualQuizData.stems?.first?.textAss = unitKnowledgeList!.first.sentenceAssList?.first;
      List<QuizModelOptions> options = [
        QuizModelOptions(
          text: unitKnowledgeList!.first.content,
          imageUrl: unitKnowledgeList!.first.imageUrl,
          audioUrl: unitKnowledgeList!.first.audioUrl,
          isAnswer: true,
        ),
      ];
      for (int i = 0; i < res.length; i++) {
        options.add(QuizModelOptions(
          text: res[i].content,
          imageUrl: res[i].imageUrl,
          audioUrl: res[i].audioUrl,
          isAnswer: false,
        ));
      }
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
    } else if (code == ManageQuizCreateType.SINGLE_CHOICE_EN_WORD_manual_creation ||
        code == ManageQuizCreateType.SINGLE_CHOICE_EN_SENTENCE_manual_creation) {
      List<int?> quantityScope = lessonQuizTemplate?.template?.optionQuantityScope ?? [];
      quantityScope.removeWhere((e) => e == null);
      int minOption = quantityScope.reduce((a, b) => a! < b! ? a : b) ?? 2;
      int maxOption = quantityScope.reduce((a, b) => a! > b! ? a : b) ?? 4;
      // 选择的手动创建
      QuizSingleChoiceManualResult? res = await ManageQuizSingleChoiceManualDialog.show(
        context: context,
        stemKnowledge: unitKnowledgeList!.first,
        minOption: minOption,
        maxOption: maxOption,
        unitId: unitId!,
        contentScope: lessonQuizTemplate?.template?.contentScope,
        language: language,
      );
      if (res == null) return;
      QuizModel manualQuizData = QuizModel.fromJson(lessonQuizTemplate!.exercise!.toJson());
      manualQuizData.stems?.first?.text = res.stem;
      manualQuizData.stems?.first?.imageUrl = unitKnowledgeList?.first.imageUrl;
      manualQuizData.stems?.first?.audioUrl = unitKnowledgeList?.first.audioUrl;
      manualQuizData.stems?.first?.textAss = unitKnowledgeList?.first.sentenceAssList?.first;

      List<QuizModelOptions> options = [
        QuizModelOptions(
          text: res.answer,
          isAnswer: true,
        ),
      ];
      for (int i = 0; i < res.options.length; i++) {
        options.add(QuizModelOptions(
          text: res.options[i],
          isAnswer: false,
        ));
      }
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
    } else if (code == ManageQuizCreateType.SINGLE_CHOICE_word_meaning ||
        code == ManageQuizCreateType.SINGLE_CHOICE_word_culture ||
        code == ManageQuizCreateType.SINGLE_CHOICE_sentence_grammar) {
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
