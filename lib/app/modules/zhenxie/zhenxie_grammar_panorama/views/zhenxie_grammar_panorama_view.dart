import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../management/common/commons.dart';
import '../bindings/zhenxie_grammar_panorama_binding.dart';
import '../controllers/zhenxie_grammar_panorama_controller.dart';
import '../../../../../common/widgets/zhenxie_widgets/zhenxie_grammar_panorama_item_widget.dart';

class ZhenxieGrammarPanoramaView extends GetView<ZhenxieGrammarPanoramaController> {
  final String tagText;
  const ZhenxieGrammarPanoramaView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 管理端入口跳转方法（生成唯一 tag，支持多实例）。
  static Future<T?> toManage<T>({dynamic arguments}) async {
    final tag = '${Routes.ZHENXIE_GRAMMAR_PANORAMA}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ZhenxieGrammarPanoramaView(tagText: tag),
      binding: ZhenxieGrammarPanoramaBinding(tagText: tag),
      routeName: Routes.ZHENXIE_GRAMMAR_PANORAMA,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  /// 标签路由跳转方法（外部传入 tag，支持实例隔离）。
  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieGrammarPanoramaView(tagText: tag),
      binding: ZhenxieGrammarPanoramaBinding(tagText: tag),
      routeName: Routes.ZHENXIE_GRAMMAR_PANORAMA,
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
  Widget _buildFilterWidget(BuildContext context) {
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

  Widget _buildListWidget() {
    return Obx(() {
      if (controller.grammarPanoramaList.isEmpty && !controller.isLoading.value) {
        return NotDataWidget(message: "暂无数据");
      }
      final int rowCount = (controller.grammarPanoramaList.length / 2).ceil();
      return ListView.separated(
        controller: controller.scrollController,
        itemCount: rowCount,
        padding: EdgeInsets.only(bottom: 200.wMin, left: 90.wMin, right: 90.wMin, top: 10.wMin),
        separatorBuilder: (context, index) => SizedBox(height: 24.wMin),
        itemBuilder: (context, index) {
          final int leftIndex = index * 2;
          final int rightIndex = leftIndex + 1;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildListItemWidget(controller.grammarPanoramaList[leftIndex]),
                ),
                SizedBox(width: 24.wMin),
                Expanded(
                  child: rightIndex < controller.grammarPanoramaList.length
                      ? _buildListItemWidget(controller.grammarPanoramaList[rightIndex])
                      : SizedBox.shrink(),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildListItemWidget(ManageGrammarPanoramaEntity data) {
    return ZhenxieGrammarPanoramaItemWidget(
      data: data,
      isManagement: controller.isManagement,
      onTap: () {
        controller.jumpToDetailPage(data);
      },
    );
  }
}
