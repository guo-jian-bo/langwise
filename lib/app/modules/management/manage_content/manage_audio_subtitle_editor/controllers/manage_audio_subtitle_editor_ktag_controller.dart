part of 'manage_audio_subtitle_editor_controller.dart';

extension AudioEditorKTagMethods on ManageAudioSubtitleEditorController {
  void beginEditingKTag(int dialogueIndex, int kTagIndex) {
    if (dialogueIndex < 0 || dialogueIndex >= dialogueList.length) return;
    final list = dialogueList[dialogueIndex].kTagList;
    if (list == null || kTagIndex < 0 || kTagIndex >= list.length) return;
    setEditingKTag(dialogueIndex, kTagIndex);
    update();
  }

  void focusEditingKTag(int dialogueIndex, int kTagIndex) {
    if (dialogueIndex < 0 || dialogueIndex >= dialogueList.length) return;
    final list = dialogueList[dialogueIndex].kTagList;
    if (list == null || kTagIndex < 0 || kTagIndex >= list.length) return;
    currentTime = list[kTagIndex].startTime ?? currentTime;
    setEditingKTag(dialogueIndex, kTagIndex);
    update();
  }

  void addKTagModel(int dialogueIndex) {
    if (dialogueIndex < 0 || dialogueIndex >= dialogueList.length) return;
    final dialogueModel = dialogueList[dialogueIndex];
    final list = dialogueModel.kTagList;
    if (list == null) return;

    if (isWordMode && editDialogueIndex == dialogueIndex) {
      final currentK = findKTagIndexByTime(dialogueIndex, currentTime) ?? (list.isEmpty ? 0 : list.length - 1);
      _insertKTagAfter(dialogueIndex, currentK, defaultText: 'value', defaultDurationMs: 50);
      return;
    }

    _insertKTagAfter(dialogueIndex, list.isEmpty ? -1 : list.length - 1, defaultText: 'value', defaultDurationMs: 50);
  }

  void setEditingKTag(int dialogueIndex, int kTagIndex, {bool requestFocus = true}) {
    if (dialogueIndex < 0 || dialogueIndex >= dialogueList.length) return;
    final list = dialogueList[dialogueIndex].kTagList;
    if (list == null || kTagIndex < 0 || kTagIndex >= list.length) return;

    for (final k in list) {
      k.isEdit = false;
    }
    list[kTagIndex].isEdit = true;
    update();

    if (requestFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (dialogueIndex >= 0 && dialogueIndex < kContentFocusNodeList.length) {
          final focusList = kContentFocusNodeList[dialogueIndex];
          if (kTagIndex >= 0 && kTagIndex < focusList.length) {
            focusList[kTagIndex].requestFocus();
          }
        }
      });
    }
  }

  void endEditingKTagsInDialogue(int dialogueIndex) {
    if (dialogueIndex < 0 || dialogueIndex >= dialogueList.length) return;
    final list = dialogueList[dialogueIndex].kTagList;
    if (list == null) return;

    bool changed = false;
    for (final k in list) {
      if (k.isEdit) {
        k.isEdit = false;
        changed = true;
      }
    }
    if (changed) update();
  }

  void endEditingCurrentKTag() {
    final idx = editDialogueIndex;
    if (idx == null) return;
    endEditingKTagsInDialogue(idx);
  }

  void _insertKTagAfter(int dialogueIndex, int afterIndex, {required String defaultText, required int defaultDurationMs}) {
    final dialogueModel = dialogueList[dialogueIndex];
    final list = dialogueModel.kTagList;
    if (list == null) return;

    final insertIndex = (afterIndex + 1).clamp(0, list.length);
    final int dur = defaultDurationMs.clamp(1, 60000);

    final k = KTagModel(
      startTime: 0,
      duration: dur,
      text: defaultText,
      kTagText: '{\\k${(dur / 10).toInt()}}$defaultText',
      isEdit: false,
    );

    list.insert(insertIndex, k);
    kContentTextFieldList[dialogueIndex].insert(insertIndex, TextEditingController(text: defaultText));
    kContentFocusNodeList[dialogueIndex].insert(insertIndex, FocusNode());

    if (insertIndex < list.length - 1) {
      final next = list[insertIndex + 1];
      final nextDur = next.duration ?? 0;
      if (nextDur > dur + 1) next.duration = nextDur - dur;
    }

    _normalizeKTagDurationsToDialogueSpan(dialogueIndex);
    updateDialogue(dialogueIndex, notify: false);
    currentTime = dialogueModel.kTagList![insertIndex].startTime ?? currentTime;
    markUnsaved(notify: false);

    setEditingKTag(dialogueIndex, insertIndex);
    update();
  }

  void _normalizeKTagDurationsToDialogueSpan(int dialogueIndex) {
    final dialogue = dialogueList[dialogueIndex];
    final list = dialogue.kTagList;
    if (list == null || list.isEmpty) return;
    final start = dialogue.startTime ?? 0;
    final end = dialogue.endTime ?? start;
    final span = (end - start).clamp(1, 1 << 30);

    for (final k in list) {
      k.duration = (k.duration ?? 1).clamp(1, span);
    }

    int total = 0;
    for (final k in list) {
      total += (k.duration ?? 0);
    }
    if (total == span) return;

    final last = list.last;
    final lastDur = (last.duration ?? 1);
    final fixed = (lastDur + (span - total)).clamp(1, span);
    last.duration = fixed;
    if (last.text != null) {
      last.kTagText = '{\\k${(fixed / 10).toInt()}}${last.text}';
    }
  }

  void swapKTagModel(int dialogueIndex, KTagModel kTagModel, int index) {
    DialogueModel dialogueModel = dialogueList[dialogueIndex];

    final fromIndex = dialogueModel.kTagList!.indexOf(kTagModel);
    if (fromIndex == -1 || fromIndex == index) return;

    final movedKTag = dialogueModel.kTagList!.removeAt(fromIndex);
    int targetIndex = fromIndex < index ? index - 1 : index;
    dialogueModel.kTagList!.insert(targetIndex, movedKTag);

    final textFieldList = kContentTextFieldList[dialogueIndex];
    final focusList = kContentFocusNodeList[dialogueIndex];

    final movedController = textFieldList.removeAt(fromIndex);
    final movedFocusNode = focusList.removeAt(fromIndex);
    int targetTextIndex = fromIndex < index ? index - 1 : index;
    textFieldList.insert(targetTextIndex, movedController);
    focusList.insert(targetTextIndex, movedFocusNode);

    updateDialogue(dialogueIndex);
    markUnsaved();
  }

  void playKTagModel(int dialogueIndex, int kTagIndex) async {
    DialogueModel dialogueModel = dialogueList[dialogueIndex];
    KTagModel kTagModel = dialogueModel.kTagList![kTagIndex];
    _manualPauseAnchorTimeMs = null;
    currentTime = kTagModel.startTime!;
    update();

    final speed = Get.find<ConfigController>().userSetting.value.expandAudioSpeed;
    final startMs = kTagModel.startTime ?? 0;
    final endMs = (startMs + (kTagModel.duration ?? 0)).clamp(0, totalDurationTime);
    final holdMs = (endMs > startMs + 10) ? (endMs - 10) : startMs;
    final endPlayMs = holdMs.clamp(0, totalDurationTime);
    _isAutoPreviewingAfterDrag = true;
    _autoPreviewStayTimeMs = endPlayMs;
    _autoPreviewFinishTimer?.cancel();
    final segMs = (endPlayMs - startMs).clamp(0, 1000000);
    final previewMs = ((segMs / (speed <= 0 ? 1.0 : speed))).ceil();
    _autoPreviewFinishTimer = Timer(Duration(milliseconds: previewMs + 250), () {
      if (_isAutoPreviewingAfterDrag) {
        _isAutoPreviewingAfterDrag = false;
        currentTime = _autoPreviewStayTimeMs;
        update();
      }
    });
    audioPlayer?.playSegment(
      source: UrlSource(audioUrl),
      playbackRate: speed,
      startTime: Duration(milliseconds: startMs),
      endTime: Duration(milliseconds: endPlayMs),
    );
  }

  void deleteKTagModel(int dialogueIndex, int kTagIndex) {
    DialogueModel dialogueModel = dialogueList[dialogueIndex];
    dialogueModel.kTagList!.removeAt(kTagIndex);
    kContentTextFieldList[dialogueIndex].removeAt(kTagIndex);
    kContentFocusNodeList[dialogueIndex].removeAt(kTagIndex);
    if (showCaptionDialogueIndex == dialogueIndex && showCaptionKTagIndex == kTagIndex) {
      showCaptionDialogueIndex = null;
    }
    updateDialogue(dialogueIndex);
    markUnsaved();
  }

  void updateDialogue(int dialogueIndex, {bool notify = true}) {
    DialogueModel dialogueModel = dialogueList[dialogueIndex];
    String kTagText = '';
    String text = '';
    for (int i = 0; i < dialogueModel.kTagList!.length; i++) {
      if (i == 0) {
        dialogueModel.kTagList![i].startTime = dialogueModel.startTime;
        dialogueModel.kTagList![i].kTagText =
            '{\\k${((dialogueModel.kTagList![i].duration ?? 0) / 10).toInt()}}${dialogueModel.kTagList![i].text ?? ''}';
        kTagText = dialogueModel.kTagList![i].kTagText!;
        text = dialogueModel.kTagList![i].text ?? '';
      } else {
        dialogueModel.kTagList![i].startTime =
            dialogueModel.kTagList![i - 1].startTime! + dialogueModel.kTagList![i - 1].duration!;
        dialogueModel.kTagList![i].kTagText =
            '{\\k${((dialogueModel.kTagList![i].duration ?? 0) / 10).toInt()}}${dialogueModel.kTagList![i].text ?? ''}';
        kTagText = '$kTagText ${dialogueModel.kTagList![i].kTagText!}';
        text = '$text ${dialogueModel.kTagList![i].text ?? ''}';
      }
    }
    dialogueModel.kTagText = kTagText;
    dialogueModel.text = text;
    if (notify) update();
  }
}
