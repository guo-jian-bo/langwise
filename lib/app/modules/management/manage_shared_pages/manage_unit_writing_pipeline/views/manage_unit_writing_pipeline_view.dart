import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_data.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../routes/routes.dart';
import '../bindings/manage_unit_writing_pipeline_binding.dart';
import '../controllers/manage_unit_writing_pipeline_controller.dart';
import '../../../common/commons.dart';

class ManageUnitWritingPipelineView extends GetView<ManageUnitWritingPipelineController> {
  static const double _cardHeight = 540;

  final String tagText;
  const ManageUnitWritingPipelineView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ManageUnitWritingPipelineView(tagText: tag),
      binding: ManageUnitWritingPipelineBinding(tagText: tag),
      routeName: Routes.MANAGE_UNIT_WRITING_PIPELINE,
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
          BreadcrumbWidget(
            isCompatibleManage: true,
          ),
          Expanded(
            child: Obx(() {
              final CourseUnitWritingDetailEntity? detail = controller.detailData.value;
              if (controller.isLoading.value && detail == null) {
                return const SizedBox.shrink();
              }
              if (detail == null) {
                return const NotDataWidget(message: '暂无写作管线数据');
              }
              final String sourceText = _buildSourceText(detail);
              return Padding(
                padding: EdgeInsets.fromLTRB(90.wMin, 24.wMin, 90.wMin, 24.wMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderWidget(detail),
                    if (sourceText.isNotEmpty) SizedBox(height: 12.wMin),
                    if (sourceText.isNotEmpty)
                      Text(
                        sourceText,
                        style: TextStyle(
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextTertiary.color,
                        ),
                      ),
                    SizedBox(height: 16.wMin),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: detail.stage == null ? _buildEmptyStageWidget() : _buildStageCardWidget(detail),
                          ),
                          SizedBox(width: 24.wMin),
                          SizedBox(
                            width: 560.wMin,
                            child: _buildGrammarScopePanel(detail),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderWidget(CourseUnitWritingDetailEntity detail) {
    final int taskCount = detail.taskCount ?? 0;
    final int compositionTaskCount = detail.compositionTaskCount ?? 0;
    return Row(
      children: [
        Text(
          '写作管线',
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        SizedBox(width: 8.wMin),
        Text(
          '当前单元挂载阶梯与时体语态',
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        const Spacer(),
        Text(
          '任务 $taskCount · 范文 $compositionTaskCount/$taskCount',
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
      ],
    );
  }

  String _buildSourceText(CourseUnitWritingDetailEntity detail) {
    return <String?>[
      detail.source?.project,
      detail.source?.theme,
      detail.source?.topic,
      detail.source?.subTopic,
    ].whereType<String>().where((item) => item.isNotEmpty).join(' · ');
  }

  Widget _buildStageCardWidget(CourseUnitWritingDetailEntity detail) {
    final StageCardData stage = detail.stage!;
    return ZhenxieWriteCatalogCardWidget(
      stageData: stage,
      height: _cardHeight,
      copyLabel: '阶梯',
      actions: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildStageActionButton(
            '更换',
            onTap: controller.changeStage,
          ),
          SizedBox(width: 10.wMin),
          _buildStageActionButton(
            '蓝图',
            onTap: controller.openBlueprintPage,
          ),
          SizedBox(width: 10.wMin),
          _buildStageActionButton(
            '任务 ${detail.taskCount ?? 0}',
            onTap: controller.openTaskPage,
          ),
        ],
      ),
      showCopyTag: (stage.nid ?? '').isNotEmpty,
    );
  }

  Widget _buildStageActionButton(String text, {VoidCallback? onTap}) {
    return TapScaleWidget(
      sclae: 1.01,
      onTap: onTap,
      child: Container(
        height: 48.wMin,
        padding: EdgeInsets.symmetric(horizontal: 18.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceTranslucentBase.color,
          borderRadius: BorderRadius.circular(9999.wMin),
          border: Border.all(
            color: AppTheme.cBorderTranslucentSubtle.color,
            width: 1.wMin,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStageWidget() {
    return _buildPanelShell(
      child: SizedBox(
        height: _cardHeight.wMin,
        child: Center(
          child: Text(
            '当前单元还没有挂载写作阶梯',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrammarScopePanel(CourseUnitWritingDetailEntity detail) {
    final bool enabled = (detail.stage?.nid ?? '').isNotEmpty;
    return _buildPanelShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '时体语态',
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(height: 12.wMin),
          Text(
            '这一课要写的窗口。空着就是不限，和语法大纲分开。',
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.wMin),
          _buildScopeAxisWidget(
            label: detail.grammarScopeMeta?.time?.name ?? '时',
            options: detail.grammarScopeMeta?.time?.options ?? const <CourseUnitWritingGrammarScopeMetaOptionEntity>[],
            selectedCodes: controller.selectedTimes,
            onTap: controller.toggleTime,
          ),
          SizedBox(height: 24.wMin),
          _buildScopeAxisWidget(
            label: detail.grammarScopeMeta?.aspect?.name ?? '体',
            options: detail.grammarScopeMeta?.aspect?.options ?? const <CourseUnitWritingGrammarScopeMetaOptionEntity>[],
            selectedCodes: controller.selectedAspects,
            onTap: controller.toggleAspect,
          ),
          SizedBox(height: 24.wMin),
          _buildScopeAxisWidget(
            label: detail.grammarScopeMeta?.voice?.name ?? '态',
            options: detail.grammarScopeMeta?.voice?.options ?? const <CourseUnitWritingGrammarScopeMetaOptionEntity>[],
            selectedCodes: controller.selectedVoices,
            onTap: controller.toggleVoice,
          ),
          SizedBox(height: 32.wMin),
          _buildSaveButton(enabled: enabled),
        ],
      ),
    );
  }

  Widget _buildScopeAxisWidget({
    required String label,
    required List<CourseUnitWritingGrammarScopeMetaOptionEntity> options,
    required List<String> selectedCodes,
    required void Function(String code) onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
        SizedBox(height: 10.wMin),
        Wrap(
          spacing: 8.wMin,
          runSpacing: 8.wMin,
          children: options.map((item) {
            final bool isSelected = selectedCodes.contains(item.code ?? '');
            return TapScaleWidget(
              sclae: 1.02,
              onTap: (item.code ?? '').isEmpty
                  ? null
                  : () {
                      onTap(item.code!);
                    },
              child: Container(
                height: 40.wMin,
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.cTextPrimary.color : AppTheme.cSurfaceTranslucentBase.color,
                  borderRadius: BorderRadius.circular(9999.wMin),
                  border: Border.all(
                    color: AppTheme.cBorderThin.color,
                    width: 1.wMin,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.name ?? '',
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? AppTheme.cBgPrimary.color : AppTheme.cTextSecondary.color,
                      ),
                    )
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton({required bool enabled}) {
    final bool canSave = enabled && controller.canSaveGrammarScope() && !controller.isSaving.value;
    return TapScaleWidget(
      sclae: 1.01,
      onTap: canSave ? controller.saveGrammarScope : null,
      child: Container(
        width: double.infinity,
        height: 52.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: canSave ? AppTheme.cTextPrimary.color : AppTheme.cSurfaceTranslucentBase.color,
          borderRadius: BorderRadius.circular(9999.wMin),
          border: Border.all(
            color: AppTheme.cBorderThin.color,
            width: 1.wMin,
          ),
        ),
        child: Text(
          controller.isSaving.value ? '保存中' : '保存时体语态',
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: canSave ? AppTheme.cBgPrimary.color : AppTheme.cTextSecondary.color,
          ),
        ),
      ),
    );
  }

  Widget _buildPanelShell({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentBase.color,
        borderRadius: BorderRadius.circular(16.wMin),
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 1.wMin,
        ),
      ),
      child: child,
    );
  }
}
