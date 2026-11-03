import 'dart:async';

import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/cached_image_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

class OfficialCourseDetailsSequenceVideoCardWidget extends StatefulWidget {
  final String? imageUrl;
  final EnKnowledgeEntityRelationVideo? relationVideo;
  final String semanticPlaybackKey;
  final bool isActive;
  final double? size;
  final bool autoPlayOnce;
  final double playbackRate;
  final SequenceTipsVideoWidgetController? videoController;
  final FutureOr<void> Function()? onCompleted;
  final ValueChanged<SequenceTipsVideoFinishReason>? onFinished;
  final FutureOr<void> Function()? onBeforePlay;

  const OfficialCourseDetailsSequenceVideoCardWidget({
    super.key,
    this.imageUrl,
    this.relationVideo,
    required this.semanticPlaybackKey,
    this.isActive = true,
    this.size,
    this.autoPlayOnce = false,
    this.playbackRate = 1.0,
    this.videoController,
    this.onCompleted,
    this.onFinished,
    this.onBeforePlay,
  });

  @override
  State<OfficialCourseDetailsSequenceVideoCardWidget> createState() => _OfficialCourseDetailsSequenceVideoCardWidgetState();
}

class _OfficialCourseDetailsSequenceVideoCardWidgetState extends State<OfficialCourseDetailsSequenceVideoCardWidget> {
  final SequenceTipsVideoWidgetController _fallbackVideoController = SequenceTipsVideoWidgetController();

  SequenceTipsVideoWidgetController get _videoController => widget.videoController ?? _fallbackVideoController;
  bool get _usesExternalVideoController => widget.videoController != null;
  bool get _hasVideo => (widget.relationVideo?.videoUrl ?? '').trim().isNotEmpty;

  @override
  void didUpdateWidget(
    covariant OfficialCourseDetailsSequenceVideoCardWidget oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    final bool playbackSourceChanged = oldWidget.semanticPlaybackKey != widget.semanticPlaybackKey ||
        oldWidget.relationVideo?.videoUrl != widget.relationVideo?.videoUrl ||
        oldWidget.relationVideo?.startSeconds != widget.relationVideo?.startSeconds ||
        oldWidget.relationVideo?.endSeconds != widget.relationVideo?.endSeconds;
    final bool shouldStopPreviousPlayback = (oldWidget.isActive && !widget.isActive) || playbackSourceChanged;

    if (shouldStopPreviousPlayback && !_usesExternalVideoController) {
      unawaited(_videoController.stopAndReset());
    }
    if (widget.autoPlayOnce && ((!oldWidget.isActive && widget.isActive) || (playbackSourceChanged && widget.isActive)) && _hasVideo) {
      _startPlaybackOnce();
    }
    if (oldWidget.playbackRate != widget.playbackRate && _hasVideo) {
      unawaited(_videoController.setPlaybackRate(widget.playbackRate));
    }
  }

  @override
  void dispose() {
    if (!_usesExternalVideoController) {
      unawaited(_videoController.stopAndReset());
      unawaited(_videoController.release());
    }
    super.dispose();
  }

  void _startPlaybackOnce() {
    unawaited(_videoController.setPlaybackRate(widget.playbackRate));
    unawaited(
      _videoController.playOnce(
        muted: widget.relationVideo?.isMute ?? false,
      ),
    );
  }

  String _buildPosterUrl() {
    if (_hasVideo) {
      final String firstFrame = widget.relationVideo?.firstFrameUrl?.trim() ?? '';
      if (firstFrame.isNotEmpty) return firstFrame;
      final String firstImage = widget.relationVideo?.firstImageUrl?.trim() ?? '';
      if (firstImage.isNotEmpty) return firstImage;
    }
    final String imageUrl = widget.imageUrl?.trim() ?? '';
    if (imageUrl.isNotEmpty) return imageUrl;
    return widget.relationVideo?.firstImageUrl?.trim() ?? widget.relationVideo?.firstFrameUrl?.trim() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size ?? 640.wMin;
    final String posterUrl = _buildPosterUrl();
    final BorderRadius borderRadius = BorderRadius.circular(20.wMin);
    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: AppTheme.cBlackAlpha10.color),
          if (_hasVideo)
            Listener(
              onPointerDown: (_) {
                unawaited(Future.sync(() => widget.onBeforePlay?.call()));
              },
              child: SequenceTipsVideoWidget(
                key: ValueKey<String>(widget.semanticPlaybackKey),
                controller: _videoController,
                posterPath: posterUrl,
                videoPath: widget.relationVideo?.videoUrl ?? '',
                width: size,
                height: size,
                borderRadius: 20.wMin,
                showLight: false,
                showExpandButton: true,
                autoPlayOnce: widget.autoPlayOnce && widget.isActive,
                autoPlayMuted: widget.relationVideo?.isMute ?? false,
                startSeconds: widget.relationVideo?.startSeconds,
                endSeconds: widget.relationVideo?.endSeconds,
                playbackRate: widget.playbackRate,
                onCompleted: widget.onCompleted,
                onFinished: widget.onFinished,
                onBeforeExpand: () async {
                  await widget.onBeforePlay?.call();
                  await _videoController.stopAndReset();
                  return true;
                },
                enableInternalTapToPlay: true,
                hideCenterPlayButtonUntilFirstPlay: false,
                showCenterPlayButton: true,
              ),
            )
          else
            CachedImageWidget(
              posterUrl,
              fit: BoxFit.cover,
              placeholder: const ColoredBox(color: Colors.transparent),
              errorWidget: const SizedBox.expand(),
            ),
        ],
      ),
    );
  }
}
