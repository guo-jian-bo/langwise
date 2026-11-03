import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_play/utils/karaoke_subtitles_utils.dart' as quiz_karaoke;
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';
import '../../utils/karaoke_subtitles_utils.dart';
import '../entities/entities.dart';

class VideoAssTextWidget extends StatefulWidget {
  final Duration position;
  final String? ass;
  final List<String?>? displayLines;
  final List<LanguageText?>? translate;
  final Color assColor;
  final double? assFontSize;
  final Color translateColor;
  final double? translateFontSize;
  final String translateLangCode;
  final bool singleLineOriginal;
  final bool animateOriginalLineChange;

  /// 视频字幕的显示
  const VideoAssTextWidget({
    super.key, 
    required this.position, 
    this.ass, 
    this.displayLines,
    this.translate,
    this.assColor = AppTheme.cTextPrimary,
    this.assFontSize,
    this.translateColor = AppTheme.cTextTertiary,
    this.translateFontSize,
    this.translateLangCode = "zh",
    this.singleLineOriginal = false,
    this.animateOriginalLineChange = false,
  });

  @override
  State<VideoAssTextWidget> createState() => _VideoAssTextWidgetState();
}

class _VideoAssTextWidgetState extends State<VideoAssTextWidget> {

  List<quiz_karaoke.SubtitlesSentenceModel> assList = [];
  List<AssSubtitle> translateAssList = [];

  @override
  void initState() {
    super.initState();
    initAss();
  }

  @override
  void didUpdateWidget(covariant VideoAssTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.ass != oldWidget.ass || widget.displayLines != oldWidget.displayLines){
      assList = _buildOriginalSentenceList();
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
    assList = _buildOriginalSentenceList();

    String? translateAss = widget.translate?.firstWhereOrNull((e) => e?.lang == widget.translateLangCode)?.text;
    if(translateAss != null){
      translateAssList = KaraokeSubtitlesUtils.parseAssTranslateDialogue(translateAss);
    }
  }

  List<quiz_karaoke.SubtitlesSentenceModel> _buildOriginalSentenceList() {
    final String assText = widget.ass?.trim() ?? '';
    if (assText.isEmpty) {
      return <quiz_karaoke.SubtitlesSentenceModel>[];
    }

    final List<quiz_karaoke.SubtitlesSentenceModel> baseSentences =
        quiz_karaoke.KaraokeSubtitlesUtils
            .parseKaraokeSubtitlesDialogueToSentence(assText)
            .where((sentence) => sentence.words.isNotEmpty)
            .toList();
    final List<String> displayLines = (widget.displayLines ?? const <String?>[])
        .whereType<String>()
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (displayLines.isEmpty || baseSentences.isEmpty) {
      return baseSentences;
    }

    final List<quiz_karaoke.SubtitlesSentenceModel> mappedSentences =
        <quiz_karaoke.SubtitlesSentenceModel>[];
    List<quiz_karaoke.SubtitlesSentenceModel> remainingSentences =
        List<quiz_karaoke.SubtitlesSentenceModel>.from(baseSentences);

    for (final String line in displayLines) {
      if (remainingSentences.isEmpty) break;
      final List<quiz_karaoke.SubtitlesSentenceModel> lineSentences =
          quiz_karaoke.KaraokeSubtitlesUtils
              .parseAssLineBreakByText(line, remainingSentences)
              .where((sentence) => sentence.words.isNotEmpty)
              .toList();
      if (lineSentences.isEmpty) continue;
      mappedSentences.addAll(lineSentences);
      final int consumedAssCount = lineSentences.length;
      if (consumedAssCount >= remainingSentences.length) {
        remainingSentences = <quiz_karaoke.SubtitlesSentenceModel>[];
      } else if (consumedAssCount > 0) {
        remainingSentences = remainingSentences.sublist(consumedAssCount);
      }
    }

    return mappedSentences.isEmpty ? baseSentences : mappedSentences;
  }

  int get _currentSubtitlePositionMs => widget.position.inMilliseconds;

  int? _findCurrentAssSentenceIndex() {
    if (assList.isEmpty) {
      return null;
    }

    final int positionMs = _currentSubtitlePositionMs;
    for (int index = 0; index < assList.length; index++) {
      final sentence = assList[index];
      if (sentence.words.isEmpty) continue;
      final int start =
          sentence.sentenceStartTime ?? sentence.words.first.startTime;
      final int end = sentence.sentenceEndTime ?? sentence.words.last.endTime;
      if (positionMs >= start && positionMs <= end) {
        return index;
      }
    }

    final quiz_karaoke.SubtitlesSentenceModel firstSentence = assList.first;
    if (firstSentence.words.isNotEmpty) {
      final int firstStart =
          firstSentence.sentenceStartTime ?? firstSentence.words.first.startTime;
      if (positionMs <= firstStart) {
        return 0;
      }
    }

    int? currentSentenceIndex;
    for (int index = 0; index < assList.length; index++) {
      final sentence = assList[index];
      if (sentence.words.isEmpty) continue;
      final int sentenceStartTime =
          sentence.sentenceStartTime ?? sentence.words.first.startTime;
      if (positionMs >= sentenceStartTime) {
        currentSentenceIndex = index;
        continue;
      }
      break;
    }

    return currentSentenceIndex ?? 0;
  }

  quiz_karaoke.SubtitlesSentenceModel? _findCurrentAssSentence(int? currentSentenceIndex) {
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

  String _renderSentenceTailSpace(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text.replaceAll(' ', '\u00A0');
  }

  InlineSpan _buildAssSentenceTextSpan(
    List<quiz_karaoke.AssSubtitle> words, {
    bool trimLeadingSpace = false,
  }) {
    int positionMs = _currentSubtitlePositionMs;
    List<InlineSpan> children = [];

    for (int index = 0; index < words.length; index++) {
      final word = words[index];
      final bool isLastWord = index == words.length - 1;
      final String leftSpace = trimLeadingSpace && index == 0 ? '' : word.leftSpace;

      bool isHighlighted = positionMs > word.startTime;

      children.add(TextSpan(
        text: '$leftSpace${word.text}${isLastWord ? _renderSentenceTailSpace(word.rightSpace) : word.rightSpace}',
        style: TextStyle(
          color: widget.assColor.withValues(alpha: isHighlighted ? 1 : 0.6),
          fontSize: widget.assFontSize ?? 48.wMin,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
      ));
    }

    return TextSpan(children: children);
  }

  List<_SingleLineSubtitleChunk> _buildSingleLineChunks(
    quiz_karaoke.SubtitlesSentenceModel sentence,
    double maxWidth,
  ) {
    final List<quiz_karaoke.AssSubtitle> words = sentence.words;
    if (words.isEmpty || maxWidth <= 0) {
      return const <_SingleLineSubtitleChunk>[];
    }

    final TextStyle measureStyle = TextStyle(
      fontSize: widget.assFontSize ?? 48.wMin,
      fontWeight: FontWeight.w600,
      height: 1.25,
    );

    final List<_SingleLineSubtitleChunk> chunks = <_SingleLineSubtitleChunk>[];
    int start = 0;
    while (start < words.length) {
      int end = start;
      while (end < words.length) {
        final List<quiz_karaoke.AssSubtitle> candidate = words.sublist(start, end + 1);
        if (end > start && !_doesChunkFit(candidate, maxWidth, measureStyle)) {
          break;
        }
        if (end == start && !_doesChunkFit(candidate, maxWidth, measureStyle)) {
          end++;
          break;
        }
        end++;
      }

      final int chunkEnd = end.clamp(start + 1, words.length);
      final List<quiz_karaoke.AssSubtitle> chunkWords = words.sublist(start, chunkEnd);
      chunks.add(
        _SingleLineSubtitleChunk(
          words: chunkWords,
          startTime: chunkWords.first.startTime,
          endTime: chunkWords.last.endTime,
        ),
      );
      start = chunkEnd;
    }
    return chunks;
  }

  bool _doesChunkFit(
    List<quiz_karaoke.AssSubtitle> words,
    double maxWidth,
    TextStyle style,
  ) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: _buildChunkPlainText(words),
        style: style,
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    return !painter.didExceedMaxLines && painter.width <= maxWidth;
  }

  String _buildChunkPlainText(List<quiz_karaoke.AssSubtitle> words) {
    final StringBuffer buffer = StringBuffer();
    for (int index = 0; index < words.length; index++) {
      final quiz_karaoke.AssSubtitle word = words[index];
      if (index > 0) {
        buffer.write(word.leftSpace);
      }
      buffer.write(word.text);
      buffer.write(word.rightSpace);
    }
    return buffer.toString().trimRight();
  }

  int _findCurrentChunkIndex(List<_SingleLineSubtitleChunk> chunks) {
    if (chunks.isEmpty) return 0;
    final int positionMs = _currentSubtitlePositionMs;
    for (int index = 0; index < chunks.length; index++) {
      final _SingleLineSubtitleChunk chunk = chunks[index];
      if (positionMs >= chunk.startTime && positionMs <= chunk.endTime) {
        return index;
      }
    }
    if (positionMs <= chunks.first.startTime) {
      return 0;
    }
    for (int index = chunks.length - 1; index >= 0; index--) {
      if (positionMs >= chunks[index].startTime) {
        return index;
      }
    }
    return 0;
  }

  Widget _buildOriginalSubtitleWidget(
    quiz_karaoke.SubtitlesSentenceModel? currentSentence,
    int? currentSentenceIndex,
  ) {
    if (currentSentence == null) {
      return const SizedBox.shrink();
    }
    if (!widget.singleLineOriginal) {
      return Text.rich(
        _buildAssSentenceTextSpan(currentSentence.words),
        key: ValueKey<int?>(currentSentenceIndex),
        textAlign: TextAlign.center,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final List<_SingleLineSubtitleChunk> chunks =
            _buildSingleLineChunks(currentSentence, constraints.maxWidth);
        final int chunkIndex = _findCurrentChunkIndex(chunks);
        final List<quiz_karaoke.AssSubtitle> displayWords = chunks.isEmpty
            ? currentSentence.words
            : chunks[chunkIndex].words;
        final Widget content = Text.rich(
          _buildAssSentenceTextSpan(
            displayWords,
            trimLeadingSpace: true,
          ),
          key: ValueKey<String>('${currentSentenceIndex ?? 0}_$chunkIndex'),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.visible,
          softWrap: false,
        );

        if (!widget.animateOriginalLineChange) {
          return content;
        }
        final double lineHeight = (widget.assFontSize ?? 48.wMin) * 1.35;
        return SizedBox(
          height: lineHeight,
          child: ClipRect(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final Animation<Offset> offsetAnimation = Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  ),
                );
              },
              child: content,
            ),
          ),
        );
      },
    );
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
            child: _buildOriginalSubtitleWidget(
              currentSentence,
              currentSentenceIndex,
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

class _SingleLineSubtitleChunk {
  final List<quiz_karaoke.AssSubtitle> words;
  final int startTime;
  final int endTime;

  const _SingleLineSubtitleChunk({
    required this.words,
    required this.startTime,
    required this.endTime,
  });
}
