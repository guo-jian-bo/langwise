import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../elements/common/elements_cards/elements_public_card.dart';
import '../../../management/common/commons.dart';
import '../bindings/zhenxie_phrase_match_extras_binding.dart';
import '../controllers/zhenxie_phrase_match_extras_controller.dart';

class ZhenxiePhraseMatchExtrasView extends GetView<ZhenxiePhraseMatchExtrasController> {
  final String tagText;
  const ZhenxiePhraseMatchExtrasView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> toManage<T>({dynamic arguments}) async {
    final tag = '${Routes.ZHENXIE_PHRASE_MATCH_EXTRAS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ZhenxiePhraseMatchExtrasView(tagText: tag),
      binding: ZhenxiePhraseMatchExtrasBinding(tagText: tag),
      routeName: Routes.ZHENXIE_PHRASE_MATCH_EXTRAS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxiePhraseMatchExtrasView(tagText: tag),
      binding: ZhenxiePhraseMatchExtrasBinding(tagText: tag),
      routeName: Routes.ZHENXIE_PHRASE_MATCH_EXTRAS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () {
        controller.getList();
      },
      backgroundColor: AppTheme.cBgPrimary,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BreadcrumbWidget(
            isCompatibleManage: controller.isManagement,
            actionWidget: GeneralSettingButtonWidget(
              isManagement: controller.isManagement,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 90.wMin),
              child: _buildListWidget(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListWidget() {
    return Obx(() {
      if (controller.isLoading.value && controller.cardList.isEmpty) return const SizedBox.shrink();
      if (controller.cardList.isEmpty) {
        return const NotDataWidget(message: "暂无补充卡片");
      }

      const int columnCount = 5;
      final int rowCount = (controller.cardList.length / columnCount).ceil();

      return ListView.separated(
        controller: controller.scrollController,
        itemCount: rowCount,
        padding: EdgeInsets.only(bottom: 120.wMin, top: 24.wMin),
        separatorBuilder: (context, rowIndex) => SizedBox(height: 24.wMin),
        itemBuilder: (context, rowIndex) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(columnCount * 2 - 1, (index) {
              if (index.isOdd) return SizedBox(width: 24.wMin);
              final int column = index ~/ 2;
              final int itemIndex = rowIndex * columnCount + column;
              if (itemIndex >= controller.cardList.length) {
                return const Expanded(child: SizedBox.shrink());
              }
              return Expanded(
                child: AspectRatio(
                  aspectRatio: 346 / 546,
                  child: ElementsDictReadCard(
                    data: controller.cardList[itemIndex],
                    isManagement: controller.isManagement,
                  ),
                ),
              );
            }),
          );
        },
      );
    });
  }
}
