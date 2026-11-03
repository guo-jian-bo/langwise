/*
填字游戏手动创建对话框实现逻辑：

1. 页面布局：
   - 使用15x8的网格作为填字游戏区域
   - 支持横向和纵向放置单词
   - 提供单词方向选择按钮（横向/竖向）

2. 核心功能：
   - 单词放置：用户可以在网格中放置单词，支持横向和纵向
   - 位置检测：自动检查单词放置位置的合法性
   - 交叉验证：确保单词交叉处的字母匹配
   - 拖拽功能：支持拖拽移动单词位置
   - 实时冲突检测：移动单词时实时检查是否与其他单词冲突

3. 数据结构：
   - 使用二维网格存储字母位置信息
   - 记录每个单词的起始位置和方向
   - 维护单词之间的交叉关系

4. 交互流程：
   - 选择单词方向
   - 输入单词内容
   - 拖拽调整位置
   - 确认无冲突后保存
*/

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:quiz_play/models/models.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/widgets/widgets.dart';

class ManageQuizCrosswordManualDialog {
  static Future<QuizCrosswordManualResult?> show({
    required BuildContext context,
    required List<ManageUnitKnowledgeEntity> knowledges,
    required ManageLessonQuizTemplateEntity quizTemplate,
    int? difficultyMin,
    int? difficultyMax,
    int? lessonId,
    int? unitId,
  }) async {
    return await showCupertinoDialog<QuizCrosswordManualResult?>(
      context: context,
      builder: (context) {
        return ManageQuizCrosswordManualDialogWidget(
          knowledges: knowledges,
          quizTemplate: quizTemplate,
          difficultyMin: difficultyMin,
          difficultyMax: difficultyMax,
          lessonId: lessonId,
          unitId: unitId,
        );
      },
    );
  }
}

class ManageQuizCrosswordManualDialogWidget extends StatefulWidget {
  final List<ManageUnitKnowledgeEntity> knowledges;
  final ManageLessonQuizTemplateEntity quizTemplate;
  final int? difficultyMin;
  final int? difficultyMax;
  final int? lessonId;
  final int? unitId;
  const ManageQuizCrosswordManualDialogWidget({
    super.key,
    required this.knowledges,
    required this.quizTemplate,
    this.difficultyMin,
    this.difficultyMax,
    this.lessonId,
    this.unitId,
  });

  @override
  State<ManageQuizCrosswordManualDialogWidget> createState() => _ManageQuizCrosswordManualDialogWidgetState();
}

class _ManageQuizCrosswordManualDialogWidgetState extends State<ManageQuizCrosswordManualDialogWidget> with WidgetsBindingObserver {
  final GlobalKey dialogKey = GlobalKey();

  final int letterRowSize = 15;
  final int letterColumnSize = 8;
  final GlobalKey girdKey = GlobalKey();
  List<VFillWordsData> dataList = [
    // _VFillWordsData(startPosition: _VFillWordPosition(0, 3), text: "apple", direction: "ACROSS"),
    // _VFillWordsData(startPosition: _VFillWordPosition(4, 2), text: "pear", direction: "DOWN"),
    // _VFillWordsData(startPosition: _VFillWordPosition(2, 0), text: "grape", direction: "DOWN"),
  ];

  /// letterRowSize * letterColumnSize 的表格
  List<VFillBlankBoxData> gridViewData = [];

  ///单词
  List<VFillWordData> wordList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getServerInitWord();
    getBlankBoxData();
  }

  Future<void> getServerInitWord() async {
    List<Map<String, dynamic>> contents = [];
    for (int i = 0; i < widget.knowledges.length; i++) {
      contents.add({
        "contentType": widget.knowledges[i].contentType,
        "contentId": widget.knowledges[i].contentId,
        "semanticId": widget.knowledges[i].semanticId,
      });
    }
    Map<String, dynamic> reqData = {
      "type": widget.quizTemplate.exerciseType,
      "config": widget.quizTemplate.config?.toJson(),
      "contents": contents,
      "difficulty": {
        "min": widget.difficultyMin,
        "max": widget.difficultyMax,
      },
      "unitId": widget.unitId,
      "lessonId": widget.lessonId,
    };

    PreviewQuizEntity? previewQuizEntity = await ManageSelectQuziKnowledge.getAiPreviewQuizList(reqData);
    if (previewQuizEntity == null) return;
    List<QuizModel?>? resQuizList = previewQuizEntity.list;
    if (resQuizList == null) return;
    if (resQuizList.isEmpty) return;

    QuizModel quizModel = resQuizList.first!;
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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    setWordOffset();
  }

  void setWordDirection() {
    for (int i = 0; i < dataList.length; i++) {
      dataList[i].isHorizontal = dataList[i].direction == "ACROSS";
    }
  }

  /// letterRowSize * letterColumnSize 的表格
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

  /// 获取单词所在的位置
  void getWordListData() {
    wordList.clear();
    for (int j = 0; j < dataList.length; j++) {
      VFillBlankBoxData? blankItemData = getBlankItemData(dataList[j].startPosition);
      if (blankItemData == null) continue;
      RenderBox? renderBox = blankItemData.key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) continue;

      // 计算单词的像素位置
      final offset = getOffsetForGird(blankItemData.key);

      // 创建字母列表
      List<VFillGridLetterData> letters = [];
      for (int i = 0; i < dataList[j].text.length; i++) {
        /// 每个单词的位置
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

      // 添加单词数据
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
    if (mounted) setState(() {});
    getRepeatsSelect();
  }

  /// 获取交错的地方 默认选择
  void getRepeatsSelect() {
    for (int i = 0; i < wordList.length; i++) {
      for (int j = 0; j < wordList[i].word.length; j++) {
        List<VFillGridLetterData> repeats = getLetterPositionRepeatList(wordList[i].word[j]);
        if (repeats.length != 2) continue;
        if (repeats.length == 2) {
          //默认选择交错的地方
          repeats[0].isSelect = true;
          repeats[1].isSelect = true;
        }
      }
    }
    if (mounted) setState(() {});
  }

  Offset getOffsetForGird(GlobalKey? key) {
    RenderBox? renderBox = girdKey.currentContext?.findRenderObject() as RenderBox?;
    RenderBox? dataRenderBox = key?.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || dataRenderBox == null) return Offset.zero;
    return renderBox.globalToLocal(dataRenderBox.localToGlobal(Offset.zero));
  }

  /// 根据位置获取空白框数据
  VFillBlankBoxData? getBlankItemData(VFillWordPosition position) {
    for (int i = 0; i < gridViewData.length; i++) {
      if (gridViewData[i].position.x == position.x && gridViewData[i].position.y == position.y) {
        return gridViewData[i];
      }
    }
    return null;
  }

  /// 单词位置
  void setWordOffset() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < wordList.length; i++) {
        VFillBlankBoxData? blankItemData = getBlankItemData(wordList[i].word.first.position);
        if (blankItemData == null) continue;
        RenderBox? renderBox = blankItemData.key.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox == null) continue;
        // 计算单词的像素位置
        final offset = getOffsetForGird(blankItemData.key);
        wordList[i].offset = offset;
        wordList[i].initOffset = offset;

        for (int j = 0; j < wordList[i].word.length; j++) {
          wordList[i].word[j].size = renderBox.size;
        }
      }
      if (mounted) setState(() {});
    });
  }

  /// 获取当前选择的单词
  VFillWordData? getCurrentWord() {
    for (int i = 0; i < wordList.length; i++) {
      if (wordList[i].isSelect) {
        return wordList[i];
      }
    }
    return null;
  }

  /// 根据字母获取 一样的位置的字母
  List<VFillGridLetterData> getLetterPositionRepeatList(VFillGridLetterData letter) {
    List<VFillGridLetterData> letters = [];
    for (int i = 0; i < wordList.length; i++) {
      for (int j = 0; j < wordList[i].word.length; j++) {
        if (wordList[i].word[j].position.x == letter.position.x && wordList[i].word[j].position.y == letter.position.y) {
          if (wordList[i].word[j].text == letter.text) {
            letters.add(wordList[i].word[j]);
          }
        }
      }
    }
    return letters;
  }

  /// 根据字母获取对应位置 是否有其他字母 如果没有返回true 如果有并且一样返回true 否则返回false
  bool getLetterPositionNotRepeat(VFillGridLetterData letter) {
    for (int i = 0; i < wordList.length; i++) {
      for (int j = 0; j < wordList[i].word.length; j++) {
        if (wordList[i].word[j].position.x == letter.position.x && wordList[i].word[j].position.y == letter.position.y) {
          if (wordList[i].word[j].text != letter.text) {
            return false;
          }
        }
      }
    }
    return true;
  }

  /// 点击方向
  void _onTapDirection(bool isHorizontal) {
    VFillWordData? currnt = getCurrentWord();
    if (currnt == null) return;

    bool isErr = false;
    if (isHorizontal) {
      int last = currnt.word.last.position.x + currnt.word.length;
      if (last > letterRowSize) isErr = true;
    } else {
      int last = currnt.word.last.position.y + currnt.word.length;
      if (last > letterColumnSize) isErr = true;
    }

    currnt.isHorizontal = isHorizontal;

    /// 更换方向 除去第一个字母 其他位置都要改变
    for (int i = 0; i < currnt.word.length; i++) {
      /// 每个单词的位置
      VFillWordPosition position = currnt.startPosition;
      if (currnt.isHorizontal) {
        position = VFillWordPosition(position.x + i, position.y);
      } else {
        position = VFillWordPosition(position.x, position.y + i);
      }
      currnt.word[i].position = position;

      /// 如果交错的地方和其他字母不一样 则error
      currnt.word[i].isErr = !getLetterPositionNotRepeat(currnt.word[i]);

      List<VFillGridLetterData> resRep = getLetterPositionRepeatList(currnt.word[i]);
      if (resRep.length == 2) {
        if (resRep[0].isSelect) resRep[1].isSelect = true;
        if (resRep[1].isSelect) resRep[0].isSelect = true;
      }

      if (currnt.word[i].isErr) {
        isErr = true;
      }
    }

    if (isErr) {
      //如果不合理 则回到原来的位置
      Future.delayed(const Duration(milliseconds: 500), () {
        for (int i = 0; i < currnt.word.length; i++) {
          currnt.word[i].isErr = false;
        }
        _onTapDirection(!isHorizontal);
      });
    }
    if (mounted) setState(() {});
  }

  /// 点击字母
  void _onLetterTap(VFillGridLetterData data, VFillWordData dataWord) {
    data.isSelect = !data.isSelect;

    /// 对于同一个位置的字母也要选择
    for (int i = 0; i < wordList.length; i++) {
      for (int j = 0; j < wordList[i].word.length; j++) {
        if (wordList[i].word[j].position.x == data.position.x && wordList[i].word[j].position.y == data.position.y) {
          wordList[i].word[j].isSelect = data.isSelect;
        }
      }
    }
    _onWordTap(dataWord);
    if (mounted) setState(() {});
  }

  /// 长按字母
  void _onLetterLongTap(VFillGridLetterData data, VFillWordData dataWord) {
    List<int> iIndexs = [];
    for (int i = 0; i < wordList.length; i++) {
      for (int j = 0; j < wordList[i].word.length; j++) {
        if (wordList[i].word[j].position.x == data.position.x && wordList[i].word[j].position.y == data.position.y) {
          iIndexs.add(i);
        }
      }
    }

    /// 长按交错地方的单词 切换单词
    if (iIndexs.length == 2) {
      if (wordList[iIndexs[0]].isSelect) {
        VFillWordData rem = wordList.removeAt(iIndexs[1]);
        wordList.add(rem);
        _onWordTap(rem);
      } else {
        VFillWordData rem = wordList.removeAt(iIndexs[0]);
        wordList.add(rem);
        _onWordTap(rem);
      }
    }
    // _onWordTap(rem);
    if (mounted) setState(() {});
  }

  /// 模拟点击单词
  void _onWordTap(VFillWordData dataWord) {
    for (int i = 0; i < wordList.length; i++) {
      wordList[i].isSelect = false;
    }
    dataWord.isSelect = true;
    if (mounted) setState(() {});
  }

  /// 开始拖动整个单词
  void _onWordPanStart(VFillWordData dataWord, int wordIndex) {
    // _VFillWordData rem = wordList.removeAt(wordIndex);
    // wordList.add(rem);
    // _onWordTap(rem);
    _onWordTap(dataWord);
  }

  /// 拖动整个单词
  void _onWordPanUpdate(VFillWordData dataWord, DragUpdateDetails details) {
    dataWord.offset += details.delta;

    // 重置所有空格的匹配状态
    for (var box in gridViewData) {
      box.isMatch = false;
    }

    // 检查每个字母是否与空格匹配
    for (int i = 0; i < dataWord.word.length; i++) {
      var letter = dataWord.word[i];
      letter.isErr = false;

      // 计算字母相对于单词起始位置的偏移，考虑网格间距
      double letterX = dataWord.offset.dx + (dataWord.isHorizontal ? i * (letter.size.width + 12.wMin) : 0);
      double letterY = dataWord.offset.dy + (dataWord.isHorizontal ? 0 : i * (letter.size.height + 12.wMin));

      // 检查每个空格
      for (var box in gridViewData) {
        RenderBox? renderBox = box.key.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox == null) continue;

        Offset boxOffset = getOffsetForGird(box.key);
        Rect boxRect = Rect.fromLTWH(
          boxOffset.dx - 6.wMin, // 适当调整匹配范围
          boxOffset.dy - 6.wMin,
          renderBox.size.width + 12.wMin,
          renderBox.size.height + 12.wMin,
        );

        Offset center = Offset(letterX + letter.size.width / 2, letterY + letter.size.height / 2);

        // 检查字母是否在扩大后的空格范围内
        if (boxRect.contains(center)) {
          box.isMatch = true;

          // 检查该位置是否有其他字母
          for (var word in wordList) {
            if (word == dataWord) continue;
            for (var otherLetter in word.word) {
              if (otherLetter.position.x == box.position.x && otherLetter.position.y == box.position.y && otherLetter.text != letter.text) {
                letter.isErr = true;
                break;
              }
            }
          }
          break;
        }
      }
    }

    if (mounted) setState(() {});
  }

  /// 整个单词拖动结束
  void _onWordPanEnd(VFillWordData dataWord, DragEndDetails details) {
    bool canPlace = true;
    List<VFillWordPosition> newPositions = [];
    Map<String, VFillWordPosition> letterPositions = {};

    // 首先收集所有匹配的空格位置
    for (var box in gridViewData) {
      if (box.isMatch) {
        letterPositions["${box.position.x},${box.position.y}"] = box.position;
      }
    }

    // 检查是否所有字母都能找到对应的位置
    if (letterPositions.length < dataWord.word.length) {
      canPlace = false;
    } else {
      // 检查每个字母的新位置是否合适
      for (int i = 0; i < dataWord.word.length; i++) {
        var letter = dataWord.word[i];
        VFillWordPosition? expectedPosition;

        // 根据单词方向计算期望位置
        if (i == 0) {
          // 第一个字母可以放在任何匹配的空格位置
          for (var pos in letterPositions.values) {
            expectedPosition = pos;
            break;
          }
        } else {
          // 后续字母必须按照方向排列
          var prevPos = newPositions[i - 1];
          String key = dataWord.isHorizontal ? "${prevPos.x + 1},${prevPos.y}" : "${prevPos.x},${prevPos.y + 1}";
          expectedPosition = letterPositions[key];
        }

        if (expectedPosition == null) {
          canPlace = false;
          break;
        }

        // 检查该位置是否有冲突
        bool hasConflict = false;
        for (var word in wordList) {
          if (word == dataWord) continue;
          for (var otherLetter in word.word) {
            if (otherLetter.position.x == expectedPosition.x && otherLetter.position.y == expectedPosition.y && otherLetter.text != letter.text) {
              hasConflict = true;
              break;
            }
          }
          if (hasConflict) break;
        }

        if (hasConflict) {
          canPlace = false;
          break;
        }

        newPositions.add(expectedPosition);
      }
    }

    if (canPlace) {
      // 更新所有字母的位置
      for (int i = 0; i < dataWord.word.length; i++) {
        dataWord.word[i].position = newPositions[i];
        dataWord.word[i].isErr = false;
        List<VFillGridLetterData> resRep = getLetterPositionRepeatList(dataWord.word[i]);
        if (resRep.length == 2) {
          if (resRep[0].isSelect) resRep[1].isSelect = true;
          if (resRep[1].isSelect) resRep[0].isSelect = true;
        }
      }
      // 更新单词的起始位置
      dataWord.startPosition = newPositions[0];
      // 更新单词的偏移量
      RenderBox? firstLetterBox =
          gridViewData.firstWhere((box) => box.position.x == newPositions[0].x && box.position.y == newPositions[0].y).key.currentContext?.findRenderObject() as RenderBox?;
      if (firstLetterBox != null) {
        dataWord.offset = getOffsetForGird(gridViewData.firstWhere((box) => box.position.x == newPositions[0].x && box.position.y == newPositions[0].y).key);
        dataWord.initOffset = dataWord.offset;
      }
    } else {
      // 如果不能放置，返回初始位置
      dataWord.offset = dataWord.initOffset;
      for (var letter in dataWord.word) {
        letter.isErr = false;
      }
    }

    // 重置所有空格的匹配状态
    for (var box in gridViewData) {
      box.isMatch = false;
    }

    if (mounted) setState(() {});
  }

  /// 完成
  void finishButton() {
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

    QuizCrosswordManualResult result = QuizCrosswordManualResult(
      stems: stems,
      options: options,
    );

    Get.back(result: result);
  }

  @override
  Widget build(BuildContext context) {
    Widget buildBoxItem(int index) {
      return Container(
        key: gridViewData[index].key,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: const Color.fromRGBO(70, 70, 72, 1),
          boxShadow: [
            BoxShadow(
              color: gridViewData[index].isMatch ? Colors.white : Colors.transparent,
              blurRadius: 5,
            ),
          ],
        ),
        child: AutoSizeText(
          gridViewData[index].position.toString(),
          minFontSize: 6,
          style: TextStyle(
            fontSize: 36.wMin,
            // color: Colors.white,
            color: Colors.transparent,
          ),
        ),
      );
    }

    Widget buildLetterWidget(VFillGridLetterData data, VFillWordData dataWord) {
      Color color = const Color.fromRGBO(70, 70, 72, 1);
      if (data.isSelect) {
        color = const Color(0xffFF781F);
      }
      if (data.isErr) {
        color = const Color(0xffFF2D46);
      }

      return TapScaleWidget(
        onTap: () {
          _onLetterTap(data, dataWord);
        },
        onLongPress: () {
          _onLetterLongTap(data, dataWord);
        },
        behavior: HitTestBehavior.deferToChild,
        sclae: 1.05,
        child: Container(
          key: data.key,
          width: data.size.width,
          height: data.size.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            color: color,
          ),
          child: AutoSizeText(
            data.text,
            minFontSize: 6,
            style: TextStyle(
              fontSize: 36.wMin,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    Widget buildWordWidget(VFillWordData data, int wordIndex) {
      Widget wordDirection() {
        if (data.isHorizontal) {
          return Row(
            spacing: 12.wMin,
            children: List.generate(data.word.length, (int index) {
              return buildLetterWidget(data.word[index], data);
            }),
          );
        }
        return Column(
          spacing: 12.wMin,
          children: List.generate(data.word.length, (int index) {
            return buildLetterWidget(data.word[index], data);
          }),
        );
      }

      return GestureDetector(
        onPanStart: (details) => _onWordPanStart(data, wordIndex),
        onPanUpdate: (details) {
          _onWordPanUpdate(data, details);
        },
        onPanEnd: (details) {
          _onWordPanEnd(data, details);
        },
        behavior: HitTestBehavior.deferToChild,
        child: Transform.translate(
          offset: Offset(-6.wMin, -6.wMin),
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: Radius.circular(8.wMin),
            dashPattern: [5.wMin, 5.wMin],
            padding: EdgeInsets.zero,
            strokeCap: StrokeCap.round,
            strokeWidth: 1.wMin,
            color: data.isSelect ? const Color(0xff2388FF) : Colors.transparent,
            child: Container(
              margin: EdgeInsets.all(6.wMin),
              child: wordDirection(),
            ),
          ),
        ),
      );
    }

    Widget buildWordContent() {
      return Stack(
        clipBehavior: Clip.none,
        key: girdKey,
        children: [
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: GridView.builder(
              itemCount: gridViewData.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              clipBehavior: Clip.none,
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: letterRowSize,
                mainAxisSpacing: 12.wMin,
                crossAxisSpacing: 12.wMin,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                return buildBoxItem(index);
              },
            ),
          ),
          ...List.generate(wordList.length, (index) {
            return Positioned(
              left: wordList[index].offset.dx,
              top: wordList[index].offset.dy,
              child: buildWordWidget(wordList[index], index),
            );
          }),
        ],
      );
    }

    Widget buildWordDirectionWidget() {
      Widget buildWordDirectionButton(bool isHorizontal, String text) {
        Color color = const Color(0xff353E5C);
        VFillWordData? currnt = getCurrentWord();
        if (currnt != null) {
          if (currnt.isHorizontal == isHorizontal) color = const Color(0xffFF781F);
        }

        return TapScaleWidget(
          onTap: () {
            _onTapDirection(isHorizontal);
          },
          sclae: 1.05,
          child: Container(
            height: 40.wMin,
            padding: EdgeInsets.symmetric(horizontal: 12.wMin),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: color,
            ),
            child: Row(
              spacing: 6.wMin,
              children: [
                Container(
                  width: 25.wMin,
                  alignment: Alignment.center,
                  child: Container(
                    width: isHorizontal ? 22.wMin : 14.wMin,
                    height: isHorizontal ? 14.wMin : 22.wMin,
                    decoration: BoxDecoration(
                      border: Border.all(width: 2.wMin, color: const Color(0xffEBEFF5)),
                      borderRadius: BorderRadius.circular(2.wMin),
                    ),
                  ),
                ),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: const Color(0xffEBEFF5),
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
          ),
        );
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 24.wMin,
        children: [
          Text(
            "单词方向",
            style: TextStyle(
              fontSize: 18.wMin,
              color: const Color(0xffEBEFF5),
              fontWeight: FontWeight.w400,
            ),
          ),
          buildWordDirectionButton(true, "横向"),
          buildWordDirectionButton(false, "竖向"),
        ],
      );
    }

    return DialogBoxWidget(
      title: "设置形式",
      width: 1080.wMin,
      onCancel: () => Get.back(),
      define: "下一步",
      onDefine: () {
        finishButton();
      },
      child: Container(
        key: dialogKey,
        margin: EdgeInsets.symmetric(horizontal: 24.wMin),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.wMin),
              child: Container(
                padding: EdgeInsets.all(24.wMin),
                decoration: BoxDecoration(
                  color: const Color(0xffC5C5C5).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20.wMin),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.37),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                    BoxShadow(color: const Color(0xff3D3D3D).withValues(alpha: 0.37), blurRadius: 3, offset: Offset(0, 5.wMin)),
                  ],
                ),
                child: buildWordContent(),
              ),
            ),
            SizedBox(height: 24.wMin),
            buildWordDirectionWidget(),
          ],
        ),
      ),
    );
  }
}

class QuizCrosswordManualResult {
  List<QuizModelStems> stems;
  List<QuizModelOptions> options;
  QuizCrosswordManualResult({
    required this.stems,
    required this.options,
  });
}

class VFillBlankBoxData {
  GlobalKey key;
  VFillWordPosition position;

  /// 是否匹配
  bool isMatch = false;
  VFillBlankBoxData({
    required this.key,
    required this.position,
  });
}

class VFillWordData {
  String wordText;

  /// 单词在表格中所在移动的位置(像素位置) 初始和initOffset一样
  Offset offset;

  /// 单词在表格中所在的初始位置(像素位置)
  Offset initOffset;

  /// 是否是横向排列
  bool isHorizontal;

  /// 是否选中
  bool isSelect;
  GlobalKey key;
  VFillWordPosition startPosition;
  List<VFillGridLetterData> word;
  String? imageUrl;
  String? audioUrl;
  VFillWordData({
    required this.wordText,
    required this.offset,
    required this.initOffset,
    required this.isHorizontal,
    required this.key,
    required this.word,
    required this.startPosition,
    this.isSelect = false,
    this.imageUrl,
    this.audioUrl,
  });
}

class VFillGridLetterData {
  /// 单个字母
  String text;
  bool isErr = false;
  bool isSelect = false;

  /// 字母在表格中的下标位置
  VFillWordPosition position;
  GlobalKey key;
  Size size;
  VFillGridLetterData({
    required this.text,
    required this.key,
    required this.size,
    required this.position,
  });
}

class VFillWordsData {
  VFillWordPosition startPosition;
  String text;
  String? imageUrl;
  String? audioUrl;
  String direction;
  // 是否是横向排列
  bool isHorizontal = false;

  VFillWordsData({
    required this.startPosition,
    required this.text,
    this.imageUrl,
    this.audioUrl,
    required this.direction,
  });
}

class VFillWordPosition {
  int x;
  int y;
  VFillWordPosition(this.x, this.y);

  String toString() {
    return "$x,$y";
  }
}
