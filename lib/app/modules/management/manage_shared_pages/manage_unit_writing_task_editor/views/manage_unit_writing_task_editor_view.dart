import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_beat_utils.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_data.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_composition_slot_strip_widget.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/audio_play_ui_widget.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../bindings/manage_unit_writing_task_editor_binding.dart';
import '../controllers/manage_unit_writing_task_editor_controller.dart';

enum _ImageMediaDialogMode {
  uid,
  upload,
}

class ManageUnitWritingTaskEditorView extends GetView<ManageUnitWritingTaskEditorController> {
  static const double _cardHeight = 455;
  static const List<Map<String, String>> _steps = [
    {
      'label': '题干',
    },
    {
      'label': '题面媒体',
    },
    {
      'label': '知识点和语法',
      'suffix': '可选',
    },
    {
      'label': '预览保存',
    },
  ];

  final String tagText;
  const ManageUnitWritingTaskEditorView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ManageUnitWritingTaskEditorView(tagText: tag),
      binding: ManageUnitWritingTaskEditorBinding(tagText: tag),
      routeName: Routes.MANAGE_UNIT_WRITING_TASK_EDITOR,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () => controller.fetchData(showLoading: true),
      body: Obx(() {
        controller.formRefreshSignal.value;
        final CourseUnitWritingTaskEditorPageEntity? editorData = controller.editorData.value;
        if (controller.isLoading.value && editorData == null) {
          return const SizedBox.shrink();
        }
        if (editorData == null) {
          return const NotDataWidget(message: '暂无写作任务配置');
        }
        return Padding(
          padding: EdgeInsets.fromLTRB(
            90.wMin,
            24.wMin,
            90.wMin,
            24.wMin + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepsWidget(),
              SizedBox(height: 24.wMin),
              Expanded(
                child: _buildStepContentWidget(editorData, context),
              ),
              _buildBottomActionsWidget(editorData),
            ],
          ),
        );
      }),
    );
  }

  /// 顶部步骤条。
  Widget _buildStepsWidget() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (int index = 0; index < _steps.length; index++) ...[
            _buildStepItem(index),
            if (index != _steps.length - 1)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                child: SizedBox(
                  width: 16.wMin,
                  height: 16.wMin,
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/svg/public/icon_arrow_right.svg',
                      width: 16.wMin,
                      height: 16.wMin,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepItem(int index) {
    final int step = index + 1;
    final bool isActive = controller.currentStep.value == step;
    final bool isDone = controller.currentStep.value > step;
    final String label = _steps[index]['label'] ?? '';
    final String suffix = _steps[index]['suffix'] ?? '';
    final Color textColor = isActive || isDone ? AppTheme.cZhenxieFontPrimary : AppTheme.cZhenxieFontSecondary;
    return Container(
      height: 48.wMin,
      padding: EdgeInsets.symmetric(horizontal: 12.wMin),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.cZhenxieColorPrimary.color.withValues(alpha: 0.12) : AppTheme.cZhenxieBackgroundPrimary,
        borderRadius: BorderRadius.circular(999.wMin),
        border: isActive
            ? Border.all(
                color: AppTheme.cZhenxieColorPrimary.color.withValues(alpha: 0.2),
                width: 1.wMin,
              )
            : Border.all(
                color: AppTheme.cZhenxieBorderPrimary,
                width: 1.wMin,
              ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32.wMin,
            height: 32.wMin,
            decoration: BoxDecoration(
              color: isDone ? AppTheme.cZhenxieFontPrimary: AppTheme.cZhenxieBackgroundPrimary,
              borderRadius: BorderRadius.circular(999.wMin),
              border: Border.all(
                color: AppTheme.cZhenxieBorderPrimary,
                width: 1.wMin,
              ),
            ),
            alignment: Alignment.center,
            child: isDone
                ? Icon(
                    Icons.check,
                    size: 16.wMin,
                    color: AppTheme.cBgPrimary,
                  )
                : Text(
                    '$step',
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      height: 1.0,
                    ),
                  ),
          ),
          SizedBox(width: 6.wMin),
          Text(
            label,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w600,
              color: textColor,
              height: 1.0,
            ),
          ),
          if (suffix.isNotEmpty) SizedBox(width: 4.wMin),
          if (suffix.isNotEmpty)
            Text(
              suffix,
              style: TextStyle(
                fontSize: 10.5.wMin,
                fontWeight: FontWeight.w400,
                color: const Color(0x66E6DCC8),
                height: 1.0,
              ),
            ),
        ],
      ),
    );
  }

  /// 按当前步骤切换内容区。
  Widget _buildStepContentWidget(CourseUnitWritingTaskEditorPageEntity editorData, BuildContext context) {
    if (controller.currentStep.value == 1) {
      return _buildEditTaskStepWidget(editorData);
    }
    if (controller.currentStep.value == 2) {
      return _buildMediaStepPlaceholderWidget(context);
    }
    if (controller.currentStep.value == 3) {
      return _buildKnowledgeStepPlaceholderWidget(editorData);
    }
    return _buildPreviewStepPlaceholderWidget(editorData);
  }

  /// 第 1 步：阶梯卡片和中英文表单。
  Widget _buildEditTaskStepWidget(CourseUnitWritingTaskEditorPageEntity editorData) {
    final StageCardData? stage = editorData.stage;
    return ListView(
      children: [
        if (stage != null) _buildStageCardWidget(stage),
        if (stage != null) SizedBox(height: 24.wMin),
        if (controller.shouldShowAnswerCountEditor(stage))
          _buildPanelShell(
            child: Row(
              children: [
                Text(
                  '这一份交几份',
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cZhenxieFontPrimary,
                  ),
                ),
                SizedBox(width: 12.wMin),
                Text(
                  '阶梯允许 ${stage?.answerMinCount}-${stage?.answerMaxCount}',
                  style: TextStyle(
                    fontSize: 14.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontSecondary,
                  ),
                ),
                const Spacer(),
                ...List.generate(
                  (stage!.answerMaxCount! - stage.answerMinCount!) + 1,
                  (index) {
                    final int count = stage.answerMinCount! + index;
                    return Padding(
                      padding: EdgeInsets.only(left: index == 0 ? 0 : 6.wMin),
                      child: _buildMediaCountButton(
                        text: '$count',
                        isSelected: controller.answerCount.value == count,
                        onTap: () {
                          controller.setAnswerCount(count);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        if (controller.shouldShowAnswerCountEditor(stage)) SizedBox(height: 24.wMin),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildPanelShell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '中文（必填）',
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cZhenxieFontSecondary,
                      ),
                    ),
                    SizedBox(height: 16.wMin),
                    CardInputWidget(
                      title: '短名 · 列表卡标题',
                      hintText: '请输入中文短名',
                      controller: controller.nameZhController,
                      height: 54.wMin,
                      
                      fillColor: AppTheme.cSurfaceTranslucentBase.color,
                      borderColor: AppTheme.cBorderThin.color,
                      borderRadius: BorderRadius.circular(8.wMin),
                      titleStyle: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cZhenxieFontTertiary,
                      ),
                      valueStyle: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.cZhenxieFontPrimary,
                      ),
                      hintStyle: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cZhenxieFontSecondary,
                      ),
                      onClean: () {
                        controller.nameZhController.clear();
                      },
                    ),
                    SizedBox(height: 16.wMin),
                    CardInputWidget(
                      title: '题干 · 学员看到的要求',
                      hintText: '写清楚写什么，写给谁，要包含哪些内容',
                      controller: controller.stemZhController,
                      height: 94.wMin,
                      maxLines: 3,
                      fillColor: AppTheme.cSurfaceTranslucentBase.color,
                      borderColor: AppTheme.cBorderThin.color,
                      borderRadius: BorderRadius.circular(8.wMin),
                      titleStyle: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cZhenxieFontTertiary,
                      ),
                      valueStyle: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cZhenxieFontPrimary,
                        height: 1.6,
                      ),
                      hintStyle: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cZhenxieFontSecondary,
                        height: 1.6,
                      ),
                      onClean: () {
                        controller.stemZhController.clear();
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 24.wMin),
            Expanded(
              child: _buildPanelShell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ENGLISH（可选）',
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cZhenxieFontSecondary,
                      ),
                    ),
                    SizedBox(height: 16.wMin),
                    CardInputWidget(
                      title: '短名 · 列表卡标题',
                      hintText: 'e.g. Say hello to a new classmate',
                      controller: controller.nameEnController,
                      height: 54.wMin,
                      fillColor: AppTheme.cSurfaceTranslucentBase.color,
                      borderColor: AppTheme.cBorderThin.color,
                      borderRadius: BorderRadius.circular(8.wMin),
                      titleStyle: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cZhenxieFontTertiary,
                      ),
                      valueStyle: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.cZhenxieFontPrimary,
                      ),
                      hintStyle: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cZhenxieFontSecondary,
                      ),
                      onClean: () {
                        controller.nameEnController.clear();
                      },
                    ),
                    SizedBox(height: 16.wMin),
                    CardInputWidget(
                      title: '题干 · 学员看到的要求',
                      hintText: 'Write clearly what to write, who it is for, and what to include',
                      controller: controller.stemEnController,
                      height: 94.wMin,
                      maxLines: 3,
                      fillColor: AppTheme.cSurfaceTranslucentBase.color,
                      borderColor: AppTheme.cBorderThin.color,
                      borderRadius: BorderRadius.circular(8.wMin),
                      titleStyle: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cZhenxieFontTertiary,
                      ),
                      valueStyle: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cZhenxieFontPrimary,
                        height: 1.6,
                      ),
                      hintStyle: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cZhenxieFontSecondary,
                        height: 1.6,
                      ),
                      onClean: () {
                        controller.stemEnController.clear();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 第 1 步顶部只读阶梯卡片。
  Widget _buildStageCardWidget(StageCardData stage) {
    return ZhenxieWriteCatalogCardWidget(
      stageData: stage,
      height: _cardHeight,
      copyLabel: '阶梯',
      showCopyTag: (stage.nid ?? '').isNotEmpty,
    );
  }

  /// 第 2 步占位区，先展示接口里已有媒体数据。
  Widget _buildMediaStepPlaceholderWidget(BuildContext context) {
    return ListView(
      children: [
        _buildPanelShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMediaHeaderWidget(
                title: '题面图片',
                helperText: '先选张数，再逐格关联 UID 或上传',
                action: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '张数',
                      style: TextStyle(
                        fontSize: 14.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cZhenxieFontSecondary,
                      ),
                    ),
                    SizedBox(width: 6.wMin),
                    ...List.generate(7, (index) {
                      final bool isSelected = controller.stemImages.length == index;
                      return Padding(
                        padding: EdgeInsets.only(left: index == 0 ? 0 : 6.wMin),
                        child: _buildMediaCountButton(
                          text: '$index',
                          isSelected: isSelected,
                          onTap: () {
                            controller.setStemImageCount(index);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(height: 20.wMin),
              if (controller.stemImages.isEmpty)
                _buildEmptyMediaText('不放图片。'),
              if (controller.stemImages.isNotEmpty)
                Wrap(
                  spacing: 16.wMin,
                  runSpacing: 16.wMin,
                  children: List.generate(controller.stemImages.length, (index) {
                    final String imageKey = controller.stemImages[index];
                    final String imageUid = controller.stemImageInputUids.length > index ? controller.stemImageInputUids[index] : '';
                    final String imageUrl = controller.stemImageUrls.length > index ? controller.stemImageUrls[index] : '';
                    return _buildMediaActionCard(
                      title: '图片${index + 1}',
                      value: imageKey,
                      uidText: imageUid,
                      preview: imageKey.isNotEmpty && imageUrl.isNotEmpty
                          ? CachedImageWidget(
                              imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(24.wMin),
                            )
                          : null,
                      onInputTap: () {
                        _showImageMediaDialog(
                          context: context,
                          index: index,
                          initialMode: _ImageMediaDialogMode.uid,
                        );
                      },
                      onUploadTap: () {
                        _showImageMediaDialog(
                          context: context,
                          index: index,
                          initialMode: _ImageMediaDialogMode.upload,
                        );
                      },
                      onReplaceTap: () {
                        _showImageMediaDialog(
                          context: context,
                          index: index,
                          initialMode: _ImageMediaDialogMode.upload,
                        );
                      },
                      uploadText: '上传图片',
                    );
                  }),
                ),
              SizedBox(height: 32.wMin),
              _buildMediaSectionDivider(),
              SizedBox(height: 32.wMin),
              _buildMediaHeaderWidget(
                title: '题面音频',
                helperText: '最多 1 个',
                action: _buildMediaActionButton(
                  text: controller.showStemAudioEditor.value ? '不要音频' : '加一个音频',
                  backgroundColor: controller.showStemAudioEditor.value
                      ? AppTheme.cZhenxieFontPrimary
                      : AppTheme.cZhenxieBackgroundPrimary,
                  borderColor: AppTheme.cZhenxieBorderPrimary,
                  textColor: controller.showStemAudioEditor.value
                      ? AppTheme.cBgPrimary
                      : AppTheme.cZhenxieFontPrimary,
                  onTap: controller.showStemAudioEditor.value
                      ? controller.clearStemAudio
                      : controller.enableStemAudioEditor,
                ),
              ),
              SizedBox(height: 20.wMin),
              if (!controller.showStemAudioEditor.value)
                _buildEmptyMediaText('不放音频。'),
              if (controller.showStemAudioEditor.value)
                _buildMediaActionCard(
                  title: '音频1',
                  value: controller.stemAudios.isEmpty ? '' : controller.stemAudios.first,
                  uidText: controller.stemAudioInputUid.value,
                  preview: controller.stemAudios.isNotEmpty &&
                          controller.stemAudios.first.isNotEmpty &&
                          controller.stemAudioUrls.isNotEmpty &&
                          controller.stemAudioUrls.first.isNotEmpty
                      ? Container(
                          width: double.infinity,
                          height: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 20.wMin),
                          decoration: BoxDecoration(
                            color: AppTheme.cZhenxieBackgroundPrimary,
                            borderRadius: BorderRadius.circular(24.wMin),
                          ),
                          child: Center(
                            child: AudioPlayUiWidget(
                              audioUrl: controller.stemAudioUrls.first,
                              showDownload: false,
                            ),
                          ),
                        )
                      : null,
                  onInputTap: () {
                    _showAudioMediaDialog(
                      context: context,
                      initialMode: _ImageMediaDialogMode.uid,
                    );
                  },
                  onUploadTap: () {
                    _showAudioMediaDialog(
                      context: context,
                      initialMode: _ImageMediaDialogMode.upload,
                    );
                  },
                  onReplaceTap: () {
                    _showAudioMediaDialog(
                      context: context,
                      initialMode: _ImageMediaDialogMode.upload,
                    );
                  },
                  uploadText: '上传音频',
                ),
              SizedBox(height: 32.wMin),
              _buildMediaSectionDivider(),
              SizedBox(height: 32.wMin),
              _buildMediaHeaderWidget(
                title: '题面视频',
                helperText: '最多 1 个',
                action: _buildMediaActionButton(
                  text: controller.showStemVideoEditor.value ? '不要视频' : '加一个视频',
                  backgroundColor: controller.showStemVideoEditor.value
                      ? AppTheme.cZhenxieFontPrimary
                      : AppTheme.cZhenxieBackgroundPrimary,
                  borderColor: AppTheme.cZhenxieBorderPrimary,
                  textColor: controller.showStemVideoEditor.value
                      ? AppTheme.cBgPrimary
                      : AppTheme.cZhenxieFontPrimary,
                  onTap: controller.showStemVideoEditor.value
                      ? controller.clearStemVideo
                      : controller.enableStemVideoEditor,
                ),
              ),
              SizedBox(height: 20.wMin),
              if (!controller.showStemVideoEditor.value)
                _buildEmptyMediaText('不放视频。'),
              if (controller.showStemVideoEditor.value)
                _buildMediaActionCard(
                  title: '视频1',
                  value: controller.stemVideos.isEmpty ? '' : controller.stemVideos.first,
                  uidText: controller.stemVideoInputUid.value,
                  preview: controller.stemVideos.isNotEmpty &&
                          controller.stemVideos.first.isNotEmpty &&
                          controller.stemVideoUrls.isNotEmpty &&
                          controller.stemVideoUrls.first.isNotEmpty
                      ? PlayVideoWidget(
                          videoUrl: controller.stemVideoUrls.first,
                          isManagement: true,
                          forceVideoMode: true,
                        )
                      : null,
                  onInputTap: () {
                    _showVideoMediaDialog(
                      context: context,
                      initialMode: _ImageMediaDialogMode.uid,
                    );
                  },
                  onUploadTap: () {
                    _showVideoMediaDialog(
                      context: context,
                      initialMode: _ImageMediaDialogMode.upload,
                    );
                  },
                  onReplaceTap: () {
                    _showVideoMediaDialog(
                      context: context,
                      initialMode: _ImageMediaDialogMode.upload,
                    );
                  },
                  uploadText: '上传视频',
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaHeaderWidget({
    required String title,
    required String helperText,
    required Widget action,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cZhenxieFontPrimary,
                    ),
                  ),
                  SizedBox(width: 8.wMin),
                  Text(
                    helperText,
                    style: TextStyle(
                      fontSize: 14.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cZhenxieFontSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 16.wMin),
        action,
      ],
    );
  }

  Widget _buildMediaSectionDivider() {
    return Container(
      width: double.infinity,
      height: 1.wMin,
      color: AppTheme.cBorderThin.color,
    );
  }

  Widget _buildEmptyMediaText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.wMin,
        fontWeight: FontWeight.w400,
        color: AppTheme.cZhenxieFontSecondary,
      ),
    );
  }

  Widget _buildMediaCountButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ButtonWidget(
      width: 32.wMin,
      height: 32.wMin,
      borderRadius: 999.wMin,
      padding: EdgeInsets.zero,
      color: isSelected ? AppTheme.cZhenxieFontPrimary : AppTheme.cZhenxieBackgroundPrimary,
      border: Border.all(
        color: isSelected ? Colors.transparent : AppTheme.cBorderThin.color,
        width: 1.wMin,
      ),
      fontSize: 13.wMin,
      fontWeight: FontWeight.w600,
      fontColor: isSelected ? AppTheme.cBgPrimary : AppTheme.cZhenxieFontSecondary,
      text: text,
      onTap: onTap,
      sclae: 1.02,
    );
  }

  Widget _buildMediaActionButton({
    required String text,
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? borderColor,
    Color? textColor,
  }) {
    return ButtonWidget(
      height: 58.wMin,
      width: 140,
      borderRadius: 999.wMin,
      color: backgroundColor ?? AppTheme.cZhenxieBackgroundPrimary,
      border: Border.all(
        color: borderColor ?? AppTheme.cZhenxieBorderPrimary,
        width: 1.wMin,
      ),
      fontSize: 20.wMin,
      fontWeight: FontWeight.w500,
      fontColor: textColor ?? AppTheme.cZhenxieFontSecondary,
      text: text,
      onTap: onTap,
      sclae: 1.02,
    );
  }

  Widget _buildMediaActionCard({
    required String title,
    required String value,
    String uidText = '',
    Widget? preview,
    required VoidCallback onInputTap,
    required VoidCallback onUploadTap,
    required VoidCallback onReplaceTap,
    required String uploadText,
  }) {
    final bool hasPreview = preview != null;
    final bool hasUid = !hasPreview && uidText.isNotEmpty;
    final String mediaLabel = title.replaceAll(RegExp(r'\d+$'), '');
    return Container(
      height: 240.wMin,
      width: 240.wMin,
      decoration: BoxDecoration(
        color: AppTheme.cZhenxieBackgroundPrimary,
        borderRadius: BorderRadius.circular(24.wMin),
      ),
      child: hasPreview
          ? Stack(
              children: [
                Positioned.fill(child: preview),
                Positioned(
                  top: 12.wMin,
                  left: 12.wMin,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.42),
                          borderRadius: BorderRadius.circular(999.wMin),
                        ),
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16.wMin,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.cZhenxieFontPrimary,
                          ),
                        ),
                      ),
                      if (uidText.isNotEmpty) SizedBox(width: 8.wMin),
                      if (uidText.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.42),
                            borderRadius: BorderRadius.circular(999.wMin),
                          ),
                          child: Text(
                            'UID $uidText',
                            style: TextStyle(
                              fontSize: 16.wMin,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.cZhenxieFontPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  right: 12.wMin,
                  bottom: 12.wMin,
                  child: _buildMediaFloatingReplaceButton(
                    onTap: onReplaceTap,
                  ),
                ),
              ],
            )
          : Padding(
              padding: EdgeInsets.all(16.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cZhenxieFontPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.wMin),
                  Expanded(
                    child: !hasUid
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildMediaActionButton(
                                text: '输入UID',
                                onTap: onInputTap,
                              ),
                              SizedBox(height: 12.wMin),
                              _buildMediaActionButton(
                                text: uploadText,
                                onTap: onUploadTap,
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$mediaLabel UID',
                                style: TextStyle(
                                  fontSize: 16.wMin,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.cZhenxieFontSecondary,
                                ),
                              ),
                              SizedBox(height: 8.wMin),
                              Text(
                                uidText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 30.wMin,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.cZhenxieFontPrimary,
                                ),
                              ),
                            ],
                          ),
                  ),
                  if (hasUid)
                    Row(
                      children: [
                        const Spacer(),
                        SizedBox(width: 6.wMin),
                        _buildMediaFloatingReplaceButton(
                          onTap: onReplaceTap,
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildMediaFloatingReplaceButton({
    required VoidCallback onTap,
  }) {
    return ButtonWidget(
      height: 32.wMin,
      borderRadius: 999.wMin,
      padding: EdgeInsets.symmetric(horizontal: 12.wMin),
      color: AppTheme.cZhenxieBackgroundPrimary.withValues(alpha: 0.92),
      border: Border.all(
        color: AppTheme.cZhenxieBorderPrimary,
        width: 1.wMin,
      ),
      fontSize: 16.wMin,
      fontWeight: FontWeight.w600,
      fontColor: AppTheme.cBgPrimary,
      leftIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.refresh,
            size: 16.wMin,
            color: AppTheme.cBgPrimary,
          ),
          SizedBox(width: 4.wMin),
        ],
      ),
      text: '替换',
      onTap: onTap,
      sclae: 1.02,
    );
  }

  Future<void> _showImageMediaDialog({
    required BuildContext context,
    required int index,
    required _ImageMediaDialogMode initialMode,
  }) async {
    await _showMediaDialog(
      context: context,
      initialMode: initialMode,
      uidTabText: '输入图片 UID',
      uploadTabText: '上传图片',
      uidLabel: '图片 UID',
      uidHintText: '图片库里的 UID，如 12345',
      uploadHintText: '支持 PNG / JPG / WebP',
      uploadActionText: '点击上传图片',
      initialUidText: controller.stemImageInputUids.length > index ? controller.stemImageInputUids[index] : '',
      onUidConfirm: (String uidText) async {
        await controller.setStemImageByInput(index, uidText);
        final String afterValue = controller.stemImages.length > index ? controller.stemImages[index] : '';
        return afterValue.isNotEmpty;
      },
      onUploadConfirm: (BuildContext dialogContext) async {
        await controller.uploadStemImage(dialogContext, index);
        final String afterValue = controller.stemImages.length > index ? controller.stemImages[index] : '';
        return afterValue.isNotEmpty;
      },
    );
  }

  Future<void> _showAudioMediaDialog({
    required BuildContext context,
    required _ImageMediaDialogMode initialMode,
  }) async {
    await _showMediaDialog(
      context: context,
      initialMode: initialMode,
      uidTabText: '输入音频 UID',
      uploadTabText: '上传音频',
      uidLabel: '音频 UID',
      uidHintText: '音频库里的 UID，如 12345',
      uploadHintText: '支持 MP3 / WAV / M4A / AAC',
      uploadActionText: '点击上传音频',
      initialUidText: controller.stemAudioInputUid.value,
      onUidConfirm: (String uidText) async {
        await controller.setStemAudioByInput(uidText);
        final String afterValue = controller.stemAudios.isEmpty ? '' : controller.stemAudios.first;
        return afterValue.isNotEmpty;
      },
      onUploadConfirm: (BuildContext dialogContext) async {
        await controller.uploadStemAudio();
        final String afterValue = controller.stemAudios.isEmpty ? '' : controller.stemAudios.first;
        return afterValue.isNotEmpty;
      },
    );
  }

  Future<void> _showVideoMediaDialog({
    required BuildContext context,
    required _ImageMediaDialogMode initialMode,
  }) async {
    await _showMediaDialog(
      context: context,
      initialMode: initialMode,
      uidTabText: '输入视频 UID',
      uploadTabText: '上传视频',
      uidLabel: '视频 UID',
      uidHintText: '视频库里的 UID，如 12345',
      uploadHintText: '支持 MP4 / MOV / M4V',
      uploadActionText: '点击上传视频',
      initialUidText: controller.stemVideoInputUid.value,
      onUidConfirm: (String uidText) async {
        await controller.setStemVideoByInput(uidText);
        final String afterValue = controller.stemVideos.isEmpty ? '' : controller.stemVideos.first;
        return afterValue.isNotEmpty;
      },
      onUploadConfirm: (BuildContext dialogContext) async {
        await controller.uploadStemVideo();
        final String afterValue = controller.stemVideos.isEmpty ? '' : controller.stemVideos.first;
        return afterValue.isNotEmpty;
      },
    );
  }

  Future<void> _showMediaDialog({
    required BuildContext context,
    required _ImageMediaDialogMode initialMode,
    required String uidTabText,
    required String uploadTabText,
    required String uidLabel,
    required String uidHintText,
    required String uploadHintText,
    required String uploadActionText,
    required String initialUidText,
    required Future<bool> Function(String uidText) onUidConfirm,
    required Future<bool> Function(BuildContext dialogContext) onUploadConfirm,
  }) async {
    _ImageMediaDialogMode currentMode = initialMode;
    final TextEditingController uidController = TextEditingController(text: initialUidText);
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 24.wMin),
              child: Container(
                width: 520.wMin,
                constraints: BoxConstraints(maxWidth: 520.wMin),
                decoration: BoxDecoration(
                  color: const Color(0xff11151D),
                  borderRadius: BorderRadius.circular(24.wMin),
                  border: Border.all(
                    color: AppTheme.cBgPrimary,
                    width: 1.wMin,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 16.wMin),
                      child: Row(
                        children: [
                          _buildMediaDialogTabButton(
                            text: uidTabText,
                            selected: currentMode == _ImageMediaDialogMode.uid,
                            onTap: () {
                              setState(() {
                                currentMode = _ImageMediaDialogMode.uid;
                              });
                            },
                          ),
                          SizedBox(width: 6.wMin),
                          _buildMediaDialogTabButton(
                            text: uploadTabText,
                            selected: currentMode == _ImageMediaDialogMode.upload,
                            onTap: () {
                              setState(() {
                                currentMode = _ImageMediaDialogMode.upload;
                              });
                            },
                          ),
                          const Spacer(),
                          TapScaleWidget(
                            onTap: () {
                              Navigator.of(dialogContext).pop();
                            },
                            sclae: 1.02,
                            child: Container(
                              width: 32.wMin,
                              height: 32.wMin,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.close,
                                size: 18.wMin,
                                color: AppTheme.cZhenxieFontSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 1.wMin,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20.wMin),
                      child: currentMode == _ImageMediaDialogMode.uid
                          ? _buildMediaUidDialogContent(
                              uidController: uidController,
                              uidLabel: uidLabel,
                              uidHintText: uidHintText,
                              onConfirm: () async {
                                final String uidText = uidController.text.trim();
                                if (uidText.isEmpty) return;
                                final bool success = await onUidConfirm(uidText);
                                if (success && dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                }
                              },
                            )
                          : _buildMediaUploadDialogContent(
                              uploadActionText: uploadActionText,
                              uploadHintText: uploadHintText,
                              onUploadTap: () async {
                                final bool success = await onUploadConfirm(dialogContext);
                                if (success && dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                }
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    uidController.dispose();
  }

  Widget _buildMediaDialogTabButton({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.02,
      child: Container(
        height: 32.wMin,
        padding: EdgeInsets.symmetric(horizontal: 14.wMin),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffF4EFE6) : Colors.transparent,
          borderRadius: BorderRadius.circular(999.wMin),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13.wMin,
            fontWeight: FontWeight.w600,
            color: selected ? const Color(0xff0B0F17) : AppTheme.cZhenxieFontSecondary.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaUidDialogContent({
    required TextEditingController uidController,
    required String uidLabel,
    required String uidHintText,
    required VoidCallback onConfirm,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          uidLabel,
          style: TextStyle(
            fontSize: 12.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cZhenxieFontSecondary.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 6.wMin),
        TextField(
          controller: uidController,
          style: TextStyle(
            fontSize: 14.wMin,
            fontWeight: FontWeight.w400,
            color: const Color(0xffF4EFE6),
          ),
          decoration: InputDecoration(
            hintText: uidHintText,
            hintStyle: TextStyle(
              fontSize: 14.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontSecondary.withValues(alpha: 0.35),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.04),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 14.wMin),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.wMin),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.wMin,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.wMin),
              borderSide: BorderSide(
                color: AppTheme.cZhenxieBorderPrimary,
                width: 1.wMin,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.wMin),
        ButtonWidget(
          width: double.infinity,
          height: 52.wMin,
          borderRadius: 16.wMin,
          color: const Color(0xffF4EFE6),
          fontSize: 14.wMin,
          fontWeight: FontWeight.w600,
          fontColor: const Color(0xff0B0F17),
          text: '确认关联',
          onTap: onConfirm,
          sclae: 1.02,
        ),
      ],
    );
  }

  Widget _buildMediaUploadDialogContent({
    required String uploadActionText,
    required String uploadHintText,
    required VoidCallback onUploadTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TapScaleWidget(
          onTap: onUploadTap,
          sclae: 1.01,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 28.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 2.wMin,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.upload_outlined,
                  size: 26.wMin,
                  color: AppTheme.cZhenxieFontSecondary.withValues(alpha: 0.4),
                ),
                SizedBox(height: 8.wMin),
                Text(
                  uploadActionText,
                  style: TextStyle(
                    fontSize: 13.5.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontSecondary.withValues(alpha: 0.75),
                  ),
                ),
                SizedBox(height: 4.wMin),
                Text(
                  uploadHintText,
                  style: TextStyle(
                    fontSize: 11.5.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontSecondary.withValues(alpha: 0.38),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 第 3 步知识点和语法选择区。
  Widget _buildKnowledgeStepPlaceholderWidget(CourseUnitWritingTaskEditorPageEntity editorData) {
    final List<CourseUnitWritingEditorKnowledgeItemEntity> lexicalList = (editorData.knowledgeList ?? const <CourseUnitWritingEditorKnowledgeItemEntity>[])
        .where((item) => controller.isLexicalKnowledgeItem(item))
        .toList();
    final List<CourseUnitWritingGrammarTargetItemEntity> grammarList =
        editorData.grammarTargetList ?? const <CourseUnitWritingGrammarTargetItemEntity>[];
    final int selectedLexicalCount = controller.getSelectedLexicalKnowledgeCount(lexicalList);
    final int outsideLexicalCount = controller.getOutsideLexicalKnowledgeCount(lexicalList);
    return ListView(
      children: [
        Text(
          '可选。勾上的单词和短语写进任务，写范文时模型只用这些。不勾就是本单元全部。已选 $selectedLexicalCount 个${outsideLexicalCount > 0 ? '，其中 $outsideLexicalCount 个不在本单元里（保留不动）' : ''}。句子按语法点抽，不在这里勾。',
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cZhenxieFontTertiary,
          ),
        ),
        SizedBox(height: 16.wMin),
        _buildPanelShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$selectedLexicalCount/${lexicalList.length}',
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cZhenxieFontSecondary,
                    ),
                  ),
                  const Spacer(),
                  _buildKnowledgeActionText(
                    text: '全选',
                    onTap: () {
                      controller.selectAllLexicalKnowledge(lexicalList);
                    },
                  ),
                  SizedBox(width: 6.wMin),
                  _buildKnowledgeActionText(
                    text: '清空',
                    onTap: () {
                      controller.clearLexicalKnowledge(lexicalList);
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.wMin),
              if (lexicalList.isEmpty)
                Text(
                  '这个单元还没有可选的单词和短语。',
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontSecondary,
                  ),
                ),
              if (lexicalList.isNotEmpty)
                Wrap(
                  spacing: 8.wMin,
                  runSpacing: 8.wMin,
                  children: List<Widget>.generate(lexicalList.length, (index) {
                    final CourseUnitWritingEditorKnowledgeItemEntity item = lexicalList[index];
                    final String contentText = (item.content ?? '').isNotEmpty
                        ? item.content!
                        : '${item.contentType ?? ''} ${item.contentId ?? ''}';
                    final String displayText = (item.definition ?? '').isNotEmpty
                        ? '$contentText ${item.definition}'
                        : contentText;
                    return _buildKnowledgeChoiceChip(
                      text: displayText,
                      selected: controller.isKnowledgePointSelected(item),
                      onTap: () {
                        controller.toggleKnowledgePoint(item);
                      },
                    );
                  }),
                ),
            ],
          ),
        ),
        SizedBox(height: 16.wMin),
        _buildPanelShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '语法点',
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cZhenxieFontPrimary,
                    ),
                  ),
                  SizedBox(width: 8.wMin),
                  Text(
                    controller.selectedGrammarTargetUids.isEmpty
                        ? '不选 · 全部 ${grammarList.length}'
                        : '${controller.selectedGrammarTargetUids.length}/${grammarList.length}',
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cZhenxieFontSecondary,
                    ),
                  ),
                  if (controller.selectedGrammarTargetUids.isNotEmpty) const Spacer(),
                  if (controller.selectedGrammarTargetUids.isNotEmpty)
                    _buildKnowledgeActionText(
                      text: '清空',
                      onTap: controller.clearGrammarTargets,
                    ),
                ],
              ),
              SizedBox(height: 16.wMin),
              if (grammarList.isEmpty)
                Text(
                  '这个单元还没有已审的语法点。',
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontSecondary,
                  ),
                ),
              if (grammarList.isNotEmpty)
                Wrap(
                  spacing: 8.wMin,
                  runSpacing: 8.wMin,
                  children: List<Widget>.generate(grammarList.length, (index) {
                    final CourseUnitWritingGrammarTargetItemEntity item = grammarList[index];
                    final String title = controller.getLangText(item.title, 'zh');
                    return _buildKnowledgeChoiceChip(
                      text: title.isNotEmpty ? title : '语法点 ${item.uid ?? ''}',
                      selected: controller.isGrammarTargetSelected(item.uid),
                      onTap: () {
                        controller.toggleGrammarTarget(item.uid);
                      },
                    );
                  }),
                ),
              SizedBox(height: 16.wMin),
              Text(
                '不选就是全部已审。勾了成对、词形变化或金字塔时，它带上的句型不再单列。',
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 第 4 步预览保存区。
  Widget _buildPreviewStepPlaceholderWidget(CourseUnitWritingTaskEditorPageEntity editorData) {
    final StageCardData? stage = editorData.stage;
    final List<String> issues = controller.collectIssues(editorData);
    final int lexicalKnowledgeCount = controller.selectedKnowledgePoints.where((item) => (item.contentType ?? '') != 'EN_SENTENCE').length;
    final String difficultyLabel = controller.getDifficultyLabel(stage?.difficulty);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildPanelShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '学员视角 · ${(controller.getLangText(stage?.name, 'zh')).isNotEmpty ? controller.getLangText(stage?.name, 'zh') : '未选阶梯'}',
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cZhenxieFontSecondary,
                  ),
                ),
                SizedBox(height: 16.wMin),
                Text(
                  controller.nameZhController.text.trim().isNotEmpty ? controller.nameZhController.text.trim() : '（短名）',
                  style: TextStyle(
                    fontSize: 26.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cZhenxieFontPrimary,
                  ),
                ),
                SizedBox(height: 16.wMin),
                Text(
                  controller.stemZhController.text.trim().isNotEmpty ? controller.stemZhController.text.trim() : '（题干）',
                  style: TextStyle(
                    fontSize: 17.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontPrimary,
                    height: 1.6,
                  ),
                ),
                if (controller.stemEnController.text.trim().isNotEmpty) SizedBox(height: 12.wMin),
                if (controller.stemEnController.text.trim().isNotEmpty)
                  Text(
                    controller.stemEnController.text.trim(),
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cZhenxieFontSecondary,
                      height: 1.6,
                    ),
                  ),
                if (controller.stemImages.isNotEmpty || controller.stemAudios.isNotEmpty || controller.stemVideos.isNotEmpty)
                  SizedBox(height: 16.wMin),
                if (controller.stemImages.isNotEmpty || controller.stemAudios.isNotEmpty || controller.stemVideos.isNotEmpty)
                  _buildPreviewMediaWidget(),
                if (stage != null) SizedBox(height: 16.wMin),
                if (stage != null)
                  Container(
                    padding: EdgeInsets.only(top: 16.wMin),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppTheme.cBorderThin.color,
                          width: 1.wMin,
                        ),
                      ),
                    ),
                    child: ZhenxieCompositionSlotStripWidget(
                      stage: stage.toCompositionStageModel(),
                      beatMap: zhenxieBeatMap,
                      beatOrderList: zhenxieBeatOrderList.isNotEmpty
                          ? zhenxieBeatOrderList
                          : stage.slots
                                .map((item) => item.beatNid ?? '')
                                .where((item) => item.isNotEmpty)
                                .toList(),
                      langTextGetter: controller.getLangText,
                      beatNameGetter: getZhenxieBeatName,
                      headLabelGetter: (currentStage) => controller.getLangText(currentStage.headName, 'zh'),
                      tailLabelGetter: (currentStage) => controller.getLangText(currentStage.tailName, 'zh'),
                      hasHeadGetter: (currentStage) => currentStage.hasHead == true,
                      hasTailGetter: (currentStage) => currentStage.hasTail == true,
                    ),
                  ),
                SizedBox(height: 16.wMin),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 12.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.wMin),
                    border: Border.all(
                      color: AppTheme.cBorderPrimary.color,
                      width: 1.wMin,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getPreviewAnswerIcon(stage?.answerKind),
                        size: 16.wMin,
                        color: AppTheme.cZhenxieFontSecondary,
                      ),
                      SizedBox(width: 8.wMin),
                      Expanded(
                        child: Text(
                          '作答：${_getPreviewAnswerText(stage, controller.answerCount.value)}',
                          style: TextStyle(
                            fontSize: 16.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cZhenxieFontSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 20.wMin),
        SizedBox(
          width: 540.wMin,
          child: Column(
            children: [
              _buildPanelShell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '落库',
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cZhenxieFontSecondary,
                      ),
                    ),
                    SizedBox(height: 16.wMin),
                    _buildPreviewSummaryRow('难度', difficultyLabel.isNotEmpty ? difficultyLabel : '--'),
                    _buildPreviewSummaryRow('answerCount', '${controller.answerCount.value ?? 0}'),
                    _buildPreviewSummaryRow('单词和短语', lexicalKnowledgeCount > 0 ? '$lexicalKnowledgeCount' : '全部'),
                    _buildPreviewSummaryRow('语法点', controller.selectedGrammarTargetUids.isNotEmpty ? '${controller.selectedGrammarTargetUids.length}' : '全部已审'),
                    _buildPreviewSummaryRow(
                      '题面媒体',
                      '${controller.stemImages.length + controller.stemAudios.length + controller.stemVideos.length}',
                    ),
                    _buildPreviewSummaryRow(
                      '保存方式',
                      controller.taskId == null ? '新建写作任务' : '保存写作任务',
                      isLast: true,
                    ),
                  ],
                ),
              ),
              if (issues.isNotEmpty) SizedBox(height: 12.wMin),
              if (issues.isNotEmpty)
                _buildPanelShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List<Widget>.generate(issues.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: index == issues.length - 1 ? 0 : 8.wMin),
                        child: Text(
                          '· ${issues[index]}',
                          style: TextStyle(
                            fontSize: 16.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cSurfaceError.color,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// 底部步骤按钮。
  Widget _buildBottomActionsWidget(CourseUnitWritingTaskEditorPageEntity editorData) {
    final bool canNext = controller.canGoNext(editorData);
    final List<String> issues = controller.collectIssues(editorData);
    return Container(
      padding: EdgeInsets.fromLTRB(0, 24.wMin, 0, 24.wMin),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.cBorderDefault.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (controller.currentStep.value > 1)
                ManageButton(
                  width: 132.wMin,
                  height: 64.wMin,
                  radius: 99.wMin,
                  text: '上一步',
                  color: AppTheme.cBorderDefault.color,
                  borderColor: AppTheme.cBorderThin.color,
                  style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cTextPrimary.color,
                    height: 1.0,
                  ),
                  onTap: controller.toPrevStep,
                ),
              if (controller.currentStep.value > 1) SizedBox(width: 8.wMin),
              Text(
                '第 ${controller.currentStep.value} / 4 步${!canNext && controller.currentStep.value != 4 ? ' · 这一步还没填完' : ''}',
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontSecondary,
                ),
              ),
            ],
          ),
          ManageButton(
              width: controller.currentStep.value == 4 ? 176.wMin : 120.wMin,
            height: 64.wMin,
            radius: 99.wMin,
            text: controller.currentStep.value == 4
                ? (controller.isSaving.value ? '保存中' : '保存任务')
                : '下一步',
            color: AppTheme.cBorderDefault.color,
            borderColor: AppTheme.cBorderThin.color,
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary.color,
              height: 1.0,
            ),
            onTap: controller.currentStep.value == 4
                ? (controller.isSaving.value || issues.isNotEmpty ? null : controller.submitTask)
                : (canNext ? controller.toNextStep : null),
          ),
        ],
      ),
    );
  }

  /// 通用内容面板。
  Widget _buildPanelShell({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentBase.color,
        borderRadius: BorderRadius.circular(28.wMin),
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 1.wMin,
        ),
      ),
      child: child,
    );
  }

  Widget _buildPreviewMediaWidget() {
    final List<Widget> items = <Widget>[];
    for (int index = 0; index < controller.stemImages.length; index++) {
      final String uidText = controller.stemImageInputUids.length > index ? controller.stemImageInputUids[index] : '';
      final String imageUrl = controller.stemImageUrls.length > index ? controller.stemImageUrls[index] : '';
      items.add(
        _buildPreviewMediaCard(
          label: '图片${index + 1}',
          uidText: uidText,
          preview: imageUrl.isNotEmpty
              ? CachedImageWidget(
                  imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(24.wMin),
                )
              : null,
        ),
      );
    }
    for (int index = 0; index < controller.stemAudios.length; index++) {
      final String uidText = index == 0 ? controller.stemAudioInputUid.value : '';
      final String audioUrl = controller.stemAudioUrls.length > index ? controller.stemAudioUrls[index] : '';
      items.add(
        _buildPreviewMediaCard(
          label: '音频${index + 1}',
          uidText: uidText,
          preview: audioUrl.isNotEmpty
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 20.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cZhenxieBackgroundPrimary,
                    borderRadius: BorderRadius.circular(24.wMin),
                  ),
                  child: Center(
                    child: AudioPlayUiWidget(
                      audioUrl: audioUrl,
                      showDownload: false,
                    ),
                  ),
                )
              : null,
        ),
      );
    }
    for (int index = 0; index < controller.stemVideos.length; index++) {
      final String uidText = index == 0 ? controller.stemVideoInputUid.value : '';
      final String videoUrl = controller.stemVideoUrls.length > index ? controller.stemVideoUrls[index] : '';
      items.add(
        _buildPreviewMediaCard(
          label: '视频${index + 1}',
          uidText: uidText,
          preview: videoUrl.isNotEmpty
              ? PlayVideoWidget(
                  videoUrl: videoUrl,
                  isManagement: true,
                )
              : null,
        ),
      );
    }
    return Wrap(
      spacing: 8.wMin,
      runSpacing: 8.wMin,
      children: items,
    );
  }

  Widget _buildPreviewMediaCard({
    required String label,
    String uidText = '',
    Widget? preview,
  }) {
    final bool hasPreview = preview != null;
    final String mediaLabel = label.replaceAll(RegExp(r'\d+$'), '');
    return Container(
      width: 240.wMin,
      height: 240.wMin,
      decoration: BoxDecoration(
        color: AppTheme.cZhenxieBackgroundPrimary.color,
        borderRadius: BorderRadius.circular(24.wMin),
      ),
      child: hasPreview
          ? Stack(
              children: [
                Positioned.fill(child: preview),
                Positioned(
                  top: 12.wMin,
                  left: 12.wMin,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.42),
                          borderRadius: BorderRadius.circular(999.wMin),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 16.wMin,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.cZhenxieFontPrimary,
                          ),
                        ),
                      ),
                      if (uidText.isNotEmpty) SizedBox(width: 8.wMin),
                      if (uidText.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.42),
                            borderRadius: BorderRadius.circular(999.wMin),
                          ),
                          child: Text(
                            'UID $uidText',
                            style: TextStyle(
                              fontSize: 16.wMin,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.cZhenxieFontPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            )
          : Padding(
              padding: EdgeInsets.all(16.wMin),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$mediaLabel UID',
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cZhenxieFontSecondary,
                    ),
                  ),
                  SizedBox(height: 10.wMin),
                  Text(
                    uidText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 30.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cZhenxieFontPrimary,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPreviewSummaryRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.wMin),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontTertiary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cZhenxieFontPrimary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPreviewAnswerIcon(String? answerKind) {
    if (answerKind == 'image') return Icons.image_outlined;
    if (answerKind == 'audio') return Icons.audiotrack_outlined;
    if (answerKind == 'video') return Icons.videocam_outlined;
    return Icons.article_outlined;
  }

  String _getPreviewAnswerText(
    StageCardData? stage,
    int? answerCount,
  ) {
    if (stage == null) return '未配置';
    if (stage.answerKind == 'text') {
      return '写一篇，按阶梯 ${stage.slots.length} 段';
    }
    final String answerTypeText = controller.getAnswerTypeText(stage.answerKind);
    final int currentAnswerCount = answerCount ?? stage.answerMinCount ?? stage.answerMaxCount ?? 1;
    if (answerTypeText.isEmpty) return '交 x$currentAnswerCount';
    return '交 $answerTypeText x$currentAnswerCount';
  }

  Widget _buildKnowledgeActionText({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.wMin),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cZhenxieFontSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildKnowledgeChoiceChip({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
        decoration: BoxDecoration(
          color: selected ? AppTheme.cZhenxieFontPrimary : AppTheme.cZhenxieBackgroundPrimary,
          borderRadius: BorderRadius.circular(999.wMin),
          border: Border.all(
            color: selected ? Colors.transparent : AppTheme.cZhenxieBorderPrimary,
            width: 1.wMin,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: selected ? AppTheme.cBgPrimary : AppTheme.cZhenxieFontSecondary,
          ),
        ),
      ),
    );
  }
}
