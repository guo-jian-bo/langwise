import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/enum/enum.dart';
import '../../../../../common/values/values.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/writing_boards.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../controllers/zhenxie_task_details_controller.dart';

class ZhenxieTaskWritingBoardWidget extends StatelessWidget {
  final ZhenxieTaskDetailsController controller;
  const ZhenxieTaskWritingBoardWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleWidget(context),
        Container(height: 1.wMin, color: AppTheme.cBorderSubtle.color),
        _buildStemWidget(context),
        Container(height: 1.wMin, color: AppTheme.cBorderSubtle.color),
        ZhenxieTaskWritingBoardCorrectionWidget(controller: controller),
        Expanded(
          child: _buildBoardWidget(context),
        ),
      ],
    );
  }

  Widget _buildTitleWidget(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    double leftPadding = padding.left > 90.wMin ? (padding.left + 16.wMin) : 90.wMin;
    return Container(
      height: 86.wMin,
      margin: EdgeInsets.only(left: leftPadding, right: 20.wMin),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final data = controller.detailsData.value;
              final title = LearningLangUtils.getLocalLang(data.title);
              return Text(
                title?.text ?? '',
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                  fontFamily: AppFontValue.sourceHanSerifCN,
                ),
              );
            }),
          ),
          SizedBox(width: 10.wMin),
          Obx(() {
            if (!controller.isCorrectionMode()) {
              return Container();
            }
            final currentReviewHistory = controller.currentReviewHistory();
            final correctionCount = controller.selectedCorrectionIndex.value;
            final seq = currentReviewHistory?.seq ?? correctionCount + 1;
            final reviewedAtText = DateFormatUtil.formatStrtoStr(currentReviewHistory?.reviewedAt, newPattern: "MM-dd HH:mm");
            return Row(
              children: [
                Text(
                  "第 $seq 次${reviewedAtText.isEmpty ? '' : ' · $reviewedAtText'}",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontTertiary.color,
                  ),
                ),
                SizedBox(width: 10.wMin),
                Visibility(
                  visible: correctionCount > 0,
                  child: TapScaleWidget(
                    onTap: () {
                      controller.updateSelectedCorrectionId(0);
                    },
                    sclae: 1,
                    child: Text(
                      "回到最新",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cZhenxieColorPrimary.color,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),

          Obx((){
            if(!controller.isTaskDraftMode()) return Container();
            final data = controller.boardController.writingBoardData.value;
            if(data == null) return Container();
            if(data.answerKindEnum.isText == false) return Container();
            final textMode = controller.boardController.writingBoardTextMode.value;
            bool isTyping = textMode == ZhenxieTaskTextSubmitModeEnum.typing;
            bool isPaper = textMode == ZhenxieTaskTextSubmitModeEnum.paper;
            return Row(
              children: [
                Text(
                  ZhenxieTaskTextSubmitModeEnum.typing.label,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w400,
                    color: isTyping ? ZhenxieTaskTextSubmitModeEnum.typing.color : AppTheme.cZhenxieFontTertiary.color,
                  ),
                ),
                SizedBox(width: 10.wMin),
                CardSwitchWidget(
                  width: 80.wMin,
                  height: 42.wMin,
                  value: isPaper,
                  switchActiveColor: ZhenxieTaskTextSubmitModeEnum.paper.color,
                  onChanged: (value) {
                    controller.boardController.changeWritingBoardTextMode();
                  },
                ),
                SizedBox(width: 10.wMin),
                Text(
                  ZhenxieTaskTextSubmitModeEnum.paper.label,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w400,
                    color: isPaper ? ZhenxieTaskTextSubmitModeEnum.paper.color : AppTheme.cZhenxieFontTertiary.color,
                  ),
                ),
              ],
            );
          }),

        ],
      ),
    );
  }

  Widget _buildStemWidget(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    double leftPadding = padding.left > 90.wMin ? (padding.left + 16.wMin) : 90.wMin;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: leftPadding,
        right: 30.wMin,
        top: 16.wMin,
        bottom: 16.wMin,
      ),
      child: Obx(() {
        final data = controller.detailsData.value;
        final stem = LearningLangUtils.getLocalLang(data.stem);
        return Text(
          stem?.text ?? '',
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cZhenxieFontTertiary.color,
          ),
        );
      }),
    );
  }

  Widget _buildBoardWidget(BuildContext context) {
    return Obx(() {
      final data = controller.boardController.writingBoardData.value;
      if (data == null) {
        return const SizedBox.shrink();
      }
      if (controller.isCorrectionMode()) {
        return ReviewBoardBoxWidget(
          data: data,
          memberWriting: controller.detailsData.value.memberWriting,
          review: controller.correctionController.currentReview(),
          correctionMode: controller.correctionController.correctionMode.value,
          activeMarkerId: controller.correctionController.selectedMarkerId.value,
          flashMarkerPulse: controller.correctionController.flashMarkerPulse.value,
          flashPartPulse: controller.correctionController.flashPartPulse.value,
          focusAnchors: controller.correctionController.focusAnchors.toList(),
          onSelectMarker: controller.correctionController.handleBoardMarkerSelection,
          onSelectBeatNid: controller.boardController.updateSelectedBeatNid,
        );
      }
      return BoardBoxWidget(
        data: data,
        isManagement: controller.isManagement,
        runtimeState: controller.boardController.writingBoardRuntimeState.value,
        controllers: controller.boardController.writingBoardControllers,
        highlightedFrameSection: controller.exemplarController.highlightedFrameSection.value,
        onTapFrameSection: controller.exemplarController.highlightFrameSection,
        onTapStep: (beatNid) {
          controller.boardController.onTapStepStamp(context, beatNid);
        },
        onSelectBeatNid: controller.boardController.updateSelectedBeatNid,
        onRequestStepFocus: controller.boardController.requestStepFocus,
        onStepTextChanged: controller.boardController.updateStepText,
        onHeadChanged: controller.boardController.updateHeadText,
        onTailChanged: controller.boardController.updateTailText,
        onImageItemsChanged: (items) {
          if (data.answerKindEnum.isText && data.writingBoardTextMode == ZhenxieTaskTextSubmitModeEnum.paper) {
            controller.boardController.updatePaperImages(items);
            return;
          }
          controller.boardController.updateAnswerImages(items);
        },
        onVideoItemsChanged: controller.boardController.updateAnswerVideos,
        onAudioItemsChanged: controller.boardController.updateAnswerAudios,
      );
    });
  }
}

class ZhenxieTaskWritingBoardCorrectionWidget extends StatelessWidget {
  final ZhenxieTaskDetailsController controller;
  const ZhenxieTaskWritingBoardCorrectionWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    double leftPadding = padding.left > 90.wMin ? (padding.left + 16.wMin) : 90.wMin;
    return AnimatedSize(
      alignment: Alignment.topCenter,
      duration: Duration(milliseconds: 200),
      child: Obx(() {
        final isTextAnswerKind = controller.detailsData.value.stage?.answerKindEnum.isText ?? true;
        final isReviewDone = controller.correctionController.isReviewDone(
          review: controller.detailsData.value.memberWriting?.review,
        );
        if (!controller.isCorrectionMode() || !isTextAnswerKind || !isReviewDone) return Container();
        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(left: leftPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.wMin),
              Row(
                children: [
                  _buildTabWidget(),
                  SizedBox(width: 16.wMin),
                  _buildTipsWidget(),
                ],
              ),
              SizedBox(height: 10.wMin),
              _buildUpgradeInfoWidget(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTabWidget() {
    final showOriginalMode = controller.correctionController.shouldShowOriginalMode();
    return Container(
      padding: EdgeInsets.all(6.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: AppTheme.cSurfaceTranslucentBase.color,
        border: Border.all(color: AppTheme.cBorderTranslucentThin.color, width: 1.wMin),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabItemWidget(ZhenxieTaskCorrectionWritingBoardModeEnum.annotation),
          _buildTabItemWidget(ZhenxieTaskCorrectionWritingBoardModeEnum.correct),
          _buildTabItemWidget(ZhenxieTaskCorrectionWritingBoardModeEnum.upgrade),
          if (showOriginalMode) _buildTabItemWidget(ZhenxieTaskCorrectionWritingBoardModeEnum.original),
        ],
      ),
    );
  }

  Widget _buildTabItemWidget(ZhenxieTaskCorrectionWritingBoardModeEnum type) {
    return TapScaleWidget(
      onTap: () {
        controller.correctionController.updateCorrectionMode(type);
      },
      sclae: 1,
      child: Obx(() {
        final correctionMode = controller.correctionController.correctionMode.value;
        bool selected = correctionMode == type;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 44.wMin,
          padding: EdgeInsets.symmetric(horizontal: 20.wMin),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: selected ? AppTheme.cZhenxieFontPrimary.color : Colors.transparent,
          ),
          child: Text(
            type.text,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: selected ? AppTheme.cBgPrimary.color : AppTheme.cZhenxieFontSecondary.color,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTipsWidget() {
    return Obx(() {
      final correctionMode = controller.correctionController.correctionMode.value;
      Widget body = Container();
      if (correctionMode == ZhenxieTaskCorrectionWritingBoardModeEnum.annotation) {
        body = _buildAnnotationWidget();
      } else if (correctionMode == ZhenxieTaskCorrectionWritingBoardModeEnum.correct) {
        body = _buildCorrectWidget();
      } else if (correctionMode == ZhenxieTaskCorrectionWritingBoardModeEnum.upgrade) {
        body = _buildUpgradeWidget();
      } else if (correctionMode == ZhenxieTaskCorrectionWritingBoardModeEnum.original) {
        body = _buildOriginalWidget();
      }
      return Expanded(
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 100),
          child: Container(
            alignment: Alignment.centerLeft,
            key: ValueKey(correctionMode),
            child: body,
          ),
        ),
      );
    });
  }

  Widget _buildAnnotationWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "错误",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cZhenxieFontTertiary.color,
            decoration: TextDecoration.underline,
            decorationColor: ReviewBoardStyleHelper.annotationErrorColor,
            decorationStyle: TextDecorationStyle.wavy,
            decorationThickness: 4.wMin,
          ),
        ),
        SizedBox(width: 16.wMin),
        Text(
          "建议",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cZhenxieFontTertiary.color,
            decoration: TextDecoration.underline,
            decorationColor: ReviewBoardStyleHelper.annotationSuggestionColor,
            decorationStyle: TextDecorationStyle.dashed,
            decorationThickness: 4.wMin,
          ),
        ),
        SizedBox(width: 16.wMin),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.wMin),
            color: ReviewBoardStyleHelper.annotationHighlightBackgroundColor.withValues(alpha: 0.8),
          ),
          child: Text(
            "亮点",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cStaticBlack.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCorrectWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "删掉的",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: ReviewBoardStyleHelper.correctDeleteTextColor.withValues(alpha: 0.8),
            decoration: TextDecoration.lineThrough,
            decorationColor: ReviewBoardStyleHelper.correctDeleteDecorationColor.withValues(alpha: 0.8),
            decorationStyle: TextDecorationStyle.solid,
            decorationThickness: 4.wMin,
          ),
        ),
        SizedBox(width: 16.wMin),
        Text(
          "补上的",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w600,
            color: ReviewBoardStyleHelper.correctInsertTextColor,
          ),
        ),
        SizedBox(width: 16.wMin),
        Text(
          "只改错误，建议不套用",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cZhenxieFontSecondary.color,
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.wMin),
            color: ReviewBoardStyleHelper.upgradeInsertBackgroundColor,
          ),
          child: Text(
            "升格改写",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: ReviewBoardStyleHelper.upgradeInsertTextColor,
            ),
          ),
        ),
        SizedBox(width: 16.wMin),
        Text(
          "灰色划线是原文",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: ReviewBoardStyleHelper.upgradeDeleteTextColor,
            decoration: TextDecoration.lineThrough,
            decorationColor: ReviewBoardStyleHelper.upgradeDeleteDecorationColor.withValues(alpha: 0.8),
            decorationThickness: 2.wMin,
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeInfoWidget() {
    return Obx(() {
      final correctionMode = controller.correctionController.correctionMode.value;
      if (correctionMode != ZhenxieTaskCorrectionWritingBoardModeEnum.upgrade) {
        return Container();
      }
      List<String?>? improvedNotes = controller.correctionController.currentReview()?.improvedNotes;
      if ((improvedNotes ?? []).isEmpty) return Container();
      return Container(
        constraints: BoxConstraints(
          maxHeight: 150.wMin,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 10.wMin),
          child: Column(
            spacing: 4.wMin,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(improvedNotes?.length ?? 0, (index) {
              return Text(
                "${index + 1}. ${improvedNotes?[index] ?? ""}",
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontTertiary.color,
                ),
              );
            }),
          ),
        ),
      );
    });
  }

  /// 原稿
  Widget _buildOriginalWidget() {
    return Text(
      "这次交的纸面照片，点开放大",
      style: TextStyle(
        fontSize: 18.wMin,
        fontWeight: FontWeight.w400,
        color: AppTheme.cZhenxieFontSecondary.color,
      ),
    );
  }

}
