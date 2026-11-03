import 'dart:async';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../../../app/routes/app_pages.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../../../entities/entities.dart';
import '../../widgets.dart';
import 'model/writing_board_data.dart';

class WritVideoUploadWidget extends StatefulWidget {
  final WritingBoardMediaAnswerData? mediaData;
  final void Function(List<WritingBoardMediaItemData> items)? onItemsChanged;
  final WritingBoardModeEnum mode;

  /// 视频上传
  const WritVideoUploadWidget({
    super.key,
    this.mediaData,
    this.onItemsChanged,
    this.mode = WritingBoardModeEnum.task,
  });

  @override
  State<WritVideoUploadWidget> createState() => _WritVideoUploadWidgetState();
}

class _WritVideoUploadWidgetState extends State<WritVideoUploadWidget> {

  List<WritingBoardMediaItemData> get _items => widget.mediaData?.items ?? const <WritingBoardMediaItemData>[];
  String? _playingVideoId;
  final Map<String, Future<void> Function()> _pauseCallbacks = <String, Future<void> Function()>{};

  int get _maxCount => widget.mediaData?.maxCount ?? 0;

  bool get _isReadOnly => widget.mode.isReadOnlyMode;

  bool get _canAddMore => !_isReadOnly && (_maxCount <= 0 || _items.length < _maxCount);

  Future<void> _selectVideo() async {
    File? file = await ImagePickerUtils.selectVideo();
    if (file == null) return;
    _appendVideo(file);
  }

  Future<void> _recordVideo() async {
    File? file = await ImagePickerUtils.recordVideo(
      context: context,
      maxDuration: const Duration(seconds: 30),
    );
    if (file == null) return;
    _appendVideo(file);
  }

  void _appendVideo(File file) {
    if (!_canAddMore) return;
    final nextItems = List<WritingBoardMediaItemData>.from(_items)..add(WritingBoardMediaItemData(localPath: file.path));
    if (mounted) setState(() {});
    widget.onItemsChanged?.call(nextItems);
  }

  void _removeVideo(int index) {
    final nextItems = List<WritingBoardMediaItemData>.from(_items)..removeAt(index);
    if (mounted) setState(() {});
    widget.onItemsChanged?.call(nextItems);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24.wMin),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "交视频",
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cZhenxieFontTertiary.color,
                ),
              ),
              Text(
                "${_items.length}/${_maxCount <= 0 ? '-' : _maxCount}",
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(24.wMin),
            child: Row(
              spacing: 16.wMin,
              children: [
                ...List.generate(_items.length, _buildVideoCard),
                if (_canAddMore) _buildActionPanel(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoCard(int index) {
    final item = _items[index];
    final videoId = _mediaId(item, index);
    return _VideoPreviewCard(
      item: item,
      videoId: videoId,
      onRegisterPause: (callback) {
        _pauseCallbacks[videoId] = callback;
      },
      onUnregisterPause: () {
        _pauseCallbacks.remove(videoId);
      },
      onPlayRequested: (id) {
        for (final entry in _pauseCallbacks.entries) {
          if (entry.key == id) continue;
          unawaited(entry.value());
        }
        _playingVideoId = id;
      },
      onPauseRequested: (id) {
        if (_playingVideoId != id) return;
        _playingVideoId = null;
      },
      onDelete: _isReadOnly ? null : () => _removeVideo(index),
    );
  }

  String _mediaId(WritingBoardMediaItemData item, int index) {
    if (item.localPath?.isNotEmpty ?? false) return 'index:${index}_local:${item.localPath}';
    if (item.url?.isNotEmpty ?? false) return 'index:${index}_url:${item.url}';
    if (item.key?.isNotEmpty ?? false) return 'index:${index}_key:${item.key}';
    return 'index:$index';
  }

  Widget _buildActionPanel() {
    return DottedBorder(
      radius: Radius.circular(24.wMin),
      borderType: BorderType.RRect,
      padding: EdgeInsets.zero,
      color: AppTheme.cZhenxieBorderPrimary.color,
      dashPattern: [5.wMin, 5.wMin],
      strokeWidth: 1.5.wMin,
      child: Container(
        height: 340.wMin,
        width: 340.wMin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.wMin),
          color: AppTheme.cZhenxieBackgroundPrimary.color,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16.wMin,
          children: [
            _buildButtonWidget(
              text: "上传视频",
              svg: "assets/svg/public/icon_upload1.svg",
              onTap: _selectVideo,
            ),
            _buildButtonWidget(
              text: "录像",
              svg: "assets/svg/public/icon_video_resource.svg",
              onTap: _recordVideo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonWidget({
    required String text,
    required String svg,
    void Function()? onTap,
  }) {
    return ButtonWidget(
      text: text,
      width: 243.wMin,
      height: 64.wMin,
      color: AppTheme.cZhenxieBorderPrimary.color,
      borderRadius: 99,
      fontColor: AppTheme.cZhenxieFontPrimary.color,
      fontSize: 20.wMin,
      fontWeight: FontWeight.w500,
      sclae: 1.03,
      border: Border.all(
        color: AppTheme.cZhenxieBorderPrimary.color,
        width: 1.wMin,
      ),
      leftIcon: Container(
        margin: EdgeInsets.only(right: 8.wMin),
        child: SvgPicture.asset(
          svg,
          width: 22.wMin,
          colorFilter: ColorFilter.mode(
            AppTheme.cZhenxieFontPrimary.color,
            BlendMode.srcIn,
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}

class _VideoPreviewCard extends StatefulWidget {
  final WritingBoardMediaItemData item;
  final String videoId;
  final void Function(String videoId)? onPlayRequested;
  final void Function(String videoId)? onPauseRequested;
  final void Function(Future<void> Function())? onRegisterPause;
  final VoidCallback? onUnregisterPause;
  final VoidCallback? onDelete;

  const _VideoPreviewCard({
    required this.item,
    required this.videoId,
    this.onPlayRequested,
    this.onPauseRequested,
    this.onRegisterPause,
    this.onUnregisterPause,
    this.onDelete,
  });

  @override
  State<_VideoPreviewCard> createState() => _VideoPreviewCardState();
}

class _VideoPreviewCardState extends State<_VideoPreviewCard> with RouteAware {
  final Player _player = Player();
  late final VideoController _controller;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _completedSub;

  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _loadedSource;
  ModalRoute<dynamic>? _route;
  bool _isRouteObserverSubscribed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoController(_player);
    _listenPlayer();
    widget.onRegisterPause?.call(_pauseFromParent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVideo();
    });
  }

  @override
  void didUpdateWidget(covariant _VideoPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_mediaSource(oldWidget.item) == _mediaSource(widget.item)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVideo();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (identical(_route, route)) return;
    if (_isRouteObserverSubscribed) {
      AppPages.observer.unsubscribe(this);
      _isRouteObserverSubscribed = false;
    }
    _route = route;
    if (route == null) return;
    AppPages.observer.subscribe(this, route);
    _isRouteObserverSubscribed = true;
  }

  @override
  void dispose() {
    widget.onUnregisterPause?.call();
    if (_isRouteObserverSubscribed) {
      AppPages.observer.unsubscribe(this);
    }
    _playingSub?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _completedSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  void _listenPlayer() {
    _playingSub = _player.stream.playing.listen((event) {
      _isPlaying = event;
      if (mounted) setState(() {});
    });
    _durationSub = _player.stream.duration.listen((event) {
      _duration = event;
      if (mounted) setState(() {});
    });
    _positionSub = _player.stream.position.listen((event) {
      _position = event;
      if (mounted) setState(() {});
    });
    _completedSub = _player.stream.completed.listen((event) async {
      if (!event) return;
      _isPlaying = false;
      await _player.pause();
      await _player.seek(Duration.zero);
      _position = Duration.zero;
      widget.onPauseRequested?.call(widget.videoId);
      if (mounted) setState(() {});
    });
  }

  @override
  void didPushNext() {
    unawaited(_pauseFromRouteChange());
  }

  Future<void> _loadVideo() async {
    final source = _mediaSource(widget.item);
    if (source == null || source.isEmpty) return;
    if (_loadedSource == source) return;
    _loadedSource = source;
    _isPlaying = false;
    _duration = Duration.zero;
    _position = Duration.zero;
    if (mounted) setState(() {});
    await _player.open(Media(source), play: false);
    final duration = await _player.stream.duration.firstWhere((event) => event > Duration.zero).timeout(
          const Duration(seconds: 2),
          onTimeout: () => Duration.zero,
        );
    if (duration > Duration.zero) {
      _duration = duration;
      if (mounted) setState(() {});
    }
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
      widget.onPauseRequested?.call(widget.videoId);
      return;
    }
    widget.onPlayRequested?.call(widget.videoId);
    if (_duration > Duration.zero && _position >= _duration) {
      await _player.seek(Duration.zero);
    }
    await _player.play();
  }

  Future<void> _pauseFromParent() async {
    if (!_isPlaying) return;
    await _player.pause();
    await _player.seek(Duration.zero);
    _isPlaying = false;
    _position = Duration.zero;
    widget.onPauseRequested?.call(widget.videoId);
    if (mounted) setState(() {});
  }

  /// 页面被其他路由覆盖时，主动停止当前卡片播放。
  Future<void> _pauseFromRouteChange() async {
    if (!_isPlaying) return;
    await _player.pause();
    await _player.seek(Duration.zero);
    _isPlaying = false;
    _position = Duration.zero;
    widget.onPauseRequested?.call(widget.videoId);
    if (mounted) setState(() {});
  }

  Duration _getRemainingDuration() {
    final remaining = _duration - _position;
    if (remaining.isNegative) return Duration.zero;
    return remaining;
  }

  String? _mediaSource(WritingBoardMediaItemData item) {
    if (item.localPath?.isNotEmpty ?? false) return item.localPath;
    if (item.url?.isNotEmpty ?? false) return item.url;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340.wMin,
      height: 340.wMin,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.wMin),
              child: TapScaleWidget(
                onTap: () async {
                  await _togglePlay();
                },
                sclae: 1,
                child: Video(
                  width: double.infinity,
                  height: double.infinity,
                  controller: _controller,
                  fit: BoxFit.contain,
                  fill: AppTheme.cZhenxieBackgroundPrimary.color,
                  controls: (state) {
                    if (_isPlaying) return Container();
                    return Container(
                      alignment: Alignment.center,
                      child: Container(
                        width: 80.wMin,
                        height: 80.wMin,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.wMin,
                          ),
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          size: 54.wMin,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            right: 10.wMin,
            top: 10.wMin,
            child: TapScaleWidget(
              onTap: () {
                ShowBigResourceDialog.showVideo(
                  context: context, 
                  useAspectRatio: false,
                  showSubtitleSetting: false,
                  relationVideo: EnKnowledgeEntityRelationVideo(
                    videoUrl: _mediaSource(widget.item),
                  ),
                );
              },
              sclae: 1,
              child: Container(
                width: 42.wMin,
                height: 42.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.4),
                ),
                child: Icon(
                  Icons.open_in_full,
                  color: AppTheme.cInverseTextLight.color,
                  size: 24.wMin,
                ),
              ),
            ),
          ),
          if (widget.onDelete != null)
            Positioned(
              top: 10.wMin,
              left: 10.wMin,
              child: _buildDeleteButton(),
            ),
          Positioned(
            bottom: 10.wMin,
            right: 10.wMin,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 6.wMin,
                vertical: 2.wMin,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.wMin),
                color: Colors.black.withValues(alpha: 0.4),
              ),
              child: Text(
                DateFormatUtil.formatDurationToMinSec(
                  _getRemainingDuration(),
                ),
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return TapScaleWidget(
      onTap: widget.onDelete,
      sclae: 1.05,
      child: Container(
        width: 42.wMin,
        height: 42.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.4),
        ),
        child: SvgPicture.asset(
          "assets/svg/public/icon_delete.svg",
          width: 20.wMin,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
