import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_title_check_text_widget.dart';
import 'package:langwise/app/modules/management/common/manage_select_knowledge_table/view.dart';
import 'package:langwise/app/modules/management/models/manage_edit_quiz_model.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/entities/en_word_entity.dart';
import 'package:langwise/common/entities/manage_quiz_template_entity.dart';
import 'package:langwise/common/https/manage_select_quzi_knowledge.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:quiz_play/models/quiz_model.dart';

import '../../../../../../routes/routes.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';
import '../../../../controllers/manage_setting_controller.dart';
import 'package:langwise/common/enum/enum.dart';

class ManageEditQuizListenFindWordController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageEditQuizListenFindWordController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_EDIT_QUIZ_LISTEN_FIND_WORD;

  @override
  String get breadcrumbTitle => '编辑听音找词';

  int? quizId;

  Rx<QuizModel> quizData = QuizModel().obs;
  ManageQuizTemplateEntityTemplate? template;

  String? knowledgeText;

  List<ManageTitleCheckTextEntity> wordTextList = [];
  final TextEditingController answerController = TextEditingController();

  final GlobalKey dialogKey = GlobalKey();
  bool answerErr = false;
  List<Map<String, dynamic>> contentList = [];

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

      for (var element in quizModel.contentList ?? []) {
        contentList.add({
          "uid": element.uid,
          "type": element.type,
          "semanticId": element.semanticId,
        });
      }

      for (var element in quizModel.options ?? []) {
        answerController.text = element?.text ?? "";
      }

      String stemStr = quizModel.stems?.first?.text ?? "";
      knowledgeText = stemStr;
      List<String> knowTextList = knowledgeText!.split(" ");
      for (int i = 0; i < knowTextList.length; i++) {
        wordTextList.add(ManageTitleCheckTextEntity(text: knowTextList[i]));
        if (knowTextList[i].contains(answerController.text)) {
          wordTextList[i].seelcted = true;
        } else {
          wordTextList[i].seelcted = false;
        }
      }

      update();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void selectItem(int index, context) async {
    for (int i = 0; i < wordTextList.length; i++) {
      if (i == index) {
        wordTextList[i].seelcted = true;
      } else {
        wordTextList[i].seelcted = false;
      }
    }
    String text = wordTextList[index].text;
    final isPunctuation = RegExp(r'[,.!?;，。！？；]$').hasMatch(text[text.length - 1]);
    if (isPunctuation) {
      text = text.substring(0, text.length - 1);
    }

    var value = await ManageSelectKnowledgeTableManager.show(
      context: context,
      defaultDessert: [],
      language: 'en',
      showSelectKnowledgeAddButton: false,
      word: text,
      searchContent: text,
      singleSelectionMode: true,
      hidePhrase: true,
      hideSentence: true,
      hideText: true,
    );
    if (value != null && value.isNotEmpty) {
      for (int i = 0; i < value.length; i++) {
        final entity = value[i];
        if (entity is EnWordEntity) {
          contentList.removeWhere((element) => element["type"] == "EN_WORD");
          contentList.add({
            "uid": entity.uid,
            "type": entity.contentType,
            "semanticId": entity.semanticIds?.first,
          });
        }
      }
    } else {
      return;
    }

    answerController.text = text;
    update();
  }

  void saveQuiz() async {
    if (answerController.text.isEmpty) {
      ToastUtils.showManageToast(text: "请选择答案位置", containerKey: dialogKey);
      answerErr = true;
      update();
      Future.delayed(const Duration(seconds: 3), () {
        answerErr = false;
        update();
      });
      return;
    }

    Map<String, dynamic> data = {
      "contentList": contentList,
      "options": [
        {
          "text": answerController.text,
        }
      ],
      'exerciseId': quizId,
      'type': quizData.value.type,
    };

    try {
      ToastUtils.showLoading();

      ManageSelectQuziKnowledge.saveEditQuiz(data).then((value) {
        if (value == true) {
          ToastUtils.showManageToast(text: '编辑成功');
          Get.back(result: {'refresh': true});
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
      final String? style = ManageSettingController.to.defaultStyle.value.style;
      List<QuizModel>? resQuizList = await ManageSelectQuziKnowledge.getQuizListByIds(
        [quizId!],
        mediaMode: mediaMode,
        styleCodes: (style != null && style.isNotEmpty) ? [style] : null,
      );
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
