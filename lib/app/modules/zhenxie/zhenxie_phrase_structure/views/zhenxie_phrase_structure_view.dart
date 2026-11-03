import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../management/common/commons.dart';
import '../bindings/zhenxie_phrase_structure_binding.dart';
import '../controllers/zhenxie_phrase_structure_controller.dart';
import 'zhenxie_phrase_structure_card_widget.dart';

class ZhenxiePhraseStructureView extends GetView<ZhenxiePhraseStructureController> {
  final String tagText;
  const ZhenxiePhraseStructureView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> toManage<T>({dynamic arguments}) async {
    final tag = '${Routes.ZHENXIE_PHRASE_STRUCTURE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ZhenxiePhraseStructureView(tagText: tag),
      binding: ZhenxiePhraseStructureBinding(tagText: tag),
      routeName: Routes.ZHENXIE_PHRASE_STRUCTURE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxiePhraseStructureView(tagText: tag),
      binding: ZhenxiePhraseStructureBinding(tagText: tag),
      routeName: Routes.ZHENXIE_PHRASE_STRUCTURE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () {
        controller.refreshList();
      },
      backgroundColor: AppTheme.cBgPrimary,
      body: Column(
        children: [
          BreadcrumbWidget(isCompatibleManage: controller.isManagement),
          Expanded(child: _buildListWidget()),
        ],
      ),
      floatingActionButton: _buildFilterWidget(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// 筛选的按钮
  Widget _buildFilterWidget(BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      child: Obx((){
        return FilterStripWidget(
          sorts: {...controller.filterSorts},
          conditions: {...controller.filterConditions},
          searchs: controller.filterSearchs,
          searchSingleWidth: 480.wMin,
          onSorts: (sorts) {
            controller.filterSorts.value = sorts;
            controller.refreshList();
          },
          onConditions: (conditions) {
            controller.filterConditions.value = conditions;
            controller.refreshList();
          },
          onReset: (sorts, conditions) {
            controller.filterSorts.value = sorts;
            controller.filterConditions.value = conditions;
            controller.refreshList();
          },
          onSearch: () {
            controller.refreshList();
          },
        );
      }),
    );
  }

  Widget _buildListWidget(){
    return Obx((){
      if (controller.dataList.isEmpty && !controller.isLoading.value) {
        return NotDataWidget(message: "暂无数据");
      }
      return GridView.builder(
        controller: controller.scrollController,
        itemCount: controller.dataList.length,
        padding: EdgeInsets.only(bottom: 200.wMin, left: 90.wMin, right: 90.wMin, top: 10.wMin),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 16.wMin,
          crossAxisSpacing: 16.wMin,
          // 高度先固定一个比例，后续按实际效果调整
          mainAxisExtent: 370.wMin,
        ),
        itemBuilder: (context, index) {
          return TapScaleWidget(
            onTap: () {
              controller.toDetails(controller.dataList[index]);
            },
            sclae: 1,
            borderRadius: 16.wMin,
            backColor: AppTheme.cZhenxieFontPrimary.color.withValues(alpha: 0.06),
            child: ZhenxiePhraseStructureCardWidget(
              data: controller.dataList[index],
              isManagement: controller.isManagement,
            ),
          );
        },
      );
    });
  }


}
