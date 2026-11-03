class AssWaveformDialogueModel {
  AssWaveformDialogueModel({
    this.index,
    this.startTime,
    this.endTime,
    this.kTagText,
    this.text,
    this.kTagList = const [],
    this.isEdit = false,
    this.layerIndex,
    this.prefixStr,
    this.zhDialogueStr,
  });

  int? index;
  int? startTime;
  int? endTime;
  String? kTagText;
  String? text;
  List<AssWaveformKTagModel> kTagList;
  bool isEdit;
  int? layerIndex;
  String? prefixStr;
  String? zhDialogueStr;

  String get startTimeStr => AssWaveformParser.formatTime(startTime ?? 0);

  String get endTimeStr => AssWaveformParser.formatTime(endTime ?? 0);

  AssWaveformDialogueModel copy() {
    return AssWaveformDialogueModel(
      index: index,
      startTime: startTime,
      endTime: endTime,
      kTagText: kTagText,
      text: text,
      kTagList: kTagList.map((item) => item.copy()).toList(),
      isEdit: isEdit,
      layerIndex: layerIndex,
      prefixStr: prefixStr,
      zhDialogueStr: zhDialogueStr,
    );
  }
}

class AssWaveformKTagModel {
  AssWaveformKTagModel({
    this.startTime,
    this.duration,
    this.kTagText,
    this.text,
    this.isEdit = false,
  });

  int? startTime;
  int? duration;
  String? kTagText;
  String? text;
  bool isEdit;

  AssWaveformKTagModel copy() {
    return AssWaveformKTagModel(
      startTime: startTime,
      duration: duration,
      kTagText: kTagText,
      text: text,
      isEdit: isEdit,
    );
  }
}

class AssEditorChangeResult {
  const AssEditorChangeResult({
    required this.ass,
    required this.translateAss,
    required this.dialogueList,
  });

  final String ass;
  final String? translateAss;
  final List<AssWaveformDialogueModel> dialogueList;
}

class AssWaveformParser {
  static final RegExp publicRegexBlank = RegExp(r'{{(\d+)}}');

  static List<AssWaveformDialogueModel> parse({
    required String ass,
    String? translateAss,
  }) {
    if (ass.trim().isEmpty) return [];
    final List<String> zhDialogueStrList = [];
    if (translateAss != null && translateAss.trim().isNotEmpty) {
      final List<String> zhDialogues = translateAss.split('Dialogue:');
      if (zhDialogues.length > 1) {
        zhDialogues.removeAt(0);
        for (final dialogueStr in zhDialogues) {
          final String afterPrefix = dialogueStr.split(',').length >= 10
              ? dialogueStr.split(',').sublist(9).join(',').replaceAll('\n', '')
              : '';
          zhDialogueStrList.add(afterPrefix);
        }
      }
    }

    final List<AssWaveformDialogueModel> dialogueList = [];
    final List<String> dialogues = ass.split('Dialogue:');
    if (dialogues.length > 1) {
      dialogues.removeAt(0);
    }

    for (int i = 0; i < dialogues.length; i++) {
      final String dialogueStr = dialogues[i];
      final int braceIndex = dialogueStr.indexOf('{');
      if (braceIndex < 0) {
        continue;
      }
      final String beforeBrace = dialogueStr.substring(0, braceIndex);
      final String afterBrace = dialogueStr.substring(braceIndex);
      final List<String> parts = beforeBrace.split(',');
      if (parts.length != 10) {
        continue;
      }
      parts[9] = afterBrace;
      final List<String> prefixStrList = parts.sublist(3, parts.length - 1);
      dialogueList.add(
        _parseDialogueString(
          parts: parts,
          prefixStr: prefixStrList.join(','),
          dialogueIndex: dialogueList.length,
          zhDialogueStr: i < zhDialogueStrList.length ? zhDialogueStrList[i] : null,
        ),
      );
    }
    return dialogueList;
  }

  static AssWaveformDialogueModel _parseDialogueString({
    required List<String> parts,
    required String prefixStr,
    required int dialogueIndex,
    String? zhDialogueStr,
  }) {
    final AssWaveformDialogueModel dialogueModel = AssWaveformDialogueModel(
      index: dialogueIndex,
      layerIndex: int.tryParse(parts[0].trim()),
      startTime: parseTime(parts[1].trim()),
      endTime: parseTime(parts[2].trim()),
      prefixStr: prefixStr,
      kTagText: parts[9].trim(),
      zhDialogueStr: zhDialogueStr,
    );
    final List<AssWaveformKTagModel> kTagList = [];
    final RegExp regex = RegExp(r'{\\k(\d+)}\s*([^{}]*?)\s*(?={\\k|$)');
    final Iterable<RegExpMatch> matches = regex.allMatches(dialogueModel.kTagText ?? '');
    int wordStartTime = dialogueModel.startTime ?? 0;
    final List<String> wordList = [];
    for (final RegExpMatch match in matches) {
      final int duration = (int.tryParse(match.group(1) ?? '') ?? 0) * 10;
      if (duration <= 0) {
        continue;
      }
      final String word = match.group(2) ?? '';
      wordList.add(word);
      kTagList.add(
        AssWaveformKTagModel(
          startTime: wordStartTime,
          duration: duration,
          kTagText: '{\\k${(duration / 10).toInt()}}$word',
          text: word,
        ),
      );
      wordStartTime += duration;
    }
    dialogueModel.kTagList = kTagList;
    dialogueModel.text = wordList.join(' ').trim();
    return dialogueModel;
  }

  static String buildAss(List<AssWaveformDialogueModel> dialogueList) {
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < dialogueList.length; i++) {
      final AssWaveformDialogueModel dialogue = dialogueList[i];
      dialogue.index = i;
      dialogue.kTagText = dialogue.kTagList.map((item) => item.kTagText ?? '').join();
      dialogue.text = dialogue.kTagList.map((item) => item.text ?? '').join(' ').trim();
      buffer.write(
        'Dialogue:${dialogue.layerIndex ?? 0},${formatTime(dialogue.startTime ?? 0)},${formatTime(dialogue.endTime ?? 0)},${dialogue.prefixStr ?? '0,0,0,,'},${dialogue.kTagText ?? ''}\n',
      );
    }
    return buffer.toString();
  }

  static String? buildTranslateAss(List<AssWaveformDialogueModel> dialogueList) {
    final Iterable<AssWaveformDialogueModel> translated = dialogueList.where(
      (item) => (item.zhDialogueStr ?? '').trim().isNotEmpty,
    );
    if (translated.isEmpty) {
      return null;
    }
    final StringBuffer buffer = StringBuffer();
    for (final AssWaveformDialogueModel dialogue in translated) {
      buffer.write(
        'Dialogue:${dialogue.layerIndex ?? 0},${formatTime(dialogue.startTime ?? 0)},${formatTime(dialogue.endTime ?? 0)},${dialogue.prefixStr ?? '0,0,0,,'},${dialogue.zhDialogueStr ?? ''}\n',
      );
    }
    return buffer.toString();
  }

  static String formatTime(int time) {
    final int hours = time ~/ 3600000;
    final int minutes = (time % 3600000) ~/ 60000;
    final int seconds = (time % 60000) ~/ 1000;
    final int milliseconds = time % 1000;
    return '${hours.toString().padLeft(1, '0')}:${minutes.toString().padLeft(2, '0')}:$seconds.${(milliseconds ~/ 10).toString().padLeft(2, '0')}';
  }

  static int parseTime(String time) {
    final List<String> parts = time.split(':');
    int hours = 0;
    int minutes = 0;
    int seconds = 0;
    int milliseconds = 0;
    if (parts.length == 3) {
      hours = int.tryParse(parts[0]) ?? 0;
      minutes = int.tryParse(parts[1]) ?? 0;
      final List<String> secondsAndMillis = parts[2].split('.');
      seconds = int.tryParse(secondsAndMillis[0]) ?? 0;
      milliseconds = secondsAndMillis.length > 1 ? int.tryParse(secondsAndMillis[1].padRight(3, '0')) ?? 0 : 0;
    } else if (parts.length == 2) {
      minutes = int.tryParse(parts[0]) ?? 0;
      final List<String> secondsAndMillis = parts[1].split('.');
      seconds = int.tryParse(secondsAndMillis[0]) ?? 0;
      milliseconds = secondsAndMillis.length > 1 ? int.tryParse(secondsAndMillis[1].padRight(3, '0')) ?? 0 : 0;
    }
    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
    ).inMilliseconds;
  }

  static void normalizeDialogue(AssWaveformDialogueModel dialogue) {
    final int start = dialogue.startTime ?? 0;
    final int end = dialogue.endTime ?? start;
    final int span = end > start ? end - start : 0;
    if (dialogue.kTagList.isEmpty) {
      dialogue.kTagList = [
        AssWaveformKTagModel(
          startTime: start,
          duration: span <= 0 ? 500 : span,
          text: dialogue.text ?? '',
          kTagText: '{\\k${((span <= 0 ? 500 : span) / 10).round()}}${dialogue.text ?? ''}',
        ),
      ];
    }
    int cursor = start;
    int total = dialogue.kTagList.fold<int>(0, (sum, item) => sum + (item.duration ?? 0));
    total = total <= 0 ? dialogue.kTagList.length * 500 : total;
    for (int i = 0; i < dialogue.kTagList.length; i++) {
      final AssWaveformKTagModel item = dialogue.kTagList[i];
      final int duration = i == dialogue.kTagList.length - 1
          ? (end > cursor ? end - cursor : (item.duration ?? 500))
          : (((item.duration ?? 500) / total) * (span <= 0 ? total : span)).round().clamp(1, 600000);
      item.startTime = cursor;
      item.duration = duration;
      item.kTagText = '{\\k${(duration / 10).round()}}${item.text ?? ''}';
      cursor += duration;
    }
    dialogue.kTagText = dialogue.kTagList.map((item) => item.kTagText ?? '').join();
    dialogue.text = dialogue.kTagList.map((item) => item.text ?? '').join(' ').trim();
  }

  static AssWaveformDialogueModel mergeDialogues(List<AssWaveformDialogueModel> dialogueList) {
    final List<AssWaveformDialogueModel> sorted = dialogueList.map((item) => item.copy()).toList()
      ..sort((a, b) => (a.index ?? 0).compareTo(b.index ?? 0));
    final AssWaveformDialogueModel first = sorted.first;
    final AssWaveformDialogueModel last = sorted.last;
    final List<AssWaveformKTagModel> mergedKTags = [];
    for (final AssWaveformDialogueModel item in sorted) {
      mergedKTags.addAll(item.kTagList.map((element) => element.copy()));
    }
    final AssWaveformDialogueModel result = AssWaveformDialogueModel(
      index: first.index,
      startTime: first.startTime,
      endTime: last.endTime,
      layerIndex: first.layerIndex,
      prefixStr: first.prefixStr,
      zhDialogueStr: sorted.map((item) => item.zhDialogueStr).whereType<String>().where((item) => item.trim().isNotEmpty).join(' ').trim(),
      kTagList: mergedKTags,
    );
    normalizeDialogue(result);
    return result;
  }

  static List<AssWaveformDialogueModel> splitDialogueBySentence(AssWaveformDialogueModel dialogue) {
    final List<String> sentences = _splitSentences(dialogue.text ?? '');
    if (sentences.length <= 1) {
      return [dialogue.copy()];
    }
    int offset = 0;
    final List<AssWaveformDialogueModel> result = [];
    for (int i = 0; i < sentences.length; i++) {
      final List<AssWaveformKTagModel> kTags = dialogue.kTagList.skip(offset).take(sentences[i].split(RegExp(r'\s+')).where((item) => item.trim().isNotEmpty).length).map((item) => item.copy()).toList();
      offset += sentences[i].split(RegExp(r'\s+')).where((item) => item.trim().isNotEmpty).length;
      if (kTags.isEmpty) {
        continue;
      }
      final AssWaveformDialogueModel item = AssWaveformDialogueModel(
        index: (dialogue.index ?? 0) + i,
        startTime: kTags.first.startTime,
        endTime: (kTags.last.startTime ?? 0) + (kTags.last.duration ?? 0),
        layerIndex: dialogue.layerIndex,
        prefixStr: dialogue.prefixStr,
        zhDialogueStr: null,
        kTagList: kTags,
      );
      normalizeDialogue(item);
      result.add(item);
    }
    return result.isEmpty ? [dialogue.copy()] : result;
  }

  static List<String> _splitSentences(String text) {
    final RegExp regex = RegExp(r'''[^。！？？；.!?,;…]+(?:\.{3}|…)(?:[''"""])?|[^。！？？；.!?,;…]+[。！？.!?](?:[''"""])?|[^。！？？；.!?,;…]+[，；,;…][''"""]|[^。！？？；.!?,;…]+[，；,;…]''');
    final List<RegExpMatch> matches = regex.allMatches(text).toList();
    final List<String> sentences = [];
    for (final RegExpMatch match in matches) {
      final String? current = match.group(0)?.trim();
      if (current != null && current.isNotEmpty) {
        sentences.add(current);
      }
    }
    if (sentences.isEmpty && text.trim().isNotEmpty) {
      sentences.add(text.trim());
    }
    return sentences;
  }
}
