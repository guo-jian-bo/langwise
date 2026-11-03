import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_beat_utils.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_composition_slot_strip_widget.dart';
import 'package:langwise/app/modules/zhenxie/zhenxie_composition_stages/models/zhenxie_composition_stages_models.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/values/app_font_value.dart';
import 'package:langwise/common/widgets/audio_play_ui_widget.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../bindings/manage_unit_writing_task_exemplar_binding.dart';
import '../controllers/manage_unit_writing_task_exemplar_controller.dart';

enum _ImageMediaDialogMode {
  uid,
  upload,
}

class ManageUnitWritingTaskExemplarView extends GetView<ManageUnitWritingTaskExemplarController> {
  final String tagText;
  const ManageUnitWritingTaskExemplarView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ManageUnitWritingTaskExemplarView(tagText: tag),
      binding: ManageUnitWritingTaskExemplarBinding(tagText: tag),
      routeName: Routes.MANAGE_UNIT_WRITING_TASK_EXEMPLAR,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () => controller.fetchData(showLoading: true),
      body: Column(
        children: [
          BreadcrumbWidget(isCompatibleManage: true),
          Expanded(
            child: Obx(() {
              controller.formRefreshSignal.value;
              final CourseUnitWritingExemplarEditorPageEntity? editorData = controller.editorData.value;
              if (controller.isLoading.value && editorData == null) {
                return const SizedBox.shrink();
              }
              if (editorData == null || editorData.data == null) {
                return const NotDataWidget(message: '暂无范文配置');
              }
              final ZhenxieTaskDetailsEntity detail = editorData.data!;
              final bool isTextAnswer = controller.isTextAnswer;
              final List<String> issues = isTextAnswer ? <String>[] : controller.collectIssues();
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  90.wMin,
                  24.wMin,
                  90.wMin,
                  24.wMin + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          _buildTaskCardWidget(detail),
                          SizedBox(height: 24.wMin),
                          if (isTextAnswer)
                            _buildTextBranchWidget(detail)
                          else ...[
                            _buildTitlePanelWidget(),
                            SizedBox(height: 24.wMin),
                            _buildMediaPanelWidget(context, detail),
                          ],
                          if (issues.isNotEmpty) SizedBox(height: 24.wMin),
                          if (issues.isNotEmpty) _buildIssuesWidget(issues),
                        ],
                      ),
                    ),
                    _buildBottomActionsWidget(issues),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 顶部任务卡片。
  Widget _buildTaskCardWidget(ZhenxieTaskDetailsEntity detail) {
    final String blueprintTitle = controller.getLangText(detail.blueprint?.name, 'zh');
    final String answerTypeText = controller.getAnswerTypeText(detail.stage?.answerKind);
    final String answerTagText = answerTypeText.isEmpty
        ? ''
        : ((detail.stage?.answerKind ?? '') == 'text' ? answerTypeText : '$answerTypeText x ${controller.getAnswerCount(detail)}');
    final CompositionStageModel? stage = detail.stage == null ? null : CompositionStageModel.fromJson(detail.stage!.toJson());
    return _buildPanelShell(
        child: Column(
      children: [
        Row(
          children: [
            Text(controller.getLangText(detail.name, 'zh'),
                style: TextStyle(
                  color: AppTheme.cZhenxieFontPrimary,
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFontValue.sourceHanSerifCN,
                )),
                SizedBox(width: 12.wMin),
            CopyTagWidget(
              name: '任务',
              value: detail.taskId?.toString() ?? '',
              isShow: true,
            ),
            SizedBox(width: 12.wMin),
            WordInflectionInfoTagWidget(blueprintTitle),
            SizedBox(width: 12.wMin),
            WordInflectionInfoTagWidget(answerTagText),
      
          ],
        ),
        Row(
          children: [
            Text(
              controller.getLangText(detail.stem, 'zh'),
              style: TextStyle(
                color: AppTheme.cZhenxieFontSecondary,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        stage == null
            ? const SizedBox.shrink()
            : ZhenxieCompositionSlotStripWidget(
                stage: stage,
                beatMap: zhenxieBeatMap,
                beatOrderList: zhenxieBeatOrderList.isNotEmpty
                    ? zhenxieBeatOrderList
                    : stage.slots.map((item) => item.beatNid ?? '').where((item) => item.isNotEmpty).toList(),
                langTextGetter: controller.getLangText,
                beatNameGetter: getZhenxieBeatName,
                headLabelGetter: controller.getHeadLabel,
                tailLabelGetter: controller.getTailLabel,
                hasHeadGetter: controller.hasHead,
                hasTailGetter: controller.hasTail,
              ),
        if (controller.role == 'given') SizedBox(height: 16.wMin),
        if (controller.role == 'given') _buildGivenRoleHintWidget(),
      ],
    ));

  }

  Widget _buildGivenRoleHintWidget() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 12.wMin),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.cBorderThin.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cZhenxieFontSecondary,
            height: 1.6,
          ),
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                margin: EdgeInsets.only(right: 8.wMin),
                padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
                decoration: BoxDecoration(
                  color: AppTheme.cZhenxieBackgroundPrimary.color,
                  borderRadius: BorderRadius.circular(999.wMin),
                  border: Border.all(
                    color: AppTheme.cZhenxieBorderPrimary.color,
                    width: 1.wMin,
                  ),
                ),
                child: Text(
                  '给拍范文',
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cZhenxieColorPrimary,
                    height: 1.0,
                  ),
                ),
              ),
            ),
            const TextSpan(text: '只用来给学生看的给定段，章法课仍用主范文。'),
          ],
        ),
      ),
    );
  }

  /// 标题输入区。
  Widget _buildTitlePanelWidget() {
    return _buildPanelShell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
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
                  title: '范文标题',
                  hintText: '请输入中文标题',
                  controller: controller.titleZhController,
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
                    controller.titleZhController.clear();
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: 24.wMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'English（可选）',
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cZhenxieFontSecondary,
                  ),
                ),
                SizedBox(height: 16.wMin),
                CardInputWidget(
                  title: 'Exemplar Title',
                  hintText: 'Enter English title',
                  controller: controller.titleEnController,
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
                    controller.titleEnController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 多媒体素材区。
  Widget _buildMediaPanelWidget(BuildContext context, ZhenxieTaskDetailsEntity detail) {
    final String answerKind = detail.stage?.answerKind ?? '';
    return _buildPanelShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '范文素材',
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cZhenxieFontPrimary,
                ),
              ),
              SizedBox(width: 12.wMin),
              Text(
                '当前题型是${controller.getAnswerTypeText(answerKind)}，按 ${controller.getAnswerCount(detail)} 份保存',
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.wMin),
          Wrap(
            spacing: 16.wMin,
            runSpacing: 16.wMin,
            children: List<Widget>.generate(controller.answerKeys.length, (index) {
              return _buildMediaCardWidget(
                context,
                index: index,
                answerKind: answerKind,
                mediaKey: controller.answerKeys[index],
                mediaUrl: index < controller.answerUrls.length ? controller.answerUrls[index] : '',
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaCardWidget(
    BuildContext context, {
    required int index,
    required String answerKind,
    required String mediaKey,
    required String mediaUrl,
  }) {
    final String answerTypeText = controller.getAnswerTypeText(answerKind);
    final String uidText = mediaKey.trim().isNotEmpty && mediaUrl.trim().isEmpty ? mediaKey : '';
    Widget? preview;
    if (uidText.isEmpty && mediaKey.trim().isNotEmpty && mediaUrl.trim().isNotEmpty) {
      if (answerKind == 'image') {
        preview = ClipRRect(
          borderRadius: BorderRadius.circular(24.wMin),
          child: CachedImageWidget(
            mediaUrl,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorWidget: _buildMediaPreviewFallback(answerTypeText),
            placeholder: _buildMediaPreviewFallback(answerTypeText),
          ),
        );
      } else if (answerKind == 'audio') {
        preview = Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 20.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cZhenxieBackgroundPrimary,
            borderRadius: BorderRadius.circular(24.wMin),
          ),
          child: Center(
            child: AudioPlayUiWidget(
              audioUrl: mediaUrl,
              showDownload: false,
            ),
          ),
        );
      } else if (answerKind == 'video') {
        preview = PlayVideoWidget(
          videoUrl: mediaUrl,
          isManagement: true,
        );
      }
    }
    return _buildMediaActionCard(
      title: '$answerTypeText${index + 1}',
      uidText: uidText,
      preview: preview,
      onInputTap: () async {
        if (answerKind == 'image') {
          await _showImageMediaDialog(
            context: context,
            index: index,
            initialMode: _ImageMediaDialogMode.uid,
          );
          return;
        }
        final String? value = await InputDialog.show(
          context: context,
          title: '输入${answerTypeText}UID',
          hintText: '请输入$answerTypeText素材标识',
        );
        if ((value ?? '').trim().isEmpty) return;
        await controller.setAnswerByInput(index, value!);
      },
      onUploadTap: () async {
        if (answerKind == 'image') {
          await _showImageMediaDialog(
            context: context,
            index: index,
            initialMode: _ImageMediaDialogMode.upload,
          );
          return;
        }
        await controller.uploadAnswer(context, index);
      },
      uploadText: '上传$answerTypeText',
    );
  }

  Widget _buildMediaPreviewFallback(String answerTypeText) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentBase.color,
        borderRadius: BorderRadius.circular(24.wMin),
      ),
      alignment: Alignment.center,
      child: Text(
        '$answerTypeText 预览加载失败',
        style: TextStyle(
          fontSize: 18.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cZhenxieFontSecondary,
        ),
      ),
    );
  }

  /// 文字题的页内分支。
  Widget _buildTextBranchWidget(ZhenxieTaskDetailsEntity detail) {
    if (controller.exemplarCompositionId != null) {
      return _buildTextStructureEditorWidget(detail);
    }
    if (controller.textStep.value == 'ai') {
      return Column(
        children: [
          _buildKnowledgeSectionWidget(detail),
          SizedBox(height: 24.wMin),
          _buildGrammarSectionWidget(detail),
          if (controller.exemplarCompositionId != null) SizedBox(height: 24.wMin),
          if (controller.exemplarCompositionId != null) _buildExemplarOverwriteHintWidget(),
        ],
      );
    }
    if (controller.textStep.value == 'reverse') {
      return Column(
        children: [
          _buildReverseTextSectionWidget(detail),
          if (controller.exemplarCompositionId != null) SizedBox(height: 24.wMin),
          if (controller.exemplarCompositionId != null) _buildExemplarOverwriteHintWidget(),
        ],
      );
    }
    return _buildTextChooseWidget();
  }

  Widget _buildTextStructureEditorWidget(ZhenxieTaskDetailsEntity detail) {
    final CompositionStageModel? stage = detail.stage == null ? null : CompositionStageModel.fromJson(detail.stage!.toJson());
    final List<ZhenxieTaskDetailsEntityParagraphInstance> memberList = controller.getParagraphInstanceList(detail);
    final bool hasHead = stage != null && controller.hasHead(stage);
    final bool hasTail = stage != null && controller.hasTail(stage);
    return Column(
      children: [
        _buildTitlePanelWidget(),
        if (hasHead) SizedBox(height: 24.wMin),
        if (hasHead)
          _buildTextEdgePanelWidget(
            title: '文首',
            slotName: controller.getHeadLabel(stage),
            fillLabel: _getFillLabel(stage.headFill),
            textController: controller.headTextController,
            hintText: '请输入文首内容',
          ),
        if (memberList.isNotEmpty) SizedBox(height: 24.wMin),
        if (memberList.isNotEmpty) _buildTextParagraphPanelWidget(memberList),
        if (hasTail) SizedBox(height: 24.wMin),
        if (hasTail)
          _buildTextEdgePanelWidget(
            title: '文尾',
            slotName: controller.getTailLabel(stage),
            fillLabel: _getFillLabel(stage.tailFill),
            textController: controller.tailTextController,
            hintText: '请输入文尾内容',
          ),
      ],
    );
  }

  Widget _buildTextEdgePanelWidget({
    required String title,
    required String slotName,
    required String fillLabel,
    required TextEditingController textController,
    required String hintText,
  }) {
    return _buildPanelShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cZhenxieFontPrimary,
                ),
              ),
              if (slotName.isNotEmpty) SizedBox(width: 12.wMin),
              if (slotName.isNotEmpty)
                Text(
                  slotName,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontSecondary,
                  ),
                ),
              if (fillLabel.isNotEmpty) SizedBox(width: 12.wMin),
              if (fillLabel.isNotEmpty)
                Text(
                  fillLabel,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontSecondary,
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.wMin),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 14.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cZhenxieBackgroundPrimary,
              borderRadius: BorderRadius.circular(18.wMin),
              border: Border.all(
                color: AppTheme.cBorderThin.color,
                width: 1.wMin,
              ),
            ),
            child: TextField(
              controller: textController,
              minLines: 2,
              maxLines: null,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontPrimary,
                height: 1.7,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextParagraphPanelWidget(List<ZhenxieTaskDetailsEntityParagraphInstance> memberList) {
    return _buildPanelShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '范文结构',
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cZhenxieFontPrimary,
            ),
          ),
          SizedBox(height: 6.wMin),
          Text(
            '${memberList.length} 段',
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontSecondary,
            ),
          ),
          SizedBox(height: 20.wMin),
          ...List<Widget>.generate(memberList.length, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: index == memberList.length - 1 ? 0 : 16.wMin),
              child: _buildTextParagraphCardWidget(
                index: index,
                member: memberList[index],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTextParagraphCardWidget({
    required int index,
    required ZhenxieTaskDetailsEntityParagraphInstance member,
  }) {
    final TextEditingController textController = index < controller.paragraphContentControllers.length
        ? controller.paragraphContentControllers[index]
        : TextEditingController(text: member.paragraph?.content ?? '');
    final String beatLabel = getZhenxieBeatName(member.beatNid);
    final String paragraphTypeLabel = controller.getLangText(member.paragraphType?.name, 'zh');
    final String usageName = controller.getLangText(member.usageName, 'zh');
    final bool changed = controller.isParagraphChanged(index);
    final List<ZhenxieTaskDetailsEntityParagraphBeatSpan> beatSpanList = controller.getParagraphBeatSpanList(index);
    final List<String> sentenceList = changed ? controller.getParagraphSentenceList(index) : <String>[];
    final String beatSeal = _getBeatSeal(member.beatNid, beatLabel);
    final int sentenceCount = changed ? sentenceList.length : _getSentenceCount(textController.text, beatSpanList);
    final String titleText = usageName.isNotEmpty ? '第 ${index + 1} 段 · $beatSeal · $usageName' : '第 ${index + 1} 段 · $beatSeal';
    final String subtitleText = paragraphTypeLabel.isNotEmpty ? '$paragraphTypeLabel·要写' : '要写';
    final Color beatColor = _getBeatColor(member.beatNid);
    final Color beatTextColor = _getBeatTextColor(member.beatNid);
    return Container(
      padding: EdgeInsets.fromLTRB(16.wMin, 16.wMin, 16.wMin, 15.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentBase.color,
        borderRadius: BorderRadius.circular(16.wMin),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.cBorderThin.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48.wMin,
                    height: 48.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: beatColor,
                      borderRadius: BorderRadius.circular(9999.wMin),
                      border: Border.all(
                        color: beatColor,
                        width: 2.wMin,
                      ),
                    ),
                    child: Text(
                      beatSeal,
                      style: TextStyle(
                        fontSize: 20.wMin,
                        fontWeight: FontWeight.w500,
                        color: beatTextColor,
                        height: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.wMin),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleText,
                        style: TextStyle(
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cZhenxieFontPrimary,
                          fontFamily: AppFontValue.sourceHanSerifCN,
                        ),
                      ),
                      SizedBox(height: 2.wMin),
                      Text(
                        subtitleText,
                        style: TextStyle(
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cZhenxieFontSecondary,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '$sentenceCount 句',
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontSecondary,
                  height: 1.0,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.wMin),
          Container(
            width: double.infinity,
            height: 161.wMin,
            padding: EdgeInsets.all(8.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceTranslucentBase.color,
              borderRadius: BorderRadius.circular(6.wMin),
              border: Border.all(
                color: AppTheme.cBorderThin.color,
                width: 1.wMin,
              ),
            ),
            child: TextField(
              controller: textController,
              minLines: null,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontPrimary,
                height: 1.6,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: '请输入这一段的英文正文',
                hintStyle: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontSecondary,
                  height: 1.6,
                ),
              ),
            ),
          ),
          if (changed) SizedBox(height: 8.wMin),
          if (changed)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8.wMin,
                  runSpacing: 8.wMin,
                  children: sentenceList.map((item) {
                    return Container(
                      constraints: BoxConstraints(maxWidth: 520.wMin),
                      padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 8.wMin),
                      decoration: BoxDecoration(
                        color: AppTheme.cSurfaceTranslucentBase.color,
                        borderRadius: BorderRadius.circular(12.wMin),
                        border: Border.all(
                          color: AppTheme.cBorderThin.color,
                          width: 1.wMin,
                        ),
                      ),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cZhenxieFontSecondary,
                          height: 1.4,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 8.wMin),
                Text(
                  '正文改过：保存后由模型重新标起承转合，知识点落点也跟着重算。',
                  style: TextStyle(
                    fontSize: 14.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          if (!changed && beatSpanList.isNotEmpty) SizedBox(height: 8.wMin),
          if (!changed && beatSpanList.isNotEmpty)
            Wrap(
              spacing: 8.wMin,
              runSpacing: 8.wMin,
              children: beatSpanList.map((item) {
                final String itemBeatSeal = _getBeatSeal(item.beatNid, getZhenxieBeatName(item.beatNid));
                final Color itemBeatColor = _getBeatColor(item.beatNid);
                final Color itemBeatTextColor = _getBeatTextColor(item.beatNid);
                final int spanIndex = beatSpanList.indexOf(item);
                return TapScaleWidget(
                  sclae: 1,
                  onTap: () {
                    controller.cycleParagraphBeat(index, spanIndex, member.paragraphTypeNid);
                  },
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 520.wMin),
                    padding: EdgeInsets.symmetric(horizontal: 11.wMin, vertical: 7.wMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.wMin),
                      border: Border.all(
                        color: itemBeatColor.withValues(alpha: 0.2),
                        width: 2.wMin,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          itemBeatColor.withValues(alpha: 0.3),
                          itemBeatColor.withValues(alpha: 0.12),
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          itemBeatSeal,
                          style: TextStyle(
                            fontSize: 20.wMin,
                            fontWeight: FontWeight.w500,
                            color: itemBeatTextColor,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(width: 6.wMin),
                        Flexible(
                          child: Text(
                            item.text ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18.wMin,
                              fontWeight: FontWeight.w400,
                              color: itemBeatTextColor,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  String _getBeatSeal(String? beatNid, String beatLabel) {
    if (beatNid == 'opening') return '起';
    if (beatNid == 'develop') return '承';
    if (beatNid == 'turn') return '转';
    if (beatNid == 'close') return '合';
    if (beatNid == 'head') return '首';
    if (beatNid == 'tail') return '尾';
    if (beatLabel.isNotEmpty) return beatLabel.substring(0, 1);
    return '';
  }

  int _getSentenceCount(
    String text,
    List<ZhenxieTaskDetailsEntityParagraphBeatSpan> beatSpanList,
  ) {
    if (beatSpanList.isNotEmpty) return beatSpanList.length;
    return controller.splitParagraphSentences(text).length;
  }

  Color _getBeatColor(String? beatNid) {
    final ParagraphRhetoricalEntityList? beat = zhenxieBeatMap[beatNid];
    return beat?.currentThemeColor?.colorValue ?? beat?.colorValue ?? AppTheme.cBorderThin.color;
  }

  Color _getBeatTextColor(String? beatNid) {
    final ParagraphRhetoricalEntityList? beat = zhenxieBeatMap[beatNid];
    return beat?.currentThemeColor?.textColorValue ?? AppTheme.cTextInverse.color;
  }

  String _getFillLabel(String? fill) {
    if (fill == 'given') return '给定';
    if (fill == 'write') return '要写';
    if (fill == 'hidden') return '不出现';
    return '';
  }

  Widget _buildTextChooseWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildTextChoiceCardWidget(
            icon: Icons.auto_awesome_outlined,
            title: 'AI 写',
            lines: const [
              '按题干、阶梯的段落和起承转合、时体语态窗口发起一篇范文。',
              '下一步还可以改这次给模型看的单词、短语和语法点，不写回任务。',
            ],
            isDisabled: controller.isSaving.value,
            onTap: () {
              controller.enterTextStep('ai');
            },
          ),
        ),
        SizedBox(width: 20.wMin),
        Expanded(
          child: _buildTextChoiceCardWidget(
            icon: Icons.content_paste_rounded,
            title: '反向处理',
            lines: const [
              '贴一篇现成的英文，系统只把句子分到文首、各段、文尾和起承转合。',
              '原文一个字都不改；对不上阶梯的地方会在后端异步任务里处理。',
            ],
            isDisabled: controller.isSaving.value,
            onTap: () {
              controller.enterTextStep('reverse');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKnowledgeSectionWidget(ZhenxieTaskDetailsEntity detail) {
    final List<CourseUnitWritingEditorKnowledgeItemEntity> knowledgeList = controller.getLexicalKnowledgeList();
    final bool taskHadKnowledge = (detail.knowledgePoints ?? const <ZhenxieTaskDetailsEntityKnowledgePoint?>[]).isNotEmpty;
    return _buildPanelShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '单词和短语',
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cZhenxieFontPrimary,
                ),
              ),
              SizedBox(width: 12.wMin),
              Expanded(
                child: Text(
                  taskHadKnowledge ? '任务勾过的先带来。这一页可以再改，不写回任务。' : '任务没勾，先按本单元全部带来。这一页可以再改，不写回任务。',
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.wMin),
          Row(
            children: [
              Text(
                '${controller.selectedKnowledgeUids.length}/${knowledgeList.length}',
                style: TextStyle(
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontSecondary,
                ),
              ),
              const Spacer(),
              _buildSectionTextButton(
                text: '全选',
                onTap: controller.selectAllKnowledge,
              ),
              SizedBox(width: 12.wMin),
              _buildSectionTextButton(
                text: '清空',
                onTap: controller.clearKnowledge,
              ),
            ],
          ),
          SizedBox(height: 16.wMin),
          Wrap(
            spacing: 8.wMin,
            runSpacing: 8.wMin,
            children: knowledgeList.map((item) {
              final int uid = item.uid ?? 0;
              final bool isSelected = controller.selectedKnowledgeUids.contains(uid);
              final String text = (item.definition ?? '').isNotEmpty ? '${item.content ?? ''} ${item.definition ?? ''}' : (item.content ?? '');
              return GestureDetector(
                onTap: () {
                  controller.toggleKnowledgeSelection(uid);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 8.wMin),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.cZhenxieFontPrimary : AppTheme.cSurfaceTranslucentBase.color,
                    borderRadius: BorderRadius.circular(999.wMin),
                    border: isSelected
                        ? Border.all(
                            color: Colors.transparent,
                            width: 1.wMin,
                          )
                        : Border.all(
                            color: AppTheme.cBorderThin.color,
                            width: 1.wMin,
                          ),
                  ),
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      color: isSelected ? AppTheme.cBgPrimary.color : AppTheme.cZhenxieFontSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGrammarSectionWidget(ZhenxieTaskDetailsEntity detail) {
    final List<CourseUnitWritingGrammarTargetItemEntity> grammarList =
        controller.editorData.value?.grammarTargetList ?? const <CourseUnitWritingGrammarTargetItemEntity>[];
    final bool taskHadGrammar = (detail.grammarTargetUids ?? const <int>[]).isNotEmpty;
    return _buildPanelShell(
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
              SizedBox(width: 12.wMin),
              Expanded(
                child: Text(
                  taskHadGrammar ? '任务勾过的先带来。这一页可以再改，不写回任务。' : '任务没勾，先按已审的全部带来。这一页可以再改，不写回任务。',
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.wMin),
          if (grammarList.isNotEmpty)
            Row(
              children: [
                Text(
                  '${controller.selectedGrammarTargetUids.length}/${grammarList.length}',
                  style: TextStyle(
                    fontSize: 14.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontSecondary,
                  ),
                ),
                const Spacer(),
                _buildSectionTextButton(
                  text: '全选',
                  onTap: controller.selectAllGrammar,
                ),
                SizedBox(width: 12.wMin),
                _buildSectionTextButton(
                  text: '清空',
                  onTap: controller.clearGrammar,
                ),
              ],
            ),
          if (grammarList.isNotEmpty) SizedBox(height: 16.wMin),
          if (grammarList.isEmpty)
            Text(
              '本单元还没有审过的语法点，模型只按时体语态窗口写。',
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontSecondary,
              ),
            ),
          if (grammarList.isNotEmpty)
            Column(
              children: grammarList.map((item) {
                final int uid = item.uid ?? 0;
                final bool isSelected = controller.selectedGrammarTargetUids.contains(uid);
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.wMin),
                  child: TapScaleWidget(
                    sclae: 1,
                    onTap: () {
                      controller.toggleGrammarSelection(uid);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 14.wMin),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.cSurfaceTertiary.color : AppTheme.cSurfaceTranslucentBase.color,
                        borderRadius: BorderRadius.circular(18.wMin),
                        border: Border.all(
                          color: isSelected ? AppTheme.cBorderPrimary.color : AppTheme.cBorderThin.color,
                          width: 1.wMin,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              controller.getLangText(item.title, 'zh').isNotEmpty
                                  ? controller.getLangText(item.title, 'zh')
                                  : '语法点 ${item.uid ?? ''}',
                              style: TextStyle(
                                fontSize: 18.wMin,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? AppTheme.cTextPrimary.color : AppTheme.cZhenxieFontSecondary,
                              ),
                            ),
                          ),
                          if ((item.kindTitle ?? '').isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 5.wMin),
                              decoration: BoxDecoration(
                                color: AppTheme.cSurfaceTranslucentBase.color,
                                borderRadius: BorderRadius.circular(999.wMin),
                                border: Border.all(
                                  color: AppTheme.cBorderThin.color,
                                  width: 1.wMin,
                                ),
                              ),
                              child: Text(
                                item.kindTitle ?? '',
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
                  ),
                );
              }).toList(),
            ),
          SizedBox(height: 8.wMin),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 14.wMin),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppTheme.cBorderThin.color,
                  width: 1.wMin,
                ),
              ),
            ),
            child: Text(
              '时体语态窗口：${controller.getGrammarScopeText()}（在单元挂载里改）',
              style: TextStyle(
                fontSize: 15.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReverseTextSectionWidget(ZhenxieTaskDetailsEntity detail) {
    final int sentenceCount = controller.getReverseSentenceCount();
    final int blockCount = controller.getReverseBlockCount();
    final int maxChars = 20000;
    final int currentLength = controller.reverseTextController.text.length;
    final bool tooLong = currentLength > maxChars;
    final int slotCount = detail.stage?.slots?.length ?? 0;
    return _buildPanelShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '原文',
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cZhenxieFontPrimary,
                ),
              ),
              SizedBox(width: 12.wMin),
              Expanded(
                child: Text(
                  blockCount > 1
                      ? '阶梯要 $slotCount 段 · 现在 $sentenceCount 句 · $blockCount 块（空行分开）'
                      : '阶梯要 $slotCount 段 · 现在 $sentenceCount 句',
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontSecondary,
                  ),
                ),
              ),
              Text(
                '$currentLength/$maxChars',
                style: TextStyle(
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                  color: tooLong ? AppTheme.cSurfaceError.color : AppTheme.cZhenxieFontSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.wMin),
          Container(
            height: 360.wMin,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 14.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceTranslucentBase.color,
              borderRadius: BorderRadius.circular(18.wMin),
              border: Border.all(
                color: AppTheme.cBorderThin.color,
                width: 1.wMin,
              ),
            ),
            child: TextField(
              controller: controller.reverseTextController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontPrimary,
                height: 1.7,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: '把英文原文贴在这里。空行当作分段线索；阶梯要文首文尾的话，称呼、日期留在最前，落款留在最后。',
                hintStyle: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExemplarOverwriteHintWidget() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16.wMin),
        border: Border.all(
          color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.3),
          width: 1.wMin,
        ),
      ),
      child: Text(
        '这个任务已经有范文 ${controller.exemplarCompositionId}。新的结果跑完会原地覆盖当前范文。',
        style: TextStyle(
          fontSize: 17.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cSurfaceWarning.color,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildSectionTextButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cZhenxieFontSecondary,
        ),
      ),
    );
  }

  Widget _buildTextChoiceCardWidget({
    required IconData icon,
    required String title,
    required List<String> lines,
    required bool isDisabled,
    required VoidCallback onTap,
  }) {
    return TapScaleWidget(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.45 : 1,
        child: Container(
          padding: EdgeInsets.all(24.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceTranslucentBase.color,
            borderRadius: BorderRadius.circular(24.wMin),
            border: Border.all(
              color: AppTheme.cBorderThin.color,
              width: 1.wMin,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
    
              Text(
                title,
                style: TextStyle(
                  fontSize: 40.wMin,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.cZhenxieFontPrimary,
                  fontFamily: AppFontValue.sourceHanSerifCN,
                ),
              ),
              SizedBox(height: 12.wMin),
              ...List<Widget>.generate(lines.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: index == lines.length - 1 ? 0 : 8.wMin),
                  child: Text(
                    lines[index],
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextSecondary,
                      height: 1.7,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIssuesWidget(List<String> issues) {
    return _buildPanelShell(
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
    );
  }

  Widget _buildBottomActionsWidget(List<String> issues) {
    final bool isTextAnswer = controller.isTextAnswer;
    final bool isEditingTextExemplar = isTextAnswer && controller.exemplarCompositionId != null;
      final bool canSubmit = issues.isEmpty && !controller.isSaving.value;
    final bool isAiStep = controller.textStep.value == 'ai';
    final bool isReverseStep = controller.textStep.value == 'reverse';
    final bool canGenerateReverse =
        !controller.isSaving.value && controller.getReverseSentenceCount() > 0 && controller.reverseTextController.text.length <= 20000;
      final String helperText = isEditingTextExemplar
          ? (issues.isNotEmpty ? issues.first : '保存后会直接更新当前已挂的文字范文。')
        : isTextAnswer
        ? (isAiStep ? '先按任务带上。这里改了只给这一次范文，不写回任务。' : (isReverseStep ? '原文一个字都不改；对不上阶梯的地方会交给后端处理。' : '先选择 AI 写还是反向处理。'))
        : (issues.isNotEmpty ? issues.first : '保存后会回到单元写作任务页');
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
          Expanded(
            child: Text(
              helperText,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: !isTextAnswer && issues.isNotEmpty ? AppTheme.cSurfaceError.color : AppTheme.cZhenxieFontSecondary,
              ),
            ),
          ),
          SizedBox(width: 16.wMin),
          if (isTextAnswer && !isEditingTextExemplar && controller.textStep.value != 'choose')
            ManageButton(
              width: 156.wMin,
              height: 64.wMin,
              radius: 99.wMin,
              text: '返回选择',
              color: AppTheme.cBorderDefault.color,
              borderColor: AppTheme.cBorderThin.color,
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
                height: 1.0,
              ),
              onTap: () {
                controller.enterTextStep('choose');
              },
            ),
          if (isTextAnswer && !isEditingTextExemplar && controller.textStep.value != 'choose') SizedBox(width: 8.wMin),
          ManageButton(
            width: 132.wMin,
            height: 64.wMin,
            radius: 99.wMin,
            text: '取消',
            color: AppTheme.cBorderDefault.color,
            borderColor: AppTheme.cBorderThin.color,
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary.color,
              height: 1.0,
            ),
            onTap: () {
              Get.back();
            },
          ),
          if (!isTextAnswer || isEditingTextExemplar) SizedBox(width: 8.wMin),
          if (!isTextAnswer || isEditingTextExemplar)
            ManageButton(
              width: 176.wMin,
              height: 64.wMin,
              radius: 99.wMin,
              text: controller.isSaving.value ? '保存中' : '保存范文',
              color: AppTheme.cBorderDefault.color,
              borderColor: AppTheme.cBorderThin.color,
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
                height: 1.0,
              ),
                onTap: canSubmit ? controller.submitExemplar : null,
            ),
          if (isTextAnswer && !isEditingTextExemplar && isAiStep) SizedBox(width: 8.wMin),
          if (isTextAnswer && !isEditingTextExemplar && isAiStep)
            ManageButton(
              width: 176.wMin,
              height: 64.wMin,
              radius: 99.wMin,
              text: controller.isSaving.value ? '生成中' : '生成范文',
              color: AppTheme.cBorderDefault.color,
              borderColor: AppTheme.cBorderThin.color,
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
                height: 1.0,
              ),
              onTap: controller.isSaving.value ? null : controller.generateTextExemplar,
            ),
          if (isTextAnswer && !isEditingTextExemplar && isReverseStep) SizedBox(width: 8.wMin),
          if (isTextAnswer && !isEditingTextExemplar && isReverseStep)
            ManageButton(
              width: 176.wMin,
              height: 64.wMin,
              radius: 99.wMin,
              text: controller.isSaving.value ? '处理中' : '生成范文',
              color: AppTheme.cBorderDefault.color,
              borderColor: AppTheme.cBorderThin.color,
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
                height: 1.0,
              ),
              onTap: canGenerateReverse ? () => controller.structureTextExemplar(controller.reverseTextController.text) : null,
            ),
        ],
      ),
    );
  }

  Widget _buildMediaActionButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return ButtonWidget(
      height: 52.wMin,
      borderRadius: 999.wMin,
      color: AppTheme.cZhenxieBackgroundPrimary,
      border: Border.all(
        color: AppTheme.cZhenxieBorderPrimary,
        width: 1.wMin,
      ),
      fontSize: 18.wMin,
      fontWeight: FontWeight.w500,
      fontColor: AppTheme.cZhenxieFontPrimary,
      text: text,
      onTap: onTap,
      sclae: 1.02,
    );
  }

  Widget _buildMediaActionCard({
    required String title,
    String uidText = '',
    Widget? preview,
    required VoidCallback onInputTap,
    required VoidCallback onUploadTap,
    required String uploadText,
  }) {
    final bool hasUid = uidText.isNotEmpty;
    final bool hasPreview = !hasUid && preview != null;
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
                  child: Container(
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
                ),
                Positioned(
                  right: 12.wMin,
                  bottom: 12.wMin,
                  child: _buildMediaFloatingReplaceButton(
                    onTap: onUploadTap,
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
                          onTap: onInputTap,
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
    _ImageMediaDialogMode currentMode = initialMode;
    final TextEditingController uidController = TextEditingController();
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
                    color: Colors.white.withValues(alpha: 0.12),
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
                          _buildImageDialogTabButton(
                            text: '输入图片 UID',
                            selected: currentMode == _ImageMediaDialogMode.uid,
                            onTap: () {
                              setState(() {
                                currentMode = _ImageMediaDialogMode.uid;
                              });
                            },
                          ),
                          SizedBox(width: 6.wMin),
                          _buildImageDialogTabButton(
                            text: '上传图片',
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
                          ? _buildImageUidDialogContent(
                              uidController: uidController,
                              onConfirm: () async {
                                final String uidText = uidController.text.trim();
                                if (uidText.isEmpty) return;
                                final bool success = await controller.setAnswerByInput(index, uidText);
                                if (success && dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                }
                              },
                            )
                          : _buildImageUploadDialogContent(
                              onUploadTap: () async {
                                final String beforeValue = controller.answerKeys.length > index ? controller.answerKeys[index] : '';
                                await controller.uploadAnswer(dialogContext, index);
                                final String afterValue = controller.answerKeys.length > index ? controller.answerKeys[index] : '';
                                if (afterValue.isNotEmpty && afterValue != beforeValue) {
                                  if (dialogContext.mounted) {
                                    Navigator.of(dialogContext).pop();
                                  }
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

  Widget _buildImageDialogTabButton({
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

  Widget _buildImageUidDialogContent({
    required TextEditingController uidController,
    required VoidCallback onConfirm,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '图片 UID',
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
            hintText: '图片库里的 UID，如 12345',
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

  Widget _buildImageUploadDialogContent({
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
                  '点击上传图片',
                  style: TextStyle(
                    fontSize: 13.5.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontSecondary.withValues(alpha: 0.75),
                  ),
                ),
                SizedBox(height: 4.wMin),
                Text(
                  '支持 PNG / JPG / WebP',
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
}
