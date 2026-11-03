part of 'manage_audio_subtitle_editor_view.dart';

extension ViewWaveformMixin on ManageAudioSubtitleEditorView {
  Widget waveformWidget(Waveform waveform) {
    return LayoutBuilder(
      builder: (context, outerConstraints) {
        int displayStartMs = 0;
        int displayDurationMs = waveform.duration.inMilliseconds;
        if (controller.isWordMode && controller.editDialogueIndex != null) {
          final idx = controller.editDialogueIndex!;
          if (idx >= 0 && idx < controller.dialogueList.length) {
            final d = controller.dialogueList[idx];
            final s = d.startTime ?? 0;
            final e = d.endTime ?? s;
            if (e > s) {
              displayStartMs = s;
              displayDurationMs = e - s;
            }
          }
        }

        controller.displayStartMs = displayStartMs;
        controller.displayDurationMs = displayDurationMs;

        // Waveform width: 1 minute of audio = viewport width at zoom 1.0.
        // If audio < 60s, stretch to fill viewport. If > 60s, scroll.
        final double contentArea =
            (outerConstraints.maxWidth - 40.wMin).clamp(1.0, double.infinity);
        const int oneMinuteMs = 60000;
        final double baseRatio = contentArea / oneMinuteMs;
        final double effectiveRatio;
        if (controller.isWordMode && displayDurationMs > 0) {
          // In word mode, ensure content fills viewport at minimum
          final double minRatio = contentArea / displayDurationMs;
          final double zoomedRatio = baseRatio * controller.zoomLevel;
          effectiveRatio = zoomedRatio < minRatio ? minRatio : zoomedRatio;
        } else {
          final double zoomedRatio = baseRatio * controller.zoomLevel;
          // If audio < 60s, stretch to fill viewport
          if (displayDurationMs < oneMinuteMs) {
            final double minRatio = contentArea / displayDurationMs;
            effectiveRatio = zoomedRatio < minRatio ? minRatio : zoomedRatio;
          } else {
            effectiveRatio = zoomedRatio;
          }
        }

        double width = displayDurationMs * effectiveRatio;
        controller.allWidth = width;

        // 同步更新实际的缩放级别
        controller.updateActualZoomLevel(contentArea, displayDurationMs);

        int effectiveCurrentTimeMs = controller.currentTime;

        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 2.wMin,
              child: IgnorePointer(
                child: Container(
                  color: controller.isWordMode
                      ? AppTheme.cSurfaceWarning
                      : AppTheme.cFeedbackSuccessText,
                ),
              ),
            ),
            Listener(
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  final isShiftPressed = HardwareKeyboard
                          .instance.logicalKeysPressed
                          .contains(LogicalKeyboardKey.shiftLeft) ||
                      HardwareKeyboard.instance.logicalKeysPressed
                          .contains(LogicalKeyboardKey.shiftRight);

                  if (isShiftPressed) {
                    if (!controller.scrollController.hasClients) return;
                    final max =
                        controller.scrollController.position.maxScrollExtent;
                    final next = (controller.scrollController.offset +
                            event.scrollDelta.dy)
                        .clamp(0.0, max);
                    controller.scrollController.jumpTo(next);
                    return;
                  }

                  if (displayDurationMs <= 0 || width <= 0) return;
                  if (!controller.scrollController.hasClients) return;
                  final double scrollOffset =
                      controller.scrollController.offset;
                  final double contentDx =
                      scrollOffset + event.localPosition.dx - 20.wMin;
                  final double ratio = (contentDx / width).clamp(0.0, 1.0);
                  final int anchorTimeMs =
                      displayStartMs + (ratio * displayDurationMs).toInt();
                  final double delta = event.scrollDelta.dy < 0 ? 0.2 : -0.2;
                  controller.zoomWithAnchor(
                    delta: delta,
                    anchorTimeMs: anchorTimeMs,
                    anchorViewportDx: event.localPosition.dx,
                  );
                }
              },
              child: ScrollConfiguration(
                behavior: _noDefaultScrollbarBehavior(),
                child: ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thickness: MaterialStateProperty.all(8.wMin),
                    radius: Radius.circular(8.wMin),
                    thumbColor:
                        MaterialStateProperty.all(AppTheme.cInversePrimary),
                    trackColor: MaterialStateProperty.all(
                        const Color.fromRGBO(255, 255, 255, 0.08)),
                    trackBorderColor:
                        MaterialStateProperty.all(Colors.transparent),
                    crossAxisMargin: 0,
                    mainAxisMargin: 0,
                  ),
                  child: MouseRegion(
                    cursor: controller.isScrollbarDragging
                        ? SystemMouseCursors.grabbing
                        : SystemMouseCursors.grab,
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (_) {
                        controller.setScrollbarDragging(true);
                      },
                      onPointerUp: (_) {
                        controller.setScrollbarDragging(false);
                      },
                      onPointerCancel: (_) {
                        controller.setScrollbarDragging(false);
                      },
                      child: Scrollbar(
                        controller: controller.scrollController,
                        scrollbarOrientation: ScrollbarOrientation.bottom,
                        thumbVisibility: true,
                        trackVisibility: true,
                        interactive: true,
                        child: Stack(
                          children: [
                            SingleChildScrollView(
                              controller: controller.scrollController,
                              scrollDirection: Axis.horizontal,
                              physics: const ClampingScrollPhysics(),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.precise,
                                child: Listener(
                                  behavior: HitTestBehavior.opaque,
                                  onPointerDown: (event) {
                                    if (controller.dragMarker != null) return;
                                    if (displayDurationMs <= 0 || width <= 0)
                                      return;
                                    final double scrollOffset =
                                        controller.scrollController.hasClients
                                            ? controller.scrollController.offset
                                            : 0.0;
                                    final double contentDx = scrollOffset +
                                        event.localPosition.dx -
                                        20.wMin;
                                    final double ratio =
                                        (contentDx / width).clamp(0.0, 1.0);
                                    final int seekMs = displayStartMs +
                                        (ratio * displayDurationMs).toInt();
                                    controller.seekToTime(seekMs,
                                        play: !controller.isPlaying,
                                        scrollWaveform: false);
                                  },
                                  child: Stack(
                                    clipBehavior: Clip.hardEdge,
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        width: width + 40.wMin,
                                        height: controller.totalHeight,
                                        child: Container(
                                          color: controller.isWordMode
                                              ? AppTheme.cBgSecondary
                                              : AppTheme.cBgQuaternary,
                                        ),
                                      ),
                                      if (!controller.isWordMode)
                                        ...List.generate(
                                            controller.dialogueList.length,
                                            (i) {
                                          final model =
                                              controller.dialogueList[i];
                                          final startMs = model.startTime ?? 0;
                                          final endMs =
                                              model.endTime ?? startMs;
                                          if (endMs <= startMs)
                                            return const SizedBox.shrink();

                                          final denom = displayDurationMs <= 0
                                              ? 1
                                              : displayDurationMs;
                                          final double segLeft =
                                              (((startMs - displayStartMs) /
                                                              denom)
                                                          .clamp(0.0, 1.0) *
                                                      width) +
                                                  20.wMin;
                                          final double segWidth =
                                              (((endMs - startMs) / denom) *
                                                      width)
                                                  .clamp(0.0, double.infinity);
                                          if (segWidth <= 0)
                                            return const SizedBox.shrink();

                                          final bool isActive = controller
                                                      .activeDialogueIndex ==
                                                  i ||
                                              controller
                                                      .showCaptionDialogueIndex ==
                                                  i;
                                          final Color segColor = isActive
                                              ? AppTheme.cTextBrand
                                                  .withOpacity(0.20)
                                              : const Color.fromRGBO(
                                                  255, 255, 255, 0.05);

                                          return Positioned(
                                            left: segLeft,
                                            top: (controller.totalHeight -
                                                    controller.subHeight) /
                                                2,
                                            width: segWidth,
                                            height: controller.subHeight,
                                            child: Container(color: segColor),
                                          );
                                        }),
                                      Center(
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 20.wMin,
                                            ),
                                            SizedBox(
                                              width: width,
                                              height: controller.subHeight,
                                              child: AudioWaveformWidget(
                                                waveform: waveform,
                                                start: Duration(
                                                    milliseconds:
                                                        displayStartMs),
                                                duration: Duration(
                                                    milliseconds:
                                                        displayDurationMs),
                                                waveColor: controller.isWordMode
                                                    ? AppTheme.cSurfaceWarning
                                                        .withOpacity(0.30)
                                                    : AppTheme.cFeedbackSuccessText
                                                        .withOpacity(0.30),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 20.wMin,
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!controller.isWordMode)
                                        ...List.generate(
                                            controller.dialogueList.length,
                                            (i) {
                                          return _buildDialogueWidget(
                                              i,
                                              width,
                                              context,
                                              displayStartMs,
                                              displayDurationMs);
                                        }),
                                      if (controller.isWordMode) ...[
                                        Positioned(
                                          left: (displayDurationMs > 0)
                                              ? ((((effectiveCurrentTimeMs -
                                                                  displayStartMs) /
                                                              displayDurationMs)
                                                          .clamp(0.0, 1.0)) *
                                                      width +
                                                  20.wMin -
                                                  (7.wMin / 2))
                                              : (20.wMin - (7.wMin / 2)),
                                          top: 0,
                                          width: 7.wMin,
                                          height: 7.wMin,
                                          child: IgnorePointer(
                                            child: CustomPaint(
                                              painter: _DownTrianglePainter(
                                                  color:
                                                      const Color(0xffFF2D46)),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: (displayDurationMs > 0)
                                              ? ((((effectiveCurrentTimeMs -
                                                                  displayStartMs) /
                                                              displayDurationMs)
                                                          .clamp(0.0, 1.0)) *
                                                      width +
                                                  20.wMin -
                                                  1.wMin)
                                              : (20.wMin - 1.wMin),
                                          top: 0,
                                          width: 2.wMin,
                                          height: controller.totalHeight,
                                          child: IgnorePointer(
                                            child: Container(
                                              color: const Color(0xffFF2D46),
                                            ),
                                          ),
                                        ),
                                        ..._buildKTagsWidget(width, context,
                                            displayStartMs, displayDurationMs),
                                      ] else ...[
                                        ..._buildKTagsWidget(width, context,
                                            displayStartMs, displayDurationMs),
                                        Positioned(
                                          left: (displayDurationMs > 0)
                                              ? ((((effectiveCurrentTimeMs -
                                                                  displayStartMs) /
                                                              displayDurationMs)
                                                          .clamp(0.0, 1.0)) *
                                                      width +
                                                  20.wMin -
                                                  (7.wMin / 2))
                                              : (20.wMin - (7.wMin / 2)),
                                          top: 0,
                                          width: 7.wMin,
                                          height: 7.wMin,
                                          child: IgnorePointer(
                                            child: CustomPaint(
                                              painter: _DownTrianglePainter(
                                                  color:
                                                      const Color(0xffFF2D46)),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: (displayDurationMs > 0)
                                              ? ((((effectiveCurrentTimeMs -
                                                                  displayStartMs) /
                                                              displayDurationMs)
                                                          .clamp(0.0, 1.0)) *
                                                      width +
                                                  20.wMin -
                                                  1.wMin)
                                              : (20.wMin - 1.wMin),
                                          top: 0,
                                          width: 2.wMin,
                                          height: controller.totalHeight,
                                          child: IgnorePointer(
                                            child: Container(
                                              color: const Color(0xffFF2D46),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ], // 闭合内部 Stack (Line 183)
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

}
