import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/values/app_font_value.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/theme/theme_utils.dart';
import 'package:langwise/utils/difficultie_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../management/common/commons.dart';
import '../zhenxie_composition_writing/models/zhenxie_composition_writing_models.dart';
import 'zhenxie_beat_utils.dart';
import 'zhenxie_composition_slot_strip_widget.dart';
import 'zhenxie_write_catalog_card_data.dart';

class ZhenxieWriteCatalogCardWidget extends StatelessWidget {
  final StageCardData? stageData;
  final ContentCardData? contentData;
  final double height;
  final String? copyLabel;
  final Widget? coverOverlay;
  final Widget? cardOverlay;
  final Widget? actions;
  final VoidCallback? onTap;
  final bool showCopyTag;
  final bool isManagement;
  final Color? borderColor;
  final String? issueTimeText;

  const ZhenxieWriteCatalogCardWidget({
    super.key,
    this.stageData,
    this.contentData,
    required this.height,
    this.copyLabel,
    this.coverOverlay,
    this.cardOverlay,
    this.actions,
    this.onTap,
    this.showCopyTag = true,
    this.isManagement = true,
    this.borderColor,
    this.issueTimeText,
  }) : assert(
          (stageData != null || contentData != null) && !(stageData != null && contentData != null),
          'stageData 和 contentData 必须二选一传入',
        );

  @override
  Widget build(BuildContext context) {
    final StageCardData? currentStageData = stageData ?? contentData?.stage;
    final String title = _getTitleText();
    final String titleEn = _getTitleText(lang: 'en');
    final String entityValue = stageData?.nid ?? contentData?.uid?.toString() ?? '';
    final CompositionTaskMemberWritingStatusModel? memberWritingStatus = contentData?.memberWritingStatus;
    final bool shouldShowMemberWritingStatus = _shouldShowMemberWritingStatus(memberWritingStatus);
    final String description = stageData != null ? _getLangText(stageData?.description, 'zh') : _getLangText(contentData?.stem, 'zh');
    final String difficultyLabel = _getDifficultyLabel();
    final String blueprintLabel = _getBlueprintLabel();
    final String genreLabel = _getGenreLabel();
    final Color? genreColor = _getGenreColor();
    final String answerTypeText = _getAnswerTypeText(currentStageData);
    final String answerDetailText = _getAnswerDetailText(currentStageData);
    final String displayAnswerDetailText = answerTypeText == '文字' ? '不设份数，按段写' : answerDetailText;
    final Widget slotStrip = _buildSlotStripWidget(currentStageData);
    final bool shouldShowCopyTag = showCopyTag && isManagement && (copyLabel ?? '').isNotEmpty;
    final List<Widget> infoTagChildren = <Widget>[
      if (difficultyLabel.isNotEmpty) WordInflectionInfoTagWidget(difficultyLabel),
      if (blueprintLabel.isNotEmpty) WordInflectionInfoTagWidget(blueprintLabel),
      if (genreLabel.isNotEmpty && genreColor != null)
        WordInflectionInfoTagWidget(
          genreLabel,
          textColor: genreColor,
          bgColor: genreColor.withValues(alpha: 0.12),
          borderColor: genreColor.withValues(alpha: 0.20),
        ),
    ];
    // AutoSizeText 要求 maxFontSize 与 stepGranularity 精确整除，整数步进可避免桌面端浮点断言。
    final double maxSize28 = 28.wMin.roundToDouble();
    final double minSize20 = 20.wMin.roundToDouble();
    final double maxSize = 18.wMin.roundToDouble();
    final double minSize = 14.wMin.roundToDouble();
    final Widget card = Container(
      height: height.wMin,
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentBase,
        borderRadius: BorderRadius.circular(28.wMin),
        border: Border.all(
          color: borderColor ?? AppTheme.cBorderThin.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 220.wMin,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(16.wMin)),
                      child: SizedBox(
                        width: double.infinity,
                        height: 220.wMin,
                        child: CachedImageWidget(
                          _getCoverUrl(),
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorWidget: buildEmptyWidget(fit: BoxFit.cover),
                          placeholder: buildEmptyWidget(fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    if (coverOverlay != null) Positioned.fill(child: coverOverlay!),
                  ],
                ),
              ),
              SizedBox(width: 16.wMin),
              Expanded(
                child: SizedBox(
                  height: 220.wMin,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isManagement)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((issueTimeText ?? '').isNotEmpty)
                              Text(
                                '下发 $issueTimeText',
                                style: TextStyle(
                                  fontSize: 16.wMin,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.cTextTertiary.color,
                                  height: 1.0,
                                ),
                              ),
                            Spacer(),
                            if (shouldShowMemberWritingStatus) _buildMemberWritingStatusWidget(memberWritingStatus!),
                          ],
                        ),
                      AutoSizeText(
                        title,
                        maxLines: 1,
                        maxFontSize: maxSize28,
                        minFontSize: minSize20,
                          stepGranularity: 1,
                        style: TextStyle(
                          fontSize: maxSize28,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFontValue.sourceHanSerifCN,
                          color: AppTheme.cTextPrimary.color,
                        ),
                      ),
                      if (titleEn.isNotEmpty) SizedBox(height: 6.wMin),
                      if (titleEn.isNotEmpty)
                        AutoSizeText(
                          titleEn,
                          maxLines: 1,
                          maxFontSize: maxSize,
                          minFontSize: minSize,
                            stepGranularity: 1,
                          style: TextStyle(
                            fontSize: maxSize,
                            fontWeight: FontWeight.w400,
                            fontFamily: AppFontValue.robotoMono,
                            color: AppTheme.cTextSecondary.color,
                          ),
                        ),
                      SizedBox(height: 6.wMin),
                      if (shouldShowCopyTag)
                        CopyTagWidget(
                          name: copyLabel!,
                          value: entityValue,
                          isShow: isManagement,
                        ),
                      if (infoTagChildren.isNotEmpty) SizedBox(height: 6.wMin),
                      if (infoTagChildren.isNotEmpty)
                        Wrap(
                          spacing: 4.wMin,
                          runSpacing: 4.wMin,
                          children: infoTagChildren,
                        ),
                      if (description.isNotEmpty) SizedBox(height: 6.wMin),
                      if (description.isNotEmpty)
                        AutoSizeText(
                          description,
                          maxLines: 2,
                          maxFontSize: maxSize,
                          minFontSize: minSize,
                            stepGranularity: 1,
                          style: TextStyle(
                            fontSize: maxSize,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextSecondary.color,
                          ),
                        ),
                      if (infoTagChildren.isNotEmpty) const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (answerTypeText.isNotEmpty) SizedBox(height: 16.wMin),
          if (answerTypeText.isNotEmpty) _buildAnswerFormWidget(answerTypeText, displayAnswerDetailText),
          if (answerTypeText.isNotEmpty) SizedBox(height: 16.wMin),
          slotStrip,
          if (actions != null) SizedBox(height: 16.wMin),
          if (actions != null) actions!,
        ],
      ),
    );
    Widget result = onTap == null
        ? card
        : TapScaleWidget(
            sclae: 1,
            onTap: onTap,
            child: card,
          );
    if (cardOverlay != null) {
      result = Stack(
        children: [
          result,
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28.wMin),
              child: cardOverlay!,
            ),
          ),
        ],
      );
    }
    return result;
  }

  Widget _buildAnswerFormWidget(String answerTypeText, String displayAnswerDetailText) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(7.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cZhenxieBackgroundPrimary,
        borderRadius: BorderRadius.circular(8.wMin),
        border: Border.all(
          color: AppTheme.cZhenxieBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 26.wMin,
            height: 26.wMin,
            decoration: BoxDecoration(
              color: AppTheme.cZhenxieColorPrimary.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6.wMin),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              _getAnswerTypeIconAsset(answerTypeText),
              width: 16.wMin,
              height: 16.wMin,
            ),
          ),
          SizedBox(width: 6.wMin),
          Text(
            '答案形式',
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieColorPrimary.color,
              height: 1.0,
            ),
          ),
          Spacer(),
          Row(
            spacing: 6.wMin,
            children: [
              Text(
                answerTypeText,
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cZhenxieFontPrimary.color,
                  height: 1.0,
                ),
              ),
              if (displayAnswerDetailText.isNotEmpty)
                Text(
                  displayAnswerDetailText,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontSecondary.color,
                    height: 1.0,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlotStripWidget(StageCardData? currentStageData) {
    if (currentStageData == null) return const SizedBox.shrink();
    final List<String> beatOrderList = zhenxieBeatOrderList.isNotEmpty
        ? zhenxieBeatOrderList
        : currentStageData.slots.map((item) => item.beatNid ?? '').where((item) => item.isNotEmpty).toList();
    return ZhenxieCompositionSlotStripWidget(
      stage: currentStageData.toCompositionStageModel(),
      beatMap: zhenxieBeatMap,
      beatOrderList: beatOrderList,
      langTextGetter: _getLangText,
      beatNameGetter: getZhenxieBeatName,
      headLabelGetter: (stage) => _getLangText(stage.headName, 'zh'),
      tailLabelGetter: (stage) => _getLangText(stage.tailName, 'zh'),
      hasHeadGetter: (stage) => stage.hasHead == true,
      hasTailGetter: (stage) => stage.hasTail == true,
    );
  }

  String _getCoverUrl() {
    return stageData?.coverUrl ?? contentData?.coverUrl ?? '';
  }

  String _getTitleText({String lang = 'zh'}) {
    if (stageData != null) return _getLangText(stageData?.name, lang);
    final List<LanguageText> values =
        contentData?.name.isNotEmpty == true ? contentData!.name : contentData?.title ?? const <LanguageText>[];
    return _getLangText(values, lang);
  }

  String _getDifficultyLabel() {
    final CardContentDifficulty? difficulty = stageData?.difficulty ?? contentData?.stage?.difficulty ?? contentData?.difficulty;
    final String minDifficultyLabel = DifficultieUtils.getLanguageDifficultieLevel1('en', difficulty?.min)?.name?.text ?? '';
    final String maxDifficultyLabel = DifficultieUtils.getLanguageDifficultieLevel1('en', difficulty?.max)?.name?.text ?? '';
    if (minDifficultyLabel.isEmpty || maxDifficultyLabel.isEmpty) return '';
    return minDifficultyLabel == maxDifficultyLabel ? minDifficultyLabel : '$minDifficultyLabel-$maxDifficultyLabel';
  }

  String _getBlueprintLabel() {
    final Map<String, dynamic>? blueprint = stageData?.compositionBlueprint ?? contentData?.blueprint;
    return _getLangText(_parseLanguageTexts(blueprint?['name']), 'zh');
  }

  String _getGenreLabel() {
    final String? genreNid = stageData?.genreNid ?? contentData?.genreNid;
    return getZhenxieGenreName(genreNid);
  }

  Color? _getGenreColor() {
    final String? genreNid = stageData?.genreNid ?? contentData?.genreNid;
    return getZhenxieGenreColor(genreNid);
  }

  String _getAnswerTypeText(StageCardData? currentStageData) {
    final String? answerKind = currentStageData?.answerKind ?? contentData?.answerKind;
    if (answerKind == 'text') return '文字';
    if (answerKind == 'image') return '图片';
    if (answerKind == 'audio') return '音频';
    if (answerKind == 'video') return '视频';
    return '';
  }

  String _getAnswerDetailText(StageCardData? currentStageData) {
    final String? answerKind = currentStageData?.answerKind ?? contentData?.answerKind;
    if (answerKind == null || answerKind == 'text') return '';
    final int? answerMinCount = currentStageData?.answerMinCount ?? contentData?.answerMinCount;
    final int? answerMaxCount = currentStageData?.answerMaxCount ?? contentData?.answerMaxCount;
    if (answerMinCount != null && answerMaxCount != null) {
      if (answerMinCount == answerMaxCount) return '$answerMinCount份';
      return '$answerMinCount-$answerMaxCount份';
    }
    if (answerMinCount != null) return '$answerMinCount份';
    if (answerMaxCount != null) return '$answerMaxCount份';
    return '';
  }

  String _getLangText(List<LanguageText>? values, String lang) {
    if (values == null || values.isEmpty) return '';
    for (final LanguageText item in values) {
      if (item.lang == lang) return item.text ?? '';
    }
    return '';
  }

  List<LanguageText> _parseLanguageTexts(dynamic values) {
    return (values as List<dynamic>? ?? const <dynamic>[]).whereType<Map<String, dynamic>>().map(LanguageText.fromJson).toList();
  }

  String _getAnswerTypeIconAsset(String answerTypeText) {
    switch (answerTypeText) {
      case '视频':
        return 'assets/svg/public/Icon_zhenxie_video.svg';
      case '图片':
        return 'assets/svg/public/Icon_zhenxie_picture.svg';
      case '音频':
        return 'assets/svg/public/Icon_zhenxie_audio.svg';
      case '文字':
      default:
        return 'assets/svg/public/Icon_zhenxie_text.svg';
    }
  }

  bool _shouldShowMemberWritingStatus(CompositionTaskMemberWritingStatusModel? memberWritingStatus) {
    return (memberWritingStatus?.statusText ?? '').isNotEmpty;
  }

  Widget _buildMemberWritingStatusWidget(CompositionTaskMemberWritingStatusModel memberWritingStatus) {
    final LanguageConfigColorEntityThemeColors? themeColors = _getMemberWritingStatusThemeColors(memberWritingStatus);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        color: themeColors?.backgroundColorC ?? AppTheme.cSurfaceTranslucentBase.color,
        borderRadius: BorderRadius.circular(9999.wMin),
        border: Border.all(
          color: themeColors?.borderColorC ?? AppTheme.cBorderThin.color,
          width: 1.wMin,
        ),
      ),
      child: Text(
        memberWritingStatus.statusText ?? '',
        style: TextStyle(
          fontSize: 16.wMin,
          fontWeight: FontWeight.w400,
          color: themeColors?.textColorC ?? AppTheme.cTextSecondary.color,
          height: 1.0,
        ),
      ),
    );
  }

  LanguageConfigColorEntityThemeColors? _getMemberWritingStatusThemeColors(
    CompositionTaskMemberWritingStatusModel memberWritingStatus,
  ) {
    final String themeKey = ThemeUtils.isCurrentTheme(AppThemeKey.light.value) ? AppThemeKey.light.value : AppThemeKey.dark.value;
    for (final LanguageConfigColorEntityThemeColors item in memberWritingStatus.colors) {
      if (item.theme == themeKey) return item;
    }
    return memberWritingStatus.colors.isNotEmpty ? memberWritingStatus.colors.first : null;
  }
}
