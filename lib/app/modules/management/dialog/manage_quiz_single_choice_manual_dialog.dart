import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import 'manage_select_knowledge_dialog.dart';
import '../common/manage_quiz_public_widget.dart';

class ManageQuizSingleChoiceManualDialog{
  static Future<QuizSingleChoiceManualResult?> show({
    required BuildContext context,
    required ManageUnitKnowledgeEntity stemKnowledge,
    required int unitId,
    int minOption = 2,
    int maxOption = 4,
    String? language,
    List<String?>? contentScope,
  }) async{
    return await showCupertinoDialog<QuizSingleChoiceManualResult?>(
      context: context, 
      builder: (context) {
        return ManageQuizSingleChoiceManualDialogWidget(
          minOption: minOption,
          maxOption: maxOption,
          stemKnowledge: stemKnowledge,
          unitId: unitId,
          contentScope: contentScope,
          language: language,
        );
      },
    );
  }
}

class ManageQuizSingleChoiceManualDialogWidget extends StatefulWidget {
  final int minOption;
  final int maxOption;
  final ManageUnitKnowledgeEntity stemKnowledge;
  final int unitId;
  final List<String?>? contentScope;
  final String? language;
  const ManageQuizSingleChoiceManualDialogWidget({
    super.key, 
    this.minOption = 2, 
    this.maxOption = 4, 
    required this.stemKnowledge, 
    required this.unitId, 
    this.contentScope,
    this.language,
  });

  @override
  State<ManageQuizSingleChoiceManualDialogWidget> createState() => _ManageQuizSingleChoiceManualDialogWidgetState();
}

class _ManageQuizSingleChoiceManualDialogWidgetState extends State<ManageQuizSingleChoiceManualDialogWidget> {
  final TextEditingController stemController = TextEditingController();

  TextEditingController answerController = TextEditingController();

  List<TextEditingController> optionList = [];

  final GlobalKey dialogKey = GlobalKey();
  bool answerErr = false;
  List<bool> optionErr = [];

  @override
  void initState() {
    super.initState();
    stemController.text = widget.stemKnowledge.content??"";
  }

  Future<void> addOption() async{
    if(optionList.length >= widget.maxOption - 1) {
      ToastUtils.showManageToast(text: "最多可以添加${widget.maxOption}个选项", containerKey: dialogKey);
      return;
    }
    optionList.add(TextEditingController());
    optionErr.add(false);
    if(mounted) setState(() {});
  }

  Future<ManageUnitKnowledgeEntity?> selectKnowledge({ManageUnitKnowledgeEntity? init}) async{
    List<ManageUnitKnowledgeEntity>? resList = await ManageSelectKnowledgeDialog.show(
      context: context, 
      unitId: widget.unitId,
      knowledgeSingle: true,
      contentScope: widget.contentScope,
      initKnowledges: init == null ? null : [init],
      language: widget.language,
    );
    if(resList == null || resList.isEmpty) return null;
    return resList.first;
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
          ToastUtils.showManageToast(text: "请输入正确答案", containerKey: dialogKey);
          answerErr = true;
          if(mounted) setState(() {});
          Future.delayed(const Duration(seconds: 3), (){
            answerErr = false;
            if(mounted) setState(() {});
          });
          return;
        }
        if(optionList.isEmpty){
          ToastUtils.showManageToast(text: "选择添加最少${widget.minOption}个选项", containerKey: dialogKey);
          return;
        }
        for(int i = 0; i < optionList.length; i++){
          if(optionList[i].text.isEmpty){
            ToastUtils.showManageToast(text: "请输入选项", containerKey: dialogKey);
            optionErr[i] = true;
            if(mounted) setState(() {});
            Future.delayed(const Duration(seconds: 3), (){
              optionErr[i] = false;
              if(mounted) setState(() {});
            });
            return;
          }
        }
        QuizSingleChoiceManualResult result = QuizSingleChoiceManualResult(
          stem: stemController.text,
          answer: answerController.text,
          options: optionList.map((e) => e.text).toList(),
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
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 290.wMin,
                  child: ManagePublicKnowledeRowItemWidget(
                    isFore: true,
                    showTR: false,
                    content: widget.stemKnowledge.content,
                    imageUrl: widget.stemKnowledge.imageUrl,
                    language: widget.language,
                    difficulty: widget.stemKnowledge.difficulty?.min,
                    audioUrl: widget.stemKnowledge.audioUrl,
                    definition: widget.stemKnowledge.definition,
                  ),
                ),
              ),
              ManageTitleInputWidget(
                title: "题目",
                hintText: "请输入题目",
                controller: stemController,
                focusOrder: 1,
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
                hintText: "请输入正确答案",
                error: answerErr,
                controller: answerController,
                inputFontColor: const Color(0xffFF781F),
                focusOrder: 2,
                tapSclae: 1.01,
              ),
              SizedBox(height: 24.wMin),
              Container(
                constraints: BoxConstraints(
                  maxHeight: 240.wMin,
                ),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12.wMin,
                    runSpacing: 12.wMin,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: List.generate(optionList.length, (index){
                      return SizedBox(
                        width: 324.5.wMin,
                        child: ManageTitleInput1Widget(
                          title: index == 0 ? "设置选项" : null,
                          subTitle: "选项",
                          hintText: "请输入选项",
                          error: optionErr[index],
                          controller: optionList[index],
                          focusOrder: (3 + index).toDouble(),
                          tapSclae: 1.01,
                          showDelIcon: true,
                          onDel: () {
                            optionErr.removeAt(index);
                            optionList.removeAt(index);
                            if(mounted) setState(() {});
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ),
              SizedBox(height: 24.wMin),
              TapScaleWidget(
                onTap: () {
                  addOption();
                },
                sclae: 1.01,
                child: DottedBorder(
                  radius: Radius.circular(8.wMin),
                  borderType: BorderType.RRect,
                  padding: EdgeInsets.zero,
                  color: const Color(0xff444B5F),
                  dashPattern: const [3, 2],
                  strokeWidth: 1.wMin,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20.wMin),
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
      ),
    );
  }
}

class QuizSingleChoiceManualResult{
  String stem;
  String answer;
  List<String> options;
  QuizSingleChoiceManualResult({
    required this.stem,
    required this.answer,
    required this.options,
  });
}
