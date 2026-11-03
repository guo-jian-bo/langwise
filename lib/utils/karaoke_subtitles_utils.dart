import 'dart:convert';

class AssSubtitle {
  int startTime;
  int endTime;
  String text;
  bool isRead = false;

  /// 左边的空格 比如英语 this is 中间有空格 你好 中间没有空格
  final String leftSpace;
  String other;

  AssSubtitle({
    required this.startTime,
    required this.endTime,
    required this.text,
    this.leftSpace = "",
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

  /// Dialogue原始文本
  String? dialogueText;

  SubtitlesSentenceModel({
    required this.words,
    this.sentenceStartTime,
    this.sentenceEndTime,
    this.dialogueText,
  });
}


/// 卡拉OK字幕
class KaraokeSubtitlesUtils {
  static final symbolRegex = RegExp(r'^[\p{P}\p{S}\p{M}\p{C}\p{Z}]+$', unicode: true);



  /// 解析ass文本中的对话字幕 以换行符拆分
  static List<SubtitlesSentenceModel> parseAssDialogue(String assText){
    if(assText == "") return [];

    List<SubtitlesSentenceModel> dialogues = [];
    
    var lines = LineSplitter.split(assText).toList();

    for (var line in lines) {
      SubtitlesSentenceModel currentDialogue = SubtitlesSentenceModel(words: []);
      if (line.startsWith('Dialogue:')) {
        var parts = line.split(',');

        // 确保有足够的部分来处理
        if (parts.length >= 10) {
          var startTime = parts[1].trim();  // parts[1] 是开始时间
          var endTime = parts[2].trim();  // parts[2] 是开始时间
        

          var text = parts.sublist(9).join(',').trim();  // 字幕文本从第10个部分开始

          // 解析时间为 Duration 类型
          var startDuration = _parseTimeToDuration(startTime);
          var endDuration = _parseTimeToDuration(endTime);

          currentDialogue.sentenceStartTime = startDuration;
          currentDialogue.sentenceEndTime = endDuration;
          currentDialogue.dialogueText = line;
          

          // 正则匹配字幕中的单词，提取出带特效的单词
          var regex = RegExp(r'\{\\k(\d+)\}([^{]+)(?=\{\\k|$)');
          var matches = regex.allMatches(text);


          int wordStartTime = startDuration; // 开始时间
          int wordEndTime = startDuration; // 结束时间

          // 提取每个匹配到的单词
          for (int i = 0; i < matches.length; i++) {
            var match = matches.elementAt(i);
            var timeStr = match.group(1) ?? '';
            int timeInt = (int.tryParse(timeStr)??0) * 10;
            var word = (match.group(2) ?? '').trim();

            wordEndTime += timeInt;

            String leftSpace = i == 0 ? "" : getLocalSpace();
            if(symbolRegex.hasMatch(word) && word.length == 1) {
              leftSpace = "";//待定

              wordStartTime += timeInt;
              currentDialogue.words.add(AssSubtitle(
                startTime: wordEndTime,
                endTime: wordEndTime,
                text: word,
              ));
              continue;
            }

            if(word.trim().isEmpty){
              wordStartTime += timeInt;
              continue;
            }

            currentDialogue.words.add(AssSubtitle(
              startTime: wordStartTime,
              endTime: wordEndTime,
              text: word,
              leftSpace: leftSpace,
            ));
            
            wordStartTime += timeInt;
            
          }
        }
      }
      dialogues.add(currentDialogue);
    }

    return dialogues;
  }

  /// 按 Dialogue 行拆分 ass 文本
  /// * 每一个 Dialogue 对应一个 SubtitlesSentenceModel
  static List<SubtitlesSentenceModel> parseAssSentenceByDialogue(String assText) {
    if (assText == "") return [];

    List<SubtitlesSentenceModel> dialogues = [];
    final RegExp dialogueRegex = RegExp(r'Dialogue:[\s\S]*?(?=Dialogue:|$)');
    final matches = dialogueRegex.allMatches(assText);

    for (final match in matches) {
      final line = (match.group(0) ?? '').trim();
      if (line.isEmpty) {
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
        var text = parts.sublist(9).join(',').trim();
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


  static List<AssSubtitle> parseKaraokeSubtitles(String assText) {
    if (assText == "") return [];

    List<AssSubtitle> subtitles = [];

    List<SubtitlesSentenceModel> dialogues = parseAssDialogue(assText);

    for (SubtitlesSentenceModel dialogue in dialogues) {
      subtitles.addAll(dialogue.words);
    }

    return subtitles;
  }

  static String getLocalSpace() {
    // 默认返回空格，或者根据需要返回其他值
    return " ";
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
    var text = parts.sublist(9).join(',').trim();

    var startDuration = _parseTimeToDuration(startTime);
    var endDuration = _parseTimeToDuration(endTime);

    currentDialogue.sentenceStartTime = startDuration;
    currentDialogue.sentenceEndTime = endDuration;
    currentDialogue.dialogueText = line;

    var regex = RegExp(r'\{\\k(\d+)\}([^\{]+)(?=\{\\k|$)');
    var matches = regex.allMatches(text);

    int wordStartTime = startDuration;
    int wordEndTime = startDuration;

    for (int i = 0; i < matches.length; i++) {
      var match = matches.elementAt(i);
      var timeStr = match.group(1) ?? '';
      int timeInt = (int.tryParse(timeStr) ?? 0) * 10;
      var word = (match.group(2) ?? '').trim();

      wordEndTime += timeInt;

      String leftSpace = i == 0 ? "" : getLocalSpace();
      if (symbolRegex.hasMatch(word) && word.length == 1) {
        leftSpace = "";

        wordStartTime += timeInt;
        currentDialogue.words.add(AssSubtitle(
          startTime: wordEndTime,
          endTime: wordEndTime,
          text: word,
        ));
        continue;
      }

      if (word.trim().isEmpty) {
        wordStartTime += timeInt;
        continue;
      }

      currentDialogue.words.add(AssSubtitle(
        startTime: wordStartTime,
        endTime: wordEndTime,
        text: word,
        leftSpace: leftSpace,
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
  /// * 从allAss中提取itemText对应的ass字幕
  /// * 返回itemText对应的ass字幕列表
  static List<SubtitlesSentenceModel> parseAssLineBreakByText(String itemText, List<SubtitlesSentenceModel> allAss) {
    String itemTextTrim = itemText.replaceAll(" ", "");

    List<SubtitlesSentenceModel> result = [];
    String assItemText = "";
    for (var assList in allAss) {
      for (var assSubtitle in assList.words) {
        String assText = assSubtitle.text;
        assItemText += assText.replaceAll(" ", "");
      }

      if (itemTextTrim.contains(assItemText)) {
        result.add(assList);
      }
    }
    return result;
  }
}

class TextOptionModel {
  int position;
  String text;

  TextOptionModel(this.position, this.text);
}
