part of 'ass_media_subtitle_editor_widget.dart';

extension _AssMediaSubtitleEditorWidgetMediaMethods
    on _AssMediaSubtitleEditorWidgetState {
  void _initData() {
    for (final controller in _zhControllers) {
      controller.dispose();
    }
    for (final list in _kTextControllers) {
      for (final controller in list) {
        controller.dispose();
      }
    }
    for (final list in _kTagFocusNodes) {
      for (final FocusNode focusNode in list) {
        focusNode.dispose();
      }
    }
    for (final list in _timeControllers) {
      for (final controller in list) {
        controller.dispose();
      }
    }
    _zhControllers.clear();
    _kTextControllers.clear();
    _kTagFocusNodes.clear();
    _timeControllers.clear();

    final AudioSubtitleEditorModel model = AudioSubtitleEditorModel(
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      widget.mediaUrl,
      null,
      null,
      widget.ass,
      null,
      null,
      null,
      null,
      widget.translateAss == null
          ? null
          : <LanguageText>[LanguageText(lang: 'zh', text: widget.translateAss)],
      null,
      null,
    );
    _dialogueList = KaraokeSubtitlesUtils.parseAssString(model)
        .map(_cloneDialogue)
        .toList();
    for (final dialogue in _dialogueList) {
      _zhControllers
          .add(TextEditingController(text: dialogue.zhDialogueStr ?? ''));
      _kTextControllers.add((dialogue.kTagList ?? <KTagModel>[])
          .map((item) => TextEditingController(text: item.text ?? ''))
          .toList());
      _kTagFocusNodes.add((dialogue.kTagList ?? <KTagModel>[])
          .map((_) => FocusNode())
          .toList());
      _timeControllers.add(<TextEditingController>[
        TextEditingController(text: dialogue.startTimeStr),
        TextEditingController(text: dialogue.endTimeStr),
      ]);
    }
    _activeDialogueIndex = _dialogueList.isEmpty ? null : 0;
    _editDialogueIndex = null;
    _showCaptionDialogueIndex = null;
    // _emitChanged();
    _updateState();
  }

  DialogueModel _cloneDialogue(DialogueModel source) {
    final DialogueModel dialogue = DialogueModel(
      index: source.index,
      startTime: source.startTime,
      endTime: source.endTime,
      kTagText: source.kTagText,
      text: source.text,
      kTagList: (source.kTagList ?? <KTagModel>[])
          .map((item) => KTagModel(
                startTime: item.startTime,
                duration: item.duration,
                kTagText: item.kTagText,
                text: item.text,
                rightSpace: item.rightSpace,
                isEdit: item.isEdit,
              ))
          .toList(),
      layerIndex: source.layerIndex,
      isEdit: source.isEdit,
      zhDialogueStr: source.zhDialogueStr,
    );
    dialogue.prefixStr = source.prefixStr;
    return dialogue;
  }

  Future<void> _prepareMedia() async {
    _waveformSubscription?.cancel();
    _waveformSubscription = null;
    _positionSubscription?.cancel();
    _completeSubscription?.cancel();
    _playingSubscription?.cancel();
    _durationSubscription?.cancel();
    try {
      await _audioPlayer?.stop();
    } catch (_) {}
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _videoController = null;
    _isVideoReady = false;

    if (widget.mediaUrl.trim().isEmpty) return;
    _loadingMedia = true;
    _waveform = null;
    _waveformError = null;
    _waveformProgress = 0;
    _updateState();

    try {
      final ResourceType type = widget.mediaType == ResourceTypeEnum.video
          ? ResourceType.video
          : ResourceType.audio;
      final String? localPath =
          await CacheManagerUtils.instance.getFile(widget.mediaUrl, type);
      if (!mounted || localPath == null || localPath.isEmpty) return;
      _audioPlayer = Player();
      if (widget.mediaType == ResourceTypeEnum.video) {
        _videoController = VideoController(_audioPlayer!);
      }
      _updateState();
      _playingSubscription = _audioPlayer?.stream.playing.listen((playing) {
        _isPlayingValue = playing;
        _updateState();
      });
      _durationSubscription = _audioPlayer?.stream.duration.listen((duration) {
        _totalDurationTime = duration.inMilliseconds;
        _updateState();
      });
      _positionSubscription = _audioPlayer?.stream.position.listen((position) {
        if (!mounted || !_isPlaying) return;
        _currentTime = position.inMilliseconds;
        for (int i = 0; i < _dialogueList.length; i++) {
          final DialogueModel dialogue = _dialogueList[i];
          if (_currentTime >= (dialogue.startTime ?? 0) &&
              _currentTime <= (dialogue.endTime ?? 0)) {
            _showCaptionDialogueIndex = i;
            _activeDialogueIndex = i;
            final List<KTagModel> tags = dialogue.kTagList ?? <KTagModel>[];
            for (int j = 0; j < tags.length; j++) {
              final int start = tags[j].startTime ?? 0;
              final int duration = tags[j].duration ?? 0;
              if (_currentTime >= start && _currentTime <= start + duration) {
                _showCaptionKTagIndex = j;
                _showCaptionKTagProgress =
                    duration <= 0 ? 0 : (_currentTime - start) / duration;
                break;
              }
            }
            _scheduleAutoScrollToDialogue(i);
            break;
          }
        }
        _updateState();
      });

      _completeSubscription =
          _audioPlayer?.stream.completed.listen((completed) async {
        if (!completed) return;
        if (_isAutoPreviewingAfterDrag) {
          _previewPauseTimer?.cancel();
          _isAutoPreviewingAfterDrag = false;
          _isPlayingValue = false;
          _currentTime = _autoPreviewStayTimeMs;
          try {
            await _audioPlayer
                ?.seek(Duration(milliseconds: _autoPreviewStayTimeMs));
            await _audioPlayer?.pause();
          } catch (_) {}
          _updateState();
          return;
        }
        if (_sentenceSegmentEndTimeMs != null) {
          final int segmentEnd = _sentenceSegmentEndTimeMs!;
          _sentenceSegmentEndTimeMs = null;
          _sentenceSegmentTimer?.cancel();
          _sentenceSegmentTimer = null;
          _sentencePlayGeneration++;
          final int? index =
              _isWordMode ? _editDialogueIndex : _activeDialogueIndex;
          final bool hasValidIndex =
              index != null && index >= 0 && index < _dialogueList.length;
          if (hasValidIndex) {
            final int start = _dialogueList[index].startTime ?? segmentEnd;
            if (_isWordMode && _editDialogueIndex == index) {
              _isPlayingValue = false;
              _currentTime = start;
              try {
                await _audioPlayer?.seek(Duration(milliseconds: start));
                await _audioPlayer?.pause();
              } catch (_) {}
              _updateState();
              return;
            }
          }
          _isPlayingValue = false;
          _currentTime = segmentEnd;
          try {
            await _audioPlayer?.pause();
          } catch (_) {}
          _updateState();
          return;
        }
        _isPlayingValue = false;
        _currentTime = 0;
        try {
          await _audioPlayer?.seek(Duration.zero);
          await _audioPlayer?.pause();
        } catch (_) {}
        _updateState();
      });
      await _audioPlayer?.open(Media(localPath), play: false);
      if (widget.mediaType == ResourceTypeEnum.video) {
        try {
          await _videoController?.waitUntilFirstFrameRendered.timeout(
            const Duration(seconds: 3),
          );
        } catch (_) {}
        _isVideoReady = true;
      } else {
        _isVideoReady = true;
      }
      await _audioPlayer?.setRate(widget.playbackRate);
      _updateState();

      final Directory tempDir =
          await Directory.systemTemp.createTemp('ass_media_editor_wave');
      _waveformSubscription = JustWaveform.extract(
        audioInFile: File(localPath),
        waveOutFile: File(path.join(tempDir.path, 'waveform.wave')),
      ).listen(
        (progress) {
          if (!mounted) return;
          _waveformProgress = progress.progress;
          if (progress.waveform != null) {
            _waveform = JustAudioWaveformData(progress.waveform!);
            _totalDurationTime = progress.waveform!.duration.inMilliseconds;
          }
          _updateState();
        },
        onError: (Object error) {
          if (!mounted) return;
          _waveformError = error;
          _updateState();
        },
      );
    } finally {
      if (mounted) {
        _loadingMedia = false;
        _updateState();
      }
    }
  }

  void _emitChanged() {
    String ass = '';
    String zhAss = '';
    for (final dialogue in _dialogueList) {
      ass += dialogue.dialogueStr;
      if (dialogue.zhDialogueAss != null) {
        zhAss += dialogue.zhDialogueAss!;
      }
    }
    if (ass.endsWith('\n')) ass = ass.substring(0, ass.length - 1);
    if (zhAss.endsWith('\n')) zhAss = zhAss.substring(0, zhAss.length - 1);
    widget.onChanged?.call(
      AssMediaSubtitleEditorValue(
        ass: ass,
        translateAss: zhAss.isEmpty ? null : zhAss,
        content: _dialogueList
            .map((item) => (item.text ?? '').trim())
            .where((item) => item.isNotEmpty)
            .join('\n'),
        dialogueList: _dialogueList.map(_cloneDialogue).toList(),
      ),
    );
  }

  Future<void> _togglePlayPause() async {
    if (_audioPlayer == null) return;
    await _audioPlayer?.setRate(widget.playbackRate);
    if (_isPlaying) {
      _isAutoPreviewingAfterDrag = false;
      _previewPauseTimer?.cancel();
      _sentenceSegmentTimer?.cancel();
      _sentenceSegmentTimer = null;
      _sentenceSegmentEndTimeMs = null;
      await _audioPlayer?.pause();
    } else {
      if (_isWordMode && _editDialogueIndex != null) {
        await _playDialogueSegmentFromTime(_editDialogueIndex!, _currentTime);
      } else {
        _sentenceSegmentEndTimeMs = null;
        await _audioPlayer?.seek(Duration(milliseconds: _currentTime));
        await _audioPlayer?.play();
      }
    }
    _updateState();
  }

  Future<void> _stopPlayback() async {
    if (_audioPlayer == null) return;
    _cancelTransientPlayback();
    _showCaptionDialogueIndex = null;
    _showCaptionKTagIndex = 0;
    _showCaptionKTagProgress = 0;
    _currentTime = 0;
    try {
      await _audioPlayer?.pause();
      await _audioPlayer?.seek(Duration.zero);
    } catch (_) {}
    _isPlayingValue = false;
    _updateState();
  }

  void _cancelTransientPlayback() {
    _isAutoPreviewingAfterDrag = false;
    _previewPauseTimer?.cancel();
    _sentenceSegmentTimer?.cancel();
    _sentenceSegmentTimer = null;
    _sentenceSegmentEndTimeMs = null;
    _sentencePlayGeneration++;
  }

  Future<void> _playDialogueSegmentFromTime(
      int dialogueIndex, int fromTimeMs) async {
    if (_audioPlayer == null) return;
    if (dialogueIndex < 0 || dialogueIndex >= _dialogueList.length) return;
    final DialogueModel dialogue = _dialogueList[dialogueIndex];
    final int start = dialogue.startTime ?? 0;
    final int end = dialogue.endTime ?? start;
    final int playFrom = fromTimeMs.clamp(start, end);
    _isAutoPreviewingAfterDrag = false;
    _previewPauseTimer?.cancel();
    _currentTime = playFrom;
    _sentenceSegmentEndTimeMs = end;
    _sentenceSegmentTimer?.cancel();
    _sentenceSegmentTimer = null;
    final int generation = ++_sentencePlayGeneration;
    final int timerMs = ((end - playFrom) /
            (widget.playbackRate <= 0 ? 1.0 : widget.playbackRate))
        .ceil();
    await _audioPlayer?.setRate(widget.playbackRate);
    await _audioPlayer?.seek(Duration(milliseconds: playFrom));
    await _audioPlayer?.play();
    _sentenceSegmentTimer = Timer(Duration(milliseconds: timerMs), () async {
      _sentenceSegmentTimer = null;
      if (_sentencePlayGeneration != generation) return;
      if (_isWordMode && _editDialogueIndex == dialogueIndex) {
        _isPlayingValue = false;
        _currentTime = start;
        _sentenceSegmentEndTimeMs = null;
        try {
          await _audioPlayer?.seek(Duration(milliseconds: start));
          await _audioPlayer?.pause();
        } catch (_) {}
        _updateState();
        return;
      }
      _isPlayingValue = false;
      _currentTime = end;
      _sentenceSegmentEndTimeMs = null;
      try {
        await _audioPlayer?.pause();
      } catch (_) {}
      _updateState();
    });
  }

  int? _findDialogueIndexByTime(int timeMs) {
    for (int i = 0; i < _dialogueList.length; i++) {
      final DialogueModel dialogue = _dialogueList[i];
      final int? start = dialogue.startTime;
      final int? end = dialogue.endTime;
      if (start == null || end == null) continue;
      if (timeMs >= start && timeMs <= end) {
        return i;
      }
    }
    return null;
  }

  int? _findKTagIndexByTime(int dialogueIndex, int timeMs) {
    if (dialogueIndex < 0 || dialogueIndex >= _dialogueList.length) return null;
    final List<KTagModel> tags =
        _dialogueList[dialogueIndex].kTagList ?? <KTagModel>[];
    if (tags.isEmpty) return null;
    for (int i = 0; i < tags.length; i++) {
      final int start = tags[i].startTime ?? 0;
      final int end = i + 1 < tags.length
          ? (tags[i + 1].startTime ?? (start + (tags[i].duration ?? 0)))
          : (_dialogueList[dialogueIndex].endTime ??
              (start + (tags[i].duration ?? 0)));
      if (timeMs >= start && timeMs < end) {
        return i;
      }
    }
    final int lastStart = tags.last.startTime ?? 0;
    if (timeMs >= lastStart) {
      return tags.length - 1;
    }
    return null;
  }

  Future<void> _seekTo(int timeMs, {bool play = false}) async {
    if (_audioPlayer == null) return;
    int targetTimeMs = timeMs.clamp(0, _totalDurationTime);
    if (_isWordMode && _editDialogueIndex != null) {
      final int dialogueIndex = _editDialogueIndex!;
      if (dialogueIndex < 0 || dialogueIndex >= _dialogueList.length) return;
      final DialogueModel dialogue = _dialogueList[dialogueIndex];
      final int dialogueStart = dialogue.startTime ?? 0;
      final int dialogueEnd = dialogue.endTime ?? dialogueStart;
      final bool hasValidRange = dialogueEnd > dialogueStart;
      if (hasValidRange) {
        targetTimeMs = targetTimeMs.clamp(dialogueStart, dialogueEnd);
      }
      final bool shouldSegmentPlay = play || _isPlaying;
      final int playFrom = (hasValidRange && targetTimeMs >= dialogueEnd)
          ? dialogueStart
          : targetTimeMs;
      _currentTime = targetTimeMs;
      await _audioPlayer?.seek(Duration(milliseconds: _currentTime));
      _activeDialogueIndex = dialogueIndex;
      _showCaptionDialogueIndex = dialogueIndex;
      final int? kTagIndex = _findKTagIndexByTime(dialogueIndex, _currentTime);
      if (kTagIndex != null) {
        _showCaptionKTagIndex = kTagIndex;
        final List<KTagModel> tags = dialogue.kTagList ?? <KTagModel>[];
        final KTagModel tag = tags[kTagIndex];
        final int start = tag.startTime ?? _currentTime;
        final int end = kTagIndex + 1 < tags.length
            ? (tags[kTagIndex + 1].startTime ?? (start + (tag.duration ?? 0)))
            : (dialogue.endTime ?? (start + (tag.duration ?? 0)));
        final int dur = (end - start).clamp(0, _totalDurationTime);
        _showCaptionKTagProgress =
            dur > 0 ? ((_currentTime - start) / dur).clamp(0.0, 1.0) : 0.0;
      } else {
        _showCaptionKTagIndex = 0;
        _showCaptionKTagProgress = 0;
      }
      if (play || _isPlaying) {
        _lastAutoScrollSentenceIndex = null;
        _scheduleAutoScrollToDialogue(dialogueIndex);
      }
      if (shouldSegmentPlay) {
        await _playDialogueSegmentFromTime(dialogueIndex, playFrom);
      }
      _updateState();
      return;
    }

    _currentTime = targetTimeMs;
    await _audioPlayer?.seek(Duration(milliseconds: _currentTime));
    int? matchedDialogueIndex;
    matchedDialogueIndex = _findDialogueIndexByTime(_currentTime);
    if (matchedDialogueIndex != null) {
      final DialogueModel dialogue = _dialogueList[matchedDialogueIndex];
      _activeDialogueIndex = matchedDialogueIndex;
      _showCaptionDialogueIndex = matchedDialogueIndex;
      final List<KTagModel> tags = dialogue.kTagList ?? <KTagModel>[];
      _showCaptionKTagIndex = 0;
      _showCaptionKTagProgress = 0;
      final int? kTagIndex =
          _findKTagIndexByTime(matchedDialogueIndex, _currentTime);
      if (kTagIndex != null) {
        _showCaptionKTagIndex = kTagIndex;
        final KTagModel tag = tags[kTagIndex];
        final int kStart = tag.startTime ?? _currentTime;
        final int kEnd = kTagIndex + 1 < tags.length
            ? (tags[kTagIndex + 1].startTime ?? (kStart + (tag.duration ?? 0)))
            : (dialogue.endTime ?? (kStart + (tag.duration ?? 0)));
        final int kDuration = (kEnd - kStart).clamp(0, _totalDurationTime);
        _showCaptionKTagProgress = kDuration <= 0
            ? 0
            : ((_currentTime - kStart) / kDuration).clamp(0.0, 1.0);
      }
    }
    if (matchedDialogueIndex == null) {
      _showCaptionDialogueIndex = null;
      _showCaptionKTagIndex = 0;
      _showCaptionKTagProgress = 0;
    } else if (play || _isPlaying) {
      _lastAutoScrollSentenceIndex = null;
      _scheduleAutoScrollToDialogue(matchedDialogueIndex);
    }
    if (play) {
      await _audioPlayer?.play();
    }
    _updateState();
  }

  Future<void> _focusOnDialogue(
    int index, {
    bool stopAtSentenceEnd = false,
  }) async {
    if (index < 0 || index >= _dialogueList.length) return;
    _activeDialogueIndex = index;
    final DialogueModel dialogue = _dialogueList[index];
    final int start = dialogue.startTime ?? 0;
    if (stopAtSentenceEnd) {
      _showCaptionDialogueIndex = index;
      final int? kTagIndex = _findKTagIndexByTime(index, start);
      _showCaptionKTagIndex = kTagIndex ?? 0;
      _showCaptionKTagProgress = 0;
      await _playDialogueSegmentFromTime(index, start);
    } else {
      await _seekTo(start, play: !_isPlaying);
    }
    final BuildContext? cellContext = _cellContexts[index];
    if (cellContext != null && cellContext.mounted) {
      await Scrollable.ensureVisible(
        cellContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    }
    if (stopAtSentenceEnd) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_centerWaveformDialogueIfNeeded(index));
      });
    }
  }

  void _restoreDialogueFromBackup(int dialogueIndex, DialogueModel backup) {
    if (dialogueIndex < 0 || dialogueIndex >= _dialogueList.length) return;
    _dialogueList[dialogueIndex] = _cloneDialogue(backup);

    _zhControllers[dialogueIndex].text =
        _dialogueList[dialogueIndex].zhDialogueStr ?? '';

    for (final TextEditingController controller
        in _kTextControllers[dialogueIndex]) {
      controller.dispose();
    }
    for (final FocusNode focusNode in _kTagFocusNodes[dialogueIndex]) {
      focusNode.dispose();
    }
    _kTextControllers[dialogueIndex] = (_dialogueList[dialogueIndex].kTagList ??
            <KTagModel>[])
        .map((KTagModel kTag) => TextEditingController(text: kTag.text ?? ''))
        .toList();
    _kTagFocusNodes[dialogueIndex] =
        (_dialogueList[dialogueIndex].kTagList ?? <KTagModel>[])
            .map((_) => FocusNode())
            .toList();

    for (final TextEditingController controller
        in _timeControllers[dialogueIndex]) {
      controller.dispose();
    }
    _timeControllers[dialogueIndex] = <TextEditingController>[
      TextEditingController(text: _dialogueList[dialogueIndex].startTimeStr),
      TextEditingController(text: _dialogueList[dialogueIndex].endTimeStr),
    ];

    _refreshDialogue(dialogueIndex, notify: false);
  }

  Future<void> _resetWaveformView() async {
    _zoomLevel = 2.5;
    if (_waveScrollController.hasClients) {
      try {
        _waveScrollController.jumpTo(0);
      } catch (_) {}
    }
  }

  Future<void> _exitWordModePlayback({required bool keepPlaying}) async {
    _sentenceSegmentTimer?.cancel();
    _sentenceSegmentTimer = null;
    _sentenceSegmentEndTimeMs = null;
    _sentencePlayGeneration++;
    _isAutoPreviewingAfterDrag = false;
    _previewPauseTimer?.cancel();

    if (!keepPlaying) {
      try {
        await _audioPlayer?.pause();
      } catch (_) {}
      _isPlayingValue = false;
      return;
    }

    try {
      await _audioPlayer?.seek(Duration(milliseconds: _currentTime));
      await _audioPlayer?.play();
    } catch (_) {}

    final int? index = _findDialogueIndexByTime(_currentTime);
    if (index != null) {
      _activeDialogueIndex = index;
    }
  }

  int _getDisplayStartMs() {
    if (_isWordMode && _editDialogueIndex != null) {
      final int index = _editDialogueIndex!;
      if (index >= 0 && index < _dialogueList.length) {
        return _dialogueList[index].startTime ?? 0;
      }
    }
    return 0;
  }

  int _getDisplayDurationMs() {
    if (_isWordMode && _editDialogueIndex != null) {
      final int index = _editDialogueIndex!;
      if (index >= 0 && index < _dialogueList.length) {
        final DialogueModel dialogue = _dialogueList[index];
        final int start = dialogue.startTime ?? 0;
        final int end = dialogue.endTime ?? start;
        if (end > start) {
          return end - start;
        }
      }
    }
    return _waveform?.duration.inMilliseconds ?? _totalDurationTime;
  }

  double _getEffectiveRatio(double contentArea, int displayDurationMs) {
    final double baseRatio = contentArea / 60000;
    if (displayDurationMs <= 0) {
      return baseRatio;
    }
    final double minRatio = contentArea / displayDurationMs;
    final double zoomedRatio = baseRatio * _zoomLevel;
    return zoomedRatio < minRatio ? minRatio : zoomedRatio;
  }

  void _updateActualZoomLevel(double contentArea, int displayDurationMs) {
    if (displayDurationMs <= 0) return;
    const int oneMinuteMs = 60000;
    final double baseRatio = contentArea / oneMinuteMs;
    final double minRatio = contentArea / displayDurationMs;
    final double currentZoomedRatio = baseRatio * _zoomLevel;
    if (displayDurationMs < oneMinuteMs ||
        (_isWordMode && displayDurationMs > 0)) {
      if (currentZoomedRatio < minRatio) {
        final double actualZoomLevel =
            (minRatio / baseRatio).clamp(1.0, double.infinity);
        if ((actualZoomLevel - _zoomLevel).abs() > 0.0001) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _zoomLevel = actualZoomLevel;
            _updateState();
          });
        }
      }
    }
  }

  void _scheduleAutoScrollToDialogue(int index) {
    if (_lastAutoScrollSentenceIndex == index) return;
    _autoScrollSentenceTimer?.cancel();
    _autoScrollSentenceTimer =
        Timer(const Duration(milliseconds: 200), () async {
      _lastAutoScrollSentenceIndex = index;
      final BuildContext? cellContext = _cellContexts[index];
      if (cellContext == null || !cellContext.mounted) return;
      await Scrollable.ensureVisible(
        cellContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _scrollWaveformByPercent(double percent) async {
    if (!_waveScrollController.hasClients) return;
    final double max = _waveScrollController.position.maxScrollExtent;
    final double delta =
        _waveScrollController.position.viewportDimension * percent;
    final double next = (_waveScrollController.offset + delta).clamp(0.0, max);
    try {
      await _waveScrollController.animateTo(
        next,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    } catch (_) {}
  }

  Future<void> _centerWaveformDialogueIfNeeded(int index) async {
    if (!_waveScrollController.hasClients) return;
    if (index < 0 || index >= _dialogueList.length) return;
    final DialogueModel dialogue = _dialogueList[index];
    final int startMs = dialogue.startTime ?? 0;
    final int endMs = dialogue.endTime ?? startMs;
    final int displayStartMs = _getDisplayStartMs();
    final int displayDurationMs = _getDisplayDurationMs();
    if (displayDurationMs <= 0) return;
    final double viewportWidth =
        _waveScrollController.position.viewportDimension;
    final double contentArea =
        (viewportWidth - 40.wMin).clamp(1.0, double.infinity);
    final double width =
        displayDurationMs * _getEffectiveRatio(contentArea, displayDurationMs);
    if (width <= 0) return;
    final double offset = _waveScrollController.offset;
    final double visibleLeft = offset;
    final double visibleRight = offset + viewportWidth;
    final double edgePadding = 20.wMin;
    final double startX =
        (((startMs - displayStartMs) / displayDurationMs).clamp(0.0, 1.0) *
                width) +
            20.wMin;
    final double endX =
        (((endMs - displayStartMs) / displayDurationMs).clamp(0.0, 1.0) *
                width) +
            20.wMin;
    final bool isOutOfView =
        startX < visibleLeft + edgePadding || endX > visibleRight - edgePadding;
    if (!isOutOfView) return;
    final double targetCenter = (startX + endX) / 2;
    final double targetOffset = (targetCenter - (viewportWidth / 2))
        .clamp(0.0, _waveScrollController.position.maxScrollExtent);
    try {
      await _waveScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    } catch (_) {}
  }

  void _zoomOut() {
    _zoomLevel = (_zoomLevel - 0.5).clamp(1.0, 20.0);
    _updateState();
  }

  void _zoomIn() {
    _zoomLevel = (_zoomLevel + 0.5).clamp(1.0, 20.0);
    _updateState();
  }

  AssEditorPlaybackBarState _buildPlaybackBarState() {
    return AssEditorPlaybackBarState(
      currentTime: _currentTime,
      totalDurationTime: _totalDurationTime,
      zoomLevel: _zoomLevel,
      isPlaying: _isPlaying,
      isWordMode: _isWordMode,
    );
  }

  AssEditorPlaybackBarActions _buildPlaybackBarActions() {
    return AssEditorPlaybackBarActions(
      togglePlayPause: _togglePlayPause,
      stop: _stopPlayback,
      switchDialogueByOffset: _switchDialogueByOffset,
      zoomOut: _zoomOut,
      zoomIn: _zoomIn,
      resetView: _resetWaveformView,
      scrollWaveformByPercent: _scrollWaveformByPercent,
    );
  }

  void _applyPendingZoomAnchorIfNeeded() {
    final int? anchorTimeMs = _pendingZoomAnchorTimeMs;
    final double? anchorViewportDx = _pendingZoomAnchorViewportDx;
    if (anchorTimeMs == null || anchorViewportDx == null) return;
    if (!_waveScrollController.hasClients) return;
    final int displayStartMs = _getDisplayStartMs();
    final int displayDurationMs = _getDisplayDurationMs();
    if (displayDurationMs <= 0) return;
    final double viewportWidth =
        _waveScrollController.position.viewportDimension;
    final double contentArea =
        (viewportWidth - 40.wMin).clamp(1.0, double.infinity);
    final double width =
        displayDurationMs * _getEffectiveRatio(contentArea, displayDurationMs);
    if (width <= 0) return;
    final double ratio =
        ((anchorTimeMs - displayStartMs) / displayDurationMs).clamp(0.0, 1.0);
    final double rawX = ratio * width + 20.wMin;
    final double target = (rawX - anchorViewportDx)
        .clamp(0.0, _waveScrollController.position.maxScrollExtent);
    try {
      _waveScrollController.jumpTo(target);
    } catch (_) {}
    _pendingZoomAnchorTimeMs = null;
    _pendingZoomAnchorViewportDx = null;
  }

  void _zoomWithAnchor({
    required double delta,
    required int anchorTimeMs,
    required double anchorViewportDx,
  }) {
    _pendingZoomAnchorTimeMs = anchorTimeMs;
    _pendingZoomAnchorViewportDx = anchorViewportDx;
    _zoomLevel = (_zoomLevel + delta).clamp(1.0, 20.0);
    _updateState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyPendingZoomAnchorIfNeeded();
    });
  }

  void _setScrollbarDragging(bool dragging) {
    if (_isScrollbarDragging == dragging) return;
    _isScrollbarDragging = dragging;
    _updateState();
  }

  Future<void> _previewSegment(int startMs, int endMs, {int? holdAtMs}) async {
    if (_audioPlayer == null) return;
    final int safeStart = startMs.clamp(0, _totalDurationTime);
    final int safeEnd = endMs.clamp(safeStart, _totalDurationTime);
    if (safeEnd <= safeStart) return;
    _cancelTransientPlayback();
    _previewPauseTimer?.cancel();
    _isAutoPreviewingAfterDrag = true;
    _currentTime = safeStart;
    _autoPreviewStayTimeMs = (holdAtMs ?? safeEnd).clamp(safeStart, safeEnd);
    await _audioPlayer?.setRate(widget.playbackRate);
    await _audioPlayer?.seek(Duration(milliseconds: safeStart));
    await _audioPlayer?.play();
    final int hold = _autoPreviewStayTimeMs;
    final int previewMs = ((safeEnd - safeStart) /
            (widget.playbackRate <= 0 ? 1.0 : widget.playbackRate))
        .ceil();
    _previewPauseTimer = Timer(Duration(milliseconds: previewMs), () async {
      if (!_isAutoPreviewingAfterDrag) return;
      try {
        await _audioPlayer?.pause();
        await _audioPlayer?.seek(Duration(milliseconds: hold));
      } catch (_) {}
      _isAutoPreviewingAfterDrag = false;
      _isPlayingValue = false;
      _currentTime = hold;
      _updateState();
    });
    _updateState();
  }

  Future<void> _previewSentenceDrag(int index, {required bool isStart}) async {
    if (index < 0 || index >= _dialogueList.length) return;
    final DialogueModel dialogue = _dialogueList[index];
    if (isStart) {
      final int start = dialogue.startTime ?? 0;
      final int end = (start + 1000).clamp(0, _totalDurationTime);
      await _previewSegment(start, end, holdAtMs: end);
      return;
    }
    final int end = dialogue.endTime ?? 0;
    final int start = (end - 1000).clamp(0, end);
    await _previewSegment(start, end, holdAtMs: end);
  }

  String _kTagKey(int dialogueIndex, int kTagIndex, {required bool isLast}) {
    return '$dialogueIndex-$kTagIndex-${isLast ? 1 : 0}';
  }

  void _onKTagPointerDown(
    int dialogueIndex,
    int kTagIndex,
    double dx, {
    bool isLast = false,
  }) {
    final String key = _kTagKey(dialogueIndex, kTagIndex, isLast: isLast);
    _kTagPointerDownDx[key] = dx;
    _kTagPointerDownAtMs[key] = DateTime.now().millisecondsSinceEpoch;
    _kTagPointerMoved[key] = false;
    if (_isPlaying) {
      _cancelTransientPlayback();
      unawaited(_audioPlayer?.pause());
      _isPlayingValue = false;
      _updateState();
    }
  }

  bool _isKTagTap(
    int dialogueIndex,
    int kTagIndex,
    double upDx, {
    bool isLast = false,
  }) {
    final String key = _kTagKey(dialogueIndex, kTagIndex, isLast: isLast);
    final double? downDx = _kTagPointerDownDx.remove(key);
    final int? downAt = _kTagPointerDownAtMs.remove(key);
    final bool moved = _kTagPointerMoved.remove(key) ?? false;
    if (downDx == null || downAt == null || moved) {
      return false;
    }
    final int dt = DateTime.now().millisecondsSinceEpoch - downAt;
    final double dd = (upDx - downDx).abs();
    return dt < 220 && dd < 4;
  }

  Future<void> _playFromKTagToNext(int dialogueIndex, int kTagIndex) async {
    if (dialogueIndex < 0 || dialogueIndex >= _dialogueList.length) return;
    final DialogueModel dialogue = _dialogueList[dialogueIndex];
    final List<KTagModel> tags = dialogue.kTagList ?? <KTagModel>[];
    if (kTagIndex < 0 || kTagIndex >= tags.length) return;
    final int start = tags[kTagIndex].startTime ?? 0;
    final int end =
        (start + (tags[kTagIndex].duration ?? 0)).clamp(0, _totalDurationTime);
    final int playEnd = (end > start + 10) ? (end - 10) : start;
    await _previewSegment(start, playEnd, holdAtMs: playEnd);
  }

  Future<void> _previewDraggedKTagToNext(
      int dialogueIndex, int kTagIndex) async {
    if (dialogueIndex < 0 || dialogueIndex >= _dialogueList.length) return;
    final DialogueModel dialogue = _dialogueList[dialogueIndex];
    final List<KTagModel> tags = dialogue.kTagList ?? <KTagModel>[];
    if (kTagIndex < 0 || kTagIndex >= tags.length) return;
    final int start = tags[kTagIndex].startTime ?? 0;
    final int end = kTagIndex + 1 < tags.length
        ? (tags[kTagIndex + 1].startTime ??
            (start + (tags[kTagIndex].duration ?? 0)))
        : (dialogue.endTime ?? (start + (tags[kTagIndex].duration ?? 0)));
    if (end <= start) return;
    final int playEnd = (end - 10).clamp(start, end);
    await _previewSegment(start, playEnd, holdAtMs: playEnd);
  }

  void _setHoverMarker(Map<String, dynamic>? marker) {
    if (marker == null && _hoverMarker == null) return;
    if (marker != null &&
        _hoverMarker != null &&
        marker.toString() == _hoverMarker.toString()) {
      return;
    }
    _hoverMarker = marker;
    _updateState();
  }

  void _beginDragMarker(Map<String, dynamic> marker) {
    _dragMarker = marker;
    _updateState();
  }

  void _endDragMarker() {
    if (_dragMarker == null) return;
    _dragMarker = null;
    _updateState();
  }
}
