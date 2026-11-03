import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../../widgets.dart';
import 'model/writing_board_data.dart';

class WritRecordingUploadWidget extends StatefulWidget {
  final WritingBoardMediaAnswerData? mediaData;
  final void Function(List<WritingBoardMediaItemData> items)? onItemsChanged;
  final WritingBoardEditPolicyMacro editPolicy;

  const WritRecordingUploadWidget({
    super.key,
    this.mediaData,
    this.onItemsChanged,
    this.editPolicy = WritingBoardEditPolicyMacro.stageRule,
  });

  @override
  State<WritRecordingUploadWidget> createState() => _WritRecordingUploadWidgetState();
}

class _WritRecordingUploadWidgetState extends State<WritRecordingUploadWidget> {
  static const List<String> _audioExtensions = ['mp3', 'wav', 'm4a', 'aac', 'flac', 'ogg'];
  static const int _maxRecordingSize = 5 * 1024 * 1024;

  bool _isRecordingUIVisible = false;
  bool _isRecording = false;
  String _recordingPcmPath = "";
  int _recordSampleRate = 16000;
  int _recordChannels = 1;

  List<WritingBoardMediaItemData> get _items => widget.mediaData?.items ?? const <WritingBoardMediaItemData>[];
  String? _playingAudioId;
  final Map<String, Future<void> Function()> _pauseCallbacks = <String, Future<void> Function()>{};

  // int get _maxCount => widget.mediaData?.maxCount ?? 0;
  int get _maxCount => 3;

  bool get _isReadOnly => widget.editPolicy == WritingBoardEditPolicyMacro.readOnly;

  bool get _canAddMore => !_isReadOnly && (_maxCount <= 0 || _items.length < _maxCount);

  @override
  void dispose() {
    if (_isRecording) {
      unawaited(RecordingServerUtils.instance.stopARecord(isResult: false));
    }
    super.dispose();
  }

  Future<void> _selectRecordingFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _audioExtensions,
      lockParentWindow: true,
      dialogTitle: "请选择录音",
    );
    if (result == null) return;
    if (!_isRecordingFileSizeValid(result.files.single.size)) {
      ToastUtils.showToast(text: "录音文件不能超过5MB");
      return;
    }
    if (result.files.single.path == null) return;
    _appendAudio(File(result.files.single.path!));
  }

  bool _isRecordingFileSizeValid(int fileSize) {
    return fileSize <= _maxRecordingSize;
  }

  Future<File?> _buildRecordedWavFile(String pcmPath) async {
    final pcmFile = File(pcmPath);
    if (!await pcmFile.exists()) return null;
    final wavPath = pcmPath.replaceFirst(RegExp(r'\.pcm$'), '.wav');
    final wavFile = File(wavPath);
    if (await wavFile.exists()) {
      await wavFile.delete();
    }
    await wavFile.create(recursive: true);
    final wavFileWriter = WavFileWriter(wavFile, _recordSampleRate, _recordChannels, 16);
    await wavFileWriter.initialize();
    await wavFileWriter.appendAudioData(await pcmFile.readAsBytes());
    await wavFileWriter.close();
    return wavFile;
  }

  Future<void> _startRecording() async {
    if (!_isRecording) {
      bool hasStarted = false;
      if (!mounted) return;
      _isRecording = true;
      if (mounted) setState(() {});
      await RecordingServerUtils.instance.startRecord(
        context: context,
        timerSeconds: 30,
        fileName: "writ_recording_temp",
        onStart: (pcmPath, sampleRate, channels) {
          hasStarted = true;
          _recordingPcmPath = pcmPath;
          _recordSampleRate = sampleRate;
          _recordChannels = channels;
        },
      );
      if (!hasStarted) {
        _isRecording = false;
        if (mounted) setState(() {});
      }
      return;
    }

    final pcmPath = await RecordingServerUtils.instance.stopARecord(
      onResult: (pcmPath, sampleRate, channels) {
        _recordingPcmPath = pcmPath;
        _recordSampleRate = sampleRate;
        _recordChannels = channels;
      },
    );
    _isRecording = false;
    if (mounted) setState(() {});
    final validPcmPath = (pcmPath?.isNotEmpty ?? false) ? pcmPath! : _recordingPcmPath;
    if (validPcmPath.isEmpty) {
      ToastUtils.showToast(text: "录音失败，请重试");
      return;
    }
    final wavFile = await _buildRecordedWavFile(validPcmPath);
    if (wavFile == null || !await wavFile.exists()) {
      ToastUtils.showToast(text: "录音失败，请重试");
      return;
    }
    if (!_isRecordingFileSizeValid(await wavFile.length())) {
      ToastUtils.showToast(text: "录音文件不能超过5MB");
      return;
    }
    _appendAudio(wavFile);
    _isRecordingUIVisible = false;
    if (mounted) setState(() {});
  }

  void _appendAudio(File file) {
    if (!_canAddMore) return;
    final nextItems = List<WritingBoardMediaItemData>.from(_items)..add(WritingBoardMediaItemData(localPath: file.path));
    if (mounted) setState(() {});
    widget.onItemsChanged?.call(nextItems);
  }

  void _removeAudio(int index) {
    final nextItems = List<WritingBoardMediaItemData>.from(_items)..removeAt(index);
    if (mounted) setState(() {});
    widget.onItemsChanged?.call(nextItems);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 853.wMin,
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.wMin),
        color: AppTheme.cSurfaceBg.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "交音频",
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary.color,
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
          SizedBox(height: 16.wMin),
          Container(
            height: 340.wMin,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: AppTheme.cSurfaceLayerElevated.color,
              border: Border.all(color: AppTheme.cBorderThin.color, width: 1.wMin),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.all(24.wMin),
              child: Row(
                spacing: 16.wMin,
                children: [
                  ...List.generate(_items.length, _buildAudioCard),
                  if (_canAddMore || _isRecordingUIVisible) _buildActionPanel(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TapScaleWidget(
          onTap: _startRecording,
          sclae: 1.05,
          child: Container(
            width: 110.wMin,
            height: 110.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xffF97316).withValues(alpha: _isRecording ? 0.8 : 0.2),
            ),
            child: SvgPicture.asset(
              "assets/svg/public/icon_microphone.svg",
              height: 54.wMin,
              colorFilter: ColorFilter.mode(
                _isRecording ? Colors.white : const Color(0xffF97316),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.wMin),
        Text(
          "点击麦克风${_isRecording ? '完成' : '开始'}录音",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        SizedBox(height: 24.wMin),
        ButtonWidget(
          text: "取消",
          width: 76.wMin,
          height: 32.wMin,
          borderRadius: 99,
          color: AppTheme.cSurfaceLayerElevated.color,
          border: Border.all(
            color: AppTheme.cBorderSubtle.color,
            width: 0.8.wMin,
          ),
          fontColor: AppTheme.cTextSecondary.color,
          fontSize: 18.wMin,
          fontWeight: FontWeight.w500,
          sclae: 1.03,
          onTap: () async {
            if (_isRecording) {
              await RecordingServerUtils.instance.stopARecord(isResult: false);
              _isRecording = false;
              _recordingPcmPath = "";
            }
            _isRecordingUIVisible = false;
            if (mounted) setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildAudioCard(int index) {
    final item = _items[index];
    final audioId = _mediaId(item, index);
    return _AudioPreviewCard(
      item: item,
      audioId: audioId,
      onRegisterPause: (callback) {
        _pauseCallbacks[audioId] = callback;
      },
      onUnregisterPause: () {
        _pauseCallbacks.remove(audioId);
      },
      onPlayRequested: (id) {
        for (final entry in _pauseCallbacks.entries) {
          if (entry.key == id) continue;
          unawaited(entry.value());
        }
        _playingAudioId = id;
      },
      onPauseRequested: (id) {
        if (_playingAudioId != id) return;
        _playingAudioId = null;
      },
      onDelete: _isReadOnly ? null : () => _removeAudio(index),
    );
  }

  Widget _buildActionPanel() {
    return _isRecordingUIVisible
        ? SizedBox(
            width: 421.wMin,
            height: 300.wMin,
            child: _buildRecordingWidget(),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16.wMin,
            children: [
              _buildButtonWidget(
                text: "上传录音",
                svg: "assets/svg/public/icon_upload1.svg",
                onTap: _selectRecordingFile,
              ),
              _buildButtonWidget(
                text: "录音",
                svg: "assets/svg/public/icon_speak.svg",
                fillColor: true,
                onTap: () {
                  _isRecordingUIVisible = true;
                  if (mounted) setState(() {});
                },
              ),
            ],
          );
  }

  String _mediaId(WritingBoardMediaItemData item, int index) {
    if (item.localPath?.isNotEmpty ?? false) return 'index:${index}_local:${item.localPath}';
    if (item.url?.isNotEmpty ?? false) return 'index:${index}_url:${item.url}';
    if (item.key?.isNotEmpty ?? false) return 'index:${index}_key:${item.key}';
    return 'index:$index';
  }

  Widget _buildButtonWidget({
    required String text,
    required String svg,
    bool fillColor = false,
    void Function()? onTap,
  }) {
    return ButtonWidget(
      text: text,
      width: 421.wMin,
      height: 64.wMin,
      color: AppTheme.cSurfaceWarning.color.withValues(alpha: fillColor ? 0.8 : 0.12),
      borderRadius: 8.wMin,
      fontColor: fillColor ? Colors.white : AppTheme.cTextPrimary.color,
      fontSize: 20.wMin,
      fontWeight: FontWeight.w500,
      sclae: 1.03,
      leftIcon: Container(
        margin: EdgeInsets.only(right: 8.wMin),
        child: SvgPicture.asset(
          svg,
          width: 22.wMin,
          colorFilter: ColorFilter.mode(
            fillColor ? Colors.white : AppTheme.cSurfaceWarning.color,
            BlendMode.srcIn,
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}

class _AudioPreviewCard extends StatefulWidget {
  final WritingBoardMediaItemData item;
  final String audioId;
  final void Function(String audioId)? onPlayRequested;
  final void Function(String audioId)? onPauseRequested;
  final void Function(Future<void> Function())? onRegisterPause;
  final VoidCallback? onUnregisterPause;
  final VoidCallback? onDelete;

  const _AudioPreviewCard({
    required this.item,
    required this.audioId,
    this.onPlayRequested,
    this.onPauseRequested,
    this.onRegisterPause,
    this.onUnregisterPause,
    this.onDelete,
  });

  @override
  State<_AudioPreviewCard> createState() => _AudioPreviewCardState();
}

class _AudioPreviewCardState extends State<_AudioPreviewCard> {
  final Player _player = Player();
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _completedSub;

  bool _isPlaying = false;
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
  void didUpdateWidget(covariant _AudioPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_mediaSource(oldWidget.item) == _mediaSource(widget.item)) return;
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
      widget.onPauseRequested?.call(widget.audioId);
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadAudio() async {
    final source = _mediaSource(widget.item);
    if (source == null || source.isEmpty) return;
    if (_loadedSource == source) return;
    _loadedSource = source;
    _isPlaying = false;
    _audioDuration = Duration.zero;
    _audioPosition = Duration.zero;
    if (mounted) setState(() {});
    await _player.open(Media(source), play: false);
    final duration = await _player.stream.duration.firstWhere((event) => event > Duration.zero).timeout(
          const Duration(seconds: 2),
          onTimeout: () => Duration.zero,
        );
    if (duration > Duration.zero) {
      _audioDuration = duration;
      if (mounted) setState(() {});
    }
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
      widget.onPauseRequested?.call(widget.audioId);
      return;
    }
    widget.onPlayRequested?.call(widget.audioId);
    if (_audioDuration > Duration.zero && _audioPosition >= _audioDuration) {
      await _player.seek(Duration.zero);
    }
    await _player.play();
  }

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

  String? _mediaSource(WritingBoardMediaItemData item) {
    if (item.localPath?.isNotEmpty ?? false) return item.localPath;
    if (item.url?.isNotEmpty ?? false) return item.url;
    return null;
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
                color: Color(0xffE8EDF4),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/svg/public/song.svg",
                      height: 180.wMin,
                      colorFilter: ColorFilter.mode(
                        Color(0xffBEC8D0),
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
          if (widget.onDelete != null)
            Positioned(
              top: 10.wMin,
              right: 10.wMin,
              child: _buildDeleteButton(),
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
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black54,
        ),
        child: SvgPicture.asset(
          "assets/svg/public/icon_delete.svg",
          width: 20.wMin,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }
}
