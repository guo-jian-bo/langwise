import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../routes/routes.dart';
import '../../common/elements_cards/elements_public_card.dart';
import '../../model/elements_detils_data_model.dart';
import '../bindings/elements_phrase_sentence_cards_binding.dart';
import '../controllers/elements_phrase_sentence_cards_controller.dart';

class ElementsPhraseSentenceCardsView
    extends GetView<ElementsPhraseSentenceCardsController> {
  final String tagText;

  const ElementsPhraseSentenceCardsView({
    super.key,
    required this.tagText,
  });

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({
    dynamic arguments,
    required String tag,
  }) async {
    return Get.to<T>(
      () => ElementsPhraseSentenceCardsView(tagText: tag),
      binding: ElementsPhraseSentenceCardsBinding(tagText: tag),
      routeName: Routes.EN_PHRASE_SENTENCE_CARDS,
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
                child: _buildBody(),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBody() {
    if (controller.isLoading.value && controller.sentenceCards.isEmpty) {
      return const SizedBox.expand();
    }
    if (controller.sentenceCards.isEmpty) {
      return _buildNotDataWidget();
    }

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
          itemCount: controller.sentenceCards.length,
          padding: EdgeInsets.only(top: 12.wMin, bottom: 24.wMin),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 24.wMin,
            crossAxisSpacing: 24.wMin,
            childAspectRatio: 346 / 546,
          ),
          itemBuilder: (BuildContext context, int index) {
            final CardPhraseSentenceCardsData item =
                controller.sentenceCards[index];
            final KnowledgeCommonEntityList? card = item.contentCard;
            if (card == null) return const SizedBox.shrink();
            final List<ElementsDetilsDataHighlightModel> sentenceHighlights =
                item.ranges
                        ?.whereType<CardPhraseSentenceCardsRange>()
                        .where((CardPhraseSentenceCardsRange range) {
                          final int start = range.start ?? -1;
                          final int end = range.end ?? -1;
                          return start >= 0 && end > start;
                        })
                        .map((CardPhraseSentenceCardsRange range) {
                          return ElementsDetilsDataHighlightModel(
                            text: range.text,
                            start: range.start!,
                            end: range.end!,
                            highlightColor: controller.resolveHighlightColor(),
                          );
                        })
                        .toList() ??
                    <ElementsDetilsDataHighlightModel>[];

            return ElementsDictReadCard(
              data: card,
              sentenceHighlights:
                  sentenceHighlights.isEmpty ? null : sentenceHighlights,
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
              '当前短语下暂时没有可展示的句子卡片。',
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
