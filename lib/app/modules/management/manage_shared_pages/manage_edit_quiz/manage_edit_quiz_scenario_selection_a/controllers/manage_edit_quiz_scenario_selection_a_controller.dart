import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/models/manage_edit_quiz_model.dart';
import 'package:langwise/app/modules/management/dialog/manage_edit_quiz_option_interpretation_dialog.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/entities/manage_quiz_template_entity.dart';
import 'package:langwise/common/https/manage_select_quzi_knowledge.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:quiz_play/models/quiz_model.dart';

import '../../../../../../routes/routes.dart';
import '../../../../../../routes/tag_routes.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';
import '../../../../utils/manage_page_registry.dart';
import '../../../../controllers/manage_setting_controller.dart';
import 'package:langwise/common/enum/enum.dart';

class ManageEditQuizScenarioSelectionAController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageEditQuizScenarioSelectionAController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_EDIT_QUIZ_SCENARIO_SELECTION_A;

  @override
  String get breadcrumbTitle => '编辑情景选择A';

  int? quizId;
  bool? needBack;

  Rx<QuizModel> quizData = QuizModel().obs;
  ManageQuizTemplateEntityTemplate? template;
  List<QuizModelQuestions?> questionList = [];
  List<bool> unfoldList = [];
  List<QuizModelContentList?> contentList = [];

  final TextEditingController textController = TextEditingController();
  final FocusNode textFocusNode = FocusNode();

  bool showInsertButton = false;

  List<TextEditingController> questionTextFieldList = [];
  List<List<TextEditingController>> optionTextFieldList = [];

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    quizId = Get.arguments["quizId"];
    needBack = Get.arguments["needBack"];

    getQuizData();
    textController.addListener(_handleControllerChange);
    textFocusNode.addListener(_handleFocusChange);
  }

  @override
  void onClose() {
    super.onClose();
    textController.removeListener(_handleControllerChange);
    textFocusNode.removeListener(_handleFocusChange);
    for (var subList in optionTextFieldList) {
      for (var textController in subList) {
        textController.dispose();
      }
    }
    for (var textController in questionTextFieldList) {
      textController.dispose();
    }
  }

  void _handleFocusChange() {
    if (textFocusNode.hasFocus) {
      debugPrint('TextField获得焦点');
      showInsertButton = true;
    } else {
      debugPrint('TextField失去焦点');
      showInsertButton = false;
    }
    update();
  }

  void _handleControllerChange() {
    final sel = textController.selection;

    if (sel.isCollapsed) {
      showInsertButton = true;
    } else {
      showInsertButton = false;
    }
    update();
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

      textController.text = quizData.value.stems?.first?.text ?? '';
      contentList = quizData.value.contentList ?? [];
      questionList = quizData.value.questions ?? [];
      questionList.sort((a, b) => (a?.position ?? 0).compareTo(b?.position ?? 0));
      optionTextFieldList = [];
      unfoldList = [];
      for (var question in questionList) {
        List<TextEditingController> subList = [];
        for (var option in question?.options ?? []) {
          subList.add(TextEditingController(text: option?.text ?? ''));
        }
        optionTextFieldList.add(subList);
        questionTextFieldList.add(TextEditingController(text: question?.question ?? ''));
        unfoldList.add(true);

        if ((question?.explanation?.length ?? 0) < 2) {
          bool isEn = false;
          bool isZh = false;
          for (var element in question?.explanation ?? []) {
            element.text = element.text ?? '';
            if (element.lang == 'en') {
              isEn = true;
            }
            if (element.lang == 'zh') {
              isZh = true;
            }
          }
          if (!isEn) {
            question?.explanation?.add(
              QuizModelOptionsExplanation(
                text: '',
                lang: 'en',
              ),
            );
          }
          if (!isZh) {
            question?.explanation?.add(
              QuizModelOptionsExplanation(
                text: '',
                lang: 'zh',
              ),
            );
          }
        }
      }

      update();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void insertNewQuestion() async {
    if ((template?.questionsLen?.max ?? 0) <= questionList.length) {
      ToastUtils.showManageToast(text: '问题数量已达到最大${template?.questionsLen?.max ?? 0}个');
      update();
      return;
    }

    int offset = textController.selection.baseOffset;
    if (offset < 0) {
      offset = textController.text.length;
    }

    final prevPosition = getPrevPlaceholderBeforeSelStart(offset);
    final nextPosition = getNextPlaceholderAfterSelEnd(offset);
    final currentPosition = determineInsertPosition(prevPosition, nextPosition);

    for (var i = questionList.length - 1; i >= 0; i--) {
      var temp = questionList[i];
      if (i + 1 >= currentPosition) {
        temp?.position = i + 2;
        textController.text = textController.text.replaceFirst("{{${i + 1}}}", "{{${i + 2}}}");
      }
    }

    QuizModelQuestions newOption = QuizModelQuestions(
      question: '',
      options: [],
      position: currentPosition,
      explanation: [
        QuizModelOptionsExplanation(
          text: '',
          lang: 'en',
        ),
        QuizModelOptionsExplanation(
          text: '',
          lang: 'zh',
        ),
      ],
    );
    questionList.insert(currentPosition - 1, newOption);

    unfoldList.insert(currentPosition - 1, true);
    optionTextFieldList.insert(currentPosition - 1, []);
    questionTextFieldList.insert(currentPosition - 1, TextEditingController(text: ''));

    textController.text = textController.text.replaceRange(offset, offset, '{{$currentPosition}}');
    textController.selection = TextSelection.collapsed(offset: offset);

    showInsertButton = false;
    update();

    textFocusNode.requestFocus();
  }

  int determineInsertPosition(int? prev, int? next) {
    if (prev == null && next == null) return 1;
    if (next != null) return next;
    return (prev ?? 0) + 1;
  }

  int? getPrevPlaceholderBeforeSelStart(int start) {
    final text = textController.text;
    final regExp = RegExp(r'\{\{(\d+)\}\}');

    int? prev;
    for (final match in regExp.allMatches(text)) {
      if (match.end <= start) {
        prev = int.parse(match.group(1)!);
      } else {
        break;
      }
    }
    return prev;
  }

  int? getNextPlaceholderAfterSelEnd(int end) {
    final text = textController.text;
    final regExp = RegExp(r'\{\{(\d+)\}\}');

    for (final match in regExp.allMatches(text)) {
      if (match.start >= end) {
        return int.parse(match.group(1)!);
      }
    }
    return null;
  }

  String getSequence(int index) {
    final normalized = ((index % 26) + 26) % 26;
    final code = 'A'.codeUnitAt(0) + normalized;
    return String.fromCharCode(code);
  }

  void deleteAllOptions() async {
    final ask = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "确认要全部移除吗？",
      define: "继续删除",
      showCancel: true,
    );

    if (ask == false) {
      return;
    }

    for (var i = 0; i < questionList.length; i++) {
      textController.text = textController.text.replaceFirst("{{${i + 1}}}", '');
    }
    questionList.clear();
    for (var subList in optionTextFieldList) {
      for (final element in subList) {
        element.dispose();
      }
    }
    optionTextFieldList.clear();
    for (final element in questionTextFieldList) {
      element.dispose();
    }
    questionTextFieldList.clear();
    unfoldList.clear();
    update();
  }

  void deleteOptionFromPreview(int index) {
    textController.text = textController.text.replaceFirst("{{$index}}", '');
    questionList.removeAt(index - 1);
    for (final element in optionTextFieldList[index - 1]) {
      element.dispose();
    }
    optionTextFieldList.removeAt(index - 1);
    questionTextFieldList[index - 1].dispose();
    questionTextFieldList.removeAt(index - 1);
    for (var temp in questionList) {
      int pos = temp?.position ?? 0;
      if (pos > index) {
        temp?.position = pos - 1;
        textController.text = textController.text.replaceFirst("{{$pos}}", "{{${pos - 1}}}");
      }
    }
    unfoldList.removeAt(index - 1);
    update();
  }

  void deleteAnswer(int index) {
    textController.text = textController.text.replaceFirst("{{${index + 1}}}", '');
    questionList.removeAt(index);
    for (final element in optionTextFieldList[index]) {
      element.dispose();
    }
    optionTextFieldList.removeAt(index);
    questionTextFieldList[index].dispose();
    questionTextFieldList.removeAt(index);
    for (var temp in questionList) {
      int pos = temp?.position ?? 0;
      if (pos > index + 1) {
        temp?.position = pos - 1;
        textController.text = textController.text.replaceFirst("{{$pos}}", "{{${pos - 1}}}");
      }
    }
    unfoldList.removeAt(index);
    update();
  }

  void deleteOption(int questionIndex, int optionIndex) {
    QuizModelQuestions? question = questionList[questionIndex];
    if (question == null) return;
    question.options?.removeAt(optionIndex);
    optionTextFieldList[questionIndex].removeAt(optionIndex);
    update();
  }

  void addOption(int index) {
    QuizModelQuestions? question = questionList[index];
    if (question == null) return;
    question.options?.add(QuizModelQuestionsOptions(
      text: '',
      isAnswer: false,
    ));
    optionTextFieldList[index].add(TextEditingController());
    update();
  }

  void updateOptionIsAnswer(int questionIndex, int optionIndex, bool isAnswer) {
    QuizModelQuestions? question = questionList[questionIndex];
    if (question == null) return;
    if (isAnswer) {
      question.options?.forEach((element) {
        element?.isAnswer = false;
      });
    }
    question.options?[optionIndex]?.isAnswer = isAnswer;
    update();
  }

  void editAnswer(int index) async {
    QuizModelQuestions? deleteOption = questionList[index];
    List<QuizModelOptionsExplanation?>? result = await ManageEditQuizOptionInterpretationDialog.show(
      context: Get.context!,
      title: '问题${deleteOption?.position ?? 0}',
      explanationList: deleteOption?.explanation,
    );
    if (result == null) return;
    deleteOption?.explanation = result;
    update();
  }

  void saveChanges() {
    if ((template?.questionsLen?.min ?? 0) > questionList.length) {
      ToastUtils.showManageToast(text: '问题数量不能少于${template?.questionsLen?.min ?? 0}个');
      return;
    }

    bool isError = false;
    for (int i = 0; i < questionList.length; i++) {
      QuizModelQuestions? question = questionList[i];

      if (question?.question == null || question?.question.isBlank == true) {
        isError = true;
        ToastUtils.showManageToast(text: '问题${question?.position ?? 0}的题目为空，请补充完整再保存！');
        break;
      }

      if ((question?.options?.length ?? 0) < 3) {
        isError = true;
        ToastUtils.showManageToast(text: '问题${question?.position ?? 0}的选项少于3个，请补充完整再保存！');
        break;
      }

      bool haveSure = false;
      for (QuizModelQuestionsOptions? option in question?.options ?? []) {
        if (option?.text == null || option?.text.isBlank == true) {
          isError = true;
          ToastUtils.showManageToast(text: '问题${question?.position ?? 0}存在空选项，请补充完整再保存！');
          break;
        }
        if (option?.isAnswer == true) {
          haveSure = true;
        }
      }

      if (!haveSure) {
        isError = true;
        ToastUtils.showManageToast(text: '问题${question?.position ?? 0}未设置正确答案，请设置后再保存！');
        break;
      }

      for (QuizModelOptionsExplanation? explanation in question?.explanation ?? []) {
        if (explanation?.text == null || explanation?.text.isBlank == true) {
          isError = true;
          ToastUtils.showManageToast(text: '问题${question?.position ?? 0}的解析为空，请补充完整再保存！');
          break;
        }
      }
    }

    if (isError) {
      return;
    }

    Map<String, dynamic> data = {
      'contentList': contentList.map((content) => content!.toJson()).toList(),
      'stems': [
        {'text': textController.text}
      ],
      'questions': questionList.map((question) => question!.toJson()).toList(),
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
      final int mediaMode = ManageSettingController.to.defaultResources.value == ResourceTypeEnum.image ? 0 : 1;
      final String? style = ManageSettingController.to.defaultStyle.value.style;
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

  void navigateToManageArticleAudioPage() {
    if(quizData.value.stems == null) return;
    String? type = quizData.value.stems?.first?.content?.type; // 跳转至列表页面并搜索出来
    int? uid = quizData.value.stems?.first?.content?.uid;
    if(type == null || uid == null) return;
    if(type == "EN_TEXT"){
      ManagePageRegistry.jumpTo(
        Routes.MANAGE_ARTICLE,
        arguments: {
          "uid": uid,
        },
      );
    }else if(type == "EN_SONG"){
      ManagePageRegistry.jumpTo(
        Routes.MANAGE_SONG,
        arguments: {
          "uid": uid,
        },
      );
    }else if(type == "EN_REVEAL"){
      ManagePageRegistry.jumpTo(
        Routes.MANAGE_SUBSCRIBE_LISTCARD,
        arguments: {
          "uid": uid,
        },
      );
    }
  }
}
