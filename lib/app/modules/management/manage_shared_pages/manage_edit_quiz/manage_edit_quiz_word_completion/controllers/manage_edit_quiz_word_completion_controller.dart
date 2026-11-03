import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_title_check_text_widget.dart';
import 'package:langwise/app/modules/management/models/manage_edit_quiz_model.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/entities/manage_quiz_template_entity.dart';
import 'package:langwise/common/https/manage_select_quzi_knowledge.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:quiz_play/models/quiz_model.dart';

import '../../../../../../routes/routes.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';
import '../../../../controllers/manage_setting_controller.dart';
import 'package:langwise/common/enum/enum.dart';

class ManageEditQuizWordCompletionController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageEditQuizWordCompletionController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_EDIT_QUIZ_WORD_COMPLETION;

  @override
  String get breadcrumbTitle => '编辑单词补全';

  int? quizId;

  Rx<QuizModel> quizData = QuizModel().obs;
  ManageQuizTemplateEntityTemplate? template;

  int minOption = 1;
  int maxOption = 4;

  List<ManageTitleCheckTextEntity> wordTextList = [];
  final TextEditingController answerController = TextEditingController();

  List<String> answerList = [];
  List<List<int>> answerPositionsList = [];
  List<TextEditingController> optionList = [];
  List<bool> optionErr = [];

  final GlobalKey dialogKey = GlobalKey();
  bool answerErr = false;

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

      minOption = template?.optionsLen?.min ?? 2;
      maxOption = template?.optionsLen?.max ?? 4;

      answerList = [];
      for (QuizModelOptions? option in quizModel.options ?? []) {
        if (option?.positions != null) {
          answerList.add(option?.text ?? "");
        } else {
          optionList.add(TextEditingController(text: option?.text ?? ""));
          optionErr.add(false);
        }
      }

      answerController.text = answerList.join(",");

      List<int> positions = [];
      String contentStr = quizModel.stems?.first?.text ?? "";
      for (int i = 0; i < answerList.length; i++) {
        String answer = answerList[i];
        final reg = RegExp('\\{\\{\\s*${i + 1}\\s*\\}\\}');
        final matches = reg.allMatches(contentStr);
        int start = matches.first.start;

        List<int> positionCopy = [];
        for (var j = 0; j < answer.length; j++) {
          positions.add(start + j);
          positionCopy.add(start + j);
        }
        answerPositionsList.add(positionCopy);
        contentStr = contentStr.replaceAll(reg, answer);
      }
      for (int i = 0; i < contentStr.length; i++) {
        if (positions.contains(i)) {
          wordTextList.add(ManageTitleCheckTextEntity(text: contentStr[i], seelcted: true));
        } else {
          wordTextList.add(ManageTitleCheckTextEntity(text: contentStr[i]));
        }
      }

      update();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void selectItem(int index) {
    answerList.clear();
    answerPositionsList.clear();

    wordTextList[index].seelcted = !wordTextList[index].seelcted;

    String answer = "";
    List<int> positions = [];
    for (int i = 0; i < wordTextList.length; i++) {
      if (wordTextList[i].seelcted) {
        answer += wordTextList[i].text;
        positions.add(i);

        if (i < wordTextList.length - 1) {
          if (!wordTextList[i + 1].seelcted) {
            List<int> positionCopy = List.from(positions);
            answerList.add(answer);
            answerPositionsList.add(positionCopy);

            answer = "";
            positions.clear();
          }
        } else {
          List<int> positionCopy = List.from(positions);
          answerList.add(answer);
          answerPositionsList.add(positionCopy);
        }
      }
    }
    answerController.text = answerList.join(",");
    update();
  }

  void saveQuiz() async {
    if (answerList.isEmpty) {
      ToastUtils.showManageToast(text: "请选择答案位置", containerKey: dialogKey);
      answerErr = true;
      update();
      Future.delayed(const Duration(seconds: 3), () {
        answerErr = false;
        update();
      });
      return;
    }

    List<Map<String, dynamic>> optionStrList = [];
    for (int i = 0; i < optionList.length; i++) {
      if (optionList[i].text.isEmpty) {
        ToastUtils.showManageToast(text: "请输入选项", containerKey: dialogKey);
        optionErr[i] = true;
        update();
        Future.delayed(const Duration(seconds: 3), () {
          optionErr[i] = false;
          update();
        });
        return;
      }

      optionStrList.add({'text': optionList[i].text});
    }

    String contentStr = "";
    for (int i = 0; i < wordTextList.length; i++) {
      contentStr += wordTextList[i].text;
    }

    for (int i = answerList.length - 1; i >= 0; i--) {
      String answer = answerList[i];
      List<int> positions = answerPositionsList[i];
      contentStr = contentStr.replaceRange(positions.first, positions.last + 1, '{{${i + 1}}}');
      optionStrList.insert(0, {
        'text': answer,
        'positions': [i + 1],
      });
    }

    Map<String, dynamic> data = {
      'stems': [
        {'text': contentStr}
      ],
      'options': optionStrList,
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
