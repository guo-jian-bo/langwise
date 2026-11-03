import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/enum/enum.dart';
import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/writing_boards.dart';
import '../../../management/common/commons.dart';
import '../bindings/zhenxie_task_details_binding.dart';
import '../controllers/zhenxie_task_details_controller.dart';
import 'zhenxie_task_blueprint_widget.dart';
import 'zhenxie_task_correction_widget.dart';
import 'zhenxie_task_exercise_widget.dart';
import 'zhenxie_task_materials_widget.dart';
import 'zhenxie_task_writing_board_widget.dart';

class ZhenxieTaskDetailsView extends GetView<ZhenxieTaskDetailsController> {
  final String tagText;
  const ZhenxieTaskDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieTaskDetailsView(tagText: tag),
      binding: ZhenxieTaskDetailsBinding(tagText: tag),
      routeName: Routes.ZHENXIE_TASK_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          controller.handlePageBack(context);
        },
        child: ManageScaffold(
          backgroundColor: AppTheme.cBgPrimary.color,
          resizeToAvoidBottomInset: false,
          onBack: () => controller.handlePageBack(context),
          body: Container(
            color: AppTheme.cSurfaceTranslucentBase.color,
            child: Column(
              children: [
                BreadcrumbWidget(isCompatibleManage: controller.isManagement),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: ZhenxieTaskWritingBoardWidget(controller: controller)),
                      Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
                      _buildInfoWidget(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoWidget(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    double rightPadding = padding.right;
    return Container(
      width: 750.wMin,
      padding: EdgeInsets.only(right: rightPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoTitleWidget(context),
          Container(height: 1.wMin, color: AppTheme.cBorderSubtle.color),
          _buildTabWidget(context),
          Expanded(child: _buildTabBodyWidget()),
          _buildButtonsWidget(context),
        ],
      ),
    );
  }

  Widget _buildInfoTitleWidget(BuildContext context) {
    return Container(
      height: 86.wMin,
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final data = controller.detailsData.value;
              final name = LearningLangUtils.getLocalLang(data.blueprint?.name);

              return Text.rich(TextSpan(
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
                children: [
                  TextSpan(text: "写作目标", style: TextStyle(color: AppTheme.cZhenxieColorPrimary.color)),
                  TextSpan(text: "：${name?.text ?? ''}"),
                ],
              ));
            }),
          ),
          _buildCorrectionDropdownWidget(context),
          Obx(() {
            final mode = controller.mode.value;
            if (!controller.isManagement || mode.isCorrectionMode) return Container();
              return Row(
                children: [
                  if (controller.routeMode == WritingBoardModeEnum.exemplar) ...[
                    ButtonWidget(
                      text: "重新生成",
                      height: 38.wMin,
                      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
                      borderRadius: 99,
                      color: AppTheme.cSurfaceLayerBase.color,
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                      fontColor: AppTheme.cTextPrimary.color,
                      sclae: 1.05,
                      border: Border.all(color: AppTheme.cBorderSubtle.color, width: 0.8.wMin),
                      onTap: controller.toManageRegenerateExemplar,
                    ),
                    SizedBox(width: 8.wMin),
                  ],
                  if (controller.hasManageEditorRouteParams())
                    ButtonWidget(
                      text: "编辑",
                      height: 38.wMin,
                      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
                      borderRadius: 99,
                      color: AppTheme.cSurfaceLayerBase.color,
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                      fontColor: AppTheme.cTextPrimary.color,
                      sclae: 1.05,
                      border: Border.all(color: AppTheme.cBorderSubtle.color, width: 0.8.wMin),
                      leftIcon: Container(
                        margin: EdgeInsets.only(right: 6.wMin),
                        child: SvgPicture.asset(
                          "assets/svg/manage/icon_edit.svg",
                          width: 18.wMin,
                        ),
                      ),
                      onTap: controller.toManageEditor,
                    ),
                ],
              );
          }),
        ],
      ),
    );
  }

  /// 批改记录下拉菜单
  Widget _buildCorrectionDropdownWidget(BuildContext context) {
    return Obx(() {
      if (!controller.isTaskDraftMode() &&
          !controller.isCorrectionExemplarMode() &&
          !controller.isCorrectionMode() &&
          !controller.isTaskExemplarMode()) {
        return Container();
      }
      final reviewHistoryList = controller.reviewHistoryList();
      if (reviewHistoryList.isEmpty) return Container();
      final selectedCorrectionIndex = controller.selectedCorrectionIndex.value;
      final currentReviewHistory = controller.isCorrectionContextMode() ? controller.currentReviewHistory() : null;
      final currentSeqText = currentReviewHistory?.seq == null ? "" : " ${currentReviewHistory!.seq}";
      return IconDropdownCheckWidget(
        selectIndex: selectedCorrectionIndex,
        width: 420.wMin,
        fontColor: AppTheme.cZhenxieFontTertiary.color,
        fontSize: 20.wMin,
        menuHeight: 800.wMin,
        alignRight: true,
        sclae: 1,
        hoverColor: AppTheme.cZhenxieBackgroundPrimary.color,
        onTap: (data, index) {
          controller.updateSelectedCorrectionId(index);
        },
        items: List.generate(reviewHistoryList.length, (index) {
          final item = reviewHistoryList[index];
          final reviewedAtText = DateFormatUtil.formatStrtoStr(item.reviewedAt, newPattern: "MM-dd HH:mm");
          final scoreText = item.score == null ? "" : "  ${item.score} 分";
          final gradeText = (item.grade ?? '').isEmpty ? "" : " · ${item.grade}";
          return IconDropdownCheckData(
            title: "第 ${item.seq ?? index + 1} 次  $reviewedAtText$scoreText$gradeText",
            value: index,
          );
        }),
        child: Container(
          height: 44.wMin,
          padding: EdgeInsets.only(left: 16.wMin, right: 10.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: AppTheme.cZhenxieBackgroundPrimary.color,
            border: Border.all(color: AppTheme.cZhenxieBorderPrimary.color, width: 0.8.wMin),
          ),
          child: Row(
            children: [
              Text(
                "批改记录$currentSeqText",
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cZhenxieFontTertiary.color,
                ),
              ),
              SizedBox(width: 6.wMin),
              SvgPicture.asset(
                "assets/svg/public/icon_arrow_down.svg",
                width: 24.wMin,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTabWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16.wMin, left: 24.wMin, right: 24.wMin),
      child: Container(
        padding: EdgeInsets.all(6.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: AppTheme.cSurfaceTranslucentBase.color,
          border: Border.all(color: AppTheme.cBorderTranslucentThin.color, width: 1.wMin),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              if(!controller.isCorrectionMode()) return Container();
              return _buildTabItemWidget(context, ZhenxieTaskDetailsTabType.correction);
            }),
            _buildTabItemWidget(context, ZhenxieTaskDetailsTabType.materials),
            _buildTabItemWidget(context, ZhenxieTaskDetailsTabType.blueprint),
            Obx(() {
              if (!controller.isExemplarContentMode()) return Container();
              if(controller.unitId == null) return Container();
              return _buildTabItemWidget(context, ZhenxieTaskDetailsTabType.exercise);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItemWidget(BuildContext context, ZhenxieTaskDetailsTabType type) {
    return TapScaleWidget(
      onTap: () {
        controller.updateTabType(context, type);
      },
      sclae: 1,
      child: Obx(() {
        bool selected = controller.tabType.value == type;
        bool showLock = type == ZhenxieTaskDetailsTabType.blueprint && !controller.isExemplarContentMode() && controller.shouldLockBlueprintTab();
        return Container(
          height: 44.wMin,
          width: 110.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: selected ? AppTheme.cZhenxieFontPrimary.color : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: showLock,
                child: Container(
                  margin: EdgeInsets.only(right: 4.wMin),
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_lock_blank.svg",
                    width: 20.wMin,
                    colorFilter: ColorFilter.mode(AppTheme.cZhenxieColorPrimary.color, BlendMode.srcIn),
                  ),
                ),
              ),
              Text(
                type.text,
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                  color: selected ? AppTheme.cBgPrimary.color : AppTheme.cZhenxieFontSecondary.color,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTabBodyWidget() {
    return Obx(() {
      final tabType = controller.tabType.value;
      Widget body = Container();
      if (tabType == ZhenxieTaskDetailsTabType.materials) {
        List<ElementsCardEntityDatas> knowledgeList = controller.taskController.taskKnowledgePointsList.toList();
        List<CourseWriteTargetItemEntity> grammarTargetList = controller.taskController.taskGrammarTargetList.toList();
        if (controller.isExemplarContentMode()) {
          knowledgeList = controller.exemplarController.exemplarKnowledgePointsList.toList();
          grammarTargetList = controller.exemplarController.exemplarGrammarTargetList.toList();
        }
        body = ZhenxieTaskMaterialsWidget(
          knowledgePointsList: knowledgeList,
          grammarTargetList: grammarTargetList,
          isManagement: controller.isManagement,
          onTapGrammarTarget: controller.jumpToGrammarDetail,
        );
      } else if (tabType == ZhenxieTaskDetailsTabType.blueprint) {
        body = ZhenxieTaskBlueprintWidget(
          detailsData: controller.detailsData.value,
          isManagement: controller.isManagement,
          mode: controller.mode.value,
          paragraphRhetoricalList: controller.paragraphRhetoricalList,
          selectBeatNid: controller.boardController.selectBeatNid.value,
          highlightedFrameSection: controller.exemplarController.highlightedFrameSection.value,
          onTapFrameSection: controller.exemplarController.highlightFrameSection,
          onSelectBeatNid: controller.boardController.updateSelectedBeatNid,
        );
      } else if (tabType == ZhenxieTaskDetailsTabType.correction) {
        body = ZhenxieTaskCorrectionWidget(controller: controller.correctionController);
      } else if (tabType == ZhenxieTaskDetailsTabType.exercise) {
        body = ZhenxieTaskExerciseWidget(controller: controller.exerciseController);
      } 
      return AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: Container(
          key: ValueKey(tabType),
          alignment: Alignment.topCenter,
          child: body,
        ),
      );
    });
  }

  Widget _buildButtonsWidget(BuildContext context) {
    
    if (controller.routeMode == WritingBoardModeEnum.exemplar) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      child: Column(
        children: [
          Container(height: 1.wMin, color: AppTheme.cBorderSubtle.color),
          SizedBox(height: 18.wMin),
          Obx(() {
            if (!controller.isCorrectionContextMode()) {
              return _buildTaskButtonWidget(context);
            }
            return _buildCorrectionButtonsWidget(context);
          }),
          SizedBox(height: 32.wMin),
        ],
      ),
    );
  }

  /// 任务按钮
  Widget _buildTaskButtonWidget(BuildContext context) {
    return Row(
      children: [
        _buildViewExemplarButtonWidget(context),
        Spacer(),
        if(!controller.isManagement) ...[
          Obx(() {
            if (!controller.taskController.hasSavedTaskDraft()) return const SizedBox.shrink();
            return Row(
              children: [
                Text(
                  "已暂存",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontTertiary.color,
                  ),
                ),
                SizedBox(width: 10.wMin),
              ],
            );
          }),
          ButtonWidget(
            text: "暂存",
            height: 48.wMin,
            padding: EdgeInsets.symmetric(horizontal: 24.wMin),
            borderRadius: 99,
            color: AppTheme.cZhenxieBorderPrimary.color,
            fontSize: 24.wMin,
            fontColor: AppTheme.cZhenxieFontTertiary.color,
            fontWeight: FontWeight.w500,
            border: Border.all(color: AppTheme.cZhenxieBorderPrimary.color, width: 0.8.wMin),
            sclae: 1.03,
            onTap: () {
              controller.taskController.saveDraft();
            },
          ),
          SizedBox(width: 12.wMin),
          ButtonWidget(
            text: "提交批改",
            height: 48.wMin,
            padding: EdgeInsets.symmetric(horizontal: 24.wMin),
            borderRadius: 99,
            color: AppTheme.cZhenxieFontPrimary.color,
            border: Border.all(color: AppTheme.cZhenxieBorderPrimary.color, width: 0.8.wMin),
            fontSize: 24.wMin,
            fontColor: AppTheme.cStaticDeprecatedBlack.color,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            rightIcon: Obx((){
              if (controller.detailsData.value.pointMessage == null) return const SizedBox.shrink();
              return Text(
                " (${controller.detailsData.value.pointMessage??""})",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cStaticDeprecatedBlack.color,
                ),
              );
            }),
            onTap: () {
              controller.taskController.submitTask();
            },
          ),
        ],
        
      ],
    );
  }

  /// 批改模式按钮
  Widget _buildCorrectionButtonsWidget(BuildContext context) {
    return Obx(() {
      final hasEditedRewrite = controller.boardController.hasPendingExitChanges(
        details: controller.taskController.taskDetailsData.value,
        runtimeState: controller.taskController.draftWritingBoardRuntimeState,
        mode: WritingBoardModeEnum.task,
      );
      final rewriteButtonText = hasEditedRewrite || controller.taskController.hasRewriteDraftEntry() ? "继续重写" : "重写一篇";
      return Row(
        children: [
          _buildViewExemplarButtonWidget(context),
          Spacer(),
          ButtonWidget(
            text: rewriteButtonText,
            height: 48.wMin,
            padding: EdgeInsets.symmetric(horizontal: 24.wMin),
            borderRadius: 99,
            color: AppTheme.cZhenxieFontPrimary.color,
            border: Border.all(color: AppTheme.cZhenxieBorderPrimary.color, width: 0.8.wMin),
            fontSize: 20.wMin,
            fontColor: AppTheme.cStaticDeprecatedBlack.color,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            onTap: () {
              controller.continueRewriteCorrection();
            },
          ),
        ],
      );
    });
  }

  /// 查看范文按钮
  Widget _buildViewExemplarButtonWidget(BuildContext context) {
    return Obx(() {
      final taskDetails = controller.taskController.taskDetailsData.value;
      final isExemplarContentMode =
          controller.isTaskExemplarMode() || controller.isCorrectionExemplarMode() || controller.isExemplarReadOnlyMode();
      if (taskDetails?.exemplarCompositionId == null) {
        return const SizedBox.shrink();
      }
      String text = "查看范文";
      if (controller.isCorrectionExemplarMode()) {
        text = "回到批改";
      } else if (isExemplarContentMode) {
        text = "继续写作";
      }

      return ButtonWidget(
        text: text,
        height: 48.wMin,
        padding: EdgeInsets.symmetric(horizontal: 20.wMin),
        borderRadius: 99,
        color: AppTheme.cZhenxieBorderPrimary.color,
        fontSize: 20.wMin,
        fontColor: AppTheme.cZhenxieFontTertiary.color,
        fontWeight: FontWeight.w500,
        sclae: 1.03,
        border: Border.all(color: AppTheme.cZhenxieBorderPrimary.color, width: 0.8.wMin),
        leftIcon: Visibility(
          visible: !isExemplarContentMode && controller.shouldLockExemplarView(),
          child: Container(
            margin: EdgeInsets.only(right: 4.wMin),
            child: SvgPicture.asset(
              "assets/svg/public/icon_lock_blank.svg",
              width: 18.wMin,
              colorFilter: ColorFilter.mode(AppTheme.cZhenxieColorPrimary.color, BlendMode.srcIn),
            ),
          ),
        ),
        onTap: () {
          controller.exemplarController.viewSample(context);
        },
      );
    });
  }
}
