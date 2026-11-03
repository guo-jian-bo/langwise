part of 'manage_audio_subtitle_editor_view.dart';

class _DownTrianglePainter extends CustomPainter {
  _DownTrianglePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DownTrianglePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ClampTrianglePainter extends CustomPainter {
  _ClampTrianglePainter({required this.color, required this.isLeft});

  final Color color;
  final bool isLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    if (isLeft) {
      path
        ..moveTo(size.width, 0)
        ..lineTo(0, size.height / 2)
        ..lineTo(size.width, size.height)
        ..close();
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, size.height / 2)
        ..lineTo(0, size.height)
        ..close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ClampTrianglePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isLeft != isLeft;
  }
}

class _NoDefaultScrollbarScrollBehavior extends ScrollBehavior {
  const _NoDefaultScrollbarScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const <PointerDeviceKind>{};

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

extension ViewWaveformKTagMixin on ManageAudioSubtitleEditorView {
  Widget _buildKTagWidget(int kTagIndex, int dialogueIndex, double width,
      context, int displayStartMs, int displayDurationMs,
      {isLast = false, double? hitZoneLeft, double? hitZoneRight}) {
    DialogueModel dialogueModel = controller.dialogueList[dialogueIndex];
    KTagModel kTagModel = dialogueModel.kTagList![kTagIndex];

    final double markerHitWidth = 32.wMin;
    final double centerX = markerHitWidth / 2;
    final Map<String, dynamic> kMarker = <String, dynamic>{
      'type': 'ktag',
      'dialogueIndex': dialogueIndex,
      'kTagIndex': kTagIndex,
      'isLast': isLast == true,
    };
    final bool kActive =
        (controller.dragMarker ?? controller.hoverMarker)?.toString() ==
            kMarker.toString();
    final bool kHovering =
        controller.hoverMarker?.toString() == kMarker.toString();
    final bool kDragging =
        controller.dragMarker?.toString() == kMarker.toString();

    final Color kColor =
        kActive ? const Color(0xffEA580C) : AppTheme.cSurfaceWarning;
    final double kLineW = kDragging ? 3.wMin : (kActive ? 2.wMin : 1.wMin);

    if (isLast) {
      return Positioned(
        left: (((((kTagModel.startTime ?? 0) + (kTagModel.duration ?? 0)) -
                            displayStartMs) /
                        (displayDurationMs <= 0 ? 1 : displayDurationMs))
                    .clamp(0.0, 1.0) *
                width) +
            20.wMin -
            centerX,
        top: (controller.totalHeight - controller.subHeight) / 2,
        child: MouseRegion(
          cursor: kActive
              ? SystemMouseCursors.grabbing
              : (kHovering
                  ? SystemMouseCursors.resizeLeftRight
                  : SystemMouseCursors.basic),
          onExit: (_) {
            if ((controller.dragMarker ?? controller.hoverMarker)?.toString() ==
                kMarker.toString()) {
              controller.setHoverMarker(null);
            }
          },
          onHover: (event) {
            final localDx = event.localPosition.dx;
            if ((localDx - centerX).abs() <=
                ManageAudioSubtitleEditorController.markerSnapTolPx) {
              controller.setHoverMarker(kMarker);
            } else {
              if (controller.hoverMarker?.toString() == kMarker.toString()) {
                controller.setHoverMarker(null);
              }
            }
          },
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) {
              RenderBox box = context.findRenderObject() as RenderBox;
              final local = box.globalToLocal(event.position);
              final double scrollOffset = controller.scrollController.hasClients
                  ? controller.scrollController.offset
                  : 0.0;
              final double contentDx = scrollOffset + local.dx - 20.wMin;
              controller.onKTagPointerDown(dialogueIndex, kTagIndex, contentDx,
                  isLast: true);
              controller.beginDragMarker(kMarker);
            },
            onPointerMove: (event) {
              if (event.buttons == 0) return;
              if (controller.dragMarker?.toString() != kMarker.toString())
                return;
              RenderBox box = context.findRenderObject() as RenderBox;
              Offset local = box.globalToLocal(event.position);
              final double scrollOffset = controller.scrollController.hasClients
                  ? controller.scrollController.offset
                  : 0.0;
              final double contentDx = scrollOffset + local.dx - 20.wMin;
              controller.onDragKTag(
                dialogueIndex,
                kTagIndex,
                contentDx,
                width,
                isLast: true,
                displayStartMs: displayStartMs,
                displayDurationMs: displayDurationMs,
              );
            },
            onPointerUp: (event) {
              RenderBox box = context.findRenderObject() as RenderBox;
              final local = box.globalToLocal(event.position);
              final double scrollOffset = controller.scrollController.hasClients
                  ? controller.scrollController.offset
                  : 0.0;
              final double contentDx = scrollOffset + local.dx - 20.wMin;
              final bool wasDragging =
                  controller.dragMarker?.toString() == kMarker.toString();
              if (wasDragging) {
                controller.endDragMarker();
              }
              if (controller.isKTagTap(dialogueIndex, kTagIndex, contentDx,
                  isLast: true)) {
                controller.playFromKTagToNext(dialogueIndex, kTagIndex);
                return;
              }
              if (wasDragging) {
                controller.onKTagDragEnd(dialogueIndex, kTagIndex);
              }
            },
            child: SizedBox(
              width: markerHitWidth,
              height: controller.subHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(child: Container(color: Colors.transparent)),
                  Positioned(
                    top: 0,
                    left: centerX - (5.wMin / 2),
                    width: 5.wMin,
                    height: 12.wMin,
                    child: Container(color: kColor),
                  ),
                  Positioned(
                    top: 12.wMin,
                    left: centerX - (kLineW / 2),
                    width: kLineW,
                    height: (controller.subHeight - 12.wMin)
                        .clamp(0.0, double.infinity),
                    child: Container(color: kColor),
                  ),
                  if (kActive) ...[
                    Positioned(
                      top: 12.wMin + 2.wMin,
                      left: centerX - 6.wMin - 2.wMin,
                      child: _buildClampTriangle(color: kColor, isLeft: true),
                    ),
                    Positioned(
                      top: 12.wMin + 2.wMin,
                      left: centerX + 2.wMin,
                      child: _buildClampTriangle(color: kColor, isLeft: false),
                    ),
                  ],
                  Positioned(
                    top: 12.wMin + 2.wMin,
                    left: markerHitWidth + 3.wMin,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(0, 0, 0, 0.20),
                        borderRadius: BorderRadius.circular(4.wMin),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.wMin, vertical: 2.wMin),
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
    final double denom =
        displayDurationMs <= 0 ? 1.0 : displayDurationMs.toDouble();
    final double xPos =
        (((kTagModel.startTime ?? 0) - displayStartMs) / denom)
                .clamp(0.0, 1.0) *
            width;
    final double zoneL = hitZoneLeft ?? (xPos - centerX);
    final double zoneR = hitZoneRight ?? (xPos + centerX);
    final double zoneW = (zoneR - zoneL).clamp(1.0, double.infinity);
    final double lineX = xPos - zoneL;

    return Positioned(
      left: zoneL + 20.wMin,
      top: (controller.totalHeight - controller.subHeight) / 2,
      child: MouseRegion(
        cursor: kActive
            ? SystemMouseCursors.grabbing
            : (kHovering
                ? SystemMouseCursors.resizeLeftRight
                : SystemMouseCursors.basic),
        onExit: (_) {
          if ((controller.dragMarker ?? controller.hoverMarker)?.toString() ==
              kMarker.toString()) {
            controller.setHoverMarker(null);
          }
        },
        onHover: (_) {
          controller.setHoverMarker(kMarker);
        },
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) {
            RenderBox box = context.findRenderObject() as RenderBox;
            final local = box.globalToLocal(event.position);
            final double scrollOffset = controller.scrollController.hasClients
                ? controller.scrollController.offset
                : 0.0;
            final double contentDx = scrollOffset + local.dx - 20.wMin;
            controller.onKTagPointerDown(dialogueIndex, kTagIndex, contentDx,
                isLast: false);
            controller.beginDragMarker(kMarker);
          },
          onPointerMove: (event) {
            if (event.buttons == 0) return;
            if (controller.dragMarker?.toString() != kMarker.toString()) return;
            RenderBox box = context.findRenderObject() as RenderBox;
            Offset local = box.globalToLocal(event.position);
            final double scrollOffset = controller.scrollController.hasClients
                ? controller.scrollController.offset
                : 0.0;
            final double contentDx = scrollOffset + local.dx - 20.wMin;
            controller.onDragKTag(
              dialogueIndex,
              kTagIndex,
              contentDx,
              width,
              displayStartMs: displayStartMs,
              displayDurationMs: displayDurationMs,
            );
          },
          onPointerUp: (event) {
            RenderBox box = context.findRenderObject() as RenderBox;
            final local = box.globalToLocal(event.position);
            final double scrollOffset = controller.scrollController.hasClients
                ? controller.scrollController.offset
                : 0.0;
            final double contentDx = scrollOffset + local.dx - 20.wMin;
            final bool wasDragging =
                controller.dragMarker?.toString() == kMarker.toString();
            if (wasDragging) {
              controller.endDragMarker();
            }
            if (controller.isKTagTap(dialogueIndex, kTagIndex, contentDx,
                isLast: false)) {
              controller.playFromKTagToNext(dialogueIndex, kTagIndex);
              return;
            }
            if (wasDragging) {
              controller.onKTagDragEnd(dialogueIndex, kTagIndex);
            }
          },
          child: SizedBox(
            width: zoneW,
            height: controller.subHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
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
                  height: (controller.subHeight - 12.wMin)
                      .clamp(0.0, double.infinity),
                  child: Container(color: kColor),
                ),
                if (kActive) ...[
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
                        horizontal: 6.wMin, vertical: 2.wMin),
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
}
