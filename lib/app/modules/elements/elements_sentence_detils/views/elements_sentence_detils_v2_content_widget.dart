import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../common/elements_memory_action_button.dart';
import '../../common/elements_public_widgets.dart';
import '../controllers/elements_sentence_detils_v2_controller.dart';
import 'elements_sentence_analysis_view.dart';
import 'elements_sentence_pronunciation_widget.dart';

class ElementsSentenceDetilsV2ContentWidget extends StatelessWidget {
  final ElementsSentenceDetilsV2Controller controller;
  final String tagText;

  const ElementsSentenceDetilsV2ContentWidget({
    super.key,
    required this.controller,
    required this.tagText,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final EnSentenceDetailV2Entity detils = controller.sentenceDetils.value;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLeftPanel(detils),
          SizedBox(width: 24.wMin),
          Expanded(
            child: _buildRightPanel(context, detils),
          ),
        ],
      );
    });
  }

  /// 左侧媒体区继续复用旧句子详情页结构，不纳入本次 V2 UI 重构范围。
  Widget _buildLeftPanel(EnSentenceDetailV2Entity detils) {
    final double leftWidth = 510.wMin;
    return SizedBox(
      width: leftWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: leftWidth,
            height: leftWidth,
            child: ElementsSemanticVideoCardWidget(
              imageUrl: detils.media?.imageUrl,
              relationVideo: detils.media?.video,
              pronunciations: detils.media?.pronunciations,
              semanticPlaybackKey: '${detils.contentId ?? 0}',
              size: double.infinity,
              showPronunciationOverlay: false,
            ),
          ),
          SizedBox(height: 12.wMin),
          ElementsSentencePronunciationWidget(
            pronunciations: detils.media?.pronunciations,
            contentType: detils.contentType,
            contentId: detils.contentId,
            content: detils.content,
            onTap: (int index) {
              controller.englishAmericanType.value = index;
            },
            englishAmericanType: controller.englishAmericanType.value,
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(BuildContext context, EnSentenceDetailV2Entity detils) {
    return Column(
      children: [
        _buildTopSection(context, detils),
        SizedBox(height: 24.wMin),
        Expanded(
          child: _buildAnalysisEntrySection(detils.analysisEntries),
        ),
      ],
    );
  }

  Widget _buildTopSection(BuildContext context, EnSentenceDetailV2Entity detils) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSentenceTypeTags(detils.structure),
          SizedBox(height: 12.wMin),
          _buildDescriptionRow(context, detils),
          _buildBlueprintSection(context, detils.structure),
        ],
      ),
    );
  }

  Widget _buildDescriptionRow(BuildContext context, EnSentenceDetailV2Entity detils) {
    final ConfigController configController = Get.find<ConfigController>();
    final String rawPreferenceCode = configController.userSetting.value.expandLang.code;
    final String preferenceCode = rawPreferenceCode.isEmpty || rawPreferenceCode == 'none'
        ? 'original'
        : rawPreferenceCode == 'translation'
            ? 'bilingual'
            : rawPreferenceCode;
    final bool showOriginal = preferenceCode != 'translation';
    final bool showTranslate = preferenceCode == 'bilingual' || preferenceCode == 'translation';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showOriginal && (detils.content ?? '').isNotEmpty)
                Text(
                  detils.content ?? '',
                  style: TextStyle(
                    fontSize: 30.wMin,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.cTextPrimary,
                  ),
                ),
              if (showTranslate && (detils.definition ?? '').isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 8.wMin),
                  child: Text(
                    detils.definition ?? '',
                    style: TextStyle(
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: 16.wMin),
        SizedBox(
          width: 180.wMin,
          child: _buildMemoryButton(context, detils),
        ),
      ],
    );
  }

  Widget _buildSentenceTypeTags(EnSentenceDetailV2Structure? structure) {
    final List<Widget> children = [];
    if ((_languageText(structure?.basicType?.name)).isNotEmpty) {
      children.add(_buildSentenceTypeTag(structure?.basicType, isBasicType: true));
    }
    if ((_languageText(structure?.functionalType?.name)).isNotEmpty) {
      children.add(_buildSentenceTypeTag(structure?.functionalType, isBasicType: false));
    }
    if (children.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 10.wMin,
      runSpacing: 10.wMin,
      children: children,
    );
  }

  Widget _buildMemoryButton(BuildContext context, EnSentenceDetailV2Entity detils) {
    return Obx(() {
      final bool isFavorited = controller.isFavorited.value;
      return ElementsMemoryActionButton(
        favorited: isFavorited,
        onTap: () => _handleMemoryAction(context, detils),
        color: AppTheme.cMorphemeCardColor1.color,
      );
    });
  }

  Future<void> _handleMemoryAction(BuildContext context, EnSentenceDetailV2Entity detils) async {
    final SimpleDictionaryAddCardParm parameter = SimpleDictionaryAddCardParm(
      uid: detils.contentId,
      type: detils.contentType,
      semanticId: controller.resolveCurrentSemanticId(),
    );
    await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: AppTheme.cBlackAlpha50,
      builder: (BuildContext dialogContext) {
        return ElementsDetailsModuleDialog(
          title: '记句子',
          backgroundColor: AppTheme.cMemoryPrimary,
          imageUrl: detils.media?.imageUrl,
          body: _buildMemoryDialogHeader(detils),
          footer: _buildMemoryDialogFooter(dialogContext, parameter),
        );
      },
    );
  }

  Widget _buildMemoryDialogHeader(EnSentenceDetailV2Entity detils) {
    final ConfigController configController = Get.find<ConfigController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                detils.content ?? '',
                style: TextStyle(
                  fontSize: 32.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary,
                  height: 1.4,
                ),
              ),
            ),
            Visibility(
              visible: detils.difficulty != null,
              child: Container(
                margin: EdgeInsets.only(left: 12.wMin),
                child: StatusTagDifficultyWidget(
                  difficulty: detils.difficulty,
                  language: configController.userSetting.value.learningLang,
                  fontSize: 22.wMin,
                ),
              ),
            ),
          ],
        ),
        if ((detils.definition ?? '').isNotEmpty) ...[
          SizedBox(height: 12.wMin),
          Text(
            detils.definition ?? '',
            style: TextStyle(
              fontSize: 26.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMemoryDialogFooter(
    BuildContext dialogContext,
    SimpleDictionaryAddCardParm parameter,
  ) {
    return Obx(() {
      final bool isFavorited = controller.isFavorited.value;
      final Color buttonColor = isFavorited ? AppTheme.cSurfaceQuaternary : AppTheme.cMemoryPrimary;
      final Color textColor = isFavorited ? AppTheme.cTextSecondary : AppTheme.cStaticWhite;
      return Align(
        alignment: Alignment.centerRight,
        child: TapScaleWidget(
          onTap: isFavorited
              ? null
              : () async {
                  final bool resp = await SimpleDictionaryDialog.addKnowledgeCard(
                    context: dialogContext,
                    parameter: [parameter],
                  );
                  if (!resp) return;
                  controller.isFavorited.value = true;
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(true);
                  }
                },
          sclae: isFavorited ? 1 : 1.02,
          child: Container(
            width: 220.wMin,
            height: 72.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(999.wMin),
            ),
            child: Text(
              isFavorited ? '已记忆' : '记句子',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBlueprintSection(BuildContext context, EnSentenceDetailV2Structure? structure) {
    final List<String> blueprintFallbackTags = _glossTagTexts(structure?.blueprintTags);
    final String patternName = _languageTextByCode(structure?.blueprint?.patternName, 'zh').isNotEmpty
        ? _languageTextByCode(structure?.blueprint?.patternName, 'zh')
        : (blueprintFallbackTags.isNotEmpty ? blueprintFallbackTags.first : '');
    final String scopeName = _languageTextByCode(structure?.blueprint?.blueprintScopeName, 'zh').isNotEmpty
        ? _languageTextByCode(structure?.blueprint?.blueprintScopeName, 'zh')
        : (blueprintFallbackTags.length > 1 ? blueprintFallbackTags[1] : '');
    final List<PatternBlueprintSentenceBriefSegmentEntity> segments = _buildBlueprintSegmentList(structure?.blueprint?.segmentList);
    if (patternName.isEmpty && scopeName.isEmpty && segments.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(top: 12.wMin),
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
            if (patternName.isNotEmpty || scopeName.isNotEmpty) SizedBox(height: 18.wMin),
            SentenceSlotExampleWidget(
              segmentList: segments,
              showCopyTags: false,
              onSlotTap: (PatternBlueprintSentenceBriefSegmentEntity segment) {
                SlotSentenceExampleDialog.show(
                  context: context,
                  segment: segment,
                  nid: structure?.blueprint?.patternNid ?? '',
                  sentenceId: structure?.blueprint?.sentenceId,
                );
              },
            ),
          ],
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
        border: Border.all(color: primaryColor.withValues(alpha: 0.30), width: 1.wMin),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20.wMin,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildAnalysisEntrySection(List<EnSentenceDetailV2AnalysisEntry?>? entries) {
    final List<EnSentenceDetailV2AnalysisEntry> data =
        (entries ?? <EnSentenceDetailV2AnalysisEntry?>[]).whereType<EnSentenceDetailV2AnalysisEntry>().toList();
    if (data.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int rowCount = ((data.length + 1) ~/ 2).clamp(1, data.length);
        final double rowSpacing = 16.wMin;
        final double totalSpacing = rowSpacing * (rowCount - 1);
        final double itemHeight = (constraints.maxHeight - totalSpacing) / rowCount;
        return GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.wMin,
            mainAxisSpacing: rowSpacing,
            mainAxisExtent: itemHeight,
          ),
          itemBuilder: (BuildContext context, int index) {
            return _buildAnalysisEntryCard(data[index]);
          },
        );
      },
    );
  }

  Widget _buildAnalysisEntryCard(EnSentenceDetailV2AnalysisEntry entry) {
    final Color primaryColor = ColorUtils.parseColor(entry.color?.from) ?? AppTheme.cBgBrand;
    final Color secondaryColor = ColorUtils.parseColor(entry.color?.to) ?? primaryColor.withValues(alpha: 0.7);
    final bool isAvailable = entry.status == 1;
    final bool isPending = entry.status == 2;
    final bool isNoData = entry.status == 3;
    final String title = _languageText(entry.title);
    final String titleZh = _languageTextByCode(entry.title, 'zh');
    final String titleEn = _languageTextByCode(entry.title, 'en');
    final String indexText = _entryIndexText(entry.index);

    return TapScaleWidget(
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
      sclae: 1.02,
      child: Container(
        padding: EdgeInsets.all(12.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceTranslucentBase,
          borderRadius: BorderRadius.circular(26.wMin),
          border: Border.all(
            color: AppTheme.cBorderTranslucentThin,
            width: 1.wMin,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Text(
                indexText,
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextTertiary,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAnalysisEntryIcon(
                      iconUrl: entry.iconUrl,
                      primaryColor: primaryColor,
                      secondaryColor: secondaryColor,
                    ),
                    SizedBox(width: 16.wMin),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 2.wMin, right: 52.wMin),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 10.wMin,
                              runSpacing: 6.wMin,
                              children: [
                                Text(
                                  titleZh.isNotEmpty ? titleZh : title,
                                  style: TextStyle(
                                    fontSize: 28.wMin,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.cTextPrimary,
                                  ),
                                ),
                                if (titleEn.isNotEmpty)
                                  Text(
                                    titleEn.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 16.wMin,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 1.2,
                                      color: AppTheme.cTextTertiary,
                                    ),
                                  ),
                              ],
                            ),
                            // SizedBox(height: 30.wMin),
                            Text(
                              _analysisEntryHintText(entry.status),
                              style: TextStyle(
                                fontSize: 18.wMin,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.cTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 13.wMin),
                Flexible(
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      final TextStyle style = TextStyle(
                        fontSize: 22.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextTertiary,
                        // height: 1.45,
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
                          entry.description ?? '',
                          maxLines: maxLines,
                          overflow: TextOverflow.ellipsis,
                          style: style,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 14.wMin),
                Row(
                  children: [

                    TagButtonWidget(text:_statusText(entry.status)),
                    
                    const Spacer(),
                    Text(
                      _analysisEntryActionText(entry, titleZh.isNotEmpty ? titleZh : title),
                      style: TextStyle(
                        fontSize: 20.wMin,
                        fontWeight: FontWeight.w500,
                        color: isAvailable ? AppTheme.cTextPrimary : AppTheme.cTextPrimary.withValues(alpha: 0.42),
                      ),
                    ),
                    if (isAvailable)
                      Icon(Icons.chevron_right,color:AppTheme.cTextPrimary ,),
                  ],
                ),
              ],
            ),
          ],
        ),
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
    final List<LanguageText> list = LearningLangUtils.getShowLBList(texts);
    return list.map((LanguageText item) => item.text ?? '').join(' ').trim();
  }

  List<String> _glossTagTexts(List<EnSentenceDetailV2GlossTag?>? tags) {
    return (tags ?? <EnSentenceDetailV2GlossTag?>[])
        .whereType<EnSentenceDetailV2GlossTag>()
        .map((EnSentenceDetailV2GlossTag item) => _languageText(item.gloss))
        .where((String item) => item.isNotEmpty)
        .toList();
  }

  String _statusText(int? status) {
    if (status == 1) return '可进入';
    if (status == 2) return '即将开放';
    if (status == 3) return '暂未开放';
    return '';
  }

  String _entryIndexText(int? index) {
    if (index == null) return '--';
    return index.toString().padLeft(2, '0');
  }

  Widget _buildAnalysisEntryIcon({
    required String? iconUrl,
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    return Container(
      width: 64.wMin,
      height: 64.wMin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, secondaryColor],
        ),
        borderRadius: BorderRadius.circular(18.wMin),
      ),
      child: iconUrl == null || iconUrl.isEmpty
          ? Icon(
              Icons.auto_awesome_mosaic_rounded,
              size: 34.wMin,
              color: Colors.white,
            )
          : Padding(
              padding: EdgeInsets.all(12.wMin),
              child: SvgPicture.network(
                iconUrl,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                placeholderBuilder: (BuildContext context) {
                  return Icon(
                    Icons.auto_awesome_mosaic_rounded,
                    size: 34.wMin,
                    color: Colors.white,
                  );
                },
              ),
            ),
    );
  }

  String _languageTextByCode(List<LanguageText?>? texts, String langCode) {
    for (final LanguageText? item in texts ?? <LanguageText?>[]) {
      if ((item?.lang ?? '').toLowerCase() == langCode) {
        return item?.text ?? '';
      }
    }
    return '';
  }

  String _analysisEntryHintText(int? status) {
    if (status == 1) return '点击进入';
    if (status == 2) return '即将开放';
    if (status == 3) return '暂未开放';
    return '';
  }

  String _analysisEntryActionText(EnSentenceDetailV2AnalysisEntry entry, String title) {
    if (entry.status == 1) return '打开$title';
    if (entry.status == 2) return '等待开放';
    if (entry.status == 3) return '暂无数据';
    return '';
  }

  List<PatternBlueprintSentenceBriefSegmentEntity> _buildBlueprintSegmentList(
    List<EnSentenceDetailV2PatternSegment?>? segments,
  ) {
    return (segments ?? <EnSentenceDetailV2PatternSegment?>[])
        .whereType<EnSentenceDetailV2PatternSegment>()
        .map(_buildBlueprintSegmentEntity)
        .toList();
  }

  PatternBlueprintSentenceBriefSegmentEntity _buildBlueprintSegmentEntity(
    EnSentenceDetailV2PatternSegment segment,
  ) {
    return PatternBlueprintSentenceBriefSegmentEntity(
      slotKey: segment.slotKey,
      slot: _buildPatternNamedInfo(segment.slot),
      required: segment.required,
      grammarControlling: segment.grammarControlling,
      growthPriority: segment.growthPriority,
      dependsOn: segment.dependsOn,
      text: segment.text,
      renderSlotKey: segment.renderSlotKey,
      sourceSlotKey: segment.sourceSlotKey,
      sourceSlot: _buildPatternNamedInfo(segment.sourceSlot),
      slotUid: segment.slotUid,
      semanticIds: segment.semanticIds,
      literal: segment.literal,
      hasChildStruct: segment.hasChildStruct,
      childStruct: _buildBlueprintChildStruct(segment.childStruct),
    );
  }

  PatternBlueprintSentenceBriefSegmentChildStructEntity? _buildBlueprintChildStruct(
    EnSentenceDetailV2PatternChildStruct? childStruct,
  ) {
    if (childStruct == null) return null;
    return PatternBlueprintSentenceBriefSegmentChildStructEntity(
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

  PatternBlueprintNamedInfoEntity? _buildPatternNamedInfo(
    EnSentenceDetailV2NidInfo? slot,
  ) {
    if (slot == null) return null;
    return PatternBlueprintNamedInfoEntity(
      nid: slot.nid,
      name: slot.name,
      description: slot.description,
      color: slot.color,
    );
  }
}
