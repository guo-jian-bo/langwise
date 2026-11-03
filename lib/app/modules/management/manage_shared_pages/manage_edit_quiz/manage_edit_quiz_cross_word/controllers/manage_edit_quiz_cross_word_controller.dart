import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/dialog/manage_quiz_crossword_manual_dialog.dart';
import 'package:langwise/app/modules/management/models/manage_edit_quiz_model.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/entities/manage_quiz_template_entity.dart';
import 'package:langwise/common/https/manage_select_quzi_knowledge.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:quiz_play/models/quiz_model.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../routes/tag_routes.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';
import '../../../../controllers/manage_setting_controller.dart';
import 'package:langwise/common/enum/enum.dart';

class ManageEditQuizCrossWordController extends GetxController with WidgetsBindingObserver, ManageBreadcrumbMixin {
  final String tag;
  ManageEditQuizCrossWordController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_EDIT_QUIZ_CROSS_WORD;

  @override
  String get breadcrumbTitle => '编辑填字游戏';

  int? quizId;

  Rx<QuizModel> quizData = QuizModel().obs;
  ManageQuizTemplateEntityTemplate? template;

  final GlobalKey dialogKey = GlobalKey();

  final int letterRowSize = 15;
  final int letterColumnSize = 8;
  final GlobalKey girdKey = GlobalKey();
  List<VFillWordsData> dataList = [];

  List<VFillBlankBoxData> gridViewData = [];

  List<VFillWordData> wordList = [];

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if (Get.arguments != null) {
      quizId = Get.arguments["quizId"];
    }

    getQuizData();
    getBlankBoxData();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    super.onClose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    setWordOffset();
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

      List<QuizModelStems?>? stems = quizModel.stems;
      if (stems == null) return;
      for (int i = 0; i < stems.length; i++) {
        if (stems[i] == null) continue;
        if (stems[i]!.position == null) continue;
        List<int?> position = stems[i]!.position ?? [];
        if (position.length != 2) continue;
        dataList.add(VFillWordsData(
          startPosition: VFillWordPosition(position[0] ?? 0, position[1] ?? 0),
          text: stems[i]!.text ?? "",
          direction: stems[i]!.direction ?? "ACROSS",
          imageUrl: stems[i]!.imageUrl,
          audioUrl: stems[i]!.audioUrl,
        ));
      }

      setWordDirection();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        getWordListData();
      });
      update();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void setWordDirection() {
    for (int i = 0; i < dataList.length; i++) {
      dataList[i].isHorizontal = dataList[i].direction == "ACROSS";
    }
  }

  void getBlankBoxData() {
    gridViewData.clear();
    for (int i = 0; i < letterColumnSize; i++) {
      for (int j = 0; j < letterRowSize; j++) {
        gridViewData.add(VFillBlankBoxData(
          key: GlobalKey(),
          position: VFillWordPosition(j, i),
        ));
      }
    }
  }

  void getWordListData() {
    wordList.clear();
    for (int j = 0; j < dataList.length; j++) {
      VFillBlankBoxData? blankItemData = getBlankItemData(dataList[j].startPosition);
      if (blankItemData == null) continue;
      RenderBox? renderBox = blankItemData.key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) continue;

      final offset = getOffsetForGird(blankItemData.key);

      List<VFillGridLetterData> letters = [];
      for (int i = 0; i < dataList[j].text.length; i++) {
        bool isHorizontal = dataList[j].isHorizontal;
        VFillWordPosition position = blankItemData.position;
        if (isHorizontal) {
          position = VFillWordPosition(position.x + i, position.y);
        } else {
          position = VFillWordPosition(position.x, position.y + i);
        }

        VFillGridLetterData item = VFillGridLetterData(
          text: dataList[j].text[i],
          key: GlobalKey(),
          size: renderBox.size,
          position: position,
        );

        letters.add(item);
      }

      wordList.add(VFillWordData(
        wordText: dataList[j].text,
        offset: offset,
        initOffset: offset,
        isHorizontal: dataList[j].isHorizontal,
        key: GlobalKey(),
        word: letters,
        startPosition: dataList[j].startPosition,
        isSelect: j == 0,
        imageUrl: dataList[j].imageUrl,
        audioUrl: dataList[j].audioUrl,
      ));
    }
    update();
    getRepeatsSelect();
  }

  void getRepeatsSelect() {
    for (int i = 0; i < wordList.length; i++) {
      for (int j = 0; j < wordList[i].word.length; j++) {
        List<VFillGridLetterData> repeats = getLetterPositionRepeatList(wordList[i].word[j]);
        if (repeats.length != 2) continue;
        if (repeats.length == 2) {
          repeats[0].isSelect = true;
          repeats[1].isSelect = true;
        }
      }
    }
    update();
  }

  List<VFillGridLetterData> getLetterPositionRepeatList(VFillGridLetterData letter) {
    List<VFillGridLetterData> repeats = [];
    for (int i = 0; i < wordList.length; i++) {
      for (int j = 0; j < wordList[i].word.length; j++) {
        if (wordList[i].word[j].position.x == letter.position.x && wordList[i].word[j].position.y == letter.position.y) {
          repeats.add(wordList[i].word[j]);
        }
      }
    }
    return repeats;
  }

  VFillBlankBoxData? getBlankItemData(VFillWordPosition position) {
    for (int i = 0; i < gridViewData.length; i++) {
      if (gridViewData[i].position.x == position.x && gridViewData[i].position.y == position.y) {
        return gridViewData[i];
      }
    }
    return null;
  }

  Offset getOffsetForGird(GlobalKey key) {
    RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return Offset.zero;
    RenderBox? girdRenderBox = girdKey.currentContext?.findRenderObject() as RenderBox?;
    if (girdRenderBox == null) return Offset.zero;
    Offset offset = renderBox.localToGlobal(Offset.zero, ancestor: girdRenderBox);
    return offset;
  }

  void setWordOffset() {
    for (int i = 0; i < wordList.length; i++) {
      VFillBlankBoxData? blankItemData = getBlankItemData(wordList[i].startPosition);
      if (blankItemData == null) continue;
      final offset = getOffsetForGird(blankItemData.key);
      wordList[i].offset = offset;
      wordList[i].initOffset = offset;
    }
    update();
  }

  void selectWord(int index) {
    for (int i = 0; i < wordList.length; i++) {
      wordList[i].isSelect = i == index;
    }
    update();
  }

  void selectLetter(VFillGridLetterData letter) {
    List<VFillGridLetterData> repeats = getLetterPositionRepeatList(letter);
    if (repeats.length == 2) {
      repeats[0].isSelect = !repeats[0].isSelect;
      repeats[1].isSelect = !repeats[1].isSelect;
    } else {
      letter.isSelect = !letter.isSelect;
    }
    update();
  }

  void saveQuiz() {
    List<QuizModelStems> stems = [];
    List<QuizModelOptions> options = [];

    for (int i = 0; i < wordList.length; i++) {
      for (int j = 0; j < wordList[i].word.length; j++) {
        if (wordList[i].word[j].isSelect) {
          options.add(QuizModelOptions(
            text: wordList[i].word[j].text,
            positions: [
              wordList[i].word[j].position.x,
              wordList[i].word[j].position.y,
            ],
          ));
        }
      }

      if (wordList[i].isHorizontal) {
        int wordX = wordList[i].word.last.position.x;
        if (wordX + 1 > letterRowSize) {
          ToastUtils.showManageToast(text: "单词${wordList[i].wordText}超出范围", containerKey: dialogKey);
          return;
        }
      } else {
        int wordY = wordList[i].word.last.position.y;
        if (wordY + 1 > letterColumnSize) {
          ToastUtils.showManageToast(text: "单词${wordList[i].wordText}超出范围", containerKey: dialogKey);
          return;
        }
      }

      stems.add(QuizModelStems(
        text: wordList[i].wordText,
        audioUrl: wordList[i].audioUrl,
        imageUrl: wordList[i].imageUrl,
        direction: wordList[i].isHorizontal ? "ACROSS" : "DOWN",
        position: [
          wordList[i].word.first.position.x,
          wordList[i].word.first.position.y,
        ],
      ));
    }

    if (options.isEmpty) {
      ToastUtils.showManageToast(text: "请选择挖空位置", containerKey: dialogKey);
      return;
    }

    List<Map<String, dynamic>> optionStrList = [];
    for (int i = 0; i < options.length; i++) {
      optionStrList.add({
        'text': options[i].text,
        'positions': options[i].positions,
      });
    }

    List<Map<String, dynamic>> stemStrList = [];
    for (int i = 0; i < stems.length; i++) {
      stemStrList.add({
        'text': stems[i].text,
        'position': stems[i].position,
        'direction': stems[i].direction,
      });
    }

    Map<String, dynamic> data = {
      'stems': stemStrList,
      'options': optionStrList,
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
