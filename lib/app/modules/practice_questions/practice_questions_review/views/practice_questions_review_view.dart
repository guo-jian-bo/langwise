import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:quiz_play/models/quiz_play_show_config.dart';
import 'package:quiz_play/quiz_play.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'package:get/get.dart';

import '../../../../../common/entities/third_party_account_entity.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../theme/theme.dart';
import '../../../management/common/manage_auth_box_widget.dart';
import '../../../management/utils/manage_auth_utils.dart';
import '../../common/practice_questions_quiz_widget.dart';
import '../controllers/practice_questions_review_controller.dart';

class PracticeQuestionsReviewView extends GetView<PracticeQuestionsReviewController> {
  const PracticeQuestionsReviewView({super.key});
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppTheme.cBgSolid.color,
        body: Column(
          children: [
            _buildHeardWidget(context),
            Expanded(child: _buildQuizWidget()),
            _buildBottomButtonsWidget(context),
          ],
        ),
      ),
    );
  }


  Widget _buildHeardWidget(BuildContext context){
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10.wMin),
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              BackWidget(
                title: "题目审核",
                onTap: OptimizeUtils.noneThrottle(() {
                  controller.exitReview();
                }, 300),
              ),

              const Spacer(),
          
              Visibility(
                visible: !controller.isReviewHistory,
                child: ButtonWidget(
                  text: "审核历史",
                  width: 120.wMin,
                  height: 54.wMin,
                  borderRadius: 8.wMin,
                  color: const Color(0xff353E5C),
                  fontColor: AppTheme.cInverseTextLight.color,
                  fontSize: 20.wMin,
                  sclae: 1.03,
                  onTap: OptimizeUtils.noneThrottle(() {
                    controller.toReviewHistory();
                  }, 300),
                ),
              ),

              Visibility(
                visible: !controller.isReviewHistory,
                child: ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.exerciseReviewHistory],
                  margin: EdgeInsets.only(left: 12.wMin),
                  child: ButtonWidget(
                    text: "管理员",
                    width: 120.wMin,
                    height: 54.wMin,
                    borderRadius: 8.wMin,
                    color: const Color(0xff353E5C),
                    fontColor: AppTheme.cInverseTextLight.color,
                    fontSize: 20.wMin,
                    sclae: 1.03,
                    onTap: OptimizeUtils.noneThrottle(() {
                      controller.toReviewHistory(fromAdmin: true);
                    }, 300),
                  ),
                ),
              ),

              Obx((){
                int currentQuizIndex = controller.currentQuizIndex.value;
                if( controller.exerciseReviewList.isEmpty){
                  return Container();
                }
                bool isEdit = controller.exerciseReviewList[currentQuizIndex].exercise?.editable??false;
                return Visibility(
                visible: isEdit && controller.isAdminPage,
                  child: ManageAuthBoxWidget(
                    authCodes: const [ManageAuthCode.exerciseEdit],
                    margin: EdgeInsets.only(left: 12.wMin),
                    child: ButtonWidget(
                      text: "编辑题目",
                      width: 120.wMin,
                      height: 54.wMin,
                      borderRadius: 8.wMin,
                      color: const Color(0xff353E5C),
                      fontColor: AppTheme.cInverseTextLight.color,
                      fontSize: 20.wMin,
                      sclae: 1.03,
                      onTap: OptimizeUtils.noneThrottle(() {
                        controller.editExercises();
                      }, 300),
                    ),
                  ),
                );
              }),
          
            ],
          ),
          Obx((){
            if(controller.exerciseReviewList.isEmpty) return Container();
            int current = controller.currentQuizIndex.value;
            int length = controller.exerciseReviewList.length;
            return Text(
              "${current + 1} / $length",
              style: TextStyle(
                color: AppTheme.cTextPrimary.color,
                fontSize: 28.wMin,
                fontWeight: FontWeight.w400,
                fontFamily: "LangWiseFont",
              ),
            );
          }),
        ],
      ),
    );
  }


  /// 底部按钮
  Widget _buildBottomButtonsWidget(BuildContext context){
    return Container(
      padding: EdgeInsets.only(bottom: 16.wMin),
      child: Obx((){

        if(controller.isReviewAll.value){
          return Container();
        }

        if(controller.exerciseReviewList.isEmpty){
          return Container();
        }

        bool isReviewCurrentQuestion = controller.isReviewCurrentQuestion.value;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [


            Visibility(
              visible: !isReviewCurrentQuestion,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [

                  Visibility(
                    visible: !controller.isReviewHistory,
                    child: Container(
                      margin: EdgeInsets.only(right: 12.wMin),
                      child: _buildButtonItemWidget(
                        text: "太难不会做", //放弃 分发给其他人
                        color: AppTheme.cSurfaceWarning.color,
                        onTap: OptimizeUtils.noneThrottle(() {
                          controller.giveUp(context);
                        }, 300),
                      ),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(right: 12.wMin),
                    child: _buildButtonItemWidget(
                      text: "题目错误", // 1分 无法进行题目交互。比如漏选项什么的
                      color: AppTheme.cSurfaceError.color,
                      onTap: OptimizeUtils.noneThrottle(() {
                        controller.exercisesErr(context, 1);
                      }, 300),
                    ),
                  ),
                ],
              ),
            ),


            Visibility(
              visible: isReviewCurrentQuestion,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 12.wMin,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildButtonItemWidget(
                    text: "再做一遍",
                    color: const Color(0xff353E5C),
                    onTap: OptimizeUtils.noneThrottle(() {
                      controller.reGenerateQuiz();
                    }, 300),
                  ),
                  _buildButtonItemWidget(
                    text: "题目错误", // 1分 可以交互完成，但是题目还是有错的
                    color: AppTheme.cSurfaceError.color,
                    onTap: OptimizeUtils.noneThrottle(() {
                      controller.exercisesErr(context, 2);
                    }, 300),
                  ),
                  _buildButtonItemWidget(
                    text: "图片/音频有瑕疵", //4分
                    color: const Color(0xff2388FF),
                    onTap: OptimizeUtils.noneThrottle(() {
                      controller.approved(context, 4);
                    }, 300),
                  ),
                  _buildButtonItemWidget(
                    text: "一切完美", // 5分
                    color: const Color(0xff44AF5C),
                    onTap: OptimizeUtils.noneThrottle(() {
                      controller.approved(context, 5);
                    }, 300),
                  ),
                ],
              ),
            ),

          ],
        );
      }),
    );
  }


  Widget _buildButtonItemWidget({
    required String text,
    required Color color,
    void Function()? onTap,
    
  }){
    return ButtonWidget(
      text: text,
      color: color,
      onTap: onTap,
      width: 288.wMin,
      height: 56.wMin,
      borderRadius: 4.wMin,
      fontColor: AppTheme.cInverseTextLight.color,
      fontSize: 24.wMin,
      sclae: 1.03,
    );
  }



  /// 题目模块
  Widget _buildQuizWidget(){
    return Obx((){
      

      if(controller.isReviewAll.value){
        return _buildAnotherBatchWidget();
      }

      if(controller.isReviewCurrentQuestion.value){
        return _buildCurrentQuizFinishWidget();
      }

      if(controller.exerciseReviewList.isEmpty) return Container();
      
      if(controller.exerciseReviewList.length <= controller.currentQuizIndex.value) return Container();
      ThirdPartyAccountEntityListApp? soundAccount = controller.soundAccount.value.app;
      return AnimatedSwitcher(
        key: ValueKey(controller.reGenerateKey.value),
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
          data: controller.exerciseReviewList[controller.currentQuizIndex.value].exercise,
          letters: Get.find<ConfigController>().quizLetters.toList(),
          endPractice: false,
          showConfig: const QuizPlayShowConfig(
            showGloss: true,
          ),
          // isShowUpDownStatus: controller.isShowUpDownStatus,
          listener: QuizPlayListener(
            onFinish: (log) {
              controller.onFinish();
            },
            onLogMidwayReport: (log) {
              
            },
            onStep: (log) {
              
            },
            onEvalObtainWordData: (reqData) async{
              return await PracticeQuestionsReqest.getAssessmentWord(reqData);
            },
            onLog: (data) {
              
            },
          ),
        ),
      );
    });
  }


  /// 再来一批按钮
  Widget _buildAnotherBatchWidget(){
    return Center(
      child: NotDataWidget(
        message: "所有题目都已审核完成",
        other: Visibility(
          visible: controller.taskIds == null && controller.lessonId == null,
          child: ButtonWidget(
            text: "再来一批",
            width: 200.wMin,
            height: 60.wMin,
            borderRadius: 8.wMin,
            fontSize: 28.wMin,
            sclae: 1.02,
            onTap: OptimizeUtils.noneThrottle(() {
              controller.getMoreExerciseReviewList();
            }, 300),
            
          ),
        ),
      ),
    );
  }


  /// 当前题目执行完毕
  Widget _buildCurrentQuizFinishWidget(){
    return Container(
      alignment: Alignment.center,
      child: Text(
        "第 ${controller.currentQuizIndex.value + 1} 个题目已做完, 请评价。",
        style: TextStyle(
          fontSize: 38.wMin,
          color: AppTheme.cTextPrimary.color,
          fontWeight: FontWeight.w600,
        ),
      ),

    );
  }





}
