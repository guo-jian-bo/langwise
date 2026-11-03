import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

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

class ElementsCardTextHighlightConfig {
  final List<String> previewForms;
  final List<ElementsCardTextHighlightRange> ranges;
  final Color? highlightColor;

  const ElementsCardTextHighlightConfig({
    this.previewForms = const <String>[],
    this.ranges = const <ElementsCardTextHighlightRange>[],
    required this.highlightColor,
  });
}

class ElementsCardTextHighlightRange {
  final int start;
  final int end;

  const ElementsCardTextHighlightRange({
    required this.start,
    required this.end,
  });
}

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
  final ElementsCardTextHighlightConfig? textHighlightConfig;

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
    this.textHighlightConfig,
  });

  ConfigController get _configController => Get.find<ConfigController>();

  List<String> _resolveGlossLines(
    List<LanguageText?>? gloss, {
    required String contentText,
  }) {
    final LangPreference preference = _configController.userSetting.value.expandLang;
    if (preference == LangPreference.none) return const <String>[];

    final String learningLang = _configController.userSetting.value.learningLang;
    final String localLang = _configController.userSetting.value.localLang;

    String resolveText(String lang) {
      if (gloss == null) return '';
      for (final LanguageText? item in gloss) {
        if (item == null) continue;
        if ((item.lang ?? '').trim() != lang) continue;
        final String text = (item.text ?? '').trim();
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    final List<String> lines = <String>[];
    if (preference == LangPreference.bilingual) {
      final String learningText = resolveText(learningLang);
      final String localText = resolveText(localLang);
      if (learningText.isNotEmpty) lines.add(learningText);
      if (localText.isNotEmpty) lines.add(localText);
    } else if (preference == LangPreference.original) {
      final String learningText = resolveText(learningLang);
      if (learningText.isNotEmpty) lines.add(learningText);
    } else if (preference == LangPreference.translation) {
      final String localText = resolveText(localLang);
      if (localText.isNotEmpty) lines.add(localText);
    }

    if (!hideGlossWhenSameAsContent) return lines;
    return lines.where((e) => e != contentText).toList();
  }

  Widget _buildContentText({
    required String contentText,
    required int maxLines,
    required TextAlign textAlign,
    required TextStyle style,
  }) {
    final ElementsCardTextHighlightConfig? highlightConfig =
        textHighlightConfig;
    final Color? highlightColor = highlightConfig?.highlightColor;
    final List<ElementsCardTextHighlightRange> highlightRanges =
        highlightConfig?.ranges ?? <ElementsCardTextHighlightRange>[];
    final List<String> previewForms = highlightConfig?.previewForms ?? <String>[];
    if (contentText.isEmpty || highlightColor == null) {
      return Text(
        contentText,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
        style: style,
      );
    }

    if (highlightRanges.isNotEmpty) {
      return Text.rich(
        TextSpan(
          style: style,
          children: _buildRangeHighlightSpans(
            contentText,
            highlightRanges,
            highlightColor,
            style,
          ),
        ),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
      );
    }

    if (previewForms.isEmpty) {
      return Text(
        contentText,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
        style: style,
      );
    }

    return Text.rich(
      TextSpan(
        style: style,
        children: _buildHighlightSpans(
          contentText,
          previewForms,
          highlightColor,
          style,
        ),
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }

  List<InlineSpan> _buildRangeHighlightSpans(
    String text,
    List<ElementsCardTextHighlightRange> ranges,
    Color highlightColor,
    TextStyle baseStyle,
  ) {
    final List<ElementsCardTextHighlightRange> safeRanges =
        ranges.where((ElementsCardTextHighlightRange range) {
      return range.start >= 0 &&
          range.end > range.start &&
          range.end <= text.length;
    }).toList()
          ..sort((ElementsCardTextHighlightRange a,
                  ElementsCardTextHighlightRange b) =>
              a.start.compareTo(b.start));
    if (safeRanges.isEmpty) {
      return <InlineSpan>[TextSpan(text: text)];
    }

    final List<InlineSpan> spans = <InlineSpan>[];
    int current = 0;
    for (final ElementsCardTextHighlightRange range in safeRanges) {
      if (range.start < current) continue;
      if (range.start > current) {
        spans.add(TextSpan(text: text.substring(current, range.start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(range.start, range.end),
          style: baseStyle.copyWith(
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

  List<InlineSpan> _buildHighlightSpans(
    String text,
    List<String> forms,
    Color highlightColor,
    TextStyle baseStyle,
  ) {
    final List<String> needles = forms
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .toSet()
        .toList()
      ..sort((String a, String b) {
        final int lengthCompare = b.length.compareTo(a.length);
        if (lengthCompare != 0) return lengthCompare;
        return a.compareTo(b);
      });
    if (needles.isEmpty) {
      return <InlineSpan>[TextSpan(text: text)];
    }

    final List<_HighlightRange> ranges = <_HighlightRange>[];
    final String lowerText = text.toLowerCase();
    for (final String needle in needles) {
      final String lowerNeedle = needle.toLowerCase();
      int start = 0;
      while (start < lowerText.length) {
        final int index = lowerText.indexOf(lowerNeedle, start);
        if (index < 0) break;
        final int end = index + lowerNeedle.length;
        if (_isTokenBounded(text, index, end) &&
            !_isOverlapping(ranges, index, end)) {
          ranges.add(_HighlightRange(start: index, end: end));
        }
        start = index + 1;
      }
    }

    if (ranges.isEmpty) {
      return <InlineSpan>[TextSpan(text: text)];
    }

    ranges.sort((_HighlightRange a, _HighlightRange b) => a.start.compareTo(b.start));
    final List<InlineSpan> spans = <InlineSpan>[];
    int current = 0;
    for (final _HighlightRange range in ranges) {
      if (range.start > current) {
        spans.add(TextSpan(text: text.substring(current, range.start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(range.start, range.end),
          style: baseStyle.copyWith(
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
                        child: _buildContentText(
                          contentText: contentText,
                          maxLines: contentMaxLines,
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
                      final List<String> glossLines = _resolveGlossLines(
                        data.data?.gloss,
                        contentText: contentText,
                      );
                      final String glossText = glossLines.join('\n');
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
                 
                  ] 
                  else 
                  ...[
                     
                     
                      _buildContentText(
                        contentText: contentText,
                        maxLines: contentMaxLines,
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
                      final LangPreference preference =
                          _configController.userSetting.value.expandLang;
                      final List<String> glossLines = _resolveGlossLines(
                        data.data?.gloss,
                        contentText: contentText,
                      );
                      final String definitionText =
                          (data.data?.definition ?? '').trim();
                      if (preference == LangPreference.none) {
                        return Container();
                      }
                      if (glossLines.isEmpty) {
                        if (preference == LangPreference.original) {
                          return Container();
                        }
                        if (definitionText.isEmpty) return Container();
                        return Text(
                          definitionText,
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
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: glossLines
                            .map(
                              (text) => Text(
                                text,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: glossFontSize,
                                  color: AppTheme.cTextTertiary.color,
                                  fontWeight: FontWeight.w400,
                                  height: glossHeight,
                                ),
                              ),
                            )
                            .toList(),
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

class _HighlightRange {
  final int start;
  final int end;

  const _HighlightRange({
    required this.start,
    required this.end,
  });
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
    ElementsInlineVideoPlaybackCoordinator.stopCurrent();
    await PlaybackInterlockUtils.instance.playSharedAudio(audioUrl);
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
