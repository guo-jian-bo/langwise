import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../management/common/commons.dart';
import '../bindings/zhenxie_composition_stage_edit_binding.dart';
import '../controllers/zhenxie_composition_stage_edit_controller.dart';
import '../models/zhenxie_composition_stages_models.dart';

class ZhenxieCompositionStageEditView extends GetView<ZhenxieCompositionStageEditController> {
  final String tagText;

  const ZhenxieCompositionStageEditView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> toManage<T>({dynamic arguments}) async {
    final String tag = '${Routes.ZHENXIE_COMPOSITION_STAGE_EDIT}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ZhenxieCompositionStageEditView(tagText: tag),
      binding: ZhenxieCompositionStageEditBinding(tagText: tag),
      routeName: Routes.ZHENXIE_COMPOSITION_STAGE_EDIT,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieCompositionStageEditView(tagText: tag),
      binding: ZhenxieCompositionStageEditBinding(tagText: tag),
      routeName: Routes.ZHENXIE_COMPOSITION_STAGE_EDIT,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      backgroundColor: AppTheme.cBgPrimary,
      onRefresh: controller.initData,
      body: Column(
        children: [
          BreadcrumbWidget(isCompatibleManage: controller.isManagement),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.detailData.value == null) {
                return const Center();
              }
              if (controller.detailData.value == null) {
                return NotDataWidget(message: '未获取到写作阶梯详情');
              }
              return _buildContentWidget();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildContentWidget() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 90.wMin, right: 90.wMin, top: 8.wMin, bottom: 120.wMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 280.wMin,
            child: _buildSidebarWidget(),
          ),
          SizedBox(width: 32.wMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderWidget(),
                SizedBox(height: 20.wMin),
                _buildBasicInfoSection(),
                SizedBox(height: 20.wMin),
                _buildRuleSection(),
                SizedBox(height: 20.wMin),
                _buildAnswerSection(),
                SizedBox(height: 20.wMin),
                _buildSlotSection(),
                SizedBox(height: 20.wMin),
                _buildMilestoneSection(),
                SizedBox(height: 28.wMin),
                _buildFooterWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarWidget() {
    final CompositionStageModel? stage = controller.detailData.value;
    final String blueprintName = controller.getBlueprintName();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 280.wMin,
          height: 280.wMin,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceTranslucentBase.color,
            borderRadius: BorderRadius.circular(24.wMin),
            border: Border.all(
              color: AppTheme.cBorderThin.color,
              width: 1.wMin,
            ),
          ),
          child: CachedImageWidget(
            controller.getCoverUrl(),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorWidget: buildEmptyWidget(fit: BoxFit.cover),
            placeholder: buildEmptyWidget(fit: BoxFit.cover),
          ),
        ),
        SizedBox(height: 14.wMin),
        Text(
          '封面跟着蓝图，这里不能换图。',
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
            height: 1.4,
          ),
        ),
        if (blueprintName.isNotEmpty) ...[
          SizedBox(height: 20.wMin),
          Text(
            blueprintName,
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
        ],
        if ((stage?.compositionBlueprint?.nid ?? '').isNotEmpty) ...[
          SizedBox(height: 10.wMin),
          CopyTagWidget(
            name: '蓝图',
            value: stage?.compositionBlueprint?.nid ?? '',
            isShow: true,
          ),
        ],
      ],
    );
  }

  Widget _buildHeaderWidget() {
    final CompositionStageModel? stage = controller.detailData.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.getStageTitle(),
          style: TextStyle(
            fontSize: 40.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        if ((stage?.nid ?? '').isNotEmpty) ...[
          SizedBox(height: 10.wMin),
          CopyTagWidget(
            name: '阶梯',
            value: stage?.nid ?? '',
            isShow: true,
          ),
        ],
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextInputField(
                title: '中文名',
                controller: controller.nameZhController,
                onChanged: (value) {
                  controller.updateName('zh', value);
                },
              ),
            ),
            SizedBox(width: 16.wMin),
            Expanded(
              child: _buildTextInputField(
                title: '英文名',
                controller: controller.nameEnController,
                onChanged: (value) {
                  controller.updateName('en', value);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 20.wMin),
        _buildTextareaField(
          title: '中文说明',
          controller: controller.descriptionZhController,
          onChanged: (value) {
            controller.updateDescription('zh', value);
          },
        ),
        SizedBox(height: 20.wMin),
        _buildTextareaField(
          title: '英文说明',
          controller: controller.descriptionEnController,
          onChanged: (value) {
            controller.updateDescription('en', value);
          },
        ),
      ],
    );
  }

  Widget _buildRuleSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildTextInputField(
            title: '课序',
            controller: controller.orderController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: controller.updateOrder,
          ),
        ),
        SizedBox(width: 16.wMin),
        Expanded(
          child: _buildSelectField<int>(
            title: '难度下限',
            value: controller.getDifficultyMin(),
            items: controller.difficultyLevelList,
            labelBuilder: controller.getDifficultyLabel,
            onChanged: (value) {
              if (value != null) {
                controller.updateDifficultyMin(value);
              }
            },
          ),
        ),
        SizedBox(width: 16.wMin),
        Expanded(
          child: _buildSelectField<int>(
            title: '难度上限',
            value: controller.getDifficultyMax(),
            items: controller.difficultyLevelList,
            labelBuilder: controller.getDifficultyLabel,
            onChanged: (value) {
              if (value != null) {
                controller.updateDifficultyMax(value);
              }
            },
          ),
        ),
        SizedBox(width: 16.wMin),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCheckTile(
                  title: '完成前锁蓝图',
                  value: controller.detailData.value?.lockBlueprintTab == true,
                  onChanged: controller.updateLockBlueprintTab,
                ),
                _buildCheckTile(
                  title: '完成前锁范文',
                  value: controller.detailData.value?.lockExemplarView == true,
                  onChanged: controller.updateLockExemplarView,
                ),
              ],
            ),
      
        ),
      ],
    );
  }

  Widget _buildAnswerSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildSelectField<String>(
            title: '作答',
            value: controller.getAnswerKind(),
            items: controller.answerKindList,
            labelBuilder: controller.getAnswerKindLabel,
            onChanged: (value) {
              if (value != null) {
                controller.updateAnswerKind(value);
              }
            },
          ),
        ),
        SizedBox(width: 16.wMin),
        Expanded(
          child: _buildTextInputField(
            title: '最少',
            controller: controller.answerMinCountController,
            enabled: controller.getAnswerKind() != 'text',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: controller.updateAnswerMinCount,
          ),
        ),
        SizedBox(width: 16.wMin),
        Expanded(
          child: _buildTextInputField(
            title: '最多',
            controller: controller.answerMaxCountController,
            enabled: controller.getAnswerKind() != 'text',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: controller.updateAnswerMaxCount,
          ),
        ),
      ],
    );
  }

  Widget _buildSlotSection() {
    final List<CompositionStageSlotModel> slots = controller.buildEditableSlots();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('拍'),
        SizedBox(height: 12.wMin),
        if (controller.hasHead()) _buildEdgeFillSection('文首', controller.getHeadFill(), controller.updateHeadFill),
        if (controller.hasHead()) SizedBox(height: 12.wMin),
        ...List.generate(slots.length, (index) {
          final CompositionStageSlotModel slot = slots[index];
          return Padding(
            padding: EdgeInsets.only(bottom: index == slots.length - 1 && !controller.hasTail() ? 0 : 12.wMin),
            child: _buildSlotItem(slot),
          );
        }),
        if (controller.hasTail()) _buildEdgeFillSection('文末', controller.getTailFill(), controller.updateTailFill),
      ],
    );
  }

  Widget _buildEdgeFillSection(
    String title,
    String value,
    void Function(String fill) onChanged,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 14.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentBase.color,
        borderRadius: BorderRadius.circular(20.wMin),
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 1.wMin,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64.wMin,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 22.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
          ),
          SizedBox(width: 12.wMin),
          Expanded(
            child: _buildSelectField<String>(
              title: '',
              value: value,
              items: controller.fillList,
              labelBuilder: controller.getFillLabel,
              onChanged: (next) {
                if (next != null) {
                  onChanged(next);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotItem(CompositionStageSlotModel slot) {
    final List<CompositionBlueprintAllowedParagraphModel> options = controller.buildAllowedParagraphs(slot.beatNid);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 14.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentBase.color,
        borderRadius: BorderRadius.circular(20.wMin),
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 1.wMin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64.wMin,
            child: Padding(
              padding: EdgeInsets.only(top: 14.wMin),
              child: Text(
                controller.getBeatName(slot.beatNid),
                style: TextStyle(
                  fontSize: 22.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.wMin),
          Expanded(
            child: _buildSelectField<String>(
              title: '',
              value: slot.paragraphTypeNid,
              items: options.map((item) => item.paragraphTypeNid ?? '').where((item) => item.isNotEmpty).toList(),
              labelBuilder: (value) {
                return controller.getParagraphTypeLabel(slot.beatNid, value);
              },
              onChanged: (value) {
                controller.updateSlotParagraphType(slot.beatNid ?? '', value);
              },
            ),
          ),
          SizedBox(width: 12.wMin),
          SizedBox(
            width: 150.wMin,
            child: _buildSelectField<String>(
              title: '',
              value: slot.fill,
              items: controller.fillList,
              labelBuilder: controller.getFillLabel,
              onChanged: (value) {
                if (value != null) {
                  controller.updateSlotFill(slot.beatNid ?? '', value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneSection() {
    final List<CompositionStageMilestoneLiteModel> milestones = controller.milestoneOptions.toList();
    final List<String> selectedMilestones = controller.detailData.value?.milestones ?? const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('水平档'),
        SizedBox(height: 12.wMin),
        Wrap(
          spacing: 12.wMin,
          runSpacing: 12.wMin,
          children: milestones.map((item) {
            final String nid = item.nid ?? '';
            final bool selected = selectedMilestones.contains(nid);
            return _buildMilestoneChip(
              text: controller.getMilestoneLabel(item),
              selected: selected,
              onTap: () {
                controller.toggleMilestone(nid);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFooterWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ManageButton(
          text: '取消',
          width: 120.wMin,
          height: 52.wMin,
          color: Colors.transparent,
          borderColor: AppTheme.cBorderTranslucentSubtle.color,
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
          onTap: () {
            Get.back();
          },
        ),
        SizedBox(width: 12.wMin),
        ManageButton(
          text: controller.isSaving.value ? '保存中...' : '保存',
          width: 120.wMin,
          height: 52.wMin,
          color: AppTheme.cSurfaceWarning.color,
          borderColor: AppTheme.cSurfaceWarning.color,
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cBgPrimary.color,
          ),
          onTap: controller.isSaving.value ? null : controller.save,
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16.wMin,
        fontWeight: FontWeight.w400,
        color: AppTheme.cTextSecondary.color,
      ),
    );
  }

  Widget _buildTextInputField({
    required String title,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
    bool enabled = true,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        SizedBox(height: 10.wMin),
        CardInputWidget(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          height: maxLines == 1 ? 56.wMin : (22 * maxLines + 24).wMin,
          fillColor: AppTheme.cSurfaceLayerBase.color,
          borderColor: enabled ? AppTheme.cBorderThin.color : AppTheme.cBorderThin.color.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16.wMin),
          enabledColor: AppTheme.cTextTertiary.color,
          valueStyle: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextPrimary.color,
          ),
          hintStyle: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextareaField({
    required String title,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.wMin),
      borderSide: BorderSide(
        width: 1.wMin,
        color: AppTheme.cBorderThin.color,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        SizedBox(height: 10.wMin),
        TextField(
          controller: controller,
          minLines: 4,
          maxLines: 4,
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextPrimary.color,
            height: 1.4,
          ),
          onChanged: onChanged,
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          decoration: InputDecoration(
            isDense: true,
            counterText: '',
            fillColor: AppTheme.cSurfaceLayerBase.color,
            filled: true,
            border: border,
            focusedBorder: border,
            enabledBorder: border,
            disabledBorder: border,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.wMin,
              vertical: 16.wMin,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectField<T>({
    required String title,
    required T? value,
    required List<T> items,
    required String Function(T value) labelBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    final T? currentValue = items.contains(value) ? value : null;
    final List<IconDropdownCheckData<T>> dropdownItems = items.map((item) {
      return IconDropdownCheckData<T>(
        title: labelBuilder(item),
        value: item,
      );
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
            SizedBox(height: 10.wMin),
        ],
        IconDropdownSelectWidget(
          hintText: '',
          items: dropdownItems,
          selectValue: currentValue,
          selectValues: null,
          multiSelect: false,
          height: 56.wMin,
          itemHeight: 56.wMin,
          itemFontSize: 18.wMin,
          padding: EdgeInsets.symmetric(horizontal: 14.wMin),
          borderRadius: BorderRadius.circular(16.wMin),
          borderColor: AppTheme.cBorderThin.color,
          fillColor: AppTheme.cSurfaceLayerBase.color,
          valueStyle: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextPrimary.color,
          ),
          hintStyle: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
          onChanged: (data, index) {
            onChanged(data.value as T?);
          },
        ),
      ],
    );
  }

  Widget _buildCheckTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: Row(
        children: [
          Checkbox(
            value: value,
            side: BorderSide(
              color: AppTheme.cBorderTranslucentSubtle.color,
              width: 1.5.wMin,
            ),
            activeColor: AppTheme.cBgBrand.color,
            checkColor: Colors.white,
            onChanged: (next) {
              onChanged(next == true);
            },
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneChip({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 12.wMin),
        decoration: BoxDecoration(
          color: selected ? AppTheme.cSurfaceWarning.color.withValues(alpha: 0.16) : AppTheme.cSurfaceLayerBase.color,
          borderRadius: BorderRadius.circular(999.wMin),
          border: Border.all(
            color: selected ? AppTheme.cSurfaceWarning.color.withValues(alpha: 0.30) : AppTheme.cBorderThin.color,
            width: 1.wMin,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w500,
            color: selected ? AppTheme.cSurfaceWarning.color : AppTheme.cTextSecondary.color,
          ),
        ),
      ),
    );
  }
}
