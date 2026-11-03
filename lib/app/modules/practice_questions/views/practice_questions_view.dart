
import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:quiz_play/models/quiz_operation_steps_model.dart';
import 'package:quiz_play/models/quiz_play_show_config.dart';
import 'package:quiz_play/quiz_play.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/third_party_account_entity.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../management/common/commons.dart';
import '../../management/utils/utils.dart';
import '../common/practice_questions_alarm_widget.dart';
import '../common/practice_questions_float_widget.dart';
import '../common/practice_questions_progress_widget.dart';
import '../common/practice_questions_quiz_widget.dart';
import '../controllers/practice_questions_controller.dart';
import '../common/practice_questions_Indicators_widget.dart';

class PracticeQuestionsView extends GetView<PracticeQuestionsController> {
  const PracticeQuestionsView({super.key});

  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if(!controller.endPractice.value){
          controller.showQuizNumber(context);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Scaffold(
            backgroundColor: AppTheme.cBgSolid.color,
            endDrawerEnableOpenDragGesture: false,
            body: _buildQuizWidget(context),
          );
        }
      ),
    );
  }


  /// 题目
  Widget _buildQuizWidget(BuildContext context){
    return Container(
      key: const ValueKey(0),
      child: Obx((){
        if(controller.questionDataList.isEmpty) return Container();
        if(controller.currentQuizIndex.value >= controller.questionDataList.length){
          return Container();
        }
        ThirdPartyAccountEntityListApp? soundAccount = controller.soundAccount.value.app;
        ConfigController configController = Get.find<ConfigController>();
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                buildTitle(context),
                Expanded(
                  child: Visibility(
                    visible: controller.isShowQuestion.value,
                    child: FutureBuilder<bool>(
                      initialData: false,
                      future: Future.delayed(const Duration(milliseconds: 200), (){
                        return true;
                      }),
                      builder: (context, snapshot) {
                        return AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: snapshot.data ?? false ? 1 : 0,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              final currentIndex = controller.currentQuizIndex.value;
                              final isNewWidget = child.key == ValueKey("$currentIndex${soundAccount?.appId}${soundAccount?.secretKey}");
                              Animation<Offset> slide = Tween<Offset>(
                                begin: Offset(0, controller.previousQuizIndex > currentIndex ? -1 : 1),
                                end: Offset.zero,
                              ).animate(animation);
                              Animation<double> slideFade = Tween<double>(begin: 0, end: 1).animate(animation);
                              if (isNewWidget) {
                                slide = Tween<Offset>(
                                  begin: Offset(0, controller.previousQuizIndex > currentIndex ? 1 : -1),
                                  end: Offset.zero,
                                ).animate(animation);
                                slideFade = Tween<double>(begin: 0, end: 1).animate(animation);
                              }
                              return FadeTransition(
                                opacity: slideFade,
                                child: SlideTransition(position: slide, child: child),
                              );
                            },
                            child: PracticeQuestionsQuizWidget(
                              key: ValueKey("${controller.currentQuizIndex.value}${soundAccount?.appId}${soundAccount?.secretKey}"),
                              soundAccount: controller.soundAccount.value,
                              stateController: controller.quizStateController,
                              data: controller.questionDataList[controller.currentQuizIndex.value].data,
                              letters: Get.find<ConfigController>().quizLetters.toList(),
                              endPractice: controller.endPractice.value,
                              showConfig: QuizPlayShowConfig(
                                showGloss: controller.isShowImageGloss && configController.userSetting.value.courseLang != LangPreference.none,
                              ),
                              isShowUpDownStatus: controller.isShowUpDownStatus,
                              listener: QuizPlayListener(
                                onFinish: (log) {
                                  controller.quizPlayOnResult(context, log);
                                },
                                onLogMidwayReport: (log) {
                                  controller.onLogMidwayReport(log);
                                },
                                onStep: (log) {
                                  controller.currentStep(log);
                                },
                                onErrorCount: (errorCount) async{
                                  return await controller.currentErrorCount(context, errorCount);
                                },
                                onEvalObtainWordData: (reqData) async{
                                  return await PracticeQuestionsReqest.getAssessmentWord(reqData);
                                },
                                onLog: (data) {
                                  ErrorLogUtils.to.logInfo(data);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Obx((){
              if(!controller.isShowSkipButton.value) return Container();
              return PracticeQuestionsFloatWidget(
                onTap: () {
                  controller.skipCurrentQuiz(context);
                },
              );
            }),
            Positioned(
              top: 8.wMin + MediaQuery.of(context).padding.top,
              child: Obx((){
                
                if(!controller.isShowQuestion.value) return Container();
                if(!controller.isShowPercentageProgress) return Container();
                return PracticeQuestionsProgressWidget(
                  questionDataList: controller.questionDataList,
                );
              }),
            ),

            Obx((){
              if(controller.questionDataList.isEmpty) return Container();
              if(controller.currentQuizIndex.value >= controller.questionDataList.length) return Container();
              QuizModel data = controller.questionDataList[controller.currentQuizIndex.value].data;

              List<QuizModelGloss?> guide = data.guide??[];
              List<LanguageText> texts = [];
              for(var item in guide){
                if(item == null) continue;
                texts.add(LanguageText.fromJson(item.toJson()));
              }
              texts = LearningLangUtils.sortLocalLangFirst(texts);
              if(texts.isEmpty) return Container();

              return Visibility(
                visible: controller.isShowAnnouncement.value,
                child: Positioned(
                  top: 110.wMin,
                  key: ValueKey(data.uid),
                  child: FutureBuilder(
                    initialData: false,
                    future: Future.delayed(const Duration(milliseconds: 100), () => true),
                    builder: (context, snapshot) {
                      return AnimatedOpacity(
                        opacity: snapshot.data ?? false ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: AnnouncementRotationWidget(
                          text: texts.map((e) => e.text??"").toList().join(" "),
                          onClose: () {
                            controller.closeAnnouncement();
                          },
                        ),
                      );
                    },
                  ),
                ),
              );
            }),



          ],
        );
      }),
    );
  }

  /// 倒计时
  Widget buildCountdown(BuildContext context) {
    return Obx(() {
      // if(!controller.isShowQuestion.value) return Container();

      String countdownText = "";
      if(controller.isCountdown.value){
        countdownText = DateFormatUtil.convertSecondsToMinSec(controller.countdownSecond.value);
      }else{
        countdownText = DateFormatUtil.convertSecondsToMinSec(controller.allCountdownSecondDate);
      }

      /// 最后一分钟
      bool lastOneMinute = controller.countdownSecond.value <= 60;

      double fontSize = 28.wMin;
      if(lastOneMinute){
        fontSize = 30.wMin;
      }
      if(!controller.isCountdown.value){
        fontSize = 20.wMin;
      }
      
      return Row(
        children: [
          SizedBox(width: 40.wMin),
          
          Container(
            alignment: Alignment.centerRight,
            width: 100.wMin,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedSize(
                  alignment: Alignment.centerRight,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      Animation<Offset> slide = Tween<Offset>(
                        begin: const Offset(0, -1),
                        end: Offset.zero,
                      ).animate(animation);
                      return SlideTransition(position: slide, child: child);
                    },
                    child: SizedBox(
                      height: controller.isCountdown.value ? 0 : null,
                      child: Text(
                        "+${DateFormatUtil.convertSecondsToMinSec(controller.countingSecond.value)}",
                        key: ValueKey(controller.isCountdown.value),
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cFeedbackWarningText.color,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedScale(
                  duration: const Duration(milliseconds: 100),
                  scale: lastOneMinute ? 1.2 : 1,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    child: lastOneMinute && controller.isCountdown.value ? BorderedText(
                      child: Text(countdownText),
                      strokeWidth: 2.wMin,
                      strokeColor: AppTheme.cTextPrimary.color,
                    ) : Text(countdownText),
                    style: TextStyle(
                      fontSize: fontSize,
                      color: lastOneMinute && controller.isCountdown.value ? AppTheme.cFeedbackErrorText.color : AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                
              ],
            ),
          ),

          SizedBox(width: 20.wMin),
          /// 闹钟图标
          GestureDetector(
            onDoubleTap: () {
              if(!UserStore.to.rolePermissions.value.isOfficial) return;
              controller.quizPlayOnResult(context, QuizLogModel());
              // controller.completeTask(context);
            },
            child: PracticeQuestionsAlarmWidget(
              isPause: controller.isPause.value,
              isCountdown: controller.isCountdown.value,
              countdownSecondProgress: controller.countdownSecondProgress.value,
              onTap: () {
                ErrorLogUtils.to.logInfo("练习 ----- 闹钟图标点击，当前题目索引: ${controller.currentQuizIndex.value}");
                controller.showQuizNumber(context);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget buildTitle(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        right: 80.wMin,
      ),
      margin: EdgeInsets.only(top: 30.wMin + MediaQuery.of(context).padding.top),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: FutureBuilder<bool>(
              initialData: false,
              future: Future.delayed(const Duration(milliseconds: 300), (){
                return true;
              }),
              builder: (context, snapshot) {
                return AnimatedOpacity(
                  opacity: snapshot.data ?? false ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Obx(() {
                    return PracticeQuestionsIndicatorsWidget(
                      scrollController: controller.indicatorScrollController,
                      current: controller.currentQuizIndex.value,
                      paddingLeft: 310.wMin,
                      list: List.generate(controller.questionDataList.length, (index) {
                        return PracticeQuestionsIndicatorsData(
                          key: controller.questionDataList[index].key,
                          purpose: controller.questionDataList[index].data.purpose,
                          result: controller.questionDataList[index].data.result,
                        );
                      }),
                    );
                  }),
                );
              },
            ),
          ),
          buildCountdown(context),

          Obx((){
            if(controller.questionDataList.isEmpty) return Container();
            if(controller.currentQuizIndex.value >= controller.questionDataList.length) return Container();
            if(controller.questionDataList[controller.currentQuizIndex.value].data.editable != true) return Container();
            if(!controller.isAdminPage) return Container();
            return ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.exerciseEdit],
              child: Container(
                margin: EdgeInsets.only(left: 24.wMin),
                child: TapScaleWidget(
                  onTap: () {
                    controller.backPage(context, editQuiz: true);
                  },
                  sclae: 1.01,
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_edit.svg",
                    width: 38.wMin,
                    colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
                  ),
                ),
              ),
            );
          }),

        ],
      ),
    );
  }


}
