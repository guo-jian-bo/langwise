import 'package:flutter/cupertino.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/painter/decoding_grading_painter.dart';
import 'package:langwise/common/widgets/filter_widgets.dart';
import 'package:langwise/common/widgets/icon_dropdown_widget.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/common/widgets/zhenxie_widgets/word_inflection_info_tag_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/values/app_font_value.dart';
import '../../../../../common/widgets/dialog_box_widget.dart';
import '../../../../../common/widgets/simple_dictionary_dialog.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/tag_routes.dart';
import '../../common/elements_analysis_cards_widget.dart';
import '../../common/elements_memory_action_button.dart';
import '../../common/elements_public_widgets.dart';
import '../../dictionary/controllers/dictionary_controller.dart';
import '../../../zhenxie/zhenxie_etymology_forest/views/zhenxie_etymology_forest_card_widget.dart';
import '../controllers/elements_word_detils_controller.dart';

class ElementsWordDetilsContentWidget extends StatefulWidget {
  final ElementsWordDetilsController controller;

  const ElementsWordDetilsContentWidget({
    super.key,
    required this.controller,
  });

  @override
  State<ElementsWordDetilsContentWidget> createState() => _ElementsWordDetilsContentWidgetState();
}

class _ElementsWordDetilsContentWidgetState extends State<ElementsWordDetilsContentWidget> {
  static const int _allPlayingIndex = 999;
  static const int _nonePlayingIndex = -1;

  final Set<String> _selectedPoses = <String>{};
  final List<PronunciationsEntity> _pronunciations = [];
  final List<DecodingGradingLetterModel> _gradingLetters = [];
  final List<String> _phoneticsTexts = [];
  final List<List<int?>> _phoneticsPositions = [];
  final Set<String> _playingAudioUrls = <String>{};
  String? _pronunciationSemanticKey;
  int _selectedPronunciationIndex = 0;
  int _selectedDividerType = 0;
  int _playingIndex = _nonePlayingIndex;
  bool _isPause = false;
  bool _hasHandledInitialModuleJump = false;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      _syncSelectedPosWithCurrentSemantic();
      if (widget.controller.currentSemantic.value.uid == null && widget.controller.semanticItems.isEmpty) {
        return const SizedBox.shrink();
      }

      final CardWordSemanticDetilsEntity detils = widget.controller.cardDetils.value;
      final CardWordDetilsEntityPosListSemantics semantic = widget.controller.currentSemantic.value;
      _syncPronunciationPanelState(detils, semantic);
      _tryHandleInitialModuleJump(detils);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double sectionSpacing = 16.wMin;
                final double contentHeight = constraints.maxHeight;
                final double availableHeight = (contentHeight - sectionSpacing).clamp(0, contentHeight);
                final double topHeight = availableHeight * 460 / 835;
                final double bottomHeight = availableHeight - topHeight;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: topHeight,
                      child: _buildTopSection(detils, semantic, topHeight),
                    ),
                    SizedBox(height: sectionSpacing),
                    SizedBox(
                      height: bottomHeight,
                      child: _buildBottomSection(detils, topHeight),
                    ),
                  ],
                );
              },
            ),
          ),
          if (widget.controller.semanticItems.isNotEmpty) ...[
            SizedBox(height: 16.wMin),
            Align(
              alignment: Alignment.center,
              child: _buildSemanticTabBar(_filteredSemanticItems()),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildTopSection(
    CardWordSemanticDetilsEntity detils,
    CardWordDetilsEntityPosListSemantics semantic,
    double topHeight,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: topHeight,
          height: topHeight,
          child: _WordImagePanel(
            imageUrl: semantic.imageUrl,
            relationVideo: semantic.video,
            pronunciations: semantic.pronunciations,
            semanticPlaybackKey: '${detils.contentId ?? 0}_${semantic.uid ?? 0}',
          ),
        ),
        SizedBox(width: 16.wMin),
        Expanded(
          child: _buildTopRightSection(detils, semantic),
        ),
      ],
    );
  }

  Widget _buildTopRightSection(
    CardWordSemanticDetilsEntity detils,
    CardWordDetilsEntityPosListSemantics semantic,
  ) {
    final bool hasPronunciation = _activePronunciations(semantic.pronunciations).isNotEmpty;
    final bool hasMorphology = detils.morphologyPreview?.components?.whereType<CardWordMorphologyPreviewComponent>().isNotEmpty == true;
    final bool showMiddleSection = hasPronunciation || hasMorphology;
    final double minInfoHeight = 158.wMin;
    final double middleHeight = 125.wMin;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: minInfoHeight),
          child: Obx(() => _buildTitleInfoSection(detils, semantic)),
        ),
        SizedBox(height: 16.wMin),
        if (showMiddleSection) ...[
          SizedBox(
            height: middleHeight,
            child: _buildPronunciationMorphologySection(
              detils,
              semantic,
              hasPronunciation: hasPronunciation,
              hasMorphology: hasMorphology,
            ),
          ),
          SizedBox(height: 16.wMin),
        ],
        Expanded(
          child: _buildGrammarSynonymSection(detils),
        ),
      ],
    );
  }

  Widget _buildMorphologyPreview(CardWordMorphologyPreview morphologyPreview) {
    final ConfigController configController = Get.find<ConfigController>();
    final List<CardWordMorphologyPreviewComponent> components =
        morphologyPreview.components?.whereType<CardWordMorphologyPreviewComponent>().toList() ?? <CardWordMorphologyPreviewComponent>[];
    final double titleFontSize = 18.wMin;
    final double contentMaxFontSize = 36.wMin;
    final double contentMinFontSize = titleFontSize;
    final double itemSpacing = 8.wMin;
    final double itemPadding = 6.wMin;
    final double headerSpacing = 6.wMin;
    final double itemBorderWidth = 1.wMin;
    final double textSafetyWidth = 6.wMin;
    return TapScaleWidget(
      onTap: () => _openMorphologyPreviewPage(morphologyPreview),
      sclae: 1.01,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceTranslucentBase.color,
          borderRadius: BorderRadius.circular(18.wMin),
          border: Border.all(
            color: AppTheme.cBorderTranslucentThin.color,
            width: 1.wMin,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.wMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double contentFontSize = _resolveMorphologyContentFontSize(
                    components: components,
                    configs: configController.colorConfigs.value,
                    maxWidth: constraints.maxWidth,
                    titleFontSize: titleFontSize,
                    contentMaxFontSize: contentMaxFontSize,
                    contentMinFontSize: contentMinFontSize,
                    itemSpacing: itemSpacing,
                    itemPadding: itemPadding,
                    headerSpacing: headerSpacing,
                    itemBorderWidth: itemBorderWidth,
                    textSafetyWidth: textSafetyWidth,
                  );

                  final List<Widget> children = [];
                  for (int index = 0; index < components.length; index++) {
                    final CardWordMorphologyPreviewComponent component = components[index];
                    final LanguageConfigColorEntityInfo? typeConfig = _findMorphologyTypeConfig(
                      configController.colorConfigs.value,
                      component.type,
                    );
                    final _MorphologyTagStyle style = _buildMorphologyTagStyle(typeConfig);
                    final double itemWidth = _measureMorphologyItemWidth(
                      component: component,
                      index: index,
                      typeConfig: typeConfig,
                      titleFontSize: titleFontSize,
                      contentFontSize: contentFontSize,
                      itemPadding: itemPadding,
                      headerSpacing: headerSpacing,
                      itemBorderWidth: itemBorderWidth,
                      textSafetyWidth: textSafetyWidth,
                    );
                    children.add(
                      SizedBox(
                        width: itemWidth,
                        child: Container(
                          padding: EdgeInsets.all(itemPadding),
                          decoration: BoxDecoration(
                            color: style.bgColor,
                            borderRadius: BorderRadius.circular(12.wMin),
                            border: Border.all(
                              color: style.borderColor,
                              width: 1.wMin,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    typeConfig?.title ?? '',
                                    style: TextStyle(
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.w400,
                                      color: style.textColor,
                                    ),
                                  ),
                                  SizedBox(width: headerSpacing),
                                  Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.w400,
                                      color: AppTheme.cTextTertiary.color,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 44.wMin,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    component.content ?? '',
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: contentFontSize,
                                      fontWeight: FontWeight.w400,
                                      color: AppTheme.cTextPrimary.color,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    if (index < components.length - 1) {
                      children.add(SizedBox(width: itemSpacing));
                    }
                  }

                  return Row(children: children, mainAxisAlignment: MainAxisAlignment.center);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleInfoSection(
    CardWordSemanticDetilsEntity detils,
    CardWordDetilsEntityPosListSemantics semantic,
  ) {
    final ConfigController configController = Get.find<ConfigController>();
    final List<PronunciationsEntity> pronunciations = _activePronunciations(semantic.pronunciations);
    final LangPreference preference = configController.userSetting.value.expandLang;
    final String infoLang = preference == LangPreference.translation
        ? configController.userSetting.value.localLang
        : configController.userSetting.value.learningLang;
    final String glossText = _findLanguageText(semantic.gloss, infoLang);
    final String descriptionText = _findLanguageText(semantic.descriptions, infoLang);
    final List<Widget> tags = _buildTitleTags(detils, semantic);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentBase.color,
        borderRadius: BorderRadius.circular(24.wMin),
        border: Border.all(
          color: AppTheme.cBorderTranslucentThin.color,
          width: 1.wMin,
        ),
      ),
      padding: EdgeInsets.all(16.wMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8.wMin,
                  runSpacing: 8.wMin,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                        detils.content ?? '',
             
                        style: TextStyle(
                          fontSize: 44.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cTextPrimary.color,
                          // height: 1.0,
                        ),
                      ),
                     ... pronunciations.take(2).map((pronunciation) {
        return _buildPronunciationButton(pronunciation);
      }),
                    // if (pronunciations.isNotEmpty) ...[
                    //   SizedBox(width: 8.wMin),
                    //   _buildPronunciationGroup(pronunciations),
                    // ],
                  ],
                ),
                if (glossText.isNotEmpty || tags.isNotEmpty) ...[
   
                   Wrap(
                    spacing: 8.wMin,
                    runSpacing: 8.wMin,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                   
                        Text(
                          glossText ,
                          style: TextStyle(
                            fontSize: 24.wMin,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.cTextPrimary,
                            height: 1.0,
                          ),
                        ),
                      ...tags,
                    ],
                  )
                  // RichText(
                  //   maxLines: 2,
                  //   textAlign: TextAlign.start,
                  //   overflow: TextOverflow.ellipsis,
                  //   text: TextSpan(
                  //     children: _buildGlossInlineSpans(
                  //       glossText: glossText,
                  //       tags: tags,
                  //     ),
                  //   ),
                  // ),
                ],
                if (descriptionText.isNotEmpty) ...[
                  SizedBox(height: 8.wMin),
                  Text(
                    descriptionText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextSecondary.color,
                      height: 1.0,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 16.wMin),
          SizedBox(
            width: 156.wMin,
            child: Column(
              children: [
                Visibility(
                  visible: detils.pronunciationExercise == true,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8.wMin),
                    child: _buildPracticeActionButton(pronunciations),
                  ),
                ),
                ElementsMemoryActionButton(
                  favorited: widget.controller.isCurrentSemanticFavorited(),
                  onTap: _handleMemoryAction,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<InlineSpan> _buildGlossInlineSpans({
    required String glossText,
    required List<Widget> tags,
  }) {
    final TextStyle glossStyle = TextStyle(
      fontSize: 40.wMin,
      fontWeight: FontWeight.w500,
      color: AppTheme.cTextPrimary.color,
      height: 1.0,
    );
    final List<InlineSpan> spans = <InlineSpan>[];
    if (glossText.isNotEmpty) {
      spans.add(TextSpan(text: glossText, style: glossStyle));
    }
    for (int index = 0; index < tags.length; index++) {
      spans.add(
        WidgetSpan(
            alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: EdgeInsets.only(left: (glossText.isNotEmpty || index > 0) ? 8.wMin : 0),
            child: tags[index],
          ),
        ),
      );
    }
    return spans;
  }

  Widget _buildPracticeActionButton(List<PronunciationsEntity> pronunciations) {
    final String national = _resolvePracticePronunciationNational(pronunciations);
    return TapScaleWidget(
      onTap: national.isEmpty
          ? null
          : () {
              ReviewExerciseUtils.toEval(
                widget.controller.cardDetils.value.contentType,
                widget.controller.cardDetils.value.contentId,
                widget.controller.currentSemanticId.value > 0 ? widget.controller.currentSemanticId.value : null,
                national,
                exerciseType: 'PRONUNCIATION_ASSESSMENT',
              );
            },
      sclae: 1.02,
      child: Container(
        height: 50.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.cTextBrand.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999.wMin),
          border: Border.all(
            color: AppTheme.cTextBrand.color.withValues(alpha: 0.2),
            width: 1.wMin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/svg/elements/Icon_bo.svg',
              width: 20.wMin,
              height: 20.wMin,
            ),
            SizedBox(width: 6.wMin),
            Text(
              '练发音',
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextBrand.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleMemoryAction() async {
    final CardWordSemanticDetilsEntity detils = widget.controller.cardDetils.value;
    final int semanticId = widget.controller.currentSemanticId.value;
    if (detils.contentId == null || (detils.contentType ?? '').isEmpty) {
      ToastUtils.showToast(text: '缺少加入记忆参数');
      return;
    }
    final SimpleDictionaryAddCardParm parameter = SimpleDictionaryAddCardParm(
      uid: detils.contentId,
      type: detils.contentType,
      semanticId: semanticId > 0 ? semanticId : null,
    );
    if (parameter.semanticId == null) {
      ToastUtils.showToast(text: '缺少加入记忆参数');
      return;
    }
    final bool resp = await SimpleDictionaryDialog.addKnowledgeCard(
      context: context,
      parameter: <SimpleDictionaryAddCardParm>[parameter],
    );
    if (!resp) return;
    widget.controller.setCurrentSemanticFavorited(true);
    final DictionaryController? dictionaryController = DictionaryController.registered;
    if (dictionaryController != null) {
      await dictionaryController.refreshList(showLoading: false);
    }
  }

  Widget _buildPronunciationMorphologySection(
    CardWordSemanticDetilsEntity detils,
    CardWordDetilsEntityPosListSemantics semantic, {
    required bool hasPronunciation,
    required bool hasMorphology,
  }) {
    if (hasPronunciation && hasMorphology) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildPronunciationSection(detils, semantic)),
          SizedBox(width: 14.wMin),
          Expanded(child: _buildMorphologyPreview(detils.morphologyPreview!)),
        ],
      );
    }
    if (hasPronunciation) {
      return _buildPronunciationSection(detils, semantic);
    }
    if (hasMorphology) {
      return _buildMorphologyPreview(detils.morphologyPreview!);
    }
    return const SizedBox.shrink();
  }

  Widget _buildPronunciationSection(
    CardWordSemanticDetilsEntity detils,
    CardWordDetilsEntityPosListSemantics semantic,
  ) {
    if (_pronunciations.isEmpty) return const SizedBox.shrink();
    final PronunciationsEntity currentPronunciation = _pronunciations[_selectedPronunciationIndex];
    final List<PronunciationsEntityIpa> syllables =
        (currentPronunciation.syllables ?? <PronunciationsEntityIpa?>[]).whereType<PronunciationsEntityIpa>().toList();
    final List<PronunciationsEntityIpa> phonetics =
        (currentPronunciation.phonetics ?? <PronunciationsEntityIpa?>[]).whereType<PronunciationsEntityIpa>().toList();
    final bool hasSyllables = syllables.length > 1;
    final bool hasPhonetics = phonetics.isNotEmpty;
    final int dividerType = _resolveDividerType(hasSyllables, hasPhonetics);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentBase.color,
        borderRadius: BorderRadius.circular(28.wMin),
        border: Border.all(
          color: AppTheme.cBorderTranslucentThin.color,
          width: 1.wMin,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.wMin, 6.wMin, 16.wMin, 14.wMin),
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: hasSyllables
                    ? (dividerType == 0
                        ? _buildSyllablesWidget(detils.content ?? '', syllables)
                        : _buildPhoneticsWidget(detils.content ?? ''))
                    : (hasPhonetics
                        ? _buildPhoneticsWidget(detils.content ?? '')
                        : _buildPronunciationNotDataWidget(
                            content: detils.content ?? '',
                            currentPronunciation: currentPronunciation,
                            syllables: syllables,
                            phonetics: phonetics,
                          )),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (hasSyllables && hasPhonetics)
                    _buildTabDividerWidget(
                      hasSyllables: hasSyllables,
                      hasPhonetics: hasPhonetics,
                      dividerType: dividerType,
                    )
                  else
                    const SizedBox.shrink(),
                  _buildHasPracticeWidget(currentPronunciation),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrammarSynonymSection(CardWordSemanticDetilsEntity detils) {
    final CardWordAnalysisEntry? grammarEntry = _findAnalysisEntry('grammar');
    final CardWordAnalysisEntry? synonymEntry = _findAnalysisEntry('synonym');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: grammarEntry == null
              ? const SizedBox.shrink()
              : _buildAnalysisCard(
                  grammarEntry,
                  _buildGrammarPreview(detils.analysisData?.grammar),
                  onTap: () => _openInflectionDetailsPage(detils.analysisData?.grammar),
                ),
        ),
        SizedBox(width: 16.wMin),
        Expanded(
          child: synonymEntry == null
              ? const SizedBox.shrink()
              : _buildAnalysisCard(
                  synonymEntry,
                  _buildLexicalSetPreview(detils.analysisData?.lexicalSetPreview),
                  onTap: () => _openAnalysisCardsPage(synonymEntry),
                ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(
    CardWordSemanticDetilsEntity detils,
    double leftWidth,
  ) {
    final CardWordAnalysisEntry? memoryEntry = _findAnalysisEntry('memory');
    final CardWordAnalysisEntry? phraseEntry = _findAnalysisEntry('phrase');
    final CardWordAnalysisEntry? sentenceEntry = _findAnalysisEntry('sentence');
    final Widget phraseWidget = phraseEntry == null
        ? const SizedBox.shrink()
        : _buildAnalysisCard(
            phraseEntry,
            _buildPhrasePreview(detils.analysisData?.phrases),
            onTap: () => _openAnalysisCardsPage(phraseEntry),
          );
    final Widget sentenceWidget = sentenceEntry == null
        ? const SizedBox.shrink()
        : _buildAnalysisCard(
            sentenceEntry,
            _buildSentencePreview(detils.analysisData?.sentences),
            onTap: () => _openAnalysisCardsPage(sentenceEntry),
          );

    if (memoryEntry == null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (phraseEntry != null) ...[
            SizedBox(
              width: leftWidth,
              child: phraseWidget,
            ),
            SizedBox(width: 16.wMin),
          ],
          Expanded(child: sentenceWidget),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: leftWidth,
          child: _buildAnalysisCard(
            memoryEntry,
            _buildMemoryPreview(detils),
            onTap: _openEtymologyMemoryPage,
          ),
        ),
        SizedBox(width: 16.wMin),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: phraseWidget),
              SizedBox(width: 16.wMin),
              Expanded(child: sentenceWidget),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisCard(CardWordAnalysisEntry entry, Widget child, {VoidCallback? onTap}) {
    final String chineseTitle = _findLanguageText(entry.title, 'zh');
    final String englishTitle = _findLanguageText(entry.title, 'en');
    final Color fromColor = ColorUtils.parseColor(entry.color?.from) ?? AppTheme.cTextBrand.color;
    final Color toColor = ColorUtils.parseColor(entry.color?.to) ?? fromColor;

    return ElementsAnalysisCardWidget(
      chineseTitle: chineseTitle,
      englishTitle: englishTitle,
      index: entry.index,
      fromColor: fromColor,
      toColor: toColor,
      onTap: onTap ?? () => ToastUtils.showToast(text: '本次暂未接入'),
      child: child,
    );
  }

  Widget _buildGrammarPreview(CardWordAnalysisGrammarData? data) {
    final List<String> previewForms =
        data?.previewForms?.whereType<String>().where((String item) => item.isNotEmpty).toList() ?? <String>[];
    if (previewForms.isEmpty) {
      return const ElementsAnalysisEmptyState(text: '暂无语法预览');
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.wMin, 8.wMin, 20.wMin, 16.wMin),
      child: Wrap(
        spacing: 8.wMin,
        runSpacing: 8.wMin,
        children: previewForms.map((form) {
          return WordInflectionInfoTagWidget(
            form,
            fontSize: 20.wMin,
          );
        }).toList(),
      ),
    );
  }

  void _syncPronunciationPanelState(
    CardWordSemanticDetilsEntity detils,
    CardWordDetilsEntityPosListSemantics semantic,
  ) {
    final String nextKey = '${detils.contentId ?? 0}_${semantic.uid ?? widget.controller.currentSemanticId.value}';
    if (_pronunciationSemanticKey != nextKey) {
      _pronunciationSemanticKey = nextKey;
      _reloadPronunciationState(
        pronunciations: semantic.pronunciations,
        content: detils.content ?? '',
        notify: false,
      );
      // 首次进入当前语义时就对齐全局发音偏好，避免后续任意 `setState`
      // 才触发二次同步，导致面板从第一条突然跳到第二条。
      _syncSelectedPronunciationWithGlobalSetting(content: detils.content ?? '');
      return;
    }
    _syncSelectedPronunciationWithGlobalSetting(content: detils.content ?? '');
  }

  List<PronunciationsEntity> _activePronunciations(
    List<PronunciationsEntity?>? pronunciations,
  ) {
    return pronunciations?.whereType<PronunciationsEntity>().toList() ?? <PronunciationsEntity>[];
  }

  void _reloadPronunciationState({
    required List<PronunciationsEntity?>? pronunciations,
    required String content,
    int selectedIndex = 0,
    bool notify = true,
  }) {
    // 这里要先拷贝一份快照，避免调用方传入的正好就是 `_pronunciations`，
    // 导致 `clear()` 时把源数据也一起清空。
    final List<PronunciationsEntity> nextPronunciations = _activePronunciations(pronunciations);
    _pronunciations
      ..clear()
      ..addAll(nextPronunciations);
    if (_pronunciations.isEmpty) {
      _selectedPronunciationIndex = 0;
    } else {
      _selectedPronunciationIndex = selectedIndex.clamp(0, _pronunciations.length - 1);
    }
    _selectedDividerType = 0;
    _playingIndex = _nonePlayingIndex;
    _isPause = false;
    _gradingLetters.clear();
    _phoneticsTexts.clear();
    _phoneticsPositions.clear();

    if (_pronunciations.isNotEmpty) {
      final PronunciationsEntity currentPronunciation = _pronunciations[_selectedPronunciationIndex];
      final List<PronunciationsEntityIpa> syllables =
          (currentPronunciation.syllables ?? <PronunciationsEntityIpa?>[]).whereType<PronunciationsEntityIpa>().toList();
      final List<PronunciationsEntityIpa> phonetics =
          (currentPronunciation.phonetics ?? <PronunciationsEntityIpa?>[]).whereType<PronunciationsEntityIpa>().toList();
      if (syllables.length <= 1 && phonetics.isNotEmpty) {
        _selectedDividerType = 1;
      }
      for (final PronunciationsEntityIpa item in phonetics) {
        _phoneticsTexts.add(item.ipa ?? '');
        List<int?> positions = item.positions ?? <int?>[];
        if ((item.ipa ?? '').isEmpty) {
          positions = <int?>[];
        }
        _phoneticsPositions.add(positions);
      }
      final String normalized = _normalizedPronunciationContent(
        content: content,
        phonetics: phonetics,
        syllables: syllables,
      );
      for (int index = 0; index < normalized.length; index++) {
        _gradingLetters.add(
          DecodingGradingLetterModel(
            letter: normalized[index],
            key: GlobalKey(),
          ),
        );
      }
    }

    if (notify && mounted) {
      setState(() {});
    }
  }

  int _preferredPronunciationIndex() {
    final String pronunciationCode = Get.find<ConfigController>().userSetting.value.expandPronunciationCode;
    for (int index = 0; index < _pronunciations.length; index++) {
      final String national = (_pronunciations[index].national ?? '').trim().toUpperCase();
      if (national == pronunciationCode) return index;
    }
    for (int index = 0; index < _pronunciations.length; index++) {
      final String title = (_pronunciations[index].nationalTitle ?? '').trim();
      if (pronunciationCode == 'UK' && title.contains('英')) return index;
      if (pronunciationCode == 'US' && title.contains('美')) return index;
    }
    return 0;
  }

  String _resolvePracticePronunciationNational(
    List<PronunciationsEntity> pronunciations,
  ) {
    if (pronunciations.isEmpty) return '';
    final String pronunciationCode = Get.find<ConfigController>().userSetting.value.expandPronunciationCode;
    for (int index = 0; index < pronunciations.length; index++) {
      final String national = (pronunciations[index].national ?? '').trim().toUpperCase();
      if (national == pronunciationCode) {
        return pronunciations[index].national ?? '';
      }
    }
    for (int index = 0; index < pronunciations.length; index++) {
      final String title = (pronunciations[index].nationalTitle ?? '').trim();
      if (pronunciationCode == 'UK' && title.contains('英')) {
        return pronunciations[index].national ?? '';
      }
      if (pronunciationCode == 'US' && title.contains('美')) {
        return pronunciations[index].national ?? '';
      }
    }
    return pronunciations.first.national ?? '';
  }

  void _syncSelectedPronunciationWithGlobalSetting({
    required String content,
  }) {
    if (_pronunciations.isEmpty) return;
    final int preferredIndex = _preferredPronunciationIndex();
    if (preferredIndex == _selectedPronunciationIndex) return;
    _reloadPronunciationState(
      pronunciations: _pronunciations,
      content: content,
      selectedIndex: preferredIndex,
      notify: false,
    );
  }

  int _resolveDividerType(bool hasSyllables, bool hasPhonetics) {
    if (_selectedDividerType == 0 && hasSyllables) return 0;
    if (_selectedDividerType == 1 && hasPhonetics) return 1;
    if (hasSyllables) return 0;
    if (hasPhonetics) return 1;
    return 0;
  }

  String _normalizedPronunciationContent({
    required String content,
    required List<PronunciationsEntityIpa> phonetics,
    required List<PronunciationsEntityIpa> syllables,
  }) {
    final String raw = content.replaceAll(RegExp(r'\s+'), '').trim();
    if (raw.isNotEmpty) return raw;
    final String fromPositions = _buildContentFromPhonetics(phonetics);
    if (fromPositions.isNotEmpty) return fromPositions;
    return syllables
        .map((PronunciationsEntityIpa item) => (item.graphemes ?? '').trim())
        .where((String item) => item.isNotEmpty)
        .join('')
        .trim();
  }

  String _buildContentFromPhonetics(List<PronunciationsEntityIpa> phonetics) {
    if (phonetics.isEmpty) return '';
    int maxIndex = -1;
    for (final PronunciationsEntityIpa item in phonetics) {
      final List<int> positions = item.positions?.whereType<int>().toList() ?? <int>[];
      if (positions.isEmpty) continue;
      final int localMax = positions.reduce((int a, int b) => a > b ? a : b);
      if (localMax > maxIndex) maxIndex = localMax;
    }
    if (maxIndex < 0) return '';

    final List<String> chars = List<String>.filled(maxIndex + 1, '');
    for (final PronunciationsEntityIpa item in phonetics) {
      final String graphemes = (item.graphemes ?? '').trim();
      final List<int> positions = item.positions?.whereType<int>().toList() ?? <int>[];
      if (graphemes.isEmpty || positions.isEmpty) continue;
      if (graphemes.length == positions.length) {
        for (int index = 0; index < positions.length; index++) {
          final int currentIndex = positions[index];
          if (currentIndex < 0 || currentIndex >= chars.length) continue;
          chars[currentIndex] = graphemes[index];
        }
        continue;
      }
      final String chunk = graphemes.replaceAll(RegExp(r'\s+'), '');
      final int start = positions.reduce((int a, int b) => a < b ? a : b);
      if (start >= 0 && start < chars.length && chars[start].isEmpty) {
        chars[start] = chunk;
      }
      for (final int currentIndex in positions.skip(1)) {
        if (currentIndex < 0 || currentIndex >= chars.length) continue;
        if (chars[currentIndex].isEmpty) chars[currentIndex] = '';
      }
    }
    return chars.join().trim();
  }

  Color _resolveActiveTextColor({
    required bool isActive,
    required bool isGroupedActive,
  }) {
    if (_playingIndex == _nonePlayingIndex) return AppTheme.cTextPrimary;
    if (_playingIndex == _allPlayingIndex) return AppTheme.cTextBrand.color;
    if (isGroupedActive || isActive) return AppTheme.cTextBrand.color;
    return AppTheme.cTextPrimary;
  }

  Future<void> _playWholePronunciationWithHighlight({
    required String audioUrl,
    required int highlightIndex,
  }) async {
    if (audioUrl.isEmpty) return;
    if (mounted) {
      setState(() {
        _playingIndex = highlightIndex;
      });
    }
    await PlaybackInterlockUtils.instance.playSharedAudio(audioUrl);
    if (!mounted || _isPause) return;
    setState(() {
      _playingIndex = _nonePlayingIndex;
    });
  }

  Future<void> startPlaySyllables() async {
    if (_pronunciations.isEmpty || _playingIndex != _nonePlayingIndex) return;
    final PronunciationsEntity currentPronunciation = _pronunciations[_selectedPronunciationIndex];
    final List<PronunciationsEntityIpa?> syllables = currentPronunciation.syllables ?? <PronunciationsEntityIpa?>[];
    _isPause = false;
    try {
      final List<int> playableIndexes = <int>[];
      for (int index = 0; index < syllables.length; index++) {
        if ((syllables[index]?.audioUrl ?? '').isEmpty) continue;
        playableIndexes.add(index);
      }
      if (playableIndexes.isEmpty) {
        await _playWholePronunciationWithHighlight(
          audioUrl: currentPronunciation.audioUrl ?? '',
          highlightIndex: _allPlayingIndex,
        );
        return;
      }
      for (final int index in playableIndexes) {
        if (mounted) {
          setState(() {
            _playingIndex = index;
          });
        }
        await PlaybackInterlockUtils.instance.playSharedAudio(
          syllables[index]?.audioUrl ?? '',
        );
        if (!mounted || _isPause) return;
      }
      if (syllables.length == 1) {
        if (mounted) {
          setState(() {
            _playingIndex = _nonePlayingIndex;
          });
        }
        return;
      }
      await _playWholePronunciationWithHighlight(
        audioUrl: currentPronunciation.audioUrl ?? '',
        highlightIndex: _allPlayingIndex,
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _playingIndex = _nonePlayingIndex;
        });
      }
    }
  }

  Future<void> playSyllablesItem(int index) async {
    if (_pronunciations.isEmpty || _playingIndex != _nonePlayingIndex) return;
    final PronunciationsEntity currentPronunciation = _pronunciations[_selectedPronunciationIndex];
    final List<PronunciationsEntityIpa?> syllables = currentPronunciation.syllables ?? <PronunciationsEntityIpa?>[];
    if (index >= syllables.length || syllables[index] == null) return;
    if ((syllables[index]?.audioUrl ?? '').isEmpty) {
      _isPause = false;
      await _playWholePronunciationWithHighlight(
        audioUrl: currentPronunciation.audioUrl ?? '',
        highlightIndex: index,
      );
      return;
    }
    if (mounted) {
      setState(() {
        _playingIndex = index;
      });
    }
    await PlaybackInterlockUtils.instance.playSharedAudio(
      syllables[index]?.audioUrl ?? '',
    );
    if (!mounted || _selectedDividerType == 1) return;
    setState(() {
      _playingIndex = _nonePlayingIndex;
    });
  }

  Future<void> startPlayPhonetics() async {
    if (_pronunciations.isEmpty || _playingIndex != _nonePlayingIndex) return;
    final PronunciationsEntity currentPronunciation = _pronunciations[_selectedPronunciationIndex];
    final List<PronunciationsEntityIpa?> phonetics = currentPronunciation.phonetics ?? <PronunciationsEntityIpa?>[];
    _isPause = false;

    int firstPos(PronunciationsEntityIpa? item, int fallback) {
      final List<int> positions = item?.positions?.whereType<int>().toList() ?? <int>[];
      if (positions.isEmpty) return fallback;
      int min = positions.first;
      for (final int value in positions) {
        if (value < min) min = value;
      }
      return min;
    }

    try {
      final List<int> order = List<int>.generate(phonetics.length, (int index) => index)
        ..sort((int a, int b) => firstPos(phonetics[a], a).compareTo(firstPos(phonetics[b], b)));
      for (final int index in order) {
        final PronunciationsEntityIpa? item = phonetics[index];
        if (item == null || (item.audioUrl ?? '').isEmpty) continue;
        if (mounted) {
          setState(() {
            _playingIndex = index;
          });
        }
        await PlaybackInterlockUtils.instance.playSharedAudio(item.audioUrl);
        if (!mounted || _isPause) return;
      }
      if (mounted) {
        setState(() {
          _playingIndex = _allPlayingIndex;
        });
      }
      await PlaybackInterlockUtils.instance.playSharedAudio(
        currentPronunciation.audioUrl,
      );
      if (!mounted || _isPause) return;
      setState(() {
        _playingIndex = _nonePlayingIndex;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _playingIndex = _nonePlayingIndex;
        });
      }
    }
  }

  Future<void> playPhoneticsItem(int index) async {
    if (_pronunciations.isEmpty || _playingIndex != _nonePlayingIndex) return;
    final PronunciationsEntity currentPronunciation = _pronunciations[_selectedPronunciationIndex];
    final List<PronunciationsEntityIpa?> phonetics = currentPronunciation.phonetics ?? <PronunciationsEntityIpa?>[];
    for (int currentIndex = 0; currentIndex < phonetics.length; currentIndex++) {
      if (!_phoneticsPositions[currentIndex].contains(index)) continue;
      if (phonetics[currentIndex] == null || phonetics[currentIndex]?.audioUrl == null) {
        continue;
      }
      if (mounted) {
        setState(() {
          _playingIndex = currentIndex;
        });
      }
      await PlaybackInterlockUtils.instance.playSharedAudio(
        phonetics[currentIndex]?.audioUrl,
      );
      break;
    }
    if (mounted) {
      setState(() {
        _playingIndex = _nonePlayingIndex;
      });
    }
  }

  Future<void> playKnowledgePointItem() async {
    if (_pronunciations.isEmpty || _playingIndex != _nonePlayingIndex) return;
    final PronunciationsEntity currentPronunciation = _pronunciations[_selectedPronunciationIndex];
    if (currentPronunciation.audioUrl == null) return;
    _isPause = false;
    if (mounted) {
      setState(() {
        _playingIndex = _allPlayingIndex;
      });
    }
    await PlaybackInterlockUtils.instance.playSharedAudio(
      currentPronunciation.audioUrl,
    );
    if (!mounted || _isPause) return;
    setState(() {
      _playingIndex = _nonePlayingIndex;
    });
  }

  Widget _buildPronunciationNotDataWidget({
    required String content,
    required PronunciationsEntity currentPronunciation,
    required List<PronunciationsEntityIpa> syllables,
    required List<PronunciationsEntityIpa> phonetics,
  }) {
    final bool all = _playingIndex == _allPlayingIndex;
    final Color phoneticColor = all ? AppTheme.cTextBrand.color : AppTheme.cTextPrimary;
    final String word = _normalizedPronunciationContent(
      content: content,
      phonetics: phonetics,
      syllables: syllables,
    );
    String text = (currentPronunciation.phonetic ?? '').trim();
    if (text.isEmpty && syllables.length > 1) {
      text = syllables.map((PronunciationsEntityIpa item) => item.graphemes ?? '').join('-').trim();
    }
    if (text.isEmpty) {
      text =
          phonetics.map((PronunciationsEntityIpa item) => item.graphemes ?? '').where((String item) => item.isNotEmpty).join(' · ').trim();
    }
    if (text.isEmpty) {
      text = content;
    }

    final Color textColor = _playingIndex == _nonePlayingIndex ? AppTheme.cTextPrimary : phoneticColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (word.isNotEmpty)
          SizedBox(
            height: 48.wMin,
            child: Center(
              child: Text(
                word,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 30.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        SizedBox(
          height: 48.wMin,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '/ ',
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFontValue.andikaRegular,
                ),
              ),
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppFontValue.andikaRegular,
                  ),
                ),
              ),
              Text(
                ' /',
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFontValue.andikaRegular,
                ),
              ),
              SizedBox(width: 12.wMin),
              _buildPlayButtonWidget(
                currentPronunciation,
                onTap: playKnowledgePointItem,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabDividerWidget({
    required bool hasSyllables,
    required bool hasPhonetics,
    required int dividerType,
  }) {
    final List<IconDropdownCheckData<int>> items = [
      IconDropdownCheckData<int>(title: '音节划分', value: 0, isEnable: hasSyllables),
      IconDropdownCheckData<int>(title: '自然拼读', value: 1, isEnable: hasPhonetics),
    ];

    return IconDropdownCheckWidget(
      key: ValueKey<String>(
        'pronunciation_divider_${_selectedPronunciationIndex}_${dividerType}_${hasSyllables ? 1 : 0}_${hasPhonetics ? 1 : 0}',
      ),
      items: items,
      width: 160.wMin,
      itemHeight: 52.wMin,
      menuHeight: 104.wMin,
      selectIndex: dividerType,
      onTap: (data, index) {
        final int? value = data.value;
        if (value == null) return;
        setState(() {
          PlayAudioUtils.instance.stopAll();
          _selectedDividerType = value;
          _playingIndex = _nonePlayingIndex;
          _isPause = true;
        });
      },
      child: Container(
        width: 112.wMin,
        height: 34.wMin,
        // padding: EdgeInsets.fromLTRB(12.wMin, 8.wMin, 8.wMin, 8.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9999.wMin),
          color: AppTheme.cSurfaceTranslucentBase.color,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              items[dividerType].title,
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(width: 2.wMin),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16.wMin,
              color: AppTheme.cTextSecondary.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyllablesWidget(
    String content,
    List<PronunciationsEntityIpa> syllables,
  ) {
    if (syllables.length <= 1) return Container();

    final String original = _normalizedPronunciationContent(
      content: content,
      phonetics: const <PronunciationsEntityIpa>[],
      syllables: syllables,
    );
    final Map<int, int> hyphenMap = <int, int>{};
    int letters = 0;
    for (int index = 0; index < original.length; index++) {
      final String char = original[index];
      if (char == '-') {
        hyphenMap[letters] = (hyphenMap[letters] ?? 0) + 1;
      } else {
        letters++;
      }
    }

    final List<String> displayTexts = <String>[];
    final List<int?> displaySources = <int?>[];
    int acc = 0;
    for (int sourceIndex = 0; sourceIndex < syllables.length; sourceIndex++) {
      final String graphemes = syllables[sourceIndex].graphemes ?? '';
      displayTexts.add(graphemes);
      displaySources.add(sourceIndex);
      acc += graphemes.length;
      final int hyphenCount = hyphenMap[acc] ?? 0;
      for (int index = 0; index < hyphenCount; index++) {
        displayTexts.add('-');
        displaySources.add(null);
      }
    }

    final TextStyle textStyle = TextStyle(
      fontSize: 30.wMin,
      color: AppTheme.cTextPrimary,
      fontWeight: FontWeight.w500,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 56.wMin,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4.wMin,
              children: List.generate(displayTexts.length, (int index) {
                final int? sourceIndex = displaySources[index];
                final bool isActive = _playingIndex == _allPlayingIndex || (sourceIndex != null && _playingIndex == sourceIndex);
                if (sourceIndex == null) {
                  return Text(displayTexts[index], style: textStyle);
                }
                return TapScaleWidget(
                  onTap: () {
                    playSyllablesItem(sourceIndex);
                  },
                  sclae: 1,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.wMin),
                      color: isActive ? AppTheme.cFeedbackInfoBackground.color.withValues(alpha: 0.85) : AppTheme.cSurfaceTertiary,
                    ),
                    child: Text(displayTexts[index], style: textStyle),
                  ),
                );
              }),
            ),
          ),
        ),
        SizedBox(
          height: 40.wMin,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '/ ',
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFontValue.andikaRegular,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(syllables.length, (int index) {
                  return Text(
                    syllables[index].ipa ?? '',
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: _resolveActiveTextColor(
                        isActive: _playingIndex == index,
                        isGroupedActive: false,
                      ),
                      fontWeight: FontWeight.w500,
                      fontFamily: AppFontValue.andikaRegular,
                    ),
                  );
                }),
              ),
              Text(
                ' /',
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFontValue.andikaRegular,
                ),
              ),
              SizedBox(width: 12.wMin),
              _buildPlayButtonWidget(
                _pronunciations[_selectedPronunciationIndex],
                onTap: startPlaySyllables,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneticsWidget(String content) {
    if (_gradingLetters.isEmpty) return Container();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 56.wMin,
          child: Center(
            child: CustomPaint(
              painter: DecodingGradingPainter(
                strokeWidth: 4.wMin,
                curveRadius: 20.wMin,
                letterBottomHeight: 2.wMin,
                models: _gradingLetters,
                positions: _phoneticsPositions,
                color: AppTheme.cTextBrand.color,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_gradingLetters.length, (int index) {
                  final bool isGroupedActive = _playingIndex >= 0 &&
                      _playingIndex < _phoneticsPositions.length &&
                      _phoneticsPositions[_playingIndex].contains(index);
                  return TapScaleWidget(
                    onTap: () {
                      playPhoneticsItem(index);
                    },
                    sclae: 1,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.wMin),
                      color: Colors.transparent,
                      child: Text(
                        _gradingLetters[index].letter,
                        key: _gradingLetters[index].key,
                        style: TextStyle(
                          fontSize: 30.wMin,
                          color: _resolveActiveTextColor(
                            isActive: false,
                            isGroupedActive: isGroupedActive,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 40.wMin,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '/ ',
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFontValue.andikaRegular,
                ),
              ),
              Row(
                children: List.generate(_phoneticsTexts.length, (int index) {
                  return Text(
                    _phoneticsTexts[index],
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: _resolveActiveTextColor(
                        isActive: _playingIndex == index,
                        isGroupedActive: false,
                      ),
                      fontWeight: FontWeight.w500,
                      fontFamily: AppFontValue.andikaRegular,
                    ),
                  );
                }),
              ),
              Text(
                ' /',
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFontValue.andikaRegular,
                ),
              ),
              SizedBox(width: 12.wMin),
              _buildPlayButtonWidget(
                _pronunciations[_selectedPronunciationIndex],
                onTap: startPlayPhonetics,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButtonWidget(
    PronunciationsEntity currentPronunciation, {
    VoidCallback? onTap,
  }) {
    return ElementsPlayButtonCircle(
      size: 32,
      iconSize: 20,
      onTap: onTap ??
          () async {
            await PlaybackInterlockUtils.instance.playSharedAudio(
              currentPronunciation.audioUrl,
            );
          },
      enabled: (currentPronunciation.audioUrl ?? '').isNotEmpty || onTap != null,
    );
  }

  Widget _buildHasPracticeWidget(PronunciationsEntity currentPronunciation) {
    if (currentPronunciation.isExercise != true) return Container();
    return TapScaleWidget(
      onTap: () async {
        await PlayAudioUtils.instance.stopAll();
        _playingIndex = _nonePlayingIndex;
        _isPause = true;
        if (mounted) setState(() {});
        ReviewExerciseUtils.toEval(
          widget.controller.cardDetils.value.contentType,
          widget.controller.cardDetils.value.contentId,
          widget.controller.currentSemanticId.value > 0 ? widget.controller.currentSemanticId.value : null,
          currentPronunciation.national,
        );
      },
      sclae: 1.02,
      child: Text(
        '练拼读',
        style: TextStyle(
          fontSize: 18.wMin,
          fontWeight: FontWeight.w600,
          color: AppTheme.cTextBrand.color,
          height: 1.0,
        ),
      ),
    );
  }

  List<Widget> _buildTitleTags(
    CardWordSemanticDetilsEntity detils,
    CardWordDetilsEntityPosListSemantics semantic,
  ) {
    final ConfigController configController = Get.find<ConfigController>();
    final CardWordSemanticItem? item = widget.controller.findCurrentSemanticItem();
    final ThemeTextStyleEntity? style = StyleUtils.getCurrentThemeText(item?.textStyle);
    final String posText = _resolvePosText(item);
    final List<Widget> tags = [];
    final Color posTagColor = ColorUtils.parseColor(style?.borderColor) ?? AppTheme.cTextPrimary.color;
    if (semantic.difficulty != null) {
      final DifficultieEntity? currentDifficulty = DifficultieUtils.getLanguageDifficultieLevel(
        configController.appConfig.value,
        configController.userSetting.value.learningLang,
        semantic.difficulty,
      );
      final String difficultyText = currentDifficulty?.name?.text ?? '';

      if (difficultyText.isNotEmpty) {
        final Color color = StatusUtils.getDifficultyBackgroundColor(semantic.difficulty).color1;
        tags.add(
          WordInflectionInfoTagWidget(
            difficultyText,
            textColor: color,
            bgColor: color.withValues(alpha: 0.12),
            borderColor: color.withValues(alpha: 0.20),
          ),
        );
      }
    }
    if (posText.isNotEmpty) {

      tags.add(
        WordInflectionInfoTagWidget(
          posText,
          textColor: posTagColor,
          bgColor: posTagColor.withValues(alpha: 0.12),
          borderColor: posTagColor.withValues(alpha: 0.20),
        ),
      );
    }
    final List<_WordTagConfig> grammaticalTags = _resolveGrammaticalTypeTags(item, configController);
    for (final _WordTagConfig tag in grammaticalTags) {
      tags.add(
        _buildGrammaticalProfileTagWidget(
          text: tag.label,
          tagColor: posTagColor,
          onTap: () => _openGrammaticalProfileDialog(
            detils: detils,
            selectedTag: tag,
            allTags: grammaticalTags,
            tagColor: posTagColor,
          ),
        ),
      );
    }
    return tags;
  }

  void _openGrammaticalProfileDialog({
    required CardWordSemanticDetilsEntity detils,
    required _WordTagConfig selectedTag,
    required List<_WordTagConfig> allTags,
    required Color tagColor,
  }) {
    final CardWordGrammaticalProfile? initialProfile = _findGrammaticalProfile(detils, selectedTag.code);
    if (initialProfile == null) {
      ToastUtils.showToast(text: '暂无语法画像');
      return;
    }
    final String descriptionText = _findLanguageText(initialProfile.descriptions, 'zh');
    if (descriptionText.isEmpty) {
      ToastUtils.showToast(text: '暂无语法画像');
      return;
    }
    _WordTagConfig currentSelectedTag = selectedTag;

    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return DialogUserWidget(
          title: '语法画像',
          width: 720.wMin,
          titlePadding: EdgeInsets.fromLTRB(32.wMin, 32.wMin, 32.wMin, 12.wMin),
          physics: const ClampingScrollPhysics(),
          child: SizedBox(
            width: double.infinity,
            child: StatefulBuilder(
              builder: (BuildContext context, void Function(void Function()) setState) {
                final CardWordGrammaticalProfile? currentProfile =
                    _findGrammaticalProfile(detils, currentSelectedTag.code);
                final String currentDescriptionText =
                    _findLanguageText(currentProfile?.descriptions, 'zh');
                return Padding(
                  padding: EdgeInsets.fromLTRB(16.wMin, 0, 16.wMin, 32.wMin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if ((detils.content ?? '').isNotEmpty)
                        Text(
                          detils.content ?? '',
                          style: TextStyle(
                            fontSize: 40.wMin,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.cTextPrimary,
                            height: 1.2,
                          ),
                        ),
                      if (allTags.isNotEmpty) ...[
                        SizedBox(height: 6.wMin),
                        Wrap(
                          spacing: 8.wMin,
                          runSpacing: 8.wMin,
                          children: allTags.map((tag) {
                            final bool isSelected = tag.code == currentSelectedTag.code;
                            return Opacity(
                              opacity: isSelected ? 1 : 0.6,
                              child: _buildGrammaticalProfileTagWidget(
                                text: tag.label,
                                tagColor: tagColor,
                                fontSize: 14.wMin,
                                fontWeight: FontWeight.w600,
                                onTap: () {
                                  if (tag.code == currentSelectedTag.code) return;
                                  final CardWordGrammaticalProfile? nextProfile =
                                      _findGrammaticalProfile(detils, tag.code);
                                  final String nextDescriptionText =
                                      _findLanguageText(nextProfile?.descriptions, 'zh');
                                  if (nextProfile == null || nextDescriptionText.isEmpty) {
                                    ToastUtils.showToast(text: '暂无语法画像');
                                    return;
                                  }
                                  setState(() {
                                    currentSelectedTag = tag;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      SizedBox(height: 16.wMin),
                      SelectableText(
                        currentDescriptionText,
                        style: TextStyle(
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cTextPrimary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrammaticalProfileTagWidget({
    required String text,
    required Color tagColor,
    double? fontSize,
    FontWeight? fontWeight,
    VoidCallback? onTap,
  }) {
    final Widget child = Container(
      height: 32.wMin,
      padding: EdgeInsets.symmetric(horizontal: 12.wMin),
      decoration: BoxDecoration(
        color: tagColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.wMin),
        border: Border.all(
          color: tagColor.withValues(alpha: 0.20),
          width: 1.wMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 16.wMin,
              fontWeight: fontWeight ?? FontWeight.w400,
              color: tagColor,
            ),
          ),
          SizedBox(width: 4.wMin),
          SvgPicture.asset(
            'assets/svg/public/Icons_dictionary_right.svg',
            width: 12.wMin,
            height: 12.wMin,
            colorFilter: ColorFilter.mode(tagColor, BlendMode.srcIn),
          ),
        ],
      ),
    );
    if (onTap == null) return child;
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.03,
      child: child,
    );
  }

  CardWordGrammaticalProfile? _findGrammaticalProfile(
    CardWordSemanticDetilsEntity detils,
    String code,
  ) {
    if (code.isEmpty) return null;
    final List<CardWordGrammaticalProfile> profiles =
        detils.grammaticalProfiles?.whereType<CardWordGrammaticalProfile>().toList() ?? <CardWordGrammaticalProfile>[];
    for (final CardWordGrammaticalProfile item in profiles) {
      if ((item.grammaticalTypeNid ?? '').toLowerCase() == code.toLowerCase()) {
        return item;
      }
    }
    return null;
  }

  Widget _buildLexicalSetPreview(
    List<CardWordLexicalSetPreviewItem?>? lexicalSetPreview,
  ) {
    final CardWordLexicalSetPreviewItem? synonym = _findLexicalSetPreviewItem(lexicalSetPreview, 'synonym');
    final CardWordLexicalSetPreviewItem? antonym = _findLexicalSetPreviewItem(lexicalSetPreview, 'antonym');
    final List<String> synonymChips = synonym?.chips?.whereType<String>().where((item) => item.isNotEmpty).toList() ?? <String>[];
    final List<String> antonymChips = antonym?.chips?.whereType<String>().where((item) => item.isNotEmpty).toList() ?? <String>[];
    if (synonymChips.isEmpty && antonymChips.isEmpty) {
      return const ElementsAnalysisEmptyState(text: '暂无同义反义');
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(12.wMin, 0, 12.wMin, 6.wMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildLexicalSetColumn(
              title: synonym?.name ?? '同义',
              chips: synonymChips,
            ),
          ),
          SizedBox(width: 8.wMin),
          Expanded(
            child: _buildLexicalSetColumn(
              title: antonym?.name ?? '反义',
              chips: antonymChips,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLexicalSetColumn({
    required String title,
    required List<String> chips,
  }) {
    return Container(
      padding: EdgeInsets.all(4.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentBase.color,
        borderRadius: BorderRadius.circular(16.wMin),
        border: Border.all(
          color: AppTheme.cBorderTranslucentThin.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(height: 4.wMin),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.wMin),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final List<String> visibleChips = _resolveLexicalVisibleChips(
                  context: context,
                  chips: chips,
                  maxWidth: constraints.maxWidth,
                  maxHeight: constraints.maxHeight,
                );
                return Align(
                  alignment: Alignment.topLeft,
                  child: Wrap(
                    spacing: 4.wMin,
                    runSpacing: 4.wMin,
                    children: visibleChips.map((String item) {
                      return WordInflectionInfoTagWidget(
                        item,
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<String> _resolveLexicalVisibleChips({
    required BuildContext context,
    required List<String> chips,
    required double maxWidth,
    required double maxHeight,
  }) {
    if (chips.isEmpty) return const <String>[];
    if (maxWidth <= 0 || maxHeight <= 0) return const <String>[];
    if (!maxWidth.isFinite || !maxHeight.isFinite) return chips;

    final int maxLines = _resolveLexicalChipMaxLines(maxHeight);
    for (int visibleCount = chips.length; visibleCount >= 0; visibleCount--) {
      final int overflowCount = chips.length - visibleCount;
      final List<String> displayTexts = chips.take(visibleCount).toList();
      if (overflowCount > 0) {
        displayTexts.add('+$overflowCount');
      }
      if (_canFitLexicalChipTexts(
        context: context,
        texts: displayTexts,
        maxWidth: maxWidth,
        maxLines: maxLines,
      )) {
        return displayTexts;
      }
    }
    return <String>['+${chips.length}'];
  }

  int _resolveLexicalChipMaxLines(double maxHeight) {
    final double lineHeight = 32.wMin;
    final double lineSpacing = 4.wMin;
    final int maxLines = ((maxHeight + lineSpacing) / (lineHeight + lineSpacing)).floor();
    return maxLines < 1 ? 1 : maxLines;
  }

  bool _canFitLexicalChipTexts({
    required BuildContext context,
    required List<String> texts,
    required double maxWidth,
    required int maxLines,
  }) {
    if (texts.isEmpty) return true;
    final double chipSpacing = 4.wMin;
    int currentLine = 1;
    double currentLineWidth = 0;
    for (final String text in texts) {
      final double chipWidth = _measureLexicalChipWidth(context, text);
      if (currentLineWidth == 0) {
        currentLineWidth = chipWidth;
        continue;
      }
      if (currentLineWidth + chipSpacing + chipWidth <= maxWidth) {
        currentLineWidth += chipSpacing + chipWidth;
        continue;
      }
      currentLine += 1;
      if (currentLine > maxLines) {
        return false;
      }
      currentLineWidth = chipWidth;
    }
    return true;
  }

  double _measureLexicalChipWidth(BuildContext context, String text) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 16.wMin,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    return painter.width + 30.wMin;
  }

  CardWordLexicalSetPreviewItem? _findLexicalSetPreviewItem(
    List<CardWordLexicalSetPreviewItem?>? items,
    String code,
  ) {
    for (final CardWordLexicalSetPreviewItem? item in items ?? <CardWordLexicalSetPreviewItem?>[]) {
      if ((item?.code ?? '').toLowerCase() == code) return item;
    }
    return null;
  }

  Future<void> _openAnalysisCardsPage(CardWordAnalysisEntry entry) async {
    final String type = (entry.type ?? '').trim();
    final String title = _findLanguageText(entry.title, 'zh');
    await _openAnalysisCardsPageByType(type: type, title: title);
  }

  Future<void> _openAnalysisCardsPageByType({
    required String type,
    String title = '',
  }) async {
    final int? contentId = widget.controller.contentId;
    final int semanticId = widget.controller.currentSemanticId.value;
    final String contentType = (widget.controller.cardDetils.value.contentType ?? '').trim();
    if (contentId == null || semanticId <= 0 || type.isEmpty) {
      ToastUtils.showToast(text: '缺少跳转参数');
      return;
    }
    if (type == 'synonym') {
      if (contentType.isEmpty) {
        ToastUtils.showToast(text: '缺少跳转参数');
        return;
      }
      await TagRoutes.toNamed(
        Routes.EN_LEXICAL_DETAIL,
        tagText: '${widget.controller.tagText}_lexical_$semanticId',
        arguments: <String, dynamic>{
          'contentType': contentType,
          'contentId': contentId,
          'semanticId': semanticId,
          'title': title,
        },
      );
      return;
    }
    await TagRoutes.toNamed(
      Routes.EN_WORD_ANALYSIS_CARDS,
      tagText: '${widget.controller.tagText}_analysis_${type}_$semanticId',
      arguments: <String, dynamic>{
        'type': type,
        'contentId': contentId,
        'contentType': contentType,
        'semanticId': semanticId,
        'title': title,
      },
    );
  }

  void _tryHandleInitialModuleJump(CardWordSemanticDetilsEntity detils) {
    if (_hasHandledInitialModuleJump) return;
    final String module = (detils.module ?? '').trim();
    if (module.isEmpty) {
      _hasHandledInitialModuleJump = true;
      return;
    }
    if (!_hasMatchedAnalysisData(detils.analysisData, module)) {
      _hasHandledInitialModuleJump = true;
      return;
    }
    _hasHandledInitialModuleJump = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _openModulePageByType(module, detils);
    });
  }

  bool _hasMatchedAnalysisData(CardWordAnalysisData? analysisData, String module) {
    if (analysisData == null || module.isEmpty) return false;
    final Map<String, dynamic> analysisMap = analysisData.toJson();
    return analysisMap.containsKey(module) && analysisMap[module] != null;
  }

  Future<void> _openModulePageByType(
    String module,
    CardWordSemanticDetilsEntity detils,
  ) async {
    if (module == 'grammar') {
      await _openInflectionDetailsPage(
        detils.analysisData?.grammar,
        contentId: widget.controller.initialContentId ?? detils.contentId,
      );
      return;
    }
    if (module == 'memory') {
      await _openEtymologyMemoryPage();
      return;
    }
    await _openAnalysisCardsPageByType(type: module);
  }

  Future<void> _openMorphologyPreviewPage(CardWordMorphologyPreview morphologyPreview) async {
    final String key = (morphologyPreview.key ?? '').trim();
    if (key.isEmpty) {
      ToastUtils.showToast(text: '缺少构词参数');
      return;
    }
    final String mode = (morphologyPreview.mode ?? '').trim().toLowerCase();
    if (mode == 'root') {
      await TagRoutes.toNamed(
        Routes.MANAGE_WORD_MORPHOLOGY_DETAILS,
        arguments: <String, dynamic>{
          'key': key,
          'isManagement': false,
        },
        tagText: '${widget.controller.tagText}_morphology_root_$key',
      );
      return;
    }
    await TagRoutes.toNamed(
      Routes.MANAGE_WORD_MORPHOLOGY_TREE,
      arguments: <String, dynamic>{
        'key': key,
        'isManagement': false,
      },
      tagText: '${widget.controller.tagText}_morphology_tree_$key',
    );
  }

  Future<void> _openEtymologyMemoryPage() async {
    final CardWordSemanticDetilsEntity detils = widget.controller.cardDetils.value;
    final int? contentId = detils.contentId;
    final String contentType = (detils.contentType ?? '').trim();
    final int semanticId = widget.controller.currentSemanticId.value;
    if (contentId == null || contentType.isEmpty || semanticId <= 0) {
      ToastUtils.showToast(text: '缺少跳转参数');
      return;
    }
    await TagRoutes.toNamed(
      Routes.ETYMOLOGY_MEMORY,
      tagText: '${widget.controller.tagText}_etymology',
      arguments: <String, dynamic>{
        'contentType': contentType,
        'contentId': contentId,
        'semanticId': semanticId,
      },
    );
  }

  Future<void> _openInflectionDetailsPage(
    CardWordAnalysisGrammarData? grammar, {
    int? contentId,
  }) async {
    final String familyKey = (grammar?.familyKey ?? '').trim();
    final int? routeContentId = contentId ?? widget.controller.cardDetils.value.contentId ?? widget.controller.contentId;
    final int semanticId = widget.controller.currentSemanticId.value;
    if (familyKey.isEmpty || routeContentId == null || semanticId <= 0) {
      ToastUtils.showToast(text: '缺少语法参数');
      return;
    }
    final Map<String, dynamic> arguments = <String, dynamic>{
      'contentId': routeContentId,
      'familyKey': familyKey,
      'semanticId': semanticId,
      'isUserSide': true,
    };
    debugPrint(
      'MANAGE_WORD_INFLECTION_DETAILS arguments: $arguments',
    );
    await TagRoutes.toNamed(
      Routes.MANAGE_WORD_INFLECTION_DETAILS,
      arguments: arguments,
      tagText: '${widget.controller.tagText}_inflection_$familyKey',
    );
  }

  Widget _buildSentencePreview(CardWordAnalysisListData? data) {
    return _buildPreviewList(
      items: data?.previewList?.whereType<CardWordAnalysisPreviewItem>().toList() ?? <CardWordAnalysisPreviewItem>[],
      emptyText: '暂无数据',
    );
  }

  Widget _buildPhrasePreview(CardWordAnalysisListData? data) {
    return _buildPreviewList(
      items: data?.previewList?.whereType<CardWordAnalysisPreviewItem>().toList() ?? <CardWordAnalysisPreviewItem>[],
      emptyText: '暂无数据',
      useGlossZh: true,
    );
  }

  Widget _buildPreviewList({
    required List<CardWordAnalysisPreviewItem> items,
    required String emptyText,
    bool useGlossZh = false,
  }) {
    if (items.isEmpty) {
      return ElementsAnalysisEmptyState(text: emptyText);
    }

    return Builder(
      builder: (context) {
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(20.wMin, 0, 20.wMin, 16.wMin),
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(
              height: 16.wMin,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 140.wMin,
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    dashPattern: [6.wMin, 4.wMin],
                    color: AppTheme.cBorderTertiary,
                    strokeWidth: 1.wMin,
                    customPath: (size) => Path()
                      ..moveTo(0, size.height)
                      ..relativeLineTo(size.width, 0),
                    padding: EdgeInsets.zero,
                    child: SizedBox(height: 1.wMin),
                  ),
                ),
              ),
            ),
            itemBuilder: (_, index) {
              final CardWordAnalysisPreviewItem item = items[index];
              final String definition = useGlossZh ? _findPreviewItemGlossZh(item.gloss) : item.definition ?? '';
              final bool canShowTranslate = definition.isNotEmpty;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPreviewContentLine(item),
                  if (canShowTranslate) ...[
                    SizedBox(height: 8.wMin),
                    Text(
                      definition,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextPrimary.color.withValues(alpha: 0.6),
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPreviewContentLine(CardWordAnalysisPreviewItem item) {
    final List<String> previewForms = widget.controller.cardDetils.value.analysisData?.grammar?.previewForms
            ?.whereType<String>()
            .where((String value) => value.isNotEmpty)
            .toList() ??
        <String>[];
    final Color highlightColor = _resolveHighlightColor();
    final List<InlineSpan> spans = _buildHighlightSpans(
      item.content ?? '',
      previewForms,
      highlightColor,
    );
    final List<PronunciationsEntity> pronunciations =
        item.pronunciations?.whereType<PronunciationsEntity>().toList() ?? <PronunciationsEntity>[];

    if (pronunciations.isEmpty) {
      return Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary,
            height: 1.5,
          ),
          children: spans,
        ),
      );
    }

    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 24.wMin,
          fontWeight: FontWeight.w600,
          color: AppTheme.cTextPrimary,
          height: 1.5,
        ),
        children: [
          ...spans,
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: SizedBox(width: 8.wMin),
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _buildPronunciationGroup(pronunciations),
          ),
        ],
      ),
    );
  }

  String _findPreviewItemGlossZh(List<LanguageText?>? texts) {
    if (texts == null || texts.isEmpty) return '';
    for (final LanguageText? item in texts) {
      if ((item?.lang ?? '').toLowerCase() == 'zh' && (item?.text ?? '').isNotEmpty) {
        return item!.text!;
      }
    }
    return '';
  }

  Widget _buildPronunciationGroup(List<PronunciationsEntity> pronunciations) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: pronunciations.take(2).map((pronunciation) {
        return Padding(
          padding: EdgeInsets.only(right: 6.wMin),
          child: _buildPronunciationButton(pronunciation),
        );
      }).toList(),
    );
  }

  Widget _buildPronunciationButton(PronunciationsEntity pronunciation) {
    final String audioUrl = pronunciation.audioUrl ?? '';
    return ElementsPronunciationCapsuleButton(
      label: _resolvePronunciationLabel(pronunciation),
      isSelected: false,
      isPlaying: audioUrl.isNotEmpty && _playingAudioUrls.contains(audioUrl),
      onTap: () async {
        if (audioUrl.isEmpty) return;
        if (mounted) {
          setState(() {
            _playingAudioUrls.add(audioUrl);
          });
        }
        try {
          await PlaybackInterlockUtils.instance.playSharedAudio(audioUrl);
        } finally {
          if (mounted) {
            setState(() {
              _playingAudioUrls.remove(audioUrl);
            });
          }
        }
      },
    );
  }

  String _resolvePronunciationLabel(PronunciationsEntity pronunciation) {
    final String national = (pronunciation.national ?? '').trim().toUpperCase();
    if (national.isNotEmpty) return national;
    return (pronunciation.nationalTitle ?? '').contains('英') ? 'UK' : 'US';
  }

  Widget _buildMemoryPreview(CardWordSemanticDetilsEntity detils) {
    final ConfigController configController = Get.find<ConfigController>();
    final CardWordAnalysisMemoryData? memory = detils.analysisData?.memory;
    if (memory == null) {
      return const ElementsAnalysisEmptyState(text: '暂无词源记忆');
    }

    final String coreText = _findLanguageText(memory.coreText, configController.userSetting.value.localLang);
    final String memoryDescriptionText = _findLanguageText(memory.descriptions, configController.userSetting.value.localLang);
    final String descriptionText =
        memoryDescriptionText.isNotEmpty ? memoryDescriptionText : _findLanguageText(memory.gloss, configController.userSetting.value.localLang);
    final List<String> branchTexts =
        (memory.branchTexts?.whereType<CardWordAnalysisMemoryBranchText>().toList() ?? <CardWordAnalysisMemoryBranchText>[])
            .map((item) => _findLanguageText(item.text, configController.userSetting.value.localLang))
            .where((text) => text.isNotEmpty)
            .toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(20.wMin, 0, 20.wMin, 16.wMin),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          ZxEtymologyMiniTreeWidget(
                headword: detils.content ?? '',
                title: coreText,
                branches: branchTexts,
              ),
          if (descriptionText.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 16.wMin),
              child: Text(
                descriptionText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFontValue.sourceHanSerifCN,
                  fontSize: 16.wMin,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSemanticTabBar(List<CardWordSemanticItem> filteredItems) {
    final List<String> allPos = _allPosList();
    final int currentSemanticId = widget.controller.currentSemanticId.value;
    final CardWordSemanticItem? currentSemanticItem =
        widget.controller.semanticItems.firstWhereOrNull((CardWordSemanticItem e) => e.semanticId == currentSemanticId);
    final ThemeTextStyleEntity? currentThemeText = StyleUtils.getCurrentThemeText(currentSemanticItem?.textStyle);
    final Color? filterColor = ColorUtils.parseColor(currentThemeText?.backgroundColor);
    final List<SemanticChipData> chips = filteredItems
        .where((item) => item.semanticId != null)
        .map((item) => SemanticChipData(
              id: item.semanticId!,
              pos: (item.posTitle?.isNotEmpty ?? false) ? item.posTitle?.first?.text : item.posAddr,
              text: item.translate ?? '',
              textStyle: item.textStyle,
            ))
        .toList();
    final bool isFiltered = _selectedPoses.isNotEmpty && _selectedPoses.length < allPos.length;
    final List<String> activeFilterLabels = isFiltered ? _selectedPosLabels() : const <String>[];

    return ElementsSemanticBottomBar(
      items: chips,
      currentId: currentSemanticId,
      showFilter: allPos.length > 1,
      isFiltered: isFiltered,
      filterColor: filterColor,
      activeFilterLabels: activeFilterLabels,
      onTapFilter: (BuildContext ctx) {
        _showPosSelectorDialog(ctx);
      },
      onRemoveFilter: _removeSelectedPos,
      onResetFilters: () => _applySelectedPoses(<String>{}),
      onTapItem: (int id) => widget.controller.switchSemantic(id),
    );
  }

  List<CardWordSemanticItem> _filteredSemanticItems() {
    final List<CardWordSemanticItem> all = widget.controller.semanticItems;
    if (_selectedPoses.isEmpty) return all;
    return all.where((CardWordSemanticItem e) => _selectedPoses.contains(e.pos ?? '')).toList();
  }

  List<String> _allPosList() {
    final Set<String> seen = <String>{};
    final List<String> result = <String>[];
    for (final CardWordSemanticItem item in widget.controller.semanticItems) {
      final String pos = item.pos ?? '';
      if (pos.isNotEmpty && seen.add(pos)) result.add(pos);
    }
    return result;
  }

  String _posDisplayText(String pos) {
    final CardWordSemanticItem? item = widget.controller.semanticItems.firstWhereOrNull((CardWordSemanticItem e) => e.pos == pos);
    if (item == null) return pos;
    final List<LanguageText?> titles = item.posTitle ?? <LanguageText?>[];
    final LanguageText? local = LearningLangUtils.getLocalLang(titles);
    if ((local?.text ?? '').isNotEmpty) return local!.text!;
    final LanguageText? learning = LearningLangUtils.getLearningLang(titles);
    if ((learning?.text ?? '').isNotEmpty) return learning!.text!;
    return item.posAddr ?? pos;
  }

  void _syncSelectedPosWithCurrentSemantic() {
    final List<String> allPos = _allPosList();
    if (allPos.isEmpty) {
      _selectedPoses.clear();
      return;
    }
    _selectedPoses.removeWhere((e) => !allPos.contains(e));
  }

  String _posDialogTitle(String pos) {
    final CardWordSemanticItem? item = widget.controller.semanticItems.firstWhereOrNull((CardWordSemanticItem e) => e.pos == pos);
    if (item == null) return pos;
    final List<LanguageText?> titles = item.posTitle ?? <LanguageText?>[];
    final String short = titles.isNotEmpty ? (titles[0]?.text ?? '') : '';
    final String long = titles.length > 1 ? (titles[1]?.text ?? '') : '';
    final String title = '$short$long'.trim();
    if (title.isNotEmpty) return title;
    return item.posAddr ?? pos;
  }

  List<String> _selectedPosLabels() {
    return _selectedPoses.map(_posDisplayText).toList();
  }

  Future<void> _applySelectedPoses(Set<String> values) async {
    final List<String> allPos = _allPosList();
    final Set<String> normalized = values.where(allPos.contains).toSet();
    if (normalized.length == allPos.length) {
      normalized.clear();
    }
    if (_selectedPoses.length == normalized.length && _selectedPoses.containsAll(normalized)) {
      return;
    }
    setState(() {
      _selectedPoses
        ..clear()
        ..addAll(normalized);
    });
    if (_selectedPoses.isEmpty) return;
    final int currentId = widget.controller.currentSemanticId.value;
    final CardWordSemanticItem? currentSemanticItem =
        widget.controller.semanticItems.firstWhereOrNull((CardWordSemanticItem e) => e.semanticId == currentId);
    if (_selectedPoses.contains(currentSemanticItem?.pos ?? '')) return;
    final CardWordSemanticItem? firstItem =
        widget.controller.semanticItems.firstWhereOrNull((CardWordSemanticItem e) => _selectedPoses.contains(e.pos ?? ''));
    if (firstItem?.semanticId == null) return;
    await widget.controller.switchSemantic(firstItem!.semanticId!);
  }

  Future<void> _showPosSelectorDialog(BuildContext anchorContext) async {
    final List<String> allPos = _allPosList();
    if (allPos.length <= 1) return;
    final int currentId = widget.controller.currentSemanticId.value;
    final CardWordSemanticItem? currentSemanticItem =
        widget.controller.semanticItems.firstWhereOrNull((CardWordSemanticItem e) => e.semanticId == currentId);
    final ThemeTextStyleEntity? currentThemeText = StyleUtils.getCurrentThemeText(currentSemanticItem?.textStyle);
    final Map<String, FilterConditionsData> result = await FilterStripUtils.showCondition(
          context: anchorContext,
          conditionsData: {
            'pos': FilterConditionsData(
              title: '词性',
              isSingle: false,
              color: ColorUtils.parseColor(currentThemeText?.backgroundColor),
              conditions: allPos.map((String value) {
                return FilterConditionsItem(
                  name: _posDialogTitle(value),
                  value: value,
                  selected: _selectedPoses.contains(value),
                );
              }).toList(),
            ),
          },
          scrollConditionKey: 'pos',
        ) ??
        <String, FilterConditionsData>{};
    if (!mounted || result.isEmpty) return;
    final Set<String> selectedValues =
        result['pos']?.conditions.where((e) => e.selected).map((e) => e.value?.toString() ?? '').where((e) => e.isNotEmpty).toSet() ??
            <String>{};
    await _applySelectedPoses(selectedValues);
  }

  Future<void> _removeSelectedPos(String label) async {
    String? value;
    for (final String item in _selectedPoses) {
      if (_posDisplayText(item) == label) {
        value = item;
        break;
      }
    }
    if (value == null) return;
    final Set<String> next = Set<String>.from(_selectedPoses)..remove(value);
    await _applySelectedPoses(next);
  }

  CardWordAnalysisEntry? _findAnalysisEntry(String type) {
    final List<CardWordAnalysisEntry> entries =
        widget.controller.cardDetils.value.analysisEntries?.whereType<CardWordAnalysisEntry>().toList() ?? <CardWordAnalysisEntry>[];
    for (final CardWordAnalysisEntry entry in entries) {
      if (entry.type == type) {
        return entry;
      }
    }
    return null;
  }

  String _resolvePosText(CardWordSemanticItem? item) {
    if (item == null) return '';
    final String chinese = _findLanguageText(item.posTitle, 'zh');
    if (chinese.isNotEmpty) return chinese;
    final String english = _findLanguageText(item.posTitle, 'en');
    if (english.isNotEmpty) return english;
    if ((item.posAddr ?? '').isNotEmpty) return item.posAddr!;
    return item.pos ?? '';
  }

  List<_WordTagConfig> _resolveGrammaticalTypeTags(
    CardWordSemanticItem? item,
    ConfigController configController,
  ) {
    final List<String> codes = item?.grammaticalTypeNids?.whereType<String>().where((item) => item.isNotEmpty).toList() ?? <String>[];
    if (codes.isEmpty) return const <_WordTagConfig>[];
    final List<LanguageConfigColorEntityInfo> configs =
        configController.colorConfigs.value.grammaticalTypes?.whereType<LanguageConfigColorEntityInfo>().toList() ??
            <LanguageConfigColorEntityInfo>[];
    final List<_WordTagConfig> tags = [];
    for (final String code in codes) {
      LanguageConfigColorEntityInfo? config;
      for (final LanguageConfigColorEntityInfo item in configs) {
        if ((item.code ?? '').toLowerCase() == code.toLowerCase()) {
          config = item;
          break;
        }
      }
      final String label = config?.title ?? '';
      if (label.isEmpty) continue;
      final Color color = ColorUtils.parseColor(config?.color?.borderColor) ?? AppTheme.cTextPrimary.color;
      tags.add(_WordTagConfig(code: code, label: label, color: color));
    }
    return tags;
  }

  String _findLanguageText(List<LanguageText?>? texts, String lang) {
    if (texts == null || texts.isEmpty) return '';
    for (final LanguageText? item in texts) {
      if ((item?.lang ?? '').toLowerCase() == lang && (item?.text ?? '').isNotEmpty) {
        return item!.text!;
      }
    }
    for (final LanguageText? item in texts) {
      if ((item?.text ?? '').isNotEmpty) {
        return item!.text!;
      }
    }
    return '';
  }

  Color _resolveHighlightColor() {
    final ThemeTextStyleEntity? style = StyleUtils.getCurrentThemeText(widget.controller.findCurrentSemanticItem()?.textStyle);
    return ColorUtils.parseColor(style?.borderColor) ?? ColorUtils.parseColor(style?.backgroundColor) ?? AppTheme.cTextBrand.color;
  }

  List<InlineSpan> _buildHighlightSpans(
    String text,
    List<String> forms,
    Color highlightColor,
  ) {
    if (text.isEmpty) {
      return const <InlineSpan>[];
    }

    final List<String> needles = forms.map((item) => item.trim()).where((item) => item.isNotEmpty).toSet().toList()
      ..sort((a, b) {
        final int lengthCompare = b.length.compareTo(a.length);
        if (lengthCompare != 0) return lengthCompare;
        return a.compareTo(b);
      });

    if (needles.isEmpty) {
      return <InlineSpan>[TextSpan(text: text)];
    }

    final List<_HighlightRange> ranges = [];
    final String lowerText = text.toLowerCase();

    for (final String needle in needles) {
      final String lowerNeedle = needle.toLowerCase();
      int start = 0;
      while (start < lowerText.length) {
        final int index = lowerText.indexOf(lowerNeedle, start);
        if (index < 0) break;
        final int end = index + lowerNeedle.length;
        if (_isTokenBounded(text, index, end) && !_isOverlapping(ranges, index, end)) {
          ranges.add(_HighlightRange(start: index, end: end));
        }
        start = index + 1;
      }
    }

    if (ranges.isEmpty) {
      return <InlineSpan>[TextSpan(text: text)];
    }

    ranges.sort((a, b) => a.start.compareTo(b.start));
    final List<InlineSpan> spans = [];
    int current = 0;
    for (final _HighlightRange range in ranges) {
      if (range.start > current) {
        spans.add(TextSpan(text: text.substring(current, range.start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(range.start, range.end),
          style: TextStyle(
            color: highlightColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      current = range.end;
    }
    if (current < text.length) {
      spans.add(TextSpan(text: text.substring(current)));
    }
    return spans;
  }

  bool _isTokenBounded(String text, int start, int end) {
    final RegExp tokenRegExp = RegExp(r"[A-Za-z0-9']");
    final bool leftOk = start == 0 || !tokenRegExp.hasMatch(text[start - 1]);
    final bool rightOk = end >= text.length || !tokenRegExp.hasMatch(text[end]);
    return leftOk && rightOk;
  }

  bool _isOverlapping(List<_HighlightRange> ranges, int start, int end) {
    for (final _HighlightRange range in ranges) {
      if (start < range.end && end > range.start) {
        return true;
      }
    }
    return false;
  }

  LanguageConfigColorEntityInfo? _findMorphologyTypeConfig(
    LanguageConfigColorEntity configs,
    String? code,
  ) {
    if ((code ?? '').isEmpty) return null;
    for (final LanguageConfigColorEntityInfo item
        in (configs.morphemeTypes ?? <LanguageConfigColorEntityInfo?>[]).whereType<LanguageConfigColorEntityInfo>()) {
      if ((item.code ?? '').toLowerCase() == code!.toLowerCase()) {
        return item;
      }
    }
    return null;
  }

  _MorphologyTagStyle _buildMorphologyTagStyle(LanguageConfigColorEntityInfo? config) {
    final LanguageConfigColorEntityThemeColors? themeColors = StatusUtils.resolveThemeColors(config);
    final Color? textColor = themeColors?.textColorC ?? themeColors?.colorC;
    final Color? bgColor = themeColors?.backgroundColorC;
    final Color? borderColor = themeColors?.borderColorC;
    if (textColor == null && bgColor == null && borderColor == null) {
      return _MorphologyTagStyle(
        textColor: AppTheme.cTextSecondary.color,
        bgColor: AppTheme.cSurfaceTranslucentBase.color,
        borderColor: AppTheme.cBorderTranslucentThin.color,
      );
    }
    return _MorphologyTagStyle(
      textColor: textColor ?? AppTheme.cTextSecondary.color,
      bgColor: bgColor ?? (textColor ?? AppTheme.cTextSecondary.color).withValues(alpha: 0.12),
      borderColor: borderColor ?? (textColor ?? AppTheme.cTextSecondary.color).withValues(alpha: 0.20),
    );
  }

  double _resolveMorphologyContentFontSize({
    required List<CardWordMorphologyPreviewComponent> components,
    required LanguageConfigColorEntity configs,
    required double maxWidth,
    required double titleFontSize,
    required double contentMaxFontSize,
    required double contentMinFontSize,
    required double itemSpacing,
    required double itemPadding,
    required double headerSpacing,
    required double itemBorderWidth,
    required double textSafetyWidth,
  }) {
    if (components.isEmpty || !maxWidth.isFinite) return contentMaxFontSize;
    final double maxTotalWidth = _measureMorphologyTotalWidth(
      components: components,
      configs: configs,
      titleFontSize: titleFontSize,
      contentFontSize: contentMaxFontSize,
      itemSpacing: itemSpacing,
      itemPadding: itemPadding,
      headerSpacing: headerSpacing,
      itemBorderWidth: itemBorderWidth,
      textSafetyWidth: textSafetyWidth,
    );
    if (maxTotalWidth <= maxWidth) return contentMaxFontSize;

    double low = contentMinFontSize;
    double high = contentMaxFontSize;
    for (int i = 0; i < 12; i++) {
      final double middle = (low + high) / 2;
      final double totalWidth = _measureMorphologyTotalWidth(
        components: components,
        configs: configs,
        titleFontSize: titleFontSize,
        contentFontSize: middle,
        itemSpacing: itemSpacing,
        itemPadding: itemPadding,
        headerSpacing: headerSpacing,
        itemBorderWidth: itemBorderWidth,
        textSafetyWidth: textSafetyWidth,
      );
      if (totalWidth <= maxWidth) {
        low = middle;
      } else {
        high = middle;
      }
    }
    return low;
  }

  double _measureMorphologyTotalWidth({
    required List<CardWordMorphologyPreviewComponent> components,
    required LanguageConfigColorEntity configs,
    required double titleFontSize,
    required double contentFontSize,
    required double itemSpacing,
    required double itemPadding,
    required double headerSpacing,
    required double itemBorderWidth,
    required double textSafetyWidth,
  }) {
    double totalWidth = 0;
    for (int index = 0; index < components.length; index++) {
      final CardWordMorphologyPreviewComponent component = components[index];
      final LanguageConfigColorEntityInfo? typeConfig = _findMorphologyTypeConfig(
        configs,
        component.type,
      );
      totalWidth += _measureMorphologyItemWidth(
        component: component,
        index: index,
        typeConfig: typeConfig,
        titleFontSize: titleFontSize,
        contentFontSize: contentFontSize,
        itemPadding: itemPadding,
        headerSpacing: headerSpacing,
        itemBorderWidth: itemBorderWidth,
        textSafetyWidth: textSafetyWidth,
      );
      if (index < components.length - 1) totalWidth += itemSpacing;
    }
    return totalWidth;
  }

  double _measureMorphologyItemWidth({
    required CardWordMorphologyPreviewComponent component,
    required int index,
    required LanguageConfigColorEntityInfo? typeConfig,
    required double titleFontSize,
    required double contentFontSize,
    required double itemPadding,
    required double headerSpacing,
    required double itemBorderWidth,
    required double textSafetyWidth,
  }) {
    final double headerWidth = _measureTextWidth(typeConfig?.title ?? '', titleFontSize) +
        headerSpacing +
        _measureTextWidth('${index + 1}', titleFontSize) +
        textSafetyWidth;
    final double contentWidth = _measureTextWidth(component.content ?? '', contentFontSize) + textSafetyWidth;
    return (headerWidth > contentWidth ? headerWidth : contentWidth) + itemPadding * 2 + itemBorderWidth * 2;
  }

  double _measureTextWidth(String text, double fontSize) {
    if (text.isEmpty) return 0;
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }
}

class _WordImagePanel extends StatelessWidget {
  final String? imageUrl;
  final EnKnowledgeEntityRelationVideo? relationVideo;
  final List<PronunciationsEntity?>? pronunciations;
  final String semanticPlaybackKey;

  const _WordImagePanel({
    required this.imageUrl,
    this.relationVideo,
    this.pronunciations,
    required this.semanticPlaybackKey,
  });

  @override
  Widget build(BuildContext context) {
    return ElementsSemanticVideoCardWidget(
      imageUrl: imageUrl,
      relationVideo: relationVideo,
      pronunciations: pronunciations,
      semanticPlaybackKey: semanticPlaybackKey,
      size: double.infinity,
      showPronunciationOverlay: false,
    );
  }
}

class _HighlightRange {
  final int start;
  final int end;

  const _HighlightRange({
    required this.start,
    required this.end,
  });
}

class _MorphologyTagStyle {
  final Color textColor;
  final Color bgColor;
  final Color borderColor;

  const _MorphologyTagStyle({
    required this.textColor,
    required this.bgColor,
    required this.borderColor,
  });
}

class _WordTagConfig {
  final String code;
  final String label;
  final Color color;

  const _WordTagConfig({
    required this.code,
    required this.label,
    required this.color,
  });
}
