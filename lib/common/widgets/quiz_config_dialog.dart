
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/components/widget/wise_switch.dart';
import 'package:quiz_play/quiz_play.dart';
import 'package:quiz_play/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../app/modules/management/common/manage_title_input_widget.dart';
import '../entities/entities.dart';

class QuizConfigDialogResult{
  QuizModelConfig quizModelConfig;
  QuizModel? quizData;
  String? desc;
  QuizConfigDialogResult({
    required this.quizModelConfig,
    required this.quizData,
    this.desc,
  });
}

/// 题型配置
class QuizConfigDialog{

  static Future<QuizConfigDialogResult?> show({
    required BuildContext context,
    required ManageQuizTemplateEntity data,
    bool showCancel = true,
    bool showDscribe = false,
    String title = '题型配置',
  }) async{

    return await showCupertinoDialog<QuizConfigDialogResult?>(
      context: context, 
      builder: (context) {
        return QuizConfigWidget(
          data: data, 
          showCancel: showCancel,
          title: title,
          showDscribe: showDscribe,
        );
      },
    );

  }

}

class QuizConfigWidget extends StatefulWidget {
  final ManageQuizTemplateEntity data;
  final String title;
  final bool showCancel;
  final bool showDscribe;
  const QuizConfigWidget({
    super.key, 
    required this.data, 
    required this.showCancel, 
    required this.title,
    this.showDscribe = false,
  });

  @override
  State<QuizConfigWidget> createState() => _QuizConfigWidgetState();
}

class _QuizConfigWidgetState extends State<QuizConfigWidget> {

  /// 变形配置
  QuizModelConfig deformationConfig = QuizModelConfig();

  /// 题目数据
  QuizModel? quizData;

  final TextEditingController _descController = TextEditingController();

  final GlobalKey dialogKey = GlobalKey();

  bool descError = false;

  @override
  void initState() {
    super.initState();

    _descController.text = widget.data.description??"";
    if((widget.data.description??"").isEmpty){
      _descController.text = widget.data.templateDescription??"";
    }

    QuizDeformationUtils.instance.initQuizTemplateEntity(widget.data);
    if(widget.data.exercise != null && widget.data.exercise?.config != null){
      deformationConfig = QuizModelConfig.fromJson(widget.data.exercise!.config!.toJson());
      if(widget.data.exercise?.type == ExerciseType.IMMERSIVE_CHAIN || 
      widget.data.exercise?.type == ExerciseType.PAIR_MATCHING || 
      widget.data.exercise?.type == ExerciseType.WORD_SEARCH){
        deformationConfig.optionCount = widget.data.exercise?.stems?.length;
      }else{
        deformationConfig.optionCount = widget.data.exercise?.options?.length;
      }

      quizData = QuizModel.fromJson(widget.data.exercise!.toJson());
    }
    
  }

  Future<void> getDeformationData() async{
    if(widget.data.exercise == null) return;
    try {
      ToastUtils.showLoading();
      quizData = await QuizDeformationUtils.instance.getQuizData(widget.data.exercise, deformationConfig);
    } finally{
      ToastUtils.hideLoading();
    }

    if(mounted) setState(() {});

  }

  @override
  Widget build(BuildContext context) {

    Widget buildQuizWidget(){
      return Expanded(
        child: Container(
          padding: EdgeInsets.all(11.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: const Color(0xff22293C),
            border: Border.all(width: 1.wMin, color: const Color(0xff23283D)),
          ),
          child: QuizPublicQuizWidget(
            key: ValueKey(quizData),
            borderRadius: 8.wMin,
            data: quizData,
          ),
        ),
      );
    }

    Widget buildTextBoxWidget(String text){
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
        decoration: BoxDecoration(
          border: Border.all(width: 1.wMin, color: const Color(0xff4B5268)),
          borderRadius: BorderRadius.circular(6.wMin),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16.wMin,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.white.withValues(alpha: 0.4), size: 20.wMin),
          ],
        ),
      );
    }

     Widget buildSwitchWidget(String name, bool value, {void Function(bool value)? onChanged, bool reasonable = true}){
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
        margin: EdgeInsets.only(top: 16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: const Color(0xff2E344E),
          border: Border.all(width: 0.5.wMin, color: const Color(0xff4B5268)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 16.wMin,
                color: const Color(0xffE5F5FF),
                fontWeight: FontWeight.w400,
              ),
            ),
            Row(
              children: [
                SizedBox(
                  height: 24.wMin,
                  child: IgnorePointer(
                    ignoring: !reasonable,
                    child: Opacity(
                      opacity: reasonable ? 1 : 0.6,
                      child: WiseSwitch(
                        value,
                        onChanged,
                        activeColor: Colors.white,
                        inactiveColor: Colors.white,
                        activeFrameColor: const Color(0xff2FB2FF),
                        activeTrackColor: const Color(0xff2FB2FF),
                        inactiveFrameColor: const Color(0xff00436D),
                        inactiveTrackColor: const Color(0xff00436D),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.wMin),
                Text(
                  value ? "开启" : "关闭",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: const Color(0xffACB4C0),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget buildConfigWidget(){

      Widget buildStemNameWidget(){
        List<QuizDeformationDisplayKV> stemScope = QuizDeformationUtils.instance.getStemScopeList()??[];
        if(stemScope.isEmpty) return Container();
        int stemIndex = QuizDeformationUtils.instance.getStemIndex(deformationConfig.stemDisplay)??0;

        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "题干模式",
                style: TextStyle(
                  fontSize: 14.wMin,
                  color: const Color(0xffEBEEF3),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 14.wMin),
              IconDropdownCheckWidget(
                selectIndex: stemIndex,
                backColor: const Color(0xff353E5C),
                hoverColor: const Color(0xff49557A),
                highlightColor: Colors.transparent,
                borderolor: const Color(0xff767E95),
                dividerColor: Colors.transparent,
                sclae: 1.01,
                itemHeight: 50.wMin,
                fontColor: const Color(0xffEBEEF3),
                fontSize: 16.wMin,
                child: buildTextBoxWidget(stemScope[stemIndex].name),
                items: List.generate(stemScope.length, (index){
                  return IconDropdownCheckData(
                    title: stemScope[index].name,
                  );
                }),
                onTap: (data, index) {
                  if(stemIndex == index) return;
                  deformationConfig.stemDisplay = stemScope[index].value;

                  // 如果此题干模式在所有选项模式中没有对应，则设置选项模式为支持此题干的第一个
                  List<String> options = [];
                  List<QuizDeformationDisplayKV> stemScopeAll = QuizDeformationUtils.instance.getStemScopeList(isSet: false)??[];
                  for(QuizDeformationDisplayKV scope in stemScopeAll){
                    if(stemScope[index].value == scope.value){
                      options.add(scope.ohterValue);
                    }
                  }
                  if(!options.contains(deformationConfig.optionDisplay)){
                    deformationConfig.optionDisplay = options.first;
                  }

                  if(deformationConfig.stemDisplay == QuizDeformationUtils.displayAudio){
                    deformationConfig.stemAudio = true;
                  }
                  if(mounted) setState(() {});
                  getDeformationData();
                },
              ),
            ],
          ),
        );
      }

      Widget buildOptionNameWidget(){
        List<QuizDeformationDisplayKV> optionScope = QuizDeformationUtils.instance.getOptionScopeList()??[];
        if(optionScope.isEmpty) return Container();
        int optionIndex = QuizDeformationUtils.instance.getOptionIndex(deformationConfig.optionDisplay)??0;

        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "选项模式",
                style: TextStyle(
                  fontSize: 14.wMin,
                  color: const Color(0xffEBEEF3),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 14.wMin),
              IconDropdownCheckWidget(
                selectIndex: optionIndex,
                backColor: const Color(0xff353E5C),
                hoverColor: const Color(0xff49557A),
                highlightColor: Colors.transparent,
                borderolor: const Color(0xff767E95),
                dividerColor: Colors.transparent,
                sclae: 1.01,
                itemHeight: 50.wMin,
                fontColor: const Color(0xffEBEEF3),
                fontSize: 16.wMin,
                child: buildTextBoxWidget(optionScope[optionIndex].name),
                items: List.generate(optionScope.length, (index){
                  return IconDropdownCheckData(
                    title: optionScope[index].name, 
                  );
                }),
                onTap: (data, index) {
                  if(optionIndex == index) return;
                  deformationConfig.optionDisplay = optionScope[index].value;

                  // 如果此选项模式在所有题干模式中没有对应，则设置题干模式为支持此选项的第一个
                  List<String> stems = [];
                  List<QuizDeformationDisplayKV> optionScopeAll = QuizDeformationUtils.instance.getOptionScopeList(isSet: false)??[];
                  for(QuizDeformationDisplayKV scope in optionScopeAll){
                    if(optionScope[index].value == scope.value){
                      stems.add(scope.ohterValue);
                    }
                  }
                  if(!stems.contains(deformationConfig.stemDisplay)){
                    deformationConfig.stemDisplay = stems.first;
                  }

                  if(deformationConfig.optionDisplay == QuizDeformationUtils.displayAudio){
                    deformationConfig.optionAudio = true;
                  }
                  if(mounted) setState(() {});
                  getDeformationData();
                },
              ),
            ],
          ),
        );
      }

      Widget buildOptionNumberWidget(){
        List<int> optionNumberScope = QuizDeformationUtils.instance.getOptionNumberScopeList()??[];
        if(optionNumberScope.isEmpty) return Container(); 
        int optionNumberIndex = QuizDeformationUtils.instance.getOptionNumberIndex(deformationConfig.optionCount)??0;
        return Container(
          margin: EdgeInsets.only(top: 16.wMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "选项数",
                style: TextStyle(
                  fontSize: 14.wMin,
                  color: const Color(0xffEBEEF3),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 14.wMin),
              IconDropdownCheckWidget(
                selectIndex: optionNumberIndex,
                backColor: const Color(0xff353E5C),
                hoverColor: const Color(0xff49557A),
                highlightColor: Colors.transparent,
                borderolor: const Color(0xff767E95),
                dividerColor: Colors.transparent,
                sclae: 1.01,
                itemHeight: 50.wMin,
                fontColor: const Color(0xffEBEEF3),
                fontSize: 16.wMin,
                onTap: (data, index) {
                  if(optionNumberIndex == index) return;
                  deformationConfig.optionCount = optionNumberScope[index];
                  if(mounted) setState(() {});
                  getDeformationData();
                },
                items: List.generate(optionNumberScope.length, (index){
                  return IconDropdownCheckData(title: "${optionNumberScope[index]}");
                }),
                child: buildTextBoxWidget("${optionNumberScope[optionNumberIndex]}"),
              ),
            ],
          ),
        );
      }

      Widget buildInputModelWidget(){
        List<QuizDeformationKV> inputModes = QuizDeformationUtils.instance.getInputScopeList()??[];
        if(inputModes.isEmpty) return Container();
        int inputModelIndex = QuizDeformationUtils.instance.getInputIndex(deformationConfig.inputMode)??0;
        return Container(
          margin: EdgeInsets.only(top: 16.wMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "输入方式",
                style: TextStyle(
                  fontSize: 14.wMin,
                  color: const Color(0xffEBEEF3),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 14.wMin),
              IconDropdownCheckWidget(
                selectIndex: inputModelIndex,
                backColor: const Color(0xff353E5C),
                hoverColor: const Color(0xff49557A),
                highlightColor: Colors.transparent,
                borderolor: const Color(0xff767E95),
                dividerColor: Colors.transparent,
                sclae: 1.01,
                itemHeight: 50.wMin,
                fontColor: const Color(0xffEBEEF3),
                fontSize: 16.wMin,
                onTap: (data, index) {
                  if(inputModelIndex == index) return;
                  deformationConfig.inputMode = inputModes[index].value;
                  if(mounted) setState(() {});
                  getDeformationData();
                },
                items: List.generate(inputModes.length, (index){
                  return IconDropdownCheckData(title: inputModes[index].name);
                }),
                child: buildTextBoxWidget(inputModes[inputModelIndex].name),
              ),
            ],
          ),
        );
      }

      Widget buildBreakdownLevelWidget(){
        List<QuizDeformationKV> breakdownLevels = QuizDeformationUtils.instance.getBreakdownScopeList()??[];
        if(breakdownLevels.isEmpty) return Container();
        int breakdownLevelIndex = QuizDeformationUtils.instance.getBreakdownIndex(deformationConfig.breakdownLevel)??0;
        return Container(
          margin: EdgeInsets.only(top: 16.wMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "拆分等级",
                style: TextStyle(
                  fontSize: 14.wMin,
                  color: const Color(0xffEBEEF3),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 14.wMin),
              IconDropdownCheckWidget(
                selectIndex: breakdownLevelIndex,
                backColor: const Color(0xff353E5C),
                hoverColor: const Color(0xff49557A),
                highlightColor: Colors.transparent,
                borderolor: const Color(0xff767E95),
                dividerColor: Colors.transparent,
                sclae: 1.01,
                itemHeight: 50.wMin,
                fontColor: const Color(0xffEBEEF3),
                fontSize: 16.wMin,
                onTap: (data, index) {
                  if(breakdownLevelIndex == index) return;
                  deformationConfig.breakdownLevel = breakdownLevels[index].value;
                  if(mounted) setState(() {});
                  getDeformationData();
                },
                items: List.generate(breakdownLevels.length, (index){
                  return IconDropdownCheckData(title: breakdownLevels[index].name);
                }),
                child: buildTextBoxWidget(breakdownLevels[breakdownLevelIndex].name),
              ),
            ],
          ),
        );
      }


      Widget buildPreTeaching(){
        List<bool> preTeachingScope = QuizDeformationUtils.instance.getPreTeachingScopeList()??[];
        if(preTeachingScope.isEmpty) return Container();
        return buildSwitchWidget(
          "预先学习",
          deformationConfig.preTeaching??false,
          reasonable: preTeachingScope.length != 1,
          onChanged: (value) {
            deformationConfig.preTeaching = value;
            if(mounted) setState(() {});
            getDeformationData();
          },
        );
      }

      Widget buildStemAudio(){
        List<bool> stemAudioScope = QuizDeformationUtils.instance.getStemAudioScopeList()??[];
        if(stemAudioScope.isEmpty) return Container();
        bool stemIsAudio = deformationConfig.stemDisplay == QuizDeformationUtils.displayAudio;
        return buildSwitchWidget(
          "题干发音",
          deformationConfig.stemAudio??false,
          reasonable: stemAudioScope.length != 1 && !stemIsAudio,
          onChanged: (value) {
            deformationConfig.stemAudio = value;
            if(mounted) setState(() {});
            getDeformationData();
          },
        );
      }

      Widget buildOptionAudio(){
        List<bool> optionAudioScope = QuizDeformationUtils.instance.getOptionAudioScopeList()??[];
        if(optionAudioScope.isEmpty) return Container();
        bool optionIsAudio = deformationConfig.optionDisplay == QuizDeformationUtils.displayAudio;
        return buildSwitchWidget(
          "选项发音",
          deformationConfig.optionAudio??false,
          reasonable: optionAudioScope.length != 1 && !optionIsAudio,
          onChanged: (value) {
            deformationConfig.optionAudio = value;
            if(mounted) setState(() {});
            getDeformationData();
          },
        );
      }

      Widget buildQuestionAudio(){
        List<bool> questionAudioScope = QuizDeformationUtils.instance.getQuestionAudioScopeList()??[];
        if(questionAudioScope.isEmpty) return Container();
        return buildSwitchWidget(
          "问题发音",
          deformationConfig.questionAudio??false,
          reasonable: questionAudioScope.length != 1,
          onChanged: (value) {
            deformationConfig.questionAudio = value;
            if(mounted) setState(() {});
            getDeformationData();
          },
        );
      }

      Widget buildFollowSentence(){
        List<bool> followSentenceScope = QuizDeformationUtils.instance.getFollowSentenceScopeList()??[];
        if(followSentenceScope.isEmpty) return Container();
        return buildSwitchWidget(
          "逐句显示",
          deformationConfig.followSentence??false,
          reasonable: followSentenceScope.length != 1,
          onChanged: (value) {
            deformationConfig.followSentence = value;
            if(mounted) setState(() {});
            getDeformationData();
          },
        );
      }

      Widget buildHighlight(){
        List<bool> highlightScope = QuizDeformationUtils.instance.getHighlightScopeList()??[];
        if(highlightScope.isEmpty) return Container();
        return buildSwitchWidget(
          "是否高亮",
          deformationConfig.highlight??false,
          reasonable: highlightScope.length != 1,
          onChanged: (value) {
            deformationConfig.highlight = value;
            if(mounted) setState(() {});
            getDeformationData();
          },
        );
      }

      return Container(
        width: 352.wMin,
        padding: EdgeInsets.all(16.wMin),
        constraints: BoxConstraints(
          minHeight: 1440.wMin / 2.46,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: const Color(0xff22293C),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 16.wMin,
              children: [
                buildStemNameWidget(),
                buildOptionNameWidget(),
              ],
            ),
            buildOptionNumberWidget(),
            buildInputModelWidget(),
            buildBreakdownLevelWidget(),
            buildPreTeaching(),
            buildStemAudio(),
            buildOptionAudio(),
            buildQuestionAudio(),
            buildFollowSentence(),
            buildHighlight(),
          ],
        ),
      );
    }

    return DialogBoxWidget(
      width: 1440.wMin,
      showCancel: widget.showCancel,
      title: widget.title,
      child: Container(
        key: dialogKey,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildQuizWidget(),
                SizedBox(width: 16.wMin),
                buildConfigWidget(),
              ],
            ),
            Visibility(
              visible: widget.showDscribe,
              child: Container(
                margin: EdgeInsets.only(top: 16.wMin),
                child: ManageTitleInputWidget(
                  title: "题型讲解",
                  maxLines: 3,
                  height: 100.wMin,
                  hintText: "请输入题型讲解",
                  required: true,
                  textInputAction: TextInputAction.newline,
                  error: descError,
                  controller: _descController,
                ),
              ),
            ),
          ],
        ),
      ),
      onCancel: () => Get.back(),
      onDefine: () {
        if(quizData == null) {
          ToastUtils.showManageToast(text: "题目数据异常", containerKey: dialogKey);
          return;
        }
        if(widget.showDscribe){
          if(widget.data.templateDescription == _descController.text){
            ToastUtils.showManageToast(text: "请完善题型讲解", containerKey: dialogKey);
            descError = true;
            if(mounted) setState(() {});
            Future.delayed(const Duration(seconds: 3), (){
              descError = false;
              if(mounted) setState(() {});
            });
            return;
          }
          if(_descController.text.isEmpty){
            ToastUtils.showManageToast(text: "请输入题型讲解", containerKey: dialogKey);
            descError = true;
            if(mounted) setState(() {});
            Future.delayed(const Duration(seconds: 3), (){
              descError = false;
              if(mounted) setState(() {});
            });
            return;
          }
        }
        QuizConfigDialogResult result = QuizConfigDialogResult(
          quizModelConfig: deformationConfig,
          quizData: quizData!,
          desc: _descController.text,
        );
        Get.back(result: result);
      },
      showOther: true,
      other: "演示",
      onOther: () {
        TagRoutes.toNamed(
          Routes.PRACTICE_QUESTIONS,
          arguments: {
            "quizDatas": [quizData],
          },
        );
      },
    );
  }


}
