part of 'manage_audio_subtitle_editor_controller.dart';

extension AudioEditorWaveformMethods on ManageAudioSubtitleEditorController {
  void registerDialogueCellContext(int index, BuildContext context) {
    _dialogueCellContexts[index] = context;
  }

  Future<void> scrollToDialogueCell(int index, {double alignment = 0.5}) async {
    final context = _dialogueCellContexts[index];
    if (context == null) return;
    if (!context.mounted) return;
    await Scrollable.ensureVisible(
      context,
      alignment: alignment,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  void _scheduleAutoScrollToDialogue(int index) {
    if (_lastAutoScrollSentenceIndex == index) return;
    _autoScrollSentenceTimer?.cancel();
    _autoScrollSentenceTimer = Timer(const Duration(milliseconds: 200), () {
      _lastAutoScrollSentenceIndex = index;
      scrollToDialogueCell(index);
    });
  }

  void _scheduleAutoCenterWaveformToDialogue(int index) {
    if (_lastAutoCenterWaveformDialogueIndex == index) return;
    _autoCenterWaveformTimer?.cancel();
    _autoCenterWaveformTimer = Timer(const Duration(milliseconds: 200), () async {
      _lastAutoCenterWaveformDialogueIndex = index;
      if (isWordMode) return;
      if (isScrollbarDragging) return;
      if (index < 0 || index >= dialogueList.length) return;
      final d = dialogueList[index];
      final start = d.startTime ?? 0;
      final end = d.endTime;
      final int durationMs = (end != null && end > start) ? (end - start) : 0;
      // Sentences >= 1 minute: align start so S-marker/timeline stay visible
      if (durationMs >= 60000) {
        await scrollWaveformToTime(start, center: false);
        return;
      }
      // Sentences < 1 minute: center in viewport
      final int centerTimeMs = (end != null && end > start) ? (start + ((end - start) ~/ 2)) : start;
      await scrollWaveformToTime(centerTimeMs, center: true);
    });
  }

  void setScrollbarDragging(bool dragging) {
    if (isScrollbarDragging == dragging) return;
    isScrollbarDragging = dragging;
    if (!dragging) {
      _lastAutoCenterWaveformDialogueIndex = null;
    }
    _throttledUpdate();
  }

  void setHoverMarker(Map<String, dynamic>? marker) {
    if (marker == null && hoverMarker == null) return;
    if (marker != null && hoverMarker != null && marker.toString() == hoverMarker.toString()) return;
    hoverMarker = marker;
    _throttledUpdate();
  }

  void beginDragMarker(Map<String, dynamic>? marker) {
    dragMarker = marker;
    _throttledUpdate();
  }

  void endDragMarker() {
    if (dragMarker == null) return;
    dragMarker = null;
    _throttledUpdate();
  }

  Future<void> _resetWaveformView() async {
    zoomLevel = 1.0;
    if (scrollController.hasClients) {
      try {
        scrollController.jumpTo(0);
      } catch (_) {}
    }
  }

  void resetView() {
    zoomLevel = 1.0;
    if (scrollController.hasClients) {
      try {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      } catch (_) {}
    }
    update();
  }

  void setZoomLevel(double level) {
    zoomLevel = level.clamp(1.0, 10.0);
    update();
  }

  void _applyPendingZoomAnchorIfNeeded() {
    final anchorTime = _pendingZoomAnchorTimeMs;
    final anchorViewportDx = _pendingZoomAnchorViewportDx;
    if (anchorTime == null || anchorViewportDx == null) return;
    if (!scrollController.hasClients) return;
    if (displayDurationMs <= 0 || allWidth <= 0) return;

    final double ratio = ((anchorTime - displayStartMs) / displayDurationMs).clamp(0.0, 1.0);
    final double rawX = ratio * allWidth + 20.0;
    final double target = (rawX - anchorViewportDx).clamp(0.0, scrollController.position.maxScrollExtent);
    try {
      scrollController.jumpTo(target);
    } catch (_) {}

    _pendingZoomAnchorTimeMs = null;
    _pendingZoomAnchorViewportDx = null;
  }

  void zoomWithAnchor({required double delta, required int anchorTimeMs, required double anchorViewportDx}) {
    _pendingZoomAnchorTimeMs = anchorTimeMs;
    _pendingZoomAnchorViewportDx = anchorViewportDx;
    zoomLevel = (zoomLevel + delta).clamp(1.0, 10.0);
    update();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyPendingZoomAnchorIfNeeded();
    });
  }

  void zoomIn() => setZoomLevel(double.parse((zoomLevel + 0.5).toStringAsFixed(1)));
  void zoomOut() => setZoomLevel(double.parse((zoomLevel - 0.5).toStringAsFixed(1)));
  void zoomInSmall() => setZoomLevel(double.parse((zoomLevel + 0.2).toStringAsFixed(1)));
  void zoomOutSmall() => setZoomLevel(double.parse((zoomLevel - 0.2).toStringAsFixed(1)));

  void shrinkInterface() => zoomOut();
  void zoomInterface() => zoomIn();

  void onDialogueDrag(int index, bool isStart, double dx, double width) {
    double newPos = (dx / width).clamp(0.0, 1.0);
    double leftLimit = index == 0 && isStart
        ? 0.0
        : isStart
            ? dialogueList[index - 1].endTime! / totalDurationTime
            : dialogueList[index].startTime! / totalDurationTime;
    double rightLimit = index == dialogueList.length - 1 && !isStart
        ? 1.0
        : isStart
            ? dialogueList[index].endTime! / totalDurationTime
            : dialogueList[index + 1].startTime! / totalDurationTime;
    newPos = newPos.clamp(leftLimit, rightLimit);

    if (isStart) {
      int duration = (newPos * totalDurationTime).toInt() - dialogueList[index].startTime!;
      for (var kTag in dialogueList[index].kTagList!) {
        kTag.startTime = kTag.startTime! + duration;
      }
    }

    isStart
        ? dialogueList[index].startTime = (newPos * totalDurationTime).toInt()
        : dialogueList[index].endTime = (newPos * totalDurationTime).toInt();
    isStart
        ? dialogueTimeTextFieldList[index].first.text = dialogueList[index].startTimeStr
        : dialogueTimeTextFieldList[index].last.text = dialogueList[index].endTimeStr;
    markUnsaved(notify: false);
    _throttledUpdate();
  }

  void onDialogueDragEnd(int index, {required bool isStart}) {
    markUnsaved();
    _autoPreviewAfterSentenceDrag(index, isStart: isStart);
  }

  void onKTagDragEnd(int dialogueIndex, int kTagIndex) {
    markUnsaved();
    _autoPreviewAfterWordDrag(dialogueIndex, kTagIndex);
  }

  void onDragKTag(
    int dialogueIndex,
    int kTagIndex,
    double dx,
    double width, {
    bool isLast = false,
    int? displayStartMs,
    int? displayDurationMs,
  }) {
    final key = _kTagKey(dialogueIndex, kTagIndex, isLast: isLast);
    _kTagPointerMoved[key] = true;

    if (kTagIndex == 0 && dialogueList[dialogueIndex].kTagList!.length != 1) return;

    DialogueModel dialogueModel = dialogueList[dialogueIndex];
    KTagModel kTagModel = dialogueModel.kTagList![kTagIndex];

    double newPos = (dx / width).clamp(0.0, 1.0);
    final bool useSegment = displayStartMs != null && displayDurationMs != null && displayDurationMs > 0;
    int currentTime = useSegment
        ? (displayStartMs + (newPos * displayDurationMs).toInt())
        : (newPos * totalDurationTime).toInt();

    const int minGapMs = 10;
    final int absoluteRight = dialogueModel.endTime ?? totalDurationTime;

    if (isLast) {
      int leftLimit = kTagIndex == 0 ? dialogueModel.startTime! : dialogueModel.kTagList![kTagIndex].startTime! + minGapMs;
      int rightLimit = useSegment ? absoluteRight : totalDurationTime;
      final int n = dialogueModel.kTagList!.length;
      if (kTagIndex + 1 < n) {
        final int nextEnd = (kTagIndex + 2 < n)
            ? (dialogueModel.kTagList![kTagIndex + 2].startTime ?? absoluteRight)
            : absoluteRight;
        final int maxRightByNext = (nextEnd - minGapMs).clamp(0, rightLimit).toInt();
        rightLimit = rightLimit.clamp(0, maxRightByNext).toInt();
      }
      if (leftLimit > rightLimit) leftLimit = rightLimit;
      currentTime = currentTime.clamp(leftLimit, rightLimit);

      int duration = currentTime - kTagModel.startTime!;
      kTagModel.duration = duration;
      kTagModel.kTagText = '{\\k${(duration / 10).toInt()}}${kTagModel.text}';

      if (kTagIndex + 1 < n) {
        final KTagModel currentWordKTag = dialogueModel.kTagList![kTagIndex + 1];
        currentWordKTag.startTime = currentTime;
        final int nextEnd = (kTagIndex + 2 < n)
            ? (dialogueModel.kTagList![kTagIndex + 2].startTime ?? absoluteRight)
            : absoluteRight;
        final int currentWordDuration = (nextEnd - currentTime).clamp(0, absoluteRight).toInt();
        currentWordKTag.duration = currentWordDuration;
        currentWordKTag.kTagText =
            '{\\k${(currentWordDuration / 10).toInt()}}${currentWordKTag.text}';
      }

      updateDialogue(dialogueIndex);
      markUnsaved();

      this.currentTime = rightLimit;
      update();
      return;
    }

    int leftLimit = kTagIndex == 0 ? dialogueModel.startTime! : dialogueModel.kTagList![kTagIndex - 1].startTime! + minGapMs;
    int oldTime = kTagModel.startTime!;
    int desiredB = currentTime.clamp(leftLimit, absoluteRight);
    int delta = desiredB - oldTime;

    final int n = dialogueModel.kTagList!.length;
    final List<int> newTimes = List<int>.generate(n, (i) {
      if (i < kTagIndex) return dialogueModel.kTagList![i].startTime!;
      if (i == kTagIndex) return desiredB;
      return dialogueModel.kTagList![i].startTime! + delta;
    });

    newTimes[n - 1] = newTimes[n - 1].clamp(0, absoluteRight);
    for (int i = n - 2; i >= kTagIndex; i--) {
      int cap = newTimes[i + 1] - minGapMs;
      if (newTimes[i] > cap) newTimes[i] = cap;
    }
    if (newTimes[kTagIndex] < leftLimit) newTimes[kTagIndex] = leftLimit;

    for (int i = kTagIndex; i < n; i++) {
      dialogueModel.kTagList![i].startTime = newTimes[i];
    }

    if (kTagIndex > 0) {
      int duration = newTimes[kTagIndex] - dialogueModel.kTagList![kTagIndex - 1].startTime!;
      dialogueModel.kTagList![kTagIndex - 1].duration = duration;
      dialogueModel.kTagList![kTagIndex - 1].kTagText = '{\\k${(duration / 10).toInt()}}${dialogueModel.kTagList![kTagIndex - 1].text}';
    }

    for (int i = kTagIndex; i < n; i++) {
      int nextStart = (i + 1 < n) ? dialogueModel.kTagList![i + 1].startTime! : absoluteRight;
      int dur = nextStart - dialogueModel.kTagList![i].startTime!;
      dialogueModel.kTagList![i].duration = dur;
      dialogueModel.kTagList![i].kTagText = '{\\k${(dur / 10).toInt()}}${dialogueModel.kTagList![i].text}';
    }

    updateDialogue(dialogueIndex, notify: false);
    markUnsaved(notify: false);

    this.currentTime = newTimes[kTagIndex];
    _throttledUpdate();
  }

  String _kTagKey(int dialogueIndex, int kTagIndex, {required bool isLast}) =>
      '$dialogueIndex-$kTagIndex-${isLast ? 1 : 0}';

  void onKTagPointerDown(int dialogueIndex, int kTagIndex, double dx, {bool isLast = false}) {
    final key = _kTagKey(dialogueIndex, kTagIndex, isLast: isLast);
    _kTagPointerDownDx[key] = dx;
    _kTagPointerDownAtMs[key] = DateTime.now().millisecondsSinceEpoch;
    _kTagPointerMoved[key] = false;
    // 播放状态暂停
    if (audioPlayer?.state == PlayerState.playing) {
      audioPlayAndPause();
    }
  }

  bool isKTagTap(int dialogueIndex, int kTagIndex, double upDx, {bool isLast = false}) {
    final key = _kTagKey(dialogueIndex, kTagIndex, isLast: isLast);
    final downDx = _kTagPointerDownDx[key];
    final downAt = _kTagPointerDownAtMs[key];
    final moved = _kTagPointerMoved[key] ?? false;
    _kTagPointerDownDx.remove(key);
    _kTagPointerDownAtMs.remove(key);
    _kTagPointerMoved.remove(key);
    if (downDx == null || downAt == null || moved) return false;
    final dt = DateTime.now().millisecondsSinceEpoch - downAt;
    final dd = (upDx - downDx).abs();
    return dt < 220 && dd < 4;
  }

  Future<void> playFromKTagToNext(int dialogueIndex, int kTagIndex) async {
    if (dialogueIndex < 0 || dialogueIndex >= dialogueList.length) return;
    final d = dialogueList[dialogueIndex];
    if (d.kTagList == null || kTagIndex < 0 || kTagIndex >= d.kTagList!.length) return;

    final k = d.kTagList![kTagIndex];
    final start = k.startTime ?? 0;
    int end;
    if (kTagIndex + 1 < d.kTagList!.length) {
      end = d.kTagList![kTagIndex + 1].startTime ?? (start + (k.duration ?? 0));
    } else {
      end = d.endTime ?? (start + (k.duration ?? 0));
    }
    if (end <= start) return;

    _manualPauseAnchorTimeMs = null;
    currentTime = start;
    update();

    if (audioUrl.isEmpty) return;
    final speed = Get.find<ConfigController>().userSetting.value.expandAudioSpeed;
    final int playEnd = (end - 10).clamp(start, end);
    final segMs = (playEnd - start).clamp(0, 1000000);
    final previewMs = ((segMs / (speed <= 0 ? 1.0 : speed))).ceil();
    _isAutoPreviewingAfterDrag = true;
    _autoPreviewStayTimeMs = playEnd;
    _autoPreviewFinishTimer?.cancel();
    _autoPreviewFinishTimer = Timer(Duration(milliseconds: previewMs + 250), () {
      if (_isAutoPreviewingAfterDrag) {
        _isAutoPreviewingAfterDrag = false;
        currentTime = _autoPreviewStayTimeMs;
        update();
      }
    });
    try {
      await audioPlayer?.playSegment(
        source: UrlSource(audioUrl),
        playbackRate: speed,
        startTime: Duration(milliseconds: start),
        endTime: Duration(milliseconds: playEnd),
      );
    } catch (_) {}
  }
}
