import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';

import '../controllers/listen_and_read_controller.dart';
import 'listen_and_read_practice_view.dart';
import 'listen_and_read_reading_view.dart';
import 'listen_and_read_shadowing_view.dart';

class ListenAndReadView extends GetView<ListenAndReadController> {
  const ListenAndReadView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        controller.audioPlayerUtils.stop();
      },
      child: MouseRegion(
        onHover: (event) {
          controller.prepareAudioControllerTimer();
        },
        child: Scaffold(
          key: controller.scaffoldKey,
          backgroundColor: AppTheme.cBgPrimary.color,
          endDrawer: Obx((){
            return SongMvListDrawerWidget(
              songs: controller.songList,
              allCount: controller.songList.length,
              selectedId: controller.currentSong?.contentId ?? -1,
              onSelected: (data) {
                controller.switchSong(data);
              },
              onScrollEnd: () async{
                await controller.loadData();
              },
            );
          }),
          drawerEnableOpenDragGesture: false,
          drawerScrimColor: Colors.transparent,
          body: Stack(
            children: [
              
              Obx((){
                int currentIndex = controller.titleNavIndex.value;
                Widget body = Container();
                if(currentIndex == 0){
                  body = const ListenAndReadReadingView();
                }if(currentIndex == 1){
                  body = const ListenAndReadShadowingView();
                }else if(currentIndex == 2){
                  body = const ListenAndReadPracticeView();
                }
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  layoutBuilder: (currentChild, previousChildren) {
                    // 只返回当前 child，不保留旧的
                    return currentChild ?? const SizedBox.shrink();
                  },
                  child: Container(
                    key: ValueKey(currentIndex),
                    child: body,
                  ),
                );
              }),
              _buildTitleWidget(context),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTitleWidget(BuildContext context){
    double topPadding = 110.wMin + MediaQuery.of(context).padding.top;
    return Obx((){
      bool isShowAudioController = controller.isShowAudioController.value;
      return AnimatedPositioned(
        duration: const Duration(milliseconds: 200),
        top: isShowAudioController ? 0 : -topPadding,
        width: MediaQuery.of(context).size.width,
        child: GestureDetector(
          onTap: (){},
          child: Container(
            height: topPadding,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 40.wMin,
              right: 40.wMin,
            ),
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceSecondary.color,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.cBgSecondary.withValues(alpha: 1),
                  AppTheme.cBgSecondary.withValues(alpha: 0.8),
                  AppTheme.cBgSecondary.withValues(alpha: 0.6),
                  AppTheme.cBgSecondary.withValues(alpha: 0.2),
                ],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double maxWidth = constraints.maxWidth;
                      return Obx((){
                        return BackWidget(
                          title: (controller.currentSong?.title??""),
                          fontFamily: "SourceSerif4",
                          titleMaxWidth: maxWidth - 200.wMin,
                        );
                      });
                    },
                  ),
                ),
                _buildSwitchListWidget(context),
                SizedBox(width: 40.wMin),
                _buildFeedbackErrorWidget(context),
              ],
            ),
          ),
        ),
      );
    });
  }

    /// 反馈错误按钮
  Widget _buildFeedbackErrorWidget(BuildContext context){
    return FeedbackErrorContentButtonWidget(
      fontColor: AppTheme.cTextSecondary,
      onTap: (){
        controller.showFeedbackErrorContentDialog(context);
      },
    );
  }

  Widget _buildSwitchListWidget(BuildContext context){
    return Obx((){
      int currentIndex = controller.titleNavIndex.value;

      return AnimatedToggleSwitch<int>.size(
        current: controller.titleNavIndex.value,
        values: List.generate(controller.titleNavList.length, (index) => index),
        indicatorSize: Size.fromWidth(100.wMin),
        height: 64.wMin,
        iconBuilder: (index){
          Color textColor = currentIndex == index ? AppTheme.cStaticWhite.color : AppTheme.cTextPrimary.color;

          if(index == 2){
            if(!controller.hasPractice.value){
              textColor = AppTheme.cTextQuaternary.color;
            }
          }
          if(index == 3){
            textColor = AppTheme.cTextDisabled.color;
          }

          return AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 24.wMin,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
            child: Text(
              controller.titleNavList[index],
            ),
          );
        },
        borderWidth: 4.wMin,
        iconAnimationType: AnimationType.onHover,
        iconOpacity: 1,
        selectedIconScale: 1,
        spacing: 1.wMin,
        customStyleBuilder: (context, local, global) {
          Color bgColor = AppTheme.cSurfaceBrand.color;
          if(local.index == 2 || local.index == 3){
            bgColor = AppTheme.cSurfaceWarning.color;
          }

          return ToggleStyle(
            borderColor: Colors.transparent,
            borderRadius: BorderRadius.circular(16.wMin),
            backgroundColor: AppTheme.cSurfaceTertiary.color,
            indicatorBorderRadius: BorderRadius.circular(14.wMin),
            indicatorColor: bgColor,
          );
        },
        separatorBuilder: (index) {
          if(index == 1){
            return Container(
              width: 1.wMin, 
              height: 35.wMin,
              color: AppTheme.cBorderSecondary.color,
            );
          }
          return Container();
        },
        onChanged: (i) => controller.changeTitleNavIndex(i),
      );
    });
  }


}
