import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/filter_widgets.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/common/widgets/zhenxie_widgets/word_inflection_info_tag_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/widgets/simple_dictionary_dialog.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/tag_routes.dart';
import '../../common/elements_analysis_cards_widget.dart';
import '../../common/elements_memory_action_button.dart';
import '../../common/elements_public_widgets.dart';
import '../../dictionary/controllers/dictionary_controller.dart';
import '../controllers/elements_word_detils_controller.dart';

class ElementsWordDetilsContentWidget extends StatefulWidget {
  final ElementsWordDetilsController controller;

  const ElementsWordDetilsContentWidget({
    super.key,
    required this.controller,
  });

  @override
  State<ElementsWordDetilsContentWidget> createState() =>
      _ElementsWordDetilsContentWidgetState();
}

class _ElementsWordDetilsContentWidgetState
    extends State<ElementsWordDetilsContentWidget> {
  final Set<String> _selectedPoses = <String>{};
  final Set<String> _playingAudioUrls = <String>{};
  bool _hasHandledInitialModuleJump = false;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      _syncSelectedPosWithCurrentSemantic();
      if (widget.controller.currentSemantic.value.uid == null &&
          widget.controller.semanticItems.isEmpty) {
        return const SizedBox.shrink();
      }

      final CardWordSemanticDetilsEntity detils =
          widget.controller.cardDetils.value;
      final CardWordDetilsEntityPosListSemantics semantic =
          widget.controller.currentSemantic.value;
      _tryHandleInitialModuleJump(detils);

      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLeftPanel(detils, semantic),
          SizedBox(width: 24.wMin),
          Expanded(
            child: _buildRightPanel(detils, semantic),
          ),
        ],
      );
    });
  }

  Widget _buildLeftPanel(
    CardWordSemanticDetilsEntity detils,
    CardWordDetilsEntityPosListSemantics semantic,
  ) {
    final CardWordMorphologyPreview? morphologyPreview = detils.morphologyPreview;
    final List<CardWordMorphologyPreviewComponent> components = morphologyPreview?.components
            ?.whereType<CardWordMorphologyPreviewComponent>()
            .toList() ??
        <CardWordMorphologyPreviewComponent>[];

    return SizedBox(
      width: 510.wMin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 510.wMin,
            height: 510.wMin,
            child: _WordImagePanel(
              imageUrl: semantic.imageUrl,
              relationVideo: semantic.video,
              pronunciations: semantic.pronunciations,
              semanticPlaybackKey: '${detils.contentId ?? 0}_${semantic.uid ?? 0}',
            ),
          ),
          SizedBox(height: 12.wMin),
          ElementsPronunciationModuleWidget(
            pronunciations: semantic.pronunciations,
            contentType: detils.contentType,
            contentId: detils.contentId,
            content: detils.content,
              showPronunciationHeader: false,
              useGlobalPronunciationSetting: true,
          ),
          if (components.isNotEmpty) ...[
            SizedBox(height: 12.wMin),
            _buildMorphologyPreview(morphologyPreview!),
          ],
        ],
      ),
    );
  }

  Widget _buildMorphologyPreview(CardWordMorphologyPreview morphologyPreview) {
    final List<CardWordMorphologyPreviewComponent> components = morphologyPreview.components
            ?.whereType<CardWordMorphologyPreviewComponent>()
            .toList() ??
        <CardWordMorphologyPreviewComponent>[];
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
              Text(
                '构词',
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary,
                ),
              ),
              SizedBox(height: 12.wMin),
              Row(
                spacing: 8.wMin,
                children: components.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final CardWordMorphologyPreviewComponent component = entry.value;
                  final _MorphologyTagStyle style = _resolveMorphologyTagStyle(component.type);
                  return Container(
                    width: 120.wMin,
                    padding: EdgeInsets.all(6.wMin),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _resolveMorphologyTypeText(component.type),
                              style: TextStyle(
                                fontSize: 18.wMin,
                                fontWeight: FontWeight.w400,
                                color: style.textColor,
                              ),
                            ),
                            Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 18.wMin,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.cTextTertiary.color,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: AutoSizeText(
                            component.content ?? '',
                            maxLines: 1,
                            minFontSize: 6,
                            stepGranularity: 0.1,
                            style: TextStyle(
                              fontSize: 36.wMin,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.cTextPrimary.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightPanel(
    CardWordSemanticDetilsEntity detils,
    CardWordDetilsEntityPosListSemantics semantic,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDescriptionRow(semantic),
        SizedBox(height: 20.wMin),
        Expanded(
          child: _buildAnalysisArea(detils),
        ),
      if (widget.controller.semanticItems.isNotEmpty) ...[
          SizedBox(height: 16.wMin),
        _buildSemanticTabBar(_filteredSemanticItems()),
        ],
      ],
    );
  }

  Widget _buildDescriptionRow(CardWordDetilsEntityPosListSemantics semantic) {
    final ConfigController configController = Get.find<ConfigController>();
    final LangPreference rawPreference = configController.userSetting.value.expandLang;
    final LangPreference preference = rawPreference == LangPreference.none
        ? LangPreference.original
        : rawPreference == LangPreference.translation
            ? LangPreference.bilingual
            : rawPreference;
    final bool showOriginal = preference != LangPreference.translation;
    final bool showTranslate = preference == LangPreference.bilingual || preference == LangPreference.translation;
    final String english = _findLanguageText(semantic.descriptions, configController.userSetting.value.learningLang);
    final String chinese = _findLanguageText(semantic.descriptions, configController.userSetting.value.localLang);
    final bool favorited = widget.controller.isCurrentSemanticFavorited();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showOriginal && english.isNotEmpty)
                Builder(
                  builder: (context) {
                    final CardWordSemanticItem? item = widget.controller.findCurrentSemanticItem();
                    final ThemeTextStyleEntity? style = StyleUtils.getCurrentThemeText(item?.textStyle);
                    final String posText = _resolvePosText(item);
                    final List<InlineSpan> spans = [
                      TextSpan(text: english),
                    ];
                    if (posText.isNotEmpty) {
                      spans.add(
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.wMin),
                            child: WordInflectionInfoTagWidget(
                              posText,
                              textColor: ColorUtils.parseColor(style?.borderColor) ?? AppTheme.cTextPrimary.color,
                              bgColor: ColorUtils.parseColor(style?.borderColor)?.withValues(alpha: 0.12) ?? AppTheme.cSurfaceTranslucentBase.color,
                              borderColor: ColorUtils.parseColor(style?.borderColor)?.withValues(alpha: 0.20) ?? AppTheme.cBorderTranslucentThin.color,
                            ),
                          ),
                        ),
                      );
                    }
                    if (semantic.difficulty != null) {
                      final ConfigEntity configEntity = configController.appConfig.value;
                      final DifficultieEntity? currentDifficulty = DifficultieUtils.getLanguageDifficultieLevel(
                        configEntity,
                        configController.userSetting.value.learningLang,
                        semantic.difficulty,
                      );
                      if (currentDifficulty != null) {
                        final Color color = StatusUtils.getDifficultyBackgroundColor(semantic.difficulty).color1;
                        spans.add(
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.only(left: 8.wMin),
                              child: WordInflectionInfoTagWidget(
                                currentDifficulty.name?.text ?? "",
                                textColor: color,
                                bgColor: color.withValues(alpha: 0.12),
                                borderColor: color.withValues(alpha: 0.20),
                              ),
                            ),
                          ),
                        );
                      }
                    }
                    return Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 28.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cTextPrimary,
                          height: 1.4,
                        ),
                        children: spans,
                      ),
                    );
                  },
                ),
              if (showTranslate && chinese.isNotEmpty) ...[
                SizedBox(height: 8.wMin),
                Text(
                  chinese,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 16.wMin),
        SizedBox(
          width: 180.wMin,
          child: _buildMemoryButton(favorited),
        ),
      ],
    );
  }

  Widget _buildMemoryButton(bool favorited) {
    return ElementsMemoryActionButton(
      favorited: favorited,
      onTap: _handleMemoryAction,
      color: AppTheme.cMorphemeCardColor1.color,
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

  Widget _buildAnalysisArea(CardWordSemanticDetilsEntity detils) {
    final List<ElementsAnalysisCardLayoutItem> topCards = [];
    final List<ElementsAnalysisCardLayoutItem> bottomCards = [];

    final CardWordAnalysisEntry? sentenceEntry = _findAnalysisEntry('sentence');
    if (_shouldShowAnalysisCard(sentenceEntry)) {
      topCards.add(
        ElementsAnalysisCardLayoutItem(
          flex: 1,
          child: _buildAnalysisCard(
            sentenceEntry!,
            _buildSentencePreview(detils.analysisData?.sentences),
              onTap: () => _openAnalysisCardsPage(sentenceEntry),
          ),
        ),
      );
    }

    final CardWordAnalysisEntry? memoryEntry = _findAnalysisEntry('memory');
    if (_shouldShowAnalysisCard(memoryEntry)) {
      topCards.add(
        ElementsAnalysisCardLayoutItem(
          flex: 1,
          child: _buildAnalysisCard(
            memoryEntry!,
            _buildMemoryPreview(detils),
              onTap: _openEtymologyMemoryPage,
          ),
        ),
      );
    }

    final CardWordAnalysisEntry? phraseEntry = _findAnalysisEntry('phrase');
    if (_shouldShowAnalysisCard(phraseEntry)) {
      bottomCards.add(
        ElementsAnalysisCardLayoutItem(
          flex: 2,
          child: _buildAnalysisCard(
            phraseEntry!,
            _buildPhrasePreview(detils.analysisData?.phrases),
              onTap: () => _openAnalysisCardsPage(phraseEntry),
          ),
        ),
      );
    }

    final CardWordAnalysisEntry? grammarEntry = _findAnalysisEntry('grammar');
    if (_shouldShowAnalysisCard(grammarEntry)) {
      bottomCards.add(
        ElementsAnalysisCardLayoutItem(
          flex: 1,
          child: _buildAnalysisCard(
            grammarEntry!,
            _buildGrammarPreview(detils.analysisData?.grammar),
              onTap: () => _openInflectionDetailsPage(detils.analysisData?.grammar),
          ),
        ),
      );
    }

    final CardWordAnalysisEntry? synonymEntry = _findAnalysisEntry('synonym');
    if (_shouldShowAnalysisCard(synonymEntry)) {
      bottomCards.add(
        ElementsAnalysisCardLayoutItem(
          flex: 1,
          child: _buildAnalysisCard(
            synonymEntry!,
            _buildSynonymPreview(detils.analysisData?.synonyms),
              onTap: () => _openAnalysisCardsPage(synonymEntry),
          ),
        ),
      );
    }

    if (topCards.isEmpty && bottomCards.isEmpty) {
      return const ElementsAnalysisEmptyState(text: '暂无分析数据');
    }

    if (topCards.isNotEmpty && bottomCards.isNotEmpty) {
      return Column(
        children: [
          Expanded(
            child: ElementsAnalysisCardRow(items: topCards),
          ),
          SizedBox(height: 16.wMin),
          Expanded(
            child: ElementsAnalysisCardRow(items: bottomCards),
          ),
        ],
      );
    }

    final List<ElementsAnalysisCardLayoutItem> singleRow =
        topCards.isNotEmpty ? topCards : bottomCards;
    return ElementsAnalysisCardRow(items: singleRow);
  }

  Widget _buildAnalysisCard(
    CardWordAnalysisEntry entry,
    Widget child,
    {VoidCallback? onTap}
  ) {
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
          return WordInflectionInfoTagWidget(form);
        }).toList(),
      ),
    );
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
      await _openInflectionDetailsPage(detils.analysisData?.grammar);
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
          'isUserSide': true,
        },
        tagText: '${widget.controller.tagText}_morphology_root_$key',
      );
      return;
    }
    await TagRoutes.toNamed(
      Routes.MANAGE_WORD_MORPHOLOGY_TREE,
      arguments: <String, dynamic>{
        'key': key,
        'isUserSide': true,
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

  Future<void> _openInflectionDetailsPage(CardWordAnalysisGrammarData? grammar) async {
    final String familyKey = (grammar?.familyKey ?? '').trim();
    final int semanticId = widget.controller.currentSemanticId.value;
    if (familyKey.isEmpty || semanticId <= 0) {
      ToastUtils.showToast(text: '缺少语法参数');
      return;
    }
    await TagRoutes.toNamed(
      Routes.MANAGE_WORD_INFLECTION_DETAILS,
      arguments: <String, dynamic>{
        'familyKey': familyKey,
        'semanticId': semanticId,
        'isUserSide': true,
      },
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
    );
  }

  Widget _buildPreviewList({
    required List<CardWordAnalysisPreviewItem> items,
    required String emptyText,
  }) {
    final ConfigController configController = Get.find<ConfigController>();
    final LangPreference rawPreference = configController.userSetting.value.expandLang;
    final LangPreference preference = rawPreference == LangPreference.none
        ? LangPreference.original
        : rawPreference == LangPreference.translation
            ? LangPreference.bilingual
            : rawPreference;
    final bool showOriginal = preference != LangPreference.translation;
    final bool showTranslate = preference == LangPreference.bilingual || preference == LangPreference.translation;
    if (items.isEmpty) {
      return ElementsAnalysisEmptyState(text: emptyText);
    }

    return ListView.separated(
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
        final String definition = item.definition ?? '';
        final bool canShowTranslate = showTranslate && definition.isNotEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showOriginal || !canShowTranslate) _buildPreviewContentLine(item),
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
    final LangPreference rawPreference = configController.userSetting.value.expandLang;
    final LangPreference preference = rawPreference == LangPreference.none
        ? LangPreference.original
        : rawPreference == LangPreference.translation
            ? LangPreference.bilingual
            : rawPreference;
    final bool showOriginal = preference != LangPreference.translation;
    final bool showTranslate = preference == LangPreference.bilingual || preference == LangPreference.translation;
    final CardWordAnalysisMemoryData? memory = detils.analysisData?.memory;
    if (memory == null) {
      return const ElementsAnalysisEmptyState(text: '暂无词源记忆');
    }

    final String coreText = _findLanguageText(memory.coreText, configController.userSetting.value.localLang);
    final List<CardWordAnalysisMemoryBranchText> branchTexts =
        memory.branchTexts?.whereType<CardWordAnalysisMemoryBranchText>().toList() ?? <CardWordAnalysisMemoryBranchText>[];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.wMin, 0, 20.wMin, 16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showOriginal || (coreText.isEmpty && !showTranslate))
            Text(
              detils.content ?? '',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary,
              ),
            ),
          if (showTranslate && coreText.isNotEmpty) ...[
            SizedBox(height: 8.wMin),
            Text(
              coreText,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary,
                height: 1.5,
              ),
            ),
          ],
          if (showTranslate && branchTexts.isNotEmpty) ...[
            SizedBox(height: 12.wMin),
            Wrap(
              spacing: 8.wMin,
              runSpacing: 8.wMin,
              children: branchTexts.map((item) {
                return WordInflectionInfoTagWidget(
                  _findLanguageText(item.text, configController.userSetting.value.localLang),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSynonymPreview(CardWordAnalysisSynonymsData? data) {
    final int previewCount = data?.previewCount ?? 0;
    final String text = previewCount > 0 ? '$previewCount 个可换用的词。' : '暂无同义词。';
    return Padding(
      padding: EdgeInsets.fromLTRB(20.wMin, 0, 20.wMin, 16.wMin),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cTextTertiary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildSemanticTabBar(List<CardWordSemanticItem> filteredItems) {
    final List<String> allPos = _allPosList();
    final int currentSemanticId = widget.controller.currentSemanticId.value;
    final CardWordSemanticItem? currentSemanticItem = widget.controller.semanticItems
        .firstWhereOrNull(
            (CardWordSemanticItem e) => e.semanticId == currentSemanticId);
    final ThemeTextStyleEntity? currentThemeText =
        StyleUtils.getCurrentThemeText(currentSemanticItem?.textStyle);
    final Color? filterColor =
        ColorUtils.parseColor(currentThemeText?.backgroundColor);
    final List<SemanticChipData> chips = filteredItems
        .where((item) => item.semanticId != null)
        .map((item) => SemanticChipData(
              id: item.semanticId!,
              pos: (item.posTitle?.isNotEmpty ?? false)
                  ? item.posTitle?.first?.text
                  : item.posAddr,
              text: item.translate ?? '',
              textStyle: item.textStyle,
            ))
        .toList();
    final bool isFiltered =
        _selectedPoses.isNotEmpty && _selectedPoses.length < allPos.length;
    final List<String> activeFilterLabels =
        isFiltered ? _selectedPosLabels() : const <String>[];

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
    return all
        .where((CardWordSemanticItem e) => _selectedPoses.contains(e.pos ?? ''))
        .toList();
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
    final CardWordSemanticItem? item = widget.controller.semanticItems
        .firstWhereOrNull((CardWordSemanticItem e) => e.pos == pos);
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
    final CardWordSemanticItem? item = widget.controller.semanticItems
        .firstWhereOrNull((CardWordSemanticItem e) => e.pos == pos);
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
    if (_selectedPoses.length == normalized.length &&
        _selectedPoses.containsAll(normalized)) {
      return;
    }
    setState(() {
      _selectedPoses
        ..clear()
        ..addAll(normalized);
    });
    if (_selectedPoses.isEmpty) return;
    final int currentId = widget.controller.currentSemanticId.value;
    final CardWordSemanticItem? currentSemanticItem = widget.controller.semanticItems
        .firstWhereOrNull((CardWordSemanticItem e) => e.semanticId == currentId);
    if (_selectedPoses.contains(currentSemanticItem?.pos ?? '')) return;
    final CardWordSemanticItem? firstItem = widget.controller.semanticItems
        .firstWhereOrNull(
            (CardWordSemanticItem e) => _selectedPoses.contains(e.pos ?? ''));
    if (firstItem?.semanticId == null) return;
    await widget.controller.switchSemantic(firstItem!.semanticId!);
  }

  Future<void> _showPosSelectorDialog(BuildContext anchorContext) async {
    final List<String> allPos = _allPosList();
    if (allPos.length <= 1) return;
    final int currentId = widget.controller.currentSemanticId.value;
    final CardWordSemanticItem? currentSemanticItem = widget.controller.semanticItems
        .firstWhereOrNull((CardWordSemanticItem e) => e.semanticId == currentId);
    final ThemeTextStyleEntity? currentThemeText =
        StyleUtils.getCurrentThemeText(currentSemanticItem?.textStyle);
    final Map<String, FilterConditionsData> result =
            await FilterStripUtils.showCondition(
                  context: anchorContext,
                  conditionsData: {
                    'pos': FilterConditionsData(
                      title: '词性',
                      isSingle: false,
                      color:
                          ColorUtils.parseColor(currentThemeText?.backgroundColor),
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
    final Set<String> selectedValues = result['pos']?.conditions
            .where((e) => e.selected)
            .map((e) => e.value?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toSet() ??
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

  bool _shouldShowAnalysisCard(CardWordAnalysisEntry? entry) {
    return entry != null;
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

  _MorphologyTagStyle _resolveMorphologyTagStyle(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'prefix':
        return _MorphologyTagStyle(
          textColor: const Color(0xFF22D3EE),
          bgColor: const Color(0xFF22D3EE).withValues(alpha: 0.12),
          borderColor: const Color(0xFF22D3EE).withValues(alpha: 0.2),
        );
      case 'root':
        return _MorphologyTagStyle(
          textColor: const Color(0xFFF59E0B),
          bgColor: const Color(0xFFF59E0B).withValues(alpha: 0.12),
          borderColor: const Color(0xFFF59E0B).withValues(alpha: 0.2),
        );
      case 'suffix':
        return _MorphologyTagStyle(
          textColor: const Color(0xFFA855F7),
          bgColor: const Color(0xFFA855F7).withValues(alpha: 0.12),
          borderColor: const Color(0xFFA855F7).withValues(alpha: 0.2),
        );
      default:
        return _MorphologyTagStyle(
          textColor: AppTheme.cTextSecondary.color,
          bgColor: AppTheme.cSurfaceTranslucentBase.color,
          borderColor: AppTheme.cBorderTranslucentThin.color,
        );
    }
  }

  String _resolveMorphologyTypeText(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'prefix':
        return '前缀';
      case 'root':
        return '词根';
      case 'suffix':
        return '后缀';
      default:
        return '';
    }
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
