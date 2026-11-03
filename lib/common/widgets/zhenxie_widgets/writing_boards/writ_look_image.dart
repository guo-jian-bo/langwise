import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../../widgets.dart';
import 'board_noise_paper.dart';
import 'model/writing_board_data.dart';
import 'model/writing_board_frame_section_type.dart';
import 'utils/writing_board_controller_bundle.dart';
import 'writ_head_tail.dart';
import 'writ_image_upload.dart';
import 'writ_just_text.dart';
import 'writ_recording_upload.dart';
import 'writ_video_upload.dart';

class WritLookImageWidget extends StatelessWidget {
  final WritingBoardData? data;
  final WritingBoardControllers? controllers;
  final String? answerKind;
  final WritingBoardFrameSectionType? highlightedFrameSection;
  final void Function(WritingBoardFrameSectionType type)? onTapFrameSection;
  final void Function(String beatNid)? onTapStep;
  final void Function(String beatNid)? onSelectBeatNid;
  final void Function(String beatNid)? onRequestStepFocus;
  final void Function(String beatNid, String text)? onStepTextChanged;
  final void Function(String text)? onHeadChanged;
  final void Function(String text)? onTailChanged;
  final void Function(List<WritingBoardMediaItemData> items)? onImageItemsChanged;
  final void Function(List<WritingBoardMediaItemData> items)? onVideoItemsChanged;
  final void Function(List<WritingBoardMediaItemData> items)? onAudioItemsChanged;

  const WritLookImageWidget({
    super.key,
    this.data,
    this.controllers,
    this.answerKind,
    this.highlightedFrameSection,
    this.onTapFrameSection,
    this.onTapStep,
    this.onSelectBeatNid,
    this.onRequestStepFocus,
    this.onStepTextChanged,
    this.onHeadChanged,
    this.onTailChanged,
    this.onImageItemsChanged,
    this.onVideoItemsChanged,
    this.onAudioItemsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final materials = data?.materials ?? const <WritingBoardMaterialData>[];
    return Column(
      children: [
        if (materials.isNotEmpty) _LookMaterialsStripWidget(materials: materials),
        Expanded(
          child: Container(
            alignment: materials.isNotEmpty ? Alignment.topCenter : Alignment.center,
            child: _buildBodyWidget(),
          ),
        ),
      ],
    );
  }

  Widget _buildBodyWidget() {
    final editPolicy = data?.editPolicy ?? WritingBoardEditPolicyMacro.stageRule;
    if (answerKind == "text") {
      return BoardNoisePaperWidget(
        child: _buildTextContentWidget(),
      );
    }

    final draftMedia = data?.mediaAnswer;
    final exemplarMedia = data?.exemplarMediaAnswer;
    final mediaData = data?.contentSource == WritingBoardContentSourceMacro.exemplar ? exemplarMedia : draftMedia;
    if (answerKind == "audio") {
      return WritRecordingUploadWidget(
        mediaData: mediaData,
        editPolicy: editPolicy,
        onItemsChanged: onAudioItemsChanged,
      );
    }
    if (answerKind == "video") {
      return WritVideoUploadWidget(
        mediaData: mediaData,
        editPolicy: editPolicy,
        onItemsChanged: onVideoItemsChanged,
      );
    }
    if (answerKind == "image") {
      return WritImageUploadWidget(
        mediaData: mediaData,
        editPolicy: editPolicy,
        onItemsChanged: onImageItemsChanged,
      );
    }
    return const SizedBox.shrink();
  }

  /// 根据渲染数据决定正文区使用纯正文还是首尾结构。
  Widget _buildTextContentWidget() {
    final currentData = data ?? const WritingBoardData();
    final useHeadTailWidget = currentData.showHead || currentData.showTail;
    if (!useHeadTailWidget) {
      return WritJustTextWidget(
        data: currentData,
        controllers: controllers,
        onTapStep: onTapStep,
        onSelectBeatNid: onSelectBeatNid,
        onRequestStepFocus: onRequestStepFocus,
        onStepTextChanged: onStepTextChanged,
      );
    }
    return WritHeadTailWidget(
      data: currentData,
      controllers: controllers,
      highlightedFrameSection: highlightedFrameSection,
      useTitleHeadStyle: _isTitleHeadStyle(currentData),
      onTapFrameSection: onTapFrameSection,
      onTapStep: onTapStep,
      onSelectBeatNid: onSelectBeatNid,
      onRequestStepFocus: onRequestStepFocus,
      onStepTextChanged: onStepTextChanged,
      onHeadChanged: onHeadChanged,
      onTailChanged: onTailChanged,
    );
  }

  /// 根据头部标签判断当前是否应该按标题样式渲染。
  bool _isTitleHeadStyle(WritingBoardData data) {
    final headLabel = data.headLabel ?? '';
    return data.showHead && (headLabel.contains('标题') || headLabel.toLowerCase().contains('title'));
  }
}

class _LookMaterialsStripWidget extends StatefulWidget {
  final List<WritingBoardMaterialData> materials;

  const _LookMaterialsStripWidget({required this.materials});

  @override
  State<_LookMaterialsStripWidget> createState() => _LookMaterialsStripWidgetState();
}

class _LookMaterialsStripWidgetState extends State<_LookMaterialsStripWidget> {
  /// 收口顶部素材区所有媒体卡片的暂停能力，保证同一时刻只播放一个。
  final Map<String, Future<void> Function()> _pauseCallbacks = <String, Future<void> Function()>{};

  String? _playingMaterialId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 90.wMin, vertical: 24.wMin),
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 16.wMin,
        children: List.generate(widget.materials.length, (index) => _buildMaterialCard(context, widget.materials[index], index)),
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, WritingBoardMaterialData material, int index) {
    if (material.kind == 'image') {
      return _buildImageWidget(context, material);
    }
    if (material.kind == 'video') {
      final materialId = _buildMediaMaterialId(material, index);
      return _buildVideoWidget(material, materialId);
    }
    if (material.kind == 'audio') {
      final materialId = _buildMediaMaterialId(material, index);
      return _buildAudioWidget(material, materialId);
    }
    return const SizedBox.shrink();
  }

  Widget _buildImageWidget(BuildContext context, WritingBoardMaterialData material) {
    return TapScaleWidget(
      onTap: () {
        if (material.url.isEmpty) return;
        ShowBigResourceDialog.showImage(
          context: context,
          imageUrls: [material.url],
        );
      },
      sclae: 1,
      child: SizedBox(
        height: 350.wMin,
        child: CachedImageWidget(
          material.url,
          placeholder: buildEmptyWidget(),
          errorWidget: buildEmptyWidget(),
          borderRadius: BorderRadius.circular(24.wMin),
        ),
      ),
    );
  }

  /// 按上传区同款样式渲染视频素材卡片。
  Widget _buildVideoWidget(WritingBoardMaterialData material, String materialId) {
    return SizedBox(
      width: 350.wMin,
      height: 350.wMin,
      child: _LookVideoPreviewCard(
        material: material,
        materialId: materialId,
        onRegisterPause: (callback) {
          _pauseCallbacks[materialId] = callback;
        },
        onUnregisterPause: () {
          _pauseCallbacks.remove(materialId);
          if (_playingMaterialId == materialId) _playingMaterialId = null;
        },
        onPlayRequested: (id) {
          for (final entry in _pauseCallbacks.entries) {
            if (entry.key == id) continue;
            unawaited(entry.value());
          }
          _playingMaterialId = id;
        },
        onPauseRequested: (id) {
          if (_playingMaterialId != id) return;
          _playingMaterialId = null;
        },
      ),
    );
  }

  /// 按上传区同款样式渲染音频素材卡片。
  Widget _buildAudioWidget(WritingBoardMaterialData material, String materialId) {
    return SizedBox(
      width: 350.wMin,
      height: 350.wMin,
      child: _LookAudioPreviewCard(
        material: material,
        materialId: materialId,
        onRegisterPause: (callback) {
          _pauseCallbacks[materialId] = callback;
        },
        onUnregisterPause: () {
          _pauseCallbacks.remove(materialId);
          if (_playingMaterialId == materialId) _playingMaterialId = null;
        },
        onPlayRequested: (id) {
          for (final entry in _pauseCallbacks.entries) {
            if (entry.key == id) continue;
            unawaited(entry.value());
          }
          _playingMaterialId = id;
        },
        onPauseRequested: (id) {
          if (_playingMaterialId != id) return;
          _playingMaterialId = null;
        },
      ),
    );
  }

  /// 为顶部媒体素材生成稳定 id，用于单播控制。
  String _buildMediaMaterialId(WritingBoardMaterialData material, int index) {
    return 'index:${index}_kind:${material.kind}_url:${material.url}_key:${material.key ?? ''}';
  }
}

class _LookVideoPreviewCard extends StatefulWidget {
  final WritingBoardMaterialData material;
  final String materialId;
  final void Function(String materialId)? onPlayRequested;
  final void Function(String materialId)? onPauseRequested;
  final void Function(Future<void> Function())? onRegisterPause;
  final VoidCallback? onUnregisterPause;

  const _LookVideoPreviewCard({
    required this.material,
    required this.materialId,
    this.onPlayRequested,
    this.onPauseRequested,
    this.onRegisterPause,
    this.onUnregisterPause,
  });

  @override
  State<_LookVideoPreviewCard> createState() => _LookVideoPreviewCardState();
}

class _LookVideoPreviewCardState extends State<_LookVideoPreviewCard> {
  /// 负责视频播放状态的底层播放器。
  final Player _player = Player();

  late final VideoController _controller;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _completedSub;

  bool _isPlaying = false;
  bool _hasLoadFailed = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _loadedSource;

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
  void didUpdateWidget(covariant _LookVideoPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.material.url == widget.material.url) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVideo();
    });
  }

  @override
  void dispose() {
    widget.onUnregisterPause?.call();
    _playingSub?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _completedSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  /// 监听播放器状态，并同步刷新播放进度与播放态。
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
      widget.onPauseRequested?.call(widget.materialId);
      if (mounted) setState(() {});
    });
  }

  /// 加载素材视频地址，并预热时长信息。
  Future<void> _loadVideo() async {
    if (widget.material.url.isEmpty || _loadedSource == widget.material.url) return;
    _loadedSource = widget.material.url;
    _hasLoadFailed = false;
    _isPlaying = false;
    _duration = Duration.zero;
    _position = Duration.zero;
    if (mounted) setState(() {});
    try {
      await _player.open(Media(widget.material.url), play: false);
      final duration = await _player.stream.duration.firstWhere((event) => event > Duration.zero).timeout(
            const Duration(seconds: 2),
            onTimeout: () => Duration.zero,
          );
      if (duration > Duration.zero) {
        _duration = duration;
        if (mounted) setState(() {});
      }
    } catch (_) {
      _hasLoadFailed = true;
      if (mounted) setState(() {});
    }
  }

  /// 切换当前视频素材的播放与暂停状态。
  Future<void> _togglePlay() async {
    if (_hasLoadFailed || widget.material.url.isEmpty) return;
    if (_isPlaying) {
      await _player.pause();
      widget.onPauseRequested?.call(widget.materialId);
      return;
    }
    widget.onPlayRequested?.call(widget.materialId);
    if (_duration > Duration.zero && _position >= _duration) {
      await _player.seek(Duration.zero);
    }
    await _player.play();
  }

  /// 响应其他素材开始播放时的强制暂停。
  Future<void> _pauseFromParent() async {
    if (!_isPlaying) return;
    await _player.pause();
    await _player.seek(Duration.zero);
    _isPlaying = false;
    _position = Duration.zero;
    if (mounted) setState(() {});
  }

  Duration _getRemainingDuration() {
    final remaining = _duration - _position;
    if (remaining.isNegative) return Duration.zero;
    return remaining;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300.wMin,
      height: 300.wMin,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.wMin),
              child: _hasLoadFailed || widget.material.url.isEmpty
                  ? _buildVideoFallbackWidget()
                  : TapScaleWidget(
                      onTap: _togglePlay,
                      sclae: 1,
                      child: Video(
                        fill: Colors.black,
                        controller: _controller,
                        fit: BoxFit.contain,
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
                                color: const Color(0xffF97316).withValues(alpha: 0.55),
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
            bottom: 10.wMin,
            right: 10.wMin,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.wMin),
                color: Colors.black54,
              ),
              child: Text(
                DateFormatUtil.formatDurationToMinSec(_getRemainingDuration()),
                style: TextStyle(
                  fontSize: 14.wMin,
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

  Widget _buildVideoFallbackWidget() {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Icon(
        Icons.play_circle_outline_rounded,
        size: 72.wMin,
        color: Colors.white.withValues(alpha: 0.8),
      ),
    );
  }
}

class _LookAudioPreviewCard extends StatefulWidget {
  final WritingBoardMaterialData material;
  final String materialId;
  final void Function(String materialId)? onPlayRequested;
  final void Function(String materialId)? onPauseRequested;
  final void Function(Future<void> Function())? onRegisterPause;
  final VoidCallback? onUnregisterPause;

  const _LookAudioPreviewCard({
    required this.material,
    required this.materialId,
    this.onPlayRequested,
    this.onPauseRequested,
    this.onRegisterPause,
    this.onUnregisterPause,
  });

  @override
  State<_LookAudioPreviewCard> createState() => _LookAudioPreviewCardState();
}

class _LookAudioPreviewCardState extends State<_LookAudioPreviewCard> {
  /// 负责音频播放状态的底层播放器。
  final Player _player = Player();

  StreamSubscription<bool>? _playingSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _completedSub;

  bool _isPlaying = false;
  bool _hasLoadFailed = false;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;
  String? _loadedSource;

  @override
  void initState() {
    super.initState();
    _listenAudio();
    widget.onRegisterPause?.call(_pauseFromParent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAudio();
    });
  }

  @override
  void didUpdateWidget(covariant _LookAudioPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.material.url == widget.material.url) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAudio();
    });
  }

  @override
  void dispose() {
    widget.onUnregisterPause?.call();
    _playingSub?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _completedSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  /// 监听播放器状态，并同步刷新音频进度与播放态。
  void _listenAudio() {
    _playingSub = _player.stream.playing.listen((event) {
      _isPlaying = event;
      if (mounted) setState(() {});
    });
    _durationSub = _player.stream.duration.listen((event) {
      _audioDuration = event;
      if (mounted) setState(() {});
    });
    _positionSub = _player.stream.position.listen((event) {
      _audioPosition = event;
      if (mounted) setState(() {});
    });
    _completedSub = _player.stream.completed.listen((event) async {
      if (!event) return;
      _isPlaying = false;
      await _player.pause();
      await _player.seek(Duration.zero);
      _audioPosition = Duration.zero;
      widget.onPauseRequested?.call(widget.materialId);
      if (mounted) setState(() {});
    });
  }

  /// 加载素材音频地址，并预热时长信息。
  Future<void> _loadAudio() async {
    if (widget.material.url.isEmpty || _loadedSource == widget.material.url) return;
    _loadedSource = widget.material.url;
    _hasLoadFailed = false;
    _isPlaying = false;
    _audioDuration = Duration.zero;
    _audioPosition = Duration.zero;
    if (mounted) setState(() {});
    try {
      await _player.open(Media(widget.material.url), play: false);
      final duration = await _player.stream.duration.firstWhere((event) => event > Duration.zero).timeout(
            const Duration(seconds: 2),
            onTimeout: () => Duration.zero,
          );
      if (duration > Duration.zero) {
        _audioDuration = duration;
        if (mounted) setState(() {});
      }
    } catch (_) {
      _hasLoadFailed = true;
      if (mounted) setState(() {});
    }
  }

  /// 切换当前音频素材的播放与暂停状态。
  Future<void> _togglePlay() async {
    if (_hasLoadFailed || widget.material.url.isEmpty) return;
    if (_isPlaying) {
      await _player.pause();
      widget.onPauseRequested?.call(widget.materialId);
      return;
    }
    widget.onPlayRequested?.call(widget.materialId);
    if (_audioDuration > Duration.zero && _audioPosition >= _audioDuration) {
      await _player.seek(Duration.zero);
    }
    await _player.play();
  }

  /// 响应其他素材开始播放时的强制暂停。
  Future<void> _pauseFromParent() async {
    if (!_isPlaying) return;
    await _player.pause();
    await _player.seek(Duration.zero);
    _isPlaying = false;
    _audioPosition = Duration.zero;
    if (mounted) setState(() {});
  }

  Duration _getRemainingDuration() {
    final remaining = _audioDuration - _audioPosition;
    if (remaining.isNegative) return Duration.zero;
    return remaining;
  }

  IconData _getPlayIconData() {
    return _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300.wMin,
      height: 300.wMin,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.wMin),
              child: Container(
                color: const Color(0xffE8EDF4),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/svg/public/song.svg",
                      height: 180.wMin,
                      colorFilter: ColorFilter.mode(
                        const Color(0xffBEC8D0),
                        BlendMode.srcIn,
                      ),
                    ),
                    TapScaleWidget(
                      onTap: _togglePlay,
                      sclae: 1.05,
                      child: Container(
                        width: 80.wMin,
                        height: 80.wMin,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xffF97316).withValues(alpha: 0.55),
                        ),
                        child: Icon(
                          _getPlayIconData(),
                          color: Colors.white,
                          size: 58.wMin,
                        ),
                      ),
                    ),
                    if (_hasLoadFailed || widget.material.url.isEmpty)
                      Text(
                        "音频不可播放",
                        style: TextStyle(
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextSecondary.color,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10.wMin,
            right: 10.wMin,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.wMin),
                color: Colors.black54,
              ),
              child: Text(
                DateFormatUtil.formatDurationToMinSec(_getRemainingDuration()),
                style: TextStyle(
                  fontSize: 14.wMin,
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
}
