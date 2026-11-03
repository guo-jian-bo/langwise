import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_title_check_text_widget.dart';
import 'package:langwise/app/modules/management/common/manage_select_knowledge_table/view.dart';
import 'package:langwise/app/modules/management/dialog/manage_quiz_contrast_cloze_manual_dialog.dart';
import 'package:langwise/app/modules/management/models/manage_edit_quiz_model.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/entities/en_phrase_entity.dart';
import 'package:langwise/common/entities/en_sentence_entity.dart';
import 'package:langwise/common/entities/en_word_entity.dart';
import 'package:langwise/common/entities/manage_quiz_template_entity.dart';
import 'package:langwise/common/entities/manage_unit_knowledge_entity.dart';
import 'package:langwise/common/https/manage_select_quzi_knowledge.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:quiz_play/models/quiz_model.dart';

import '../../../../../../routes/routes.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';

class ManageEditQuizContrastClozeController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageEditQuizContrastClozeController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_EDIT_QUIZ_CONTRAST_CLOZE;

  @override
  String get breadcrumbTitle => '编辑对比填空';

  int? quizId;

  Rx<QuizModel> quizData = QuizModel().obs;
  ManageQuizTemplateEntityTemplate? template;

  List<ManageUnitKnowledgeEntity>? unitKnowledgeList = [];

  int minOption = 2;
  int maxOption = 4;

  List<List<ManageTitleCheckTextEntity>> wordsTextList = [];
  List<List<ContrastClozeData>> optionsList = [];

  final GlobalKey dialogKey = GlobalKey();

  int selectFlagIndex = 0;
  int takeTurns = 0;
  int? _lastProcessedIndex;
  List<int> panSelectIndexs = [];
  List semanticList = [];

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if (Get.arguments != null) {
      quizId = Get.arguments["quizId"];
    }

    getQuizData();
  }

  void dealOption(QuizModelOptions? option, int index, int subIndex) {
    ContrastClozeData contrastClozeData = ContrastClozeData(
      controller: TextEditingController(text: option?.text ?? ""),
      id: selectFlagIndex,
      selectIndexs: [subIndex],
    );

    if (option?.content?.uid != null) {
      EnWordEntity knowledgeModel = EnWordEntity(
        uid: option?.content?.uid ?? 0,
        contentType: option?.content?.type,
        semanticIds: [option?.content?.semanticId],
        content: option?.text,
        definition: (index + 1).toString(),
      );
      semanticList.add(knowledgeModel);
    }

    if (index % 2 == 0) {
      optionsList.add([contrastClozeData]);
    } else {
      optionsList.last.add(contrastClozeData);
      selectFlagIndex++;
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

      minOption = template?.optionsLen?.min ?? 2;
      maxOption = template?.optionsLen?.max ?? 4;

      List<String> stemTextList1 = quizModel.stems?.first?.text?.split(' ') ?? [];
      List<String> stemTextList2 = quizModel.stems?.last?.text?.split(' ') ?? [];
      for (int i = 0; i < (quizModel.options ?? []).length; i++) {
        String stemText = '';
        final RegExp placeHolderReg = RegExp(r'\{\{\d+\}\}');

        List<String> stemTextList = [];
        if (i % 2 == 0) {
          stemTextList = stemTextList1;
        } else {
          stemTextList = stemTextList2;
        }

        int subIndex = -1;
        for (var j = 0; j < stemTextList.length; j++) {
          String element = stemTextList[j];
          if (placeHolderReg.hasMatch(element)) {
            stemText = element;
            subIndex = j;
            break;
          }
        }

        if (stemText.isEmpty) {
          continue;
        }

        stemText = stemText.substring(2);
        stemText = stemText.split('}').first;
        final int index = int.parse(stemText);
        if (subIndex == -1) {
          continue;
        }
        for (QuizModelOptions? option in quizModel.options ?? []) {
          if (option?.positions?.first == index) {
            dealOption(option, i, subIndex);
            if (i % 2 == 0) {
              stemTextList1[subIndex] = stemTextList1[subIndex].replaceAll("{{$index}}", option?.text ?? '');
            } else {
              stemTextList2[subIndex] = stemTextList2[subIndex].replaceAll("{{$index}}", option?.text ?? '');
            }
          }
        }
      }

      quizModel.stems?.first?.text = stemTextList1.join(' ');
      quizModel.stems?.last?.text = stemTextList2.join(' ');

      for (var stem in quizModel.stems ?? []) {
        ManageUnitKnowledgeEntity knowledgeModel = ManageUnitKnowledgeEntity(
          content: stem?.text,
          audioUrl: stem?.audioUrl,
          imageUrl: stem?.imageUrl,
          difficulty: stem?.difficulty,
          definition: stem?.gloss?.where((element) => element?.lang == 'zh').first?.text,
          contentId: stem?.content?.uid,
          contentType: stem?.content?.type,
          semanticId: stem?.content?.semanticId,
        );
        unitKnowledgeList?.add(knowledgeModel);

        String stemText = stem?.text ?? "";
        List<String> texts = stemText.split(" ");
        if (texts.isEmpty) return;
        List<ManageTitleCheckTextEntity> list = [];
        for (var str in texts) {
          list.add(ManageTitleCheckTextEntity(text: str, key: GlobalKey()));
        }
        wordsTextList.add(list);
      }

      for (var i = 0; i < wordsTextList.length; i++) {
        List<ManageTitleCheckTextEntity> list = wordsTextList[i];

        List<int> selectIndexs = [];
        for (List<ContrastClozeData> element in optionsList) {
          ContrastClozeData conData = element[i];
          selectIndexs.addAll(conData.selectIndexs);
        }

        for (var j = 0; j < list.length; j++) {
          if (selectIndexs.contains(j)) {
            list[j].seelcted = true;
          }
        }
      }

      update();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  String substringString(String text) {
    final isPunctuation = RegExp(r'[,.!?;，。！？；]$').hasMatch(text[text.length - 1]);
    if (isPunctuation) {
      text = text.substring(0, text.length - 1);
    }
    return text;
  }

  void selectItem(int index, List<ManageTitleCheckTextEntity> list, BuildContext context) async {
    if (maxOption - 1 < selectFlagIndex * unitKnowledgeList!.length) {
      ToastUtils.showManageToast(text: "最多可选择$maxOption个选项");
      return;
    }
    if (list[index].seelcted) return;
    list[index].seelcted = true;
    String text = substringString(list[index].text);

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
        entity.content = text;
        entity.definition = (selectFlagIndex * 2 + takeTurns + 1).toString();
        semanticList.removeWhere((element) => element.uid == entity.uid);
        semanticList.add(entity);
      }
    } else {
      list[index].seelcted = false;
      return;
    }

    List<ContrastClozeData>? testList;
    try {
      testList = optionsList[selectFlagIndex];
    } catch (e) {
      // ignore
    }

    bool addFlag = true;
    if (testList != null) {
      for (int i = 0; i < testList.length; i++) {
        if (testList[i].selectIndexs.isEmpty) {
          addFlag = false;
          break;
        }
      }
    }

    if (addFlag) {
      List<ContrastClozeData> conList = [];
      for (int i = 0; i < wordsTextList.length; i++) {
        conList.add(ContrastClozeData(
          controller: TextEditingController(),
          id: selectFlagIndex,
          selectIndexs: [],
        ));
      }
      optionsList.add(conList);
    }

    for (int i = 0; i < optionsList[selectFlagIndex].length; i++) {
      if (optionsList[selectFlagIndex][i].selectIndexs.isEmpty) {
        optionsList[selectFlagIndex][i].controller.text = text;
        optionsList[selectFlagIndex][i].selectIndexs.add(index);
        break;
      }
    }

    bool indexFlag = true;
    for (int i = 0; i < optionsList[selectFlagIndex].length; i++) {
      if (optionsList[selectFlagIndex][i].selectIndexs.isEmpty) {
        indexFlag = false;
        break;
      }
    }

    if (indexFlag) selectFlagIndex++;
    takeTurns++;
    if (takeTurns >= unitKnowledgeList!.length) takeTurns = 0;
    update();
  }

  void handlePanStart(DragStartDetails details, bool isFirstRow) {
    _lastProcessedIndex = null;
  }

  void handlePanUpdate(DragUpdateDetails details, List<ManageTitleCheckTextEntity> currentList, context) {
    if (maxOption - 1 < selectFlagIndex * unitKnowledgeList!.length) {
      ToastUtils.showManageToast(text: "最多可选择$maxOption个选项");
      return;
    }

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);

    for (int i = 0; i < currentList.length; i++) {
      if (currentList[i].key?.currentContext != null) {
        final RenderBox textBox = currentList[i].key!.currentContext!.findRenderObject() as RenderBox;
        final Offset textPosition = textBox.localToGlobal(Offset.zero, ancestor: box);
        final Size textSize = textBox.size;

        if (localPosition.dx >= textPosition.dx &&
            localPosition.dx <= textPosition.dx + textSize.width &&
            localPosition.dy >= textPosition.dy &&
            localPosition.dy <= textPosition.dy + textSize.height) {
          if (i != _lastProcessedIndex) {
            bool isAdjacent = false;
            if (panSelectIndexs.isEmpty) {
              isAdjacent = true;
            } else {
              int lastSelectedIndex = panSelectIndexs.last;
              isAdjacent = (i == lastSelectedIndex + 1) || (i == lastSelectedIndex - 1);
            }

            if (isAdjacent) {
              _lastProcessedIndex = i;
              if (currentList[i].seelcted) continue;
              currentList[i].seelcted = true;
              if (!panSelectIndexs.contains(i)) {
                panSelectIndexs.add(i);
              }
            }
          }
          break;
        }
      }
    }
    update();
  }

  void handlePanEnd(DragEndDetails details, List<ManageTitleCheckTextEntity> currentList) {
    _lastProcessedIndex = null;
    if (panSelectIndexs.isEmpty) return;

    panSelectIndexs.sort();

    String text = "";
    for (int i = 0; i < panSelectIndexs.length; i++) {
      text += substringString(currentList[panSelectIndexs[i]].text);
      text += " ";
    }
    bool hasSelection = currentList.any((item) => item.seelcted);
    if (hasSelection) {
      List<ContrastClozeData>? testList;
      try {
        testList = optionsList[selectFlagIndex];
      } catch (e) {
        // ignore
      }

      bool addFlag = true;
      if (testList != null) {
        for (int i = 0; i < testList.length; i++) {
          if (testList[i].selectIndexs.isEmpty) {
            addFlag = false;
            break;
          }
        }
      }

      if (addFlag) {
        List<ContrastClozeData> conList = [];
        for (int i = 0; i < wordsTextList.length; i++) {
          conList.add(ContrastClozeData(
            controller: TextEditingController(),
            id: selectFlagIndex,
            selectIndexs: [],
          ));
        }
        optionsList.add(conList);
      }

      for (int i = 0; i < optionsList[selectFlagIndex].length; i++) {
        if (optionsList[selectFlagIndex][i].selectIndexs.isEmpty) {
          optionsList[selectFlagIndex][i].controller.text = text;
          optionsList[selectFlagIndex][i].selectIndexs = panSelectIndexs.toList();
          break;
        }
      }

      bool indexFlag = true;
      for (int i = 0; i < optionsList[selectFlagIndex].length; i++) {
        if (optionsList[selectFlagIndex][i].selectIndexs.isEmpty) {
          indexFlag = false;
          break;
        }
      }

      if (indexFlag) selectFlagIndex++;
      takeTurns++;
      if (takeTurns >= unitKnowledgeList!.length) takeTurns = 0;
      update();
    }

    panSelectIndexs.clear();
    update();
  }

  void delOption(int index) {
    List<ContrastClozeData> list = optionsList[index];

    int select = 0;
    for (int i = 0; i < list.length; i++) {
      List<int> selectList = list[i].selectIndexs;
      List<ManageTitleCheckTextEntity> wordList = wordsTextList[i];
      for (var j = 0; j < wordList.length; j++) {
        ManageTitleCheckTextEntity entity = wordList[j];
        if (selectList.contains(j)) {
          semanticList.removeWhere((element) => entity.text.contains(element.content));
          entity.seelcted = false;
          select++;
        }
      }
    }

    optionsList.removeAt(index);
    takeTurns = 0;
    if (select == wordsTextList.length) selectFlagIndex--;
    update();
  }

  int resultTextIndex = 1;
  int resultOptionIndex = 1;

  String getResText(int index) {
    List<ManageTitleCheckTextEntity> wordTextList = wordsTextList[index];
    List<ContrastClozeData> optionList = [];
    for (int i = 0; i < optionsList.length; i++) {
      for (int j = 0; j < optionsList[i].length; j++) {
        if (j == index) {
          optionList.add(optionsList[i][index]);
        }
      }
    }
    String text = "";

    int optionOldIndex = -1;
    for (int i = 0; i < wordTextList.length; i++) {
      bool isSelected = false;
      int optionIndex = 0;

      for (int j = 0; j < optionList.length; j++) {
        if (optionList[j].selectIndexs.contains(i)) {
          isSelected = true;
          optionIndex = resultTextIndex;
          break;
        }
      }

      if (optionOldIndex == optionIndex) continue;
      if (i != 0) text += " ";
      if (isSelected) {
        text += "{{$optionIndex}}";
        optionOldIndex = optionIndex;
        resultTextIndex++;
      } else {
        text += wordTextList[i].text;
      }
    }
    return text;
  }

  List<QuizModelOptions> getOptions(int index) {
    List<ManageTitleCheckTextEntity> wordTextList = wordsTextList[index];
    List<ContrastClozeData> optionList = [];
    for (int i = 0; i < optionsList.length; i++) {
      for (int j = 0; j < optionsList[i].length; j++) {
        if (j == index) {
          optionList.add(optionsList[i][j]);
        }
      }
    }
    List<QuizModelOptions> options = [];
    for (int i = 0; i < optionList.length; i++) {
      String text = "";
      for (int j = 0; j < optionList[i].selectIndexs.length; j++) {
        if (j != 0) text += " ";
        text += wordTextList[optionList[i].selectIndexs[j]].text;
      }
      options.add(QuizModelOptions(
        text: text,
        positions: [resultOptionIndex],
      ));
      resultOptionIndex++;
    }
    return options;
  }

  Future<void> changeSemantic(int index, int index1, context) async {
    String text = optionsList[index][index1].controller.text;
    if (text.isEmpty) {
      return;
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
        entity.content = text;
        entity.definition = (index * 2 + index1 + 1).toString();
        semanticList.removeWhere((element) => element.uid == entity.uid);
        semanticList.add(entity);
      }
    }

    update();
  }

  Future<void> saveQuiz() async {
    for (int i = 0; i < optionsList.length; i++) {
      for (var item in optionsList[i]) {
        if (item.selectIndexs.isEmpty) {
          ToastUtils.showManageToast(text: "选项必须对应", containerKey: dialogKey);
          item.error = true;
          update();
          Future.delayed(const Duration(milliseconds: 3000), () {
            item.error = false;
            update();
          });
          return;
        }
      }
    }

    if (minOption > selectFlagIndex * unitKnowledgeList!.length) {
      ToastUtils.showManageToast(text: "最少要添加$minOption个选项");
      return;
    }

    List<Map<String, dynamic>> contentList = [];
    for (ManageUnitKnowledgeEntity model in unitKnowledgeList!) {
      contentList.add({
        "uid": model.contentId,
        "type": model.contentType,
        "semanticId": model.semanticId,
      });
    }

    if (semanticList.length != selectFlagIndex * 2) {
      ToastUtils.showManageToast(text: "选项未关联语义，请重新选择进行关联！");
      return;
    }

    List<Map<String, dynamic>> optionList = [];
    for (int i = 0; i < semanticList.length; i++) {
      final entity = semanticList[i];
      if (entity is EnWordEntity) {
        contentList.add({
          "uid": entity.uid,
          "type": entity.contentType,
          "semanticId": entity.semanticIds?.first,
        });
        optionList.add({
          "text": entity.content,
          "positions": [entity.definition],
        });
      } else if (entity is EnPhraseEntity) {
        contentList.add({
          "uid": entity.uid,
          "type": entity.contentType,
          "semanticId": entity.semanticIds?.first,
        });
        optionList.add({
          "text": entity.content,
          "positions": [entity.definition],
        });
      } else if (entity is EnSentenceEntity) {
        contentList.add({
          "uid": entity.uid,
          "type": entity.contentType,
          "semanticId": entity.semanticIds?.first,
        });
        optionList.add({
          "text": entity.content,
          "positions": [entity.definition],
        });
      }
    }

    List<List<String>> sentenceList = [];
    for (var i = 0; i < wordsTextList.length; i++) {
      List<String> subList = [];
      for (var j = 0; j < wordsTextList[i].length; j++) {
        subList.add(wordsTextList[i][j].text);
      }
      sentenceList.add(subList);
    }

    for (var i = 0; i < sentenceList.length; i++) {
      List<String> subList = sentenceList[i];
      bool option = false;
      for (int j = optionsList.length - 1; j >= 0; j--) {
        List<ContrastClozeData> element = optionsList[j];
        ContrastClozeData item = element[i];
        int index = item.id * 2 + i + 1;
        subList.removeWhere((element) {
          int k = subList.indexOf(element);
          if (item.selectIndexs.contains(k)) {
            if (!option) {
              subList[k] = element.replaceAll(item.controller.text, "{{$index}}");
              option = true;
              return false;
            } else {
              return true;
            }
          }
          return false;
        });
        option = false;
      }
    }

    List<Map<String, dynamic>> stemList = [];
    for (var i = 0; i < sentenceList.length; i++) {
      String stem = sentenceList[i].join(' ');
      stemList.add({"text": stem});
    }

    Map<String, dynamic> data = {
      "contentList": contentList,
      "options": optionList,
      "stems": stemList,
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
