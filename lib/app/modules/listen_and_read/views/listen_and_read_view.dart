
import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/player_widgets/play_list_drwer_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';

import '../../../../common/widgets/player_widgets/play_title_widget.dart';
import '../controllers/listen_and_read_controller.dart';
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
            return PlayListDrwerWidget(
              songs: controller.songList.toList(),
              contents: controller.contents,
              allCount: controller.contents?.length ?? 0,
              selectedUniqueKey: controller.currentContentUniqueKey.value,
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
                Widget body = Container();
                if(!controller.isShadowing.value){
                  body = const ListenAndReadReadingView();
                }else{
                  body = const ListenAndReadShadowingView();
                }
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  layoutBuilder: (currentChild, previousChildren) {
                    // 只返回当前 child，不保留旧的
                    return currentChild ?? const SizedBox.shrink();
                  },
                  child: Container(
                    key: ValueKey(controller.isShadowing.value),
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

  Widget _buildTitleWidget(BuildContext context) {
    double top = MediaQuery.of(context).padding.top + 24.wMin;
    return Obx(() {
      bool isShowMenu = controller.isShowAudioController.value;
      return AnimatedPositioned(
        width: MediaQuery.of(context).size.width,
        top: isShowMenu ? top : -(top + 72.wMin + 10.wMin),
        duration: const Duration(milliseconds: 300),
        child: GestureDetector(
          onTap: () {
            controller.prepareAudioControllerTimer();
          },
          child: PlayTitleWidget(
            title: controller.currentSong?.title,
            titleFontFamily: "SourceSerif4",
            onFeedbackError: () {
              controller.showFeedbackErrorContentDialog(context);
            },
          ),
        ),
      );
    });
  }

}
