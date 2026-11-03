import 'package:flutter/material.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/widgets/guide_engine/guide_anchor.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../common/starry_background_widget.dart';
import '../controllers/mission_complete_controller.dart';

class MissionCompleteView extends GetView<MissionCompleteController> {
  const MissionCompleteView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: StarryBackgroundWidget(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTitleWidget(),
                // SizedBox(height: 48.wMin),
                Obx((){
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: !controller.isStarAnimationComplete.value ? 150.wMin : 48.wMin,
                  );
                }),
                _buildStarWidget(),
                _buildTotalScoreWidget(),
              ],
            ),
          ),
          bottomNavigationBar: _buildButtonsWidget(context),
        ),
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Column(
      children: [
        Text(
          "任务完成",
          style: TextStyle(
            fontSize: 96.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          "太棒了！又征服了一个任务！",
          style: TextStyle(
            fontSize: 36.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStarWidget(){
    return Obx((){

      List<TaskMissionCompleteEntityStarDetails?> starDetails = controller.missionData.value.starDetails ?? [];

      return Row(
        spacing: 40.wMin,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(starDetails.length, (index) {
          if(starDetails[index] == null) return const SizedBox();
          return _buildStarItemWidget(starDetails[index]!);
        }),
      );
    });
  }


  Widget _buildStarItemWidget(TaskMissionCompleteEntityStarDetails data){
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      child: Container(
        // color: Colors.white,
        width: 400.wMin,
        child: Column(
          children: [
            SizedBox(
              width: 158.wMin,
              child: Stack(
                children: [
                  Image.asset(
                    "assets/images/public/icon_star_un.webp", 
                    width: 158.wMin,
                    height: 158.wMin,
                    fit: BoxFit.fill,
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.easeInQuad,
                    transitionBuilder: (child, animation) {
                      Animation<double> anim = Tween(begin: 3.0, end: 1.0).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: RotationTransition(
                          turns: animation,
                          child: ScaleTransition(
                            scale: anim,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: data.isShowStar ? 
                    Image.asset(
                      "assets/images/public/icon_star.webp", 
                      width: 158.wMin,
                      height: 158.wMin,
                      fit: BoxFit.fill,
                      key: const ValueKey(true),
                    ) : const SizedBox(key: ValueKey(false)),
                  ),
                ],
              ),
            ),
        
            Obx((){
              if(!controller.isStarAnimationComplete.value) return Container();
              return FutureBuilder<bool>(
                initialData: false,
                future: Future.delayed(const Duration(milliseconds: 100), (){
                  return true;
                }),
                builder: (context, snapshot) {
                  return AnimatedOpacity(
                    opacity: snapshot.data ?? false ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      children: [
                        SizedBox(height: 16.wMin),
                        Text(
                          data.target ?? "",
                          style: TextStyle(
                            fontSize: 32.wMin,
                            color: AppTheme.cTextPrimary.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.wMin),
                        Text(
                          data.result ?? "",
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: data.isComplete ? AppTheme.cFeedbackSuccessText.color : AppTheme.cFeedbackErrorText.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 16.wMin),
                        Text(
                          "+${data.points?.toString()??''}",
                          style: TextStyle(
                            fontSize: 56.wMin,
                            color: data.isComplete ? AppTheme.cLearnSomethingBg.color : AppTheme.cTextTertiary.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
        
          ],
        ),
      ),
    );
  }

  /// 总获得学点
  Widget _buildTotalScoreWidget(){
    return Obx((){
      if(!controller.isStarAnimationComplete.value) return Container();
      return FutureBuilder<bool>(
        initialData: false,
        future: Future.delayed(const Duration(milliseconds: 350), (){
          return true;
        }),
        builder: (context, snapshot) {
          return Container(
            margin: EdgeInsets.only(top: 48.wMin),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: snapshot.data ?? false ? 1.0 : 0.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "总获得学点：",
                    style: TextStyle(
                      fontSize: 40.wMin,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cTextPrimary.color,
                    ),
                  ),
                  Text(
                    "+${controller.missionData.value.points??0}",
                    style: TextStyle(
                      color: AppTheme.cLearnSomethingBg.color,
                      fontSize: 64.wMin,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }


  Widget _buildButtonsWidget(BuildContext context){
    TaskMissionEntityMissions? nextMission = controller.nextMission;


    return Obx((){
      return IgnorePointer(
        ignoring: !controller.isStarAnimationComplete.value,
        child: AnimatedOpacity(
          opacity: controller.isStarAnimationComplete.value ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          onEnd: (){
            
          },
          child: Container(
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 100.wMin,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GuideAnchor(
                  id: 'back_to_mission_control_center',
                  route: Routes.MISSION_COMPLETE,
                  child: ButtonWidget(
                    text: "返回控制中心",
                    width: 400.wMin,
                    height: 64.wMin,
                    color: AppTheme.cFeedbackDefaultBackground.color,
                    borderRadius: 12.wMin,
                    fontSize: 28.wMin,
                    fontColor: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w500,
                    sclae: 1.01,
                    onTap: () {
                      controller.backToMissionControlCenter(context);
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 24.wMin),
                  child: ButtonWidget(
                    text: "再做一遍",
                    width: 400.wMin,
                    height: 64.wMin,
                    color: Colors.transparent,
                    borderRadius: 12.wMin,
                    fontSize: 28.wMin,
                    border: Border.all(width: 2.wMin, color: AppTheme.cBorderBrand.color),
                    fontColor: AppTheme.cTextBrand.color,
                    fontWeight: FontWeight.w500,
                    sclae: 1.01,
                    onTap: () async{
                      controller.doAgain();
                    },
                  ),
                ),
                Visibility(
                  visible: !controller.isLastMission && (nextMission?.isMission??false),
                  child: Container(
                    margin: EdgeInsets.only(left: 24.wMin),
                    child: ButtonWidget(
                      text: "继续下一任务",
                      width: 400.wMin,
                      height: 64.wMin,
                      color: AppTheme.cBgBrand.color,
                      borderRadius: 12.wMin,
                      fontSize: 28.wMin,
                      fontColor: AppTheme.cStaticWhite.color,
                      fontWeight: FontWeight.w500,
                      sclae: 1.01,
                      onTap: () {
                        controller.continueNextMission();
                      },
                    ),
                  ),
                ),
                Visibility(
                  visible: (nextMission?.isTest??false),
                  child: Container(
                    margin: EdgeInsets.only(left: 24.wMin),
                    child: ButtonWidget(
                      text: "去测试",
                      width: 400.wMin,
                      height: 64.wMin,
                      color: AppTheme.cBgBrand.color,
                      borderRadius: 12.wMin,
                      fontSize: 28.wMin,
                      fontColor: AppTheme.cStaticWhite.color,
                      fontWeight: FontWeight.w500,
                      sclae: 1.01,
                      onTap: () {
                        controller.continueNextMission();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

}
