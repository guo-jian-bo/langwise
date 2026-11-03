import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/elements_card_type.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../model/elements_detils_data_model.dart';
import 'elements_card_body_widget.dart';
import 'elements_card_box_widget.dart';
import 'elements_card_media_widget.dart';
import 'elements_public_widgets.dart';
import 'elements_card_title_widget.dart';

class ElementsMorphemeWordCoverCardWidget extends StatelessWidget {
  final CardMorphemeWordEntityDatas data;
  final String morphemeContent;
  final String morphemeType;
  final VoidCallback? onTap;

  const ElementsMorphemeWordCoverCardWidget({
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
    final ElementsDetilsDataModel cardData = _buildCardData(data);
    final List<PronunciationsEntity> pronunciations = (cardData.data?.pronunciations ?? const <PronunciationsEntity?>[])
        .whereType<PronunciationsEntity>()
        .where((e) => (e.audioUrl ?? '').trim().isNotEmpty)
        .toList();

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
                  child: ElementsCardMediaWidget(data: cardData.data),
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
                  child: Obx(() {
                    final LanguageText? gloss = LearningLangUtils.getShowForNone(cardData.data?.gloss);
                    final String glossText = gloss?.text ?? '';
                    final bool hideGloss = glossText.isEmpty || glossText == (cardData.data?.content ?? '');
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
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
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
                                if (pronunciations.isNotEmpty) ...[
                                  SizedBox(height: 8.wMin),
                                  _MorphemePronunciationCapsuleButtons(pronunciations: pronunciations),
                                ],
                              ],
                            ),
                          ),
                        if (hideGloss && pronunciations.isNotEmpty)
                          Container(
                            margin: EdgeInsets.only(top: 8.wMin),
                            child: _MorphemePronunciationCapsuleButtons(pronunciations: pronunciations),
                          ),
                      ],
                    );
                  }),
                ),
              ),
              SizedBox(height: 8.wMin),
              ElementCardTypeLevelWidget(
                type: cardData.type,
                name: cardData.data?.contentTypeTitle ?? '',
                minDifficulty: cardData.data?.difficulty?.min,
                maxDifficulty: cardData.data?.difficulty?.max,
                language: _configController.userSetting.value.learningLang,
                pos: cardData.data?.pos,
                posTitle: cardData.data?.posTitle,
                onDetailTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
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
                (CardMorphemeWordEntityDatasPronunciations item) => PronunciationsEntity(
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

  _HighlightSegments _buildHighlightSegments() {
    final String word = data.content ?? '';
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

class _MorphemePronunciationCapsuleButtons extends StatefulWidget {
  final List<PronunciationsEntity> pronunciations;

  const _MorphemePronunciationCapsuleButtons({
    required this.pronunciations,
  });

  @override
  State<_MorphemePronunciationCapsuleButtons> createState() => _MorphemePronunciationCapsuleButtonsState();
}

class _MorphemePronunciationCapsuleButtonsState extends State<_MorphemePronunciationCapsuleButtons> {
  int _playingIndex = -1;

  String _resolvePronunciationLabel(PronunciationsEntity item) {
    final String national = (item.national ?? '').trim().toUpperCase();
    if (national.isNotEmpty) return national;
    return (item.nationalTitle ?? '').contains('英') ? 'UK' : 'US';
  }

  Future<void> _togglePlay(int index) async {
    final String audioUrl = (widget.pronunciations[index].audioUrl ?? '').trim();
    if (audioUrl.isEmpty) return;

    if (_playingIndex == index) {
      await PlayAudioUtils.instance.stopAll();
      _playingIndex = -1;
      if (mounted) setState(() {});
      return;
    }

    await PlayAudioUtils.instance.stopAll();
    _playingIndex = index;
    if (mounted) setState(() {});
    await PlayAudioUtils.instance.playSingle(audioUrl);
    _playingIndex = -1;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(widget.pronunciations.length, (int index) {
        return Padding(
          padding: EdgeInsets.only(right: index == widget.pronunciations.length - 1 ? 0 : 8.wMin),
          child: ElementsPronunciationCapsuleButton(
            label: _resolvePronunciationLabel(widget.pronunciations[index]),
            isSelected: false,
            isPlaying: _playingIndex == index,
            onTap: () => _togglePlay(index),
          ),
        );
      }),
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
