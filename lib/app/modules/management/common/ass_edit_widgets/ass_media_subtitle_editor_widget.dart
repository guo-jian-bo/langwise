import 'dart:async';
import 'dart:io';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:langwise/common/entities/card_public_entity.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path/path.dart' as path;
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../manage_content/manage_audio_subtitle_editor/models/audio_dialogue_model.dart';
import '../../manage_content/manage_audio_subtitle_editor/models/audio_subtitle_editor_model.dart';
import '../../manage_content/manage_audio_subtitle_editor/views/audio_waveform_widget.dart';

enum AssMediaSubtitleEditorMediaType { audio, video }

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
  final AssMediaSubtitleEditorMediaType mediaType;
  final double playbackRate;
  final bool enabled;
  final Widget? sideActionWidget;
  final ValueChanged<AssMediaSubtitleEditorValue>? onChanged;

  const AssMediaSubtitleEditorWidget({
    super.key,
    required this.mediaUrl,
    required this.ass,
    this.translateAss,
    this.mediaType = AssMediaSubtitleEditorMediaType.audio,
    this.playbackRate = 1.0,
    this.enabled = true,
    this.sideActionWidget,
    this.onChanged,
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
  final List<List<TextEditingController>> _timeControllers =
      <List<TextEditingController>>[];

  final Set<int> _mergeSelectedIndices = <int>{};

  List<DialogueModel> _dialogueList = <DialogueModel>[];
  Player? _audioPlayer;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<bool>? _completeSubscription;
  StreamSubscription<bool>? _playingSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<WaveformProgress>? _waveformSubscription;

  Waveform? _waveform;
  Object? _waveformError;
  double _waveformProgress = 0;
  bool _loadingMedia = false;

  int _currentTime = 0;
  int _totalDurationTime = 0;
  int? _activeDialogueIndex;
  int? _editDialogueIndex;
  int? _showCaptionDialogueIndex;
  int _showCaptionKTagIndex = 0;
  double _showCaptionKTagProgress = 0;
  bool _isMergeMode = false;
  double _zoomLevel = 2.5;
  bool _isPlayingValue = false;

  bool get _isWordMode => _editDialogueIndex != null;
  bool get _isPlaying => _isPlayingValue;

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
    _waveformSubscription?.cancel();
    _positionSubscription?.cancel();
    _completeSubscription?.cancel();
    _playingSubscription?.cancel();
    _durationSubscription?.cancel();
    _waveScrollController.dispose();
    for (final controller in _zhControllers) {
      controller.dispose();
    }
    for (final list in _kTextControllers) {
      for (final controller in list) {
        controller.dispose();
      }
    }
    for (final list in _timeControllers) {
      for (final controller in list) {
        controller.dispose();
      }
    }
    unawaited(_audioPlayer?.stop());
    _audioPlayer?.dispose();
    super.dispose();
  }

  void _initData() {
    for (final controller in _zhControllers) {
      controller.dispose();
    }
    for (final list in _kTextControllers) {
      for (final controller in list) {
        controller.dispose();
      }
    }
    for (final list in _timeControllers) {
      for (final controller in list) {
        controller.dispose();
      }
    }
    _zhControllers.clear();
    _kTextControllers.clear();
    _timeControllers.clear();

    final AudioSubtitleEditorModel model = AudioSubtitleEditorModel(
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      widget.mediaUrl,
      null,
      null,
      widget.ass,
      null,
      null,
      null,
      null,
      widget.translateAss == null
          ? null
          : <LanguageText>[LanguageText(lang: 'zh', text: widget.translateAss)],
      null,
      null,
    );
    _dialogueList = KaraokeSubtitlesUtils.parseAssString(model)
        .map(_cloneDialogue)
        .toList();
    for (final dialogue in _dialogueList) {
      _zhControllers
          .add(TextEditingController(text: dialogue.zhDialogueStr ?? ''));
      _kTextControllers.add((dialogue.kTagList ?? <KTagModel>[])
          .map((item) => TextEditingController(text: item.text ?? ''))
          .toList());
      _timeControllers.add(<TextEditingController>[
        TextEditingController(text: dialogue.startTimeStr),
        TextEditingController(text: dialogue.endTimeStr),
      ]);
    }
    _activeDialogueIndex = _dialogueList.isEmpty ? null : 0;
    _editDialogueIndex = null;
    _showCaptionDialogueIndex = null;
    _emitChanged();
    if (mounted) setState(() {});
  }

  DialogueModel _cloneDialogue(DialogueModel source) {
    final DialogueModel dialogue = DialogueModel(
      index: source.index,
      startTime: source.startTime,
      endTime: source.endTime,
      kTagText: source.kTagText,
      text: source.text,
      kTagList: (source.kTagList ?? <KTagModel>[])
          .map((item) => KTagModel(
                startTime: item.startTime,
                duration: item.duration,
                kTagText: item.kTagText,
                text: item.text,
                isEdit: item.isEdit,
              ))
          .toList(),
      layerIndex: source.layerIndex,
      isEdit: source.isEdit,
      zhDialogueStr: source.zhDialogueStr,
    );
    dialogue.prefixStr = source.prefixStr;
    return dialogue;
  }

  Future<void> _prepareMedia() async {
    _waveformSubscription?.cancel();
    _positionSubscription?.cancel();
    _completeSubscription?.cancel();
    _playingSubscription?.cancel();
    _durationSubscription?.cancel();
    try {
      await _audioPlayer?.stop();
    } catch (_) {}
    _audioPlayer?.dispose();
    _audioPlayer = null;

    if (widget.mediaUrl.trim().isEmpty) return;
    setState(() {
      _loadingMedia = true;
      _waveform = null;
      _waveformError = null;
      _waveformProgress = 0;
    });

    try {
      final ResourceType type =
          widget.mediaType == AssMediaSubtitleEditorMediaType.video
              ? ResourceType.video
              : ResourceType.audio;
      final String? localPath =
          await CacheManagerUtils.instance.getFile(widget.mediaUrl, type);
      if (!mounted || localPath == null || localPath.isEmpty) return;
      _audioPlayer = Player();
      _playingSubscription = _audioPlayer?.stream.playing.listen((playing) {
        _isPlayingValue = playing;
        if (mounted) setState(() {});
      });
      _durationSubscription = _audioPlayer?.stream.duration.listen((duration) {
        _totalDurationTime = duration.inMilliseconds;
        if (mounted) setState(() {});
      });
      _positionSubscription = _audioPlayer?.stream.position.listen((position) {
        if (!mounted || !_isPlaying) return;
        _currentTime = position.inMilliseconds;
        for (int i = 0; i < _dialogueList.length; i++) {
          final DialogueModel dialogue = _dialogueList[i];
          if (_currentTime >= (dialogue.startTime ?? 0) &&
              _currentTime <= (dialogue.endTime ?? 0)) {
            _showCaptionDialogueIndex = i;
            _activeDialogueIndex = i;
            final List<KTagModel> tags = dialogue.kTagList ?? <KTagModel>[];
            for (int j = 0; j < tags.length; j++) {
              final int start = tags[j].startTime ?? 0;
              final int duration = tags[j].duration ?? 0;
              if (_currentTime >= start && _currentTime <= start + duration) {
                _showCaptionKTagIndex = j;
                _showCaptionKTagProgress = duration <= 0
                    ? 0
                    : (_currentTime - start) / duration;
                break;
              }
            }
            break;
          }
        }
        if (mounted) setState(() {});
      });

      _completeSubscription = _audioPlayer?.stream.completed.listen((completed) async {
        if (!completed) return;
        _isPlayingValue = false;
        _currentTime = 0;
        try {
          await _audioPlayer?.seek(Duration.zero);
          await _audioPlayer?.pause();
        } catch (_) {}
        if (mounted) setState(() {});
      });
      await _audioPlayer?.open(Media(localPath), play: false);
      await _audioPlayer?.setRate(widget.playbackRate);

      final Directory tempDir =
          await Directory.systemTemp.createTemp('ass_media_editor_wave');
      _waveformSubscription = JustWaveform.extract(
        audioInFile: File(localPath),
        waveOutFile: File(path.join(tempDir.path, 'waveform.wave')),
      ).listen(
        (progress) {
          if (!mounted) return;
          setState(() {
            _waveformProgress = progress.progress;
            if (progress.waveform != null) {
              _waveform = progress.waveform;
              _totalDurationTime = progress.waveform!.duration.inMilliseconds;
            }
          });
        },
        onError: (Object error) {
          if (!mounted) return;
          setState(() {
            _waveformError = error;
          });
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingMedia = false;
        });
      }
    }
  }

  void _emitChanged() {
    String ass = '';
    String zhAss = '';
    for (final dialogue in _dialogueList) {
      ass += dialogue.dialogueStr;
      if (dialogue.zhDialogueAss != null) {
        zhAss += dialogue.zhDialogueAss!;
      }
    }
    if (ass.endsWith('\n')) ass = ass.substring(0, ass.length - 1);
    if (zhAss.endsWith('\n')) zhAss = zhAss.substring(0, zhAss.length - 1);
    widget.onChanged?.call(
      AssMediaSubtitleEditorValue(
        ass: ass,
        translateAss: zhAss.isEmpty ? null : zhAss,
        content: _dialogueList
            .map((item) => (item.text ?? '').trim())
            .where((item) => item.isNotEmpty)
            .join('\n'),
        dialogueList: _dialogueList.map(_cloneDialogue).toList(),
      ),
    );
  }

  Future<void> _togglePlayPause() async {
    if (_audioPlayer == null) return;
    await _audioPlayer?.setRate(widget.playbackRate);
    if (_isPlaying) {
      await _audioPlayer?.pause();
    } else {
      await _audioPlayer?.seek(Duration(milliseconds: _currentTime));
      await _audioPlayer?.play();
    }
    if (mounted) setState(() {});
  }

  Future<void> _seekTo(int timeMs, {bool play = false}) async {
    if (_audioPlayer == null) return;
    _currentTime = timeMs.clamp(0, _totalDurationTime);
    await _audioPlayer?.seek(Duration(milliseconds: _currentTime));
    if (play) {
      await _audioPlayer?.play();
    }
    if (mounted) setState(() {});
  }

  Future<void> _focusOnDialogue(int index) async {
    if (index < 0 || index >= _dialogueList.length) return;
    _activeDialogueIndex = index;
    await _seekTo(_dialogueList[index].startTime ?? 0, play: !_isPlaying);
    final BuildContext? cellContext = _cellContexts[index];
    if (cellContext != null && cellContext.mounted) {
      await Scrollable.ensureVisible(
        cellContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    }
  }

  void _refreshDialogue(int dialogueIndex) {
    final DialogueModel dialogue = _dialogueList[dialogueIndex];
    final List<KTagModel> tags = dialogue.kTagList ?? <KTagModel>[];
    String text = '';
    String kTagText = '';
    for (int i = 0; i < tags.length; i++) {
      if (i == 0) {
        tags[i].startTime = dialogue.startTime;
      } else {
        tags[i].startTime =
            (tags[i - 1].startTime ?? 0) + (tags[i - 1].duration ?? 0);
      }
      tags[i].kTagText =
          '{\\k${((tags[i].duration ?? 0) / 10).toInt()}}${tags[i].text ?? ''}';
      text = i == 0 ? (tags[i].text ?? '') : '$text ${tags[i].text ?? ''}';
      kTagText = i == 0
          ? (tags[i].kTagText ?? '')
          : '$kTagText ${tags[i].kTagText ?? ''}';
    }
    dialogue.text = text;
    dialogue.kTagText = kTagText;
    _emitChanged();
    if (mounted) setState(() {});
  }

  void _startEditingDialogue(int index) {
    for (final dialogue in _dialogueList) {
      dialogue.isEdit = false;
    }
    _dialogueList[index].isEdit = true;
    _editDialogueIndex = index;
    _activeDialogueIndex = index;
    if (mounted) setState(() {});
  }

  void _saveEditingDialogue(int index) {
    _dialogueList[index].isEdit = false;
    _editDialogueIndex = null;
    _emitChanged();
    if (mounted) setState(() {});
  }

  void _cancelEditingDialogue(int index) {
    _dialogueList[index].isEdit = false;
    _editDialogueIndex = null;
    if (mounted) setState(() {});
  }

  void _addKTag(int dialogueIndex) {
    final DialogueModel dialogue = _dialogueList[dialogueIndex];
    final List<KTagModel> tags = dialogue.kTagList ?? <KTagModel>[];
    tags.add(
      KTagModel(
        startTime: dialogue.startTime,
        duration: 200,
        text: 'value',
        kTagText: '{\\k20}value',
      ),
    );
    _kTextControllers[dialogueIndex].add(TextEditingController(text: 'value'));
    _refreshDialogue(dialogueIndex);
  }

  void _deleteKTag(int dialogueIndex, int kTagIndex) {
    final List<KTagModel> tags = _dialogueList[dialogueIndex].kTagList ?? <KTagModel>[];
    if (kTagIndex < 0 || kTagIndex >= tags.length) return;
    tags.removeAt(kTagIndex);
    _kTextControllers[dialogueIndex].removeAt(kTagIndex).dispose();
    _refreshDialogue(dialogueIndex);
  }

  void _swapKTag(int dialogueIndex, KTagModel tag, int index) {
    final List<KTagModel> tags = _dialogueList[dialogueIndex].kTagList ?? <KTagModel>[];
    final int fromIndex = tags.indexOf(tag);
    if (fromIndex == -1 || fromIndex == index) return;
    final KTagModel movedTag = tags.removeAt(fromIndex);
    final TextEditingController movedController =
        _kTextControllers[dialogueIndex].removeAt(fromIndex);
    final int targetIndex = fromIndex < index ? index - 1 : index;
    tags.insert(targetIndex, movedTag);
    _kTextControllers[dialogueIndex].insert(targetIndex, movedController);
    _refreshDialogue(dialogueIndex);
  }

  void _toggleMergeMode() {
    _isMergeMode = !_isMergeMode;
    _mergeSelectedIndices.clear();
    if (mounted) setState(() {});
  }

  bool get _canMergeSelected {
    if (_mergeSelectedIndices.length < 2) return false;
    final List<int> sorted = _mergeSelectedIndices.toList()..sort();
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i] != sorted[i - 1] + 1) return false;
    }
    return true;
  }

  void _mergeSelectedDialogues() {
    if (!_canMergeSelected) return;
    final List<int> sorted = _mergeSelectedIndices.toList()..sort();
    DialogueModel merged = _cloneDialogue(_dialogueList[sorted.first]);
    for (int i = 1; i < sorted.length; i++) {
      merged = KaraokeSubtitlesUtils.mergeDialogueModel(
        merged,
        _cloneDialogue(_dialogueList[sorted[i]]),
      );
    }
    for (int i = sorted.length - 1; i >= 0; i--) {
      final int index = sorted[i];
      _dialogueList.removeAt(index);
      _zhControllers.removeAt(index).dispose();
      for (final controller in _kTextControllers.removeAt(index)) {
        controller.dispose();
      }
      for (final controller in _timeControllers.removeAt(index)) {
        controller.dispose();
      }
    }
    merged.index = sorted.first;
    _dialogueList.insert(sorted.first, merged);
    _zhControllers.insert(
      sorted.first,
      TextEditingController(text: merged.zhDialogueStr ?? ''),
    );
    _kTextControllers.insert(
      sorted.first,
      (merged.kTagList ?? <KTagModel>[])
          .map((item) => TextEditingController(text: item.text ?? ''))
          .toList(),
    );
    _timeControllers.insert(sorted.first, <TextEditingController>[
      TextEditingController(text: merged.startTimeStr),
      TextEditingController(text: merged.endTimeStr),
    ]);
    for (int i = 0; i < _dialogueList.length; i++) {
      _dialogueList[i].index = i;
    }
    _isMergeMode = false;
    _mergeSelectedIndices.clear();
    _emitChanged();
    if (mounted) setState(() {});
  }

  void _showMessage(String text) {
    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _showAddDialogueDialog() async {
    final int? anchorIndex = _activeDialogueIndex;
    if (anchorIndex == null ||
        anchorIndex < 0 ||
        anchorIndex >= _dialogueList.length) {
      _showMessage('请先定位一句');
      return;
    }
    final TextEditingController controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.cBgSecondary,
          title: Text(
            '添加句子',
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextPrimary,
            ),
          ),
          content: SizedBox(
            width: 680.wMin,
            child: TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '输入句子文本，单词用空格分隔',
                hintStyle: TextStyle(
                  fontSize: 14.wMin,
                  color: AppTheme.cTextDisabled,
                ),
                filled: true,
                fillColor: AppTheme.cBgTertiary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.wMin),
                  borderSide: BorderSide(
                    color: AppTheme.cBorderPrimary,
                    width: 1.wMin,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.wMin),
                  borderSide: BorderSide(
                    color: AppTheme.cBorderPrimary,
                    width: 1.wMin,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.wMin),
                  borderSide: BorderSide(
                    color: AppTheme.cBorderPrimary,
                    width: 1.wMin,
                  ),
                ),
              ),
              style: TextStyle(
                fontSize: 14.wMin,
                color: AppTheme.cTextPrimary,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                '取消',
                style: TextStyle(color: AppTheme.cTextSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                _insertDialogueRelative(
                  anchorIndex,
                  controller.text,
                  before: true,
                );
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                '添加到前面',
                style: TextStyle(color: AppTheme.cMorphemeTagPrefix),
              ),
            ),
            TextButton(
              onPressed: () {
                _insertDialogueRelative(
                  anchorIndex,
                  controller.text,
                  before: false,
                );
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                '添加到后面',
                style: TextStyle(color: AppTheme.cTextBrand),
              ),
            ),
          ],
        );
      },
    );
    controller.dispose();
  }

  void _insertDialogueRelative(
    int anchorIndex,
    String rawText, {
    required bool before,
  }) {
    final List<String> words = rawText
        .trim()
        .split(RegExp(r'\s+'))
        .where((item) => item.trim().isNotEmpty)
        .toList();
    if (words.isEmpty) {
      _showMessage('请输入句子文本');
      return;
    }

    final DialogueModel anchor = _dialogueList[anchorIndex];
    final int insertIndex = before ? anchorIndex : anchorIndex + 1;
    final int startMs = before
        ? (anchorIndex > 0 ? (_dialogueList[anchorIndex - 1].endTime ?? 0) : 0)
        : (anchor.endTime ?? (anchor.startTime ?? 0));
    final int endMs = before
        ? (anchor.startTime ?? startMs)
        : (anchorIndex + 1 < _dialogueList.length
            ? (_dialogueList[anchorIndex + 1].startTime ?? startMs)
            : _totalDurationTime);

    if (endMs <= startMs) {
      _showMessage('当前句前后没有可用时间空隙');
      return;
    }

    final int totalDuration = endMs - startMs;
    final int averageDuration =
        (totalDuration / words.length).floor().clamp(1, totalDuration);
    int cursor = startMs;
    final List<KTagModel> tags = <KTagModel>[];
    for (int i = 0; i < words.length; i++) {
      final int duration =
          i == words.length - 1 ? (endMs - cursor) : averageDuration;
      final int safeDuration = duration.clamp(1, totalDuration);
      tags.add(
        KTagModel(
          startTime: cursor,
          duration: safeDuration,
          text: words[i],
          kTagText: '{\\k${(safeDuration / 10).toInt()}}${words[i]}',
        ),
      );
      cursor += safeDuration;
    }

    final DialogueModel dialogue = DialogueModel(
      index: insertIndex,
      startTime: startMs,
      endTime: endMs,
      kTagList: tags,
      kTagText: tags.map((item) => item.kTagText ?? '').join(' '),
      text: words.join(' '),
      zhDialogueStr: null,
      layerIndex: anchor.layerIndex,
    );
    dialogue.prefixStr = anchor.prefixStr ?? 'Default,,0,0,0,';

    _dialogueList.insert(insertIndex, dialogue);
    _zhControllers.insert(insertIndex, TextEditingController());
    _kTextControllers.insert(
      insertIndex,
      tags
          .map((item) => TextEditingController(text: item.text ?? ''))
          .toList(),
    );
    _timeControllers.insert(
      insertIndex,
      <TextEditingController>[
        TextEditingController(text: dialogue.startTimeStr),
        TextEditingController(text: dialogue.endTimeStr),
      ],
    );

    for (int i = 0; i < _dialogueList.length; i++) {
      _dialogueList[i].index = i;
    }
    _activeDialogueIndex = insertIndex;
    _emitChanged();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: <Widget>[
          Expanded(child: _buildBody()),
          _buildBottomPlayerBar(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1640.wMin),
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _dialogueList.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildDialogueCell(index);
                },
              ),
            ),
          ),
        ),
        Positioned(
          right: 6.wMin,
          bottom: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              if (widget.sideActionWidget != null) ...<Widget>[
                widget.sideActionWidget!,
                SizedBox(height: 10.wMin),
              ],
              
              _buildSideButton(
                '添加句子',
                AppTheme.cMorphemeTagPrefix,
                widget.enabled ? _showAddDialogueDialog : null,
              ),
              SizedBox(height: 10.wMin),

              _isMergeMode
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _buildSideButton(
                          '合并(${_mergeSelectedIndices.length})',
                          _canMergeSelected
                              ? AppTheme.cMorphemeTagCombiningForm
                              : AppTheme.cBgTertiary,
                          _canMergeSelected ? _mergeSelectedDialogues : null,
                        ),
                        SizedBox(width: 10.wMin),
                        _buildSideButton('取消', AppTheme.cBgTertiary,
                            _toggleMergeMode),
                      ],
                    )
                  : _buildSideButton(
                      '多选合并',
                      AppTheme.cMorphemeTagCombiningForm,
                      _toggleMergeMode,
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSideButton(String text, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 12.wMin),
        decoration: BoxDecoration(
          color: color.withOpacity(onTap == null ? 0.35 : 1),
          borderRadius: BorderRadius.circular(10.wMin),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 14.wMin, color: AppTheme.cTextPrimary),
        ),
      ),
    );
  }

  Widget _buildDialogueCell(int index) {
    final DialogueModel dialogue = _dialogueList[index];
    final bool active = _activeDialogueIndex == index || _editDialogueIndex == index;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 15.wMin),
      child: Builder(
        builder: (BuildContext context) {
          _cellContexts[index] = context;
          return GestureDetector(
            onTap: () {
              if (_isMergeMode) {
                if (_mergeSelectedIndices.contains(index)) {
                  _mergeSelectedIndices.remove(index);
                } else {
                  _mergeSelectedIndices.add(index);
                }
                setState(() {});
                return;
              }
              if (_isWordMode && _editDialogueIndex == index) {
                unawaited(_togglePlayPause());
                return;
              }
              unawaited(_focusOnDialogue(index));
            },
            child: Container(
              padding: EdgeInsets.all(16.wMin),
              decoration: BoxDecoration(
                color: active ? const Color(0x08F97316) : AppTheme.cBgTertiary,
                borderRadius: BorderRadius.circular(12.wMin),
                border: Border.all(
                  color: _mergeSelectedIndices.contains(index)
                      ? AppTheme.cFeedbackSuccessIcon
                      : active
                          ? AppTheme.cSurfaceWarning
                          : AppTheme.cBgQuaternary,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${dialogue.startTimeStr} - ${dialogue.endTimeStr}',
                    style: TextStyle(
                      fontSize: 14.wMin,
                      color: AppTheme.cTextPrimary,
                    ),
                  ),
                  SizedBox(height: 8.wMin),
                  _buildKaraokeText(index),
                  if ((dialogue.zhDialogueStr ?? '').isNotEmpty) ...<Widget>[
                    SizedBox(height: 8.wMin),
                    Text(
                      dialogue.zhDialogueStr ?? '',
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextPrimary,
                      ),
                    ),
                  ],
                  if (dialogue.isEdit) ...<Widget>[
                    SizedBox(height: 12.wMin),
                    _buildEditPanel(index),
                  ],
                  SizedBox(height: 12.wMin),
                  Row(
                    children: <Widget>[
                      const Spacer(),
                      if (_editDialogueIndex == index) ...<Widget>[
                        _buildTagButton('保存句子', AppTheme.cFeedbackSuccessText,
                            () => _saveEditingDialogue(index)),
                        SizedBox(width: 8.wMin),
                        _buildTagButton(
                            '取消', AppTheme.cBgTertiary, () => _cancelEditingDialogue(index)),
                      ] else ...<Widget>[
                        _buildTagButton('编辑', AppTheme.cSurfaceWarning,
                            widget.enabled ? () => _startEditingDialogue(index) : null),
                        SizedBox(width: 8.wMin),
                        _buildTagButton('定位', AppTheme.cSurfaceSuccess,
                            () => unawaited(_focusOnDialogue(index))),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTagButton(String text, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
        decoration: BoxDecoration(
          color: color.withOpacity(onTap == null ? 0.35 : 1),
          borderRadius: BorderRadius.circular(8.wMin),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 14.wMin, color: AppTheme.cTextPrimary),
        ),
      ),
    );
  }

  Widget _buildKaraokeText(int dialogueIndex) {
    final DialogueModel dialogue = _dialogueList[dialogueIndex];
    final List<KTagModel> tags = dialogue.kTagList ?? <KTagModel>[];
    if (_showCaptionDialogueIndex != dialogueIndex || tags.isEmpty) {
      return SelectableText(
        dialogue.text ?? '',
        style: TextStyle(fontSize: 20.wMin, color: AppTheme.cTextPrimary),
      );
    }
    final List<TextSpan> spans = <TextSpan>[];
    for (int i = 0; i < tags.length; i++) {
      final bool passed = i < _showCaptionKTagIndex;
      final bool current = i == _showCaptionKTagIndex && _showCaptionKTagProgress > 0;
      spans.add(
        TextSpan(
          text: '${tags[i].text ?? ''} ',
          style: TextStyle(
            fontSize: 20.wMin,
            color: (passed || current)
                ? AppTheme.cSurfaceWarning
                : AppTheme.cTextPrimary,
            decoration: current ? TextDecoration.underline : TextDecoration.none,
            decorationColor: AppTheme.cSurfaceWarning,
          ),
        ),
      );
    }
    return SelectableText.rich(TextSpan(children: spans));
  }

  Widget _buildEditPanel(int dialogueIndex) {
    final DialogueModel dialogue = _dialogueList[dialogueIndex];
    final List<KTagModel> tags = dialogue.kTagList ?? <KTagModel>[];
    return Container(
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10.wMin),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(
                width: 110.wMin,
                child: TextField(
                  controller: _timeControllers[dialogueIndex].first,
                  decoration: const InputDecoration(border: InputBorder.none),
                  style: TextStyle(fontSize: 18.wMin, color: AppTheme.cTextLink),
                  onSubmitted: (value) {
                    _dialogueList[dialogueIndex].startTime =
                        KaraokeSubtitlesUtils.parseTimeToDuration(value);
                    _refreshDialogue(dialogueIndex);
                  },
                ),
              ),
              Text('-', style: TextStyle(fontSize: 18.wMin, color: AppTheme.cTextLink)),
              SizedBox(width: 20.wMin),
              SizedBox(
                width: 110.wMin,
                child: TextField(
                  controller: _timeControllers[dialogueIndex].last,
                  decoration: const InputDecoration(border: InputBorder.none),
                  style: TextStyle(fontSize: 18.wMin, color: AppTheme.cTextLink),
                  onSubmitted: (value) {
                    _dialogueList[dialogueIndex].endTime =
                        KaraokeSubtitlesUtils.parseTimeToDuration(value);
                    _refreshDialogue(dialogueIndex);
                  },
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: widget.enabled ? () => _addKTag(dialogueIndex) : null,
                child: Text('添加块', style: TextStyle(color: AppTheme.cTextBrand)),
              ),
            ],
          ),
          TextField(
            controller: _zhControllers[dialogueIndex],
            decoration: const InputDecoration(hintText: '请输入翻译'),
            onChanged: (value) {
              dialogue.zhDialogueStr = value;
              _emitChanged();
            },
          ),
          SizedBox(height: 12.wMin),
          Wrap(
            spacing: 10.wMin,
            runSpacing: 10.wMin,
            children: List<Widget>.generate(tags.length, (int index) {
              return SizedBox(
                width: 280.wMin,
                child: DragTarget<KTagModel>(
                  onAcceptWithDetails: (details) =>
                      _swapKTag(dialogueIndex, details.data, index),
                  builder: (context, candidateData, rejectedData) {
                    final KTagModel tag = tags[index];
                    return LongPressDraggable<KTagModel>(
                      data: tag,
                      feedback: Material(
                        color: Colors.transparent,
                        child: SizedBox(
                          width: 280.wMin,
                          child: _buildTagEditorItem(dialogueIndex, index, true),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.35,
                        child: _buildTagEditorItem(dialogueIndex, index, candidateData.isNotEmpty),
                      ),
                      child: _buildTagEditorItem(
                        dialogueIndex,
                        index,
                        candidateData.isNotEmpty,
                      ),
                    );
                  },
                ),
              );
            }),
          ),
          SizedBox(height: 12.wMin),
          Text(
            dialogue.kTagText ?? '',
            style: TextStyle(fontSize: 16.wMin, color: AppTheme.cTextPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildTagEditorItem(int dialogueIndex, int tagIndex, bool highlight) {
    final KTagModel tag = _dialogueList[dialogueIndex].kTagList![tagIndex];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        color: highlight
            ? AppTheme.cSurfaceWarning.withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6.wMin),
        border: Border.all(
          color: highlight
              ? AppTheme.cSurfaceWarning.withOpacity(0.6)
              : Colors.white.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.drag_indicator, color: AppTheme.cTextTertiary, size: 18.wMin),
          IconButton(
            onPressed: () => unawaited(_seekTo(tag.startTime ?? 0, play: true)),
            icon: Icon(Icons.play_arrow, color: AppTheme.cTextPrimary, size: 18.wMin),
          ),
          Expanded(
            child: TextField(
              controller: _kTextControllers[dialogueIndex][tagIndex],
              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
              style: TextStyle(fontSize: 16.wMin, color: AppTheme.cTextPrimary),
              onChanged: (value) {
                tag.text = value;
                _refreshDialogue(dialogueIndex);
              },
            ),
          ),
          Text(
            '${tag.duration ?? 0}ms',
            style: TextStyle(fontSize: 12.wMin, color: AppTheme.cTextTertiary),
          ),
          IconButton(
            onPressed: widget.enabled ? () => _deleteKTag(dialogueIndex, tagIndex) : null,
            icon: Icon(Icons.delete, color: AppTheme.cTextTertiary, size: 16.wMin),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPlayerBar() {
    final Color accent =
        _isWordMode ? AppTheme.cSurfaceWarning : AppTheme.cFeedbackSuccessText;
    return Padding(
      padding: EdgeInsets.all(16.wMin),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 70.wMin, vertical: 16.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfacePrimary,
          border: Border(top: BorderSide(color: accent, width: 1.wMin)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 120.wMin,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.cBgSecondary,
                borderRadius: BorderRadius.circular(10.wMin),
              ),
              child: _buildWaveformArea(),
            ),
            SizedBox(height: 12.wMin),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  width: 240.wMin,
                  child: Text(
                    '${KaraokeSubtitlesUtils.parseTimeToString(_currentTime)} / ${KaraokeSubtitlesUtils.parseTimeToString(_totalDurationTime)}',
                    style: TextStyle(
                      fontSize: 15.wMin,
                      color: AppTheme.cTextPrimary,
                      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        if ((_activeDialogueIndex ?? 0) > 0) {
                          unawaited(_focusOnDialogue((_activeDialogueIndex ?? 0) - 1));
                        }
                      },
                      child: Text('上一句', style: TextStyle(fontSize: 18.wMin, color: AppTheme.cTextPrimary)),
                    ),
                    SizedBox(width: 8.wMin),
                    IconButton(
                      onPressed: _togglePlayPause,
                      icon: Container(
                        width: 40.wMin,
                        height: 40.wMin,
                        decoration: BoxDecoration(
                          color: AppTheme.cBgBrand.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: AppTheme.cTextBrand,
                          size: 26.wMin,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.wMin),
                    GestureDetector(
                      onTap: () {
                        final int current = _activeDialogueIndex ?? 0;
                        if (current + 1 < _dialogueList.length) {
                          unawaited(_focusOnDialogue(current + 1));
                        }
                      },
                      child: Text('下一句', style: TextStyle(fontSize: 18.wMin, color: AppTheme.cTextPrimary)),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextButton(onPressed: () => setState(() => _zoomLevel = (_zoomLevel - 0.5).clamp(1.0, 20.0)), child: const Text('缩小')),
                    Text(
                      '${(_zoomLevel * 100).toInt()}%',
                      style: TextStyle(fontSize: 14.wMin, color: AppTheme.cTextTertiary),
                    ),
                    TextButton(onPressed: () => setState(() => _zoomLevel = (_zoomLevel + 0.5).clamp(1.0, 20.0)), child: const Text('放大')),
                    TextButton(onPressed: () => setState(() => _zoomLevel = 2.5), child: const Text('重置')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveformArea() {
    if (_waveformError != null) {
      return Center(child: Text('Error: $_waveformError'));
    }
    if (_loadingMedia || _waveform == null) {
      return Center(
        child: Text(
          '${(_waveformProgress * 100).toInt()}%',
          style: TextStyle(fontSize: 26.wMin, color: AppTheme.cTextPrimary),
        ),
      );
    }
    final int displayStartMs = 0;
    final int displayDurationMs = _waveform!.duration.inMilliseconds;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double contentArea = (constraints.maxWidth - 40.wMin).clamp(1.0, double.infinity).toDouble();
        final double baseRatio = contentArea / 60000;
        final double minRatio = displayDurationMs <= 0 ? baseRatio : contentArea / displayDurationMs;
        final double effectiveRatio = (baseRatio * _zoomLevel) < minRatio ? minRatio : (baseRatio * _zoomLevel);
        final double width = displayDurationMs * effectiveRatio;
        return SingleChildScrollView(
          controller: _waveScrollController,
          scrollDirection: Axis.horizontal,
          child: GestureDetector(
            onTapUp: (details) {
              final double ratio = ((details.localPosition.dx - 20.wMin) / width).clamp(0.0, 1.0);
              unawaited(_seekTo((ratio * displayDurationMs).toInt()));
            },
            child: Stack(
              children: <Widget>[
                Container(
                  width: width + 40.wMin,
                  height: 120.wMin,
                  color: _isWordMode ? AppTheme.cBgSecondary : AppTheme.cBgQuaternary,
                ),
                Positioned(
                  left: 20.wMin,
                  top: 0,
                  width: width,
                  height: 120.wMin,
                  child: AudioWaveformWidget(
                    waveform: _waveform!,
                    start: Duration(milliseconds: displayStartMs),
                    duration: Duration(milliseconds: displayDurationMs),
                    waveColor: (_isWordMode ? AppTheme.cSurfaceWarning : AppTheme.cFeedbackSuccessText).withOpacity(0.3),
                  ),
                ),
                ...List<Widget>.generate(_dialogueList.length, (int index) {
                  final DialogueModel dialogue = _dialogueList[index];
                  final int start = dialogue.startTime ?? 0;
                  final int end = dialogue.endTime ?? start;
                  final double left = ((start / displayDurationMs) * width) + 20.wMin;
                  final double segWidth = (((end - start) / displayDurationMs) * width).clamp(0.0, double.infinity);
                  final bool active = _activeDialogueIndex == index || _showCaptionDialogueIndex == index;
                  return Positioned(
                    left: left,
                    top: 0,
                    width: segWidth,
                    height: 120.wMin,
                    child: Container(
                      color: active ? AppTheme.cTextBrand.withOpacity(0.2) : const Color.fromRGBO(255, 255, 255, 0.05),
                    ),
                  );
                }),
                Positioned(
                  left: (((_currentTime / displayDurationMs) * width).clamp(0.0, width)) + 20.wMin - 1.wMin,
                  top: 0,
                  width: 2.wMin,
                  height: 120.wMin,
                  child: Container(color: const Color(0xffFF2D46)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
