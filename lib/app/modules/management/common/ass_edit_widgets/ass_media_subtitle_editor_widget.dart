import 'dart:async';
import 'dart:io';
import 'dart:ui' show FontFeature;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/common/entities/card_public_entity.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:path/path.dart' as path;
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../../../../common/enum/enum.dart';
import '../../manage_content/manage_audio_subtitle_editor/models/audio_dialogue_model.dart';
import '../../manage_content/manage_audio_subtitle_editor/models/audio_subtitle_editor_model.dart';
import 'audio_waveform_data.dart';
import '../../manage_content/manage_audio_subtitle_editor/widgets/editor_action_tag_widget.dart';
import 'audio_waveform_widget.dart';
import 'editor_sidebar_btn_widget.dart';

part 'ass_media_subtitle_editor_widget_helpers.dart';
part 'ass_media_subtitle_editor_widget_dialogs.dart';
part 'ass_media_subtitle_editor_widget_media.dart';
part 'ass_media_subtitle_editor_widget_view.dart';
part 'ass_media_subtitle_editor_widget_waveform.dart';


class AssMediaSubtitleEditorValue {
  final String ass;
  final String? translateAss;
  final String content;
  final List<DialogueModel> dialogueList;

  const AssMediaSubtitleEditorValue({
    required this.ass,
    required this.translateAss,
    required this.content,
    required this.dialogueList,
  });
}

class AssMediaSubtitleEditorWidget extends StatefulWidget {
  final String mediaUrl;
  final String ass;
  final String? translateAss;
  final ResourceTypeEnum mediaType;
  final double playbackRate;
  final bool enabled;
  final ValueChanged<AssMediaSubtitleEditorValue>? onChanged;
  /// 右边浮动的工具栏按钮
  final List<EditorSidebarBtnWidget>? rightToolButtons;
  /// 隐藏添加句子
  final bool hideAddSentence;
  /// 隐藏翻译
  final bool hideTranslation;

  /// 浮动在包络线上方的widget
  final Widget? envelopeTopFloatWidget;

  const AssMediaSubtitleEditorWidget({
    super.key,
    required this.mediaUrl,
    required this.ass,
    this.translateAss,
    this.mediaType = ResourceTypeEnum.audio,
    this.playbackRate = 1.0,
    this.enabled = true,
    this.onChanged,
    this.rightToolButtons,
    this.hideAddSentence = false,
    this.hideTranslation = false,
    this.envelopeTopFloatWidget,
  });

  @override
  State<AssMediaSubtitleEditorWidget> createState() =>
      _AssMediaSubtitleEditorWidgetState();
}

class _AssMediaSubtitleEditorWidgetState
    extends State<AssMediaSubtitleEditorWidget> {
  final ScrollController _waveScrollController = ScrollController();
  final Map<int, BuildContext> _cellContexts = <int, BuildContext>{};

  final List<TextEditingController> _zhControllers = <TextEditingController>[];
  final List<List<TextEditingController>> _kTextControllers =
      <List<TextEditingController>>[];
  final List<List<FocusNode>> _kTagFocusNodes = <List<FocusNode>>[];
  final List<List<TextEditingController>> _timeControllers =
      <List<TextEditingController>>[];

  final Set<int> _mergeSelectedIndices = <int>{};

  List<DialogueModel> _dialogueList = <DialogueModel>[];
  Player? _audioPlayer;
  VideoController? _videoController;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<bool>? _completeSubscription;
  StreamSubscription<bool>? _playingSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<WaveformProgress>? _waveformSubscription;

  AudioWaveformData? _waveform;
  Object? _waveformError;
  double _waveformProgress = 0;
  bool _loadingMedia = false;
  bool _isVideoReady = false;

  int _currentTime = 0;
  int _totalDurationTime = 0;
  static const double _markerSnapTolPx = 8.0;
  final double _waveformTotalHeight = 120.wMin;
  final double _waveformSubHeight = 120.wMin;
  final double _waveformMinDistance = 12.wMin;
  Map<String, dynamic>? _hoverMarker;
  Map<String, dynamic>? _dragMarker;
  int? _activeDialogueIndex;
  int? _editDialogueIndex;
  int? _showCaptionDialogueIndex;
  int _showCaptionKTagIndex = 0;
  double _showCaptionKTagProgress = 0;
  DialogueModel? _editingBackupDialogue;
  int? _editingBackupDialogueIndex;
  bool _isMergeMode = false;
  double _zoomLevel = 2.5;
  bool _isPlayingValue = false;
  bool _isScrollbarDragging = false;
  int? _pendingZoomAnchorTimeMs;
  double? _pendingZoomAnchorViewportDx;
  Timer? _previewPauseTimer;
  Timer? _autoScrollSentenceTimer;
  int? _lastAutoScrollSentenceIndex;
  Timer? _autoCenterWaveformTimer;
  int? _lastAutoCenterWaveformDialogueIndex;
  Timer? _sentenceSegmentTimer;
  int? _sentenceSegmentEndTimeMs;
  int _sentencePlayGeneration = 0;
  bool _isAutoPreviewingAfterDrag = false;
  int _autoPreviewStayTimeMs = 0;
  final Map<String, double> _kTagPointerDownDx = <String, double>{};
  final Map<String, int> _kTagPointerDownAtMs = <String, int>{};
  final Map<String, bool> _kTagPointerMoved = <String, bool>{};

  bool get _isWordMode => _editDialogueIndex != null;
  bool get _isPlaying => _isPlayingValue;

  void _updateState([VoidCallback? updater]) {
    if (!mounted) return;
    setState(updater ?? () {});
  }

  @override
  void initState() {
    super.initState();
    _initData();
    unawaited(_prepareMedia());
  }

  @override
  void didUpdateWidget(covariant AssMediaSubtitleEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ass != widget.ass ||
        oldWidget.translateAss != widget.translateAss) {
      _initData();
    }
    if (oldWidget.mediaUrl != widget.mediaUrl ||
        oldWidget.mediaType != widget.mediaType) {
      unawaited(_prepareMedia());
    }
    if (oldWidget.playbackRate != widget.playbackRate) {
      unawaited(_audioPlayer?.setRate(widget.playbackRate));
    }
  }

  @override
  void dispose() {
    _previewPauseTimer?.cancel();
    _sentenceSegmentTimer?.cancel();
    _waveformSubscription?.cancel();
    _positionSubscription?.cancel();
    _completeSubscription?.cancel();
    _playingSubscription?.cancel();
    _durationSubscription?.cancel();
    _previewPauseTimer?.cancel();
    _autoScrollSentenceTimer?.cancel();
    _autoCenterWaveformTimer?.cancel();
    _sentenceSegmentTimer?.cancel();
    _waveScrollController.dispose();
    for (final controller in _zhControllers) {
      controller.dispose();
    }
    for (final list in _kTextControllers) {
      for (final controller in list) {
        controller.dispose();
      }
    }
    for (final list in _kTagFocusNodes) {
      for (final focusNode in list) {
        focusNode.dispose();
      }
    }
    for (final list in _timeControllers) {
      for (final controller in list) {
        controller.dispose();
      }
    }
    unawaited(_audioPlayer?.stop());
    _videoController = null;
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildRoot();
  }
}
