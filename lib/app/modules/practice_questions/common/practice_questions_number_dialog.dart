import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../../utils/utils.dart';
import '../model/quiz_info_model.dart';

class PracticeQuestionsNumberDialog{

  /// * 返回结果 null=继续 -1=退出 >-1序号
  static Future<int?> showTestQuizList({
    required BuildContext context,
    required RxList<QuizDataInfoModel> questionDataList,
    required RxInt currentQuizIndex,
    required RxInt originalQuizIndex,
    bool isCanSwitchByNumber = true,
  }) async{
    return await showCupertinoDialog<int?>(
      context: context,
      builder: (context) {
        return PracticeQuestionsNumberDialogWidget(
          questionDataList: questionDataList,
          currentQuizIndex: currentQuizIndex,
          originalQuizIndex: originalQuizIndex,
          isCanSwitchByNumber: isCanSwitchByNumber,
        );
      },
    );
  }
}

class PracticeQuestionsNumberDialogWidget extends StatefulWidget {
  final List<QuizDataInfoModel> questionDataList;
  final RxInt currentQuizIndex;
  final RxInt originalQuizIndex;
  final bool isCanSwitchByNumber;
  const PracticeQuestionsNumberDialogWidget({
    super.key,
    required this.questionDataList,
    required this.currentQuizIndex,
    required this.originalQuizIndex,
    this.isCanSwitchByNumber = true,
  });

  @override
  State<PracticeQuestionsNumberDialogWidget> createState() => _PracticeQuestionsNumberDialogWidgetState();
}

class _PracticeQuestionsNumberDialogWidgetState extends State<PracticeQuestionsNumberDialogWidget> {
  final ConfigController _configController = Get.find<ConfigController>();


  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 100.wMin,
          bottom: MediaQuery.of(context).padding.bottom + 100.wMin,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendPanel(),
            Visibility(
              visible: widget.questionDataList.isNotEmpty,
              child: Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 100.wMin,
                      right: 100.wMin,
                      top: 32.wMin,
                      bottom: 32.wMin,
                    ),
                    child: Obx((){
                      return Wrap(
                        spacing: 32.wMin,
                        runSpacing: 32.wMin,
                        children: List.generate(widget.questionDataList.length, (index) {
                          return _buildItemWidget(widget.questionDataList[index], index);
                        }),
                      );
                    }),
                  ),
                ),
              ),
            ),

            SizedBox(height: 24.wMin),
    
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 24.wMin,
              children: [
                _buildStopButtonWidget(),
                _buildContinueButtonWidget(),
              ],
            ),
    
          ],
        ),
      ),
    );
  }

  /// 继续按钮
  Widget _buildContinueButtonWidget(){
    return ButtonWidget(
      text: "继续",
      width: 400.wMin,
      height: 52.wMin,
      borderRadius: 8.wMin,
      color: AppTheme.cFeedbackSuccessBackground.color,
      border: Border.all(width: 2.wMin, color: AppTheme.cFeedbackSuccessBorder.color),
      fontSize: 28.wMin,
      fontColor: AppTheme.cFeedbackSuccessText.color,
      fontWeight: FontWeight.w500,
      sclae: 1.03,
      onTap: OptimizeUtils.noneThrottle(() {
        Get.back();
      }, 1000),
    );
  }

  Widget _buildStopButtonWidget(){
    return ButtonWidget(
      text: "结束",
      width: 400.wMin,
      height: 52.wMin,
      borderRadius: 8.wMin,
      color: AppTheme.cFeedbackErrorBackground.color,
      border: Border.all(width: 2.wMin, color: AppTheme.cFeedbackErrorBorder.color),
      fontSize: 28.wMin,
      fontColor: AppTheme.cFeedbackErrorText.color,
      fontWeight: FontWeight.w500,
      sclae: 1.03,
      onTap: OptimizeUtils.noneThrottle(() {
        Get.back(result: -1);
      }, 1000),
    );
  }

  Widget _buildItemWidget(QuizDataInfoModel data, int index){

    bool isNotCheck = (data.data.result == null || widget.currentQuizIndex.value == index) && widget.originalQuizIndex.value < index;
    if(!widget.isCanSwitchByNumber) isNotCheck = true;
    
    bool isAdmin = UserStore.to.rolePermissions.value.isOfficial;
    // isAdmin = false;

    String value = data.data.purpose??'';
    if(value.isNotEmpty){
      value = value.substring(0, 1);
    }

    bool isCurrent = index == widget.currentQuizIndex.value || widget.originalQuizIndex.value == index;
    LearnTypeColors bgBorderColor = StatusUtils.getLearnTypeColor(
      data.data.purpose??'', 
      result: data.data.result,
      isCurrent: isCurrent,
    );

    return Transform.scale(
      scale: isCurrent ? 1.15 : 1,
      child: TapScaleWidget(
        onTap: OptimizeUtils.noneThrottle(() {
          if(isNotCheck && !isAdmin) return;
          Get.back(result: index);
        }, 1000),
        sclae: isNotCheck && !isAdmin ? 1 : 1.05,
        child: AnimatedContainer(
          width: 85.wMin,
          height: 85.wMin,
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgBorderColor.statusBgColor.withValues(alpha: 1),
            border: Border.all(
              width: 5.wMin,
              color: bgBorderColor.statusBorderColor,
            ),
            boxShadow: [
              BoxShadow(
                color: bgBorderColor.shadowTypeColor,
                blurRadius: 2.wMin,
                spreadRadius: 6.wMin,
              ),
              BoxShadow(
                color: bgBorderColor.shadowTypeColor,
                spreadRadius: 4.wMin,
                blurRadius: 10.wMin,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${index + 1}",
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cStaticWhite.color,
                  height: 1,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.cStaticWhite.color,
                  fontFamily: "LangWiseFont",
                  height: 1,
                ),
              ),
        
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendPanel() {
    final testTypes = _buildLegendTestTypes();
    final scoreConfigs = _buildLegendScoreConfigs();
    if (testTypes.isEmpty && scoreConfigs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(

      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: 150.wMin,
        vertical: 20.wMin,
      ),
    
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 12.wMin,),
              Text(
            '学习标识状态',
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w700,
              color: AppTheme.cStaticWhite.color,
            ),
          ),
            ],
          ),
          SizedBox(height: 16.wMin),
          Row(
            children: [
              Expanded(child: _buildLegendGroup('题目类型', testTypes)),
              
              Expanded(child: _buildLegendGroup('作答情况', scoreConfigs)),
            ],
          ),
        ],
      ),
    
    
    );
  }

  Widget _buildLegendGroup(String title, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 12.wMin,),
            Text(
          title,
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cStaticWhite.color.withValues(alpha: 0.72),
          ),
        ),
          ],
        ),
        SizedBox(height: 16.wMin),
        Wrap(
          spacing: 24.wMin,
          runSpacing: 20.wMin,
          children: children,
        ),
      ],
    );
  }

  List<Widget> _buildLegendTestTypes() {
    final cachedItems = _configController.exerciseLearnScoreConfigs.value.testTypes ?? [];
    return cachedItems
        .where((item) => (item.code ?? '').trim().isNotEmpty && (item.title ?? '').trim().isNotEmpty)
        .map((item) => _buildTypeLegendItem(item.code!.trim(), item.title!.trim()))
        .toList();
  }

  List<Widget> _buildLegendScoreConfigs() {
    final cachedItems = _configController.exerciseLearnScoreConfigs.value.scoreConfigs ?? [];
    return cachedItems
        .where((item) => (item.title ?? '').trim().isNotEmpty)
        .map((item) => _buildScoreLegendItem(item.code?.trim(), item.title!.trim()))
        .toList();
  }

  Widget _buildTypeLegendItem(String code, String title) {
    final color = StatusUtils.getLearnTypeColor(code, isCurrent: true).shadowTypeColor;
    return SizedBox(
      width: 96.wMin,
      child: Column(
        children: [
          Container(
            width: 70.wMin,
            height: 70.wMin,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.cStaticBlack.color.withValues(alpha: 0.30),
              border: Border.all(
                width: 4.wMin,
                color: color,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.20),
                  blurRadius: 10.wMin,
                  spreadRadius: 2.wMin,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              code.substring(0, 1),
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w700,
                color: AppTheme.cStaticWhite.color,
                height: 1,
              ),
            ),
          ),
          SizedBox(height: 10.wMin),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cStaticWhite.color.withValues(alpha: 0.80),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreLegendItem(String? code, String title) {
    final color = StatusUtils.getLearnTypeColor(
      LearningTypeEnum.LEARN,
      result: code,
      isCurrent: true,
    );
    final bool isEmpty = (code ?? '').isEmpty;
    final bgColor = isEmpty ? AppTheme.cQuizDefaultBackground.color : color.statusBgColor;
    final borderColor = isEmpty ? AppTheme.cQuizDefaultBorder.color : color.statusBorderColor;
    return SizedBox(
      width: 110.wMin,
      child: Column(
        children: [
          Container(
            width: 70.wMin,
            height: 70.wMin,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
              border: Border.all(
                width: 4.wMin,
                color: borderColor,
              ),
            ),
            alignment: Alignment.center,
            child: null,
          ),
          SizedBox(height: 10.wMin),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cStaticWhite.color.withValues(alpha: 0.80),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }


}
