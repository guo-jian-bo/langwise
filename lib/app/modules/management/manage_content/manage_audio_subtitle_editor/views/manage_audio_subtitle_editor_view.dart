
import 'dart:io';
import 'dart:ui' show FontFeature;

import 'package:audio_player_ex/audio_player_ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:langwise/utils/toast_utils.dart';
import '../../../../../../common/widgets/button_widgets.dart';
import '../../../../../../common/widgets/tap_scale_widget.dart';
import '../../../../../../common/widgets/ask_dialog.dart';
import '../../../../../../theme/theme.dart';
import '../../../common/ass_edit_widgets/editor_sidebar_btn_widget.dart';
import '../../../common/commons.dart';
import '../../../controllers/management_breadcrumb_controller.dart';
import '../controllers/manage_audio_subtitle_editor_controller.dart';
import '../models/audio_dialogue_model.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../bindings/manage_audio_subtitle_editor_binding.dart';
import 'package:langwise/app/routes/app_pages.dart';
import '../widgets/editor_tool_btn_widget.dart';
import 'audio_waveform_widget.dart';
import 'package:flutter/gestures.dart';
import '../../../../elements/utils/elements_page_utils.dart';
import '../widgets/editor_action_tag_widget.dart';

part 'manage_audio_subtitle_editor_view_dialogs.dart';
part 'manage_audio_subtitle_editor_view_panels.dart';
part 'manage_audio_subtitle_editor_view_player_bar.dart';
part 'manage_audio_subtitle_editor_view_dialogue_cell.dart';
part 'manage_audio_subtitle_editor_view_ktag_list.dart';
part 'manage_audio_subtitle_editor_view_waveform.dart';
part 'manage_audio_subtitle_editor_view_waveform_dialogue.dart';
part 'manage_audio_subtitle_editor_view_waveform_ktag.dart';

class ManageAudioSubtitleEditorView
    extends GetView<ManageAudioSubtitleEditorController> {
  ManageAudioSubtitleEditorView({super.key, required this.tagText});

  final FocusNode waveformFocusNode = FocusNode();
  final String tagText;

  Widget _buildClampTriangle({required Color color, required bool isLeft}) {
    return CustomPaint(
      size: Size(6.wMin, 6.wMin),
      painter: _ClampTrianglePainter(color: color, isLeft: isLeft),
    );
  }

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag =
        '${Routes.MANAGE_AUDIO_SUBTITLE_EDITOR}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageAudioSubtitleEditorView(tagText: tag),
      binding: ManageAudioSubtitleEditorBinding(tag: tag),
      routeName: Routes.MANAGE_AUDIO_SUBTITLE_EDITOR,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  ScrollBehavior _noDefaultScrollbarBehavior() {
    return const _NoDefaultScrollbarScrollBehavior();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManageAudioSubtitleEditorController>(
      tag: tagText,
      builder: (_) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              controller.forceStopAllAudio();
              return;
            }
            _handleBackNavigation();
          },
          child: ManageScaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: AppTheme.cBgPrimary,
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Column(
                children: [
                  // 顶部的tab列表
                  buildHeadWidget(),
                  Expanded(
                    child: _buildCenterBody(context),
                  ),
                  _buildBottomPlayerBar(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCenterBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final contentWidth = (screenWidth * 0.80).clamp(0.0, 1640.wMin);

        return Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: contentWidth,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 16.wMin, right: 16.wMin, bottom: 0.wMin),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Padding(
                        //   padding: EdgeInsets.only(left: 15.wMin),
                        //   child: Text(
                        //     '句子时间轴编辑器',
                        //     style: TextStyle(
                        //       fontSize: 20.wMin,
                        //       color: AppTheme.cTextPrimary,
                        //     ),
                        //   ),
                        // ),
                        controller.editDialogueIndex != null
                            ? ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: controller.dialogueList.length,
                                itemBuilder: (context, index) {
                                  return buildDialogueCellWidget(index);
                                },
                              )
                            : ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: controller.dialogueList.length,
                                itemBuilder: (context, index) {
                                  return LongPressDraggable<DialogueModel>(
                                    data: controller.dialogueList[index],
                                    feedback: Material(
                                      color: Colors.transparent,
                                      child: SizedBox(
                                        width: contentWidth,
                                        child: buildDialogueCellWidget(index),
                                      ),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.3,
                                      child: buildDialogueCellWidget(index),
                                    ),
                                    child: DragTarget<DialogueModel>(
                                      builder: (context, candidateData,
                                          rejectedData) {
                                        return buildDialogueCellWidget(index,
                                            isDropTarget:
                                                candidateData.isNotEmpty);
                                      },
                                      onAcceptWithDetails: (details) {
                                        controller.mergeDialogueModel(
                                            details.data,
                                            controller.dialogueList[index]);
                                      },
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 6.wMin,
              top: 60.wMin,
              child: Align(
                alignment: Alignment.bottomRight,
                child: _buildAudioGenerationStatus(context),
              ),
            ),
            Positioned(
              right: 6.wMin,
              bottom: 0.wMin,
              child: Align(
                alignment: Alignment.bottomRight,
                child: _buildFloatingActionGroup(context),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAudioGenerationStatus(BuildContext context) {
    final status = controller.audioModel?.status;
    final errMsg = controller.audioModel?.errMsg;

    // Don't show if status is null or errMsg is empty for failed state
    if (status == null || (status == 'failed' && (errMsg == null || errMsg.isEmpty))) {
      return const SizedBox.shrink();
    }

    Color backgroundColor;
    Color textColor;
    String text;
    VoidCallback? onTap;

    switch (status) {
      case 'start':
        backgroundColor = AppTheme.cBgBrand.withOpacity(0.2);
        textColor = AppTheme.cBgBrand;
        text = '音频生成中';
        onTap = null;
        break;
      case 'finished':
        backgroundColor = AppTheme.cMorphemeTagRoot.withOpacity(0.2);
        textColor = AppTheme.cMorphemeTagRoot;
        text = '音频已生成';
        onTap = null;
        break;
      case 'failed':
        backgroundColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red;
        text = '音频生成失败';
        onTap = () => _showErrorDialog(context, errMsg);
        break;
      default:
        return const SizedBox.shrink();
    }

    return TapScaleWidget(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4.wMin),

        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == 'start')
              Container(
                width: 8.wMin,
                height: 8.wMin,
                decoration: BoxDecoration(
                  color: textColor,
                  shape: BoxShape.circle,
                ),
              )
            else if (status == 'failed')
              Icon(
                Icons.error_outline,
                size: 16.wMin,
                color: textColor,
              )
            else
              Icon(
                Icons.chevron_right,
                size: 16.wMin,
                color: textColor,
              ),
            SizedBox(width: 6.wMin),
            Text(
              text,
              style: TextStyle(
                fontSize: 16.wMin,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String? errMsg) {
    if (errMsg == null || errMsg.isEmpty) return;

    AskDialog.showCustom<void>(
      context: context,
      title: '生成失败',
      width: 500,
      showTopClose: false,
      actions: [
        AskDialogAction(
          text: '关闭',
          color: AppTheme.cBgTertiary,
          fontColor: AppTheme.cTextSecondary,
          onTap: () => Get.back(),
        ),
      ],
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.wMin),
        child: Text(
          errMsg,
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextPrimary,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  void _handleBackNavigation() {
    if (controller.hasUnsavedChanges) {
      _showUnsavedChangesDialog();
    } else {
      _performBackNavigation();
    }
  }

  void _showUnsavedChangesDialog() {
    AskDialog.showCustom<void>(
      context: Get.context!,
      title: '未保存的更改',
      width: 500,
      showTopClose: false,
      actions: [
        AskDialogAction(
          text: '取消',
          color: AppTheme.cBgTertiary,
          fontColor: AppTheme.cTextSecondary,
          onTap: () => Get.back(),
        ),
        AskDialogAction(
          text: '不保存',
          color: AppTheme.cSurfaceError,
          fontColor: AppTheme.cTextPrimary,
          onTap: () {
            Get.back();
            _performBackNavigation();
          },
        ),
      ],
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.wMin),
        child: Text(
          '您有未保存的更改，确定要退出吗？',
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextPrimary,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  void _performBackNavigation() {
    controller.forceStopAllAudio();
    if (Get.isRegistered<ManagementBreadcrumbController>()) {
      Get.find<ManagementBreadcrumbController>().breadcrumbBack();
    } else {
      Get.back();
    }
  }
}
