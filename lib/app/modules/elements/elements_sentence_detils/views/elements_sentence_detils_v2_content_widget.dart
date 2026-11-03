import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/elements/elements_sentence_detils/views/elements_sentence_dialog_body_widget.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../common/elements_analysis_cards_widget.dart';
import '../../common/elements_memory_action_button.dart';
import '../../common/elements_public_widgets.dart';
import '../../dictionary/controllers/dictionary_controller.dart';
import '../controllers/elements_sentence_detils_v2_controller.dart';
import 'elements_sentence_analysis_view.dart';

class ElementsSentenceDetilsV2ContentWidget extends StatefulWidget {
  final ElementsSentenceDetilsV2Controller controller;
  final String tagText;

  const ElementsSentenceDetilsV2ContentWidget({
    super.key,
    required this.controller,
    required this.tagText,
  });

  @override
  State<ElementsSentenceDetilsV2ContentWidget> createState() => _ElementsSentenceDetilsV2ContentWidgetState();
}

class _ElementsSentenceDetilsV2ContentWidgetState extends State<ElementsSentenceDetilsV2ContentWidget> {
  final Set<String> _playingAudioUrls = <String>{};
  final GlobalKey _blueprintSectionKey = GlobalKey();
  bool _blueprintExpanded = false;

  ElementsSentenceDetilsV2Controller get controller => widget.controller;
  String get tagText => widget.tagText;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final EnSentenceDetailV2Entity detils = controller.sentenceDetils.value;
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
                      child: _buildTopSection(context, detils, topHeight),
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
        ],
      );
    });
  }

  Widget _buildTopSection(
    BuildContext context,
    EnSentenceDetailV2Entity detils,
    double topHeight,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: topHeight,
          height: topHeight,
          child: ElementsSemanticVideoCardWidget(
            imageUrl: detils.media?.imageUrl,
            relationVideo: detils.media?.video,
            pronunciations: detils.media?.pronunciations,
            semanticPlaybackKey: '${detils.contentId ?? 0}',
            size: double.infinity,
            showPronunciationOverlay: false,
          ),
        ),
        SizedBox(width: 16.wMin),
        Expanded(
          child: _buildTopRightSection(context, detils),
        ),
      ],
    );
  }

  Widget _buildTopRightSection(
    BuildContext context,
    EnSentenceDetailV2Entity detils,
  ) {
    final EnSentenceDetailV2AnalysisEntry? relationsEntry = _findAnalysisEntry(detils.analysisEntries, 'relations');
    final bool hasBlueprint = _hasBlueprintSection(detils.structure);
    final bool showRelations = relationsEntry != null && !_blueprintExpanded;
    final double minInfoHeight = 130.wMin;
    final double blueprintHeight = 162.wMin;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasBlueprint)
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: minInfoHeight),
            child: Obx(() => _buildInfoSection(context, detils)),
          )
        else
          Expanded(
            child: Obx(() => _buildInfoSection(context, detils)),
          ),
        if (hasBlueprint || showRelations) SizedBox(height: 16.wMin),
        if (hasBlueprint && showRelations) ...[
          SizedBox(
            height: blueprintHeight,
            child: KeyedSubtree(
              key: _blueprintSectionKey,
              child: _buildBlueprintSection(context, detils.structure),
            ),
          ),
          SizedBox(height: 16.wMin),
          Expanded(
            child: _buildAnalysisEntryCard(detils, relationsEntry),
          ),
        ] else if (hasBlueprint)
          Expanded(
            child: KeyedSubtree(
              key: _blueprintSectionKey,
              child: _buildBlueprintSection(context, detils.structure),
            ),
          )
        else if (showRelations)
          Expanded(
            child: _buildAnalysisEntryCard(detils, relationsEntry),
          ),
      ],
    );
  }

  Widget _buildBottomSection(
    EnSentenceDetailV2Entity detils,
    double leftWidth,
  ) {
    final EnSentenceDetailV2AnalysisEntry? chunksEntry = _findAnalysisEntry(detils.analysisEntries, 'chunks');
    final EnSentenceDetailV2AnalysisEntry? svocaEntry = _findAnalysisEntry(detils.analysisEntries, 'svoca');
    final EnSentenceDetailV2AnalysisEntry? syntaxEntry = _findAnalysisEntry(detils.analysisEntries, 'syntax');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (chunksEntry != null)
          SizedBox(
            width: leftWidth,
            child: _buildAnalysisEntryCard(detils, chunksEntry),
          ),
        if (chunksEntry != null) SizedBox(width: 16.wMin),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (svocaEntry != null)
                Expanded(
                  child: _buildAnalysisEntryCard(detils, svocaEntry),
                ),
              if (svocaEntry != null && syntaxEntry != null) SizedBox(width: 16.wMin),
              if (syntaxEntry != null)
                Expanded(
                  child: _buildAnalysisEntryCard(detils, syntaxEntry),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, EnSentenceDetailV2Entity detils) {
    final ConfigController configController = Get.find<ConfigController>();
    final LangPreference preference = configController.userSetting.value.expandLang;
    final bool showTranslate = preference == LangPreference.translation;
    final List<PronunciationsEntity> pronunciations =
        (detils.media?.pronunciations ?? <PronunciationsEntity?>[]).whereType<PronunciationsEntity>().toList();
    final List<Widget> tags = _buildTitleTags(configController, detils);
    final String definition = detils.definition ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentBase,
        borderRadius: BorderRadius.circular(24.wMin),
        border: Border.all(
          color: AppTheme.cBorderTranslucentThin,
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
                if ((detils.content ?? '').isNotEmpty)
                  _buildAdaptiveSentenceTitle(detils.content ?? '', pronunciations),
                if ((showTranslate && definition.isNotEmpty) || tags.isNotEmpty) ...[
                  SizedBox(height: 8.wMin),
                  RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: _buildDefinitionInlineSpans(
                        definition: showTranslate ? definition : '',
                        tags: tags,
                      ),
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
                  favorited: detils.favorited ?? false,
                  onTap: () => _handleMemoryAction(context, detils),
                  color: AppTheme.cMorphemeCardColor1.color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTitleTags(
    ConfigController configController,
    EnSentenceDetailV2Entity detils,
  ) {
    final List<Widget> tags = <Widget>[];
    final EnSentenceDetailV2Structure? structure = detils.structure;

    if (detils.difficulty != null) {
      final ConfigEntity configEntity = configController.appConfig.value;
      final DifficultieEntity? currentDifficulty = DifficultieUtils.getLanguageDifficultieLevel(
        configEntity,
        configController.userSetting.value.learningLang,
        detils.difficulty,
      );
      if (currentDifficulty != null) {
        final Color color = StatusUtils.getDifficultyBackgroundColor(detils.difficulty).color1;
        tags.add(
          WordInflectionInfoTagWidget(
            currentDifficulty.name?.text ?? '',
            textColor: color,
            bgColor: color.withValues(alpha: 0.12),
            borderColor: color.withValues(alpha: 0.20),
          ),
        );
      }
    }
    if ((_languageText(structure?.basicType?.name)).isNotEmpty) {
      tags.add(_buildSentenceTypeTag(structure?.basicType, isBasicType: true));
    }
    if ((_languageText(structure?.functionalType?.name)).isNotEmpty) {
      tags.add(_buildSentenceTypeTag(structure?.functionalType, isBasicType: false));
    }
    return tags;
  }

  List<InlineSpan> _buildDefinitionInlineSpans({
    required String definition,
    required List<Widget> tags,
  }) {
    final TextStyle definitionStyle = TextStyle(
      fontSize: 20.wMin,
      fontWeight: FontWeight.w500,
      color: AppTheme.cTextPrimary,
      height: 1.0,
    );
    final List<InlineSpan> spans = <InlineSpan>[];
    if (definition.isNotEmpty) {
      spans.add(TextSpan(text: definition, style: definitionStyle));
    }
    for (int index = 0; index < tags.length; index++) {
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: EdgeInsets.only(left: (definition.isNotEmpty || index > 0) ? 8.wMin : 0),
            child: tags[index],
          ),
        ),
      );
    }
    return spans;
  }

  Widget _buildAdaptiveSentenceTitle(
    String text,
    List<PronunciationsEntity> pronunciations,
  ) {
    const double minFontSize = 14;
    final double maxFontSize = 32.wMin;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final TextDirection textDirection = Directionality.of(context);
        double resolvedFontSize = minFontSize;

        for (double candidate = maxFontSize; candidate >= minFontSize; candidate -= 1) {
          final TextPainter textPainter = TextPainter(
            text: TextSpan(
              text: text,
              style: TextStyle(
                fontSize: candidate,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary,
                height: 1.0,
              ),
            ),
            textDirection: textDirection,
            maxLines: 3,
          )..layout(maxWidth: constraints.maxWidth);

          if (textPainter.didExceedMaxLines) {
            continue;
          }

          final List<LineMetrics> lineMetrics = textPainter.computeLineMetrics();
          if (lineMetrics.isEmpty || lineMetrics.length > 3) {
            continue;
          }

          final double scale = candidate / maxFontSize;
          final double pronunciationWidth = _measurePronunciationGroupWidth(
            pronunciations,
            scale,
            textDirection,
          );
          final double tailSpacing = pronunciations.isEmpty ? 0 : 8.wMin * scale;
          final double lastLineWidth = lineMetrics.last.width;

          if (lastLineWidth + tailSpacing + pronunciationWidth <= constraints.maxWidth) {
            resolvedFontSize = candidate;
            break;
          }
        }

        final double scale = resolvedFontSize / maxFontSize;
        return RichText(
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            style: TextStyle(
              fontSize: resolvedFontSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary,
              height: 1.0,
            ),
            children: [
              TextSpan(text: text),
              if (pronunciations.isNotEmpty)
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.wMin * scale),
                    child: _buildPronunciationGroup(pronunciations, scale: scale),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  double _measurePronunciationGroupWidth(
    List<PronunciationsEntity> pronunciations,
    double scale,
    TextDirection textDirection,
  ) {
    if (pronunciations.isEmpty) return 0;

    double width = 0;
    final List<PronunciationsEntity> items = pronunciations.take(2).toList();
    for (int index = 0; index < items.length; index++) {
      width += _measurePronunciationButtonWidth(
        _resolvePronunciationLabel(items[index]),
        scale,
        textDirection,
      );
      if (index != items.length - 1) {
        width += 6.wMin * scale;
      }
    }
    return width;
  }

  double _measurePronunciationButtonWidth(
    String label,
    double scale,
    TextDirection textDirection,
  ) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 16.wMin * scale,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: textDirection,
    )..layout();

    return 12.wMin * scale * 2 + 16.wMin * scale + 6.wMin * scale + textPainter.width;
  }

  Widget _buildPronunciationGroup(
    List<PronunciationsEntity> pronunciations, {
    double scale = 1,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: pronunciations.take(2).map((PronunciationsEntity pronunciation) {
        return Padding(
          padding: EdgeInsets.only(right: 6.wMin * scale),
          child: _buildPronunciationButton(pronunciation, scale: scale),
        );
      }).toList(),
    );
  }

  Widget _buildPronunciationButton(
    PronunciationsEntity pronunciation, {
    double scale = 1,
  }) {
    final String audioUrl = pronunciation.audioUrl ?? '';
    final String label = _resolvePronunciationLabel(pronunciation);
    final bool isPlaying = audioUrl.isNotEmpty && _playingAudioUrls.contains(audioUrl);

    return MouseRegion(
      cursor: audioUrl.isEmpty ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: audioUrl.isEmpty
            ? null
            : () async {
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
        child: AnimatedContainer(
          height: 32.wMin * scale,
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 12.wMin * scale),
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceTertiary.color,
            borderRadius: BorderRadius.circular(999.wMin),
            border: Border.all(color: AppTheme.cBorderPrimary.color),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimationPlayIconWidget(
                isPlaying: isPlaying,
                size: 16.wMin * scale,
                color: AppTheme.cTextSecondary.color,
              ),
              SizedBox(width: 6.wMin * scale),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16.wMin * scale,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _resolvePronunciationLabel(PronunciationsEntity pronunciation) {
    final String national = (pronunciation.national ?? '').trim().toUpperCase();
    if (national.isNotEmpty) return national;
    return (pronunciation.nationalTitle ?? '').contains('英') ? 'UK' : 'US';
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

  Widget _buildPracticeActionButton(List<PronunciationsEntity> pronunciations) {
    final String national = _resolvePracticePronunciationNational(pronunciations);
    return TapScaleWidget(
      onTap: national.isEmpty
          ? null
          : () {
              ReviewExerciseUtils.toEval(
                widget.controller.sentenceDetils.value.contentType,
                widget.controller.sentenceDetils.value.contentId,
                (widget.controller.sentenceDetils.value.semanticId ?? 0) > 0
                    ? widget.controller.sentenceDetils.value.semanticId
                    : null,
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

  EnSentenceDetailV2AnalysisEntry? _findAnalysisEntry(
    List<EnSentenceDetailV2AnalysisEntry?>? entries,
    String type,
  ) {
    for (final EnSentenceDetailV2AnalysisEntry? entry in entries ?? <EnSentenceDetailV2AnalysisEntry?>[]) {
      if ((entry?.type ?? '').toLowerCase() == type) {
        return entry;
      }
    }
    return null;
  }

  Future<void> _handleMemoryAction(BuildContext context, EnSentenceDetailV2Entity detils) async {
    if (detils.contentId == null || (detils.contentType ?? '').isEmpty) {
      ToastUtils.showToast(text: '缺少加入记忆参数2');
      return;
    }
    final SimpleDictionaryAddCardParm parameter = SimpleDictionaryAddCardParm(
      uid: detils.contentId,
      type: detils.contentType,
      semanticId: (detils.semanticId ?? 0) > 0 ? detils.semanticId : null,
    );
    final bool resp = await SimpleDictionaryDialog.addKnowledgeCard(
      context: context,
      parameter: <SimpleDictionaryAddCardParm>[parameter],
    );
    if (!resp) return;
    ToastUtils.showToast(text: '添加成功', type: ToastType.success);
    controller.sentenceDetils.update((value) {
      value?.favorited = true;
    });
    final DictionaryController? dictionaryController = DictionaryController.registered;
    if (dictionaryController != null) {
      await dictionaryController.refreshList(showLoading: false);
    }
  }

  Widget _buildBlueprintSection(BuildContext context, EnSentenceDetailV2Structure? structure) {
    final List<String> blueprintFallbackTags = _glossTagTexts(structure?.blueprintTags);
    final String patternName = _languageTextByCode(structure?.blueprint?.patternName, 'zh').isNotEmpty
        ? _languageTextByCode(structure?.blueprint?.patternName, 'zh')
        : (blueprintFallbackTags.isNotEmpty ? blueprintFallbackTags.first : '');
    final String scopeName = _languageTextByCode(structure?.blueprint?.blueprintScopeName, 'zh').isNotEmpty
        ? _languageTextByCode(structure?.blueprint?.blueprintScopeName, 'zh')
        : (blueprintFallbackTags.length > 1 ? blueprintFallbackTags[1] : '');
    final List<ZhenxieSentenceMemberSegmentEntity> segments = _buildBlueprintSegmentList(structure?.blueprint?.segmentList);
    if (patternName.isEmpty && scopeName.isEmpty && segments.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentBase,
        borderRadius: BorderRadius.circular(26.wMin),
        border: Border.all(
          color: AppTheme.cBorderTranslucentThin,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (patternName.isNotEmpty || scopeName.isNotEmpty)
                    Wrap(
                      spacing: 10.wMin,
                      runSpacing: 10.wMin,
                      children: [
                        if (patternName.isNotEmpty)
                          _buildBlueprintInfoTag(
                            text: patternName,
                            backgroundColor: AppTheme.cSurfaceTranslucentBase,
                            borderColor: AppTheme.cSurfaceLayerElevated,
                            textColor: AppTheme.cTextSecondary,
                          ),
                        if (scopeName.isNotEmpty)
                          _buildBlueprintInfoTag(
                            text: scopeName,
                            backgroundColor: AppTheme.cSurfaceTranslucentBase,
                            borderColor: AppTheme.cSurfaceLayerElevated,
                            textColor: AppTheme.cTextSecondary,
                          ),
                      ],
                    ),
                  if (segments.isNotEmpty) ...[
                    if (patternName.isNotEmpty || scopeName.isNotEmpty) SizedBox(height: 8.wMin),
                    SentenceSlotExampleWidget(
                      content: structure?.blueprint?.content,
                      segmentList: segments,
                      onExpandedChanged: (bool expanded) {
                        if (_blueprintExpanded == expanded) return;
                        setState(() {
                          _blueprintExpanded = expanded;
                        });
                      },
                      onSlotTap: (ZhenxieSentenceMemberSegmentEntity segment) {
                        final String chipText = _languageTextByCode(segment.slot?.name, 'zh').isNotEmpty
                            ? _languageTextByCode(segment.slot?.name, 'zh')
                            : _languageText(segment.slot?.name);
                        final Color primaryColor = ColorUtils.parseColor(segment.slot?.color) ?? AppTheme.cTextBrand.color;
                        final String zhText = _languageTextByCode(segment.slot?.description, 'zh');
                        final String enText = _languageTextByCode(segment.slot?.description, 'en');
                        showCupertinoDialog<void>(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return DialogUserWidget(
                              title: '槽位详情',
                              width: 960.wMin,
                              physics: const ClampingScrollPhysics(),
                              child: ElementsSentenceDialogBodyWidget(
                                chipText: chipText,
                                titleText: segment.text ?? '',
                                chipTextColor: primaryColor,
                                chipBackground: primaryColor.withValues(alpha: 0.12),
                                chipBorderColor: primaryColor.withValues(alpha: 0.20),
                                zhText: zhText,
                                enText: enText,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceTypeTag(
    EnSentenceDetailV2NidInfo? info, {
    required bool isBasicType,
  }) {
    final String text = _languageText(info?.name);
    if (text.isEmpty) return const SizedBox.shrink();
    final ConfigController? configController = Get.isRegistered<ConfigController>() ? Get.find<ConfigController>() : null;
    final List<LanguageConfigColorEntityInfo?>? colorConfigs =
        isBasicType ? configController?.colorConfigs.value.basicLevels : configController?.colorConfigs.value.functionalLevels;
    LanguageConfigColorEntityInfo? colorConfig;
    for (final LanguageConfigColorEntityInfo item
        in (colorConfigs ?? <LanguageConfigColorEntityInfo?>[]).whereType<LanguageConfigColorEntityInfo>()) {
      if ((item.code ?? '').toLowerCase() == (info?.nid ?? '').toLowerCase()) {
        colorConfig = item;
        break;
      }
    }
    final Color? primaryColor = ColorUtils.parseColor(colorConfig?.color?.textColor);
    if (primaryColor == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.wMin),
        border: Border.all(color: primaryColor.withValues(alpha: 0.20), width: 1.wMin),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.wMin,
          fontWeight: FontWeight.w400,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildAnalysisEntryCard(EnSentenceDetailV2Entity detils, EnSentenceDetailV2AnalysisEntry entry) {
    final Color primaryColor = ColorUtils.parseColor(entry.color?.from) ?? AppTheme.cBgBrand;
    final Color secondaryColor = ColorUtils.parseColor(entry.color?.to) ?? primaryColor.withValues(alpha: 0.7);
    final bool isAvailable = entry.status == 1;
    final bool isPending = entry.status == 2;
    final bool isNoData = entry.status == 3;
    final String title = _languageText(entry.title);
    final String titleZh = _languageTextByCode(entry.title, 'zh');
    final String titleEn = _languageTextByCode(entry.title, 'en');

    return ElementsAnalysisCardWidget(
      chineseTitle: titleZh.isNotEmpty ? titleZh : title,
      englishTitle: titleEn,
      index: entry.index,
      fromColor: primaryColor,
      toColor: secondaryColor,
      onTap: () {
        if (isAvailable) {
          ElementsSentenceAnalysisView.to(
            tag: '${tagText}_${entry.type ?? 'chunks'}',
            arguments: {
              'contentId': controller.contentId,
              'layer': entry.type ?? controller.analysisLayer.value,
              'module': controller.jumpType,
            },
          );
          return;
        }
        if (isNoData) {
          ToastUtils.showToast(
            text: entry.learnTip ?? '当前句子暂无${title.isNotEmpty ? title : '该分析'}数据',
          );
          return;
        }
        if (isPending) {
          ToastUtils.showToast(
            text: entry.learnTip ?? '${title.isNotEmpty ? title : '该分析'}正在建设中',
          );
          return;
        }
      },
      child: _buildAnalysisEntryContent(detils, entry),
    );
  }

  /// 句子分析卡片只保留内容区，头部和底部统一复用公共卡片外壳。
  Widget _buildAnalysisEntryContent(EnSentenceDetailV2Entity detils, EnSentenceDetailV2AnalysisEntry entry) {
    if (entry.type == 'relations') {
      final List<EnSentenceDetailV2RelationItem> relationItems =
          (detils.analysisData?.relations?.items ?? <EnSentenceDetailV2RelationItem?>[])
              .whereType<EnSentenceDetailV2RelationItem>()
              .toList();
      if (relationItems.isNotEmpty) {
        return _buildRelationsPreviewGrid(relationItems);
      }
      return _buildAnalysisEntryDescription(entry.description ?? '');
    }
    return _buildAnalysisEntryDescription(entry.description ?? '');
  }

  /// 关联卡片内容区改为单行关系预览，不再展示描述文案。
  Widget _buildRelationsPreviewGrid(List<EnSentenceDetailV2RelationItem> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.fromLTRB(20.wMin, 0, 20.wMin, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: data.asMap().entries.map((entry) {
          final int index = entry.key;
          final EnSentenceDetailV2RelationItem item = entry.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == data.length - 1 ? 0 : 8.wMin),
              child: SizedBox(
                height: 56.wMin,
                child: _buildRelationPreviewItem(item),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRelationPreviewItem(EnSentenceDetailV2RelationItem item) {
    final Color dotColor = ColorUtils.parseColor(item.color) ?? AppTheme.cTextBrand.color;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentBase,
        borderRadius: BorderRadius.circular(6.wMin),
        border: Border.all(
          color: AppTheme.cBorderTranslucentThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8.wMin,
            height: 8.wMin,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.wMin),
          Expanded(
            child: Text(
              item.title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary,
              ),
            ),
          ),
          SizedBox(width: 8.wMin),
          Text(
            '${item.previewCount ?? 0}',
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlueprintInfoTag({
    required String text,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999.wMin),
        border: Border.all(color: borderColor, width: 1.wMin),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20.wMin,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _languageText(List<LanguageText?>? texts) {
    final LanguageText? text = LearningLangUtils.getShowLList(texts);
    return text?.text ?? '';
  }

  List<String> _glossTagTexts(List<EnSentenceDetailV2GlossTag?>? tags) {
    return (tags ?? <EnSentenceDetailV2GlossTag?>[])
        .whereType<EnSentenceDetailV2GlossTag>()
        .map((EnSentenceDetailV2GlossTag item) => _languageText(item.gloss))
        .where((String item) => item.isNotEmpty)
        .toList();
  }

  String _languageTextByCode(List<LanguageText?>? texts, String langCode) {
    for (final LanguageText? item in texts ?? <LanguageText?>[]) {
      if ((item?.lang ?? '').toLowerCase() == langCode) {
        return item?.text ?? '';
      }
    }
    return '';
  }

  List<ZhenxieSentenceMemberSegmentEntity> _buildBlueprintSegmentList(
    List<EnSentenceDetailV2PatternSegment?>? segments,
  ) {
    return (segments ?? <EnSentenceDetailV2PatternSegment?>[])
        .whereType<EnSentenceDetailV2PatternSegment>()
        .map(_buildBlueprintSegmentEntity)
        .toList();
  }

  ZhenxieSentenceMemberSegmentEntity _buildBlueprintSegmentEntity(
    EnSentenceDetailV2PatternSegment segment,
  ) {
    return ZhenxieSentenceMemberSegmentEntity(
      slotKey: segment.slotKey,
      slot: _buildZhenxieNamedInfo(segment.slot),
      required: segment.required,
      grammarControlling: segment.grammarControlling,
      growthPriority: segment.growthPriority,
      dependsOn: segment.dependsOn,
      text: segment.text,
      renderSlotKey: segment.renderSlotKey,
      sourceSlotKey: segment.sourceSlotKey,
      sourceSlot: _buildZhenxieNamedInfo(segment.sourceSlot),
      slotUid: segment.slotUid,
      semanticIds: segment.semanticIds,
      literal: segment.literal,
      hasChildStruct: segment.hasChildStruct,
      childStruct: _buildBlueprintChildStruct(segment.childStruct),
    );
  }

  ZhenxieSentenceMemberSegmentChildStructEntity? _buildBlueprintChildStruct(
    EnSentenceDetailV2PatternChildStruct? childStruct,
  ) {
    if (childStruct == null) return null;
    return ZhenxieSentenceMemberSegmentChildStructEntity(
      structType: childStruct.structType,
      rootClauseId: childStruct.rootClauseId,
      clauseIdList: childStruct.clauseIdList,
      content: childStruct.content,
      patternNid: childStruct.patternNid,
      patternTemplate: childStruct.patternTemplate,
      clauseType: childStruct.clauseType,
      patternName: childStruct.patternName,
      patternDescription: childStruct.patternDescription,
      segmentList: _buildBlueprintSegmentList(childStruct.segmentList),
    );
  }

  ZhenxieSentenceMemberNamedInfoEntity? _buildZhenxieNamedInfo(
    EnSentenceDetailV2NidInfo? slot,
  ) {
    if (slot == null) return null;
    return ZhenxieSentenceMemberNamedInfoEntity(
      nid: slot.nid,
      name: slot.name,
      description: slot.description,
      color: slot.color,
    );
  }

  Widget _buildAnalysisEntryDescription(String description) {
    if (description.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.fromLTRB(20.wMin, 21.wMin, 20.wMin, 16.wMin),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final TextStyle style = TextStyle(
            fontSize: 22.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary,
          );
          final TextPainter painter = TextPainter(
            text: TextSpan(text: 'A', style: style),
            textDirection: TextDirection.ltr,
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          final double lineHeight = painter.preferredLineHeight;
          final int maxLines = constraints.maxHeight >= lineHeight * 2 ? 2 : 1;
          return Align(
            alignment: Alignment.topLeft,
            child: Text(
              description,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          );
        },
      ),
    );
  }

  bool _hasBlueprintSection(EnSentenceDetailV2Structure? structure) {
    final List<String> blueprintFallbackTags = _glossTagTexts(structure?.blueprintTags);
    final String patternName = _languageTextByCode(structure?.blueprint?.patternName, 'zh').isNotEmpty
        ? _languageTextByCode(structure?.blueprint?.patternName, 'zh')
        : (blueprintFallbackTags.isNotEmpty ? blueprintFallbackTags.first : '');
    final String scopeName = _languageTextByCode(structure?.blueprint?.blueprintScopeName, 'zh').isNotEmpty
        ? _languageTextByCode(structure?.blueprint?.blueprintScopeName, 'zh')
        : (blueprintFallbackTags.length > 1 ? blueprintFallbackTags[1] : '');
    final List<ZhenxieSentenceMemberSegmentEntity> segments = _buildBlueprintSegmentList(structure?.blueprint?.segmentList);
    return patternName.isNotEmpty || scopeName.isNotEmpty || segments.isNotEmpty;
  }
}
