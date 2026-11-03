import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/models/manage_edit_quiz_model.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/entities/manage_quiz_template_entity.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:quiz_play/models/quiz_model.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../routes/routes.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';

class ManageEditQuizLabelPictureController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageEditQuizLabelPictureController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_EDIT_QUIZ_LABEL_PICTURE;

  @override
  String get breadcrumbTitle => '编辑图片标注';

  int? quizId;
  bool? needBack;

  Rx<QuizModel> quizData = QuizModel().obs;
  ManageQuizTemplateEntityTemplate? template;

  String labelImageUrl = "";

  List<LabelPictureQuizModel> showKnowledgeList = [];

  final RxInt selectKnowledgeIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if (Get.arguments != null) {
      quizId = Get.arguments["quizId"];
      needBack = Get.arguments["needBack"];
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

      dealLabelPicture();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void dealLabelPicture() async {
    labelImageUrl = quizData.value.stems?.first?.imageUrl ?? '';

    for (var i = 0; i < (quizData.value.options?.length ?? 0); i++) {
      QuizModelOptions? option = quizData.value.options?[i];
      if (option == null) continue;
      Rect rect = Rect.fromLTWH(
        (option.boxs?[0] ?? 0) * 720.wMin,
        (option.boxs?[1] ?? 0) * 720.wMin,
        (option.boxs?[2] ?? 0) * 720.wMin,
        (option.boxs?[3] ?? 0) * 720.wMin,
      );

      showKnowledgeList.add(LabelPictureQuizModel(
        option: option,
        rect: rect,
        xPercent: option.boxs?[0] ?? 0,
        yPercent: option.boxs?[1] ?? 0,
        widthPercent: option.boxs?[2] ?? 0,
        heightPercent: option.boxs?[3] ?? 0,
      ));
    }
    update();
  }

  void drawBox(Rect rect, double size) {
    showKnowledgeList[selectKnowledgeIndex.value].rect = rect;

    double xPercent = (rect.left / size);
    double yPercent = (rect.top / size);
    double widthPercent = (rect.width / size);
    double heightPercent = (rect.height / size);

    showKnowledgeList[selectKnowledgeIndex.value].xPercent = xPercent;
    showKnowledgeList[selectKnowledgeIndex.value].yPercent = yPercent;
    showKnowledgeList[selectKnowledgeIndex.value].widthPercent = widthPercent;
    showKnowledgeList[selectKnowledgeIndex.value].heightPercent = heightPercent;

    update();
  }

  void clearAnnotation() {
    for (int j = 0; j < showKnowledgeList.length; j++) {
      showKnowledgeList[j].rect = Rect.zero;
      showKnowledgeList[j].xPercent = 0;
      showKnowledgeList[j].yPercent = 0;
      showKnowledgeList[j].widthPercent = 0;
      showKnowledgeList[j].heightPercent = 0;
    }

    update();
  }

  Future<void> reGenerate(BuildContext context) async {
    bool ask = await AskDialog.showUserAsk(
      context: context,
      title: "重新生成",
      content: "确定重新生成吗？",
    );
    if (!ask) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "exerciseId": quizId,
      };
      bool res = await ExerciseReviewRequest.reGenerate(reqData);
      if (!res) return;
      ToastUtils.showManageToast(text: "重新生成提交成功");
      Get.back(result: {'refresh': true});
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void changeSelectIndex(int index) {
    selectKnowledgeIndex.value = index;
  }

  void saveQuiz() async {
    List<Map<String, dynamic>> optionStrList = [];
    for (int i = 0; i < showKnowledgeList.length; i++) {
      if (showKnowledgeList[i].rect == Rect.zero) {
        selectKnowledgeIndex.value = i;
        ToastUtils.showManageToast(text: "请画 ${showKnowledgeList[i].option?.text ?? ''} 的框");
        return;
      } else {
        optionStrList.add({
          'text': showKnowledgeList[i].option?.text ?? '',
          'boxs': [
            showKnowledgeList[i].xPercent,
            showKnowledgeList[i].yPercent,
            showKnowledgeList[i].widthPercent,
            showKnowledgeList[i].heightPercent,
          ],
        });
      }
    }

    Map<String, dynamic> data = {
      'options': optionStrList,
      'exerciseId': quizId,
      'type': quizData.value.type,
    };

    try {
      ToastUtils.showLoading();

      ManageSelectQuziKnowledge.saveEditQuiz(data).then((value) {
        if (value == true) {
          ToastUtils.showManageToast(text: '编辑成功');
          if (needBack == true) {
            Get.back(result: {'refresh': true});
            Get.back(result: {'refresh': true});
          }
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
      List<QuizModel>? resQuizList = await ManageSelectQuziKnowledge.getQuizListByIds([quizId!]);
      if (resQuizList == null || resQuizList.isEmpty) return;
      quizModel = resQuizList.first;
      await Get.toNamed(
        Routes.PRACTICE_QUESTIONS,
        preventDuplicates: false,
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

class LabelPictureQuizModel {
  QuizModelOptions? option;
  Rect rect;
  double xPercent;
  double yPercent;
  double widthPercent;
  double heightPercent;
  LabelPictureQuizModel({
    this.option,
    this.rect = Rect.zero,
    this.xPercent = 0,
    this.yPercent = 0,
    this.widthPercent = 0,
    this.heightPercent = 0,
  });
}
