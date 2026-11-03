import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_title_check_text_widget.dart';
import 'package:langwise/app/modules/management/common/manage_select_knowledge_table/view.dart';
import 'package:langwise/app/modules/management/dialog/manage_quiz_contrast_cloze_manual_dialog.dart';
import 'package:langwise/app/modules/management/common/manage_create_quiz_request.dart';
import 'package:langwise/common/entities/en_phrase_entity.dart';
import 'package:langwise/common/entities/en_sentence_entity.dart';
import 'package:langwise/common/entities/en_word_entity.dart';
import 'package:langwise/common/entities/manage_lesson_quiz_template_entity.dart';
import 'package:langwise/common/entities/manage_unit_knowledge_entity.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:quiz_play/models/quiz_model.dart';

import '../../../../../../routes/routes.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';

class ManageCreateQuizContrastClozeController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageCreateQuizContrastClozeController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_CREATE_QUIZ_CONTRAST_CLOZE;

  @override
  String get breadcrumbTitle => '创建对比填空';

  List<ManageUnitKnowledgeEntity>? unitKnowledgeList;
  ManageLessonQuizTemplateEntity? lessonQuizTemplate;
  int? lessonId;
  int? unitId;
  String? language;

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
      Map argumentsMap = Get.arguments;
      lessonId = argumentsMap["lessonId"];
      unitId = argumentsMap["unitId"];
      language = argumentsMap["language"];
      lessonQuizTemplate = argumentsMap["lessonQuizTemplate"];
      unitKnowledgeList = argumentsMap["knowledgeList"];

      minOption = lessonQuizTemplate?.template?.optionsLen?.min ?? 1;
      maxOption = lessonQuizTemplate?.template?.optionsLen?.max ?? 4;
    }

    for (int i = 0; i < unitKnowledgeList!.length; i++) {
      List<String> texts = unitKnowledgeList![i].content?.split(" ") ?? [];
      if (texts.isEmpty) return;
      List<ManageTitleCheckTextEntity> list = [];
      for (var str in texts) {
        list.add(ManageTitleCheckTextEntity(text: str, key: GlobalKey()));
      }
      wordsTextList.add(list);
    }

    update();
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
        entity.definition = index.toString();
        int sentenceIndex = wordsTextList.indexOf(list);
        entity.difficulty = unitKnowledgeList![sentenceIndex].contentId;
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

  void createQuiz() async {
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
          "uid": entity.difficulty,
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
          "uid": entity.difficulty,
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
          "uid": entity.difficulty,
          "text": entity.content,
          "positions": [entity.definition],
        });
      }
    }

    String quizType = lessonQuizTemplate?.exerciseType ?? "";
    Map<String, dynamic> reqData = {
      "type": quizType,
      "configId": lessonQuizTemplate?.config?.uid,
      "contentList": contentList,
      "options": optionList,
      "lessonId": lessonId,
      "unitId": unitId,
    };

    try {
      ToastUtils.showLoading();

      bool isSuccess = await ManageCreateQuizRequest.createQuiz(reqData);
      if (isSuccess) {
        ToastUtils.showManageToast(text: "创建成功");
        Get.back(result: {'refresh': true});
        Get.back(result: {'refresh': true});
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }
}
