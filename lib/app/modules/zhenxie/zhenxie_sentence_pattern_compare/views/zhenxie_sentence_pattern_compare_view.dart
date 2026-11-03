import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../management/common/commons.dart';
import '../bindings/zhenxie_sentence_pattern_compare_binding.dart';
import '../controllers/zhenxie_sentence_pattern_compare_controller.dart';
import '../../../../../common/widgets/zhenxie_widgets/zhenxie_sentence_pattern_compare_card_widget.dart';

class ZhenxieSentencePatternCompareView extends GetView<ZhenxieSentencePatternCompareController> {
  final String tagText;
  const ZhenxieSentencePatternCompareView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 管理端入口跳转方法（生成唯一 tag，支持多实例）。
  static Future<T?> toManage<T>({dynamic arguments}) async {
    final tag = '${Routes.ZHENXIE_SENTENCE_PATTERN_COMPARE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ZhenxieSentencePatternCompareView(tagText: tag),
      binding: ZhenxieSentencePatternCompareBinding(tagText: tag),
      routeName: Routes.ZHENXIE_SENTENCE_PATTERN_COMPARE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  /// 标签路由跳转方法（外部传入 tag，支持实例隔离）。
  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieSentencePatternCompareView(tagText: tag),
      binding: ZhenxieSentencePatternCompareBinding(tagText: tag),
      routeName: Routes.ZHENXIE_SENTENCE_PATTERN_COMPARE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: ManageScaffold(
        onRefresh: () {
          controller.refreshList();
        },
        body: Column(
          children: [
            BreadcrumbWidget(isCompatibleManage: controller.isManagement),
            Expanded(child: _buildListWidget()),
          ],
        ),
        floatingActionButton: _buildFilterWidget(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
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
      if(controller.patternCompareList.isEmpty && !controller.isLoading.value){
        return NotDataWidget(message: "暂无数据");
      }
      final int rowCount = (controller.patternCompareList.length / 2).ceil();

      return ListView.separated(
        controller: controller.scrollController,
        itemCount: rowCount,
        padding: EdgeInsets.only(bottom: 200.wMin, left: 90.wMin, right: 90.wMin, top: 10.wMin),
        separatorBuilder: (context, rowIndex) => SizedBox(height: 16.wMin),
        itemBuilder: (context, rowIndex) {
          final int leftIndex = rowIndex * 2;
          final int rightIndex = leftIndex + 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16.wMin,
              children: [
                Expanded(child: _buildListItemWidget(leftIndex)),
                Expanded(
                  child: rightIndex < controller.patternCompareList.length ? _buildListItemWidget(rightIndex) : SizedBox.shrink(),
                ),
              ],
            ),
          );
        },
      );
    });
  }


  Widget _buildListItemWidget(int index) {
    return ZhenxieSentencePatternCompareCardWidget(
      data: controller.patternCompareList[index],
      isManagement: controller.isManagement,
      onTap: (data) {
        controller.jumpToDetailPage(controller.patternCompareList[index]);
      },
    );
  }

 
  
}
