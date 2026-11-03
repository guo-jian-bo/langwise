/// 对比完形填空题 - 手动创建弹窗
///
/// 功能说明：
/// 1. 展示两个句子，让用户通过点击或拖动选择需要对比的词组
/// 2. 支持单词级别和词组级别的选择
/// 3. 自动生成对应的选项和答案
///
/// 数据结构：
/// 1. wordTextList/wordTextList1: 两个句子的单词列表，每个单词包含：
///    - text: 单词文本
///    - selected: 是否被选中
///    - key: 用于定位单词位置的GlobalKey
///
/// 2. optionsList: 选项列表，每个选项包含两组数据：
///    - controller: 文本输入控制器，存储选中的文本
///    - selectIndexs: 选中单词的索引列表
///    - id: 选项唯一标识
///
/// 交互流程：
/// 1. 点击/拖动选择：
///    - takeTurns标识控制当前在哪个句子中选择
///    - 支持连续选择相邻单词形成词组
///    - 自动过滤标点符号
///
/// 2. 选项生成：
///    - 第一句选中后创建新选项
///    - 第二句选中后完成一组对比
///    - 支持选项拖动排序
///
/// 3. 选项编辑：
///    - 可删除已创建的选项
///    - 删除时自动清除对应单词的选中状态
///
/// 实现要点：
/// 1. 使用GlobalKey准确定位每个单词的位置
/// 2. 通过GestureDetector实现拖动选择
/// 3. 使用ReorderableColumn支持选项拖动排序
/// 4. 严格控制选择顺序，确保对比的准确性

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:quiz_play/models/models.dart';
import 'package:reorderables/reorderables.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import 'package:langwise/app/modules/management/common/manage_title_check_text_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';

class ManageQuizContrastClozeManualDialog {
  static Future<List<QuizContrastClozeManualResult>?> show({
    required BuildContext context,
    required List<ManageUnitKnowledgeEntity> knowledgeList,
    int minOption = 2,
    int maxOption = 4,
  }) async {
    return await showCupertinoDialog<List<QuizContrastClozeManualResult>?>(
      context: context,
      builder: (context) {
        return ManageQuizContrastClozeManualDialogWidget(
          knowledgeList: knowledgeList,
          minOption: minOption,
          maxOption: maxOption,
        );
      },
    );
  }
}

class ManageQuizContrastClozeManualDialogWidget extends StatefulWidget {
  final List<ManageUnitKnowledgeEntity> knowledgeList;
  final int minOption;
  final int maxOption;
  const ManageQuizContrastClozeManualDialogWidget({
    super.key,
    required this.knowledgeList,
    this.minOption = 2,
    this.maxOption = 4,
  });

  @override
  State<ManageQuizContrastClozeManualDialogWidget> createState() => _ManageQuizContrastClozeManualDialogWidgetState();
}

class _ManageQuizContrastClozeManualDialogWidgetState extends State<ManageQuizContrastClozeManualDialogWidget> {
  List<List<ManageTitleCheckTextEntity>> wordsTextList = [
    // [
    //   ManageTitleCheckTextEntity(text: "The"),
    //   ManageTitleCheckTextEntity(text: "boy"),
    //   ManageTitleCheckTextEntity(text: "is"),
    //   ManageTitleCheckTextEntity(text: "eating"),
    //   ManageTitleCheckTextEntity(text: "an"),
    //   ManageTitleCheckTextEntity(text: "apple."),
    // ],
    // [
    //   ManageTitleCheckTextEntity(text: "The"),
    //   ManageTitleCheckTextEntity(text: "boys"),
    //   ManageTitleCheckTextEntity(text: "is"),
    //   ManageTitleCheckTextEntity(text: "eating"),
    //   ManageTitleCheckTextEntity(text: "the"),
    //   ManageTitleCheckTextEntity(text: "apples."),
    // ]
  ];

  List<List<ContrastClozeData>> optionsList = [];

  final GlobalKey dialogKey = GlobalKey();

  int selectFlagIndex = 0;

  /// 上下轮番标识
  int takeTurns = 0;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.knowledgeList.length; i++) {
      List<String> texts = widget.knowledgeList[i].content?.split(" ") ?? [];
      if (texts.isEmpty) return;
      List<ManageTitleCheckTextEntity> list = [];
      for (var str in texts) {
        list.add(ManageTitleCheckTextEntity(text: str, key: GlobalKey()));
      }
      wordsTextList.add(list);
    }

    // for(int i = 0; i < wordsTextList.length; i++){
    //   for(var item in wordsTextList[i]){
    //     item.key = GlobalKey();
    //   }
    // }
  }

  String substringString(String text) {
    final isPunctuation = RegExp(r'[,.!?;，。！？；]$').hasMatch(text[text.length - 1]);
    if (isPunctuation) {
      text = text.substring(0, text.length - 1);
    }
    return text;
  }

  void selectItem(int index, List<ManageTitleCheckTextEntity> list) {
    if (widget.maxOption - 1 < selectFlagIndex * widget.knowledgeList.length) {
      ToastUtils.showManageToast(text: "最多可选择${widget.maxOption}个选项");
      return;
    }
    if (list[index].seelcted) return;
    list[index].seelcted = true;
    String text = substringString(list[index].text);

    List<ContrastClozeData>? testList;
    try {
      testList = optionsList[selectFlagIndex];
      // ignore: empty_catches
    } catch (e) {}

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
    if (takeTurns >= widget.knowledgeList.length) takeTurns = 0;
    if (mounted) setState(() {});
  }

  /// 记录滑动开始时的选择状态
  int? _lastProcessedIndex;
  List<int> panSelectIndexs = [];

  void _handlePanStart(DragStartDetails details, bool isFirstRow) {
    _lastProcessedIndex = null;
  }

  void _handlePanUpdate(DragUpdateDetails details, List<ManageTitleCheckTextEntity> currentList) {
    if (widget.maxOption - 1 < selectFlagIndex * widget.knowledgeList.length) {
      ToastUtils.showManageToast(text: "最多可选择${widget.maxOption}个选项");
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
            // 检查是否与已选中的单词相邻
            bool isAdjacent = false;
            if (panSelectIndexs.isEmpty) {
              isAdjacent = true; // 第一个选中的单词
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
    if (mounted) setState(() {});
  }

  void _handlePanEnd(DragEndDetails details, List<ManageTitleCheckTextEntity> currentList) {
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
        // ignore: empty_catches
      } catch (e) {}

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
      if (takeTurns >= widget.knowledgeList.length) takeTurns = 0;
      if (mounted) setState(() {});
    }

    panSelectIndexs.clear();
    if (mounted) setState(() {});
  }

  void delOption(int index) {
    List<ContrastClozeData> list = optionsList[index];

    int select = 0;

    for (int i = 0; i < list.length; i++) {
      for (var item in wordsTextList) {
        for (int itemIndex in list[i].selectIndexs) {
          if (item[itemIndex].seelcted) {
            item[itemIndex].seelcted = false;
            select++;
          }
        }
      }
    }

    optionsList.removeAt(index);
    takeTurns = 0;
    if (select == wordsTextList.length) selectFlagIndex--;
    if (mounted) setState(() {});
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
      // 检查当前单词是否在任何选项中
      bool isSelected = false;
      int optionIndex = 0;

      for (int j = 0; j < optionList.length; j++) {
        if (optionList[j].selectIndexs.contains(i)) {
          isSelected = true;
          optionIndex = resultTextIndex;
          break;
        }
      }

      // 如果是选中的单词，使用{n}格式替换
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

  @override
  Widget build(BuildContext context) {
    Widget buildOptionWidget(int index) {
      return Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 16.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.wMin),
              color: const Color(0xff141828).withValues(alpha: 0.4),
            ),
            child: Row(
              spacing: 16.wMin,
              children: List.generate(optionsList[index].length, (index1) {
                return Expanded(
                  child: ManageTitleInput1Widget(
                    title: "${(index * 2) + (index1) + 1}",
                    subTitle: "正确答案",
                    enabled: false,
                    error: optionsList[index][index1].error,
                    inputFontColor: const Color(0xffFF781F),
                    controller: optionsList[index][index1].controller,
                  ),
                );
              }),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: TapScaleWidget(
              onTap: () => delOption(index),
              child: Container(
                padding: EdgeInsets.all(10.wMin),
                color: Colors.transparent,
                child: SvgPicture.asset(
                  "assets/svg/manage/icon_close.svg",
                  width: 16.wMin,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return DialogBoxWidget(
      title: "手动创建",
      width: 1080.wMin,
      onCancel: () => Get.back(),
      define: "下一步",
      onDefine: () {
        for (int i = 0; i < optionsList.length; i++) {
          for (var item in optionsList[i]) {
            if (item.selectIndexs.isEmpty) {
              ToastUtils.showManageToast(text: "选项必须对应", containerKey: dialogKey);
              item.error = true;
              if (mounted) setState(() {});
              Future.delayed(const Duration(milliseconds: 3000), () {
                item.error = false;
                if (mounted) setState(() {});
              });
              return;
            }
          }
        }

        if (widget.minOption > selectFlagIndex * widget.knowledgeList.length) {
          ToastUtils.showManageToast(text: "最少要添加${widget.minOption}个选项");
          return;
        }

        List<QuizContrastClozeManualResult> result = [];
        for (int i = 0; i < wordsTextList.length; i++) {
          String text = getResText(i);
          print(text);
          List<QuizModelOptions> options = getOptions(i);
          result.add(QuizContrastClozeManualResult(
            text: text,
            options: options,
            image: widget.knowledgeList[i].imageUrl,
            audio: widget.knowledgeList[i].audioUrl,
            textAss: widget.knowledgeList[i].sentenceAssList?.first,
          ));
        }

        Get.back(result: result);
      },
      child: Container(
        key: dialogKey,
        height: 800.wMin,
        margin: EdgeInsets.symmetric(horizontal: 24.wMin),
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: const Color(0xff22293C),
        ),
        child: Column(
          spacing: 24.wMin,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...List.generate(wordsTextList.length, (listIndex) {
              return IgnorePointer(
                ignoring: takeTurns != listIndex,
                child: GestureDetector(
                  onPanStart: (details) => _handlePanStart(details, true),
                  onPanUpdate: (details) => _handlePanUpdate(details, wordsTextList[listIndex]),
                  onPanEnd: (details) => _handlePanEnd(details, wordsTextList[listIndex]),
                  child: ManageTitleCheckTextWidget(
                    title: listIndex == 0 ? "题目" : null,
                    textList: wordsTextList[listIndex],
                    isFocus: takeTurns == listIndex,
                    onTap: (index) => selectItem(index, wordsTextList[listIndex]),
                  ),
                ),
              );
            }),
            Row(
              children: [
                Text(
                  "选项",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: const Color(0xffACB4C0),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Expanded(
                  child: Container(height: 0.5.wMin, color: Colors.white.withValues(alpha: 0.4)),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: ReorderableColumn(
                  buildDraggableFeedback: (context, constraints, child) {
                    return Transform.scale(
                      scale: 1.02,
                      child: Container(
                        constraints: constraints,
                        child: child,
                      ),
                    );
                  },
                  onReorder: (oldIndex, newIndex) {
                    List<ContrastClozeData> row = optionsList.removeAt(oldIndex);
                    optionsList.insert(newIndex, row);
                    if (mounted) setState(() {});
                  },
                  children: List.generate(optionsList.length, (index) {
                    return Container(
                      key: Key(index.toString()),
                      margin: EdgeInsets.only(bottom: 16.wMin),
                      child: buildOptionWidget(index),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizContrastClozeManualResult {
  List<QuizModelOptions> options;
  String text;
  String? image;
  String? audio;
  String? textAss;
  QuizContrastClozeManualResult({
    required this.options,
    required this.text,
    this.image,
    this.audio,
    this.textAss,
  });
}

class ContrastClozeData {
  TextEditingController controller;
  List<int> selectIndexs;
  int id;
  bool error = false;

  ContrastClozeData({
    required this.controller,
    required this.selectIndexs,
    this.id = 0,
  });
}
