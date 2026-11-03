import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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


}