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
import '../../../../../common/widgets/zhenxie_widgets/phrase_enter_sentence_phrase_widget.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/tag_routes.dart';
import '../../common/elements_analysis_cards_widget.dart';
import '../../common/elements_memory_action_button.dart';
import '../../common/elements_public_widgets.dart';
import '../../dictionary/controllers/dictionary_controller.dart';
import '../controllers/elements_phrase_detils_controller.dart';

class ElementsPhraseDetilsContentWidget extends StatefulWidget {
  final ElementsPhraseDetilsController controller;

  const ElementsPhraseDetilsContentWidget({
    super.key,
    required this.controller,
  });

  @override
  State<ElementsPhraseDetilsContentWidget> createState() => _ElementsPhraseDetilsContentWidgetState();
}

class _ElementsPhraseDetilsContentWidgetState extends State<ElementsPhraseDetilsContentWidget> {
  final Set<String> _selectedPoses = <String>{};

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      _syncSelectedPosWithCurrentSemantic();
      if (widget.controller.currentSemantic.value.uid == null && widget.controller.semanticItems.isEmpty) {
        return const SizedBox.shrink();
      }

      final CardPhraseSemanticDetilsEntity detils = widget.controller.cardDetils.value;
      final CardPhraseSemantic semantic = widget.controller.currentSemantic.value;

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
    CardPhraseSemanticDetilsEntity detils,
    CardPhraseSemantic semantic,
  ) {
    return SizedBox(
      width: 510.wMin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 510.wMin,
            height: 510.wMin,
            child: ElementsSemanticVideoCardWidget(
              imageUrl: semantic.imageUrl,
              relationVideo: semantic.video,
              pronunciations: semantic.pronunciations,
              semanticPlaybackKey: '${detils.contentId ?? 0}_${semantic.uid ?? 0}',
              size: double.infinity,
              showPronunciationOverlay: false,
            ),
          ),
          SizedBox(height: 12.wMin),
          ElementsPhrasePronunciationWidget(
            pronunciations: semantic.pronunciations,
            contentType: detils.contentType,
            contentId: detils.contentId,
            content: detils.content,
          ),
          if (detils.structure != null) ...[
            SizedBox(height: 12.wMin),
            _buildStructureWidget(detils.structure),
          ],
        ],
      ),
    );
  }

  Widget _buildStructureWidget(CardPhraseStructure? structure) {
    if (structure == null) return const SizedBox.shrink();
    final List<CardPhraseStructureItem> items =
        structure.items?.whereType<CardPhraseStructureItem>().toList() ?? <CardPhraseStructureItem>[];
    final String explanation = _findZhOnlyText(structure.explanations);

    return TapScaleWidget(
      onTap: _openPhraseStructureDetailPage,
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
                '结构',
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary,
                ),
              ),
              SizedBox(height: 12.wMin),
              if (explanation.isNotEmpty) ...[
                Text(
                  explanation,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextSecondary,
                  ),
                ),
                SizedBox(height: 12.wMin),
              ],
              if (items.isNotEmpty)
                SizedBox(
                  height: 108.wMin,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final CardPhraseStructureItem item = items[index];
                      final _PhraseStructureRoleStyle style =
                          _resolveStructureRoleStyle(item.roleNid);

                      return Container(
                        margin: EdgeInsets.only(
                          right: index == items.length - 1 ? 0 : 8.wMin,
                        ),
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
                            Text(
                              style.title,
                              style: TextStyle(
                                fontSize: 18.wMin,
                                fontWeight: FontWeight.w400,
                                color: style.textColor,
                              ),
                            ),
                            Spacer(),
                            Text(
                              item.text ?? '',
                              style: TextStyle(
                                fontSize: 46.wMin,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.cTextPrimary.color,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightPanel(
    CardPhraseSemanticDetilsEntity detils,
    CardPhraseSemantic semantic,
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

  Widget _buildDescriptionRow(CardPhraseSemantic semantic) {
    final ConfigController configController = Get.find<ConfigController>();
    final rawPreference = configController.userSetting.value.expandLang;
    final preference = rawPreference == LangPreference.none
        ? LangPreference.original
        : rawPreference == LangPreference.translation
            ? LangPreference.bilingual
            : rawPreference;
    final bool showOriginal = preference != LangPreference.translation;
    final bool showTranslate = preference == LangPreference.bilingual || preference == LangPreference.translation;
    final String english = _findLanguageText(
      semantic.descriptions,
      configController.userSetting.value.learningLang,
    );
    final String chinese = _findLanguageText(
      semantic.descriptions,
      configController.userSetting.value.localLang,
    );
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
                    final CardPhraseSemanticItem? item = widget.controller.findCurrentSemanticItem();
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
    final CardPhraseSemanticDetilsEntity detils = widget.controller.cardDetils.value;
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

  Widget _buildAnalysisArea(CardPhraseSemanticDetilsEntity detils) {
    final CardPhraseAnalysisEntry? sentenceEntry = _findAnalysisEntry('sentence');
    final CardPhraseAnalysisEntry? memoryEntry = _findAnalysisEntry('memory');
    final CardPhraseAnalysisEntry? relationEntry = _findAnalysisEntry('relation');
    final CardPhraseAnalysisEntry? synonymEntry = _findAnalysisEntry('synonym');

    if (sentenceEntry == null && memoryEntry == null && relationEntry == null && synonymEntry == null) {
      return const ElementsAnalysisEmptyState(text: '暂无分析数据');
    }

    final Widget? leftCard = sentenceEntry == null
        ? null
        : _buildAnalysisCard(
            sentenceEntry,
            _buildSentencePreview(detils.analysisData?.sentence, detils.content ?? ''),
            onTap: () => _openPhraseSentenceCardsPage(sentenceEntry),
          );

    final List<ElementsAnalysisCardLayoutItem> bottomItems = [];
    if (relationEntry != null) {
      bottomItems.add(
        ElementsAnalysisCardLayoutItem(
          flex: 1,
          child: _buildAnalysisCard(
            relationEntry,
            _buildRelationPreview(detils.analysisData?.relation),
            onTap: () => _openAnalysisCardsPage(relationEntry),
          ),
        ),
      );
    }
    if (synonymEntry != null) {
      bottomItems.add(
        ElementsAnalysisCardLayoutItem(
          flex: 1,
          child: _buildAnalysisCard(
            synonymEntry,
            _buildSynonymPreview(detils.analysisData?.synonym),
            onTap: () => _openAnalysisCardsPage(synonymEntry),
          ),
        ),
      );
    }

    final List<Widget> rightColumnChildren = [];
    if (memoryEntry != null) {
      rightColumnChildren.add(
        Expanded(
          child: _buildAnalysisCard(
            memoryEntry,
            _buildMemoryPreview(detils),
            onTap: _openEtymologyMemoryPage,
          ),
        ),
      );
    }
    if (bottomItems.isNotEmpty) {
      if (rightColumnChildren.isNotEmpty) {
        rightColumnChildren.add(SizedBox(height: 16.wMin));
      }
      rightColumnChildren.add(
        Expanded(
          child: ElementsAnalysisCardRow(items: bottomItems),
        ),
      );
    }

    final Widget? rightColumn = rightColumnChildren.isEmpty ? null : Column(children: rightColumnChildren);

    if (leftCard != null && rightColumn != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: leftCard),
          SizedBox(width: 16.wMin),
          Expanded(child: rightColumn),
        ],
      );
    }
    if (leftCard != null) return leftCard;
    if (rightColumn != null) return rightColumn;
    return const ElementsAnalysisEmptyState(text: '暂无分析数据');
  }

  Widget _buildAnalysisCard(
    CardPhraseAnalysisEntry entry,
    Widget child, {
    VoidCallback? onTap,
  }) {
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

  Widget _buildSentencePreview(
    CardPhraseAnalysisSentenceData? data,
    String phraseContent,
  ) {
    final List<CardPhraseSentencePreviewItem> items =
        data?.previewSentences?.whereType<CardPhraseSentencePreviewItem>().toList() ?? <CardPhraseSentencePreviewItem>[];
    final List<EnterSentenceEntityPreviewGovernedSlots> governedSlots =
        data?.governedSlots
                ?.whereType<EnterSentenceEntityPreviewGovernedSlots>()
                .toList() ??
            <EnterSentenceEntityPreviewGovernedSlots>[];
    final ConfigController configController = Get.find<ConfigController>();
    final rawPreference = configController.userSetting.value.expandLang;
    final preference = rawPreference == LangPreference.none
        ? LangPreference.original
        : rawPreference == LangPreference.translation
            ? LangPreference.bilingual
            : rawPreference;
    final bool showOriginal = preference != LangPreference.translation;
    final bool showTranslate = preference == LangPreference.bilingual || preference == LangPreference.translation;
    final String descriptionsZh = _findZhOnlyText(data?.descriptions).isNotEmpty
        ? _findZhOnlyText(data?.descriptions)
        : (data?.descriptionsZh ?? '').trim();

    if (items.isEmpty && descriptionsZh.isEmpty && governedSlots.isEmpty) {
      return const ElementsAnalysisEmptyState(text: '暂无数据');
    }

    final List<Widget> children = <Widget>[];
    if (descriptionsZh.isNotEmpty) {
      children.add(
        Text(
          descriptionsZh,
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary,
            height: 1.5,
          ),
        ),
      );
    }
    if (governedSlots.isNotEmpty) {
      if (children.isNotEmpty) {
        children.add(SizedBox(height: 12.wMin));
      }
      children.add(
        PhraseEnterSentencePhraseWidget(
          governedSlots: governedSlots,
          content: phraseContent,
        ),
      );
    }
    if (items.isNotEmpty) {
      if (children.isNotEmpty) {
        children.add(SizedBox(height: 16.wMin));
      }
      for (int index = 0; index < items.length; index++) {
        if (index > 0) {
          children.add(
            SizedBox(
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
          );
        }
        final CardPhraseSentencePreviewItem item = items[index];
        final CardPhraseSentencePreviewContentCard? card = item.contentCard;
        final String content = card?.content ?? '';
        final String definition = card?.definition ?? '';
        final bool canShowTranslate = showTranslate && definition.isNotEmpty;
        children.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showOriginal || !canShowTranslate)
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cTextPrimary,
                      height: 1.5,
                    ),
                    children: _buildSentenceHighlightSpans(content, item.ranges),
                  ),
                ),
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
          ),
        );
      }
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(20.wMin, 0, 20.wMin, 16.wMin),
      children: children,
    );
  }

  Widget _buildMemoryPreview(CardPhraseSemanticDetilsEntity detils) {
    final ConfigController configController = Get.find<ConfigController>();
    final rawPreference = configController.userSetting.value.expandLang;
    final preference = rawPreference == LangPreference.none
        ? LangPreference.original
        : rawPreference == LangPreference.translation
            ? LangPreference.bilingual
            : rawPreference;
    final bool showOriginal = preference != LangPreference.translation;
    final bool showTranslate = preference == LangPreference.bilingual || preference == LangPreference.translation;
    final CardPhraseAnalysisMemoryData? memory = detils.analysisData?.memory;
    if (memory == null) {
      return const ElementsAnalysisEmptyState(text: '暂无词源记忆');
    }

    final String coreText = _findLanguageText(
      memory.coreText,
      configController.userSetting.value.localLang,
    );
    final List<CardPhraseAnalysisMemoryBranchText> branchTexts =
        memory.branchTexts?.whereType<CardPhraseAnalysisMemoryBranchText>().toList() ?? <CardPhraseAnalysisMemoryBranchText>[];

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
                  _findLanguageText(
                    item.text,
                    configController.userSetting.value.localLang,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSynonymPreview(CardPhraseAnalysisSynonymData? data) {
    if (data == null) {
      return const ElementsAnalysisEmptyState(text: '暂无同义词');
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20.wMin, 16, 20.wMin, 16.wMin),
      child: Text(
        '${data.count} 个可换用的词。',
        style: TextStyle(
          fontSize: 20.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cTextTertiary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildRelationPreview(CardPhraseAnalysisRelationData? data) {
    final List<CardPhraseAnalysisRelationItem> items =
        data?.items?.whereType<CardPhraseAnalysisRelationItem>().toList() ??
            <CardPhraseAnalysisRelationItem>[];
    if (items.isEmpty) {
      return const ElementsAnalysisEmptyState(text: '暂无关联数据');
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20.wMin,16.wMin, 20.wMin, 0.wMin),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: 6.wMin),
      itemBuilder: (_, index) {
        final CardPhraseAnalysisRelationItem item = items[index];
        final Color dotColor =
            ColorUtils.parseColor(item.color) ?? AppTheme.cTextBrand.color;

        return Container(
          padding: EdgeInsets.all(14.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceTranslucentBase.color,
            borderRadius: BorderRadius.circular(6.wMin),
            border: Border.all(
              color: AppTheme.cBorderTranslucentThin.color,
              width: 1.wMin,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 12.wMin,
                height: 12.wMin,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 10.wMin),
              Text(
                item.title ?? '',
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '${item.previewCount ?? 0}',
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openAnalysisCardsPage(CardPhraseAnalysisEntry entry) async {
    final int? contentId = widget.controller.contentId;
    final int semanticId = widget.controller.currentSemanticId.value;
    final String contentType = (widget.controller.cardDetils.value.contentType ?? '').trim();
    final String type = (entry.type ?? '').trim();
    if (contentId == null || semanticId <= 0 || type.isEmpty) {
      ToastUtils.showToast(text: '缺少跳转参数');
      return;
    }
    final String title = _findLanguageText(entry.title, 'zh');
    if (type == 'synonym') {
      if (contentType.isEmpty) {
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
      return;
    }
    if (type == 'relation') {
      await _openPhraseRelationsPage(title);
      return;
    }
    ToastUtils.showToast(text: '本次暂未接入');
  }

  Future<void> _openEtymologyMemoryPage() async {
    final CardPhraseSemanticDetilsEntity detils = widget.controller.cardDetils.value;
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

  Future<void> _openPhraseStructureDetailPage() async {
    final int? contentId = widget.controller.cardDetils.value.contentId;
    if (contentId == null) {
      ToastUtils.showToast(text: '缺少跳转参数');
      return;
    }
    await TagRoutes.toNamed(
      Routes.ZHENXIE_PHRASE_STRUCTURE_DETAILS,
      tagText: '${widget.controller.tagText}_phrase_structure_$contentId',
      arguments: <String, dynamic>{
        'contentId': contentId,
        'isManagement': false,
      },
    );
  }

  Future<void> _openPhraseSentenceCardsPage(CardPhraseAnalysisEntry entry) async {
    final int? contentId = widget.controller.contentId;
    final int semanticId = widget.controller.currentSemanticId.value;
    if (contentId == null || semanticId <= 0) {
      ToastUtils.showToast(text: '缺少跳转参数');
      return;
    }
    final String title = _findLanguageText(entry.title, 'zh');
    await TagRoutes.toNamed(
      Routes.EN_PHRASE_SENTENCE_CARDS,
      tagText: '${widget.controller.tagText}_phrase_sentence_$semanticId',
      arguments: <String, dynamic>{
        'contentId': contentId,
        'semanticId': semanticId,
        'title': title,
        'highlightColorValue': _resolveHighlightColor().toARGB32(),
      },
    );
  }

  Future<void> _openPhraseRelationsPage(String title) async {
    final int? contentId = widget.controller.contentId;
    final int semanticId = widget.controller.currentSemanticId.value;
    if (contentId == null || semanticId <= 0) {
      ToastUtils.showToast(text: '缺少跳转参数');
      return;
    }
    await TagRoutes.toNamed(
      Routes.EN_PHRASE_RELATIONS,
      tagText: '${widget.controller.tagText}_phrase_relations_$semanticId',
      arguments: <String, dynamic>{
        'contentId': contentId,
        'title': title,
      },
    );
  }

  Widget _buildSemanticTabBar(List<CardPhraseSemanticItem> filteredItems) {
    final List<String> allPos = _allPosList();
    final int currentSemanticId = widget.controller.currentSemanticId.value;
    final CardPhraseSemanticItem? currentSemanticItem =
        widget.controller.semanticItems.firstWhereOrNull((CardPhraseSemanticItem e) => e.semanticId == currentSemanticId);
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

  List<CardPhraseSemanticItem> _filteredSemanticItems() {
    final List<CardPhraseSemanticItem> all = widget.controller.semanticItems;
    if (_selectedPoses.isEmpty) return all;
    return all.where((CardPhraseSemanticItem e) => _selectedPoses.contains(e.pos ?? '')).toList();
  }

  List<String> _allPosList() {
    final Set<String> seen = <String>{};
    final List<String> result = <String>[];
    for (final CardPhraseSemanticItem item in widget.controller.semanticItems) {
      final String pos = item.pos ?? '';
      if (pos.isNotEmpty && seen.add(pos)) result.add(pos);
    }
    return result;
  }

  String _posDisplayText(String pos) {
    final CardPhraseSemanticItem? item = widget.controller.semanticItems.firstWhereOrNull((CardPhraseSemanticItem e) => e.pos == pos);
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
    final CardPhraseSemanticItem? item = widget.controller.semanticItems.firstWhereOrNull((CardPhraseSemanticItem e) => e.pos == pos);
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
    final CardPhraseSemanticItem? currentSemanticItem =
        widget.controller.semanticItems.firstWhereOrNull((CardPhraseSemanticItem e) => e.semanticId == currentId);
    if (_selectedPoses.contains(currentSemanticItem?.pos ?? '')) return;
    final CardPhraseSemanticItem? firstItem =
        widget.controller.semanticItems.firstWhereOrNull((CardPhraseSemanticItem e) => _selectedPoses.contains(e.pos ?? ''));
    if (firstItem?.semanticId == null) return;
    await widget.controller.switchSemantic(firstItem!.semanticId!);
  }

  Future<void> _showPosSelectorDialog(BuildContext anchorContext) async {
    final List<String> allPos = _allPosList();
    if (allPos.length <= 1) return;
    final int currentId = widget.controller.currentSemanticId.value;
    final CardPhraseSemanticItem? currentSemanticItem =
        widget.controller.semanticItems.firstWhereOrNull((CardPhraseSemanticItem e) => e.semanticId == currentId);
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

  CardPhraseAnalysisEntry? _findAnalysisEntry(String type) {
    final List<CardPhraseAnalysisEntry> entries =
        widget.controller.cardDetils.value.analysisEntries?.whereType<CardPhraseAnalysisEntry>().toList() ?? <CardPhraseAnalysisEntry>[];
    for (final CardPhraseAnalysisEntry entry in entries) {
      if (entry.type == type) {
        return entry;
      }
    }
    return null;
  }

  String _resolvePosText(CardPhraseSemanticItem? item) {
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

  String _findZhOnlyText(List<LanguageText?>? texts) {
    if (texts == null || texts.isEmpty) return '';
    for (final LanguageText? item in texts) {
      if ((item?.lang ?? '').toLowerCase() == 'zh' && (item?.text ?? '').isNotEmpty) {
        return item!.text!;
      }
    }
    return '';
  }

  List<InlineSpan> _buildSentenceHighlightSpans(
    String text,
    List<CardPhraseSentencePreviewRange?>? ranges,
  ) {
    if (text.isEmpty) {
      return const <InlineSpan>[];
    }
    final List<CardPhraseSentencePreviewRange> sortedRanges =
        ranges?.whereType<CardPhraseSentencePreviewRange>().toList() ?? <CardPhraseSentencePreviewRange>[];
    if (sortedRanges.isEmpty) {
      return <InlineSpan>[TextSpan(text: text)];
    }
    sortedRanges.sort((a, b) => (a.start ?? 0).compareTo(b.start ?? 0));

    final List<InlineSpan> spans = [];
    int current = 0;
    final Color highlightColor = _resolveHighlightColor();
    for (final CardPhraseSentencePreviewRange range in sortedRanges) {
      final int start = range.start ?? 0;
      final int end = range.end ?? 0;
      if (start > current) {
        spans.add(TextSpan(text: text.substring(current, start)));
      }
      if (end > start && end <= text.length) {
        spans.add(
          TextSpan(
            text: text.substring(start, end),
            style: TextStyle(
              color: highlightColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
        current = end;
      }
    }
    if (current < text.length) {
      spans.add(TextSpan(text: text.substring(current)));
    }
    return spans;
  }

  Color _resolveHighlightColor() {
    final ThemeTextStyleEntity? style = StyleUtils.getCurrentThemeText(widget.controller.findCurrentSemanticItem()?.textStyle);
    return ColorUtils.parseColor(style?.borderColor) ?? ColorUtils.parseColor(style?.backgroundColor) ?? AppTheme.cTextBrand.color;
  }

  _PhraseStructureRoleStyle _resolveStructureRoleStyle(String? roleNid) {
    final ConfigController configController = Get.find<ConfigController>();
    final LanguageConfigColorModel? colorConfig = StatusUtils.getConfigColor(
      configController.colorConfigs.value.phraseItemRoles,
      roleNid,
    );
    final String title = colorConfig?.title ?? ((roleNid ?? '').trim().isEmpty ? '' : roleNid!);
    return _PhraseStructureRoleStyle(
      title: title,
      textColor: colorConfig?.color?.textColor ?? AppTheme.cTextSecondary.color,
      bgColor: colorConfig?.color?.bgColor ?? AppTheme.cSurfaceTranslucentBase.color,
      borderColor: colorConfig?.color?.borderColor ?? AppTheme.cBorderTranslucentThin.color,
    );
  }
}

class _PhraseStructureRoleStyle {
  final String title;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;

  const _PhraseStructureRoleStyle({
    required this.title,
    required this.textColor,
    required this.bgColor,
    required this.borderColor,
  });
}
