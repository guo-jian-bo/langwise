import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/dialog/manage_select_knowledge_dialog.dart';
import 'package:langwise/app/modules/management/dialog/manage_quiz_classify_challenge_manual_dialog.dart';
import 'package:langwise/app/modules/management/models/manage_edit_quiz_model.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/https/manage_select_quzi_knowledge.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:quiz_play/models/quiz_model.dart';

import 'package:langwise/common/entities/entities.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../routes/tag_routes.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';
import '../../../../controllers/manage_setting_controller.dart';
import 'package:langwise/common/enum/enum.dart';

class ManageEditQuizClassifyChallengeController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageEditQuizClassifyChallengeController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_EDIT_QUIZ_CLASSIFY_CHALLENGE;

  @override
  String get breadcrumbTitle => '编辑分类挑战';

  int? quizId;

  Rx<QuizModel> quizData = QuizModel().obs;
  ManageQuizTemplateEntityTemplate? template;

  List<ManageUnitKnowledgeEntity>? unitKnowledgeList = [];

  List<String?>? contentScope;
  int minClass = 2;
  int maxClass = 4;

  final GlobalKey dialogKey = GlobalKey();

  final List<int> selectKnowledgeIndexs = [];
  final List<int> selectUnIndexs = [];
  List<ManageQuizClassifyChallengeData> classList = [];

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if (Get.arguments != null) {
      quizId = Get.arguments["quizId"];
    }

    getQuizData();
  }

  Future<void> getQuizData() async {
    if (quizId == null) return;

    try {
      ToastUtils.showLoading();

      ManageEditQuizModel? editModel = await ManageSelectQuziKnowledge.getQuizListById(quizId!);
      QuizModel? quizModel = editModel?.exercise;
      if (quizModel == null) return;
      quizData.value = quizModel;
      template = editModel?.template;
      if (template == null) return;

      contentScope = template?.contentScope;
      minClass = template?.optionsLen?.min ?? 2;
      maxClass = template?.optionsLen?.max ?? 4;

      for (QuizModelOptions? option in quizModel.options ?? []) {
        ManageUnitKnowledgeEntity classModel = ManageUnitKnowledgeEntity(
          content: option?.text,
          contentId: option?.content?.uid,
          contentType: option?.content?.type,
          semanticId: option?.content?.semanticId,
        );
        classList.add(ManageQuizClassifyChallengeData(classData: classModel));
      }

      for (int i = 0; i < (quizModel.stems ?? []).length; i++) {
        QuizModelStems? option = quizModel.stems?[i];
        ManageUnitKnowledgeEntity knowledgeModel = ManageUnitKnowledgeEntity(
          content: option?.text,
          audioUrl: option?.audioUrl,
          imageUrl: option?.imageUrl,
          difficulty: CardContentDifficulty(
            min: option?.difficulty,
            max: option?.difficulty,
          ),
          definition: option?.gloss?.where((element) => element?.lang == 'zh').first?.text,
          contentId: option?.content?.uid,
          contentType: option?.content?.type,
          semanticId: option?.content?.semanticId,
        );
        unitKnowledgeList?.add(knowledgeModel);

        for (var element in classList) {
          if (option?.category == element.classData.content) {
            element.selectIndex.add(i);
            selectUnIndexs.add(i);
          }
        }
      }

      update();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void addSemantic(int index, context) async {
    List<ManageUnitKnowledgeEntity>? resList = await ManageSelectKnowledgeDialog.show(
      context: context,
      unitId: 1,
      knowledgeSingle: true,
      contentScope: contentScope,
      language: 'en',
      showHaveKnowledge: false,
      title: "选择分类名",
    );
    if (resList == null || resList.isEmpty) return;

    classList[index].classData = resList.first;
    update();
  }

  Future<void> addOption(context) async {
    if (classList.length >= maxClass) {
      ToastUtils.showManageToast(text: "最多可以添加$maxClass个分类");
      return;
    }

    List<ManageUnitKnowledgeEntity>? resList = await ManageSelectKnowledgeDialog.show(
      context: context,
      unitId: 1,
      knowledgeSingle: true,
      contentScope: contentScope,
      language: 'en',
      showHaveKnowledge: false,
      title: "选择分类名",
    );
    if (resList == null || resList.isEmpty) return;

    for (int i = 0; i < classList.length; i++) {
      if (classList[i].classData.uid == resList.first.uid) {
        ToastUtils.showManageToast(text: "分类已存在", containerKey: dialogKey);
        return;
      }
    }
    classList.insert(0, ManageQuizClassifyChallengeData(classData: resList.first));
    update();
  }

  Future<void> saveQuiz() async {
    if (classList.length < minClass) {
      return ToastUtils.showManageToast(text: "最少需要$minClass个分类");
    }

    List<Map<String, dynamic>> contentList = [];
    List<Map<String, dynamic>> categoryList = [];
    for (int i = 0; i < classList.length; i++) {
      ManageQuizClassifyChallengeData classModel = classList[i];
      if (classModel.selectIndex.isEmpty) {
        return ToastUtils.showManageToast(text: "请添加知识点到分类${classModel.classData.content}里面");
      }

      contentList.add({
        "uid": classModel.classData.contentId,
        "type": classModel.classData.contentType,
        "semanticId": classModel.classData.semanticId,
      });
      List<Map<String, dynamic>> knowledgePoints = [];
      for (var index in classModel.selectIndex) {
        ManageUnitKnowledgeEntity knowModel = unitKnowledgeList![index];
        knowledgePoints.add({
          "uid": knowModel.contentId,
          "text": knowModel.content,
        });

        contentList.add({
          "uid": knowModel.contentId,
          "type": knowModel.contentType,
          "semanticId": knowModel.semanticId,
        });
      }
      categoryList.add({
        "name": classModel.classData.content,
        "knowledge_points": knowledgePoints,
      });
    }

    Map<String, dynamic> data = {
      "contentList": contentList,
      "category": categoryList,
      'exerciseId': quizId,
      'type': quizData.value.type,
    };

    try {
      ToastUtils.showLoading();

      ManageSelectQuziKnowledge.saveEditQuiz(data).then((value) {
        if (value == true) {
          ToastUtils.showManageToast(text: '编辑成功');
        }
      });
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void showQuizEditResult() async {
    final ask = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "保存后，题型演示才能体验到您的新修改，是否继续？",
      define: "继续演示",
      showCancel: true,
    );

    if (ask == false) {
      return;
    }

    QuizModel quizModel;
    try {
      ToastUtils.showLoading();
      final int mediaMode = ManageSettingController.to.defaultResources.value == ResourceTypeEnum.image ? 0 : 1;
      final String? style = ManageSettingController.to.getCurrentStyleCode();
      List<QuizModel>? resQuizList = await ManageSelectQuziKnowledge.getQuizListByIds(
        [quizId!],
        mediaMode: mediaMode,
        styleCodes: (style != null && style.isNotEmpty) ? [style] : null,
      );
      if (resQuizList == null || resQuizList.isEmpty) return;
      quizModel = resQuizList.first;
      await TagRoutes.toNamed(
        Routes.PRACTICE_QUESTIONS,
        arguments: {
          "quizDatas": [quizModel],
          "isShowUpDownStatus": true,
        },
      );
    } finally {
      ToastUtils.hideLoading();
    }
  }
}
