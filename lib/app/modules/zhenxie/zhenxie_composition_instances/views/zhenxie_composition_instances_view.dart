import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_data.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../management/common/commons.dart';
import '../bindings/zhenxie_composition_instances_binding.dart';
import '../controllers/zhenxie_composition_instances_controller.dart';
import '../models/zhenxie_composition_instances_models.dart';
import 'zhenxie_composition_instance_card_widget.dart';

class ZhenxieCompositionInstancesView extends GetView<ZhenxieCompositionInstancesController> {
  final String tagText;

  const ZhenxieCompositionInstancesView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> toManage<T>({dynamic arguments}) async {
    final String tag = '${Routes.ZHENXIE_COMPOSITION_INSTANCES}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ZhenxieCompositionInstancesView(tagText: tag),
      binding: ZhenxieCompositionInstancesBinding(tagText: tag),
      routeName: Routes.ZHENXIE_COMPOSITION_INSTANCES,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieCompositionInstancesView(tagText: tag),
      binding: ZhenxieCompositionInstancesBinding(tagText: tag),
      routeName: Routes.ZHENXIE_COMPOSITION_INSTANCES,
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
          SizedBox(height: 12.wMin),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.instanceList.isEmpty) {
                return const Center();
              }
              if (controller.instanceList.isEmpty) {
                return NotDataWidget(
                  message: controller.stageNid.isEmpty ? "暂无匹配的篇章范文" : "当前阶梯暂无篇章范文",
                );
              }
              return _buildListContent();
            }),
          ),
        ],
      ),
      floatingActionButton: _buildBottomBarWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBottomBarWidget() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      child: Obx(() {
        return FilterStripWidget(
          startText: "${controller.instanceTotalCount.value} 篇范文",
          sorts: {...controller.filterSorts},
          conditions: {...controller.filterConditions},
          searchs: controller.filterSearchs,
          searchSingleWidth: 420.wMin,
          onSorts: controller.onSortsChanged,
          onConditions: controller.onConditionsChanged,
          onReset: controller.onResetFilters,
          onSearch: controller.onSearch,
          onSingleClearSearch: controller.onSearch,
        );
      }),
    );
  }

  Widget _buildListContent() {
    return GridView.builder(
      controller: controller.listScrollController,
      padding: EdgeInsets.only(left: 90.wMin, right: 90.wMin, top: 6.wMin, bottom: 180.wMin),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20.wMin,
        mainAxisSpacing: 20.wMin,
        mainAxisExtent: controller.isManagement ? 670.wMin : 454.wMin,
      ),
      itemCount: controller.instanceList.length,
      itemBuilder: (context, index) {
        final CompositionInstanceModel instance = controller.instanceList[index];
        final ContentCardData? contentData = index < controller.instanceCardList.length ? controller.instanceCardList[index] : null;
        if (contentData == null) return const SizedBox.shrink();
        return ZhenxieCompositionInstanceCardWidget(
          instance: instance,
          contentData: contentData,
          isManagement: controller.isManagement,
          showCoverOverlay: controller.isManagement,
          onReviewImages: () => controller.openInstanceImageReview(instance),
          onCropCover: () => controller.openInstanceCoverCrop(instance),
          onEditCover: () => controller.openInstanceCoverEdit(instance),
          onTap: () => controller.openInstanceDetail(instance),
          onRefreshServiceData: () => controller.refreshInstanceServiceData(instance.uid),
          onToggleAccess: () => controller.toggleInstanceAccess(instance),
        );
      },
    );
  }
}
