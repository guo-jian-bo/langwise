import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'package:langwise/app/modules/management/common/manage_title_check_text_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';

class ManageQuizListenFindWordManualDialog{
  static Future<String?> show({
    required BuildContext context,
    required String knowledgeText,
  }) async{
    return await showCupertinoDialog<String?>(
      context: context, 
      builder: (context) {
        return ManageQuizListenFindWordManualDialogWidget(
          knowledgeText: knowledgeText,
        );
      },
    );
  }
}

class ManageQuizListenFindWordManualDialogWidget extends StatefulWidget {
  final String knowledgeText;
  const ManageQuizListenFindWordManualDialogWidget({
    super.key, 
    required this.knowledgeText,
  });

  @override
  State<ManageQuizListenFindWordManualDialogWidget> createState() => _ManageQuizListenFindWordManualDialogWidgetState();
}

class _ManageQuizListenFindWordManualDialogWidgetState extends State<ManageQuizListenFindWordManualDialogWidget> {
  List<ManageTitleCheckTextEntity> wordTextList = [];
  final TextEditingController answerController = TextEditingController();

  final GlobalKey dialogKey = GlobalKey();
  bool answerErr = false;

  @override
  void initState() {
    super.initState();
    List<String> knowTextList = widget.knowledgeText.split(" ");
    for(int i = 0; i < knowTextList.length; i++){
      wordTextList.add(ManageTitleCheckTextEntity(text: knowTextList[i]));
    }
  }

  void selectItem(int index){
    for(int i = 0; i < wordTextList.length; i++){
      if(i == index){
        wordTextList[i].seelcted = true;
      }else{
        wordTextList[i].seelcted = false;
      }
    }
    String text = wordTextList[index].text;
    final isPunctuation = RegExp(r'[,.!?;，。！？；]$').hasMatch(text[text.length - 1]);
    if(isPunctuation){
      text = text.substring(0, text.length - 1);
    }
    answerController.text = text;
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
        Get.back(result: answerController.text);
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
              textList: wordTextList,
              error: answerErr,
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
              enabled: false,
              error: answerErr,
              controller: answerController,
              inputFontColor: const Color(0xffFF781F),
            ),
          ],
        ),
      ),
    );
  }
}
