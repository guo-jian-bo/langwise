import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/third_party_account_entity.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/common/widgets/player_widgets/player_jump_page_utils.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/play_record_utils/play_record_constants.dart';
import 'package:quiz_play/models/quiz_play_show_config.dart';
import 'package:quiz_play/quiz_play.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/widgets/player_widgets/play_page_type_widgets.dart';
import '../../../../../common/widgets/player_widgets/play_title_widget.dart';
import '../../../practice_questions/common/practice_questions_quiz_widget.dart';
import '../../../../routes/routes.dart';
import '../bindings/zhendu_practice_binding.dart';
import '../controllers/zhendu_practice_controller.dart';

class ZhenduPracticeView extends GetView<ZhenduPracticeController> {
  final String tagText;
  const ZhenduPracticeView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenduPracticeView(tagText: tag),
      binding: ZhenduPracticeBinding(tagText: tag),
      routeName: Routes.ZHENDU_PRACTICE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // controller.audioPlayerUtils.stop();
      },
      child: MouseRegion(
        onHover: (event) {
          // controller.prepareAudioControllerTimer();
        },
        child: Scaffold(
          key: controller.scaffoldKey,
          backgroundColor: AppTheme.cBgPrimary.color,
          // endDrawer: Obx((){
          //   return SongMvListDrawerWidget(
          //     songs: controller.songList,
          //     allCount: controller.songList.length,
          //     selectedId: controller.currentSong?.contentId ?? -1,
          //     onSelected: (data) {
          //       controller.switchSong(data);
          //     },
          //     onScrollEnd: () async{
          //       await controller.loadData();
          //     },
          //   );
          // }),
          drawerEnableOpenDragGesture: false,
          drawerScrimColor: Colors.transparent,
          body: Stack(
            children: [
              AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  layoutBuilder: (currentChild, previousChildren) {
                    // 只返回当前 child，不保留旧的
                    return currentChild ?? const SizedBox.shrink();
                  },
                  child: Container(
                    child: Obx(() {
                      if (controller.quizDatas.isEmpty) return Container();
                      double topPadding = 110.wMin + MediaQuery.of(context).padding.top;
                      return Container(
                        margin: EdgeInsets.only(top: topPadding),
                        child: PracticeQuestionsQuizWidget(
                          data: controller.quizDatas[controller.currentQuizIndex.value],
                          letters: const [],
                          stateController: controller.stateController,
                          endPractice: false,
                          soundAccount: ThirdPartyAccountEntityList(),
                          showConfig: const QuizPlayShowConfig(usePlayerControllerForStemAudioControls: true),
                          // playSpeed: controller.listenAndReadController.playbackRate.value,
                          listener: QuizPlayListener(
                            onPageTypeTap: (tapContext) {
                              if (controller.contentId == null || controller.contentType == null) return;
                              if (controller.pageTypeList.isEmpty) return;
                              Function()? closeDialog;
                              closeDialog = PlayPageTypeDialog.showPageTypeDialog(
                                context: tapContext,
                                learnItems: controller.pageTypeList.toList(),
                                currentPageType: ZhenduPageTypeEnum.practice,
                                onPageTypeChange: (item) {
                                  closeDialog?.call();
                                  final contents = controller.contents.isNotEmpty
                                      ? controller.contents
                                      : <Map<String, dynamic>>[
                                          {
                                            'contentId': controller.contentId,
                                            'contentType': controller.contentType,
                                            'styleId': controller.styleId,
                                            'dialect': controller.dialect,
                                          },
                                        ];
                                  Future.microtask(() {
                                    PlayerJumpPageUtils.jumpToPage(
                                      pageType: item.pageType,
                                      contentId: controller.contentId,
                                      contentType: controller.contentType,
                                      semanticId: null,
                                      styleId: controller.styleId,
                                      dialect: controller.dialect,
                                      contents: contents,
                                      type: controller.type == null ? null : PlayRecordPageType.fromValue(controller.type!),
                                      typeId: controller.typeId,
                                      traceAdminHeader: controller.traceAdminHeader,
                                    );
                                  });
                                },
                              );
                            },
                            onFinish: (log) {
                              controller.nextQuiz();
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                _buildTitleWidget(context),
              
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildTitleWidget(BuildContext context) {
    double top = MediaQuery.of(context).padding.top + 24.wMin;
    return AnimatedPositioned(
      width: MediaQuery.of(context).size.width,
      top: top,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: () {
          // controller.prepareAudioControllerTimer();
        },
        child: Obx(() {
          return PlayTitleWidget(
            title: controller.title,
            titleFontFamily: "SourceSerif4",
            onFeedbackError: () {
              controller.showFeedbackErrorContentDialog(context);
            },
          );
        }),
      ),
    );

  }
  // Widget _buildTitleWidget(BuildContext context){
  //   double topPadding = 110.wMin + MediaQuery.of(context).padding.top;
  //   return AnimatedPositioned(
  //       duration: const Duration(milliseconds: 200),
  //
  //       width: MediaQuery.of(context).size.width,
  //       child: GestureDetector(
  //         onTap: (){},
  //         child: Container(
  //           height: topPadding,
  //           padding: EdgeInsets.only(
  //             top: MediaQuery.of(context).padding.top,
  //             left: 40.wMin,
  //             right: 40.wMin,
  //           ),
  //           decoration: BoxDecoration(
  //             color: AppTheme.cSurfaceSecondary.color,
  //             gradient: LinearGradient(
  //               begin: Alignment.topCenter,
  //               end: Alignment.bottomCenter,
  //               colors: [
  //                 AppTheme.cBgSecondary.withValues(alpha: 1),
  //                 AppTheme.cBgSecondary.withValues(alpha: 0.8),
  //                 AppTheme.cBgSecondary.withValues(alpha: 0.6),
  //                 AppTheme.cBgSecondary.withValues(alpha: 0.2),
  //               ],
  //             ),
  //           ),
  //           child: Row(
  //             children: [
  //               Expanded(
  //                 child: LayoutBuilder(
  //                   builder: (context, constraints) {
  //                     double maxWidth = constraints.maxWidth;
  //                     return BackWidget(
  //                         // title: (controller.currentSong?.title??""),
  //                         fontFamily: "SourceSerif4",
  //                         titleMaxWidth: maxWidth - 200.wMin,
  //                       );
  //                   },
  //                 ),
  //               ),
  //
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //   ;
  // }
}
