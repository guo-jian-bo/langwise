import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/widgets/widgets.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/writing_boards.dart';
import '../../../management/common/commons.dart';
import '../bindings/zhenxie_task_details_binding.dart';
import '../controllers/zhenxie_task_details_controller.dart';
import 'zhenxie_task_blueprint_widget.dart';
import 'zhenxie_task_materials_widget.dart';

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
          backgroundColor: AppTheme.cSurfaceLayerElevated.color,
          onBack: () => controller.handlePageBack(context),
          body: Column(
            children: [
              BreadcrumbWidget(isCompatibleManage: controller.isManagement),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildWritingBoardWidget(context)),
                    Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
                    _buildInfoWidget(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 写作板
  Widget _buildWritingBoardWidget(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    double leftPadding = padding.left > 90.wMin ? (padding.left + 16.wMin) : 90.wMin;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 86.wMin,
          margin: EdgeInsets.only(left: leftPadding),
          alignment: Alignment.centerLeft,
          child: Obx(() {
            final data = controller.detailsData.value;
            final title = LearningLangUtils.getLocalLang(data.title);
            return Text(
              title?.text ?? '',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            );
          }),
        ),
        Container(height: 1.wMin, color: AppTheme.cBorderSubtle.color),
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            left: 90.wMin,
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
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextPrimary.color,
              ),
            );
          }),
        ),
        Container(height: 1.wMin, color: AppTheme.cBorderSubtle.color),
        Expanded(
          child: Obx(() {
            final data = controller.writingBoardData.value;
            if (data == null) {
              return const SizedBox.shrink();
            }
            return BoardBoxWidget(
              data: data,
              runtimeState: controller.writingBoardRuntimeState.value,
              controllers: controller.writingBoardControllers,
              highlightedFrameSection: controller.highlightedFrameSection.value,
              onTapFrameSection: controller.highlightFrameSection,
              onTapStep: (beatNid) {
                controller.onTapStepStamp(context, beatNid);
              },
              onSelectBeatNid: controller.updateSelectedBeatNid,
              onRequestStepFocus: controller.requestStepFocus,
              onStepTextChanged: controller.updateStepText,
              onHeadChanged: controller.updateHeadText,
              onTailChanged: controller.updateTailText,
              onImageItemsChanged: controller.updateAnswerImages,
              onVideoItemsChanged: controller.updateAnswerVideos,
              onAudioItemsChanged: controller.updateAnswerAudios,
            );
          }),
        ),
      ],
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
          Container(
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
                        TextSpan(text: "写作目标", style: TextStyle(color: Color(0xffFB923C))),
                        TextSpan(text: "：${name?.text ?? ''}"),
                      ],
                    ));
                  }),
                ),
                Obx(() {
                  bool isEditMode = controller.isExemplarEditMode();
                  bool isExemplar = controller.isExemplarContentMode() && !isEditMode;
                  bool isWritingMode = controller.isTaskDraftMode();
                  return Visibility(
                    visible: controller.isManagement && (isExemplar || isWritingMode),
                    child: ButtonWidget(
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
                      onTap: () {
                        controller.navigateToEditPage();
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          Container(height: 1.wMin, color: AppTheme.cBorderSubtle.color),
          _buildTabWidget(context),
          Expanded(child: _buildTabBodyWidget()),
          _buildButtonsWidget(context),
        ],
      ),
    );
  }

  Widget _buildTabWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20.wMin, left: 24.wMin, right: 24.wMin),
      child: Container(
        padding: EdgeInsets.all(2.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.wMin),
          color: AppTheme.cSurfaceLayerElevated.color,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth / 2;
            return Stack(
              children: [
                Obx(() {
                  int tabType = controller.tabType.value;
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    alignment: tabType == 0 ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      width: width,
                      height: 40.wMin,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.wMin),
                        color: AppTheme.cSurfaceBg.color,
                      ),
                    ),
                  );
                }),
                Row(
                  children: [
                    _buildTabItemWidget(context, 0),
                    _buildTabItemWidget(context, 1),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabItemWidget(BuildContext context, int type) {
    return Expanded(
      child: TapScaleWidget(
        onTap: () {
          controller.updateTabType(context, type);
        },
        sclae: 1,
        child: Container(
          height: 40.wMin,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Obx(() {
            bool selected = controller.tabType.value == type;
            bool showLock =
                type == 1 && controller.detailsData.value.stage?.lockBlueprintTab == true && !controller.isExemplarContentMode();
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Visibility(
                  visible: showLock,
                  child: Container(
                    margin: EdgeInsets.only(right: 4.wMin),
                    child: SvgPicture.asset(
                      "assets/svg/public/icon_lock_blank.svg",
                      width: 20.wMin,
                      colorFilter: ColorFilter.mode(Color(0xffFB923C), BlendMode.srcIn),
                    ),
                  ),
                ),
                Text(
                  type == 0 ? "资料" : "蓝图",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w500,
                    color: selected ? Color(0xffFB923C) : AppTheme.cTextDisabled.color,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabBodyWidget() {
    return Obx(() {
      int tabType = controller.tabType.value;
      return AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: Container(
          key: ValueKey(tabType),
          alignment: Alignment.topCenter,
          child: tabType == 0
              ? ZhenxieTaskMaterialsWidget(
                  knowledgePointsList: controller.knowledgePointsList.toList(),
                )
              : ZhenxieTaskBlueprintWidget(
                  detailsData: controller.detailsData.value,
                  isManagement: controller.isManagement,
                  contentSource: controller.contentSourceMacro.value,
                  editPolicy: controller.editPolicyMacro.value,
                  paragraphRhetoricalList: controller.paragraphRhetoricalList,
                  selectBeatNid: controller.selectBeatNid.value,
                  highlightedFrameSection: controller.highlightedFrameSection.value,
                  onTapFrameSection: controller.highlightFrameSection,
                  onSelectBeatNid: controller.updateSelectedBeatNid,
                ),
        ),
      );
    });
  }

  Widget _buildButtonsWidget(BuildContext context) {
    if (controller.routeContentSourceMacro == WritingBoardContentSourceMacro.exemplar) {
      return Obx(() {
        if (controller.isExemplarReadOnlyMode()) {
          return Container();
        }
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 24.wMin),
          child: Column(
            children: [
              Container(height: 1.wMin, color: AppTheme.cBorderSubtle.color),
              SizedBox(height: 18.wMin),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ButtonWidget(
                    text: "保存范文",
                    height: 48.wMin,
                    padding: EdgeInsets.symmetric(horizontal: 32.wMin),
                    borderRadius: 8.wMin,
                    color: Color(0xffFB923C).withValues(alpha: 0.45),
                    border: Border.all(color: Color(0xffFB923C).withValues(alpha: 0.2), width: 0.8.wMin),
                    fontSize: 24.wMin,
                    fontColor: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w500,
                    sclae: 1.03,
                    onTap: () async {
                      await controller.saveSample();
                    },
                  ),
                ],
              ),
              SizedBox(height: 32.wMin),
            ],
          ),
        );
      });
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      child: Column(
        children: [
          Container(height: 1.wMin, color: AppTheme.cBorderSubtle.color),
          SizedBox(height: 18.wMin),
          Row(
            children: [
              Obx(() {
                bool isExemplarContentMode = controller.isExemplarContentMode();
                if(controller.detailsData.value.exemplarCompositionId == null) {
                  return Container();
                }
                return ButtonWidget(
                  text: !isExemplarContentMode ? "查看范文" : "继续写作",
                  height: 48.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 32.wMin),
                  borderRadius: 8.wMin,
                  color: AppTheme.cSurfaceLayerElevated.color,
                  fontSize: 24.wMin,
                  fontColor: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w500,
                  sclae: 1.03,
                  leftIcon: Visibility(
                    visible: !isExemplarContentMode && controller.detailsData.value.stage?.lockExemplarView == true,
                    child: Container(
                      margin: EdgeInsets.only(right: 4.wMin),
                      child: SvgPicture.asset(
                        "assets/svg/public/icon_lock_blank.svg",
                        width: 20.wMin,
                        colorFilter: ColorFilter.mode(Color(0xffFB923C), BlendMode.srcIn),
                      ),
                    ),
                  ),
                  onTap: () {
                    controller.viewSample(context);
                  },
                );
              }),
              Spacer(),
              ButtonWidget(
                text: "暂存",
                height: 48.wMin,
                padding: EdgeInsets.symmetric(horizontal: 32.wMin),
                borderRadius: 8.wMin,
                color: AppTheme.cSurfaceLayerElevated.color,
                fontSize: 24.wMin,
                fontColor: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w500,
                sclae: 1.03,
                onTap: () {
                  controller.saveDraft();
                },
              ),
              SizedBox(width: 12.wMin),
              ButtonWidget(
                text: "提交",
                height: 48.wMin,
                padding: EdgeInsets.symmetric(horizontal: 32.wMin),
                borderRadius: 8.wMin,
                color: Color(0xffFB923C).withValues(alpha: 0.8),
                border: Border.all(color: Color(0xffFB923C).withValues(alpha: 0.2), width: 0.8.wMin),
                fontSize: 24.wMin,
                fontColor: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
                sclae: 1.03,
                onTap: () {
                  controller.submitTask();
                },
              ),
            ],
          ),
          SizedBox(height: 32.wMin),
        ],
      ),
    );
  }
}
