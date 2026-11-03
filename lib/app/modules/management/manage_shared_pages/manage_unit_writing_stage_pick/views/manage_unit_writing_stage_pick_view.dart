import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_data.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_widget.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../bindings/manage_unit_writing_stage_pick_binding.dart';
import '../controllers/manage_unit_writing_stage_pick_controller.dart';
import '../../../../zhenxie/zhenxie_composition_stages/models/zhenxie_composition_stages_models.dart';

class ManageUnitWritingStagePickView extends GetView<ManageUnitWritingStagePickController> {
  static const double _cardHeight = 444;

  final String tagText;
  const ManageUnitWritingStagePickView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ManageUnitWritingStagePickView(tagText: tag),
      binding: ManageUnitWritingStagePickBinding(tagText: tag),
      routeName: Routes.MANAGE_UNIT_WRITING_STAGE_PICK,
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
              final List<CompositionStageModel> stageList = controller.stageList;
              final String selectedStageNid = controller.selectedStageNid.value;
              if (stageList.isEmpty && controller.isLoading.value) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  if (controller.currentStageName.isNotEmpty) _buildCurrentStageBanner(),
                  Expanded(
                    child: stageList.isEmpty
                        ? const NotDataWidget(message: '暂无写作阶梯')
                        : GridView.builder(
                            controller: controller.listScrollController,
                            padding: EdgeInsets.fromLTRB(90.wMin, 24.wMin, 90.wMin, 24.wMin),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 24.wMin,
                              mainAxisSpacing: 24.wMin,
                              mainAxisExtent: _cardHeight.wMin,
                            ),
                            itemCount: stageList.length,
                            itemBuilder: (context, index) {
                              return _buildStageCardWidget(
                                stageList[index],
                                selectedStageNid: selectedStageNid,
                              );
                            },
                          ),
                  ),
                ],
              );
            }),
          ),
          _buildBottomBarWidget(context),
        ],
      ),
    );
  }

  Widget _buildCurrentStageBanner() {
    final int taskCount = controller.taskCount;
    final int compositionTaskCount = controller.compositionTaskCount;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(90.wMin, 24.wMin, 90.wMin, 0),
      padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 16.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceError.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18.wMin),
        border: Border.all(
          color: AppTheme.cSurfaceError.color.withValues(alpha: 0.24),
          width: 1.wMin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 22.wMin,
            color: AppTheme.cSurfaceError.color,
          ),
          SizedBox(width: 12.wMin),
          Expanded(
            child: Text(
              '当前单元挂的是「${controller.currentStageName}」，下面有 $taskCount 个任务、$compositionTaskCount 篇范文。更换阶梯后，它们都会从本单元解除挂载。',
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextPrimary.color,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageCardWidget(
    CompositionStageModel stage, {
    required String selectedStageNid,
  }) {
    final int index = controller.stageList.indexOf(stage);
    final StageCardData? stageData = index >= 0 && index < controller.stageCardList.length ? controller.stageCardList[index] : null;
    if (stageData == null) return const SizedBox.shrink();
    final bool isSelected = (selectedStageNid.isNotEmpty ? selectedStageNid : controller.currentStageNid) == (stage.nid ?? '');
    return TapScaleWidget(
      sclae: 1,
      onTap: () {
        if ((stage.nid ?? '').isEmpty) return;
        controller.selectStage(stage.nid!);
      },
      child: ZhenxieWriteCatalogCardWidget(
        stageData: stageData,
        height: _cardHeight,
        copyLabel: '阶梯',
        coverOverlay: IgnorePointer(
          child: Padding(
            padding: EdgeInsets.all(12.wMin),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // color: Colors.black.withValues(alpha: 0.42),
                ),
                child: SvgPicture.asset(
                  isSelected ? 'assets/svg/manage/icon_radio.svg' : 'assets/svg/manage/icon_unradio.svg',
                  width: 28.wMin,
                  height: 28.wMin,
                  color:AppTheme.cZhenxieColorPrimary
                ),
              ),
            ),
          ),
        ),
        showCopyTag: true,
        borderColor: isSelected ? AppTheme.cZhenxieColorPrimary.color : null,
      ),
    );
  }

  Widget _buildBottomBarWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(90.wMin, 0, 90.wMin, 24.wMin),
      child: Obx(() {
        return Row(
          children: [
            Expanded(
              child: FilterStripWidget(
                startText: '当前 ${controller.stageTotalCount.value} 阶',
                sorts: {...controller.filterSorts},
                conditions: {...controller.filterConditions},
                searchs: controller.filterSearchs,
                searchSingleWidth: 420.wMin,
                onSorts: controller.onSortsChanged,
                onConditions: controller.onConditionsChanged,
                onReset: controller.onResetFilters,
                onSearch: controller.onSearch,
                onSingleClearSearch: controller.onSearch,
              ),
            ),
            SizedBox(width: 16.wMin),
            _buildConfirmButton(context),
          ],
        );
      }),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    final bool enabled = controller.canConfirm;
    return TapScaleWidget(
      sclae: enabled ? 1.01 : 1.0,
      onTap: enabled
          ? () {
              controller.confirmSelection(context);
            }
          : null,
      child: Container(
        height: 64.wMin,
        padding: EdgeInsets.symmetric(horizontal: 28.wMin),
        decoration: BoxDecoration(
          color: enabled ? AppTheme.cTextPrimary.color : AppTheme.cSurfaceLayerBase.color,
          borderRadius: BorderRadius.circular(9999.wMin),
          border: Border.all(
            color: enabled ? AppTheme.cBorderThin.color : AppTheme.cBorderThin.color,
            width: 1.wMin,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '确认',
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w600,
            color: enabled ? AppTheme.cBgPrimary.color : AppTheme.cTextTertiary.color,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
