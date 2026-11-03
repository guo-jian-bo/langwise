import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../management/common/commons.dart';
import '../bindings/zhenxie_etymology_forest_binding.dart';
import '../controllers/zhenxie_etymology_forest_controller.dart';
import 'zhenxie_etymology_forest_card_widget.dart';

class ZhenxieEtymologyForestView extends GetView<ZhenxieEtymologyForestController> {
  final String tagText;
  const ZhenxieEtymologyForestView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieEtymologyForestView(tagText: tag),
      binding: ZhenxieEtymologyForestBinding(tagText: tag),
      routeName: Routes.ZHENXIE_ETYMOLOGY_FOREST,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      backgroundColor: AppTheme.cBgPrimary,
      body: Column(
        children: [
          BreadcrumbWidget(isCompatibleManage: controller.isManagement,actionWidget: Container(child: Text("义项不是一条条背，是同一根意思的投影",style: TextStyle(fontSize: 16.wMin,fontWeight: FontWeight.w400,color: AppTheme.cTextSecondary.color),),)),
          Expanded(child: _buildListWidget()),
        ],
      ),
      floatingActionButton: _buildFilterWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }


  /// 森林卡片三列网格
  Widget _buildListWidget() {
    return Obx(() {
      if (controller.dataList.isEmpty && !controller.isLoading.value) {
        return NotDataWidget(message: "没有匹配的森林，试试重置筛选。");
      }
      return GridView.builder(
        controller: controller.scrollController,
        padding: EdgeInsets.only(bottom: 200.wMin, left: 90.wMin, right: 90.wMin, top: 6.wMin),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16.wMin,
          mainAxisSpacing: 16.wMin,
          mainAxisExtent: 260.wMin,
        ),
        itemCount: controller.dataList.length,
        itemBuilder: (context, index) {
          return TapScaleWidget(
            onTap: () {
              controller.toDetails(controller.dataList[index]);
            },
            sclae: 1,
            borderRadius: 16.wMin,
            backColor: AppTheme.cZhenxieFontPrimary.color.withValues(alpha: 0.06),
            child: ZhenxieEtymologyForestCardWidget(data: controller.dataList[index]),
          );
        },
      );
    });
  }

  /// 底部的搜索筛选
  Widget _buildFilterWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      child: Obx(() {
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
}
