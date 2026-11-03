part of 'manage_audio_subtitle_editor_controller.dart';

extension AudioEditorAudioMethods on ManageAudioSubtitleEditorController {
  void _audioTrace(String message) {
    debugPrint('[AudioSubtitleEditor] $message');
  }

  bool _isTextInputFocused() {
    final focus = FocusManager.instance.primaryFocus;
    final context = focus?.context;
    if (context == null) return false;
    if (context.widget is EditableText) return true;
    return context.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  bool _shouldLoopWholeAudio() {
    final String contentType = (type ?? audioModel?.type ?? '').toUpperCase();
    if (contentType == 'EN_PHRASE' || contentType == 'EN_SENTENCE') {
      return false;
    }
    return true;
  }

  Future<void> _handleWordModeLoopIfNeeded() async {
    if (!wordModeLoopEnabled) return;
    if (!isWordMode) return;
    if (editDialogueIndex == null) return;
    if (_isWordModeLoopSeeking) return;
    if (audioPlayer?.state != PlayerState.playing) return;
    if (_sentenceSegmentEndTimeMs != null) return;

    final idx = editDialogueIndex!;
    if (idx < 0 || idx >= dialogueList.length) return;

    final d = dialogueList[idx];
    final start = d.startTime;
    final end = d.endTime;
    if (start == null || end == null) return;
    if (end <= start) return;

    if (currentTime >= end) {
      _isWordModeLoopSeeking = true;
      try {
        await audioPlayer?.seek(Duration(milliseconds: start));
        await audioPlayer?.pause();
        currentTime = start;
        update();
      } catch (_) {
      } finally {
        _isWordModeLoopSeeking = false;
      }
    }
  }

  Future<void> _downloadAudioFile(String? urlString, int taskVersion) async {
    ToastUtils.showLoading();

    try {
      if (!isLatestAudioDataTask(taskVersion)) {
        return;
      }
      final tempDir = await Directory.systemTemp.createTemp('audio_waveform');
      final filePath = File(join(tempDir.path, 'waveform.mp3'));
      audioDownloadCancelToken?.cancel();
      audioDownloadCancelToken = CancelToken();
      WiseHttp().download(
        urlString ?? '',
        filePath.path,
        cancelToken: audioDownloadCancelToken,
        onReceiveProgress: (count, total) {
          if (!isLatestAudioDataTask(taskVersion)) {
            return;
          }
          if (count >= total) {
            audioFilePath = filePath.path;
            audioUrl = urlString ?? '';
            _getAudioWaveform(tempDir.path);
            audioPlayerInit(filePath.path, taskVersion);
          }
        },
      );
    } catch (e) {
      debugPrint("下载音频文件失败======: $e");
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void audioPlayerInit(String filePath, int taskVersion) async {
    if (!isLatestAudioDataTask(taskVersion)) {
      return;
    }
    await _positionSubscription?.cancel();
    await _playerCompleteSubscription?.cancel();
    try {
      await audioPlayer?.stop();
    } catch (_) {}
    audioPlayer?.dispose();
    audioPlayer = AudioPlayerEx();
    audioPlayer?.setReleaseMode(ReleaseMode.stop);
    audioPlayer?.setPlaybackRate(Get.find<ConfigController>().userSetting.value.expandAudioSpeed);
    _positionSubscription = audioPlayer?.onPositionChanged.listen(
      (position) {
        final state = audioPlayer?.state;
        if (state != PlayerState.playing || position.inMilliseconds <= 0) return;
        currentTime = position.inMilliseconds;

        for (var i = 0; i < dialogueList.length; i++) {
          DialogueModel dialogueModel = dialogueList[i];
          if (currentTime >= dialogueModel.startTime! && currentTime <= dialogueModel.endTime!) {
            for (var j = 0; j < dialogueModel.kTagList!.length; j++) {
              if (currentTime >= dialogueModel.kTagList![j].startTime! && currentTime <= dialogueModel.kTagList![j].startTime! + dialogueModel.kTagList![j].duration!) {
                showCaptionKTagIndex = j;
                showCaptionKTagProgress = (currentTime - dialogueModel.kTagList![j].startTime!) / dialogueModel.kTagList![j].duration!;
                break;
              }
            }
            showCaptionDialogueIndex = i;
            break;
          }
          showCaptionDialogueIndex = null;
        }

        if (showCaptionDialogueIndex != null) {
          if (activeDialogueIndex != showCaptionDialogueIndex) {
            activeDialogueIndex = showCaptionDialogueIndex;
            if (!isWordMode) {
              _scheduleAutoScrollToDialogue(activeDialogueIndex!);
            }
            _scheduleAutoCenterWaveformToDialogue(activeDialogueIndex!);
          }
        }

        _handleWordModeLoopIfNeeded();
        update();
      },
    );
    _playerCompleteSubscription = audioPlayer?.onPlayerComplete.listen(
      (event) async {
        if (_isAutoPreviewingAfterDrag) {
          _autoPreviewFinishTimer?.cancel();
          _isAutoPreviewingAfterDrag = false;
          currentTime = _autoPreviewStayTimeMs;
          update();
          return;
        }
        if (_sentenceSegmentEndTimeMs != null) {
          final int segmentEnd = _sentenceSegmentEndTimeMs!;
          currentTime = segmentEnd;
          _sentenceSegmentEndTimeMs = null;
          _sentenceSegmentTimer?.cancel();
          _sentenceSegmentTimer = null;
          _sentencePlayGeneration++;

          final int? idx = isWordMode ? editDialogueIndex : activeDialogueIndex;
          final bool hasValidIndex = idx != null && idx >= 0 && idx < dialogueList.length;
          if (hasValidIndex) {
            final int start = dialogueList[idx].startTime ?? currentTime;
            final bool shouldLoopInSentenceMode = !isWordMode;
            final bool shouldLoopInWordMode = wordModeLoopEnabled && isWordMode && editDialogueIndex == idx;
            if (shouldLoopInSentenceMode || shouldLoopInWordMode) {
              await playDialogueModelFromTime(idx, start);
              return;
            }
            if (isWordMode && editDialogueIndex == idx) {
              currentTime = start;
              try {
                await audioPlayer?.seek(Duration(milliseconds: start));
                await audioPlayer?.pause();
              } catch (_) {}
              update();
              return;
            }
          }
          update();
          return;
        }
        if (!isWordMode) {
          currentTime = 0;
          try {
            await audioPlayer?.seek(Duration.zero);
            if (_shouldLoopWholeAudio()) {
              await audioPlayer?.resume();
            } else {
              await audioPlayer?.pause();
            }
          } catch (_) {}
          update();
        }
      },
    );
    await audioPlayer?.setSource(UrlSource(audioUrl));
    totalDurationTime = (await audioPlayer?.getDuration())!.inMilliseconds;
  }

  Future<void> _getAudioWaveform(String filePath) async {
    ToastUtils.showLoading();

    final audioFile = File(join(filePath, 'waveform.mp3'));
    final waveFile = File(join(filePath, 'waveform.wave'));

    try {
      JustWaveform.extract(audioInFile: audioFile, waveOutFile: waveFile).listen(
        (progress) {
          progressController.add(progress);
          if (progress.waveform != null) {
            totalDurationTime = progress.waveform!.duration.inMilliseconds;
            update();
          }
        },
        onError: progressController.addError,
      );
    } catch (e) {
      progressController.addError(e);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  bool handleKeyboardEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (event.logicalKey == LogicalKeyboardKey.space) {
      if (_isTextInputFocused()) return false;
      if (audioPlayer == null) return false;
      audioPlayAndPause();
      return true;
    }
    return false;
  }

  void audioPlayAndPause() async {
    audioPlayer?.setPlaybackRate(Get.find<ConfigController>().userSetting.value.expandAudioSpeed);
    if (audioPlayer?.state == PlayerState.playing) {
      final savedTime = currentTime;
      _audioTrace('pause pressed savedTime=$savedTime state=${audioPlayer?.state}');
      _manualPauseAnchorTimeMs = savedTime;
      _sentenceSegmentTimer?.cancel();
      _sentenceSegmentTimer = null;
      _sentenceSegmentEndTimeMs = null;
      _isAutoPreviewingAfterDrag = false;
      _autoPreviewFinishTimer?.cancel();
      await audioPlayer?.pause();
      currentTime = savedTime;
      _audioTrace('pause done state=${audioPlayer?.state} current=$currentTime anchor=$_manualPauseAnchorTimeMs');
      update();
      return;
    } else {
      _audioTrace('play pressed state=${audioPlayer?.state} current=$currentTime anchor=$_manualPauseAnchorTimeMs wordMode=$isWordMode editIndex=$editDialogueIndex');
      _manualPauseAnchorTimeMs = null;
      if (isWordMode && editDialogueIndex != null) {
        final int idx = editDialogueIndex!;
        if (idx >= 0 && idx < dialogueList.length) {
          final d = dialogueList[idx];
          final int start = d.startTime ?? currentTime;
          final int end = d.endTime ?? start;
          final int from = (end > start)
              ? ((currentTime >= end) ? start : currentTime.clamp(start, end))
              : currentTime;
          _audioTrace('playDialogueModelFromTime word mode idx=$idx from=$currentTime');
          playDialogueModelFromTime(idx, from);
          _lastAutoCenterWaveformDialogueIndex = null;
          _scheduleAutoCenterWaveformToDialogue(idx);
          update();
          return;
        }
      }
      _sentenceSegmentEndTimeMs = null;
      if (audioPlayer?.state == PlayerState.paused) {
        await audioPlayer?.seek(Duration(milliseconds: currentTime));
        await audioPlayer?.resume();
        _audioTrace('resume global from current=$currentTime');
      } else {
        await audioPlayer?.seek(Duration(milliseconds: currentTime));
        await audioPlayer?.resume();
        _audioTrace('seek+resume global from current=$currentTime');
      }
      final int? idx = showCaptionDialogueIndex ?? activeDialogueIndex;
      if (idx != null) {
        _lastAutoCenterWaveformDialogueIndex = null;
        _scheduleAutoCenterWaveformToDialogue(idx);
      }
    }
    update();
  }

  void audioInit() async {
    currentTime = 0;
    showCaptionDialogueIndex = null;
    await audioPlayer?.stop();
    update();
  }

  Future<void> seekToTime(int timeMs, {bool play = false, bool scrollWaveform = true}) async {
    if (timeMs < 0) timeMs = 0;
    if (totalDurationTime > 0 && timeMs > totalDurationTime) timeMs = totalDurationTime;
    currentTime = timeMs;

    if (isWordMode && editDialogueIndex != null) {
      final dIdx = editDialogueIndex!;
      if (dIdx < 0 || dIdx >= dialogueList.length) return;
      final d = dialogueList[dIdx];
      final int dialogueStart = d.startTime ?? 0;
      final int dialogueEnd = d.endTime ?? dialogueStart;
      final bool hasValidRange = dialogueEnd > dialogueStart;
      if (hasValidRange) {
        timeMs = timeMs.clamp(dialogueStart, dialogueEnd);
      }
      currentTime = timeMs;

      final kIdx = findKTagIndexByTime(dIdx, timeMs);
      if (kIdx != null) {
        final k = d.kTagList![kIdx];
        final start = k.startTime ?? timeMs;
        final int end;
        if (kIdx + 1 < d.kTagList!.length) {
          end = (d.kTagList![kIdx + 1].startTime ?? (start + (k.duration ?? 0))).clamp(0, totalDurationTime);
        } else {
          end = (d.endTime ?? (start + (k.duration ?? 0))).clamp(0, totalDurationTime);
        }
        final int dur = (end - start).clamp(0, totalDurationTime);
        showCaptionDialogueIndex = dIdx;
        showCaptionKTagIndex = kIdx;
        showCaptionKTagProgress = dur > 0 ? ((timeMs - start) / dur).clamp(0.0, 1.0) : 0.0;
      }
      if (play) {
        final int playFrom = (hasValidRange && timeMs >= dialogueEnd) ? dialogueStart : timeMs;
        currentTime = playFrom;
        _manualPauseAnchorTimeMs = null;
        playDialogueModelFromTime(dIdx, playFrom);
        _lastAutoCenterWaveformDialogueIndex = null;
        _scheduleAutoCenterWaveformToDialogue(dIdx);
        if (scrollWaveform) {
          await scrollWaveformToTime(playFrom, center: false);
        }
        update();
        return;
      }
      if (audioPlayer?.state == PlayerState.playing) {
        final int playFrom = (hasValidRange && timeMs >= dialogueEnd) ? dialogueStart : timeMs;
        currentTime = playFrom;
        _manualPauseAnchorTimeMs = null;
        playDialogueModelFromTime(dIdx, playFrom);
        update();
        return;
      }
      try {
        await audioPlayer?.seek(Duration(milliseconds: timeMs));
      } catch (_) {}
      update();
      return;
    }

    try {
      await audioPlayer?.seek(Duration(milliseconds: timeMs));
      if (play) {
        _manualPauseAnchorTimeMs = null;
        await audioPlayer?.resume();
      }
    } catch (_) {}

    final idx = findDialogueIndexByTime(timeMs);
    if (idx != null) {
      activeDialogueIndex = idx;
      _scheduleAutoScrollToDialogue(idx);
    }
    if (scrollWaveform) {
      await scrollWaveformToTime(timeMs, center: false);
    }
    update();
  }

  Future<void> scrollWaveformToTime(int timeMs, {bool center = true}) async {
    if (!scrollController.hasClients) return;
    if (totalDurationTime <= 0) return;
    if (allWidth <= 0) return;

    final viewport = scrollController.position.viewportDimension;
    final raw = (timeMs / totalDurationTime) * allWidth + 20.0;
    final target = center ? (raw - viewport / 2) : raw;
    final clamped = target.clamp(0.0, scrollController.position.maxScrollExtent);
    try {
      await scrollController.animateTo(
        clamped,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    } catch (_) {}
  }

  Future<void> scrollWaveformByPercent(double percent) async {
    if (!scrollController.hasClients) return;
    if (percent == 0) return;
    final max = scrollController.position.maxScrollExtent;
    final target = (scrollController.offset + max * percent).clamp(0.0, max);
    try {
      await scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    } catch (_) {}
  }

  void _autoPreviewAfterSentenceDrag(int index, {required bool isStart}) {
    if (audioUrl.isEmpty) return;
    if (index < 0 || index >= dialogueList.length) return;
    final d = dialogueList[index];

    if (isStart) {
      currentTime = d.startTime ?? 0;
      final end = (currentTime + 1000).clamp(0, totalDurationTime);
      _manualPauseAnchorTimeMs = null;
      _isAutoPreviewingAfterDrag = true;
      _autoPreviewStayTimeMs = end;
      update();
      _autoPreviewFinishTimer?.cancel();
      final speed = Get.find<ConfigController>().userSetting.value.expandAudioSpeed;
      final segMs = (end - currentTime).clamp(0, 1000000);
      final previewMs = ((segMs / (speed <= 0 ? 1.0 : speed)) * 1.0).ceil();
      _autoPreviewFinishTimer = Timer(Duration(milliseconds: previewMs + 250), () {
        _isAutoPreviewingAfterDrag = false;
        currentTime = _autoPreviewStayTimeMs;
        update();
      });
      audioPlayer?.playSegment(
        source: UrlSource(audioUrl),
        playbackRate: Get.find<ConfigController>().userSetting.value.expandAudioSpeed,
        startTime: Duration(milliseconds: currentTime),
        endTime: Duration(milliseconds: end),
      );
      return;
    }

    final endTime = d.endTime ?? 0;
    final start = (endTime - 1000).clamp(0, endTime);
    _manualPauseAnchorTimeMs = null;
    _isAutoPreviewingAfterDrag = true;
    _autoPreviewStayTimeMs = endTime;
    currentTime = start;
    update();
    _autoPreviewFinishTimer?.cancel();
    final speed = Get.find<ConfigController>().userSetting.value.expandAudioSpeed;
    final segMs = (endTime - start).clamp(0, 1000000);
    final previewMs = ((segMs / (speed <= 0 ? 1.0 : speed)) * 1.0).ceil();
    _autoPreviewFinishTimer = Timer(Duration(milliseconds: previewMs + 250), () {
      _isAutoPreviewingAfterDrag = false;
      currentTime = _autoPreviewStayTimeMs;
      update();
    });
    audioPlayer?.playSegment(
      source: UrlSource(audioUrl),
      playbackRate: Get.find<ConfigController>().userSetting.value.expandAudioSpeed,
      startTime: Duration(milliseconds: start),
      endTime: Duration(milliseconds: endTime),
    );
  }

  Future<void> _autoPreviewAfterWordDrag(int dialogueIndex, int kTagIndex) async {
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
