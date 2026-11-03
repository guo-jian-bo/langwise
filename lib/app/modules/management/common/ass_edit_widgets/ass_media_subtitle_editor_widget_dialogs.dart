part of 'ass_media_subtitle_editor_widget.dart';

extension _AssMediaSubtitleEditorWidgetDialogsMethods
    on _AssMediaSubtitleEditorWidgetState {
  Widget _buildBody() {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1640.wMin),
            child: SingleChildScrollView(
              child: _editDialogueIndex != null
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _dialogueList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildDialogueCell(index);
                      },
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _dialogueList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return LongPressDraggable<DialogueModel>(
                          data: _dialogueList[index],
                          feedback: Material(
                            color: Colors.transparent,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 1640.wMin),
                              child: _buildDialogueCell(index),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: _buildDialogueCell(index),
                          ),
                          child: DragTarget<DialogueModel>(
                            builder: (
                              BuildContext context,
                              List<DialogueModel?> candidateData,
                              List<dynamic> rejectedData,
                            ) {
                              return _buildDialogueCell(
                                index,
                                isDropTarget: candidateData.isNotEmpty,
                              );
                            },
                            onAcceptWithDetails:
                                (DragTargetDetails<DialogueModel>
                                    details) async {
                              final DialogueModel source = details.data;
                              final DialogueModel target = _dialogueList[index];
                              final int sourceIndex =
                                  _dialogueList.indexOf(source);
                              if (sourceIndex == -1 || sourceIndex == index) {
                                return;
                              }
                              if ((source.index! - target.index!).abs() != 1) {
                                _showMessage('仅支持连续2个进行合并!');
                                return;
                              }
                              if (_isPlaying) {
                                await _audioPlayer?.pause();
                                _isPlayingValue = false;
                                _updateState();
                              }
                              final DialogueModel merged =
                                  KaraokeSubtitlesUtils.mergeDialogueModel(
                                _cloneDialogue(source),
                                _cloneDialogue(target),
                              );
                              final int firstIndex =
                                  sourceIndex < index ? sourceIndex : index;
                              final int secondIndex =
                                  sourceIndex < index ? index : sourceIndex;
                              for (final int removeIndex in <int>[
                                secondIndex,
                                firstIndex
                              ]) {
                                _dialogueList.removeAt(removeIndex);
                                _zhControllers.removeAt(removeIndex).dispose();
                                for (final TextEditingController controller
                                    in _kTextControllers
                                        .removeAt(removeIndex)) {
                                  controller.dispose();
                                }
                                for (final FocusNode focusNode
                                    in _kTagFocusNodes.removeAt(removeIndex)) {
                                  focusNode.dispose();
                                }
                                for (final TextEditingController controller
                                    in _timeControllers.removeAt(removeIndex)) {
                                  controller.dispose();
                                }
                              }
                              merged.index = firstIndex;
                              _dialogueList.insert(firstIndex, merged);
                              _zhControllers.insert(
                                firstIndex,
                                TextEditingController(
                                    text: merged.zhDialogueStr ?? ''),
                              );
                              _kTextControllers.insert(
                                firstIndex,
                                (merged.kTagList ?? <KTagModel>[])
                                    .map(
                                      (KTagModel item) => TextEditingController(
                                        text: item.text ?? '',
                                      ),
                                    )
                                    .toList(),
                              );
                              _kTagFocusNodes.insert(
                                firstIndex,
                                (merged.kTagList ?? <KTagModel>[])
                                    .map((_) => FocusNode())
                                    .toList(),
                              );
                              _timeControllers
                                  .insert(firstIndex, <TextEditingController>[
                                TextEditingController(
                                    text: merged.startTimeStr),
                                TextEditingController(text: merged.endTimeStr),
                              ]);
                              for (int i = 0; i < _dialogueList.length; i++) {
                                _dialogueList[i].index = i;
                              }
                              _emitChanged();
                              _updateState();
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
        Positioned(
          right: 6.wMin,
          bottom: 20.wMin,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 10.wMin,
            children: <Widget>[
              if (widget.rightToolButtons != null) ...widget.rightToolButtons!,
              Visibility(
                visible: !widget.hideAddSentence,
                child: EditorSidebarBtnWidget(
                  text: "添加句子",
                  color: AppTheme.cMorphemeTagPrefix.color,
                  onTap: () {
                    if (widget.enabled) {
                      _showAddDialogueDialog();
                    }
                  },
                ),
              ),
              _isMergeMode
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        EditorSidebarBtnWidget(
                          text: '合并(${_mergeSelectedIndices.length})',
                          color: _canMergeSelected
                              ? AppTheme.cMorphemeTagCombiningForm
                              : AppTheme.cTextTertiary,
                          width: 90.wMin,
                          onTap: () {
                            _mergeSelectedDialogues();
                          },
                        ),
                        SizedBox(width: 10.wMin),
                        EditorSidebarBtnWidget(
                          text: '取消',
                          color: AppTheme.cTextTertiary,
                          width: 90.wMin,
                          onTap: () {
                            _toggleMergeMode();
                          },
                        ),
                      ],
                    )
                  : EditorSidebarBtnWidget(
                      text: '多选合并',
                      color: AppTheme.cMorphemeTagCombiningForm,
                      onTap: () {
                        _toggleMergeMode();
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }

  void _refreshDialogue(int dialogueIndex, {bool notify = true}) {
    final DialogueModel dialogue = _dialogueList[dialogueIndex];
    final List<KTagModel> tags = dialogue.kTagList ?? <KTagModel>[];
    for (int i = 0; i < tags.length; i++) {
      if (i == 0) {
        tags[i].startTime = dialogue.startTime;
      } else {
        tags[i].startTime =
            (tags[i - 1].startTime ?? 0) + (tags[i - 1].duration ?? 0);
      }
    }
    if (tags.isNotEmpty) {
      tags.last.rightSpace = '';
    }
    dialogue.text = KaraokeSubtitlesUtils.buildDialogueTextFromKTags(tags);
    dialogue.kTagText = KaraokeSubtitlesUtils.buildKTagTextFromKTags(tags);
    if (notify) {
      _emitChanged();
    }
    _updateState();
  }

  void _startEditingDialogue(int index) {
    if (index < 0 || index >= _dialogueList.length) return;
    _editingBackupDialogue = _cloneDialogue(_dialogueList[index]);
    _editingBackupDialogueIndex = index;
    for (final dialogue in _dialogueList) {
      dialogue.isEdit = false;
    }
    _dialogueList[index].isEdit = true;
    _editDialogueIndex = index;
    _activeDialogueIndex = index;
    unawaited(_resetWaveformView());
    unawaited(_playDialogueSegmentFromTime(
        index, _dialogueList[index].startTime ?? 0));
    _updateState();
  }

  Future<void> _saveEditingDialogue(int index) async {
    if (index < 0 || index >= _dialogueList.length) return;
    final bool wasPlaying = _isPlaying;
    _endEditingCurrentKTag();
    await _exitWordModePlayback(keepPlaying: wasPlaying);
    _dialogueList[index].isEdit = false;
    _editDialogueIndex = null;
    _editingBackupDialogue = null;
    _editingBackupDialogueIndex = null;
    await _resetWaveformView();
    _emitChanged();
    _updateState();
  }

  Future<void> _cancelEditingDialogue(int index) async {
    if (index < 0 || index >= _dialogueList.length) return;
    final bool wasPlaying = _isPlaying;
    _endEditingCurrentKTag();
    await _exitWordModePlayback(keepPlaying: wasPlaying);
    if (_editingBackupDialogue != null &&
        _editingBackupDialogueIndex == index) {
      _restoreDialogueFromBackup(index, _editingBackupDialogue!);
    }
    _dialogueList[index].isEdit = false;
    _editDialogueIndex = null;
    _editingBackupDialogue = null;
    _editingBackupDialogueIndex = null;
    await _resetWaveformView();
    _updateState();
  }

  Future<void> _confirmSaveEditingDialogue(int index) async {
    await _saveEditingDialogue(index);
  }

  void _addKTag(int dialogueIndex) {
    if (dialogueIndex < 0 || dialogueIndex >= _dialogueList.length) return;
    final DialogueModel dialogue = _dialogueList[dialogueIndex];
    final List<KTagModel> tags = dialogue.kTagList ?? <KTagModel>[];
    final int insertAfterIndex;
    if (_isWordMode && _editDialogueIndex == dialogueIndex) {
      insertAfterIndex = _findKTagIndexByTime(dialogueIndex, _currentTime) ??
          (tags.isEmpty ? -1 : tags.length - 1);
    } else {
      insertAfterIndex = tags.isEmpty ? -1 : tags.length - 1;
    }

    final int insertIndex = (insertAfterIndex + 1).clamp(0, tags.length);
    const int defaultDurationMs = 50;
    final KTagModel kTag = KTagModel(
      startTime: 0,
      duration: defaultDurationMs,
      text: 'value',
      rightSpace: insertIndex == tags.length ? '' : ' ',
      kTagText: '{\\k${(defaultDurationMs / 10).toInt()}}value',
      isEdit: false,
    );

    tags.insert(insertIndex, kTag);
    _kTextControllers[dialogueIndex].insert(
      insertIndex,
      TextEditingController(text: 'value'),
    );
    _kTagFocusNodes[dialogueIndex].insert(insertIndex, FocusNode());

    if (insertIndex < tags.length - 1) {
      final KTagModel next = tags[insertIndex + 1];
      final int nextDuration = next.duration ?? 0;
      if (nextDuration > defaultDurationMs + 1) {
        next.duration = nextDuration - defaultDurationMs;
      }
    }

    final int start = dialogue.startTime ?? 0;
    final int end = dialogue.endTime ?? start;
    final int span = (end - start).clamp(1, 1 << 30);
    for (final KTagModel item in tags) {
      item.duration = (item.duration ?? 1).clamp(1, span);
    }
    int total = 0;
    for (final KTagModel item in tags) {
      total += item.duration ?? 0;
    }
    if (total != span && tags.isNotEmpty) {
      final KTagModel last = tags.last;
      final int lastDuration = last.duration ?? 1;
      final int fixed = (lastDuration + (span - total)).clamp(1, span);
      last.duration = fixed;
      last.kTagText = '{\\k${(fixed / 10).toInt()}}${last.text ?? ''}';
    }

    _refreshDialogue(dialogueIndex, notify: false);
    _currentTime = tags[insertIndex].startTime ?? _currentTime;
    _setEditingKTag(dialogueIndex, insertIndex);
    _emitChanged();
  }

  void _deleteKTag(int dialogueIndex, int kTagIndex) {
    final List<KTagModel> tags =
        _dialogueList[dialogueIndex].kTagList ?? <KTagModel>[];
    if (kTagIndex < 0 || kTagIndex >= tags.length) return;
    tags.removeAt(kTagIndex);
    _kTextControllers[dialogueIndex].removeAt(kTagIndex).dispose();
    _kTagFocusNodes[dialogueIndex].removeAt(kTagIndex).dispose();
    if (_showCaptionDialogueIndex == dialogueIndex &&
        _showCaptionKTagIndex == kTagIndex) {
      _showCaptionDialogueIndex = null;
    }
    _refreshDialogue(dialogueIndex);
  }

  void _swapKTag(int dialogueIndex, KTagModel tag, int index) {
    final List<KTagModel> tags =
        _dialogueList[dialogueIndex].kTagList ?? <KTagModel>[];
    final int fromIndex = tags.indexOf(tag);
    if (fromIndex == -1 || fromIndex == index) return;
    final KTagModel movedTag = tags.removeAt(fromIndex);
    final TextEditingController movedController =
        _kTextControllers[dialogueIndex].removeAt(fromIndex);
    final FocusNode movedFocusNode =
        _kTagFocusNodes[dialogueIndex].removeAt(fromIndex);
    final int targetIndex = fromIndex < index ? index - 1 : index;
    tags.insert(targetIndex, movedTag);
    _kTextControllers[dialogueIndex].insert(targetIndex, movedController);
    _kTagFocusNodes[dialogueIndex].insert(targetIndex, movedFocusNode);
    _refreshDialogue(dialogueIndex);
  }

  void _setEditingKTag(int dialogueIndex, int kTagIndex,
      {bool requestFocus = true}) {
    if (dialogueIndex < 0 || dialogueIndex >= _dialogueList.length) return;
    final List<KTagModel> tags =
        _dialogueList[dialogueIndex].kTagList ?? <KTagModel>[];
    if (kTagIndex < 0 || kTagIndex >= tags.length) return;
    for (final KTagModel kTag in tags) {
      kTag.isEdit = false;
    }
    tags[kTagIndex].isEdit = true;
    _updateState();

    if (requestFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (dialogueIndex >= 0 && dialogueIndex < _kTagFocusNodes.length) {
          final List<FocusNode> focusList = _kTagFocusNodes[dialogueIndex];
          if (kTagIndex >= 0 && kTagIndex < focusList.length) {
            focusList[kTagIndex].requestFocus();
          }
        }
      });
    }
  }

  void _beginEditingKTag(int dialogueIndex, int kTagIndex) {
    if (!_isWordMode || _editDialogueIndex != dialogueIndex) return;
    _setEditingKTag(dialogueIndex, kTagIndex);
  }

  void _endEditingCurrentKTag() {
    final int? dialogueIndex = _editDialogueIndex;
    if (dialogueIndex == null ||
        dialogueIndex < 0 ||
        dialogueIndex >= _dialogueList.length) {
      return;
    }
    bool changed = false;
    for (final KTagModel kTag
        in _dialogueList[dialogueIndex].kTagList ?? <KTagModel>[]) {
      if (kTag.isEdit) {
        kTag.isEdit = false;
        changed = true;
      }
    }
    if (changed) {
      _updateState();
    }
  }

  void _toggleMergeMode() {
    _isMergeMode = !_isMergeMode;
    _mergeSelectedIndices.clear();
    _updateState();
  }

  bool get _canMergeSelected {
    if (_mergeSelectedIndices.length < 2) return false;
    final List<int> sorted = _mergeSelectedIndices.toList()..sort();
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i] != sorted[i - 1] + 1) return false;
    }
    return true;
  }

  void _mergeSelectedDialogues() async {
    if (!_canMergeSelected) {
      _showMessage('仅支持选择相邻句子合并');
      return;
    }
    if (_isPlaying) {
      await _audioPlayer?.pause();
      _isPlayingValue = false;
      _updateState();
    }
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
      for (final focusNode in _kTagFocusNodes.removeAt(index)) {
        focusNode.dispose();
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
    _kTagFocusNodes.insert(
      sorted.first,
      (merged.kTagList ?? <KTagModel>[]).map((_) => FocusNode()).toList(),
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
    _activeDialogueIndex = sorted.first;
    _emitChanged();
    _updateState();
  }

  void _showMessage(String text) {
    ToastUtils.showToast(text: text);
  }

  Future<void> _deleteDialogue(int dialogueIndex) async {
    if (_dialogueList.length == 1) return ToastUtils.showToast(text: "最少保留一句");
    if (dialogueIndex < 0 || dialogueIndex >= _dialogueList.length) {
      return;
    }
    if (_isPlaying) {
      await _audioPlayer?.pause();
      _isPlayingValue = false;
    }
    _dialogueList.removeAt(dialogueIndex);
    _zhControllers.removeAt(dialogueIndex).dispose();
    for (final TextEditingController controller
        in _kTextControllers.removeAt(dialogueIndex)) {
      controller.dispose();
    }
    for (final FocusNode focusNode in _kTagFocusNodes.removeAt(dialogueIndex)) {
      focusNode.dispose();
    }
    for (final TextEditingController controller
        in _timeControllers.removeAt(dialogueIndex)) {
      controller.dispose();
    }
    if (_editDialogueIndex == dialogueIndex) {
      _editDialogueIndex = null;
    }
    if (_showCaptionDialogueIndex == dialogueIndex) {
      _showCaptionDialogueIndex = null;
    }
    for (int i = 0; i < _dialogueList.length; i++) {
      _dialogueList[i].index = i;
    }
    _emitChanged();
    _updateState();
  }

  List<String> _getAvailableSplitPunctuation(int dialogueIndex) {
    if (dialogueIndex < 0 || dialogueIndex >= _dialogueList.length) {
      return const <String>[];
    }
    final String text = _dialogueList[dialogueIndex].text ?? '';
    const List<String> candidates = <String>[
      '，',
      '。',
      ',',
      '.',
      '！',
      '？',
      '!',
      '?',
      '；',
      '：',
      ';',
      ':',
      '…',
    ];
    final List<String> result = <String>[];
    for (final String punctuation in candidates) {
      if (text.contains(punctuation)) {
        result.add(punctuation);
      }
    }
    return result;
  }

  List<DialogueModel> _previewSplitDialogue(
      int dialogueIndex, List<String> selectedPunctuation) {
    if (dialogueIndex < 0 || dialogueIndex >= _dialogueList.length) {
      return const <DialogueModel>[];
    }
    if (selectedPunctuation.isEmpty) {
      return <DialogueModel>[_cloneDialogue(_dialogueList[dialogueIndex])];
    }
    return _splitDialogueByPunctuation(
      _cloneDialogue(_dialogueList[dialogueIndex]),
      selectedPunctuation.toSet(),
    );
  }

  List<DialogueModel> _splitDialogueByPunctuation(
    DialogueModel dialogueModel,
    Set<String> selected,
  ) {
    final List<KTagModel> kTags = dialogueModel.kTagList ?? <KTagModel>[];
    if (kTags.isEmpty) {
      return <DialogueModel>[dialogueModel];
    }
    final List<List<KTagModel>> segments = <List<KTagModel>>[
      <KTagModel>[],
    ];
    for (int i = 0; i < kTags.length; i++) {
      final KTagModel tag = kTags[i];
      segments.last.add(
        KTagModel(
          startTime: tag.startTime,
          duration: tag.duration,
          kTagText: tag.kTagText,
          text: tag.text,
          rightSpace: tag.rightSpace,
          isEdit: tag.isEdit,
        ),
      );
      final String currentText = (tag.text ?? '').trimRight();
      final bool hit = selected
          .any((String punctuation) => currentText.endsWith(punctuation));
      if (hit && i != kTags.length - 1) {
        segments.add(<KTagModel>[]);
      }
    }
    final List<List<KTagModel>> valid = segments
        .where((List<KTagModel> segment) => segment.isNotEmpty)
        .toList();
    if (valid.length <= 1) {
      return <DialogueModel>[dialogueModel];
    }
    final List<DialogueModel> result = <DialogueModel>[];
    for (int i = 0; i < valid.length; i++) {
      final List<KTagModel> segment = valid[i];
      final DialogueModel item = DialogueModel();
      item.zhDialogueStr = null;
      item.layerIndex = dialogueModel.layerIndex;
      item.prefixStr = dialogueModel.prefixStr;
      item.index = (dialogueModel.index ?? 0) + i;
      item.startTime = segment.first.startTime;
      item.endTime = i == valid.length - 1
          ? dialogueModel.endTime
          : (segment.last.startTime ?? 0) + (segment.last.duration ?? 0);
      item.kTagList = segment;
      item.kTagText = KaraokeSubtitlesUtils.buildKTagTextFromKTags(segment);
      item.text = KaraokeSubtitlesUtils.buildDialogueTextFromKTags(segment);
      result.add(item);
    }
    return result;
  }

  Future<void> _splitDialogueByPunctuationAction(
    int dialogueIndex,
    List<String> selectedPunctuation,
  ) async {
    if (dialogueIndex < 0 || dialogueIndex >= _dialogueList.length) {
      return;
    }
    if (selectedPunctuation.isEmpty) {
      return;
    }
    if (_isPlaying) {
      await _audioPlayer?.pause();
      _isPlayingValue = false;
    }
    final List<DialogueModel> splitList = _splitDialogueByPunctuation(
      _cloneDialogue(_dialogueList[dialogueIndex]),
      selectedPunctuation.toSet(),
    );
    if (splitList.length <= 1) {
      _showMessage('该句子中没有可用的拆分点');
      return;
    }

    _dialogueList.removeAt(dialogueIndex);
    _zhControllers.removeAt(dialogueIndex).dispose();
    for (final TextEditingController controller
        in _kTextControllers.removeAt(dialogueIndex)) {
      controller.dispose();
    }
    for (final FocusNode focusNode in _kTagFocusNodes.removeAt(dialogueIndex)) {
      focusNode.dispose();
    }
    for (final TextEditingController controller
        in _timeControllers.removeAt(dialogueIndex)) {
      controller.dispose();
    }

    for (int i = 0; i < splitList.length; i++) {
      final DialogueModel dialogue = splitList[i];
      _dialogueList.insert(dialogueIndex + i, dialogue);
      _zhControllers.insert(
        dialogueIndex + i,
        TextEditingController(text: dialogue.zhDialogueStr ?? ''),
      );
      _kTextControllers.insert(
        dialogueIndex + i,
        (dialogue.kTagList ?? <KTagModel>[])
            .map((KTagModel tag) => TextEditingController(text: tag.text ?? ''))
            .toList(),
      );
      _kTagFocusNodes.insert(
        dialogueIndex + i,
        (dialogue.kTagList ?? <KTagModel>[]).map((_) => FocusNode()).toList(),
      );
      _timeControllers.insert(dialogueIndex + i, <TextEditingController>[
        TextEditingController(text: dialogue.startTimeStr),
        TextEditingController(text: dialogue.endTimeStr),
      ]);
    }

    for (int i = 0; i < _dialogueList.length; i++) {
      _dialogueList[i].index = i;
    }
    _emitChanged();
    _updateState();
  }

  Future<void> _showSplitDialogueDialog(int dialogueIndex) async {
    final List<String> available = _getAvailableSplitPunctuation(dialogueIndex);
    final List<String> selected = <String>[];

    await AskDialog.showCustom<void>(
      context: context,
      title: '拆分句子',
      width: 720,
      showTopClose: false,
      barrierDismissible: true,
      actions: <AskDialogAction>[
        AskDialogAction(
          text: '取消',
          color: AppTheme.cBgTertiary,
          fontColor: AppTheme.cTextSecondary,
          onTap: () => Navigator.of(context).pop(),
        ),
        AskDialogAction(
          text: '确认拆分',
          color: AppTheme.cMorphemeTagSuffix,
          onTap: () async {
            if (selected.isEmpty) return;
            await _splitDialogueByPunctuationAction(dialogueIndex, selected);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ],
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          final List<DialogueModel> preview =
              _previewSplitDialogue(dialogueIndex, selected);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '当前句子',
                style: TextStyle(
                  fontSize: 14.wMin,
                  color: AppTheme.cTextSecondary,
                ),
              ),
              SizedBox(height: 10.wMin),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.wMin),
                decoration: BoxDecoration(
                  color: AppTheme.cBgTertiary,
                  borderRadius: BorderRadius.circular(12.wMin),
                ),
                child: Text(
                  _dialogueList[dialogueIndex].text ?? '',
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: AppTheme.cTextPrimary,
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(height: 16.wMin),
              Text(
                '选择分割标点',
                style: TextStyle(
                  fontSize: 14.wMin,
                  color: AppTheme.cTextSecondary,
                ),
              ),
              SizedBox(height: 10.wMin),
              if (available.isEmpty)
                Text(
                  '该句子中没有可用的标点符号',
                  style: TextStyle(
                    fontSize: 13.wMin,
                    color: AppTheme.cTextDisabled,
                  ),
                )
              else
                Wrap(
                  spacing: 10.wMin,
                  runSpacing: 10.wMin,
                  children: available.map((String punctuation) {
                    final bool isOn = selected.contains(punctuation);
                    final Color color = AppTheme.cMorphemeTagSuffix;
                    return TapScaleWidget(
                      sclae: 1.03,
                      onTap: () {
                        setState(() {
                          if (isOn) {
                            selected.remove(punctuation);
                          } else {
                            selected.add(punctuation);
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.wMin,
                          vertical: 10.wMin,
                        ),
                        decoration: BoxDecoration(
                          color: isOn
                              ? color.withOpacity(0.12)
                              : AppTheme.cBgTertiary,
                          borderRadius: BorderRadius.circular(12.wMin),
                          border: Border.all(
                            color: isOn ? color : AppTheme.cBorderPrimary,
                            width: 1.wMin,
                          ),
                        ),
                        child: Text(
                          punctuation,
                          style: TextStyle(
                            fontSize: 16.wMin,
                            color: isOn ? color : AppTheme.cTextPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              SizedBox(height: 16.wMin),
              Text(
                '预览效果',
                style: TextStyle(
                  fontSize: 14.wMin,
                  color: AppTheme.cTextSecondary,
                ),
              ),
              SizedBox(height: 10.wMin),
              Container(
                width: double.infinity,
                constraints: BoxConstraints(maxHeight: 280.wMin),
                padding: EdgeInsets.all(10.wMin),
                decoration: BoxDecoration(
                  color: AppTheme.cBgTertiary,
                  borderRadius: BorderRadius.circular(12.wMin),
                ),
                child: preview.length <= 1
                    ? Text(
                        '请选择标点以预览拆分效果',
                        style: TextStyle(
                          fontSize: 13.wMin,
                          color: AppTheme.cTextDisabled,
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: preview.length,
                        separatorBuilder: (_, __) => SizedBox(height: 8.wMin),
                        itemBuilder: (BuildContext context, int index) {
                          final DialogueModel dialogue = preview[index];
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.wMin,
                              vertical: 10.wMin,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.cMorphemeTagSuffix.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12.wMin),
                              border: Border.all(
                                color: AppTheme.cMorphemeTagSuffix
                                    .withOpacity(0.25),
                                width: 1.wMin,
                              ),
                            ),
                            child: Text(
                              '${KaraokeSubtitlesUtils.parseTimeToString(dialogue.startTime ?? 0)} → ${dialogue.text ?? ''}',
                              style: TextStyle(
                                fontSize: 13.wMin,
                                color: AppTheme.cTextPrimary,
                                height: 1.35,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showAddDialogueDialog() async {
    final int? anchorIndex =
        _activeDialogueIndex ?? _showCaptionDialogueIndex ?? _editDialogueIndex;
    if (anchorIndex == null ||
        anchorIndex < 0 ||
        anchorIndex >= _dialogueList.length) {
      _showMessage('请先选择一句');
      return;
    }
    final TextEditingController controller = TextEditingController();
    await AskDialog.showCustom<void>(
      context: context,
      title: '添加句子',
      width: 720,
      showTopClose: false,
      barrierDismissible: true,
      actions: <AskDialogAction>[
        AskDialogAction(
          text: '取消',
          color: AppTheme.cBgTertiary,
          fontColor: AppTheme.cTextSecondary,
          onTap: () => Navigator.of(context).pop(),
        ),
        AskDialogAction(
          text: '添加到当前句前面',
          color: AppTheme.cMorphemeTagPrefix,
          onTap: () {
            _insertDialogueRelative(anchorIndex, controller.text, before: true);
            Get.back();
          },
        ),
        AskDialogAction(
          text: '添加到当前句后面',
          color: AppTheme.cTextBrand,
          onTap: () {
            _insertDialogueRelative(anchorIndex, controller.text,
                before: false);
            Get.back();
          },
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '当前句子',
            style: TextStyle(
              fontSize: 14.wMin,
              color: AppTheme.cTextSecondary,
            ),
          ),
          SizedBox(height: 10.wMin),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cBgTertiary,
              borderRadius: BorderRadius.circular(12.wMin),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${KaraokeSubtitlesUtils.parseTimeToString(_dialogueList[anchorIndex].startTime ?? 0)} - ${KaraokeSubtitlesUtils.parseTimeToString(_dialogueList[anchorIndex].endTime ?? 0)}',
                  style: TextStyle(
                    fontSize: 12.wMin,
                    color: AppTheme.cTextSecondary,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 6.wMin),
                Text(
                  _dialogueList[anchorIndex].text ?? '',
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: AppTheme.cTextPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.wMin),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '输入句子文本（单词以空格分隔）。',
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
              height: 1.4,
            ),
          ),
        ],
      ),
    );
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
      _showMessage(before ? '当前句前没有可用空隙' : '当前句后没有可用空隙');
      return;
    }

    final String defaultPrefix = (() {
      if (insertIndex > 0) {
        return _dialogueList[insertIndex - 1].prefixStr ?? '';
      }
      if (insertIndex < _dialogueList.length) {
        return _dialogueList[insertIndex].prefixStr ?? '';
      }
      return '';
    })();

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
          rightSpace: i == words.length - 1 ? '' : ' ',
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
      kTagText: KaraokeSubtitlesUtils.buildKTagTextFromKTags(tags),
      text: KaraokeSubtitlesUtils.buildDialogueTextFromKTags(tags),
      zhDialogueStr: null,
      layerIndex: anchor.layerIndex,
    );
    dialogue.prefixStr =
        defaultPrefix.isNotEmpty ? defaultPrefix : 'Default,,0,0,0,';

    _dialogueList.insert(insertIndex, dialogue);
    _zhControllers.insert(insertIndex, TextEditingController());
    _kTextControllers.insert(
      insertIndex,
      tags.map((item) => TextEditingController(text: item.text ?? '')).toList(),
    );
    _kTagFocusNodes.insert(
      insertIndex,
      tags.map((_) => FocusNode()).toList(),
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
    _emitChanged();
    _updateState();
  }

  Widget _buildDialogueCell(int index, {bool isDropTarget = false}) {
    final DialogueModel dialogue = _dialogueList[index];
    final bool isBlankCellByRegex =
        KaraokeSubtitlesUtils.publicRegexBlank.hasMatch(dialogue.text ?? '') ||
            KaraokeSubtitlesUtils.publicRegexBlank
                .hasMatch(dialogue.kTagText ?? '');
    final bool isPlaying = _isPlaying;
    final int cur = _currentTime;
    final int end = dialogue.endTime ?? 0;
    final int? nextStart = (index + 1 < _dialogueList.length)
        ? _dialogueList[index + 1].startTime
        : null;
    final bool isGapBlank = !_isWordMode &&
        isPlaying &&
        nextStart != null &&
        nextStart > end &&
        cur >= end &&
        cur < nextStart;
    final bool isBlankCell = isBlankCellByRegex || isGapBlank;
    final bool isPointPlay =
        (_activeDialogueIndex == index || _showCaptionDialogueIndex == index) &&
            !isGapBlank;
    final bool isWordModeCell = _isWordMode && _editDialogueIndex == index;
    final bool isActiveStyle = (isWordModeCell || isPointPlay) && !isBlankCell;

    final Color defaultBg = AppTheme.cBgTertiary;
    final Color defaultBorder = AppTheme.cBgQuaternary;
    final Color activeAccent =
        isWordModeCell ? AppTheme.cSurfaceWarning : AppTheme.cTextBrand;
    final Color blankAccent = AppTheme.cTextBrand;
    final Color bgColor = isBlankCell
        ? const Color(0x0D38BDF8)
        : isActiveStyle
            ? const Color(0x08F97316)
            : defaultBg;
    final Color borderColor = isBlankCell
        ? blankAccent
        : isActiveStyle
            ? activeAccent
            : defaultBorder;
    final Color indexBgColor = isBlankCell
        ? blankAccent
        : isActiveStyle
            ? activeAccent
            : defaultBorder;

    return Padding(
      key: Key('dialogueCellWidget$index'),
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
                _updateState();
                return;
              }
              if (_isWordMode && _editDialogueIndex != index) {
                _showMessage('请先保存当前句子的编辑');
                return;
              }
              if (_isWordMode && _editDialogueIndex == index) {
                unawaited(_togglePlayPause());
                return;
              }
              unawaited(_focusOnDialogue(index, stopAtSentenceEnd: true));
            },
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12.wMin),
                border: Border.all(
                  color: isDropTarget
                      ? AppTheme.cBgBrand
                      : _mergeSelectedIndices.contains(index)
                          ? AppTheme.cFeedbackSuccessIcon
                          : borderColor,
                  width: 1.0,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.wMin),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 18.wMin,
                          height: 18.wMin,
                          decoration: BoxDecoration(
                            color: indexBgColor,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 11.wMin,
                              color: AppTheme.cTextPrimary,
                              height: 1.0,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.wMin),
                        Expanded(
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
                              SizedBox(height: 8.wMin),
                              _buildZhCaptionsWidget(index),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (dialogue.isEdit) ...<Widget>[
                      SizedBox(height: 12.wMin),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10.wMin),
                          border: Border.all(
                            color: const Color(0xffFFFFFF).withOpacity(0.15),
                            width: 1.0,
                          ),
                        ),
                        padding: EdgeInsets.all(12.wMin),
                        child: _buildEditPanel(index),
                      ),
                      Visibility(
                        visible: !widget.hideTranslation,
                        child: Column(
                          children: [
                            SizedBox(height: 12.wMin),
                            TextFormField(
                              controller: _zhControllers[index],
                              decoration: InputDecoration(
                                hintText: '请输入翻译',
                                hintStyle: TextStyle(
                                  fontSize: 16.wMin,
                                  color: AppTheme.cTextPrimary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.wMin),
                                ),
                                filled: true,
                                fillColor:
                                    const Color(0xffFFFFFF).withOpacity(0.15),
                              ),
                              style: TextStyle(
                                fontSize: 16.wMin,
                                color: AppTheme.cTextPrimary,
                              ),
                              onChanged: (String value) {
                                dialogue.zhDialogueStr = value;
                                _refreshDialogue(index);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 16.wMin),
                    Divider(
                      color: defaultBorder,
                      height: 1.wMin,
                      thickness: 1.wMin,
                    ),
                    SizedBox(height: 12.wMin),
                    Row(
                      children: <Widget>[
                        if (_isMergeMode)
                          Text(
                            _mergeSelectedIndices.contains(index)
                                ? '已选'
                                : '点击选择',
                            style: TextStyle(
                              color: AppTheme.cFeedbackSuccessIcon,
                              fontSize: 12.wMin,
                            ),
                          ),
                        const Spacer(),
                        if (isWordModeCell) ...<Widget>[
                          GestureDetector(
                            onTap: () {
                              unawaited(_confirmSaveEditingDialogue(index));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.cFeedbackSuccessText,
                                borderRadius: BorderRadius.circular(8.wMin),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.wMin,
                                vertical: 6.wMin,
                              ),
                              child: Text(
                                '保存句子',
                                style: TextStyle(
                                  fontSize: 16.wMin,
                                  color: AppTheme.cTextPrimary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.wMin),
                          GestureDetector(
                            onTap: () {
                              unawaited(_cancelEditingDialogue(index));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.cBgTertiary,
                                borderRadius: BorderRadius.circular(8.wMin),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.wMin,
                                vertical: 6.wMin,
                              ),
                              child: Text(
                                '取消',
                                style: TextStyle(
                                  fontSize: 16.wMin,
                                  color: AppTheme.cTextSecondary,
                                ),
                              ),
                            ),
                          ),
                        ] else ...<Widget>[
                          EditorActionTagWidget(
                            text: '删除',
                            color: AppTheme.cSurfaceError,
                            onTap: widget.enabled
                                ? () {
                                    unawaited(_deleteDialogue(index));
                                  }
                                : () {},
                          ),
                          SizedBox(width: 8.wMin),
                          EditorActionTagWidget(
                            text: '拆分',
                            color: AppTheme.cMorphemeTagSuffix,
                            onTap: widget.enabled
                                ? () {
                                    _activeDialogueIndex = index;
                                    unawaited(_showSplitDialogueDialog(index));
                                  }
                                : () {},
                          ),
                          SizedBox(width: 8.wMin),
                          EditorActionTagWidget(
                            text: '编辑',
                            color: AppTheme.cSurfaceWarning,
                            onTap: widget.enabled
                                ? () {
                                    _activeDialogueIndex = index;
                                    _startEditingDialogue(index);
                                  }
                                : () {},
                          ),
                          SizedBox(width: 8.wMin),
                          EditorActionTagWidget(
                            text: '定位',
                            color: AppTheme.cSurfaceSuccess,
                            onTap: () {
                              unawaited(_focusOnDialogue(index));
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKaraokeText(int dialogueIndex) {
    final DialogueModel dialogue = _dialogueList[dialogueIndex];
    final List<KTagModel> tags = dialogue.kTagList ?? <KTagModel>[];
    final bool isActiveCaption = _showCaptionDialogueIndex == dialogueIndex;
    String buildDisplayText(int index) {
      final String text = tags[index].text ?? '';
      final String nextText = index + 1 < tags.length ? (tags[index + 1].text ?? '') : '';
      final bool shouldAppendDisplaySpace = nextText.isNotEmpty &&
          !RegExp(r'\s$').hasMatch(text) &&
          !RegExp(r'^\s').hasMatch(nextText);
      return shouldAppendDisplaySpace ? '$text ' : text;
    }

    final bool isBlankCellByRegex =
        KaraokeSubtitlesUtils.publicRegexBlank.hasMatch(dialogue.text ?? '') ||
            KaraokeSubtitlesUtils.publicRegexBlank
                .hasMatch(dialogue.kTagText ?? '');
    final bool isPlaying = _isPlaying;
    final int cur = _currentTime;
    final int end = dialogue.endTime ?? 0;
    final int? nextStart = (dialogueIndex + 1 < _dialogueList.length)
        ? _dialogueList[dialogueIndex + 1].startTime
        : null;
    final bool isGapBlank = !_isWordMode &&
        isPlaying &&
        nextStart != null &&
        nextStart > end &&
        cur >= end &&
        cur < nextStart;
    final bool isBlankCell = isBlankCellByRegex || isGapBlank;
    final bool isPointPlay = (_activeDialogueIndex == dialogueIndex ||
            _showCaptionDialogueIndex == dialogueIndex) &&
        !isGapBlank;
    final bool isWordModeCell =
        _isWordMode && _editDialogueIndex == dialogueIndex;
    final bool isActiveStyle = (isWordModeCell || isPointPlay) && !isBlankCell;
    final Color activeAccent = AppTheme.cSurfaceWarning;

    if (!isActiveCaption || tags.isEmpty) {
      return SelectableText(
        tags.isEmpty
            ? (dialogue.text ?? '')
            : List<String>.generate(tags.length, buildDisplayText).join(),
        style: TextStyle(fontSize: 20.wMin, color: AppTheme.cTextPrimary),
      );
    }

    final bool useWordModeHighlight =
        _isWordMode && _editDialogueIndex == dialogueIndex;
    int wordModeActiveKTagIdx = -1;
    if (useWordModeHighlight) {
      for (int wi = 0; wi < tags.length; wi++) {
        final int kStart = tags[wi].startTime ?? 0;
        final int kEnd = (wi + 1 < tags.length)
            ? (tags[wi + 1].startTime ?? (kStart + (tags[wi].duration ?? 0)))
            : (dialogue.endTime ?? (kStart + (tags[wi].duration ?? 0)));
        if (_currentTime >= kStart && _currentTime < kEnd) {
          wordModeActiveKTagIdx = wi;
          break;
        }
      }
    }

    final List<TextSpan> spans = <TextSpan>[];
    for (int i = 0; i < tags.length; i++) {
      final String text = tags[i].text ?? '';
      if (text.isEmpty) continue;
      final String displayText = buildDisplayText(i);
      final bool isPassed = useWordModeHighlight
          ? (wordModeActiveKTagIdx >= 0 && i < wordModeActiveKTagIdx)
          : i < _showCaptionKTagIndex;
      final bool isCurrent = useWordModeHighlight
          ? (i == wordModeActiveKTagIdx)
          : (i == _showCaptionKTagIndex && _showCaptionKTagProgress > 0);

      if ((isPassed || isCurrent) && isActiveStyle && !isBlankCell) {
        spans.add(
          TextSpan(
            text: displayText,
            style: TextStyle(
              fontSize: 20.wMin,
              color: activeAccent,
              decoration:
                  isCurrent ? TextDecoration.underline : TextDecoration.none,
              decorationColor: activeAccent,
            ),
          ),
        );
        continue;
      }

      spans.add(
        TextSpan(
          text: displayText,
          style: TextStyle(fontSize: 20.wMin, color: AppTheme.cTextPrimary),
        ),
      );
    }
    return SelectableText.rich(
      TextSpan(
        style: TextStyle(fontSize: 20.wMin, color: AppTheme.cTextPrimary),
        children: spans,
      ),
    );
  }

  Widget _buildZhCaptionsWidget(int dialogueIndex) {
    final DialogueModel dialogue = _dialogueList[dialogueIndex];
    if (dialogue.zhDialogueStr == null) {
      return const SizedBox.shrink();
    }
    return Text(
      dialogue.zhDialogueStr!,
      style: TextStyle(
        fontSize: 18.wMin,
        color: AppTheme.cTextPrimary,
      ),
    );
  }

  Widget _buildEditPanel(int dialogueIndex) {
    final DialogueModel dialogue = _dialogueList[dialogueIndex];
    final List<KTagModel> tags = dialogue.kTagList ?? <KTagModel>[];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 15.wMin),
        Row(
          children: <Widget>[
            Text(
              'K标签块',
              style: TextStyle(
                fontSize: 16.wMin,
                color: AppTheme.cTextTertiary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: widget.enabled ? () => _addKTag(dialogueIndex) : null,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cTextBrand.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(5.wMin),
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
                child: Text(
                  '添加块',
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: AppTheme.cTextBrand,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.wMin),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            _endEditingCurrentKTag();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300.wMin,
              mainAxisExtent: 60.wMin,
              crossAxisSpacing: 10.wMin,
              mainAxisSpacing: 10.wMin,
            ),
            itemCount: tags.length,
            itemBuilder: (BuildContext context, int index) {
              return DragTarget<KTagModel>(
                onAcceptWithDetails: (DragTargetDetails<KTagModel> details) {
                  _swapKTag(dialogueIndex, details.data, index);
                },
                builder: (context, candidateData, rejectedData) {
                  return _buildTagEditorItem(
                    dialogueIndex,
                    index,
                    candidateData.isNotEmpty,
                  );
                },
              );
            },
          ),
        ),
        SizedBox(height: 25.wMin),
        Text(
          '带K标签的文本',
          style: TextStyle(
            fontSize: 16.wMin,
            color: AppTheme.cTextTertiary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15.wMin),
        Text(
          dialogue.kTagText ?? '',
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTagEditorItem(
    int dialogueIndex,
    int tagIndex,
    bool highlight, {
    bool enableDragHandle = true,
  }) {
    final KTagModel tag = _dialogueList[dialogueIndex].kTagList![tagIndex];
    final int start = tag.startTime ?? 0;
    final List<KTagModel> list =
        _dialogueList[dialogueIndex].kTagList ?? <KTagModel>[];
    final int end = tagIndex + 1 < list.length
        ? (list[tagIndex + 1].startTime ?? (start + (tag.duration ?? 0)))
            .clamp(0, _totalDurationTime)
        : ((_dialogueList[dialogueIndex].endTime ??
                (start + (tag.duration ?? 0)))
            .clamp(0, _totalDurationTime));
    final bool isActiveByTime = _isWordMode &&
        _editDialogueIndex == dialogueIndex &&
        _currentTime >= start &&
        _currentTime < end;
    final bool itemHighlight = highlight || isActiveByTime;
    final bool isEditing = _isWordMode && tag.isEdit;
    final bool isActivePlaying = _isPlaying && isActiveByTime;
    final bool isDesktopPlatform = kIsWeb ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;

    void endEditingAndUnfocus() {
      _endEditingCurrentKTag();
      FocusManager.instance.primaryFocus?.unfocus();
    }

    void onTapPlayOrPauseCurrentKTag() {
      if (isActivePlaying) {
        unawaited(_togglePlayPause());
        return;
      }
      endEditingAndUnfocus();
      unawaited(_playFromKTagToNext(dialogueIndex, tagIndex));
    }

    Widget dragHandleChild({required MouseCursor cursor}) {
      return MouseRegion(
        cursor: cursor,
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 8.wMin),
          child: Icon(
            Icons.drag_indicator,
            color: AppTheme.cTextTertiary,
            size: 18.wMin,
          ),
        ),
      );
    }

    Widget dragFeedback() {
      return Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(
            width: 220.wMin,
            height: 60.wMin,
          ),
          child: _buildTagEditorItem(
            dialogueIndex,
            tagIndex,
            false,
            enableDragHandle: false,
          ),
        ),
      );
    }

    Widget dragHandleWidget() {
      if (!enableDragHandle) {
        return dragHandleChild(cursor: SystemMouseCursors.basic);
      }

      if (isDesktopPlatform) {
        return Draggable<KTagModel>(
          data: tag,
          feedback: dragFeedback(),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: dragHandleChild(cursor: SystemMouseCursors.grab),
          ),
          child: dragHandleChild(cursor: SystemMouseCursors.grab),
        );
      }

      return LongPressDraggable<KTagModel>(
        data: tag,
        feedback: dragFeedback(),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: dragHandleChild(cursor: SystemMouseCursors.grab),
        ),
        child: dragHandleChild(cursor: SystemMouseCursors.grab),
      );
    }

    return GestureDetector(
      onTap: onTapPlayOrPauseCurrentKTag,
      child: Container(
        key: Key('kTagWidget$dialogueIndex-$tagIndex'),
        padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 6.wMin),
        decoration: BoxDecoration(
          color: itemHighlight
              ? AppTheme.cSurfaceWarning.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(6.wMin),
          border: Border.all(
            color: itemHighlight
                ? AppTheme.cSurfaceWarning.withOpacity(0.6)
                : Colors.white.withOpacity(0.15),
            width: 1.wMin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            dragHandleWidget(),
            GestureDetector(
              onTap: onTapPlayOrPauseCurrentKTag,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(
                  width: 28.wMin,
                  height: 28.wMin,
                ),
                icon: Container(
                  width: 24.wMin,
                  height: 24.wMin,
                  decoration: BoxDecoration(
                    color: const Color(0xffffffff).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    isActivePlaying ? Icons.pause : Icons.play_arrow,
                    color: AppTheme.cTextPrimary,
                    size: 18.wMin,
                  ),
                ),
                onPressed: onTapPlayOrPauseCurrentKTag,
              ),
            ),
            SizedBox(width: 6.wMin),
            Expanded(
              child: GestureDetector(
                onTap: onTapPlayOrPauseCurrentKTag,
                onDoubleTap: () {
                  _beginEditingKTag(dialogueIndex, tagIndex);
                },
                child: Container(
                  decoration: isEditing
                      ? BoxDecoration(
                          color: AppTheme.cMorphemeTagRoot.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(6.wMin),
                          border: Border.all(
                            color: AppTheme.cMorphemeTagRoot.withOpacity(0.75),
                            width: 1.wMin,
                          ),
                        )
                      : null,
                  padding: isEditing
                      ? EdgeInsets.symmetric(
                          horizontal: 6.wMin, vertical: 2.wMin)
                      : EdgeInsets.zero,
                  child: TextField(
                    controller: _kTextControllers[dialogueIndex][tagIndex],
                    focusNode: _kTagFocusNodes[dialogueIndex][tagIndex],
                    readOnly: !tag.isEdit,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                        fontSize: 16.wMin, color: AppTheme.cTextPrimary),
                    onChanged: (String value) {
                      tag.text = value;
                      _refreshDialogue(dialogueIndex);
                    },
                    onSubmitted: (_) {
                      endEditingAndUnfocus();
                    },
                  ),
                ),
              ),
            ),
            SizedBox(width: 6.wMin),
            Text(
              '${tag.duration ?? 0}ms',
              style:
                  TextStyle(fontSize: 12.wMin, color: AppTheme.cTextTertiary),
            ),
            SizedBox(width: 6.wMin),
            GestureDetector(
              onTap: widget.enabled
                  ? () {
                      endEditingAndUnfocus();
                      _deleteKTag(dialogueIndex, tagIndex);
                    }
                  : null,
              child: Container(
                padding: EdgeInsets.all(2.wMin),
                child: Icon(
                  Icons.delete,
                  color: AppTheme.cTextTertiary,
                  size: 16.wMin,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
