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
import '../../common/elements_card_title_widget.dart';
import '../../model/elements_detils_data_model.dart';
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
                return ElementsMorphemeDetilsUnifiedCardWidget(
                  data: _buildCardData(data),
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

  ElementsDetilsDataModel _buildCardData(CardMorphemeWordEntityDatas data) {
    final ElementsCardEntityDatas cardData = ElementsCardEntityDatas(
      contentType: data.contentType,
      contentTypeTitle: data.contentTypeTitle,
      contentId: data.contentId,
      content: data.content,
      definition: data.definition,
      difficulty: CardContentDifficulty(
        min: data.difficulty?.min,
        max: data.difficulty?.max,
      ),
      audioUrl: data.audioUrl,
      imageUrl: data.imageUrl,
      phonetic: data.phonetic,
      rights: data.rights,
      pos: data.pos,
      posTitle: data.posTitle,
      gloss: data.gloss,
      video: data.video,
      tags: data.tags,
      pronunciations: data.pronunciations
              ?.whereType<CardMorphemeWordEntityDatasPronunciations>()
              .map(
                (CardMorphemeWordEntityDatasPronunciations item) =>
                    PronunciationsEntity(
                  phonetic: item.phonetic,
                  audioUrl: item.audioUrl,
                  national: item.national,
                  nationalTitle: item.nationalTitle,
                  nationalIconUrl: item.nationalIconUrl,
                ),
              )
              .toList() ??
          <PronunciationsEntity>[],
    );
    cardData.semanticIds = data.semanticIds;
    return ElementsDetilsDataModel(
      type: ElementsCardType.fromRawValue(data.contentType ?? ''),
      data: cardData,
    );
  }
}

class ElementsMorphemeDetilsUnifiedCardWidget extends StatelessWidget {
  final ElementsDetilsDataModel data;
  final String morphemeContent;
  final String morphemeType;
  final VoidCallback? onTap;

  const ElementsMorphemeDetilsUnifiedCardWidget({
    super.key,
    required this.data,
    required this.morphemeContent,
    required this.morphemeType,
    this.onTap,
  });

  ConfigController get _configController => Get.find<ConfigController>();

  @override
  Widget build(BuildContext context) {
    final Color highlightColor = StatusUtils.getMorphemeTagColor(morphemeType);
    final _HighlightSegments segments = _buildHighlightSegments();

    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.01,
      child: ElementsCardBoxWidget(
        front: Container(
          padding: EdgeInsets.only(
            left: 8.wMin,
            right: 8.wMin,
            bottom: 10.wMin,
          ),
          child: Column(
            children: [
              SizedBox(height: 6.wMin),
              AspectRatio(
                aspectRatio: 1,
                child: ElementsCardBodyWidget(
          
                  child: ElementsCardMediaWidget(data: data.data),
                ),
              ),
              SizedBox(height: 6.wMin),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.wMin),
                    color: AppTheme.cBgTertiary,
                  ),
                  child: Obx(
                    () {
                      final LanguageText? gloss =
                          LearningLangUtils.getShowForNone(data.data?.gloss);
                      final String glossText = gloss?.text ?? '';
                      final bool hideGloss = glossText.isEmpty ||
                          glossText == (data.data?.content ?? '');
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text.rich(
                            TextSpan(
                              style: TextStyle(
                                fontSize: 28.wMin,
                                color: AppTheme.cTextPrimary,
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                              ),
                              children: [
                                TextSpan(text: segments.before),
                                TextSpan(
                                  text: segments.highlight,
                                  style: TextStyle(color: highlightColor),
                                ),
                                TextSpan(text: segments.after),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          if (!hideGloss)
                            Container(
                              margin: EdgeInsets.only(top: 6.wMin),
                              child: Text(
                                glossText,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20.wMin,
                                  color: AppTheme.cTextPrimary,
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 8.wMin),
              ElementCardTypeLevelWidget(
                type: data.type,
                name: data.data?.contentTypeTitle ?? '',
                minDifficulty: data.data?.difficulty?.min,
                maxDifficulty: data.data?.difficulty?.max,
                language: _configController.userSetting.value.learningLang,
                pos: data.data?.pos,
                posTitle: data.data?.posTitle,
                onDetailTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _HighlightSegments _buildHighlightSegments() {
    final String word = data.data?.content ?? '';
    final String highlight = morphemeContent.replaceAll('-', '');
    if (word.isEmpty || highlight.isEmpty) {
      return _HighlightSegments(before: '', highlight: word, after: '');
    }

    int start = word.indexOf(highlight);
    if (start < 0) {
      start = word.toLowerCase().indexOf(highlight.toLowerCase());
    }
    if (start < 0) {
      return _HighlightSegments(before: '', highlight: word, after: '');
    }

    final int end = start + highlight.length;
    return _HighlightSegments(
      before: word.substring(0, start),
      highlight: word.substring(start, end),
      after: word.substring(end),
    );
  }
}

class _HighlightSegments {
  final String before;
  final String highlight;
  final String after;

  const _HighlightSegments({
    required this.before,
    required this.highlight,
    required this.after,
  });
}
