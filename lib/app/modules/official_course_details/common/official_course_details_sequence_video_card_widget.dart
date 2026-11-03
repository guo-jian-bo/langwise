import 'dart:io';

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
  bool _isVideoPlaying = false;

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
    if (shouldStopPreviousPlayback && _isVideoPlaying) {
      setState(() {
        _isVideoPlaying = false;
      });
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

  Future<void> _handlePosterTap() async {
    await widget.onBeforePlay?.call();
    _startPlaybackOnce();
  }

  String _buildPosterUrl() {
    final String imageUrl = widget.imageUrl?.trim() ?? '';
    if (imageUrl.isNotEmpty) return imageUrl;
    if (_hasVideo) {
      final String firstFrame = widget.relationVideo?.firstFrameUrl?.trim() ?? '';
      if (firstFrame.isNotEmpty) return firstFrame;
      final String firstImage = widget.relationVideo?.firstImageUrl?.trim() ?? '';
      if (firstImage.isNotEmpty) return firstImage;
    }
    return widget.relationVideo?.firstImageUrl?.trim() ?? widget.relationVideo?.firstFrameUrl?.trim() ?? '';
  }

  File? _resolveLocalPosterFile(String path) {
    final String normalizedPath = path.trim();
    if (normalizedPath.isEmpty) return null;
    if (normalizedPath.startsWith('/') ||
        RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(normalizedPath) ||
        normalizedPath.startsWith(r'\\')) {
      return File(normalizedPath);
    }
    final Uri? uri = Uri.tryParse(normalizedPath);
    if (uri?.scheme == 'file') {
      return File.fromUri(uri!);
    }
    return null;
  }

  Widget _buildPosterWidget(String posterUrl) {
    final File? localPosterFile = _resolveLocalPosterFile(posterUrl);
    if (localPosterFile != null) {
      return Image.file(
        localPosterFile,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.expand(),
      );
    }
    return CachedImageWidget(
      posterUrl,
      fit: BoxFit.cover,
      placeholder: const ColoredBox(color: Colors.transparent),
      errorWidget: const SizedBox.expand(),
    );
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
            Stack(
              fit: StackFit.expand,
              children: [
                IgnorePointer(
                  ignoring: !_isVideoPlaying,
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
                    onPlayingChanged: (playing) {
                      if (!mounted || _isVideoPlaying == playing) return;
                      setState(() {
                        _isVideoPlaying = playing;
                      });
                    },
                    onFinished: (reason) {
                      if (_isVideoPlaying && mounted) {
                        setState(() {
                          _isVideoPlaying = false;
                        });
                      }
                      widget.onFinished?.call(reason);
                    },
                    onBeforeExpand: () async {
                      await widget.onBeforePlay?.call();
                      await _videoController.stopAndReset();
                      if (_isVideoPlaying && mounted) {
                        setState(() {
                          _isVideoPlaying = false;
                        });
                      }
                      return true;
                    },
                    enableInternalTapToPlay: true,
                    hideCenterPlayButtonUntilFirstPlay: false,
                    showCenterPlayButton: true,
                  ),
                ),
                if (!_isVideoPlaying)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        unawaited(_handlePosterTap());
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildPosterWidget(posterUrl),
                          Center(
                            child: Container(
                              width: 80.wMin,
                              height: 80.wMin,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 50.wMin,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            )
          else
            _buildPosterWidget(posterUrl),
        ],
      ),
    );
  }
}
