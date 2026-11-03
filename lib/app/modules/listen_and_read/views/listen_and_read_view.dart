
import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/player_widgets/play_list_drwer_widget.dart';
import 'package:langwise/utils/interaction_record_utils/interaction_record_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';

import '../../../../common/widgets/player_widgets/play_title_widget.dart';
import '../../../routes/routes.dart';
import '../controllers/listen_and_read_controller.dart';
import '../bindings/listen_and_read_binding.dart';
import 'listen_and_read_reading_view.dart';
import 'listen_and_read_shadowing_view.dart';

class ListenAndReadView extends GetView<ListenAndReadController> {
  final String tagText;
  const ListenAndReadView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ListenAndReadView(tagText: tag),
      binding: ListenAndReadBinding(tagText: tag),
      routeName: Routes.LISTEN_AND_READ,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InteractionSessionContainer(
      source: 'listen_and_read',
      child: PopScope(
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
                    body = ListenAndReadReadingView(tagText: tagText);
                  }else{
                    body = ListenAndReadShadowingView(tagText: tagText);
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
