import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:api/entities/response.dart';
import 'package:audio_player_ex/audio_player_ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:langwise/common/https/manage_select_quzi_knowledge.dart';
import 'package:langwise/common/https/subscribe.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wise_http/wise_http.dart';
import 'package:just_audio/just_audio.dart' as just_audio;

import '../../../../../../common/public_controller/config_controller.dart';
import '../../../../../../utils/oss_upload_file_utils/oss_update_response_entity.dart';
import '../../../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../../../../../routes/routes.dart';
import '../../../manage_shared_pages/manage_quiz_list/controllers/manage_quiz_list_controller.dart';
import '../../../manage_shared_pages/manage_select_quzi_knowledge/controllers/manage_select_quzi_knowledge_controller.dart';
import '../../../models/manage_english_content_management_sentence_model.dart';
import '../../../utils/utils.dart';
import '../models/audio_dialogue_model.dart';
import '../models/audio_subtitle_editor_model.dart';

part 'manage_audio_subtitle_editor_audio_controller.dart';
part 'manage_audio_subtitle_editor_waveform_controller.dart';
part 'manage_audio_subtitle_editor_sentence_controller.dart';
part 'manage_audio_subtitle_editor_sentence_crud_controller.dart';
part 'manage_audio_subtitle_editor_ktag_controller.dart';
part 'manage_audio_subtitle_editor_api_controller.dart';

class ManageAudioSubtitleEditorController extends GetxController with ManageBreadcrumbMixin, WidgetsBindingObserver {
  final String tag;
  ManageAudioSubtitleEditorController({required this.tag});

  static final Set<ManageAudioSubtitleEditorController> _instances = {};

  bool _isLeavingPage = false;
  bool _isGeneratingTranslate = false;
  bool _isStoppingAudio = false;
  int _audioDataTaskVersion = 0;

  bool get canRunEditorTasks => !_isLeavingPage && !isClosed;
  bool get isGeneratingTranslate => _isGeneratingTranslate;

  int createAudioDataTaskVersion() {
    _audioDataTaskVersion += 1;
    return _audioDataTaskVersion;
  }

  bool isLatestAudioDataTask(int taskVersion) {
    return canRunEditorTasks && taskVersion == _audioDataTaskVersion;
  }

  void markLeavingPage() {
    if (_isLeavingPage) {
      return;
    }
    _isLeavingPage = true;
    _audioDataTaskVersion += 1;
    _isGeneratingTranslate = false;
    audioDownloadCancelToken?.cancel();
  }

  static Future<void> stopAllAudioEditors() async {
    try {
      final snapshot = List<ManageAudioSubtitleEditorController>.from(_instances);
      for (final controller in snapshot) {
        try {
          await controller.stopAndResetAudio();
        } catch (_) {}
      }
    } catch (_) {}
  }

  static void markAllAudioEditorsLeavingPage() {
    final snapshot = List<ManageAudioSubtitleEditorController>.from(_instances);
    for (final controller in snapshot) {
      controller.markLeavingPage();
    }
  }

  @override
  String get breadcrumbRoute => Routes.MANAGE_AUDIO_SUBTITLE_EDITOR;

  @override
  String get breadcrumbTitle => '编辑音频';

  List<ManageEnglishContentManagementSentenceIpaAudioModel>? audioList = [];
  int? currentAudioIndex;
  String? type;

  AudioSubtitleEditorModel? audioModel;
  bool publishStatus = false;
  int zmPublishStatus = 0;

  int downPercentage = 0;

  AudioPlayerEx? audioPlayer;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  String audioFilePath = '';
  String audioUrl = '';
  CancelToken? audioDownloadCancelToken;

  StreamController<WaveformProgress> progressController =
      StreamController<WaveformProgress>.broadcast();
  double allWidth = 0;
  List<DialogueModel> dialogueList = [];
  List<TextEditingController> zhCaptionsTextFieldList = [];
  List<List<TextEditingController>> kContentTextFieldList = [];
  List<List<FocusNode>> kContentFocusNodeList = [];

  final ScrollController scrollController = ScrollController();
  static const double _pixelsPerMsBase = 0.2;
  double zoomLevel = 2.5;
  double get zoomRatio => _pixelsPerMsBase * zoomLevel;
  double totalHeight = 120;
  double subHeight = 120;
  double minDistance = 12.0;

  int displayStartMs = 0;
  int displayDurationMs = 0;

  int? _pendingZoomAnchorTimeMs;
  double? _pendingZoomAnchorViewportDx;

  int currentTime = 0;
  int totalDurationTime = 0;

  bool hasUnsavedChanges = false;

  DialogueModel? _editingBackupDialogue;
  int? _editingBackupDialogueIndex;
  bool _unsavedBeforeEditing = false;

  static const int _dragFrameMs = 16;
  int _lastDragUpdateAtMs = 0;

  int? editDialogueIndex;
  int? showCaptionDialogueIndex;
  int showCaptionKTagIndex = 0;
  double showCaptionKTagProgress = 0.0;

  int? activeDialogueIndex;

  bool isMergeMode = false;
  final Set<int> mergeSelectedIndices = <int>{};

  final Map<int, BuildContext> _dialogueCellContexts = <int, BuildContext>{};
  Timer? _autoScrollSentenceTimer;
  int? _lastAutoScrollSentenceIndex;

  Timer? _autoCenterWaveformTimer;
  int? _lastAutoCenterWaveformDialogueIndex;

  bool wordModeLoopEnabled = true;
  bool _isWordModeLoopSeeking = false;

  int? _sentenceSegmentEndTimeMs;
  Timer? _sentenceSegmentTimer;
  int _sentencePlayGeneration = 0;

  bool _isAutoPreviewingAfterDrag = false;
  int _autoPreviewStayTimeMs = 0;
  Timer? _autoPreviewFinishTimer;
  int? _manualPauseAnchorTimeMs;

  final Map<String, double> _kTagPointerDownDx = <String, double>{};
  final Map<String, int> _kTagPointerDownAtMs = <String, int>{};
  final Map<String, bool> _kTagPointerMoved = <String, bool>{};

  static const double markerSnapTolPx = 8.0;

  Map<String, dynamic>? hoverMarker;
  Map<String, dynamic>? dragMarker;

  bool isScrollbarDragging = false;

  final just_audio.AudioPlayer justAudioPlayer = just_audio.AudioPlayer();

  late final bool Function(KeyEvent) _keyboardEventCallback;

  TextEditingController promptController = TextEditingController();
  List<List<TextEditingController>> dialogueTimeTextFieldList = [];
  int? collectionId = 0;

  void _throttledUpdate() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastDragUpdateAtMs < _dragFrameMs) return;
    _lastDragUpdateAtMs = now;
    update();
  }

  void markUnsaved({bool notify = true}) {
    if (!hasUnsavedChanges) {
      hasUnsavedChanges = true;
    }
    if (notify) {
      update();
    }
  }

  bool get isWordMode => editDialogueIndex != null;

  bool get isPlaying => audioPlayer?.state == PlayerState.playing;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    _instances.add(this);

    if (Get.arguments != null) {
      currentAudioIndex = Get.arguments['currentAudioIndex'];
      final rawList = Get.arguments['audioList'];
      if (rawList is List) {
        audioList = rawList
            .whereType<ManageEnglishContentManagementSentenceIpaAudioModel>()
            .toList();
      }
      type = Get.arguments['type'];
      collectionId = Get.arguments['collectionId'];
    }

    initAudioData();
  }

  @override
  void onReady() {
    super.onReady();
    _keyboardEventCallback = handleKeyboardEvent;
    HardwareKeyboard.instance.addHandler(_keyboardEventCallback);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    markLeavingPage();
    HardwareKeyboard.instance.removeHandler(_keyboardEventCallback);
    WidgetsBinding.instance.removeObserver(this);
    try {
      audioPlayer?.stop();
      justAudioPlayer.stop();
    } catch (_) {}
    _instances.remove(this);
    unawaited(stopAndResetAudio());
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _autoScrollSentenceTimer?.cancel();
    _autoCenterWaveformTimer?.cancel();
    _autoPreviewFinishTimer?.cancel();
    _sentenceSegmentTimer?.cancel();
    audioDownloadCancelToken?.cancel();
    progressController.close();
    audioPlayer?.dispose();
    scrollController.dispose();
    for (var i = 0; i < kContentTextFieldList.length; i++) {
      for (var j = 0; j < kContentTextFieldList[i].length; j++) {
        kContentTextFieldList[i][j].dispose();
      }
    }
    for (var i = 0; i < kContentFocusNodeList.length; i++) {
      for (var j = 0; j < kContentFocusNodeList[i].length; j++) {
        kContentFocusNodeList[i][j].dispose();
      }
    }
    for (var i = 0; i < zhCaptionsTextFieldList.length; i++) {
      zhCaptionsTextFieldList[i].dispose();
    }
    promptController.dispose();
    justAudioPlayer.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        forceStopAllAudio();
        break;
      case AppLifecycleState.resumed:
      case AppLifecycleState.inactive:
        break;
    }
  }

  void forceStopAllAudio() {
    unawaited(stopAndResetAudio());
  }

  Future<void> stopAndResetAudio() async {
    if (_isStoppingAudio) return;
    _isStoppingAudio = true;
    try {
      _isAutoPreviewingAfterDrag = false;
      _manualPauseAnchorTimeMs = null;
      _sentenceSegmentEndTimeMs = null;
      _isWordModeLoopSeeking = false;
      _autoPreviewFinishTimer?.cancel();
      _sentenceSegmentTimer?.cancel();
      try {
        await audioPlayer?.pause();
        await audioPlayer?.stop();
      } catch (_) {}
      try {
        await justAudioPlayer.pause();
        await justAudioPlayer.stop();
      } catch (_) {}
    } finally {
      _isStoppingAudio = false;
    }
  }

  void switchAudio(int index) async {
    currentAudioIndex = index;
    initAllData();
    initAudioData();
  }

  void initAllData() async {
    dialogueList.clear();
    for (var i = 0; i < kContentTextFieldList.length; i++) {
      for (var j = 0; j < kContentTextFieldList[i].length; j++) {
        kContentTextFieldList[i][j].dispose();
      }
    }
    for (var i = 0; i < kContentFocusNodeList.length; i++) {
      for (var j = 0; j < kContentFocusNodeList[i].length; j++) {
        kContentFocusNodeList[i][j].dispose();
      }
    }
    for (var zhTextField in zhCaptionsTextFieldList) {
      zhTextField.dispose();
    }
    zhCaptionsTextFieldList.clear();
    kContentTextFieldList.clear();
    kContentFocusNodeList.clear();

    currentTime = 0;
    showCaptionKTagIndex = 0;
    showCaptionKTagProgress = 0.0;
    showCaptionDialogueIndex = null;

    await audioPlayer?.stop();
    zoomLevel = 2.5;
    if (scrollController.hasClients) {
      try {
        scrollController.jumpTo(0);
      } catch (_) {}
    }

    audioModel = null;
    update();
  }

  initAudioData() async {
    if (!canRunEditorTasks ||
        audioList == null ||
        audioList!.isEmpty ||
        currentAudioIndex == null ||
        type == null) {
      return;
    }
    final taskVersion = createAudioDataTaskVersion();
    try {
      ToastUtils.showLoading();

      Map<String, dynamic> data = {};
      if (audioList![currentAudioIndex!].uid != null) {
        data['uid'] = audioList![currentAudioIndex!].uid;
      } else {
        data['contentId'] = audioList![currentAudioIndex!].contentId!;
        data['accentId'] = audioList![currentAudioIndex!].accentId!;
        data['type'] = type!;
      }

      final res = await ManageSelectQuziKnowledge.getSentenceAudioDetail(
          parameters: {}, data: data);
      if (!isLatestAudioDataTask(taskVersion) || res == null || res.data == null) {
        return;
      }
      final originalModel = res.data!;
      audioModel = AudioSubtitleEditorModel.fromOriginalModel(originalModel);
      publishStatus = audioModel!.published ?? false;
      zmPublishStatus = audioModel!.assPublished ?? 0;
      audioList![currentAudioIndex!].published = audioModel!.published ?? false;
      promptController.text = audioModel!.prompt ?? '';
      if (isLatestAudioDataTask(taskVersion)) {
        update();
      }

      if (audioModel?.url != null) {
        unawaited(_downloadAudioFile(audioModel?.url ?? '', taskVersion));
      }
      if (isLatestAudioDataTask(taskVersion)) {
        parseAssString();
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void parseAssString() {
    if (!canRunEditorTasks) {
      return;
    }
    dialogueList = KaraokeSubtitlesUtils.parseAssString(audioModel);
    for (var i = 0; i < dialogueList.length; i++) {
      zhCaptionsTextFieldList
          .add(TextEditingController(text: dialogueList[i].zhDialogueStr));

      List<TextEditingController> kContentTextFieldControllerList = [];
      List<FocusNode> kFocusNodeList = [];
      for (var j = 0; j < dialogueList[i].kTagList!.length; j++) {
        kContentTextFieldControllerList.add(
            TextEditingController(text: dialogueList[i].kTagList![j].text));
        kFocusNodeList.add(FocusNode());
      }
      kContentTextFieldList.add(kContentTextFieldControllerList);
      kContentFocusNodeList.add(kFocusNodeList);

      List<TextEditingController> dialogueTimeTextFieldControllerList = [];
      dialogueTimeTextFieldControllerList.add(
          TextEditingController(text: dialogueList[i].startTimeStr));
      dialogueTimeTextFieldControllerList.add(
          TextEditingController(text: dialogueList[i].endTimeStr));
      dialogueTimeTextFieldList.add(dialogueTimeTextFieldControllerList);
    }

    if (dialogueList.isNotEmpty) {
      activeDialogueIndex = 0;
    } else {
      activeDialogueIndex = null;
    }
    if (canRunEditorTasks) {
      update();
    }
  }
}
