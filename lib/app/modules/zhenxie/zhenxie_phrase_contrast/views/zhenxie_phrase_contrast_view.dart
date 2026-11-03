import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/widgets/widgets.dart';
import '../../../management/common/commons.dart';
import '../bindings/zhenxie_phrase_contrast_binding.dart';
import '../controllers/zhenxie_phrase_contrast_controller.dart';
import 'zhenxie_phrase_contrast_card_widget.dart';

class ZhenxiePhraseContrastView extends GetView<ZhenxiePhraseContrastController> {
  final String tagText;
  const ZhenxiePhraseContrastView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> toManage<T>({dynamic arguments}) async {
    final tag = '${Routes.ZHENXIE_PHRASE_CONTRAST}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ZhenxiePhraseContrastView(tagText: tag),
      binding: ZhenxiePhraseContrastBinding(tagText: tag),
      routeName: Routes.ZHENXIE_PHRASE_CONTRAST,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxiePhraseContrastView(tagText: tag),
      binding: ZhenxiePhraseContrastBinding(tagText: tag),
      routeName: Routes.ZHENXIE_PHRASE_CONTRAST,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      backgroundColor: AppTheme.cBgPrimary,
      onRefresh: () {
        controller.refreshList();
      },
      body: Column(
        children: [
          BreadcrumbWidget(isCompatibleManage: controller.isManagement),
          _buildTitleWidget(),
          SizedBox(height: 10.wMin),
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

  Widget _buildTitleWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      margin: EdgeInsets.only(top: 16.wMin),
      child: Row(
        children: [
          Text(
            "短语对照",
            style: TextStyle(
              fontSize: 32.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(width: 24.wMin),
          Text(
            "一条对照是一池：每列先钉教例，类比摊在同一槽。没有入池时只显示目录草稿。",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildListWidget(){
    return Obx((){
      if (controller.dataList.isEmpty && !controller.isLoading.value) {
        return NotDataWidget(message: "暂无数据");
      }
      return ListView.separated(
        controller: controller.scrollController,
        itemCount: controller.dataList.length,
        padding: EdgeInsets.only(bottom: 200.wMin, left: 90.wMin, right: 90.wMin, top: 6.wMin),
        separatorBuilder: (context, index) => SizedBox(height: 24.wMin),
        itemBuilder: (context, index) {
          return TapScaleWidget(
            onTap: () {
              controller.toDetails(controller.dataList[index]);
            },
            sclae: 1,
            child: ZhenxiePhraseContrastCardWidget(
              data: controller.dataList[index],
              isManagement: controller.isManagement,
            ),
          );
        },
      );
    });
  }

}
