import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/filter_widgets.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/common/widgets/zhenxie_widgets/phrase_enter_sentence_phrase_widget.dart';
import 'package:langwise/common/widgets/zhenxie_widgets/phrase_structure_preview_widget.dart';
import 'package:langwise/common/widgets/zhenxie_widgets/word_inflection_info_tag_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/values/app_font_value.dart';
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
  final Set<String> _playingAudioUrls = <String>{};

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      _syncSelectedPosWithCurrentSemantic();
      if (widget.controller.currentSemantic.value.uid == null && widget.controller.semanticItems.isEmpty) {
        return const SizedBox.shrink();
      }

      final CardPhraseSemanticDetilsEntity detils = widget.controller.cardDetils.value;
      final CardPhraseSemantic semantic = widget.controller.currentSemantic.value;

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

  /// 上半区：左侧媒体，右侧信息区与结构/同反义区。
  Widget _buildTopSection(
    CardPhraseSemanticDetilsEntity detils,
    CardPhraseSemantic semantic,
    double topHeight,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: topHeight,
          height: topHeight,
          child: ElementsSemanticVideoCardWidget(
            imageUrl: semantic.imageUrl,
            relationVideo: semantic.video,
            pronunciations: semantic.pronunciations,
            semanticPlaybackKey: '${detils.contentId ?? 0}_${semantic.uid ?? 0}',
            size: double.infinity,
            showPronunciationOverlay: false,
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
    CardPhraseSemanticDetilsEntity detils,
    CardPhraseSemantic semantic,
  ) {
    final bool hasStructure = _findAnalysisEntry('structure') != null;
    final bool hasLexicalSetPreview = _findAnalysisEntry('synonym') != null;
    final bool showBottomSection = hasStructure || hasLexicalSetPreview;
    final double minInfoHeight = 176.wMin;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: minInfoHeight),
          child: Obx(() => _buildTitleInfoSection(detils, semantic)),
        ),
        if (showBottomSection) ...[
          SizedBox(height: 16.wMin),
          Expanded(
            child: _buildStructureLexicalSection(detils),
          ),
        ],
      ],
    );
  }

  /// 信息区：标题、发音按钮、翻译、标签、详情和右侧操作按钮。
  Widget _buildTitleInfoSection(
    CardPhraseSemanticDetilsEntity detils,
    CardPhraseSemantic semantic,
  ) {
    final ConfigController configController = Get.find<ConfigController>();
    final List<PronunciationsEntity> pronunciations = _activePronunciations(semantic.pronunciations);
    final LangPreference preference = configController.userSetting.value.expandLang;
    final String infoLang = preference == LangPreference.translation
        ? configController.userSetting.value.localLang
        : configController.userSetting.value.learningLang;
    final String glossText = _findLanguageText(semantic.gloss, infoLang);
    final String descriptionText = _findLanguageText(semantic.descriptions, infoLang);
    final List<Widget> tags = _buildTitleTags(semantic);

    return Container(
      // constraints: BoxConstraints(minHeight: 176.wMin),
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 32.wMin,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cTextPrimary.color,
                      // height: 1.0,
                    ),
                    children: [
                      TextSpan(text: detils.content ?? ''),
                      if (pronunciations.isNotEmpty)
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: SizedBox(width: 8.wMin),
                        ),
                      for (int index = 0; index < pronunciations.take(2).length; index++)
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.only(right: index == 1 ? 0 : 6.wMin),
                            child: _buildPronunciationButton(pronunciations[index]),
                          ),
                        ),
                    ],
                  ),
                ),
                if (glossText.isNotEmpty || tags.isNotEmpty) ...[
                  SizedBox(height: 8.wMin),
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
                  ),
                ],
                if (descriptionText.isNotEmpty) ...[
                  SizedBox(height: 8.wMin),
                  Text(
                    descriptionText,
                    maxLines: 3,
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
      fontSize: 24.wMin,
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
            color: AppTheme.cTextBrand.color.withValues(alpha: 0.20),
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

  /// 上半区第二行：左结构，右同义反义。
  Widget _buildStructureLexicalSection(CardPhraseSemanticDetilsEntity detils) {
    final CardPhraseAnalysisEntry? structureEntry = _findAnalysisEntry('structure');
    final CardPhraseAnalysisEntry? synonymEntry = _findAnalysisEntry('synonym');
    final bool hasStructure = structureEntry != null;
    final bool hasLexicalSetPreview = synonymEntry != null;

    if (hasStructure && hasLexicalSetPreview) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildAnalysisCard(
              structureEntry,
              _buildStructureContent(detils.structure),
              onTap: _openPhraseStructureDetailPage,
            ),
          ),
          SizedBox(width: 14.wMin),
          Expanded(
            child: _buildAnalysisCard(
              synonymEntry,
              _buildLexicalSetPreview(detils.analysisData?.lexicalSetPreview),
              onTap: _openLexicalDetailPage,
            ),
          ),
        ],
      );
    }
    if (hasStructure) {
      return _buildAnalysisCard(
        structureEntry,
        _buildStructureContent(detils.structure),
        onTap: _openPhraseStructureDetailPage,
      );
    }
    if (hasLexicalSetPreview) {
      return _buildAnalysisCard(
        synonymEntry,
        _buildLexicalSetPreview(detils.analysisData?.lexicalSetPreview),
        onTap: _openLexicalDetailPage,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStructureContent(CardPhraseStructure? structure) {
    final List<CardPhraseStructureItem> items =
        structure?.items?.whereType<CardPhraseStructureItem>().toList() ?? <CardPhraseStructureItem>[];
    final String explanation = _findZhOnlyText(structure?.explanations);
    final bool hasContent = explanation.isNotEmpty || items.isNotEmpty;

    if (!hasContent) {
      return const ElementsAnalysisEmptyState(text: '暂无结构数据');
    }

    return Padding(
      padding: EdgeInsets.all(16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (explanation.isNotEmpty)
            Text(
              explanation,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary,
              ),
            ),
          if (items.isNotEmpty) ...[
            if (explanation.isNotEmpty) SizedBox(height: 10.wMin),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: PhraseStructurePreviewWidget(
                  items: items,
                  fitAlignment: Alignment.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 下半区：左词源，右关联与句子。
  Widget _buildBottomSection(
    CardPhraseSemanticDetilsEntity detils,
    double leftWidth,
  ) {
    final CardPhraseAnalysisEntry? memoryEntry = _findAnalysisEntry('memory');
    final CardPhraseAnalysisEntry? relationEntry = _findAnalysisEntry('relation');
    final CardPhraseAnalysisEntry? sentenceEntry = _findAnalysisEntry('sentence');

    final Widget? memoryWidget = memoryEntry == null
        ? null
        : _buildAnalysisCard(
            memoryEntry,
            _buildMemoryPreview(detils),
            onTap: _openEtymologyMemoryPage,
          );
    final Widget? relationWidget = relationEntry == null
        ? null
        : _buildAnalysisCard(
            relationEntry,
            _buildRelationPreview(detils.analysisData?.relation),
            onTap: () => _openAnalysisCardsPage(relationEntry),
          );
    final Widget? sentenceWidget = sentenceEntry == null
        ? null
        : _buildAnalysisCard(
            sentenceEntry,
            _buildSentencePreview(
              detils.analysisData?.sentence,
              detils.content ?? '',
              ColorUtils.parseColor(sentenceEntry.color?.from) ?? AppTheme.cTextBrand.color,
            ),
            onTap: () => _openPhraseSentenceCardsPage(sentenceEntry),
          );

    final List<Widget> rightChildren = [];
    if (relationWidget != null) {
      rightChildren.add(Expanded(child: relationWidget));
    }
    if (sentenceWidget != null) {
      if (rightChildren.isNotEmpty) {
        rightChildren.add(SizedBox(width: 16.wMin));
      }
      rightChildren.add(Expanded(child: sentenceWidget));
    }
    final Widget? rightWidget = rightChildren.isEmpty
        ? null
        : Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rightChildren,
          );

    if (memoryWidget != null && rightWidget != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: leftWidth,
            child: memoryWidget,
          ),
          SizedBox(width: 16.wMin),
          Expanded(child: rightWidget),
        ],
      );
    }
    if (memoryWidget != null) return memoryWidget;
    if (rightWidget != null) return rightWidget;
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
    Color mainColor,
  ) {
    final List<CardPhraseSentencePreviewItem> items =
        data?.previewSentences?.whereType<CardPhraseSentencePreviewItem>().toList() ?? <CardPhraseSentencePreviewItem>[];
    final List<EnterSentenceEntityPreviewGovernedSlots> governedSlots =
        data?.governedSlots?.whereType<EnterSentenceEntityPreviewGovernedSlots>().toList() ?? <EnterSentenceEntityPreviewGovernedSlots>[];
    final String descriptionsZh =
        _findZhOnlyText(data?.descriptions).isNotEmpty ? _findZhOnlyText(data?.descriptions) : (data?.descriptionsZh ?? '').trim();

    if (items.isEmpty && descriptionsZh.isEmpty && governedSlots.isEmpty) {
      return const ElementsAnalysisEmptyState(text: '暂无数据');
    }

    final List<Widget> children = <Widget>[];
    if (descriptionsZh.isNotEmpty) {
      children.add(
        Text(
          descriptionsZh,
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary,
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
          mainColor: mainColor,
        ),
      );
    } else {
      if (children.isNotEmpty) {
        children.add(SizedBox(height: 12.wMin));
      }
      children.add(_buildPhraseItemWidget(phraseContent, mainColor));
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
                    customPath: (Size size) => Path()
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
        final KnowledgeCommonEntityList? card = item.contentCard;
        final String content = card?.title ?? '';
        final String definition = card?.subTitle ?? '';
        final bool canShowTranslate = definition.isNotEmpty;
        children.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

    return Builder(
      builder: (BuildContext context) {
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.wMin, 0, 20.wMin, 16.wMin),
            children: children,
          ),
        );
      },
    );
  }

  Widget _buildPhraseItemWidget(String? content, Color mainColor) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: EdgeInsets.all(8.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.wMin),
            color: mainColor.withValues(alpha: 0.12),
            border: Border.all(
              color: mainColor.withValues(alpha: 0.20),
              width: 0.5.wMin,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '整块',
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w500,
                  color: mainColor.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 10.wMin),
              Text(
                content ?? '',
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemoryPreview(CardPhraseSemanticDetilsEntity detils) {
    final ConfigController configController = Get.find<ConfigController>();
    final CardPhraseAnalysisMemoryData? memory = detils.analysisData?.memory;
    if (memory == null) {
      return const ElementsAnalysisEmptyState(text: '暂无词源记忆');
    }

    final String coreText = _findLanguageText(memory.coreText, configController.userSetting.value.localLang);
    final String memoryDescriptionText = _findLanguageText(memory.descriptions, configController.userSetting.value.localLang);
    final String descriptionText = memoryDescriptionText.isNotEmpty
        ? memoryDescriptionText
        : _findLanguageText(memory.gloss, configController.userSetting.value.localLang);
    final List<String> branchTexts =
        (memory.branchTexts?.whereType<CardPhraseAnalysisMemoryBranchText>().toList() ?? <CardPhraseAnalysisMemoryBranchText>[])
            .map((CardPhraseAnalysisMemoryBranchText item) => _findLanguageText(item.text, configController.userSetting.value.localLang))
            .where((String text) => text.isNotEmpty)
            .toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(20.wMin, 0, 20.wMin, 16.wMin),
      child: Column(
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

  Widget _buildLexicalSetPreview(
    List<CardPhraseLexicalSetPreviewItem?>? lexicalSetPreview,
  ) {
    final CardPhraseLexicalSetPreviewItem? synonym = _findLexicalSetPreviewItem(lexicalSetPreview, 'synonym');
    final CardPhraseLexicalSetPreviewItem? antonym = _findLexicalSetPreviewItem(lexicalSetPreview, 'antonym');
    final List<String> synonymChips = synonym?.chips?.whereType<String>().where((String item) => item.isNotEmpty).toList() ?? <String>[];
    final List<String> antonymChips = antonym?.chips?.whereType<String>().where((String item) => item.isNotEmpty).toList() ?? <String>[];

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
    return painter.width + 26.wMin;
  }

  Widget _buildRelationPreview(CardPhraseAnalysisRelationData? data) {
    final List<CardPhraseAnalysisRelationItem> items =
        data?.items?.whereType<CardPhraseAnalysisRelationItem>().toList() ?? <CardPhraseAnalysisRelationItem>[];
    if (items.isEmpty) {
      return const ElementsAnalysisEmptyState(text: '暂无关联数据');
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20.wMin, 16.wMin, 20.wMin, 0),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: 6.wMin),
      itemBuilder: (_, int index) {
        final CardPhraseAnalysisRelationItem item = items[index];
        final Color dotColor = ColorUtils.parseColor(item.color) ?? AppTheme.cTextBrand.color;

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

  Future<void> _openAnalysisCardsPage(CardPhraseAnalysisEntry entry) async {
    final int? contentId = widget.controller.contentId;
    final int semanticId = widget.controller.currentSemanticId.value;
    final String type = (entry.type ?? '').trim();
    if (contentId == null || semanticId <= 0 || type.isEmpty) {
      ToastUtils.showToast(text: '缺少跳转参数');
      return;
    }
    final String title = _findLanguageText(entry.title, 'zh');
    if (type == 'relation') {
      await _openPhraseRelationsPage(title);
      return;
    }
    ToastUtils.showToast(text: '本次暂未接入');
  }

  Future<void> _openLexicalDetailPage() async {
    final int? contentId = widget.controller.contentId;
    final int semanticId = widget.controller.currentSemanticId.value;
    final String contentType = (widget.controller.cardDetils.value.contentType ?? '').trim();
    if (contentId == null || semanticId <= 0 || contentType.isEmpty) {
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
        'title': '同义反义',
      },
    );
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
        'phraseId': contentId,
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
        .where((CardPhraseSemanticItem item) => item.semanticId != null)
        .map((CardPhraseSemanticItem item) => SemanticChipData(
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
      if (pos.isNotEmpty && seen.add(pos)) {
        result.add(pos);
      }
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
    _selectedPoses.removeWhere((String e) => !allPos.contains(e));
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
          conditionsData: <String, FilterConditionsData>{
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
    final Set<String> selectedValues = result['pos']
            ?.conditions
            .where((FilterConditionsItem e) => e.selected)
            .map((FilterConditionsItem e) => e.value?.toString() ?? '')
            .where((String e) => e.isNotEmpty)
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

  List<Widget> _buildTitleTags(CardPhraseSemantic semantic) {
    final ConfigController configController = Get.find<ConfigController>();
    final CardPhraseSemanticItem? item = widget.controller.findCurrentSemanticItem();
    final ThemeTextStyleEntity? style = StyleUtils.getCurrentThemeText(item?.textStyle);
    final String posText = _resolvePosText(item);
    final Color posTagColor = ColorUtils.parseColor(style?.borderColor) ?? AppTheme.cTextPrimary.color;
    final List<Widget> tags = [];

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
    final List<String> sentenceProfileTags = _resolveSentenceProfileTags();
    final Color tagColor = ColorUtils.parseColor(style?.borderColor) ?? AppTheme.cTextPrimary.color;
    for (final String tag in sentenceProfileTags) {
      if (tag.isNotEmpty) {
        tags.add(
          WordInflectionInfoTagWidget(
            tag,
            textColor: tagColor,
            bgColor: tagColor.withValues(alpha: 0.12),
            borderColor: tagColor.withValues(alpha: 0.20),
          ),
        );
      }
    }
    return tags;
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

  List<String> _resolveSentenceProfileTags() {
    final CardPhraseAnalysisSentenceData? sentence = widget.controller.cardDetils.value.analysisData?.sentence;
    if (sentence == null) return const <String>[];
    final List<String> tags = [];
    final String grammaticalTypeText = _resolveSentenceGrammaticalTypeText(sentence);
    if (grammaticalTypeText.isNotEmpty) {
      tags.add(grammaticalTypeText);
    }
    tags.addAll(_resolveSentenceSlotCategoryTexts(sentence));
    return tags;
  }

  String _resolveSentenceGrammaticalTypeText(CardPhraseAnalysisSentenceData sentence) {
    final List<LanguageText> texts = sentence.grammaticalType?.whereType<LanguageText>().toList() ?? <LanguageText>[];
    if (texts.isNotEmpty) {
      return texts.first.text ?? '';
    }
    return sentence.grammaticalTypeNameZh ?? '';
  }

  List<String> _resolveSentenceSlotCategoryTexts(CardPhraseAnalysisSentenceData sentence) {
    final List<String> texts = [];
    final List<List<LanguageText?>?> categories = sentence.sentenceSlotCategory ?? <List<LanguageText?>?>[];
    for (final List<LanguageText?>? category in categories) {
      final LanguageText? first = category?.whereType<LanguageText>().firstOrNull;
      final String text = first?.text ?? '';
      if (text.isNotEmpty) {
        texts.add(text);
      }
    }
    if (texts.isNotEmpty) return texts;
    return sentence.sentenceSlotCategoryNamesZh?.whereType<String>().where((String item) => item.isNotEmpty).toList() ?? <String>[];
  }

  List<PronunciationsEntity> _activePronunciations(
    List<PronunciationsEntity?>? pronunciations,
  ) {
    return pronunciations?.whereType<PronunciationsEntity>().toList() ?? <PronunciationsEntity>[];
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

  CardPhraseLexicalSetPreviewItem? _findLexicalSetPreviewItem(
    List<CardPhraseLexicalSetPreviewItem?>? items,
    String code,
  ) {
    for (final CardPhraseLexicalSetPreviewItem? item in items ?? <CardPhraseLexicalSetPreviewItem?>[]) {
      if ((item?.code ?? '').toLowerCase() == code) {
        return item;
      }
    }
    return null;
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
    sortedRanges.sort((CardPhraseSentencePreviewRange a, CardPhraseSentencePreviewRange b) => (a.start ?? 0).compareTo(b.start ?? 0));

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
}
