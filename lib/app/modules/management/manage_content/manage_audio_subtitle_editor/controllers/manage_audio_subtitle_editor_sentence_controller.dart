part of 'manage_audio_subtitle_editor_controller.dart';

extension AudioEditorSentenceMethods on ManageAudioSubtitleEditorController {
  int? findDialogueIndexByTime(int timeMs) {
    for (var i = 0; i < dialogueList.length; i++) {
      final d = dialogueList[i];
      if (d.startTime == null || d.endTime == null) continue;
      if (timeMs >= d.startTime! && timeMs <= d.endTime!) return i;
    }
    return null;
  }

  int? findKTagIndexByTime(int dialogueIndex, int timeMs) {
    if (dialogueIndex < 0 || dialogueIndex >= dialogueList.length) return null;
    final d = dialogueList[dialogueIndex];
    final list = d.kTagList;
    if (list == null || list.isEmpty) return null;

    for (int i = 0; i < list.length; i++) {
      final k = list[i];
      final start = k.startTime ?? 0;
      final int end;
      if (i + 1 < list.length) {
        end = list[i + 1].startTime ?? (start + (k.duration ?? 0));
      } else {
        end = d.endTime ?? (start + (k.duration ?? 0));
      }
      if (timeMs >= start && timeMs < end) return i;
    }

    final lastStart = list.last.startTime ?? 0;
    if (timeMs >= lastStart) return list.length - 1;
    return null;
  }

  Future<void> focusOnDialogue(int index) async {
    if (index < 0 || index >= dialogueList.length) return;
    final dialogue = dialogueList[index];
    final start = dialogue.startTime ?? 0;
    final end = dialogue.endTime;
    final int durationMs = (end != null && end > start) ? (end - start) : 0;

    setActiveDialogueIndex(index);
    await seekToTime(start, play: !isPlaying, scrollWaveform: false);
    // Sentences >= 1 minute: align start; < 1 minute: center
    if (durationMs >= 60000) {
      await scrollWaveformToTime(start, center: false);
    } else {
      final int centerTimeMs = (end != null && end > start) ? (start + ((end - start) ~/ 2)) : start;
      await scrollWaveformToTime(centerTimeMs, center: true);
    }
    await scrollToDialogueCell(index);
    update();
  }

  void setActiveDialogueIndex(int index) {
    if (index < 0 || index >= dialogueList.length) return;
    activeDialogueIndex = index;
    update();
  }

  void toggleMergeMode() {
    isMergeMode = !isMergeMode;
    mergeSelectedIndices.clear();
    update();
  }

  void toggleMergeSelect(int index) {
    if (!isMergeMode) return;
    if (index < 0 || index >= dialogueList.length) return;
    if (mergeSelectedIndices.contains(index)) {
      mergeSelectedIndices.remove(index);
    } else {
      mergeSelectedIndices.add(index);
    }
    update();
  }

  bool get canMergeSelected {
    if (mergeSelectedIndices.length < 2) return false;
    final sorted = mergeSelectedIndices.toList()..sort();
    for (var i = 1; i < sorted.length; i++) {
      if (sorted[i] != sorted[i - 1] + 1) return false;
    }
    return true;
  }

  Future<void> mergeSelectedDialogues() async {
    if (!canMergeSelected) {
      ToastUtils.showManageToast(text: '仅支持选择相邻句子合并');
      return;
    }

    if (audioPlayer?.state == PlayerState.playing) {
      await audioPlayer?.pause();
      update();
    }

    final indices = mergeSelectedIndices.toList()..sort();
    DialogueModel merged = dialogueList[indices.first];
    for (var i = 1; i < indices.length; i++) {
      merged = KaraokeSubtitlesUtils.mergeDialogueModel(merged, dialogueList[indices[i]]);
    }

    for (var i = indices.length - 1; i >= 0; i--) {
      final idx = indices[i];
      dialogueList.removeAt(idx);
      kContentTextFieldList.removeAt(idx);
      kContentFocusNodeList.removeAt(idx);
      zhCaptionsTextFieldList.removeAt(idx);
      dialogueTimeTextFieldList.removeAt(idx);
    }

    final insertIndex = indices.first;
    merged.index = insertIndex;
    dialogueList.insert(insertIndex, merged);

    kContentTextFieldList.insert(insertIndex, []);
    kContentFocusNodeList.insert(insertIndex, []);
    for (var i = 0; i < (merged.kTagList?.length ?? 0); i++) {
      kContentTextFieldList[insertIndex].add(TextEditingController(text: merged.kTagList![i].text ?? ''));
      kContentFocusNodeList[insertIndex].add(FocusNode());
    }

    zhCaptionsTextFieldList.insert(insertIndex, TextEditingController(text: merged.zhDialogueStr));

    final timeControllers = <TextEditingController>[];
    timeControllers.add(TextEditingController(text: merged.startTimeStr));
    timeControllers.add(TextEditingController(text: merged.endTimeStr));
    dialogueTimeTextFieldList.insert(insertIndex, timeControllers);

    for (var i = 0; i < dialogueList.length; i++) {
      dialogueList[i].index = i;
    }

    isMergeMode = false;
    mergeSelectedIndices.clear();
    activeDialogueIndex = insertIndex;
    markUnsaved();
    update();
    updateSentenceAudio();
  }

  void mergeDialogueModel(DialogueModel oldDialogueModel, DialogueModel newDialogueModel) async {
    if ((oldDialogueModel.index! - newDialogueModel.index!).abs() != 1) {
      ToastUtils.showManageToast(text: '仅支持连续2个进行合并!');
      return;
    }

    if (audioPlayer?.state == PlayerState.playing) {
      await audioPlayer?.pause();
      update();
    }

    DialogueModel dialogueModel = KaraokeSubtitlesUtils.mergeDialogueModel(oldDialogueModel, newDialogueModel);

    dialogueList.remove(oldDialogueModel);
    dialogueList.remove(newDialogueModel);
    if (oldDialogueModel.index! < newDialogueModel.index!) {
      kContentTextFieldList.removeAt(oldDialogueModel.index!);
      kContentTextFieldList.removeAt(newDialogueModel.index! - 1);
      kContentFocusNodeList.removeAt(oldDialogueModel.index!);
      kContentFocusNodeList.removeAt(newDialogueModel.index! - 1);
      zhCaptionsTextFieldList.removeAt(oldDialogueModel.index!);
      zhCaptionsTextFieldList.removeAt(newDialogueModel.index! - 1);
      dialogueTimeTextFieldList.removeAt(oldDialogueModel.index!);
      dialogueTimeTextFieldList.removeAt(newDialogueModel.index! - 1);
    } else {
      kContentTextFieldList.removeAt(oldDialogueModel.index!);
      kContentTextFieldList.removeAt(newDialogueModel.index!);
      kContentFocusNodeList.removeAt(oldDialogueModel.index!);
      kContentFocusNodeList.removeAt(newDialogueModel.index!);
      zhCaptionsTextFieldList.removeAt(oldDialogueModel.index!);
      zhCaptionsTextFieldList.removeAt(newDialogueModel.index!);
      dialogueTimeTextFieldList.removeAt(oldDialogueModel.index!);
      dialogueTimeTextFieldList.removeAt(newDialogueModel.index!);
    }

    dialogueList.insert(dialogueModel.index!, dialogueModel);
    kContentTextFieldList.insert(dialogueModel.index!, []);
    kContentFocusNodeList.insert(dialogueModel.index!, []);
    for (var i = 0; i < dialogueModel.kTagList!.length; i++) {
      kContentTextFieldList[dialogueModel.index!].add(TextEditingController(text: dialogueModel.kTagList![i].text!));
      kContentFocusNodeList[dialogueModel.index!].add(FocusNode());
    }

    final timeControllers = <TextEditingController>[];
    timeControllers.add(TextEditingController(text: dialogueModel.startTimeStr));
    timeControllers.add(TextEditingController(text: dialogueModel.endTimeStr));
    dialogueTimeTextFieldList.insert(dialogueModel.index!, timeControllers);
    zhCaptionsTextFieldList.insert(dialogueModel.index!, TextEditingController(text: dialogueModel.zhDialogueStr));

    for (var i = 0; i < dialogueList.length; i++) {
      dialogueList[i].index = i;
    }
    markUnsaved();
    update();
    updateSentenceAudio();
  }

  void playDialogueModel(int dialogueIndex) {
    playDialogueModelFromTime(dialogueIndex, dialogueList[dialogueIndex].startTime!);
  }

  Future<void> playDialogueModelFromTime(int dialogueIndex, int fromTimeMs) async {
    DialogueModel dialogueModel = dialogueList[dialogueIndex];
    final int start = dialogueModel.startTime!;
    final int end = dialogueModel.endTime!;
    final int playFrom = fromTimeMs.clamp(start, end);
    currentTime = playFrom;
    _sentenceSegmentEndTimeMs = end;

    _sentenceSegmentTimer?.cancel();
    _sentenceSegmentTimer = null;
    final int generation = ++_sentencePlayGeneration;

    var mSpeed = Get.find<ConfigController>().userSetting.value.expandAudioSpeed;
    final int timerMs = ((end - playFrom) / mSpeed).ceil();

    await audioPlayer?.setPlaybackRate(mSpeed);
    await audioPlayer?.seek(Duration(milliseconds: playFrom));
    await audioPlayer?.resume();

    _sentenceSegmentTimer = Timer(Duration(milliseconds: timerMs), () async {
      _sentenceSegmentTimer = null;
      if (_sentencePlayGeneration == generation) {
        final bool shouldLoopInSentenceMode = !isWordMode;
        if (shouldLoopInSentenceMode) {
          playDialogueModelFromTime(dialogueIndex, start);
          return;
        }

        if (isWordMode && editDialogueIndex == dialogueIndex) {
          currentTime = start;
          _sentenceSegmentEndTimeMs = null;
          try {
            await audioPlayer?.seek(Duration(milliseconds: start));
            await audioPlayer?.pause();
          } catch (_) {}
          update();
          return;
        }

        currentTime = end;
        _sentenceSegmentEndTimeMs = null;
        await audioPlayer?.pause();
        update();
      }
    });
  }

  void editDialogueModel(int dialogueIndex) {
    DialogueModel dialogueModel = dialogueList[dialogueIndex];
    if (!dialogueModel.isEdit) {
      startEditingDialogue(dialogueIndex);
      return;
    }
    saveEditingDialogue(dialogueIndex);
  }

  void startEditingDialogue(int dialogueIndex) {
    if (dialogueIndex < 0 || dialogueIndex >= dialogueList.length) return;

    _editingBackupDialogue = _cloneDialogue(dialogueList[dialogueIndex]);
    _editingBackupDialogueIndex = dialogueIndex;
    _unsavedBeforeEditing = hasUnsavedChanges;

    for (var model in dialogueList) {
      model.isEdit = false;
    }
    dialogueList[dialogueIndex].isEdit = true;
    editDialogueIndex = dialogueIndex;
    activeDialogueIndex = dialogueIndex;
    _resetWaveformView();

    // 进入单词模式时自动播放当前句子
    playDialogueModel(dialogueIndex);
    
    update();
  }

  Future<void> saveEditingDialogue(int dialogueIndex) async {
    if (dialogueIndex < 0 || dialogueIndex >= dialogueList.length) return;
    final bool wasPlaying = audioPlayer?.state == PlayerState.playing;
    await _exitWordModePlayback(keepPlaying: wasPlaying);
    
    dialogueList[dialogueIndex].isEdit = false;
    editDialogueIndex = null;
    _editingBackupDialogue = null;
    _editingBackupDialogueIndex = null;
    _unsavedBeforeEditing = false;
    _resetWaveformView();
    markUnsaved();
    updateSentenceAudio();
  }

  Future<void> cancelEditingDialogue(int dialogueIndex) async {
    if (dialogueIndex < 0 || dialogueIndex >= dialogueList.length) return;
    final bool wasPlaying = audioPlayer?.state == PlayerState.playing;
    await _exitWordModePlayback(keepPlaying: wasPlaying);
    
    if (_editingBackupDialogue != null && _editingBackupDialogueIndex == dialogueIndex) {
      _restoreDialogueFromBackup(dialogueIndex, _editingBackupDialogue!);
      hasUnsavedChanges = _unsavedBeforeEditing;
    }

    dialogueList[dialogueIndex].isEdit = false;
    editDialogueIndex = null;
    _editingBackupDialogue = null;
    _editingBackupDialogueIndex = null;
    _unsavedBeforeEditing = false;
    _resetWaveformView();
    update();
  }

  Future<void> _exitWordModePlayback({required bool keepPlaying}) async {
    _sentenceSegmentTimer?.cancel();
    _sentenceSegmentTimer = null;
    _sentenceSegmentEndTimeMs = null;
    _sentencePlayGeneration++;

    _isAutoPreviewingAfterDrag = false;
    _autoPreviewFinishTimer?.cancel();

    if (!keepPlaying) {
      try {
        await audioPlayer?.pause();
      } catch (_) {}
      return;
    }

    try {
      await audioPlayer?.seek(Duration(milliseconds: currentTime));
      await audioPlayer?.resume();
    } catch (_) {}

    final idx = findDialogueIndexByTime(currentTime);
    if (idx != null) {
      activeDialogueIndex = idx;
    }
  }

  DialogueModel _cloneDialogue(DialogueModel src) {
    final model = DialogueModel(
      index: src.index,
      startTime: src.startTime,
      endTime: src.endTime,
      kTagText: src.kTagText,
      text: src.text,
      layerIndex: src.layerIndex,
      zhDialogueStr: src.zhDialogueStr,
      isEdit: false,
      kTagList: (src.kTagList ?? [])
          .map((k) => KTagModel(
                startTime: k.startTime,
                duration: k.duration,
                kTagText: k.kTagText,
                text: k.text,
                isEdit: false,
              ))
          .toList(),
    );
    model.prefixStr = src.prefixStr;
    return model;
  }

  void _restoreDialogueFromBackup(int dialogueIndex, DialogueModel backup) {
    if (dialogueIndex < 0 || dialogueIndex >= dialogueList.length) return;

    dialogueList[dialogueIndex] = _cloneDialogue(backup);

    for (final c in kContentTextFieldList[dialogueIndex]) c.dispose();
    for (final f in kContentFocusNodeList[dialogueIndex]) f.dispose();
    kContentTextFieldList[dialogueIndex] = [];
    kContentFocusNodeList[dialogueIndex] = [];

    final list = dialogueList[dialogueIndex].kTagList ?? [];
    for (final k in list) {
      kContentTextFieldList[dialogueIndex].add(TextEditingController(text: k.text ?? ''));
      kContentFocusNodeList[dialogueIndex].add(FocusNode());
    }

    updateDialogue(dialogueIndex, notify: false);
  }

  Future<void> confirmSaveEditingDialogue(int dialogueIndex) async {
    // final ask = await AskDialog.showUserAsk(
    //   context: Get.context!,
    //   content: '是否保存当前句子的修改？3',
    //   cancel: 'Cancel',
    //   define: 'OK',
    //   showCancel: true,
    // );
    // if (ask != true) return;
    ToastUtils.showManageToast(text: '保存成功');
    saveEditingDialogue(dialogueIndex);
    update();
  }

  Future<void> toPrevDialogue() async {
    if (dialogueList.isEmpty) return;
    final current = isWordMode ? editDialogueIndex : activeDialogueIndex;
    if (current == null) return;
    final target = current - 1;
    if (target < 0) {
      ToastUtils.showManageToast(text: '没有上一句了');
      return;
    }

    if (isWordMode) {
      await saveEditingDialogue(current);
      startEditingDialogue(target);
      setActiveDialogueIndex(target);
      return;
    }

    setActiveDialogueIndex(target);
    playDialogueModel(target);
  }

  Future<void> toNextDialogue() async {
    if (dialogueList.isEmpty) return;
    final current = isWordMode ? editDialogueIndex : activeDialogueIndex;
    if (current == null) return;
    final target = current + 1;
    if (target >= dialogueList.length) {
      ToastUtils.showManageToast(text: '没有下一句了');
      return;
    }

    if (isWordMode) {
      await saveEditingDialogue(current);
      startEditingDialogue(target);
      setActiveDialogueIndex(target);
      return;
    }

    setActiveDialogueIndex(target);
    playDialogueModel(target);
  }
}
