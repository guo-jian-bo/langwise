import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../management/common/commons.dart';
import '../bindings/zhenxie_phrase_pair_binding.dart';
import '../controllers/zhenxie_phrase_pair_controller.dart';
import 'zhenxie_phrase_pair_card_widget.dart';

class ZhenxiePhrasePairView extends GetView<ZhenxiePhrasePairController> {
  final String tagText;
  const ZhenxiePhrasePairView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> toManage<T>({dynamic arguments}) async {
    final tag = '${Routes.ZHENXIE_PHRASE_PAIR}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ZhenxiePhrasePairView(tagText: tag),
      binding: ZhenxiePhrasePairBinding(tagText: tag),
      routeName: Routes.ZHENXIE_PHRASE_PAIR,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxiePhrasePairView(tagText: tag),
      binding: ZhenxiePhrasePairBinding(tagText: tag),
      routeName: Routes.ZHENXIE_PHRASE_PAIR,
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
      if (controller.dataList.isEmpty && !controller.isLoading.value) {
        return NotDataWidget(message: "暂无数据");
      }

      const int columnCount = 3;
      final int rowCount = (controller.dataList.length / columnCount).ceil();

      return ListView.separated(
        controller: controller.scrollController,
        itemCount: rowCount,
        padding: EdgeInsets.only(bottom: 200.wMin, left: 90.wMin, right: 90.wMin, top: 10.wMin),
        separatorBuilder: (context, rowIndex) => SizedBox(height: 16.wMin),
        itemBuilder: (context, rowIndex) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16.wMin,
              children: List.generate(columnCount, (column) {
                final int index = rowIndex * columnCount + column;
                if (index >= controller.dataList.length) {
                  return const Expanded(child: SizedBox.shrink());
                }
                return Expanded(child: _buildListItemWidget(index));
              }),
            ),
          );
        },
      );
    });
  }

  Widget _buildListItemWidget(int index) {
    return ZhenxiePhrasePairCardWidget(
      data: controller.dataList[index],
      isManagement: controller.isManagement,
      onTap: () {
        controller.toDetails(controller.dataList[index]);
      },
    );
  }
}
