import '../../../../../../common/entities/entities.dart';
import 'audio_subtitle_editor_model.dart';

class DialogueModel {
  int? index;
  int? startTime;
  int? endTime;
  String? kTagText;
  String? text;
  List<KTagModel>? kTagList;
  bool isEdit;
  int? layerIndex;
  String? prefixStr;
  String? zhDialogueStr;

  DialogueModel({
    this.index,
    this.startTime,
    this.endTime,
    this.kTagText,
    this.text,
    this.kTagList,
    this.layerIndex,
    this.isEdit = false,
    this.zhDialogueStr,
  });

  @override
  String toString() {
    return 'DialogueModel(index: $index, startTime: $startTime, endTime: $endTime, kTagText: $kTagText, text: $text, kTagList: $kTagList, layerIndex: $layerIndex, isEdit: $isEdit, zhDialogueStr: $zhDialogueStr)';
  }

  String get endTimeStr {
    return KaraokeSubtitlesUtils.parseTimeToString(endTime!);
  }

  String get startTimeStr {
    return KaraokeSubtitlesUtils.parseTimeToString(startTime!);
  }

  String get dialogueStr {
    return 'Dialogue:$layerIndex,$startTimeStr,$endTimeStr,$prefixStr,$kTagText\n';
  }

  String? get zhDialogueAss {
    if (zhDialogueStr == null) return null;
    return 'Dialogue:$layerIndex,$startTimeStr,$endTimeStr,$prefixStr,$zhDialogueStr\n';
  }
}

class KTagModel {
  int? startTime;
  int? duration;
  String? kTagText;
  String? text;
  String rightSpace;
  bool isEdit;

  KTagModel({
    this.startTime,
    this.duration,
    this.kTagText,
    this.text,
    this.rightSpace = '',
    this.isEdit = false,
  });

  @override
  String toString() {
    return 'AssSubtitle(startTime: $startTime, duration: $duration, kTagText: $kTagText, text: $text)';
  }
}

class CutDialogueModelResult {
  bool isSuccess;
  List<DialogueModel>? result;
  String? message;

  CutDialogueModelResult({
    this.isSuccess = false,
    this.result,
    this.message,
  });
}

// 音频模型处理类
class KaraokeSubtitlesUtils {
  static final symbolRegex = RegExp(r'^[\p{P}\p{S}\p{M}\p{C}\p{N}\p{Z}]+$', unicode: true);
  static final RegExp publicRegexBlank = RegExp(r'{{(\d+)}}');

  //将ass字符串解析为DialogueModel列表
  static List<DialogueModel> parseAssString(AudioSubtitleEditorModel? audioModel) {
    String assText = audioModel?.ass ?? "";
    if (assText == "") return [];

    List<String> zhDialogueStrList = [];
    for (LanguageText gloss in audioModel?.translate ?? []) {
      if (gloss.lang == 'zh' && gloss.text != null) {
        String zhAss = gloss.text!;
        var dialogues = zhAss.split('Dialogue:');
        if (dialogues.length == 1) break;
        dialogues.removeAt(0);

        for (var dialogueStr in dialogues) {
          String afterBrace = dialogueStr.split('0,0,0,,').last;
          afterBrace = afterBrace.replaceAll('\n', '');
          zhDialogueStrList.add(afterBrace);
        }
        break;
      }
    }

    List<DialogueModel> dialogueList = [];
    final List<String> dialogues = assText.split('Dialogue:');
    if (dialogues.length > 1) {
      dialogues.removeAt(0);
    }

    for (int i = 0; i < dialogues.length; i++) {
      final String dialogueStr = dialogues[i].replaceFirst(RegExp(r'[\r\n]+$'), '');
      if (dialogueStr.replaceAll(RegExp(r'[\r\n]+'), '').trim().isEmpty) {
        continue;
      }
      final String? zhDialogueStr =
          i < zhDialogueStrList.length ? zhDialogueStrList[i] : null;
      final DialogueModel? dialogueModel = _parseDialogueString(
        dialogueStr,
        dialogueList.length,
        zhDialogueStr,
      );
      if (dialogueModel != null) {
        dialogueList.add(dialogueModel);
      }
    }

    return dialogueList;
  }

  static String buildDialogueTextFromKTags(List<KTagModel> tags) {
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < tags.length; i++) {
      final KTagModel tag = tags[i];
      buffer.write(tag.text ?? '');
      buffer.write(tag.rightSpace);
    }
    return buffer.toString();
  }

  static String buildKTagTextFromKTags(List<KTagModel> tags) {
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < tags.length; i++) {
      final KTagModel tag = tags[i];
      final int duration = tag.duration ?? 0;
      final String text = tag.text ?? '';
      final String current = '{\\k${(duration / 10).toInt()}}$text${tag.rightSpace}';
      tag.kTagText = current;
      buffer.write(current);
    }
    return buffer.toString();
  }

  static DialogueModel? _parseDialogueString(
    String dialogueStr,
    int dialogueIndex,
    String? zhDialogueStr,
  ) {
    final int firstBraceIndex = dialogueStr.indexOf('{');
    if (firstBraceIndex == -1) {
      return null;
    }

    final String beforeBrace = dialogueStr.substring(0, firstBraceIndex);
    final String afterBrace = dialogueStr.substring(firstBraceIndex);
    final List<String> parts = beforeBrace.split(',');
    if (parts.length != 10) {
      return null;
    }
    parts.last = afterBrace;

    final DialogueModel dialogueModel = DialogueModel();
    dialogueModel.zhDialogueStr = zhDialogueStr;
    dialogueModel.prefixStr = parts.sublist(3, 9).join(',');
    dialogueModel.index = dialogueIndex;
    dialogueModel.layerIndex = int.tryParse(parts[0].trim());
    dialogueModel.startTime = parseTimeToDuration(parts[1].trim());
    dialogueModel.endTime = parseTimeToDuration(parts[2].trim());
    dialogueModel.kTagText = parts[9];

    final List<KTagModel> kTagList = <KTagModel>[];
    final RegExp regex = RegExp(r'{\\k(\d+)}([^{}]*)');
    final List<RegExpMatch> matches = regex.allMatches(afterBrace).toList();
    int wordStartTime = dialogueModel.startTime ?? 0;
    for (final RegExpMatch match in matches) {
      final int duration = (int.tryParse(match.group(1) ?? '') ?? 0) * 10;
      if (duration <= 0) {
        continue;
      }
      final String rawText = match.group(2) ?? '';
      kTagList.add(
        KTagModel(
          startTime: wordStartTime,
          duration: duration,
          text: rawText,
          rightSpace: '',
          kTagText: '{\\k${(duration / 10).toInt()}}$rawText',
        ),
      );
      wordStartTime += duration;
    }

    dialogueModel.kTagList = kTagList;
    dialogueModel.text = buildDialogueTextFromKTags(kTagList);
    dialogueModel.kTagText = buildKTagTextFromKTags(kTagList);
    return dialogueModel;
  }

  // 将字幕时间字符串（如 "0:00:01.00"）转换为 Duration 类型
  static int parseTimeToDuration(String time) {
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

  // 格式化时间 1300 -> 0:00:1.30
  static String parseTimeToString(int time) {
    int hours = time ~/ 3600000;
    int minutes = (time % 3600000) ~/ 60000;
    int seconds = (time % 60000) ~/ 1000;
    int milliseconds = time % 1000;
    return '${hours.toString().padLeft(1, '0')}:${minutes.toString().padLeft(2, '0')}:$seconds.${(milliseconds ~/ 10).toString().padLeft(2, '0')}';
  }

  // 格式化时间 5000 -> 00:05
  static String formatTime(int milliseconds) {
    int totalSeconds = milliseconds ~/ 1000;
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  //合并2个DialogueModel为一个
  static DialogueModel mergeDialogueModel(DialogueModel dialogueModel1, DialogueModel dialogueModel2) {
    if (dialogueModel1.index! > dialogueModel2.index!) {
      DialogueModel temp = dialogueModel1;
      dialogueModel1 = dialogueModel2;
      dialogueModel2 = temp;
    }

    KTagModel tagModel = KTagModel(
      startTime: dialogueModel1.endTime!,
      duration: dialogueModel2.startTime! - dialogueModel1.endTime!,
      kTagText: '{\\k${((dialogueModel2.startTime! - dialogueModel1.endTime!) / 10).toInt()}}',
      text: '',
    );
    dialogueModel1.kTagList!.add(tagModel);

    DialogueModel dialogueModel = DialogueModel();
    dialogueModel.layerIndex = dialogueModel1.layerIndex;
    dialogueModel.zhDialogueStr = null;
    dialogueModel.prefixStr = dialogueModel1.prefixStr;
    dialogueModel.index = dialogueModel1.index;
    dialogueModel.startTime = dialogueModel1.startTime!;
    dialogueModel.endTime = dialogueModel2.endTime!;
    dialogueModel.kTagText = dialogueModel1.kTagText! + tagModel.kTagText! + dialogueModel2.kTagText!;
    dialogueModel.text = dialogueModel1.text! + ' ' + dialogueModel2.text!;
    dialogueModel.kTagList = dialogueModel1.kTagList! + dialogueModel2.kTagList!;
    return dialogueModel;
  }

  // 一个DialogueModel通过分割句子，转换为多个DialogueModel
  static CutDialogueModelResult sentenceToDialogueModels(DialogueModel dialogueModel) {
    List<String> sentences = _splitSentencesWithText(dialogueModel.text!);
    if (sentences.length <= 1) {
      return CutDialogueModelResult(
        isSuccess: false,
        message: '该句为单独的句子，无需切分',
      );
    }

    List<DialogueModel> dialogueList = [];
    List lastWordList = [];
    for (var i = 0; i < sentences.length; i++) {
      String lastWord = sentences[i].split(' ').last;
      lastWordList.add(lastWord);
    }

    int lastWordNum = lastWordList.length;
    List<KTagModel> kTagList = dialogueModel.kTagList ?? [];
    int matchIndex = 0;
    List<List<KTagModel>> matchResult = [];
    for (int i = 0; i < kTagList.length; i++) {
      if (lastWordList.isNotEmpty && kTagList[i].text == lastWordList.first) {
        List<KTagModel> kTagModelList = kTagList.sublist(matchIndex, i + 1);
        matchResult.add(kTagModelList);
        matchIndex = i + 1;
        lastWordList.removeAt(0);
      }
    }

    if (matchResult.length != lastWordNum) {
      return CutDialogueModelResult(
        isSuccess: false,
        message: '分割失败,请检查所有K标签格式是否符合规范',
      );
    }

    if (matchResult.last.last.startTime! > dialogueModel.endTime!) {
      return CutDialogueModelResult(
        isSuccess: false,
        message: '存在K标签的开始时间超过整个句子的结束时间',
      );
    }

    for (var i = 0; i < matchResult.length; i++) {
      matchResult[i].removeWhere((item) {
        String text = item.text!;
        text = text.trim();
        return text.isEmpty;
      });
    }

    for (var i = 0; i < matchResult.length; i++) {
      DialogueModel newDialogueModel = DialogueModel();
      newDialogueModel.zhDialogueStr = null;
      newDialogueModel.layerIndex = dialogueModel.layerIndex;
      newDialogueModel.prefixStr = dialogueModel.prefixStr;
      newDialogueModel.index = dialogueModel.index! + i;
      newDialogueModel.startTime = matchResult[i].first.startTime;
      if (i == matchResult.length - 1) {
        newDialogueModel.endTime = dialogueModel.endTime;
      } else {
        newDialogueModel.endTime = matchResult[i].last.startTime! + matchResult[i].last.duration!;
      }
      newDialogueModel.kTagText = matchResult[i].map((e) => e.kTagText).join('');
      newDialogueModel.text = matchResult[i].map((e) => e.text).join(' ');
      newDialogueModel.kTagList = matchResult[i];
      dialogueList.add(newDialogueModel);
    }

    return CutDialogueModelResult(
      isSuccess: true,
      result: dialogueList,
    );
  }

  // 将字符串分为单个的句子
  static List<String> _splitSentencesWithText(String text) {
    final regex = RegExp(r'''[^。！？？；.!?,;…]+(?:\.{3}|…)(?:[''"""])?|[^。！？？；.!?,;…]+[。！？.!?](?:[''"""])?|[^。！？？；.!?,;…]+[，；,;…][''"""]|[^。！？？；.!?,;…]+[，；,;…]''');

    final matches = regex.allMatches(text).toList();
    final sentences = <String>[];

    for (final m in matches) {
      final s = m.group(0)?.trim();
      if (s != null && s.isNotEmpty) {
        sentences.add(s);
      }
    }

    // 处理最后一句没有标点的情况
    if (text.trim().isNotEmpty) {
      final lastEnd = matches.isNotEmpty ? matches.last.end : 0;
      if (lastEnd < text.length) {
        final tail = text.substring(lastEnd).trim();
        if (tail.isNotEmpty) {
          sentences.add(tail);
        }
      }
    }

    return sentences;
  }
}
