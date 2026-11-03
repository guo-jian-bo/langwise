import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_select_knowledge_table/view.dart';
import 'package:langwise/app/modules/management/dialog/manage_edit_quiz_option_interpretation_dialog.dart';
import 'package:langwise/app/modules/management/models/manage_edit_quiz_model.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/entities/en_phrase_entity.dart';
import 'package:langwise/common/entities/en_sentence_entity.dart';
import 'package:langwise/common/entities/en_word_entity.dart';
import 'package:langwise/common/entities/knowledge.dart';
import 'package:langwise/common/entities/manage_quiz_template_entity.dart';
import 'package:langwise/common/https/manage_select_quzi_knowledge.dart';
import 'package:langwise/common/stores/base_controller.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:quiz_play/models/quiz_model.dart';

import '../../../../../../routes/routes.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';
import '../../../../utils/manage_page_registry.dart';
import '../../../../controllers/manage_setting_controller.dart';
import 'package:langwise/common/enum/enum.dart';

class ManageEditQuizClozeTestAController extends BaseController with ManageBreadcrumbMixin {
  final String tag;
  ManageEditQuizClozeTestAController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_EDIT_QUIZ_CLOZE_TEST_A;

  @override
  String get breadcrumbTitle => '编辑完形填空A';

  int? quizId;
  bool? needBack;

  Rx<QuizModel> quizData = QuizModel().obs;
  ManageQuizTemplateEntityTemplate? template;
  List<QuizModelOptions?> optionList = [];

  final TextEditingController textController = TextEditingController();
  final FocusNode textFocusNode = FocusNode();

  String? selectedWord;
  int? selStart;
  int? selEnd;

  List<TextEditingController> optionTextFieldList = [];

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
    for (var controller in optionTextFieldList) {
      controller.dispose();
    }
  }

  void _handleFocusChange() {
    if (textFocusNode.hasFocus) {
      debugPrint('TextField获得焦点');
    } else {
      debugPrint('TextField失去焦点');
      selectedWord = null;
      selStart = null;
      selEnd = null;
      update();
    }
  }

  void _handleControllerChange() {
    final sel = textController.selection;
    final text = textController.text;

    if (sel.isCollapsed) {
      selectedWord = null;
      selStart = null;
      selEnd = null;
      update();
    } else {
      int start = sel.start;
      int end = sel.end;
      if (start < 0 || end > text.length) return;

      final candidate = text.substring(start, end);
      selectedWord = candidate;
      selStart = start;
      selEnd = end;
      textController.selection = TextSelection(baseOffset: start, extentOffset: end);
      update();
      return;
    }
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
      optionList = quizData.value.options ?? [];
      optionList.sort((a, b) => (a?.positions?.first ?? 0).compareTo(b?.positions?.first ?? 0));
      optionTextFieldList = [];
      for (var option in optionList) {
        optionTextFieldList.add(TextEditingController(text: option?.text ?? ''));
        for (var explanation in option?.explanation ?? []) {
          explanation.text = explanation.text ?? '';
        }

        if ((option?.explanation?.length ?? 0) < 2) {
          bool isEn = false;
          bool isZh = false;
          for (var element in option?.explanation ?? []) {
            element.text = element.text ?? '';
            if (element.lang == 'en') {
              isEn = true;
            }
            if (element.lang == 'zh') {
              isZh = true;
            }
          }
          if (!isEn) {
            option?.explanation?.add(
              QuizModelOptionsExplanation(
                text: '',
                lang: 'en',
              ),
            );
          }
          if (!isZh) {
            option?.explanation?.add(
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

  void replaceSelectedWord() async {
    if (selStart == null || selEnd == null) return;
    if ((template?.optionsLen?.max ?? 0) <= optionList.length) {
      ToastUtils.showManageToast(text: '选项数已达到最大${template?.optionsLen?.max ?? 0}个');
      selectedWord = null;
      selStart = null;
      selEnd = null;
      update();
      return;
    }

    final String word = selectedWord ?? '';
    final start = selStart!;
    final end = selEnd!;

    final prevPosition = getPrevPlaceholderBeforeSelStart(start);
    final nextPosition = getNextPlaceholderAfterSelEnd(end);
    final currentPosition = determineInsertPosition(prevPosition, nextPosition);

    for (var i = optionList.length - 1; i >= 0; i--) {
      var temp = optionList[i];
      if (i + 1 >= currentPosition) {
        temp?.positions?.first = i + 2;
        textController.text = textController.text.replaceFirst("{{${i + 1}}}", "{{${i + 2}}}");
      }
    }

    QuizModelOptions newOption = QuizModelOptions(
      text: word,
      positions: [currentPosition],
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

    optionList.insert(currentPosition - 1, newOption);

    optionTextFieldList.insert(currentPosition - 1, TextEditingController(text: word));
    textController.text = textController.text.replaceRange(start, end, '{{$currentPosition}}');
    textController.selection = TextSelection.collapsed(offset: start);
    selectedWord = null;
    selStart = null;
    selEnd = null;
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

    for (var i = 0; i < optionList.length; i++) {
      QuizModelOptions? deleteOption = optionList[i];
      textController.text = textController.text.replaceFirst("{{${i + 1}}}", deleteOption?.text ?? '');
    }
    optionList.clear();
    for (var controller in optionTextFieldList) {
      controller.dispose();
    }
    optionTextFieldList.clear();
    update();
  }

  void deleteOptionFromPreview(int index) {
    QuizModelOptions? deleteOption = optionList[index - 1];
    textController.text = textController.text.replaceFirst("{{$index}}", deleteOption?.text ?? '');
    optionList.removeAt(index - 1);
    optionTextFieldList[index - 1].dispose();
    optionTextFieldList.removeAt(index - 1);
    for (var temp in optionList) {
      int pos = temp?.positions?.first ?? 0;
      if (pos > index) {
        temp?.positions?.first = pos - 1;
        textController.text = textController.text.replaceFirst("{{$pos}}", "{{${pos - 1}}}");
      }
    }

    update();
  }

  void deleteOptionFromOptions(int index) {
    QuizModelOptions? deleteOption = optionList[index];
    textController.text = textController.text.replaceFirst("{{${index + 1}}}", deleteOption?.text ?? '');
    optionList.removeAt(index);
    optionTextFieldList[index].dispose();
    optionTextFieldList.removeAt(index);
    for (var temp in optionList) {
      int pos = temp?.positions?.first ?? 0;
      if (pos > index + 1) {
        temp?.positions?.first = pos - 1;
        textController.text = textController.text.replaceFirst("{{$pos}}", "{{${pos - 1}}}");
      }
    }

    update();
  }

  void editAnswer(int index) async {
    QuizModelOptions? option = optionList[index];
    if (option == null) return;

    List<QuizModelOptionsExplanation?>? result = await ManageEditQuizOptionInterpretationDialog.show(
      context: Get.context!,
      title: '选项${option.text ?? ''}',
      explanationList: option.explanation,
    );
    if (result == null) return;
    option.explanation = result;
    update();
  }

  void associateSemantic(BuildContext context, int index) async {
    QuizModelOptions? option = optionList[index];
    if (option == null) return;
    int oldId = option.content?.uid ?? 0;
    BaseKnowledge knowledge = BaseKnowledge(
      uid: oldId,
      contentType: option.content?.type,
    );

    var value = await ManageSelectKnowledgeTableManager.show(
      context: context,
      defaultDessert: [knowledge],
      language: 'en',
      showSelectKnowledgeAddButton: false,
      searchContent: option.text ?? '',
      singleSelectionMode: true,
    );
    if (value != null && value.isNotEmpty) {
      for (int i = 0; i < value.length; i++) {
        final entity = value[i];
        if (entity is EnWordEntity) {
          QuizModelContentList newContent = QuizModelContentList(
            type: entity.contentType,
            uid: entity.uid,
            semanticId: entity.semanticIds?.first,
          );
          optionList[index]?.content = newContent;
        } else if (entity is EnPhraseEntity) {
          QuizModelContentList newContent = QuizModelContentList(
            type: entity.contentType,
            uid: entity.uid,
            semanticId: entity.semanticIds?.first,
          );
          optionList[index]?.content = newContent;
        } else if (entity is EnSentenceEntity) {
          QuizModelContentList newContent = QuizModelContentList(
            type: entity.contentType,
            uid: entity.uid,
            semanticId: entity.semanticIds?.first,
          );
          optionList[index]?.content = newContent;
        }
      }
    }
    update();
  }

  void saveChanges() {
    if ((template?.optionsLen?.min ?? 0) > optionList.length) {
      ToastUtils.showManageToast(text: '选项数不能少于${template?.optionsLen?.min ?? 0}个');
      return;
    }

    bool isError = false;

    for (QuizModelOptions? option in optionList) {
      if (option!.text == null || option.text.isBlank == true) {
        isError = true;
        ToastUtils.showManageToast(text: '存在空选项，请补充完整再保存！');
        break;
      }

      for (QuizModelOptionsExplanation? explanation in option.explanation!) {
        if (explanation?.text == null || explanation?.text.isBlank == true) {
          isError = true;
          ToastUtils.showManageToast(text: '${option.text}的解析为空，请补充完整再保存！');
          break;
        }
      }
    }

    if (isError) {
      return;
    }

    Map<String, dynamic> data = {
      'stems': [
        {'text': textController.text}
      ],
      'options': optionList.map((option) => option!.toJson()).toList(),
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
