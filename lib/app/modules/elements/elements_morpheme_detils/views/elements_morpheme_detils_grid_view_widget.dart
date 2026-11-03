import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/elements_card_type.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../common/elements_card_body_widget.dart';
import '../../common/elements_card_box_widget.dart';
import '../../common/elements_card_media_widget.dart';
import '../../common/elements_public_widgets.dart';
import '../../common/elements_card_title_widget.dart';
import '../../model/elements_detils_data_model.dart';
import '../../common/elements_morpheme_word_cover_card_widget.dart';
import '../controllers/elements_morpheme_detils_controller.dart';

class ElementsMorphemeDetilsGridViewWidget
    extends GetView<ElementsMorphemeDetilsController> {
  final String tagText;

  /// 网格视图
  const ElementsMorphemeDetilsGridViewWidget(
      {super.key, required this.tagText});

  @override
  // String? get tag => Get.arguments['contentId']?.toString();
  // String? get tag => StorageUtil().getString("ElementsMorphemeDetilsDuplicatePagesId");
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
        return RefreshIndicator(
          onRefresh: controller.refreshGridList,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is ScrollUpdateNotification &&
                  notification.metrics.pixels >=
                      notification.metrics.maxScrollExtent - 1000.wMin) {
                controller.loadMoreGrid();
              }
              return false;
            },
            child: GridView.builder(
              controller: controller.gridScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: controller.gridDatas.length,
              padding: EdgeInsets.only(
                left: 40.wMin,
                right: 40.wMin,
                top: 12.wMin,
                bottom: 150.wMin + MediaQuery.of(context).padding.bottom,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 24.wMin,
                crossAxisSpacing: 24.wMin,
                childAspectRatio: 346 / 546,
              ),
              itemBuilder: (context, index) {
                final CardMorphemeWordEntityDatas data =
                    controller.gridDatas[index];
                return ElementsMorphemeWordCoverCardWidget(
                  data: data,
                  morphemeContent:
                      controller.morphemeDetils.value.content ?? '',
                  morphemeType: controller.morphemeDetils.value.type ?? '',
                  onTap: () {
                    controller.toWordDetils(context, data);
                  },
                );
              },
            ),
          ),
        );
      });
  }
}
