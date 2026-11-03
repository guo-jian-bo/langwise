
import 'package:flutter/material.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:quiz_play/models/quiz_operation_steps_model.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';
import 'package:quiz_play/quiz_play.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/entities/third_party_account_entity.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../common/practice_questions_alarm_widget.dart';
import '../../common/practice_questions_float_widget.dart';
import '../../common/practice_questions_quiz_widget.dart';
import '../bindings/practice_questions_eval_binding.dart';
import '../controllers/practice_questions_eval_controller.dart';
import '../../../../routes/routes.dart';

class PracticeQuestionsEvalView extends GetView<PracticeQuestionsEvalController> {
  final String tagText;
  const PracticeQuestionsEvalView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      PracticeQuestionsEvalView(tagText: tag),
      binding: PracticeQuestionsEvalBinding(tagText: tag),
      routeName: Routes.PRACTICE_QUESTIONS_EVAL,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

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
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              buildTitle(context),
              Expanded(
                child: Obx((){
                  if(!controller.isShowQuestion.value) return Container();
                  if(controller.questionDataList.isEmpty) return Container();
                  if(controller.currentQuizIndex.value >= controller.questionDataList.length) return Container();
                  ThirdPartyAccountEntityListApp? soundAccount = controller.soundAccount.value.app;
                  return FutureBuilder<bool>(
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
                            hideResultAutoEnd: true,
                            isJudgeScore: true,
                            listener: QuizPlayListener(
                              onFinish: (log) {
                                controller.quizPlayOnResult(context, log);
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
                              onAudioSourceStatus: (success, errorEvent, successEvent) {
                                if(success){
                                  controller.audioNetworkPlayErrClear();
                                }else{
                                  controller.audioNetworkPlayErr(errorEvent);
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
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
                  top: 40.wMin,
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
      ),
    );
  }

  Widget buildTitle(BuildContext context){
    double sysPaddingRight = MediaQuery.of(context).padding.right;
    double paddingRight = sysPaddingRight > 80.wMin ? sysPaddingRight : 80.wMin;
    return Container(
      padding: EdgeInsets.only(right: paddingRight),
      margin: EdgeInsets.only(top: 24.wMin + MediaQuery.of(context).padding.top),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Spacer(),

          buildCountdown(context),

          // Obx((){
          //   return AudioErrorWidget(
          //     errType: controller.audioErrorEvent.value?.type,
          //     retryCallback: () {
          //       controller.audioNetworkPlayErrRetry();
          //     },
          //   );
          // }),

        ],
      ),
    );
  }

  /// 倒计时
  Widget buildCountdown(BuildContext context) {
    return Obx(() {

      String countUpText = DateFormatUtil.convertSecondsToMinSec(controller.countUpSecond.value);
      
      return Row(
        children: [
          SizedBox(width: 40.wMin),
          
          Container(
            alignment: Alignment.centerRight,
            width: 100.wMin,
            child: Text(
              countUpText,
              style: TextStyle(
                fontSize: 32.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
          ),

          SizedBox(width: 16.wMin),
          /// 闹钟图标
          GestureDetector(
            onDoubleTap: () {
              if(!UserStore.to.rolePermissions.value.isOfficial) return;
              controller.quizPlayOnResult(context, QuizLogModel());
            },
            child: PracticeQuestionsAlarmWidget(
              isPause: controller.isPause.value,
              countdownSecondProgress: controller.countdownSecondProgress.value,
              onTap: () {
                controller.showQuizNumber(context);
              },
            ),
          ),
        ],
      );
    });
  }


}
