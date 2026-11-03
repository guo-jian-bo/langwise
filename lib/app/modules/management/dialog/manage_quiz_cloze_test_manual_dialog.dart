import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_play/models/models.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import 'package:langwise/app/modules/management/common/manage_title_check_text_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';

class ManageQuizClozeTestManualDialog{
  static Future<QuizClozeTestManualResult?> show({
    required BuildContext context,
    required String content,
    int minOption = 1,
    int maxOption = 2,
  }) async{
    return await showCupertinoDialog<QuizClozeTestManualResult?>(
      context: context, 
      builder: (context) {
        return ManageQuizClozeTestManualDialogWidget(
          content: content,
          minOption: minOption,
          maxOption: maxOption,
        );
      },
    );
  }
}

class ManageQuizClozeTestManualDialogWidget extends StatefulWidget {
  final String content;
  final int minOption;
  final int maxOption;
  const ManageQuizClozeTestManualDialogWidget({
    super.key, 
    required this.content, 
    this.minOption = 1, 
    this.maxOption = 4,
  });

  @override
  State<ManageQuizClozeTestManualDialogWidget> createState() => _ManageQuizClozeTestManualDialogWidgetState();
}

class _ManageQuizClozeTestManualDialogWidgetState extends State<ManageQuizClozeTestManualDialogWidget> {
  final GlobalKey dialogKey = GlobalKey();


  List<ManageTitleCheckTextEntity> wordTextList = [
    // ManageTitleCheckTextEntity(text: "The"),
    // ManageTitleCheckTextEntity(text: "boy"),
    // ManageTitleCheckTextEntity(text: "is"),
    // ManageTitleCheckTextEntity(text: "eating"),
    // ManageTitleCheckTextEntity(text: "an"),
    // ManageTitleCheckTextEntity(text: "apple."),

    // ManageTitleCheckTextEntity(text: "The"),
    // ManageTitleCheckTextEntity(text: "boy"),
    // ManageTitleCheckTextEntity(text: "is"),
    // ManageTitleCheckTextEntity(text: "eating"),
    // ManageTitleCheckTextEntity(text: "an"),
    // ManageTitleCheckTextEntity(text: "apple."),

    // ManageTitleCheckTextEntity(text: "The"),
    // ManageTitleCheckTextEntity(text: "boy"),
    // ManageTitleCheckTextEntity(text: "is"),
    // ManageTitleCheckTextEntity(text: "eating"),
    // ManageTitleCheckTextEntity(text: "an"),
    // ManageTitleCheckTextEntity(text: "apple."),
  ];

  List<_ManageQuizClozeTestData> optionList = [];

    /// 记录滑动开始时的选择状态
  int? _lastProcessedIndex;
  List<int> panSelectIndexs = [];

  @override
  void initState() {
    super.initState();
    List<String> contentList = widget.content.split(" ");

    for(int i = 0; i < contentList.length; i++){
      wordTextList.add(ManageTitleCheckTextEntity(text: contentList[i], key: GlobalKey()));
    }

    // for(int i = 0; i < wordTextList.length; i++){
    //   wordTextList[i].key = GlobalKey();
    // }
  }

  String substringString(String text){
    final isPunctuation = RegExp(r'[,.!?;，。！？；]$').hasMatch(text[text.length - 1]);
    if(isPunctuation){
      text = text.substring(0, text.length - 1);
    }
    return text;
  }

  void selectItem(int index){
    if(optionList.length >= widget.maxOption) {
      ToastUtils.showManageToast(text: "最多可选择${widget.maxOption}个选项", containerKey: dialogKey);
      return;
    }
    if(!wordTextList[index].seelcted){
      wordTextList[index].seelcted = true;
      String text = substringString(wordTextList[index].text);
      optionList.add(_ManageQuizClozeTestData(
        controller: TextEditingController(text: text),
        selectList: [wordTextList[index]],
        selectIndexs: [index],
      ));
    }else{
      // for(int i = 0; i < optionList.length; i++){
      //   if(optionList[i].selectIndexs.contains(index)){
      //     optionList.removeAt(i);
      //     break;
      //   }
      // }
    }
    if(mounted) setState(() {});
  }

  void _handlePanStart(DragStartDetails details, bool isFirstRow) {
    _lastProcessedIndex = null;
  }

  void _handlePanUpdate(DragUpdateDetails details, bool isFirstRow) {
    if(optionList.length >= widget.maxOption) {
      ToastUtils.showManageToast(text: "最多可选择${widget.maxOption}个选项", containerKey: dialogKey);
      return;
    }
    
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);
    
    
    for (int i = 0; i < wordTextList.length; i++) {
      if (wordTextList[i].key?.currentContext != null) {
        final RenderBox textBox = wordTextList[i].key!.currentContext!.findRenderObject() as RenderBox;
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
              if(wordTextList[i].seelcted) continue;
              wordTextList[i].seelcted = true;
              if(!panSelectIndexs.contains(i)){
                wordTextList[i].seelcted = true;
                panSelectIndexs.add(i);
              }else{
                wordTextList[i].seelcted = false;
                panSelectIndexs.remove(i);
              }
            }
          }
          break;
        }
      }
    }
    if(mounted) setState(() {});
  }

  void _handlePanEnd(DragEndDetails details) {
    _lastProcessedIndex = null;
    if(panSelectIndexs.isEmpty) return;

    panSelectIndexs.sort();

    String text = "";
    List<ManageTitleCheckTextEntity> list = [];
    for(int i = 0; i < panSelectIndexs.length; i++){
      text += substringString(wordTextList[panSelectIndexs[i]].text);
      text += " ";
      list.add(wordTextList[panSelectIndexs[i]]);
    }
    optionList.add(_ManageQuizClozeTestData(
      controller: TextEditingController(text: text),
      selectList: list.toList(),
      selectIndexs: panSelectIndexs.toList(),
    ));
    panSelectIndexs.clear();
    if (mounted) setState(() {});
  }

  void delOption(int index){
    List<int> indexs0 = optionList[index].selectIndexs;
    for(int item in indexs0){
      wordTextList[item].seelcted = false;
    }
    List<int> indexs1 = optionList[index].selectIndexs;
    for(int item in indexs1){
      wordTextList[item].seelcted = false;
    }

    optionList.removeAt(index);
    if(mounted) setState(() {});
  }

  

  
  @override
  Widget build(BuildContext context) {
    return DialogBoxWidget(
      title: "手动创建",
      width: 1080.wMin,
      onCancel: () => Get.back(),
      define: "下一步",
      onDefine: () {
        if(widget.minOption > optionList.length){
          ToastUtils.showManageToast(text: "最少需要${widget.minOption}个选项", containerKey: dialogKey);
          return;
        }

        /// 1 返回一个text 比如数据 wordTextList(实际是实体类的text) = [cross,the,street]
        /// 2 格式= ‘{1} the {2}’ tip:{n}是持续增加的数字 判断optionList的selectIndexs包含的wordTextList的下标 
        /// 比如 [cross,the,street] optionList[j].selectIndexs 包含[cross,the,street]的 第0个 那么这个就是{1} 
        /// 3 重要：如果是selectIndexs=[0, 1] 也就是包含cross,the 那么结果应该是{1} street
        /// 如果selectIndexs=[3] 那么结果应该是cross the {1}

        String text = "";
        
        
        int optionOldIndex = -1;
        for(int i = 0; i < wordTextList.length; i++){
          
          // 检查当前单词是否在任何选项中
          bool isSelected = false;
          int optionIndex = 0;
          
          for(int j = 0; j < optionList.length; j++){
            if(optionList[j].selectIndexs.contains(i)){
              isSelected = true;
              optionIndex = j + 1;
              break;
            }
          }
          
          // 如果是选中的单词，使用{n}格式替换
          if(optionOldIndex == optionIndex) continue;
          if(i != 0) text += " ";
          if(isSelected){
            text += "{{$optionIndex}}";
            optionOldIndex = optionIndex;
          } else {
            text += wordTextList[i].text;
          }
        }

        List<QuizModelOptions> options = [];
        int optionIndex = 1;
        for(int i = 0; i < optionList.length; i++){
          String text = "";
          for(int j = 0; j < optionList[i].selectIndexs.length; j++){
            if(j != 0) text += " ";
            text += wordTextList[optionList[i].selectIndexs[j]].text;
          }
          options.add(QuizModelOptions(
            text: text,
            positions: [optionIndex],
          ));
          optionIndex ++;
        }

        print(text);
        print(options);
        QuizClozeTestManualResult result = QuizClozeTestManualResult(
          text: text,
          options: options,
        );
        Get.back(result: result);
      },
      child: Container(
        key: dialogKey,
        height: 600.wMin,
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
            GestureDetector(
              onPanStart: (details) => _handlePanStart(details, true),
              onPanUpdate: (details) => _handlePanUpdate(details, true),
              onPanEnd: _handlePanEnd,
              child: ManageTitleCheckTextWidget(
                title: "题目",
                textList: wordTextList,
                onTap: (index) => selectItem(index),
              ),
            ),

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
                child: Wrap(
                  spacing: 16.wMin,
                  runSpacing: 16.wMin,
                  children: List.generate(optionList.length, (index){
                    return SizedBox(
                      width: 490.wMin,
                      child: ManageTitleInput1Widget(
                        subTitle: "${index + 1}",
                        enabled: false,
                        showDelIcon: true,
                        controller: optionList[index].controller,
                        onDel: () => delOption(index),
                      ),
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

class QuizClozeTestManualResult{
  String text;
  List<QuizModelOptions> options;
  QuizClozeTestManualResult({
    required this.text,
    required this.options,
  });
}

class _ManageQuizClozeTestData{
  List<ManageTitleCheckTextEntity> selectList;
  List<int> selectIndexs;
  TextEditingController controller;

  _ManageQuizClozeTestData({
    required this.selectList,
    required this.controller,
    required this.selectIndexs,
  });
}