import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/play_audio_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';

class ElementsInlineVideoPlaybackCoordinator {
  ElementsInlineVideoPlaybackCoordinator._();

  static _ElementsInlineVideoWidgetState? _currentPlayingState;

  static void stopCurrent() {
    _stopCurrentExcept();
  }

  static void _stopCurrentExcept([_ElementsInlineVideoWidgetState? except]) {
    final _ElementsInlineVideoWidgetState? currentPlayingState =
        _currentPlayingState;
    if (currentPlayingState == null || identical(currentPlayingState, except)) return;
    currentPlayingState._resetToPoster();
  }

  static void _setCurrent(_ElementsInlineVideoWidgetState state) {
    _currentPlayingState = state;
  }

  static void _clearCurrent(_ElementsInlineVideoWidgetState state) {
    if (identical(_currentPlayingState, state)) {
      _currentPlayingState = null;
    }
  }
}

class ElementsCardMediaWidget extends StatelessWidget {
  final ElementsCardEntityDatas? data;
  final Widget? fallbackChild;
  final bool disableImagePreview;

  const ElementsCardMediaWidget({
    super.key,
    this.data,
    this.fallbackChild,
    this.disableImagePreview = false,
  });

  ConfigController get _configController => Get.find<ConfigController>();

  bool get _hasPlayableVideo => data?.video?.videoUrl?.trim().isNotEmpty ?? false;

  String get _coverUrl {
    final bool useVideoCover = _configController.currentShowResource.value == ResourceTypeEnum.video && _hasPlayableVideo;
    final String firstFrameUrl = data?.video?.firstFrameUrl?.trim() ?? "";
    if (useVideoCover && firstFrameUrl.isNotEmpty) return firstFrameUrl;
    return data?.imageUrl?.trim() ?? firstFrameUrl;
  }

  Future<void> _showImageDialog(BuildContext context, String imageUrl) async {
    if (imageUrl.trim().isEmpty) return;
    await ShowBigResourceDialog.showImage(
      context: context,
      imageUrls: [imageUrl],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final String imageUrl = _coverUrl;
      final bool showVideo = _configController.currentShowResource.value == ResourceTypeEnum.video && _hasPlayableVideo;
      final Widget baseMedia = imageUrl.isNotEmpty
          ? CachedImageWidget(
              imageUrl,
              errorWidget: buildEmptyWidget(),
              placeholder: buildLoadingWidget(),
              fadeInDuration: Duration.zero,
            )
          : (fallbackChild != null
              ? Center(child: fallbackChild!)
              : buildEmptyWidget());

      if (showVideo) {
        return _ElementsInlineVideoWidget(
          data: data,
          poster: baseMedia,
        );
      }

      if (imageUrl.isNotEmpty) {
        if (disableImagePreview) {
          return baseMedia;
        }
        return TapScaleWidget(
          onTap: () async {
            await _showImageDialog(context, imageUrl);
          },
          sclae: 1,
          child: baseMedia,
        );
      }

      return baseMedia;
    });
  }
}

class _ElementsInlineVideoWidget extends StatefulWidget {
  final ElementsCardEntityDatas? data;
  final Widget poster;

  const _ElementsInlineVideoWidget({
    required this.data,
    required this.poster,
  });

  @override
  State<_ElementsInlineVideoWidget> createState() =>
      _ElementsInlineVideoWidgetState();
}

class _ElementsInlineVideoWidgetState extends State<_ElementsInlineVideoWidget> {
  final VideoPlayeController _videoController = VideoPlayeController();

  /// 当前播放会话标记，用于丢弃已经过期的异步回调。
  int _playSessionId = 0;

  /// 是否正处于点击播放后的资源准备阶段。
  bool _isLoading = false;

  /// 是否已经把播放器挂进当前卡片区域。
  bool _showPlayer = false;

  /// 当前卡片视频的原始网络地址。
  String get _videoUrl => widget.data?.video?.videoUrl?.trim() ?? '';

  /// 当前片段的起始时间。
  Duration get _clipStartDuration =>
      _secondsToDuration(widget.data?.video?.startSeconds ?? 0);

  /// 当前片段的结束时间，并对异常区间做边界收敛。
  Duration? get _clipEndDuration {
    final Duration rawDuration =
        _secondsToDuration(widget.data?.video?.duration ?? 0);
    Duration endDuration = widget.data?.video?.endSeconds == null
        ? rawDuration
        : _secondsToDuration(widget.data?.video?.endSeconds ?? 0);
    if (endDuration <= Duration.zero) return null;
    if (endDuration < _clipStartDuration) {
      return _clipStartDuration;
    }
    if (rawDuration != Duration.zero && endDuration > rawDuration) {
      return rawDuration;
    }
    return endDuration;
  }

  /// 将后端返回的秒数转换成播放器需要的 Duration。
  Duration _secondsToDuration(double seconds) {
    return Duration(milliseconds: (seconds * 1000).round());
  }

  /// 点击播放后准备资源，并切到卡片内播放器。
  Future<void> _startPlay() async {
    if (_videoUrl.isEmpty) return;

    await PlaybackInterlockUtils.instance.stopAllAudio();
    ElementsInlineVideoPlaybackCoordinator._stopCurrentExcept(this);
    ElementsInlineVideoPlaybackCoordinator._setCurrent(this);

    // if (_isLoading || _showPlayer || _videoUrl.isEmpty) return;

    // _playSessionId++;
    _isLoading = true;
    if (mounted) setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isLoading || _showPlayer) return;
      _showPlayer = true;
      setState(() {});
    });
  }

  /// 将卡片媒体区恢复到播放前的封面初始态。
  void _resetToPoster() {
    _playSessionId++;
    ElementsInlineVideoPlaybackCoordinator._clearCurrent(this);
    _isLoading = true;
    if (mounted) setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_showPlayer) return;
      _showPlayer = false;
      _isLoading = false;
      setState(() {});
    });
  }

  @override
  void dispose() {
    ElementsInlineVideoPlaybackCoordinator._clearCurrent(this);
    super.dispose();
  }

  /// 播放器 ready 后补充静音和播放列表模式设置。
  Future<void> _handleVideoReady(int sessionId) async {
    if (!mounted || sessionId != _playSessionId) return;
    if (widget.data?.video?.isMute == true) {
      await _videoController.setVolume(0);
    }
    await _videoController.setPlaylistMode(PlaylistMode.none);
  }

  /// 同步播放器状态，用于结束 loading 和处理播完回退。
  void _handleVideoInfoChange(dynamic info, int sessionId) {
    if (!mounted || sessionId != _playSessionId) return;
    if (info.completed) {
      _resetToPoster();
      return;
    }

    final bool hasFirstFrame = info.positionDuration > Duration.zero ||
        (_clipStartDuration > Duration.zero &&
            info.positionDuration >= _clipStartDuration);
    if (!hasFirstFrame || !_isLoading) return;
    _isLoading = false;
    if (mounted) setState(() {});
  }

  /// 构建卡片中央的播放按钮。
  Widget _buildPlayButton() {
    return Center(
      child: ClipOval(
        child: Container(
          width: 80.wMin,
          height: 80.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.cInverseTextLight.withValues(alpha: 0.03),
            border: Border.all(
              color: AppTheme.cInverseTextLight.withValues(alpha: 0.4),
              width: 1.wMin,
            ),
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            color: AppTheme.cInverseTextLight,
            size: 50.wMin,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int sessionId = _playSessionId;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: (_isLoading || _showPlayer) ? () {} : _startPlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_showPlayer)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: VideoPlayerWidget(
                  key: ValueKey<String>('elements_inline_video_$sessionId'),
                  controller: _videoController,
                  autoPlay: true,
                  loadingWidget: const SizedBox.shrink(),
                  playList: [
                    MediaModel(
                      resource: _videoUrl,
                      // start: _clipStartDuration,
                      // end: _clipEndDuration,
                    ),
                  ],
                  controls: (_) => Container(),
                  onReady: () async {
                    await _handleVideoReady(sessionId);
                  },
                  onVideoPlayInfoChange: (info) {
                    _handleVideoInfoChange(info, sessionId);
                  },
                ),
              ),
            ),
          if (!_showPlayer || _isLoading) widget.poster,
          if (!_isLoading && !_showPlayer) _buildPlayButton(),
        ],
      ),
    );
  }
}
