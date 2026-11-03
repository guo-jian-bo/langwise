
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../theme/theme.dart';
import '../../utils/utils.dart';
import 'widgets.dart';

class PlayVideoWidget extends StatefulWidget {
  /// 视频网络路径
  final String? videoUrl;

  /// 默认封面图路径
  final String? imageUrl;

  const PlayVideoWidget({
    super.key,
    required this.videoUrl,
    this.imageUrl,
  });

  @override
  State<PlayVideoWidget> createState() => _PlayVideoWidgetState();
}

class _PlayVideoWidgetState extends State<PlayVideoWidget> {
  String? _videoCachePath;

  Player? _player;
  VideoController? _videoController;

  StreamSubscription<bool>? _playingSubscription;
  StreamSubscription<bool>? _completedSubscription;
  StreamSubscription<Duration>? _positionSubscription;

  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasFirstFrame = false;
  bool _isVideoMounted = false;
  bool _isMediaOpened = false;
  bool _isDisposed = false;

  bool get _hasVideo => (widget.videoUrl ?? '').trim().isNotEmpty;

  String get _playId {
    final String videoUrl = widget.videoUrl?.trim() ?? '';
    if (videoUrl.isNotEmpty) return videoUrl;
    return widget.key?.toString() ?? hashCode.toString();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PlayVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl == widget.videoUrl && oldWidget.imageUrl == widget.imageUrl) {
      return;
    }

    final String oldId = oldWidget.videoUrl?.trim() ?? '';
    if (oldId.isNotEmpty) {
      PlayVideoManager.instance.unregister(oldId);
    }

    _videoCachePath = null;
    unawaited(_resetToPoster(shouldUnregister: false));

  }

  @override
  void dispose() {
    _isDisposed = true;
    PlayVideoManager.instance.unregister(_playId);
    unawaited(_resetToPoster(shouldUnregister: false, shouldNotify: false));
    super.dispose();
  }


  /// 点击播放后先把视频组件挂进树里，避免后续 open 时出现空白切换。
  Future<void> _ensureVideoWidgetMounted() async {
    if (_player != null) return;

    final Player player = Player();
    final VideoController controller = VideoController(player);

    _player = player;
    _videoController = controller;
    _isVideoMounted = true;

    await _playingSubscription?.cancel();
    _playingSubscription = player.stream.playing.listen((playing) {
      if (_player != player) return;
      _isPlaying = playing;
      if (!playing && !_hasFirstFrame) {
        _isLoading = false;
      }
      _safeSetState();
    });

    await _completedSubscription?.cancel();
    _completedSubscription = player.stream.completed.listen((completed) {
      if (_player != player || !completed) return;
      unawaited(_resetToPoster());
    });

    await _positionSubscription?.cancel();
    _positionSubscription = player.stream.position.listen((position) {
      if (_player != player) return;
      if (position <= Duration.zero) return;

      // 进度大于 0 说明首帧已经出来，可以把封面和 loading 一起隐藏。
      _hasFirstFrame = true;
      _isLoading = false;
      _safeSetState();
    });

    _safeSetState();
  }

  Future<void> _ensureMediaOpened() async {
    await _ensureVideoWidgetMounted();
    if (_player == null || _videoCachePath == null || _isMediaOpened) return;

    await _player!.open(Media(_videoCachePath!), play: false);
    _isMediaOpened = true;
  }

  Future<void> _handlePlayTap() async {
    if (!_hasVideo || _isLoading || _isPlaying) return;

    _isLoading = true;
    _hasFirstFrame = false;
    _safeSetState();

    await PlayVideoManager.instance.requestPlay(
      id: _playId,
      stopPrevious: () => _resetToPoster(shouldUnregister: false),
    );

    if (_isDisposed || !PlayVideoManager.instance.isCurrent(_playId)) {
      await _resetToPoster(shouldUnregister: false);
      return;
    }

    await _ensureVideoWidgetMounted();

    _videoCachePath ??= await CacheManagerUtils.instance.getFile(
      widget.videoUrl,
      ResourceType.video,
    );

    if (_isDisposed || !PlayVideoManager.instance.isCurrent(_playId)) {
      await _resetToPoster(shouldUnregister: false);
      return;
    }

    if (_videoCachePath == null) {
      await _resetToPoster();
      return;
    }

    if (_videoCachePath == null || !PlayVideoManager.instance.isCurrent(_playId)) {
      await _resetToPoster(shouldUnregister: false);
      return;
    }

    try {
      await _ensureMediaOpened();
      if (_isDisposed || !PlayVideoManager.instance.isCurrent(_playId)) {
        await _resetToPoster(shouldUnregister: false);
        return;
      }
      await _player?.play();
    } catch (_) {
      await _resetToPoster();
    }
  }

  Future<void> _handleVisibilityChanged(VisibilityInfo info) async {
    if (info.visibleFraction > 0) return;
    await _resetToPoster();
  }

  /// 统一回到初始态：
  /// 1. 停止播放并释放播放器
  /// 2. 隐藏视频组件
  /// 3. 恢复封面图和播放按钮
  Future<void> _resetToPoster({
    bool shouldUnregister = true,
    bool shouldNotify = true,
  }) async {
    final Player? currentPlayer = _player;
    final StreamSubscription<bool>? currentPlayingSubscription = _playingSubscription;
    final StreamSubscription<bool>? currentCompletedSubscription = _completedSubscription;
    final StreamSubscription<Duration>? currentPositionSubscription = _positionSubscription;

    _player = null;
    _videoController = null;
    _playingSubscription = null;
    _completedSubscription = null;
    _positionSubscription = null;
    _isPlaying = false;
    _isLoading = false;
    _hasFirstFrame = false;
    _isVideoMounted = false;
    _isMediaOpened = false;

    if (shouldUnregister) {
      PlayVideoManager.instance.unregister(_playId);
    }

    if (shouldNotify) {
      _safeSetState();
    }

    await currentPlayingSubscription?.cancel();
    await currentCompletedSubscription?.cancel();
    await currentPositionSubscription?.cancel();

    if (currentPlayer == null) return;

    try {
      await currentPlayer.pause();
      await currentPlayer.seek(Duration.zero);
    } catch (_) {}

    await currentPlayer.dispose();
  }

  void _safeSetState() {
    if (!mounted || _isDisposed) return;
    setState(() {});
  }

  Widget _buildPoster() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: !_hasVideo ? null : (){},
        child: CachedImageWidget(
          widget.imageUrl ?? "",
          alignment: Alignment.topCenter,
          errorWidget: buildEmptyWidget(fit: BoxFit.cover),
          placeholder: buildEmptyWidget(fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return TapScaleWidget(
      onTap: () async {
        await _handlePlayTap();
      },
      sclae: 1,
      child: Container(
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Container(
          width: 80.wMin,
          height: 80.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.92),
              width: 1.wMin,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
              ),
            ],
          ),
          child: Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 40.wMin,
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return GestureDetector(
      onTap: (){},
      child: Container(
        alignment: Alignment.center,
        color: Colors.black.withValues(alpha: 0.12),
        child: SpinKitFadingCircle(
          color: AppTheme.cBgBrand,
          size: 100.wMin,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showPoster = !_hasFirstFrame;
    final bool showPlayButton = _hasVideo && !_isLoading && !_isPlaying;
    final Widget content = Stack(
      children: [
        if (_isVideoMounted && _videoController != null)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: Video(
                controller: _videoController!,
                fill: AppTheme.cSurfaceTertiary.color,
                controls: (_) => Container(),
              ),
            ),
          ),
        if (showPoster) _buildPoster(),
        if (showPlayButton) _buildPlayButton(),
        if (_isLoading) _buildLoading(),
      ],
    );

    return VisibilityDetector(
      key: ValueKey('play_video_widget_$_playId'),
      onVisibilityChanged: (info) {
        unawaited(_handleVisibilityChanged(info));
      },
      child: _hasVideo
          ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: content,
            )
          : content,
    );
  }
}

class PlayVideoManager {
  PlayVideoManager._();

  static final PlayVideoManager instance = PlayVideoManager._();

  String? _currentId;
  Future<void> Function()? _stopCurrent;

  Future<void> requestPlay({
    required String id,
    required Future<void> Function() stopPrevious,
  }) async {
    if (_currentId != null && _currentId != id) {
      await _stopCurrent?.call();
    }
    _currentId = id;
    _stopCurrent = stopPrevious;
  }

  void unregister(String id) {
    if (_currentId != id) return;
    _currentId = null;
    _stopCurrent = null;
  }

  bool isCurrent(String id) {
    return _currentId == id;
  }
}
