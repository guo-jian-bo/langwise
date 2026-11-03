import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';
import '../../utils/karaoke_subtitles_utils.dart';
import '../entities/entities.dart';

class VideoAssTextWidget extends StatefulWidget {
  final Duration position;
  final String? ass;
  final List<LanguageText?>? translate;
  final Color assColor;
  final double? assFontSize;
  final Color translateColor;
  final double? translateFontSize;
  final String translateLangCode;

  /// 视频字幕的显示
  const VideoAssTextWidget({
    super.key, 
    required this.position, 
    this.ass, 
    this.translate,
    this.assColor = AppTheme.cTextPrimary,
    this.assFontSize,
    this.translateColor = AppTheme.cTextTertiary,
    this.translateFontSize,
    this.translateLangCode = "zh",
  });

  @override
  State<VideoAssTextWidget> createState() => _VideoAssTextWidgetState();
}

class _VideoAssTextWidgetState extends State<VideoAssTextWidget> {

  List<SubtitlesSentenceModel> assList = [];
  List<AssSubtitle> translateAssList = [];

  @override
  void initState() {
    super.initState();
    initAss();
  }

  @override
  void didUpdateWidget(covariant VideoAssTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.ass != oldWidget.ass){
      assList = widget.ass == null
          ? []
          : KaraokeSubtitlesUtils.parseAssSentenceByDialogue(widget.ass!);
    }
    if(widget.translate != oldWidget.translate || widget.translateLangCode != oldWidget.translateLangCode){
      String? translateAss = widget.translate?.firstWhereOrNull((e) => e?.lang == widget.translateLangCode)?.text;
      translateAssList = translateAss == null
          ? []
          : KaraokeSubtitlesUtils.parseAssTranslateDialogue(translateAss);
    }
  }

  /// 解析原文 ASS 与翻译 ASS，生成播放时使用的字幕数据。
  void initAss(){
    if(widget.ass != null){
      assList = KaraokeSubtitlesUtils.parseAssSentenceByDialogue(widget.ass!);
    }

    String? translateAss = widget.translate?.firstWhereOrNull((e) => e?.lang == widget.translateLangCode)?.text;
    if(translateAss != null){
      translateAssList = KaraokeSubtitlesUtils.parseAssTranslateDialogue(translateAss);
    }
  }

  int get _currentSubtitlePositionMs => widget.position.inMilliseconds;

  int? _findCurrentAssSentenceIndex() {
    if (assList.isEmpty) {
      return null;
    }

    int positionMs = _currentSubtitlePositionMs;
    int? currentSentenceIndex = 0;
    for (int index = 0; index < assList.length; index++) {
      final sentence = assList[index];
      int sentenceStartTime = sentence.sentenceStartTime ?? 0;
      if (positionMs >= sentenceStartTime) {
        currentSentenceIndex = index;
        continue;
      }
      break;
    }

    return currentSentenceIndex;
  }

  SubtitlesSentenceModel? _findCurrentAssSentence(int? currentSentenceIndex) {
    if (currentSentenceIndex == null) {
      return null;
    }

    if (currentSentenceIndex < 0 || currentSentenceIndex >= assList.length) {
      return null;
    }

    return assList[currentSentenceIndex];
  }

  AssSubtitle? _findCurrentTranslateSubtitle() {
    if (translateAssList.isEmpty) {
      return null;
    }

    int positionMs = _currentSubtitlePositionMs;
    int currentSubtitleIndex = 0;
    for (int index = 0; index < translateAssList.length; index++) {
      final subtitle = translateAssList[index];
      if (positionMs >= subtitle.startTime) {
        currentSubtitleIndex = index;
        continue;
      }
      break;
    }

    return translateAssList[currentSubtitleIndex];
  }

  String _normalizeSubtitleText(String text) {
    return text
        .replaceAll(RegExp(r'\{[^}]*\}'), '')
        .replaceAll(r'\N', '\n')
        .trim();
  }

  InlineSpan _buildAssSentenceTextSpan(SubtitlesSentenceModel? sentence) {
    int positionMs = _currentSubtitlePositionMs;
    List<InlineSpan> children = [];

    for (final word in sentence?.words ?? []) {
      bool isHighlighted = positionMs > word.startTime;
      children.add(
        TextSpan(
          text: '${word.leftSpace}${word.text}',
          style: TextStyle(
            color: widget.assColor.withValues(alpha: isHighlighted ? 1 : 0.6),
            fontSize: widget.assFontSize ?? 48.wMin,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),
      );
    }

    return TextSpan(children: children);
  }

  @override
  Widget build(BuildContext context) {
    final int? currentSentenceIndex = _findCurrentAssSentenceIndex();
    final currentSentence = _findCurrentAssSentence(currentSentenceIndex);
    final currentTranslateSubtitle = _findCurrentTranslateSubtitle();
    final String translateText = _normalizeSubtitleText(currentTranslateSubtitle?.text ?? '');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 48.wMin),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: currentSentence != null,
            child: Text.rich(
              _buildAssSentenceTextSpan(currentSentence),
              textAlign: TextAlign.center,
            ),
          ),
          Visibility(
            visible: translateText.isNotEmpty,
            child: Text(
              translateText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: widget.translateFontSize?? 28.wMin,
                fontWeight: FontWeight.w600,
                color: widget.translateColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
