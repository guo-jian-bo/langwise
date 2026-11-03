part of 'ass_media_subtitle_editor_widget.dart';

extension _AssMediaSubtitleEditorWidgetWaveformMethods
    on _AssMediaSubtitleEditorWidgetState {
  Widget _buildBottomPlayerBar() {
    final Color accent = _isWordMode ? AppTheme.cSurfaceWarning : AppTheme.cFeedbackSuccessText;
    
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 70.wMin, vertical: 10.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfacePrimary,
          border: Border(top: BorderSide(color: accent, width: 1.wMin)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: _waveformTotalHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.cBgSecondary,
                borderRadius: BorderRadius.circular(10.wMin),
              ),
              child: _buildWaveformArea(),
            ),
            // SizedBox(height: 12.wMin),
            Row(
              spacing: 16.wMin,
              children: <Widget>[
                SizedBox(
                  width: 240.wMin,
                  child: Text(
                    '${KaraokeSubtitlesUtils.parseTimeToString(_currentTime)} / ${KaraokeSubtitlesUtils.parseTimeToString(_totalDurationTime)}',
                    style: TextStyle(
                      fontSize: 15.wMin,
                      color: AppTheme.cTextPrimary,
                      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        unawaited(_switchDialogueByOffset(-1));
                      },
                      child: Text(
                        '上一句',
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: AppTheme.cTextPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.wMin),
                    IconButton(
                      onPressed: _togglePlayPause,
                      icon: Container(
                        width: 40.wMin,
                        height: 40.wMin,
                        decoration: BoxDecoration(
                          color: AppTheme.cBgBrand.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: AppTheme.cTextBrand,
                          size: 26.wMin,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.wMin),
                    GestureDetector(
                      onTap: () {
                        unawaited(_switchDialogueByOffset(1));
                      },
                      child: Text(
                        '下一句',
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: AppTheme.cTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => _updateState(
                        () => _zoomLevel = (_zoomLevel - 0.5).clamp(1.0, 20.0),
                      ),
                      child: const Text('缩小'),
                    ),
                    Text(
                      '${(_zoomLevel * 100).toInt()}%',
                      style: TextStyle(fontSize: 14.wMin, color: AppTheme.cTextTertiary),
                    ),
                    TextButton(
                      onPressed: () => _updateState(
                        () => _zoomLevel = (_zoomLevel + 0.5).clamp(1.0, 20.0),
                      ),
                      child: const Text('放大'),
                    ),
                    TextButton(
                      onPressed: () => _updateState(() => _zoomLevel = 2.5),
                      child: const Text('重置'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _switchDialogueByOffset(int offset) async {
    final int? current = _isWordMode ? _editDialogueIndex : _activeDialogueIndex;
    if (current == null) return;
    final int target = current + offset;
    if (target < 0 || target >= _dialogueList.length) return;

    if (_isWordMode) {
      await _saveEditingDialogue(current);
      _startEditingDialogue(target);
      final BuildContext? cellContext = _cellContexts[target];
      if (cellContext != null && cellContext.mounted) {
        await Scrollable.ensureVisible(
          cellContext,
          alignment: 0.5,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
      }
      return;
    }

    await _focusOnDialogue(target);
  }

  Widget _buildWaveformArea() {
    if (_waveformError != null) {
      return Center(child: Text('Error: $_waveformError'));
    }
    if (_loadingMedia || _waveform == null) {
      return Center(
        child: Text(
          '${(_waveformProgress * 100).toInt()}%',
          style: TextStyle(fontSize: 26.wMin, color: AppTheme.cTextPrimary),
        ),
      );
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int displayStartMs = _getDisplayStartMs();
        final int displayDurationMs = _getDisplayDurationMs();
        final double contentArea =
            (constraints.maxWidth - 40.wMin).clamp(1.0, double.infinity).toDouble();
        _updateActualZoomLevel(contentArea, displayDurationMs);
        final double effectiveRatio = _getEffectiveRatio(contentArea, displayDurationMs);
        final double width = displayDurationMs * effectiveRatio;
        final int effectiveCurrentTimeMs = _currentTime;
        return Listener(
          onPointerSignal: (event) {
            if (event is! PointerScrollEvent) return;
            final bool isShiftPressed =
                HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftLeft) ||
                    HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftRight);
            if (isShiftPressed) {
              if (!_waveScrollController.hasClients) return;
              final double max = _waveScrollController.position.maxScrollExtent;
              final double next = (_waveScrollController.offset + event.scrollDelta.dy)
                  .clamp(0.0, max);
              _waveScrollController.jumpTo(next);
              return;
            }
            if (displayDurationMs <= 0 || width <= 0) return;
            if (!_waveScrollController.hasClients) return;
            final double scrollOffset = _waveScrollController.offset;
            final double contentDx = scrollOffset + event.localPosition.dx - 20.wMin;
            final double ratio = (contentDx / width).clamp(0.0, 1.0);
            final int anchorTimeMs =
                displayStartMs + (ratio * displayDurationMs).toInt();
            final double delta = event.scrollDelta.dy < 0 ? 0.2 : -0.2;
            _zoomWithAnchor(
              delta: delta,
              anchorTimeMs: anchorTimeMs,
              anchorViewportDx: event.localPosition.dx,
            );
          },
          child: ScrollConfiguration(
            behavior: const _NoDefaultScrollbarScrollBehavior(),
            child: ScrollbarTheme(
              data: ScrollbarThemeData(
                thickness: MaterialStateProperty.all(8.wMin),
                radius: Radius.circular(8.wMin),
                thumbColor: MaterialStateProperty.all(AppTheme.cInversePrimary),
                trackColor: MaterialStateProperty.all(
                  const Color.fromRGBO(255, 255, 255, 0.08),
                ),
                trackBorderColor: MaterialStateProperty.all(Colors.transparent),
                crossAxisMargin: 0,
                mainAxisMargin: 0,
              ),
              child: MouseRegion(
                cursor: _isScrollbarDragging
                    ? SystemMouseCursors.grabbing
                    : SystemMouseCursors.grab,
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (_) => _setScrollbarDragging(true),
                  onPointerUp: (_) => _setScrollbarDragging(false),
                  onPointerCancel: (_) => _setScrollbarDragging(false),
                  child: Scrollbar(
                    controller: _waveScrollController,
                    scrollbarOrientation: ScrollbarOrientation.bottom,
                    thumbVisibility: true,
                    trackVisibility: true,
                    interactive: true,
                    child: SingleChildScrollView(
                      controller: _waveScrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: Builder(
                        builder: (BuildContext stackContext) {
                          return MouseRegion(
                            cursor: SystemMouseCursors.precise,
                            child: Listener(
                              behavior: HitTestBehavior.opaque,
                              onPointerDown: (event) {
                                if (_dragMarker != null) return;
                                if (displayDurationMs <= 0 || width <= 0) return;
                                final double scrollOffset = _waveScrollController.hasClients
                                    ? _waveScrollController.offset
                                    : 0.0;
                                final double contentDx =
                                    scrollOffset + event.localPosition.dx - 20.wMin;
                                final double ratio = (contentDx / width).clamp(0.0, 1.0);
                                final int seekMs =
                                    displayStartMs + (ratio * displayDurationMs).toInt();
                                unawaited(_seekTo(seekMs, play: !_isPlaying));
                              },
                              child: Stack(
                                clipBehavior: Clip.hardEdge,
                                children: <Widget>[
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    top: 0,
                                    height: 2.wMin,
                                    child: IgnorePointer(
                                      child: Container(
                                        color: _isWordMode
                                            ? AppTheme.cSurfaceWarning
                                            : AppTheme.cFeedbackSuccessText,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    width: width + 40.wMin,
                                    height: _waveformTotalHeight,
                                    child: Container(
                                      color: _isWordMode
                                          ? AppTheme.cBgSecondary
                                          : AppTheme.cBgQuaternary,
                                    ),
                                  ),
                                  if (!_isWordMode)
                                    ...List<Widget>.generate(_dialogueList.length, (int i) {
                                      final DialogueModel dialogue = _dialogueList[i];
                                      final int startMs = dialogue.startTime ?? 0;
                                      final int endMs = dialogue.endTime ?? startMs;
                                      if (endMs <= startMs) {
                                        return const SizedBox.shrink();
                                      }
                                      final int denom = displayDurationMs <= 0 ? 1 : displayDurationMs;
                                      final double segLeft =
                                          (((startMs - displayStartMs) / denom).clamp(0.0, 1.0) * width) +
                                              20.wMin;
                                      final double segWidth =
                                          (((endMs - startMs) / denom) * width).clamp(0.0, double.infinity);
                                      if (segWidth <= 0) {
                                        return const SizedBox.shrink();
                                      }
                                      final bool isActive =
                                          _activeDialogueIndex == i || _showCaptionDialogueIndex == i;
                                      return Positioned(
                                        left: segLeft,
                                        top: (_waveformTotalHeight - _waveformSubHeight) / 2,
                                        width: segWidth,
                                        height: _waveformSubHeight,
                                        child: Container(
                                          color: isActive
                                              ? AppTheme.cTextBrand.withValues(alpha: 0.2)
                                              : const Color.fromRGBO(255, 255, 255, 0.05),
                                        ),
                                      );
                                    }),
                                  Center(
                                    child: Row(
                                      children: <Widget>[
                                        SizedBox(width: 20.wMin),
                                        SizedBox(
                                          width: width,
                                          height: _waveformSubHeight,
                                          child: AudioWaveformWidget(
                                            waveform: _waveform!,
                                            start: Duration(milliseconds: displayStartMs),
                                            duration: Duration(milliseconds: displayDurationMs),
                                            waveColor: (_isWordMode
                                                    ? AppTheme.cSurfaceWarning
                                                    : AppTheme.cFeedbackSuccessText)
                                                .withValues(alpha: 0.3),
                                          ),
                                        ),
                                        SizedBox(width: 20.wMin),
                                      ],
                                    ),
                                  ),
                                  if (!_isWordMode)
                                    ...List<Widget>.generate(
                                      _dialogueList.length,
                                      (int i) => _buildWaveformDialogueHandles(
                                        i,
                                        width,
                                        stackContext,
                                        displayStartMs,
                                        displayDurationMs,
                                      ),
                                    ),
                                  ..._buildKTagHandles(
                                    width,
                                    stackContext,
                                    displayStartMs,
                                    displayDurationMs,
                                  ),
                                  Positioned(
                                    left: displayDurationMs > 0
                                        ? ((((effectiveCurrentTimeMs - displayStartMs) /
                                                            displayDurationMs)
                                                        .clamp(0.0, 1.0)) *
                                                    width +
                                                20.wMin -
                                                (7.wMin / 2))
                                        : (20.wMin - (7.wMin / 2)),
                                    top: 0,
                                    width: 7.wMin,
                                    height: 7.wMin,
                                    child: const IgnorePointer(
                                      child: CustomPaint(
                                        painter: _DownTrianglePainter(color: Color(0xffFF2D46)),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: displayDurationMs > 0
                                        ? ((((effectiveCurrentTimeMs - displayStartMs) /
                                                            displayDurationMs)
                                                        .clamp(0.0, 1.0)) *
                                                    width +
                                                20.wMin -
                                                1.wMin)
                                        : (20.wMin - 1.wMin),
                                    top: 0,
                                    width: 2.wMin,
                                    height: _waveformTotalHeight,
                                    child: IgnorePointer(
                                      child: Container(color: const Color(0xffFF2D46)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onDialogueDrag(
    int index,
    bool isStart,
    double contentDx,
    double width,
    int displayDurationMs,
  ) {
    if (index < 0 || index >= _dialogueList.length) return;
    if (displayDurationMs <= 0 || width <= 0) return;
    final DialogueModel dialogue = _dialogueList[index];
    final double newPosRaw = (contentDx / width).clamp(0.0, 1.0);
    final double leftLimit = index == 0 && isStart
        ? 0.0
        : isStart
            ? ((_dialogueList[index - 1].endTime ?? 0) / displayDurationMs)
            : ((dialogue.startTime ?? 0) / displayDurationMs);
    final double rightLimit = index == _dialogueList.length - 1 && !isStart
        ? 1.0
        : isStart
            ? ((dialogue.endTime ?? 0) / displayDurationMs)
            : ((_dialogueList[index + 1].startTime ?? displayDurationMs) /
                displayDurationMs);
    final double newPos = newPosRaw.clamp(leftLimit, rightLimit);
    final int newTime = (newPos * displayDurationMs).toInt();
    if (isStart) {
      final int delta = newTime - (dialogue.startTime ?? 0);
      for (final KTagModel kTag in dialogue.kTagList ?? <KTagModel>[]) {
        kTag.startTime = (kTag.startTime ?? 0) + delta;
      }
      dialogue.startTime = newTime;
      _timeControllers[index].first.text = dialogue.startTimeStr;
    } else {
      dialogue.endTime = newTime;
      _timeControllers[index].last.text = dialogue.endTimeStr;
    }
    _updateState();
  }

  Future<void> _onDialogueDragEnd(int index, {required bool isStart}) async {
    if (index < 0 || index >= _dialogueList.length) return;
    _emitChanged();
    await _previewSentenceDrag(index, isStart: isStart);
  }

  void _onKTagDrag(
    int dialogueIndex,
    int kTagIndex,
    double dx,
    double width, {
    bool isLast = false,
    int? displayStartMs,
    int? displayDurationMs,
  }) {
    final String key = _kTagKey(dialogueIndex, kTagIndex, isLast: isLast);
    _kTagPointerMoved[key] = true;
    if (dialogueIndex < 0 || dialogueIndex >= _dialogueList.length) return;
    final DialogueModel dialogue = _dialogueList[dialogueIndex];
    final List<KTagModel> tags = dialogue.kTagList ?? <KTagModel>[];
    if (kTagIndex < 0 || kTagIndex >= tags.length) return;
    if (kTagIndex == 0 && tags.length != 1) return;
    final bool useSegment =
        displayStartMs != null && displayDurationMs != null && displayDurationMs > 0;
    final int absoluteRight = dialogue.endTime ?? _totalDurationTime;
    final double newPos = (dx / width).clamp(0.0, 1.0);
    int currentTime = useSegment
        ? (displayStartMs + (newPos * displayDurationMs).toInt())
        : (newPos * _totalDurationTime).toInt();
    const int minGapMs = 10;

    if (isLast) {
      int leftLimit = kTagIndex == 0
          ? (dialogue.startTime ?? 0)
          : (tags[kTagIndex].startTime ?? 0) + minGapMs;
      int rightLimit = useSegment ? absoluteRight : _totalDurationTime;
      if (kTagIndex + 1 < tags.length) {
        final int nextEnd = (kTagIndex + 2 < tags.length)
            ? (tags[kTagIndex + 2].startTime ?? absoluteRight)
            : absoluteRight;
        final int maxRightByNext =
            (nextEnd - minGapMs).clamp(0, rightLimit).toInt();
        rightLimit = rightLimit.clamp(0, maxRightByNext).toInt();
      }
      if (leftLimit > rightLimit) leftLimit = rightLimit;
      currentTime = currentTime.clamp(leftLimit, rightLimit);
      final int duration = currentTime - (tags[kTagIndex].startTime ?? currentTime);
      tags[kTagIndex].duration = duration;
      tags[kTagIndex].kTagText =
          '{\\k${(duration / 10).toInt()}}${tags[kTagIndex].text ?? ''}';
      if (kTagIndex + 1 < tags.length) {
        tags[kTagIndex + 1].startTime = currentTime;
        final int nextEnd = (kTagIndex + 2 < tags.length)
            ? (tags[kTagIndex + 2].startTime ?? absoluteRight)
            : absoluteRight;
        final int nextDuration =
            (nextEnd - currentTime).clamp(0, absoluteRight).toInt();
        tags[kTagIndex + 1].duration = nextDuration;
        tags[kTagIndex + 1].kTagText =
            '{\\k${(nextDuration / 10).toInt()}}${tags[kTagIndex + 1].text ?? ''}';
      }
      _currentTime = rightLimit;
      _refreshDialogue(dialogueIndex, notify: false);
      return;
    }

    int leftLimit = kTagIndex == 0
        ? (dialogue.startTime ?? 0)
        : (tags[kTagIndex - 1].startTime ?? 0) + minGapMs;
    final int oldTime = tags[kTagIndex].startTime ?? 0;
    final int desiredBoundary = currentTime.clamp(leftLimit, absoluteRight);
    final int delta = desiredBoundary - oldTime;
    final int n = tags.length;
    final List<int> newTimes = List<int>.generate(n, (int i) {
      if (i < kTagIndex) return tags[i].startTime ?? 0;
      if (i == kTagIndex) return desiredBoundary;
      return (tags[i].startTime ?? 0) + delta;
    });
    newTimes[n - 1] = newTimes[n - 1].clamp(0, absoluteRight);
    for (int i = n - 2; i >= kTagIndex; i--) {
      final int cap = newTimes[i + 1] - minGapMs;
      if (newTimes[i] > cap) newTimes[i] = cap;
    }
    if (newTimes[kTagIndex] < leftLimit) {
      newTimes[kTagIndex] = leftLimit;
    }
    for (int i = kTagIndex; i < n; i++) {
      tags[i].startTime = newTimes[i];
    }
    if (kTagIndex > 0) {
      final int duration = newTimes[kTagIndex] - (tags[kTagIndex - 1].startTime ?? 0);
      tags[kTagIndex - 1].duration = duration;
      tags[kTagIndex - 1].kTagText =
          '{\\k${(duration / 10).toInt()}}${tags[kTagIndex - 1].text ?? ''}';
    }
    for (int i = kTagIndex; i < n; i++) {
      final int nextStart = (i + 1 < n) ? newTimes[i + 1] : absoluteRight;
      final int duration = nextStart - (tags[i].startTime ?? nextStart);
      tags[i].duration = duration;
      tags[i].kTagText = '{\\k${(duration / 10).toInt()}}${tags[i].text ?? ''}';
    }
    _currentTime = newTimes[kTagIndex];
    _refreshDialogue(dialogueIndex, notify: false);
  }

  Future<void> _onKTagDragEnd(int dialogueIndex, int kTagIndex) async {
    if (dialogueIndex < 0 || dialogueIndex >= _dialogueList.length) return;
    _refreshDialogue(dialogueIndex);
    await _previewDraggedKTagToNext(dialogueIndex, kTagIndex);
  }

  Widget _buildClampTriangle({required Color color, required bool isLeft}) {
    return SizedBox(
      width: 6.wMin,
      height: 8.wMin,
      child: CustomPaint(
        painter: _ClampTrianglePainter(color: color, isLeft: isLeft),
      ),
    );
  }

  Widget _buildWaveformDialogueHandles(
    int index,
    double width,
    BuildContext stackContext,
    int displayStartMs,
    int displayDurationMs,
  ) {
    final DialogueModel model = _dialogueList[index];
    final int startMs = model.startTime ?? 0;
    final int endMs = model.endTime ?? startMs;
    final double denom = displayDurationMs <= 0 ? 1 : displayDurationMs.toDouble();
    final double subWidth = ((endMs - startMs) / denom) * width;
    if (subWidth <= 0) {
      return const SizedBox.shrink();
    }
    final double markerHitWidth = 48.wMin;
    final double centerX = markerHitWidth / 2;
    final Map<String, dynamic> sMarker = <String, dynamic>{
      'type': 'sentence',
      'index': index,
      'isStart': true,
    };
    final Map<String, dynamic> eMarker = <String, dynamic>{
      'type': 'sentence',
      'index': index,
      'isStart': false,
    };
    final bool sActive = (_dragMarker ?? _hoverMarker)?.toString() == sMarker.toString();
    final bool eActive = (_dragMarker ?? _hoverMarker)?.toString() == eMarker.toString();
    final bool sDragging = _dragMarker?.toString() == sMarker.toString();
    final bool eDragging = _dragMarker?.toString() == eMarker.toString();
    final bool sHovering = _hoverMarker?.toString() == sMarker.toString();
    final bool eHovering = _hoverMarker?.toString() == eMarker.toString();
    final bool isOverlapPriorityE =
        subWidth <= (_AssMediaSubtitleEditorWidgetState._markerSnapTolPx * 2);
    final bool seRangeActive = !_isWordMode &&
        _currentTime >= startMs &&
        _currentTime <= endMs;
    final Color sColor = sActive
        ? const Color(0xff059669)
        : (seRangeActive ? const Color(0xff34D399) : AppTheme.cFeedbackSuccessText);
    final Color eColor = eActive
        ? const Color(0xffDC2626)
        : (seRangeActive ? const Color(0xffF87171) : const Color(0xffEF4444));
    final double sLineW = sDragging
        ? 3.wMin
        : (sActive ? 2.wMin : (seRangeActive ? 2.wMin : 1.wMin));
    final double eLineW = eDragging
        ? 3.wMin
        : (eActive ? 2.wMin : (seRangeActive ? 2.wMin : 1.wMin));

    return Positioned(
      left: (((startMs - displayStartMs) / denom).clamp(0.0, 1.0) * width) -
          _waveformMinDistance / 2 +
          20.wMin,
      width: width,
      height: _waveformTotalHeight,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: _waveformMinDistance / 2 - centerX,
            child: MouseRegion(
              cursor: sActive
                  ? SystemMouseCursors.grabbing
                  : (sHovering
                      ? SystemMouseCursors.resizeLeftRight
                      : SystemMouseCursors.basic),
              onExit: (_) {
                if (_dragMarker?.toString() == sMarker.toString()) return;
                if (_hoverMarker?.toString() == sMarker.toString()) {
                  _setHoverMarker(null);
                }
              },
              onHover: (event) {
                if (isOverlapPriorityE) {
                  if (_hoverMarker?.toString() == sMarker.toString()) {
                    _setHoverMarker(null);
                  }
                  return;
                }
                final double localDx = event.localPosition.dx;
                if ((localDx - centerX).abs() <=
                    _AssMediaSubtitleEditorWidgetState._markerSnapTolPx) {
                  _setHoverMarker(sMarker);
                } else if (_hoverMarker?.toString() == sMarker.toString()) {
                  _setHoverMarker(null);
                }
              },
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (event) {
                  if (isOverlapPriorityE) return;
                  if ((event.localPosition.dx - centerX).abs() <=
                      _AssMediaSubtitleEditorWidgetState._markerSnapTolPx) {
                    _setHoverMarker(sMarker);
                    _beginDragMarker(sMarker);
                  }
                },
                onPointerMove: (event) {
                  if (event.buttons == 0) return;
                  if (_dragMarker?.toString() != sMarker.toString()) return;
                  final RenderBox box = stackContext.findRenderObject() as RenderBox;
                  final Offset local = box.globalToLocal(event.position);
                  final double contentDx =
                      (_waveScrollController.hasClients ? _waveScrollController.offset : 0.0) +
                          local.dx -
                          20.wMin;
                  _onDialogueDrag(index, true, contentDx, width, displayDurationMs);
                },
                onPointerUp: (_) {
                  final bool wasDragging = _dragMarker?.toString() == sMarker.toString();
                  if (!wasDragging) return;
                  _endDragMarker();
                  unawaited(_onDialogueDragEnd(index, isStart: true));
                },
                onPointerCancel: (_) => _endDragMarker(),
                child: SizedBox(
                  width: markerHitWidth,
                  height: _waveformTotalHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Positioned.fill(child: Container(color: Colors.transparent)),
                      Positioned(
                        top: 0,
                        left: centerX - (5.wMin / 2),
                        width: 5.wMin,
                        height: 12.wMin,
                        child: Container(color: sColor),
                      ),
                      Positioned(
                        top: 12.wMin,
                        left: centerX - (sLineW / 2),
                        width: sLineW,
                        height: (_waveformTotalHeight - 12.wMin).clamp(0.0, double.infinity),
                        child: Container(color: sColor),
                      ),
                      if (sActive) ...<Widget>[
                        Positioned(
                          top: 12.wMin + 2.wMin,
                          left: centerX - 6.wMin - 2.wMin,
                          child: _buildClampTriangle(
                            color: AppTheme.cFeedbackSuccessText,
                            isLeft: true,
                          ),
                        ),
                        Positioned(
                          top: 12.wMin + 2.wMin,
                          left: centerX + 2.wMin,
                          child: _buildClampTriangle(
                            color: AppTheme.cFeedbackSuccessText,
                            isLeft: false,
                          ),
                        ),
                      ],
                      Positioned(
                        top: 12.wMin + 2.wMin,
                        left: centerX + 3.wMin,
                        child: Text(
                          'S',
                          style: TextStyle(
                            fontSize: 16.wMin,
                            color: sColor,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: _waveformMinDistance / 2 + subWidth - centerX,
            child: MouseRegion(
              cursor: eActive
                  ? SystemMouseCursors.grabbing
                  : (eHovering
                      ? SystemMouseCursors.resizeLeftRight
                      : SystemMouseCursors.basic),
              onExit: (_) {
                if (_dragMarker?.toString() == eMarker.toString()) return;
                if (_hoverMarker?.toString() == eMarker.toString()) {
                  _setHoverMarker(null);
                }
              },
              onHover: (event) {
                final double localDx = event.localPosition.dx;
                if ((localDx - centerX).abs() <=
                    _AssMediaSubtitleEditorWidgetState._markerSnapTolPx) {
                  _setHoverMarker(eMarker);
                } else if (_hoverMarker?.toString() == eMarker.toString()) {
                  _setHoverMarker(null);
                }
              },
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (event) {
                  if ((event.localPosition.dx - centerX).abs() <=
                      _AssMediaSubtitleEditorWidgetState._markerSnapTolPx) {
                    _setHoverMarker(eMarker);
                    _beginDragMarker(eMarker);
                  }
                },
                onPointerMove: (event) {
                  if (event.buttons == 0) return;
                  if (_dragMarker?.toString() != eMarker.toString()) return;
                  final RenderBox box = stackContext.findRenderObject() as RenderBox;
                  final Offset local = box.globalToLocal(event.position);
                  final double contentDx =
                      (_waveScrollController.hasClients ? _waveScrollController.offset : 0.0) +
                          local.dx -
                          20.wMin;
                  _onDialogueDrag(index, false, contentDx, width, displayDurationMs);
                },
                onPointerUp: (_) {
                  final bool wasDragging = _dragMarker?.toString() == eMarker.toString();
                  if (!wasDragging) return;
                  _endDragMarker();
                  unawaited(_onDialogueDragEnd(index, isStart: false));
                },
                onPointerCancel: (_) => _endDragMarker(),
                child: SizedBox(
                  width: markerHitWidth,
                  height: _waveformTotalHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Positioned.fill(child: Container(color: Colors.transparent)),
                      Positioned(
                        top: 0,
                        left: centerX - (5.wMin / 2),
                        width: 5.wMin,
                        height: 12.wMin,
                        child: Container(color: eColor),
                      ),
                      Positioned(
                        top: 12.wMin,
                        left: centerX - (eLineW / 2),
                        width: eLineW,
                        height: (_waveformTotalHeight - 12.wMin).clamp(0.0, double.infinity),
                        child: Container(color: eColor),
                      ),
                      if (eActive) ...<Widget>[
                        Positioned(
                          top: 12.wMin + 2.wMin,
                          left: centerX - 6.wMin - 2.wMin,
                          child: _buildClampTriangle(
                            color: const Color(0xffEF4444),
                            isLeft: true,
                          ),
                        ),
                        Positioned(
                          top: 12.wMin + 2.wMin,
                          left: centerX + 2.wMin,
                          child: _buildClampTriangle(
                            color: const Color(0xffEF4444),
                            isLeft: false,
                          ),
                        ),
                      ],
                      Positioned(
                        top: 12.wMin + 2.wMin,
                        left: centerX - (12.wMin + 3.wMin),
                        child: Text(
                          'E',
                          style: TextStyle(
                            fontSize: 16.wMin,
                            color: eColor,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildKTagHandles(
    double width,
    BuildContext stackContext,
    int displayStartMs,
    int displayDurationMs,
  ) {
    if (_editDialogueIndex == null) return const <Widget>[];
    final int dialogueIndex = _editDialogueIndex!;
    if (dialogueIndex < 0 || dialogueIndex >= _dialogueList.length) {
      return const <Widget>[];
    }
    final DialogueModel dialogue = _dialogueList[dialogueIndex];
    final List<KTagModel> tags = dialogue.kTagList ?? <KTagModel>[];
    if (tags.isEmpty) return const <Widget>[];
    final int n = tags.length;
    final double denom = displayDurationMs <= 0 ? 1.0 : displayDurationMs.toDouble();
    final double defaultHalf = 16.wMin;
    final List<double> xPos = List<double>.generate(n, (int i) {
      return (((tags[i].startTime ?? 0) - displayStartMs) / denom).clamp(0.0, 1.0) * width;
    });
    final List<Widget> result = <Widget>[];
    for (int i = 0; i < n; i++) {
      final double halfLeft = i > 0
          ? ((xPos[i] - xPos[i - 1]) / 2.0).clamp(0.0, defaultHalf)
          : defaultHalf;
      final double halfRight = i < n - 1
          ? ((xPos[i + 1] - xPos[i]) / 2.0).clamp(0.0, defaultHalf)
          : defaultHalf;
      result.add(
        _buildKTagHandle(
          i,
          dialogueIndex,
          width,
          stackContext,
          displayStartMs,
          displayDurationMs,
          hitZoneLeft: xPos[i] - halfLeft,
          hitZoneRight: xPos[i] + halfRight,
        ),
      );
    }
    return result;
  }

  Widget _buildKTagHandle(
    int kTagIndex,
    int dialogueIndex,
    double width,
    BuildContext stackContext,
    int displayStartMs,
    int displayDurationMs, {
    bool isLast = false,
    double? hitZoneLeft,
    double? hitZoneRight,
  }) {
    final DialogueModel dialogue = _dialogueList[dialogueIndex];
    final List<KTagModel> tags = dialogue.kTagList ?? <KTagModel>[];
    final KTagModel kTagModel = tags[kTagIndex];
    final double markerHitWidth = 32.wMin;
    final double centerX = markerHitWidth / 2;
    final Map<String, dynamic> kMarker = <String, dynamic>{
      'type': 'ktag',
      'dialogueIndex': dialogueIndex,
      'kTagIndex': kTagIndex,
      'isLast': isLast,
    };
    final bool kActive = (_dragMarker ?? _hoverMarker)?.toString() == kMarker.toString();
    final bool kHovering = _hoverMarker?.toString() == kMarker.toString();
    final bool kDragging = _dragMarker?.toString() == kMarker.toString();
    final Color kColor = kActive ? const Color(0xffEA580C) : AppTheme.cSurfaceWarning;
    final double kLineW = kDragging ? 3.wMin : (kActive ? 2.wMin : 1.wMin);

    Widget buildHandle(double left, double widthBox, double lineX) {
      return Positioned(
        left: left,
        top: (_waveformTotalHeight - _waveformSubHeight) / 2,
        child: MouseRegion(
          cursor: kActive
              ? SystemMouseCursors.grabbing
              : (kHovering
                  ? SystemMouseCursors.resizeLeftRight
                  : SystemMouseCursors.basic),
          onExit: (_) {
            if ((_dragMarker ?? _hoverMarker)?.toString() == kMarker.toString()) {
              _setHoverMarker(null);
            }
          },
          onHover: (event) {
            if (isLast) {
              final double localDx = event.localPosition.dx;
              if ((localDx - centerX).abs() <=
                  _AssMediaSubtitleEditorWidgetState._markerSnapTolPx) {
                _setHoverMarker(kMarker);
              } else if (_hoverMarker?.toString() == kMarker.toString()) {
                _setHoverMarker(null);
              }
              return;
            }
            _setHoverMarker(kMarker);
          },
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) {
              final RenderBox box = stackContext.findRenderObject() as RenderBox;
              final Offset local = box.globalToLocal(event.position);
              final double scrollOffset =
                  _waveScrollController.hasClients ? _waveScrollController.offset : 0.0;
              final double contentDx = scrollOffset + local.dx - 20.wMin;
              _onKTagPointerDown(dialogueIndex, kTagIndex, contentDx, isLast: isLast);
              _beginDragMarker(kMarker);
            },
            onPointerMove: (event) {
              if (event.buttons == 0) return;
              if (_dragMarker?.toString() != kMarker.toString()) return;
              final RenderBox box = stackContext.findRenderObject() as RenderBox;
              final Offset local = box.globalToLocal(event.position);
              final double scrollOffset =
                  _waveScrollController.hasClients ? _waveScrollController.offset : 0.0;
              final double contentDx = scrollOffset + local.dx - 20.wMin;
              _onKTagDrag(
                dialogueIndex,
                kTagIndex,
                contentDx,
                width,
                isLast: isLast,
                displayStartMs: displayStartMs,
                displayDurationMs: displayDurationMs,
              );
            },
            onPointerUp: (event) {
              final RenderBox box = stackContext.findRenderObject() as RenderBox;
              final Offset local = box.globalToLocal(event.position);
              final double scrollOffset =
                  _waveScrollController.hasClients ? _waveScrollController.offset : 0.0;
              final double contentDx = scrollOffset + local.dx - 20.wMin;
              final bool wasDragging = _dragMarker?.toString() == kMarker.toString();
              if (wasDragging) {
                _endDragMarker();
              }
              if (_isKTagTap(dialogueIndex, kTagIndex, contentDx, isLast: isLast)) {
                unawaited(_playFromKTagToNext(dialogueIndex, kTagIndex));
                return;
              }
              if (wasDragging) {
                unawaited(_onKTagDragEnd(dialogueIndex, kTagIndex));
              }
            },
            onPointerCancel: (_) => _endDragMarker(),
            child: SizedBox(
              width: widthBox,
              height: _waveformSubHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned.fill(child: Container(color: Colors.transparent)),
                  Positioned(
                    top: 0,
                    left: lineX - (5.wMin / 2),
                    width: 5.wMin,
                    height: 12.wMin,
                    child: Container(color: kColor),
                  ),
                  Positioned(
                    top: 12.wMin,
                    left: lineX - (kLineW / 2),
                    width: kLineW,
                    height: (_waveformSubHeight - 12.wMin).clamp(0.0, double.infinity),
                    child: Container(color: kColor),
                  ),
                  if (kActive) ...<Widget>[
                    Positioned(
                      top: 12.wMin + 2.wMin,
                      left: lineX - 6.wMin - 2.wMin,
                      child: _buildClampTriangle(color: kColor, isLeft: true),
                    ),
                    Positioned(
                      top: 12.wMin + 2.wMin,
                      left: lineX + 2.wMin,
                      child: _buildClampTriangle(color: kColor, isLeft: false),
                    ),
                  ],
                  Positioned(
                    top: 12.wMin + 2.wMin,
                    left: lineX + centerX + 3.wMin,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(0, 0, 0, 0.20),
                        borderRadius: BorderRadius.circular(4.wMin),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.wMin,
                        vertical: 2.wMin,
                      ),
                      child: Text(
                        kTagModel.text ?? '',
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: AppTheme.cTextPrimary,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (isLast) {
      final double left = (((((kTagModel.startTime ?? 0) + (kTagModel.duration ?? 0)) -
                          displayStartMs) /
                      (displayDurationMs <= 0 ? 1 : displayDurationMs))
                  .clamp(0.0, 1.0) *
              width) +
          20.wMin -
          centerX;
      return buildHandle(left, markerHitWidth, centerX);
    }

    final double denom = displayDurationMs <= 0 ? 1.0 : displayDurationMs.toDouble();
    final double xPos = (((kTagModel.startTime ?? 0) - displayStartMs) / denom)
            .clamp(0.0, 1.0) *
        width;
    final double zoneL = hitZoneLeft ?? (xPos - centerX);
    final double zoneR = hitZoneRight ?? (xPos + centerX);
    final double zoneW = (zoneR - zoneL).clamp(1.0, double.infinity);
    final double lineX = xPos - zoneL;
    return buildHandle(zoneL + 20.wMin, zoneW, lineX);
  }
}
