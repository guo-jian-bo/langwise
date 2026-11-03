

class AssSubtitle {
  int startTime;
  int endTime;
  String text;
  bool isRead = false;

  /// 左边的空格 比如英语 this is 中间有空格 你好 中间没有空格
  final String leftSpace;
  final String rightSpace;

  String other;

  AssSubtitle({
    required this.startTime,
    required this.endTime,
    required this.text,
    this.leftSpace = "",
    this.rightSpace = "",
    this.other = "",
  });

  @override
  String toString() {
    return 'AssSubtitle(startTime: $startTime, endTime: $endTime, text: $text)';
  }
}

/// 句子
class SubtitlesSentenceModel{
  List<AssSubtitle> words;

  /// 句子的开始时间
  int? sentenceStartTime;
  
  /// 句子的结束时间
  int? sentenceEndTime;

  /// 人物演员
  String? actor;

  /// Dialogue原始文本
  String? dialogueText;

  SubtitlesSentenceModel({
    required this.words,
    this.actor,
    this.sentenceStartTime,
    this.sentenceEndTime,
    this.dialogueText,
  });
}


/// 卡拉OK字幕
class KaraokeSubtitlesUtils {
  static final symbolRegex = RegExp(r'^[\p{P}\p{S}\p{M}\p{C}\p{Z}]+$', unicode: true);
  static final _whiteSpaceRegex = RegExp(r'\s+');
  static final _nonWordRegex = RegExp(r'[^\p{L}\p{N}]+', unicode: true);
  static final _trimNonWordEdgeRegex = RegExp(r'^[^\p{L}\p{N}]+|[^\p{L}\p{N}]+$', unicode: true);
  static final _stripSpeakerPrefixRegex = RegExp(r'^\s*[\p{L}\p{N}][\p{L}\p{N}\s]{0,30}:\s*', unicode: true);
  static final _letterOrNumberRegex = RegExp(r'[\p{L}\p{N}]', unicode: true);

  /// 按 Dialogue 行拆分 ass 文本
  /// * 每一个 Dialogue 对应一个 SubtitlesSentenceModel
  static List<SubtitlesSentenceModel> parseAssSentenceByDialogue(String assText) {
    if (assText == "") return [];

    List<SubtitlesSentenceModel> dialogues = [];
    final RegExp dialogueRegex = RegExp(r'Dialogue:[\s\S]*?(?=Dialogue:|$)');
    final matches = dialogueRegex.allMatches(assText);

    for (final match in matches) {
      final String rawLine = match.group(0) ?? '';
      final String line = rawLine.trimLeft();
      if (line.trim().isEmpty) {
        continue;
      }

      dialogues.add(parseDialogueLineToSentenceModel(line));
    }

    return dialogues;
  }

  /// 解析ass翻译 以Dialogue
  static List<AssSubtitle> parseAssTranslateDialogue(String assText) {
    if (assText == "") return [];
    List<AssSubtitle> dialogues = [];
    var partsList = assText.split('Dialogue:');
    if (partsList.length <= 1) return [];
    partsList.removeAt(0);
    for (var part in partsList) {
      var parts = part.split(',');
      if (parts.length >= 10) {
        var startTime = parts[1].trim();
        var text = _removeAssNewLines(parts.sublist(9).join(','));
        // var text = parts.sublist(9).join(',');
        var startDuration = _parseTimeToDuration(startTime);
        var endTime = parts[2].trim();  // parts[2] 是开始时间
        var endDuration = _parseTimeToDuration(endTime);
        dialogues.add(AssSubtitle(
          startTime: startDuration,
          endTime: endDuration,
          text: text,
        ));
      }
    }
    return dialogues;
  }

  /// 移除ass中的换行符
  /// * 移除 \\N, \\n, \\r 换行符
  /// * 移除 \\r, \\n 换行符
  static String _removeAssNewLines(String text) {
    final _assNewLineRegex = RegExp(r'(?:\\N|\\n|\\r)');
    final _newLineCharRegex = RegExp(r'[\r\n]+');

    var result = text.replaceAll(_newLineCharRegex, '');
    result = result.replaceAll(_assNewLineRegex, '');
    return result;
  }


  static List<AssSubtitle> parseKaraokeSubtitles(String assText) {
    if (assText == "") return [];

    List<AssSubtitle> subtitles = [];

    List<SubtitlesSentenceModel> dialogues = parseAssSentenceByDialogue(assText);

    for (SubtitlesSentenceModel dialogue in dialogues) {
      subtitles.addAll(dialogue.words);
    }

    return subtitles;
  }


  /// 获取字符串的前导空格
  static String _getLeadingSpaces(String text) {
    return RegExp(r'^\s+').firstMatch(text)?.group(0) ?? '';
  }

  /// 获取字符串的尾随空格
  static String _getTrailingSpaces(String text) {
    return RegExp(r'\s+$').firstMatch(text)?.group(0) ?? '';
  }

  static SubtitlesSentenceModel parseDialogueLineToSentenceModel(String line) {
    SubtitlesSentenceModel currentDialogue = SubtitlesSentenceModel(words: []);

    if (!line.startsWith('Dialogue:')) {
      return currentDialogue;
    }

    var parts = line.split(',');

    if (parts.length < 10) {
      return currentDialogue;
    }

    var startTime = parts[1].trim();
    var endTime = parts[2].trim();
    var actor = parts[4].trim();
    var text = _removeAssNewLines(parts.sublist(9).join(','));

    var startDuration = _parseTimeToDuration(startTime);
    var endDuration = _parseTimeToDuration(endTime);

    currentDialogue.sentenceStartTime = startDuration;
    currentDialogue.sentenceEndTime = endDuration;
    currentDialogue.actor = actor;
    currentDialogue.dialogueText = line;

    var regex = RegExp(r'\{\\k(\d+)\}([^\{]+)(?=\{\\k|$)');
    var matches = regex.allMatches(text);

    int wordStartTime = startDuration;
    int wordEndTime = startDuration;

    // 上一个单元的右边的空格
    String lastRightSpace = "";

    for (int i = 0; i < matches.length; i++) {
      var match = matches.elementAt(i);
      var timeStr = match.group(1) ?? '';
      int timeInt = (int.tryParse(timeStr) ?? 0) * 10;
      var rawWord = match.group(2) ?? '';
      var word = rawWord.trim();

      wordEndTime += timeInt;

      // 如果全是空格，直接累加到 pendingSpace，作为下一个单词的左侧空格
      if (word.isEmpty) {
        wordStartTime += timeInt;
        continue;
      }

      // 提取当前片段的前导和尾随空格
      String currentLeading = _getLeadingSpaces(rawWord);
      String currentTrailing = _getTrailingSpaces(rawWord);
      
      // 当前词的 leftSpace 只来自“当前片段的前导空格”（以及开头的纯空白片段）
      String leftSpace = currentLeading;

      if(leftSpace.isEmpty && lastRightSpace.isEmpty){// TODO: 是否需要？ 如果没有空格强制增加一个空格
        leftSpace = " ";
      }

      lastRightSpace = currentTrailing;

      currentDialogue.words.add(AssSubtitle(
        startTime: wordStartTime,
        endTime: wordEndTime,
        text: word,
        leftSpace: leftSpace,
        rightSpace: currentTrailing,
      ));

      wordStartTime += timeInt;
    }

    return currentDialogue;
  }


  // 将字幕时间字符串（如 "0:00:01.00"）转换为 Duration 类型
  static int _parseTimeToDuration(String time) {
    var parts = time.split(':');

    int hours = 0;
    int minutes = 0;
    int seconds = 0;
    int milliseconds = 0;

    // 如果有 3 个部分，说明是 时:分:秒.毫秒 格式
    if (parts.length == 3) {
      hours = int.parse(parts[0]); // 获取小时
      minutes = int.parse(parts[1]); // 获取分钟

      // 处理秒.毫秒 部分
      var secondsAndMillis = parts[2].split('.');
      seconds = int.parse(secondsAndMillis[0]); // 秒
      milliseconds = secondsAndMillis.length > 1 ? int.parse(secondsAndMillis[1].padRight(3, '0')) : 0; // 毫秒
    }
    // 如果有 2 个部分，说明是 分:秒.毫秒 格式
    else if (parts.length == 2) {
      minutes = int.parse(parts[0]); // 获取分钟

      // 处理秒.毫秒 部分
      var secondsAndMillis = parts[1].split('.');
      seconds = int.parse(secondsAndMillis[0]); // 秒
      milliseconds = secondsAndMillis.length > 1 ? int.parse(secondsAndMillis[1].padRight(3, '0')) : 0; // 毫秒
    }

    Duration resp = Duration(hours: hours, minutes: minutes, seconds: seconds, milliseconds: milliseconds);
    return resp.inMilliseconds;
  }

  /// 根据text对齐ass字幕
  /// * itemText 一段文本
  /// * allAss 所有ass字幕
  /// * 从allAss中选择最可能属于 itemText 的 Dialogue 段（用于时间轴）
  ///
  /// 业务约束（核心）：
  /// 1) 页面渲染以 itemText 为准：返回结果里的 words.text 必须来自 itemText
  /// 2) audioAss 只提供时间轴：尽量用 ASS 做词/句高亮；对不上时允许降级
  /// 3) 标点处理：单词尾部标点不拆成独立 token（避免 UI 换行拆开）
  /// 4) 降级策略：
  ///   - allAss 为空：仍返回 itemText 分词结果，时间设为 -1（避免误高亮）
  ///   - text/ass 差异大：不强行严格匹配，改用时间轴比例映射（保证高亮推进稳定）
  ///
  /// 注意：返回 List 的每一项仍是一个句子（SubtitlesSentenceModel）。
  /// 若该句子来源于 ASS，会携带对应的 dialogueText，用于调用方计算“消耗了多少条 ASS Dialogue”。
  static List<SubtitlesSentenceModel> parseAssLineBreakByText(String itemText, List<SubtitlesSentenceModel> allAss) {
    final List<_TextToken> textTokens = _tokenizeTextKeepingPunctuation(itemText);

    if (textTokens.isEmpty) {
      return [
        SubtitlesSentenceModel(
          words: [],
          sentenceStartTime: -1,
          sentenceEndTime: -1,
        ),
      ];
    }

    if (allAss.isEmpty) {
      return [
        SubtitlesSentenceModel(
          words: List.generate(
            textTokens.length,
            (i) => AssSubtitle(
              startTime: -1,
              endTime: -1,
              text: textTokens[i].text,
              leftSpace: i == 0 || symbolRegex.hasMatch(textTokens[i].text) ? "" : " ",
            ),
          ),
          sentenceStartTime: -1,
          sentenceEndTime: -1,
        ),
      ];
    }

    final int assSentenceCount = _chooseAssSentenceCountForText(itemText, allAss);
    if (assSentenceCount <= 0) {
      return [
        SubtitlesSentenceModel(
          words: List.generate(
            textTokens.length,
            (i) => AssSubtitle(
              startTime: -1,
              endTime: -1,
              text: textTokens[i].text,
              leftSpace: i == 0 || symbolRegex.hasMatch(textTokens[i].text) ? "" : " ",
            ),
          ),
          sentenceStartTime: -1,
          sentenceEndTime: -1,
        ),
      ];
    }

    final List<SubtitlesSentenceModel> selectedAss = allAss.take(assSentenceCount).toList();
    final List<List<_TextToken>> tokenGroups = _splitTokensByAssWeights(textTokens, selectedAss);

    final List<SubtitlesSentenceModel> result = [];
    for (int i = 0; i < selectedAss.length; i++) {
      final SubtitlesSentenceModel assSentence = selectedAss[i];
      final List<_TextToken> group = i < tokenGroups.length ? tokenGroups[i] : const [];

      final List<AssSubtitle> mappedWords = _mapTextTokensToAssTimeline(group, assSentence);
      result.add(SubtitlesSentenceModel(
        words: mappedWords,
        actor: assSentence.actor,
        sentenceStartTime: assSentence.sentenceStartTime ?? -1,
        sentenceEndTime: assSentence.sentenceEndTime ?? -1,
        dialogueText: assSentence.dialogueText,
      ));
    }

    return result;
  }

  /// 将文本按“空白分隔”为 token，同时把纯标点 token 合并到前一个 token（避免拆开换行）。
  static List<_TextToken> _tokenizeTextKeepingPunctuation(String text) {
    final List<_TextToken> tokens = [];
    int i = 0;

    while (i < text.length) {
      final String ch = text[i];
      if (_isWhitespaceChar(ch)) {
        i++;
        continue;
      }

      int j = i;
      while (j < text.length && !_isWhitespaceChar(text[j])) {
        j++;
      }

      final String rawToken = text.substring(i, j);
      i = j;

      if (rawToken.trim().isEmpty) {
        continue;
      }

      final bool isPureSymbol = symbolRegex.hasMatch(rawToken);
      if (isPureSymbol && tokens.isNotEmpty) {
        final _TextToken prev = tokens.last;
        tokens[tokens.length - 1] = _TextToken(prev.leftSpace, '${prev.text}$rawToken');
        continue;
      }

      tokens.add(_TextToken("", rawToken));
    }

    return tokens;
  }

  static bool _isWhitespaceChar(String ch) {
    return ch == ' ' || ch == '\n' || ch == '\t' || ch == '\r' || ch == '\f';
  }

  /// 从 allAss 开头挑选“最可能属于 itemText”的 Dialogue 数量（通常为 1 或多句）。
  /// 规则：以“词级编辑距离 + 句子数量提示”做最小代价选择，允许 text/ass 有少量增删词。
  ///
  /// 说明：
  /// - itemText 往往是一个段落，可能包含多个句子；ASS 的 Dialogue 通常按句切分
  /// - 若错误地只消费了 1 条 Dialogue，会导致整段高亮“跑得很快”
  static int _chooseAssSentenceCountForText(String itemText, List<SubtitlesSentenceModel> allAss) {
    if (allAss.isEmpty) return 0;

    final String noSpeakerText = _stripPossibleSpeakerPrefix(itemText);
    final List<String> textTokens = _normalizeTextToWordTokens(noSpeakerText);
    if (textTokens.isEmpty) return 0;

    final int sentenceHint = _estimateSentenceCountFromText(noSpeakerText);
    int maxCount = sentenceHint + 20;
    if (maxCount < 4) maxCount = 4;
    if (maxCount > allAss.length) maxCount = allAss.length;

    int bestCount = 1;
    double bestScore = double.infinity;

    final List<String> assTokens = [];

    for (int count = 1; count <= maxCount; count++) {
      assTokens.addAll(_normalizeAssSentenceToWordTokens(allAss[count - 1]));
      if (assTokens.isEmpty) continue;

      final List<String> expandedTextTokens = _expandTextWordTokensByAssTokens(
        textTokens: textTokens,
        assTokens: assTokens,
      );
      final _AlignmentResult alignment = _alignTokens(assTokens, expandedTextTokens);
      final int maxLen = assTokens.length > expandedTextTokens.length ? assTokens.length : expandedTextTokens.length;
      final double mismatchRatio = maxLen == 0 ? 1.0 : alignment.editDistance / maxLen;
      final double lengthPenalty =
          (assTokens.length - expandedTextTokens.length).abs() / (expandedTextTokens.isEmpty ? 1 : expandedTextTokens.length);
      final double countPenalty = (count - sentenceHint).abs() * 0.02;

      final double score = mismatchRatio + (lengthPenalty * 0.35) + countPenalty;
      if (score < bestScore) {
        bestScore = score;
        bestCount = count;
      }

      if (count >= sentenceHint && mismatchRatio < 0.18 && lengthPenalty < 0.22) {
        break;
      }
    }

    return bestCount;
  }

  static List<String> _expandTextWordTokensByAssTokens({
    required List<String> textTokens,
    required List<String> assTokens,
  }) {
    if (textTokens.isEmpty) return textTokens;
    if (assTokens.isEmpty) return textTokens;

    final List<String> out = [];
    int cursor = 0;

    for (final t in textTokens) {
      if (t.isEmpty) continue;
      if (cursor < 0) cursor = 0;
      if (cursor > assTokens.length) cursor = assTokens.length;

      final _GlueMatch? match = _findGlueMatch(
        tokenLower: t,
        assNorm: assTokens,
        startIndex: cursor,
      );

      if (match != null && match.count >= 2) {
        for (int i = 0; i < match.count; i++) {
          out.add(assTokens[match.start + i]);
        }
        cursor = match.start + match.count;
        continue;
      }

      out.add(t);
      if (cursor < assTokens.length && t == assTokens[cursor]) {
        cursor += 1;
      }
    }

    return out;
  }

  static int _estimateSentenceCountFromText(String text) {
    final Iterable<RegExpMatch> matches = RegExp(r'(?<!\.)\.(?!\.)|[!?。！？]').allMatches(text);
    final int count = matches.length;
    return count <= 0 ? 1 : count;
  }

  static List<String> _normalizeTextToWordTokens(String text) {
    final List<_TextToken> tokens = _tokenizeTextKeepingPunctuation(text);
    final List<String> out = [];
    for (final t in tokens) {
      final String w = _normalizeTokenToWord(t.text);
      if (w.isEmpty) continue;
      out.add(w);
    }
    return out;
  }

  static List<String> _normalizeAssSentenceToWordTokens(SubtitlesSentenceModel assSentence) {
    final List<String> out = [];
    for (final w in assSentence.words) {
      if (w.text.trim().isEmpty) continue;
      if (symbolRegex.hasMatch(w.text)) continue;
      final String normalized = _normalizeTokenToWord(w.text);
      if (normalized.isEmpty) continue;
      out.add(normalized);
    }
    return out;
  }

  static String _stripPossibleSpeakerPrefix(String text) {
    final String trimmed = text.trimLeft();
    if (!_stripSpeakerPrefixRegex.hasMatch(trimmed)) {
      return text;
    }
    return trimmed.replaceFirst(_stripSpeakerPrefixRegex, '');
  }

  static String _normalizeForMatch(String text) {
    final String lower = text.toLowerCase().replaceAll(_whiteSpaceRegex, '');
    return lower.replaceAll(_nonWordRegex, '');
  }

  /// 将 itemText 的 tokens 按 ASS 句子的“权重”拆成 N 份（N = selectedAss.length）。
  /// - 优先按句末标点拆分（更贴近 Dialogue 的句级结构）
  /// - 若拆不出来，再退化为“按长度权重”分配
  static List<List<_TextToken>> _splitTokensByAssWeights(List<_TextToken> tokens, List<SubtitlesSentenceModel> selectedAss) {
    final int n = selectedAss.length;
    if (n <= 1) return [tokens];

    final List<List<_TextToken>>? sentenceGroups = _splitTokensBySentenceTerminators(tokens, n);
    if (sentenceGroups != null) {
      return sentenceGroups;
    }

    final List<int> weights = List<int>.filled(n, 1);
    int weightSum = 0;
    for (int i = 0; i < n; i++) {
      final int len = _normalizeForMatch(_joinAssSentenceText([selectedAss[i]])).length;
      weights[i] = len > 0 ? len : 1;
      weightSum += weights[i];
    }

    final int total = tokens.length;
    final List<int> sizes = List<int>.filled(n, 0);
    int allocated = 0;

    for (int i = 0; i < n; i++) {
      int size = (total * weights[i] / weightSum).round();
      if (size < 0) size = 0;
      sizes[i] = size;
      allocated += size;
    }

    while (allocated < total) {
      sizes[n - 1] += 1;
      allocated += 1;
    }
    while (allocated > total) {
      int idx = _findFirstIndexWhere(sizes, (v) => v > 0);
      if (idx == -1) break;
      sizes[idx] -= 1;
      allocated -= 1;
    }

    final List<List<_TextToken>> groups = List.generate(n, (_) => <_TextToken>[]);
    int cursor = 0;
    for (int i = 0; i < n; i++) {
      final int end = cursor + sizes[i];
      if (cursor >= total) {
        groups[i] = [];
        continue;
      }
      groups[i] = tokens.sublist(cursor, end > total ? total : end);
      cursor = end;
    }

    if (cursor < total) {
      groups[n - 1] = [...groups[n - 1], ...tokens.sublist(cursor)];
    }

    return groups;
  }

  static List<List<_TextToken>>? _splitTokensBySentenceTerminators(List<_TextToken> tokens, int targetGroupCount) {
    if (tokens.isEmpty) return null;
    if (targetGroupCount <= 1) return [tokens];

    final List<List<_TextToken>> groups = [];
    List<_TextToken> current = [];

    for (final t in tokens) {
      current.add(t);
      if (_endsWithSentenceTerminator(t.text)) {
        groups.add(current);
        current = [];
      }
    }

    if (current.isNotEmpty) {
      groups.add(current);
    }

    groups.removeWhere((g) => g.isEmpty);
    if (groups.isEmpty) return null;
    if (groups.length < targetGroupCount) return null;

    while (groups.length > targetGroupCount) {
      int bestIndex = 0;
      int bestScore = 1 << 30;
      for (int i = 0; i < groups.length - 1; i++) {
        final int a = groups[i].length;
        final int b = groups[i + 1].length;
        final int minLen = a < b ? a : b;
        final int score = (minLen * 1000) + (a + b);
        if (score < bestScore) {
          bestScore = score;
          bestIndex = i;
        }
      }

      final List<_TextToken> merged = [...groups[bestIndex], ...groups[bestIndex + 1]];
      groups[bestIndex] = merged;
      groups.removeAt(bestIndex + 1);
    }

    return groups;
  }

  static bool _endsWithSentenceTerminator(String text) {
    if (text.isEmpty) return false;
    int i = text.length - 1;
    while (i >= 0) {
      final int code = text.codeUnitAt(i);
      final bool isCloser = code == 0x22 || // "
          code == 0x27 || // '
          code == 0x29 || // )
          code == 0x5D || // ]
          code == 0x7D; // }
      if (!isCloser) break;
      i--;
    }
    if (i < 0) return false;

    final String last = text[i];
    if (last == '!') return true;
    if (last == '?') return true;
    if (last == '！') return true;
    if (last == '？') return true;
    if (last == '。') return true;

    if (last == '…') return false;

    if (last == '.') {
      int dotCount = 0;
      int j = i;
      while (j >= 0 && text[j] == '.') {
        dotCount++;
        j--;
      }
      if (dotCount >= 2) {
        return false;
      }
      return true;
    }

    return false;
  }

  static int _findFirstIndexWhere(List<int> list, bool Function(int) test) {
    for (int i = 0; i < list.length; i++) {
      if (test(list[i])) return i;
    }
    return -1;
  }

  static String _joinAssSentenceText(List<SubtitlesSentenceModel> sentences) {
    final StringBuffer sb = StringBuffer();
    for (final s in sentences) {
      for (final w in s.words) {
        sb.write(w.text);
      }
    }
    return sb.toString();
  }

  /// 把 itemText 的 token（显示文本）映射到 ASS 的时间轴（高亮）。
  /// - 尽量做“词级”对齐；差异大时退化为“句级时间比例映射”
  /// - 对齐失败的额外 token 默认不给时间（-1），避免误高亮
  static List<AssSubtitle> _mapTextTokensToAssTimeline(List<_TextToken> tokens, SubtitlesSentenceModel assSentence) {
    if (tokens.isEmpty) return [];

    final int start = assSentence.sentenceStartTime ?? -1;
    final int end = assSentence.sentenceEndTime ?? -1;

    if (start < 0 || end <= start) {
      return tokens
          .map((t) => AssSubtitle(startTime: -1, endTime: -1, text: t.text, leftSpace: t.leftSpace, rightSpace: ""))
          .toList();
    }

    final List<AssSubtitle> assWords = assSentence.words
        .where((w) => w.text.trim().isNotEmpty && !symbolRegex.hasMatch(w.text))
        .toList();

    if (assWords.isEmpty) {
      return _mapByProportion(tokens, start, end, assWords: assWords);
    }

    final List<_TextToken> expandedTokens = _expandGluedEnglishTokensByAss(tokens: tokens, assWords: assWords);
    final List<String> textNorm = expandedTokens.map((t) => _normalizeForMatch(t.text)).toList();
    final List<String> assNorm = assWords.map((w) => _normalizeForMatch(w.text)).toList();
    final _AlignmentResult alignment = _alignTokens(assNorm, textNorm);

    final int maxLen = assNorm.length > textNorm.length ? assNorm.length : textNorm.length;
    final double mismatchRatio = maxLen == 0 ? 1.0 : alignment.editDistance / maxLen;

    if (mismatchRatio > 0.45) {
      return _mapByProportion(expandedTokens, start, end, assWords: assWords);
    }

    final List<int?> textToAssIndex = alignment.textToAssIndex;
    final List<AssSubtitle> result = List<AssSubtitle>.generate(
      expandedTokens.length,
      (i) => AssSubtitle(
        startTime: -1,
        endTime: -1,
        text: expandedTokens[i].text,
        leftSpace: _assLeftSpaceForToken(
          tokenIndex: i,
          tokenText: expandedTokens[i].text,
          tokenCount: expandedTokens.length,
          assWords: assWords,
        ),
        rightSpace: _assRightSpaceForToken(
          tokenIndex: i,
          tokenText: expandedTokens[i].text,
          tokenCount: expandedTokens.length,
          assWords: assWords,
        ),
      ),
      growable: false,
    );

    for (int i = 0; i < expandedTokens.length; i++) {
      final int? assIndex = textToAssIndex[i];
      if (assIndex != null && assIndex >= 0 && assIndex < assWords.length) {
        final AssSubtitle aw = assWords[assIndex];
        final String tokenNorm = _normalizeForMatch(expandedTokens[i].text);
        final String assWordNorm = _normalizeForMatch(aw.text);
        if (tokenNorm != assWordNorm) {
          continue;
        }
        result[i] = AssSubtitle(
          startTime: aw.startTime,
          endTime: aw.endTime,
          text: expandedTokens[i].text,
          leftSpace: aw.leftSpace,
          rightSpace: aw.rightSpace,
        );
      }
    }

    return result;
  }

  static List<_TextToken> _expandGluedEnglishTokensByAss({
    required List<_TextToken> tokens,
    required List<AssSubtitle> assWords,
  }) {
    if (tokens.isEmpty) return tokens;
    if (assWords.isEmpty) return tokens;

    final List<String> assNorm = assWords.map((w) => _normalizeForMatch(w.text)).toList(growable: false);
    final List<_TextToken> out = [];

    int cursor = 0;
    for (final t in tokens) {
      if (cursor < 0) cursor = 0;
      if (cursor > assNorm.length) cursor = assNorm.length;

      if (!_looksLikeGluedToken(t.text)) {
        out.add(t);
        final String tMatch = _normalizeForMatch(t.text);
        if (tMatch.isNotEmpty && cursor < assNorm.length && tMatch == assNorm[cursor]) {
          cursor += 1;
        }
        continue;
      }

      final String tokenLower = _normalizeForMatch(t.text);
      final _GlueMatch? match = _findGlueMatch(
        tokenLower: tokenLower,
        assNorm: assNorm,
        startIndex: cursor,
      );

      if (match == null || match.count < 2) {
        if (cursor < assNorm.length && tokenLower == assNorm[cursor]) {
          cursor += 1;
        }
        out.add(t);
        continue;
      }

      final List<_TextToken>? pieces = _splitTokenByAssPieces(
        token: t,
        assPiecesNorm: assNorm.sublist(match.start, match.start + match.count),
        assPieces: assWords.sublist(match.start, match.start + match.count),
      );
      if (pieces == null || pieces.length != match.count) {
        out.add(t);
        continue;
      }

      out.addAll(pieces);
      cursor = match.start + match.count;
    }

    return out;
  }

  static bool _looksLikeGluedToken(String token) {
    if (token.isEmpty) return false;
    if (_whiteSpaceRegex.hasMatch(token)) return false;
    if (symbolRegex.hasMatch(token)) return false;
    final String match = _normalizeForMatch(token);
    if (match.length < 4) return false;
    return true;
  }

  static _GlueMatch? _findGlueMatch({
    required String tokenLower,
    required List<String> assNorm,
    required int startIndex,
  }) {
    if (tokenLower.isEmpty) return null;
    if (assNorm.isEmpty) return null;

    const int maxStartLookahead = 30;
    const int maxWordJoin = 10;

    final int start = startIndex < 0 ? 0 : startIndex;
    for (int s = start; s <= start + maxStartLookahead && s < assNorm.length; s++) {
      String built = "";
      final int maxCount = (assNorm.length - s) < maxWordJoin ? (assNorm.length - s) : maxWordJoin;
      for (int k = 1; k <= maxCount; k++) {
        final String part = assNorm[s + k - 1];
        if (part.isEmpty) break;
        built += part;
        if (!tokenLower.startsWith(built)) break;
        if (built == tokenLower) {
          return _GlueMatch(start: s, count: k);
        }
      }
    }
    return null;
  }

  static List<_TextToken>? _splitTokenByAssPieces({
    required _TextToken token,
    required List<String> assPiecesNorm,
    required List<AssSubtitle> assPieces,
  }) {
    final String original = token.text;
    if (original.isEmpty) return null;
    if (assPieces.length != assPiecesNorm.length) return null;

    final int coreStart = _firstIndexOfLetterOrNumber(original);
    final int coreEndExclusive = _lastIndexOfLetterOrNumberExclusive(original);
    if (coreStart < 0 || coreEndExclusive <= coreStart) {
      return null;
    }

    final String prefix = original.substring(0, coreStart);
    final String core = original.substring(coreStart, coreEndExclusive);
    final String suffix = original.substring(coreEndExclusive);

    int pos = 0;
    final List<String> pieces = [];
    for (int i = 0; i < assPiecesNorm.length; i++) {
      final String target = assPiecesNorm[i];
      if (target.isEmpty) return null;

      int end = pos;
      bool found = false;
      while (end < core.length) {
        end += 1;
        final String candidate = core.substring(pos, end);
        final String builtNorm = _normalizeForMatch(candidate);
        if (builtNorm.isEmpty) {
          continue;
        }
        if (!target.startsWith(builtNorm)) {
          continue;
        }
        if (builtNorm == target) {
          pieces.add(candidate);
          pos = end;
          found = true;
          break;
        }
      }
      if (!found) {
        return null;
      }
    }

    if (pos != core.length) {
      return null;
    }

    final List<_TextToken> out = [];
    for (int i = 0; i < pieces.length; i++) {
      String text = pieces[i];
      if (i == 0) text = '$prefix$text';
      if (i == pieces.length - 1) text = '$text$suffix';
      out.add(_TextToken(assPieces[i].leftSpace, text));
    }
    return out;
  }

  static List<AssSubtitle> _mapByProportion(List<_TextToken> tokens, int start, int end, {List<AssSubtitle>? assWords}) {
    if (tokens.isEmpty) return [];
    if (start < 0 || end <= start) {
      return tokens.map((t) => AssSubtitle(startTime: -1, endTime: -1, text: t.text, leftSpace: t.leftSpace)).toList();
    }

    final int total = tokens.length;
    final int duration = end - start;
    final List<AssSubtitle> result = [];
    final Set<String> assNormSet = (assWords == null || assWords.isEmpty)
        ? const {}
        : assWords.map((w) => _normalizeForMatch(w.text)).where((w) => w.isNotEmpty).toSet();

    for (int i = 0; i < total; i++) {
      final int s = start + (duration * i ~/ total);
      int e;
      if (i == total - 1) {
        e = end;
      } else {
        e = start + (duration * (i + 1) ~/ total) - 1;
        if (e < s) e = s;
      }
      final bool canHighlight = assWords == null ? true : _tokenExistsInAss(tokenText: tokens[i].text, assNormSet: assNormSet);
      result.add(AssSubtitle(
        startTime: canHighlight ? s : -1,
        endTime: canHighlight ? e : -1,
        text: tokens[i].text,
        leftSpace: _assLeftSpaceForToken(
          tokenIndex: i,
          tokenText: tokens[i].text,
          tokenCount: total,
          assWords: assWords ?? const [],
        ),
      ));
    }

    return result;
  }

  static bool _tokenExistsInAss({
    required String tokenText,
    required Set<String> assNormSet,
  }) {
    if (tokenText.trim().isEmpty) return false;
    if (symbolRegex.hasMatch(tokenText)) return false;
    if (assNormSet.isEmpty) return false;
    final String norm = _normalizeForMatch(tokenText);
    if (norm.isEmpty) return false;
    return assNormSet.contains(norm);
  }

  static int _firstIndexOfLetterOrNumber(String s) {
    for (int i = 0; i < s.length; i++) {
      final int code = s.codeUnitAt(i);
      if (_letterOrNumberRegex.hasMatch(String.fromCharCode(code))) return i;
    }
    return -1;
  }

  static int _lastIndexOfLetterOrNumberExclusive(String s) {
    for (int i = s.length - 1; i >= 0; i--) {
      final int code = s.codeUnitAt(i);
      if (_letterOrNumberRegex.hasMatch(String.fromCharCode(code))) return i + 1;
    }
    return -1;
  }

  static String _assLeftSpaceForToken({
    required int tokenIndex,
    required String tokenText,
    required int tokenCount,
    required List<AssSubtitle> assWords,
  }) {
    if (symbolRegex.hasMatch(tokenText)) return "";
    if (assWords.isEmpty) return " ";
    int idx = (tokenIndex * assWords.length / tokenCount).floor();
    if (idx < 0) idx = 0;
    if (idx >= assWords.length) idx = assWords.length - 1;
    return assWords[idx].leftSpace;
  }

  static String _assRightSpaceForToken({
    required int tokenIndex,
    required String tokenText,
    required int tokenCount,
    required List<AssSubtitle> assWords,
  }) {
    if (symbolRegex.hasMatch(tokenText)) return "";
    if (assWords.isEmpty) return "";
    int idx = (tokenIndex * assWords.length / tokenCount).floor();
    if (idx < 0) idx = 0;
    if (idx >= assWords.length) idx = assWords.length - 1;
    return assWords[idx].rightSpace;
  }

  static String _normalizeTokenToWord(String token) {
    final String lower = token.toLowerCase();
    final String trimmed = lower.replaceAll(_trimNonWordEdgeRegex, '');
    return trimmed.isEmpty ? lower : trimmed;
  }

  static bool _tokensSimilar(String a, String b) {
    if (a == b) return true;
    if (a.isEmpty || b.isEmpty) return false;
    if (a.length >= 3 && b.length >= 3) {
      return a.contains(b) || b.contains(a);
    }
    return false;
  }

  static _AlignmentResult _alignTokens(List<String> assTokens, List<String> textTokens) {
    final int aLen = assTokens.length;
    final int tLen = textTokens.length;

    final List<List<int>> dp = List.generate(aLen + 1, (_) => List<int>.filled(tLen + 1, 0));

    for (int i = 0; i <= aLen; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= tLen; j++) {
      dp[0][j] = j;
    }

    for (int i = 1; i <= aLen; i++) {
      for (int j = 1; j <= tLen; j++) {
        final int matchCost = _tokensSimilar(assTokens[i - 1], textTokens[j - 1]) ? 0 : 1;
        final int diag = dp[i - 1][j - 1] + matchCost;
        final int del = dp[i - 1][j] + 1;
        final int ins = dp[i][j - 1] + 1;

        int best = diag;
        if (del < best) best = del;
        if (ins < best) best = ins;
        dp[i][j] = best;
      }
    }

    final List<int?> textToAssIndex = List<int?>.filled(tLen, null);
    int i = aLen;
    int j = tLen;
    while (i > 0 || j > 0) {
      if (i > 0 && j > 0) {
        final int matchCost = _tokensSimilar(assTokens[i - 1], textTokens[j - 1]) ? 0 : 1;
        if (dp[i][j] == dp[i - 1][j - 1] + matchCost) {
          if (matchCost == 0) {
            textToAssIndex[j - 1] = i - 1;
          }
          i--;
          j--;
          continue;
        }
      }

      if (i > 0 && dp[i][j] == dp[i - 1][j] + 1) {
        i--;
        continue;
      }
      if (j > 0 && dp[i][j] == dp[i][j - 1] + 1) {
        j--;
        continue;
      }

      if (i > 0) {
        i--;
      } else if (j > 0) {
        j--;
      }
    }

    return _AlignmentResult(editDistance: dp[aLen][tLen], textToAssIndex: textToAssIndex);
  }
}

class _TextToken {
  final String leftSpace;
  final String text;

  const _TextToken(this.leftSpace, this.text);
}

class _AlignmentResult {
  final int editDistance;
  final List<int?> textToAssIndex;

  const _AlignmentResult({
    required this.editDistance,
    required this.textToAssIndex,
  });
}

class _GlueMatch {
  final int start;
  final int count;

  const _GlueMatch({
    required this.start,
    required this.count,
  });
}

class TextOptionModel {
  int position;
  String text;

  TextOptionModel(this.position, this.text);
}
