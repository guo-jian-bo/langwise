part of 'manage_audio_subtitle_editor_controller.dart';

extension AudioEditorSentenceCrudMethods on ManageAudioSubtitleEditorController {
  void insertDialogueBefore(int dialogueIndex, String text) {
    if (dialogueIndex < 0 || dialogueIndex >= dialogueList.length) return;
    final words = text.trim().split(RegExp(r'\s+')).where((e) => e.trim().isNotEmpty).toList();
    if (words.isEmpty) {
      ToastUtils.showManageToast(text: '请输入句子文本');
      return;
    }

    final cur = dialogueList[dialogueIndex];
    final int curStart = cur.startTime ?? 0;
    final int prevEnd = dialogueIndex > 0 ? (dialogueList[dialogueIndex - 1].endTime ?? 0) : 0;
    final int startMs = prevEnd;
    final int endMs = curStart;
    if (endMs <= startMs) {
      ToastUtils.showManageToast(text: '当前句前没有可用空隙');
      return;
    }
    _insertDialogueAt(dialogueIndex, words, startMs, endMs);
  }

  void insertDialogueAfter(int dialogueIndex, String text) {
    if (dialogueIndex < 0 || dialogueIndex >= dialogueList.length) return;
    final words = text.trim().split(RegExp(r'\s+')).where((e) => e.trim().isNotEmpty).toList();
    if (words.isEmpty) {
      ToastUtils.showManageToast(text: '请输入句子文本');
      return;
    }

    final cur = dialogueList[dialogueIndex];
    final int curEnd = cur.endTime ?? (cur.startTime ?? 0);
    final int nextStart = (dialogueIndex + 1 < dialogueList.length)
        ? (dialogueList[dialogueIndex + 1].startTime ?? curEnd)
        : totalDurationTime;
    final int startMs = curEnd;
    final int endMs = nextStart;
    if (endMs <= startMs) {
      ToastUtils.showManageToast(text: '当前句后没有可用空隙');
      return;
    }
    _insertDialogueAt(dialogueIndex + 1, words, startMs, endMs);
  }

  void _insertDialogueAt(int insertIndex, List<String> words, int startMs, int endMs) {
    final int durationMs = (endMs - startMs).clamp(1, totalDurationTime);
    final int per = (durationMs / words.length).floor().clamp(1, durationMs);

    final List<KTagModel> kTags = [];
    int cursor = startMs;
    for (var i = 0; i < words.length; i++) {
      final int d = (i == words.length - 1) ? (endMs - cursor) : per;
      final int dur = d.clamp(1, endMs - cursor);
      kTags.add(KTagModel(
        startTime: cursor,
        duration: dur,
        kTagText: '{\\k${(dur / 10).toInt()}}${words[i]}',
        text: words[i],
      ));
      cursor += dur;
      if (cursor >= endMs) break;
    }

    final String defaultPrefix = (() {
      if (insertIndex > 0) {
        return dialogueList[insertIndex - 1].prefixStr ?? '';
      }
      if (insertIndex < dialogueList.length) {
        return dialogueList[insertIndex].prefixStr ?? '';
      }
      return '';
    })();

    final DialogueModel newDialogue = DialogueModel();
    newDialogue.zhDialogueStr = null;
    newDialogue.layerIndex = 0;
    newDialogue.prefixStr = defaultPrefix.isNotEmpty ? defaultPrefix : 'Default,,0,0,0,';
    newDialogue.startTime = startMs;
    newDialogue.endTime = endMs;
    newDialogue.kTagList = kTags;
    newDialogue.kTagText = kTags.map((e) => e.kTagText).join('');
    newDialogue.text = words.join(' ');

    dialogueList.insert(insertIndex, newDialogue);
    kContentTextFieldList.insert(insertIndex, kTags.map((e) => TextEditingController(text: e.text ?? '')).toList());
    kContentFocusNodeList.insert(insertIndex, kTags.map((_) => FocusNode()).toList());
    zhCaptionsTextFieldList.insert(insertIndex, TextEditingController(text: newDialogue.zhDialogueStr));
    dialogueTimeTextFieldList.insert(insertIndex, [
      TextEditingController(text: newDialogue.startTimeStr),
      TextEditingController(text: newDialogue.endTimeStr),
    ]);

    for (var i = 0; i < dialogueList.length; i++) {
      dialogueList[i].index = i;
    }
    updateDialogue(insertIndex, notify: false);
    markUnsaved();
    update();
    updateSentenceAudio();
  }

  void deleteDialogueModel(int dialogueIndex) async {
    if (audioPlayer?.state == PlayerState.playing) {
      await audioPlayer?.pause();
      update();
    }

    dialogueList.removeAt(dialogueIndex);
    kContentTextFieldList.removeAt(dialogueIndex);
    kContentFocusNodeList.removeAt(dialogueIndex);
    zhCaptionsTextFieldList.removeAt(dialogueIndex);
    dialogueTimeTextFieldList.removeAt(dialogueIndex);
    if (editDialogueIndex == dialogueIndex) editDialogueIndex = null;
    if (showCaptionDialogueIndex == dialogueIndex) showCaptionDialogueIndex = null;

    for (var i = 0; i < dialogueList.length; i++) {
      dialogueList[i].index = i;
    }
    markUnsaved();
    update();
  }

  List<String> getAvailableSplitPunctuation(int dialogueIndex) {
    if (dialogueIndex < 0 || dialogueIndex >= dialogueList.length) return const [];
    final text = dialogueList[dialogueIndex].text ?? '';
    const candidates = ['，', '。', ',', '.', '！', '？', '!', '?', '；', '：', ';', ':', '…'];
    final res = <String>[];
    for (final p in candidates) {
      if (text.contains(p)) res.add(p);
    }
    return res;
  }

  List<DialogueModel> previewSplitDialogueModel(int dialogueIndex, List<String> selectedPunctuation) {
    if (dialogueIndex < 0 || dialogueIndex >= dialogueList.length) return const [];
    if (selectedPunctuation.isEmpty) return [dialogueList[dialogueIndex]];
    final selected = selectedPunctuation.toSet();
    final origin = dialogueList[dialogueIndex];
    return _splitDialogueByPunctuation(origin, selected);
  }

  Future<void> splitDialogueModelByPunctuation(int dialogueIndex, List<String> selectedPunctuation) async {
    if (dialogueIndex < 0 || dialogueIndex >= dialogueList.length) return;
    if (selectedPunctuation.isEmpty) return;

    if (audioPlayer?.state == PlayerState.playing) {
      await audioPlayer?.pause();
      update();
    }

    final selected = selectedPunctuation.toSet();
    final origin = dialogueList[dialogueIndex];
    final splitList = _splitDialogueByPunctuation(origin, selected);
    if (splitList.length <= 1) {
      ToastUtils.showManageToast(text: '该句子中没有可用的拆分点');
      return;
    }

    dialogueList.removeAt(dialogueIndex);
    kContentTextFieldList.removeAt(dialogueIndex);
    kContentFocusNodeList.removeAt(dialogueIndex);
    zhCaptionsTextFieldList.removeAt(dialogueIndex);
    dialogueTimeTextFieldList.removeAt(dialogueIndex);

    for (var i = 0; i < splitList.length; i++) {
      final d = splitList[i];
      dialogueList.insert(dialogueIndex + i, d);
      kContentTextFieldList.insert(dialogueIndex + i, []);
      kContentFocusNodeList.insert(dialogueIndex + i, []);
      for (var j = 0; j < (d.kTagList?.length ?? 0); j++) {
        kContentTextFieldList[dialogueIndex + i].add(TextEditingController(text: d.kTagList![j].text ?? ''));
        kContentFocusNodeList[dialogueIndex + i].add(FocusNode());
      }
      zhCaptionsTextFieldList.insert(dialogueIndex + i, TextEditingController(text: splitList[i].zhDialogueStr));
      dialogueTimeTextFieldList.insert(dialogueIndex + i, [
        TextEditingController(text: splitList[i].startTimeStr),
        TextEditingController(text: splitList[i].endTimeStr),
      ]);
    }

    for (var i = 0; i < dialogueList.length; i++) {
      dialogueList[i].index = i;
    }
    markUnsaved();
    update();
    updateSentenceAudio();
  }

  List<DialogueModel> _splitDialogueByPunctuation(DialogueModel dialogueModel, Set<String> selected) {
    final kTags = dialogueModel.kTagList;
    if (kTags == null || kTags.isEmpty) return [dialogueModel];

    final segments = <List<KTagModel>>[[]];
    for (var i = 0; i < kTags.length; i++) {
      final k = kTags[i];
      segments.last.add(k);
      final t = (k.text ?? '').trimRight();
      final bool hit = selected.any((p) => t.endsWith(p));
      if (hit && i != kTags.length - 1) segments.add([]);
    }
    final valid = segments.where((s) => s.isNotEmpty).toList();
    if (valid.length <= 1) return [dialogueModel];

    final List<DialogueModel> res = [];
    for (var i = 0; i < valid.length; i++) {
      final seg = valid[i];
      final d = DialogueModel();
      d.zhDialogueStr = null;
      d.layerIndex = dialogueModel.layerIndex;
      d.prefixStr = dialogueModel.prefixStr;
      d.index = (dialogueModel.index ?? 0) + i;
      d.startTime = seg.first.startTime;
      d.endTime = i == valid.length - 1
          ? dialogueModel.endTime
          : (seg.last.startTime ?? 0) + (seg.last.duration ?? 0);
      d.kTagList = seg;
      d.kTagText = seg.map((e) => e.kTagText).join('');
      d.text = seg.map((e) => e.text).join(' ');
      res.add(d);
    }
    return res;
  }

  void splitDialogueModel(int dialogueIndex) async {
    if (audioPlayer?.state == PlayerState.playing) {
      await audioPlayer?.pause();
      update();
    }

    DialogueModel dialogueModel = dialogueList[dialogueIndex];
    CutDialogueModelResult cutDialogueModelResult = KaraokeSubtitlesUtils.sentenceToDialogueModels(dialogueModel);
    if (!cutDialogueModelResult.isSuccess) {
      ToastUtils.showManageToast(text: cutDialogueModelResult.message ?? '');
      return;
    }

    List<DialogueModel> dialogueModelList = cutDialogueModelResult.result!;
    dialogueList.removeAt(dialogueIndex);
    kContentTextFieldList.removeAt(dialogueIndex);
    kContentFocusNodeList.removeAt(dialogueIndex);
    zhCaptionsTextFieldList.removeAt(dialogueIndex);
    dialogueTimeTextFieldList.removeAt(dialogueIndex);

    for (var i = 0; i < dialogueModelList.length; i++) {
      dialogueList.insert(dialogueIndex + i, dialogueModelList[i]);
      kContentTextFieldList.insert(dialogueIndex + i, []);
      kContentFocusNodeList.insert(dialogueIndex + i, []);

      for (var j = 0; j < dialogueModelList[i].kTagList!.length; j++) {
        kContentTextFieldList[dialogueIndex + i].add(TextEditingController(text: dialogueModelList[i].kTagList![j].text!));
        kContentFocusNodeList[dialogueIndex + i].add(FocusNode());
      }

      zhCaptionsTextFieldList.insert(dialogueIndex + i, TextEditingController(text: dialogueModelList[i].zhDialogueStr));
      dialogueTimeTextFieldList.insert(dialogueIndex + i, [
        TextEditingController(text: dialogueModelList[i].startTimeStr),
        TextEditingController(text: dialogueModelList[i].endTimeStr),
      ]);
    }

    for (var i = 0; i < dialogueList.length; i++) {
      dialogueList[i].index = i;
    }
    markUnsaved();
    update();
  }

  void checkSentenceError() async {
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "您确定要进行句子错误校验操作？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) return;

    for (var i = 0; i < dialogueList.length; i++) {
      DialogueModel d1 = dialogueList[i];
      if (d1.startTime! > totalDurationTime) d1.startTime = totalDurationTime;
      if (d1.endTime! > totalDurationTime) d1.endTime = totalDurationTime;
      if (d1.startTime! > d1.endTime!) d1.endTime = d1.startTime!;

      if (i < dialogueList.length - 1) {
        DialogueModel d2 = dialogueList[i + 1];
        if (d1.endTime! > d2.startTime!) d2.startTime = d1.endTime;
        if (d2.startTime! > d2.endTime!) d2.endTime = d2.startTime!;
      }
    }
    update();
  }

  void updateDialogueStartTime(int dialogueIndex, String startTimeStr) {
    int startTime = KaraokeSubtitlesUtils.parseTimeToDuration(startTimeStr);

    bool isOK = true;
    if (startTime < 0) {
      ToastUtils.showManageToast(text: '开始时间不能小于0');
      isOK = false;
    }
    if (startTime > totalDurationTime) {
      ToastUtils.showManageToast(text: '开始时间不能大于总时长');
      isOK = false;
    }
    if (dialogueIndex > 0) {
      int endTimePre = dialogueList[dialogueIndex - 1].endTime!;
      if (startTime < endTimePre) {
        ToastUtils.showManageToast(text: '开始时间不能小于上一句的结束时间');
        isOK = false;
      }
    }
    if (dialogueIndex < dialogueList.length - 1) {
      int startTimeSuf = dialogueList[dialogueIndex + 1].startTime!;
      if (startTime > startTimeSuf) {
        ToastUtils.showManageToast(text: '开始时间不能大于下一句的开始时间');
        isOK = false;
      }
    }

    if (!isOK) {
      dialogueTimeTextFieldList[dialogueIndex].first.text = dialogueList[dialogueIndex].startTimeStr;
      update();
    } else {
      dialogueList[dialogueIndex].startTime = startTime;
      update();
      markUnsaved();
    }
  }

  void updateDialogueEndTime(int dialogueIndex, String endTimeStr) {
    int startTime = dialogueList[dialogueIndex].startTime!;
    int endTime = KaraokeSubtitlesUtils.parseTimeToDuration(endTimeStr);

    bool isOK = true;
    if (endTime < 0) {
      ToastUtils.showManageToast(text: '结束时间不能小于0');
      isOK = false;
    }
    if (endTime > totalDurationTime) {
      ToastUtils.showManageToast(text: '结束时间不能大于总时长');
      isOK = false;
    }
    if (endTime < startTime) {
      ToastUtils.showManageToast(text: '结束时间不能小于开始时间');
      isOK = false;
    }
    if (dialogueIndex > 0) {
      int endTimePre = dialogueList[dialogueIndex - 1].endTime!;
      if (endTime < endTimePre) {
        ToastUtils.showManageToast(text: '结束时间不能小于上一句的结束时间');
        isOK = false;
      }
    }
    if (dialogueIndex < dialogueList.length - 1) {
      int startTimeSuf = dialogueList[dialogueIndex + 1].startTime!;
      if (endTime > startTimeSuf) {
        ToastUtils.showManageToast(text: '结束时间不能大于下一句的开始时间');
        isOK = false;
      }
    }

    if (!isOK) {
      dialogueTimeTextFieldList[dialogueIndex].last.text = dialogueList[dialogueIndex].endTimeStr;
      update();
    } else {
      dialogueList[dialogueIndex].endTime = endTime;
      update();
      markUnsaved();
    }
  }
}
