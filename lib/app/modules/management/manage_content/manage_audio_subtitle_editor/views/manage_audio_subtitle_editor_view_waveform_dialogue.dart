part of 'manage_audio_subtitle_editor_view.dart';

extension ViewWaveformDialogueMixin on ManageAudioSubtitleEditorView {
  Widget _buildDialogueWidget(int index, double width, context,
      int displayStartMs, int displayDurationMs) {
    DialogueModel model = controller.dialogueList[index];
    final startMs = model.startTime ?? 0;
    final endMs = model.endTime ?? startMs;
    final denom = displayDurationMs <= 0 ? 1 : displayDurationMs;
    double subWidth = ((endMs - startMs) / denom) * width;

    final double markerHitWidth = 48.wMin;
    final double centerX = markerHitWidth / 2;
    final Map<String, dynamic> sMarker = <String, dynamic>{
      'type': 'sentence',
      'index': index,
      'isStart': true
    };
    final Map<String, dynamic> eMarker = <String, dynamic>{
      'type': 'sentence',
      'index': index,
      'isStart': false
    };
    final bool sActive =
        (controller.dragMarker ?? controller.hoverMarker)?.toString() ==
            sMarker.toString();
    final bool eActive =
        (controller.dragMarker ?? controller.hoverMarker)?.toString() ==
            eMarker.toString();
    final bool sDragging =
        controller.dragMarker?.toString() == sMarker.toString();
    final bool eDragging =
        controller.dragMarker?.toString() == eMarker.toString();
    final bool sHovering =
        controller.hoverMarker?.toString() == sMarker.toString();
    final bool eHovering =
        controller.hoverMarker?.toString() == eMarker.toString();
    final bool isOverlapPriorityE =
        subWidth <= (ManageAudioSubtitleEditorController.markerSnapTolPx * 2);

    final bool seRangeActive = !controller.isWordMode &&
        controller.currentTime >= startMs &&
        controller.currentTime <= endMs;

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
          controller.minDistance / 2 +
          20.wMin,
      width: width,
      height: controller.totalHeight,
      child: Stack(
        children: [
          Positioned(
            left: controller.minDistance / 2,
            top: (controller.totalHeight - controller.subHeight) / 2,
            width: subWidth,
            height: controller.subHeight,
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Positioned(
            top: 0,
            left: controller.minDistance / 2 - centerX,
            child: MouseRegion(
              cursor: sActive
                  ? SystemMouseCursors.grabbing
                  : (sHovering
                      ? SystemMouseCursors.resizeLeftRight
                      : SystemMouseCursors.basic),
              onExit: (_) {
                if (controller.dragMarker?.toString() == sMarker.toString())
                  return;
                if (controller.hoverMarker?.toString() == sMarker.toString()) {
                  controller.setHoverMarker(null);
                }
              },
              onHover: (event) {
                if (isOverlapPriorityE) {
                  if (controller.hoverMarker?.toString() ==
                      sMarker.toString()) {
                    controller.setHoverMarker(null);
                  }
                  return;
                }
                final localDx = event.localPosition.dx;
                if ((localDx - centerX).abs() <=
                    ManageAudioSubtitleEditorController.markerSnapTolPx) {
                  controller.setHoverMarker(sMarker);
                } else {
                  if (controller.hoverMarker?.toString() ==
                      sMarker.toString()) {
                    controller.setHoverMarker(null);
                  }
                }
              },
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (event) {
                  if (isOverlapPriorityE) return;
                  if ((event.localPosition.dx - centerX).abs() <=
                      ManageAudioSubtitleEditorController.markerSnapTolPx) {
                    controller.setHoverMarker(sMarker);
                    controller.beginDragMarker(sMarker);
                  }
                },
                onPointerMove: (event) {
                  if (event.buttons == 0) return;
                  if (controller.dragMarker?.toString() != sMarker.toString())
                    return;
                  RenderBox box = context.findRenderObject() as RenderBox;
                  Offset local = box.globalToLocal(event.position);
                  final double scrollOffset =
                      controller.scrollController.hasClients
                          ? controller.scrollController.offset
                          : 0.0;
                  final double contentDx = scrollOffset + local.dx - 20.wMin;
                  controller.onDialogueDrag(index, true, contentDx, width);
                },
                onPointerUp: (event) {
                  if (controller.dragMarker?.toString() == sMarker.toString()) {
                    controller.endDragMarker();
                    controller.onDialogueDragEnd(index, isStart: true);
                  }
                },
                child: SizedBox(
                  width: markerHitWidth,
                  height: controller.totalHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                          child: Container(color: Colors.transparent)),
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
                        height: (controller.totalHeight - 12.wMin)
                            .clamp(0.0, double.infinity),
                        child: Container(color: sColor),
                      ),
                      if (sActive) ...[
                        Positioned(
                          top: 12.wMin + 2.wMin,
                          left: centerX - 6.wMin - 2.wMin,
                          child: _buildClampTriangle(
                              color: AppTheme.cFeedbackSuccessText, isLeft: true),
                        ),
                        Positioned(
                          top: 12.wMin + 2.wMin,
                          left: centerX + 2.wMin,
                          child: _buildClampTriangle(
                              color: AppTheme.cFeedbackSuccessText, isLeft: false),
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
            left: controller.minDistance / 2 + subWidth - centerX,
            child: MouseRegion(
              cursor: eActive
                  ? SystemMouseCursors.grabbing
                  : (eHovering
                      ? SystemMouseCursors.resizeLeftRight
                      : SystemMouseCursors.basic),
              onExit: (_) {
                if (controller.dragMarker?.toString() == eMarker.toString())
                  return;
                if (controller.hoverMarker?.toString() == eMarker.toString()) {
                  controller.setHoverMarker(null);
                }
              },
              onHover: (event) {
                final localDx = event.localPosition.dx;
                if ((localDx - centerX).abs() <=
                    ManageAudioSubtitleEditorController.markerSnapTolPx) {
                  controller.setHoverMarker(eMarker);
                } else {
                  if (controller.hoverMarker?.toString() ==
                      eMarker.toString()) {
                    controller.setHoverMarker(null);
                  }
                }
              },
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (event) {
                  if ((event.localPosition.dx - centerX).abs() <=
                      ManageAudioSubtitleEditorController.markerSnapTolPx) {
                    controller.setHoverMarker(eMarker);
                    controller.beginDragMarker(eMarker);
                  }
                },
                onPointerMove: (event) {
                  if (event.buttons == 0) return;
                  if (controller.dragMarker?.toString() != eMarker.toString())
                    return;
                  RenderBox box = context.findRenderObject() as RenderBox;
                  Offset local = box.globalToLocal(event.position);
                  final double scrollOffset =
                      controller.scrollController.hasClients
                          ? controller.scrollController.offset
                          : 0.0;
                  final double contentDx = scrollOffset + local.dx - 20.wMin;
                  controller.onDialogueDrag(index, false, contentDx, width);
                },
                onPointerUp: (event) {
                  if (controller.dragMarker?.toString() == eMarker.toString()) {
                    controller.endDragMarker();
                    controller.onDialogueDragEnd(index, isStart: false);
                  }
                },
                child: SizedBox(
                  width: markerHitWidth,
                  height: controller.totalHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                          child: Container(color: Colors.transparent)),
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
                        height: (controller.totalHeight - 12.wMin)
                            .clamp(0.0, double.infinity),
                        child: Container(color: eColor),
                      ),
                      if (eActive) ...[
                        Positioned(
                          top: 12.wMin + 2.wMin,
                          left: centerX - 6.wMin - 2.wMin,
                          child: _buildClampTriangle(
                              color: const Color(0xffEF4444), isLeft: true),
                        ),
                        Positioned(
                          top: 12.wMin + 2.wMin,
                          left: centerX + 2.wMin,
                          child: _buildClampTriangle(
                              color: const Color(0xffEF4444), isLeft: false),
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

  List<Widget> _buildKTagsWidget(
      double width, context, int displayStartMs, int displayDurationMs) {
    if (controller.editDialogueIndex == null) return [];

    List<Widget> kTagWidgets = [];
    DialogueModel dialogueModel =
        controller.dialogueList[controller.editDialogueIndex!];
    if (dialogueModel.kTagList == null || dialogueModel.kTagList!.isEmpty) {
      return kTagWidgets;
    }

    final List<KTagModel> kTagList = dialogueModel.kTagList!;
    final int n = kTagList.length;
    final double denom =
        displayDurationMs <= 0 ? 1.0 : displayDurationMs.toDouble();
    final double defaultHalf = 16.wMin;

    final List<double> xPos = List.generate(n, (i) {
      return (((kTagList[i].startTime ?? 0) - displayStartMs) / denom)
              .clamp(0.0, 1.0) *
          width;
    });

    for (var i = 0; i < n; i++) {
      final double halfLeft = i > 0
          ? ((xPos[i] - xPos[i - 1]) / 2.0).clamp(0.0, defaultHalf)
          : defaultHalf;
      final double halfRight = i < n - 1
          ? ((xPos[i + 1] - xPos[i]) / 2.0).clamp(0.0, defaultHalf)
          : defaultHalf;
      kTagWidgets.add(_buildKTagWidget(
        i,
        controller.editDialogueIndex!,
        width,
        context,
        displayStartMs,
        displayDurationMs,
        hitZoneLeft: xPos[i] - halfLeft,
        hitZoneRight: xPos[i] + halfRight,
      ));
    }
    return kTagWidgets;
  }

}
