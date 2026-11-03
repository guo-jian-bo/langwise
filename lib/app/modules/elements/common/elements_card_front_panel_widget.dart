import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../model/elements_detils_data_model.dart';
import 'elements_card_body_widget.dart';
import 'elements_card_media_widget.dart';
import 'elements_card_star_level_widget.dart';
import 'elements_card_title_widget.dart';
import 'elements_public_widgets.dart';

class ElementsCardFrontPanelWidget extends StatelessWidget {
  final ElementsDetilsDataModel data;
  final VoidCallback? onDetailTap;
  final bool disableImagePreview;
  final double contentFontSize;
  final double contentHeight;
  final int contentMaxLines;
  final double glossFontSize;
  final double glossHeight;
  final int glossMaxLines;
  final bool hideGlossWhenSameAsContent;
  final bool showDetailAction;
  final bool useOptimizedTextLayout;

  const ElementsCardFrontPanelWidget({
    super.key,
    required this.data,
    this.onDetailTap,
    this.disableImagePreview = false,
    required this.contentFontSize,
    required this.contentHeight,
    this.contentMaxLines = 2,
    required this.glossFontSize,
    required this.glossHeight,
    this.glossMaxLines = 2,
    this.hideGlossWhenSameAsContent = false,
    this.showDetailAction = true,
    this.useOptimizedTextLayout = false,
  });

  ConfigController get _configController => Get.find<ConfigController>();

  @override
  Widget build(BuildContext context) {
    final List<PronunciationsEntity> pronunciations =
        (data.data?.pronunciations ?? const <PronunciationsEntity?>[])
            .whereType<PronunciationsEntity>()
            .where((e) => (e.audioUrl ?? '').trim().isNotEmpty)
            .toList();
    final String contentText = data.data?.content ?? '';
    return Container(
      padding: EdgeInsets.only(
        left: 8.wMin,
        right: 8.wMin,
        bottom: 10.wMin,
      ),
      child: Column(
        children: [
          ElemenetsCardStarLevelWidget(
            star: data.data?.cardStar,
            hideStar: data.hideStar,
          ),
          SizedBox(height: 6.wMin),
          AspectRatio(
            aspectRatio: 1,
            child: ElementsCardBodyWidget(
  
                child: ElementsCardMediaWidget(
                  data: data.data,
                  disableImagePreview: disableImagePreview,
                ),
            ),
          ),
          SizedBox(height: 6.wMin),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 10.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.wMin),
                color: AppTheme.cBgTertiary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (!useOptimizedTextLayout) ...[
                    Center(
                      child: Text(
                        contentText,
                        maxLines: contentMaxLines,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: contentFontSize,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w600,
                          height: contentHeight,
                        ),
                      ),
                    ),
                    Obx(() {
                      final LanguageText? gloss =
                          LearningLangUtils.getShowForNone(data.data?.gloss);
                      final String glossText = gloss?.text ?? "";
                      final bool hideGloss = glossText.isEmpty ||
                          (hideGlossWhenSameAsContent &&
                              glossText == contentText);
                      if (hideGloss) return Container();
                      return Container(
                        margin: EdgeInsets.only(top: 6.wMin),
                        alignment: Alignment.center,
                        child: Text(
                          glossText,
                          maxLines: glossMaxLines,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: glossFontSize,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w500,
                            height: glossHeight,
                          ),
                        ),
                      );
                    }),
                 
                  ] else ...[
                    Text(
                      contentText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: contentFontSize,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w600,
                        height: contentHeight,
                      ),
                    ),
                    if (pronunciations.isNotEmpty) ...[
                      SizedBox(height: 6.wMin),
                      SizedBox(
                        height: 44.wMin,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _PronunciationCapsuleButtons(
                              pronunciations: pronunciations,
                            ),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 6.wMin),
                    Obx(() {
                      final LanguageText? gloss =
                          LearningLangUtils.getShowForNone(data.data?.gloss);
                      final String glossText = gloss?.text ?? "";
                      final bool hideGloss = glossText.isEmpty ||
                          (hideGlossWhenSameAsContent &&
                              glossText == contentText);
                      final String definitionText =
                          (data.data?.definition ?? '').trim();
                      final String subtitleText =
                          hideGloss ? definitionText : glossText;
                      if (subtitleText.isEmpty) return Container();
                      return Text(
                        subtitleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: glossFontSize,
                          color: AppTheme.cTextTertiary.color,
                          fontWeight: FontWeight.w400,
                          height: glossHeight,
                        ),
                      );
                    }),
                  
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 8.wMin),
          ElementCardTypeLevelWidget(
            type: data.type,
            name: data.data?.contentTypeTitle ?? "",
            minDifficulty: data.data?.difficulty?.min,
            maxDifficulty: data.data?.difficulty?.max,
            language: _configController.userSetting.value.learningLang,
            pos: data.data?.pos,
            posTitle: data.data?.posTitle,
            onDetailTap: onDetailTap,
            showDetailAction: showDetailAction,
          ),
        ],
      ),
    );
  }
}

class _PronunciationCapsuleButtons extends StatefulWidget {
  final List<PronunciationsEntity> pronunciations;

  const _PronunciationCapsuleButtons({
    required this.pronunciations,
  });

  @override
  State<_PronunciationCapsuleButtons> createState() =>
      _PronunciationCapsuleButtonsState();
}

class _PronunciationCapsuleButtonsState
    extends State<_PronunciationCapsuleButtons> {
  int _playingIndex = -1;

  String _resolvePronunciationLabel(PronunciationsEntity item) {
    final String national = (item.national ?? '').trim().toUpperCase();
    if (national.isNotEmpty) return national;
    return (item.nationalTitle ?? '').contains('英') ? 'UK' : 'US';
  }

  Future<void> _togglePlay(int index) async {
    final String audioUrl =
        (widget.pronunciations[index].audioUrl ?? '').trim();
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
          padding: EdgeInsets.only(
            right: index == widget.pronunciations.length - 1 ? 0 : 8.wMin,
          ),
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
