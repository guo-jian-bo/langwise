
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:quiz_play/models/models.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import 'package:langwise/app/modules/management/common/manage_title_check_text_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';

/// 单词补全 - 手动创建弹窗
class ManageQuizWordCompletionManualDialog{
  static Future<WordCompletionManualResult?> show({
    required BuildContext context,
    required ManageUnitKnowledgeEntity knowledge,
    int minOption = 1,
    int maxOption = 4,
    int initOptionCount = 4,
  }) async{
    return await showCupertinoDialog<WordCompletionManualResult?>(
      context: context, 
      builder: (context) {
        return ManageQuizWordCompletionManualDialogWidget(
          knowledge: knowledge,
          initOptionCount: initOptionCount,
        );
      },
    );
  }
}

class ManageQuizWordCompletionManualDialogWidget extends StatefulWidget {
  final ManageUnitKnowledgeEntity knowledge;
  final int minOption;
  final int maxOption;
  final int initOptionCount;
  const ManageQuizWordCompletionManualDialogWidget({
    super.key, 
    required this.knowledge, 
    this.minOption = 1, 
    this.maxOption = 4,
    this.initOptionCount = 4,
  });

  @override
  State<ManageQuizWordCompletionManualDialogWidget> createState() => _ManageQuizWordCompletionManualDialogWidgetState();
}

class _ManageQuizWordCompletionManualDialogWidgetState extends State<ManageQuizWordCompletionManualDialogWidget> {
  
  // ManageTitleCheckTextEntity(text: "g", seelcted: false, activation: true);
  List<ManageTitleCheckTextEntity> wordTextList = [];

  final TextEditingController answerController = TextEditingController();
  List<TextEditingController> optionList = [];
  List<bool> optionErr = [];

  final GlobalKey dialogKey = GlobalKey();
  bool answerErr = false;

  @override
  void initState() {
    super.initState();
    String contentText = widget.knowledge.content ?? "";
    for(int i = 0; i < contentText.length; i++){
      wordTextList.add(ManageTitleCheckTextEntity(text: contentText[i]));
    }
    for(int i = 0; i < widget.initOptionCount - 1; i++){
      optionList.add(TextEditingController());
      optionErr.add(false);
    }
  }


  void selectItem(int index){

    wordTextList[index].seelcted = !wordTextList[index].seelcted;

    // 检查是否有任何字母被选中
    bool hasSelected = wordTextList.any((element) => element.seelcted);

    if (!hasSelected) {
      // 如果没有字母被选中，所有字母都处于激活状态
      for (var item in wordTextList) {
        item.activation = true;
      }
    } else {
      // 如果有字母被选中，只激活相邻字母
      for (int i = 0; i < wordTextList.length; i++) {
        bool hasAdjacentSelected = false;
        // 检查前一个字母是否被选中
        if (i > 0 && wordTextList[i - 1].seelcted) {
          hasAdjacentSelected = true;
        }
        // 检查后一个字母是否被选中
        if (i < wordTextList.length - 1 && wordTextList[i + 1].seelcted) {
          hasAdjacentSelected = true;
        }
        // 设置激活状态：当前字母未被选中时，只有相邻字母被选中才激活
        wordTextList[i].activation = wordTextList[i].seelcted || hasAdjacentSelected;
      }

      /// 如果选择多个 那么只有前后激活 中间禁止点击
      int fist = -1;
      int last = 0;
      for (int i = 0; i < wordTextList.length; i++) {
        if(wordTextList[i].seelcted){
          wordTextList[i].activation = false;
          if(fist == -1) fist = i;
          if(fist != -1){
            last = i;
          }
        }
      }
      wordTextList[fist].activation = true;
      wordTextList[last].activation = true;
    }
    getAnswer();
    if(mounted) setState(() {});
  }

  void getAnswer(){
    String answer = "";
    for (int i = 0; i < wordTextList.length; i++) {
      if(wordTextList[i].seelcted){
        answer += wordTextList[i].text;
      }
    }
    answerController.text = answer;
  }

  
  @override
  Widget build(BuildContext context) {

    return DialogBoxWidget(
      title: "手动创建",
      width: 1080.wMin,
      onCancel: () => Get.back(),
      define: "下一步",
      onDefine: () {
        if(answerController.text.isEmpty){
          ToastUtils.showManageToast(text: "请选择答案位置", containerKey: dialogKey);
          answerErr = true;
          if(mounted) setState(() {});
          Future.delayed(const Duration(seconds: 3), (){
            answerErr = false;
            if(mounted) setState(() {});
          });
          return;
        }
        String text = "";
        String textBlank = "";
        for(int i = 0; i < wordTextList.length; i++){
          if(wordTextList[i].seelcted){
            if(textBlank == ""){
              textBlank = "{{1}}";
              text += textBlank;
            }
          }else{
            text += wordTextList[i].text;
          }
        }

        List<QuizModelOptions> optionStrList = [QuizModelOptions(
          text: answerController.text,
          positions: [1],
        )];
        for(int i = 0; i < optionList.length; i++){
          if(optionList[i].text.isEmpty) {
            ToastUtils.showManageToast(text: "请输入选项", containerKey: dialogKey);
            optionErr[i] = true;
            if(mounted) setState(() {});
            Future.delayed(const Duration(seconds: 3), (){
              optionErr[i] = false;
              if(mounted) setState(() {});
            });
            return;
          }
          optionStrList.add(QuizModelOptions(
            text: optionList[i].text,
          ));
        }

        WordCompletionManualResult result = WordCompletionManualResult(
          knowledge: widget.knowledge,
          stems: QuizModelStems(
            text: text, 
            imageUrl: widget.knowledge.imageUrl,
            audioUrl: widget.knowledge.audioUrl,
            textAss: widget.knowledge.sentenceAssList?.first,
          ),
          options: optionStrList,
        );

        Get.back(result: result);
      },
      child: Container(
        key: dialogKey,
        margin: EdgeInsets.all(24.wMin),
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: const Color(0xff22293C),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ManageTitleCheckTextWidget(
              title: "题目",
              error: answerErr,
              textList: wordTextList,
              onTap: selectItem,
            ),
            SizedBox(height: 24.wMin),
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
            SizedBox(height: 24.wMin),
            ManageTitleInput1Widget(
              title: "位置",
              subTitle: "正确答案",
              error: answerErr,
              enabled: false,
              controller: answerController,
              inputFontColor: const Color(0xffFF781F),
            ),
            SizedBox(height: 24.wMin),
            FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Wrap(
                spacing: 12.wMin,
                runSpacing: 12.wMin,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: List.generate(optionList.length, (int index){
                  return SizedBox(
                    width: 324.6.wMin,
                    child: ManageTitleInput1Widget(
                      title: index == 0 ? "设置选项" : null,
                      controller: optionList[index],
                      error: optionErr[index],
                      focusOrder: index.toDouble(),
                      subTitle: "选项",
                      showDelIcon: optionList.length > widget.minOption,
                      onDel:  () {
                        optionList.removeAt(index);
                        if(mounted) setState(() {});
                      },
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 24.wMin),
            TapScaleWidget(
              onTap: (){
                if(optionList.length + 1 > widget.maxOption - 1) {
                  ToastUtils.showManageToast(text: "最多只能添加${widget.maxOption - 1}个选项");
                  return;
                }
                optionList.add(TextEditingController());
                if(mounted) setState(() {});
              },
              sclae: 1.01,
              child: DottedBorder(
                radius: Radius.circular(8.wMin),
                borderType: BorderType.RRect,
                padding: EdgeInsets.zero,
                color: const Color(0xff4B5268),
                dashPattern: [3.wMin, 3.wMin],
                strokeWidth: 1.wMin,
                child: Container(
                  height: 56.wMin,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/svg/manage/icon_add.svg",
                        height: 22.ww,
                      ),
                      Text(
                        "添加选项",
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: const Color(0xffEAECFF),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),


          ],
        ),
      ),
    );


  }
}

class WordCompletionManualResult{
  ManageUnitKnowledgeEntity knowledge;
  QuizModelStems stems;
  List<QuizModelOptions> options;
  WordCompletionManualResult({
    required this.knowledge,
    required this.stems,
    required this.options,
  });
}