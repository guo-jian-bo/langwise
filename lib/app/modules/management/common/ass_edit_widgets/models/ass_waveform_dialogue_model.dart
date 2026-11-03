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


  static String formatTime(int time) {
    final int hours = time ~/ 3600000;
    final int minutes = (time % 3600000) ~/ 60000;
    final int seconds = (time % 60000) ~/ 1000;
    final int milliseconds = time % 1000;
    return '${hours.toString().padLeft(1, '0')}:${minutes.toString().padLeft(2, '0')}:$seconds.${(milliseconds ~/ 10).toString().padLeft(2, '0')}';
  }

}
