import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../../common/elements_cards/elements_public_card.dart';
import '../bindings/elements_word_analysis_cards_binding.dart';
import '../controllers/elements_word_analysis_cards_controller.dart';

class ElementsWordAnalysisCardsView
    extends GetView<ElementsWordAnalysisCardsController> {
  final String tagText;

  const ElementsWordAnalysisCardsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return Get.to<T>(
      () => ElementsWordAnalysisCardsView(tagText: tag),
      binding: ElementsWordAnalysisCardsBinding(tagText: tag),
      routeName: Routes.EN_WORD_ANALYSIS_CARDS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    return Obx(() {
      return Scaffold(
        backgroundColor: AppTheme.cBgPrimary.color,
        body: Column(
          children: [
            BreadcrumbWidget(
              actionWidget: GeneralSettingButtonWidget(),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  90.wMin,
                  0,
                  90.wMin,
                  24.wMin + bottomInset,
                ),
                child: LockOverlayWidget(
                  rights: controller.rights.value,
                  showBack: false,
                  child: _buildBody(),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBody() {
    if (controller.isLoading.value && controller.datas.isEmpty) {
      return const SizedBox.expand();
    }
    if (controller.datas.isEmpty) {
      return _buildNotDataWidget();
    }

    final List<ElementsTitleHighlightRule>? titleHighlightRules =
        controller.shouldEnableTextHighlight()
            ? controller.previewForms
                .where((String item) => item.trim().isNotEmpty)
                .map((String item) => ElementsTitleHighlightRule(
                      text: item,
                      color: controller.resolveHighlightColor(),
                    ))
                .toList()
            : null;

    return RefreshIndicator(
      onRefresh: () => controller.refreshList(showLoading: false),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollUpdateNotification &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 1000.wMin) {
            controller.loadMore();
          }
          return false;
        },
        child: GridView.builder(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: controller.datas.length,
          padding: EdgeInsets.only(top: 12.wMin, bottom: 24.wMin),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 24.wMin,
            crossAxisSpacing: 24.wMin,
            childAspectRatio: 346 / 546,
          ),
          itemBuilder: (BuildContext context, int index) {
            final KnowledgeCommonEntityList item = controller.datas[index];
            return ElementsDictReadCard(
              data: item,
              titleHighlightRules: titleHighlightRules,
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotDataWidget() {
    return Container(
      alignment: Alignment.center,
      child: NotDataWidget(
        other: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '没有找到相关内容',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            Text(
              '当前分析下暂时没有可展示的词典卡片。',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
