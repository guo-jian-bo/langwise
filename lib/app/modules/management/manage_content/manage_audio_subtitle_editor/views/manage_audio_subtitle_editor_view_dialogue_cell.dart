part of 'manage_audio_subtitle_editor_view.dart';

extension ViewDialogueCellMixin on ManageAudioSubtitleEditorView {
  Widget buildDialogueCellWidget(int index, {bool isDropTarget = false}) {
    DialogueModel dialogueModel = controller.dialogueList[index];

    final bool isBlankCellByRegex = KaraokeSubtitlesUtils.publicRegexBlank
            .hasMatch(dialogueModel.text ?? '') ||
        KaraokeSubtitlesUtils.publicRegexBlank
            .hasMatch(dialogueModel.kTagText ?? '');

    final bool isPlaying = controller.audioPlayer?.state == PlayerState.playing;
    final int cur = controller.currentTime;
    final int end = dialogueModel.endTime ?? 0;
    final int? nextStart = (index + 1 < controller.dialogueList.length)
        ? controller.dialogueList[index + 1].startTime
        : null;
    final bool isGapBlank = !controller.isWordMode &&
        isPlaying &&
        nextStart != null &&
        nextStart > end &&
        cur >= end &&
        cur < nextStart;

    final bool isBlankCell = isBlankCellByRegex || isGapBlank;

    final bool isPointPlay = (controller.activeDialogueIndex == index ||
            controller.showCaptionDialogueIndex == index) &&
        !isGapBlank;
    final bool isWordModeCell =
        controller.isWordMode && controller.editDialogueIndex == index;
    final bool isActiveStyle = (isWordModeCell || isPointPlay) && !isBlankCell;

    final defaultBg = AppTheme.cBgTertiary;
    final defaultBorder = AppTheme.cBgQuaternary;
    final Color activeAccent =
        isWordModeCell ? AppTheme.cSurfaceWarning : AppTheme.cTextBrand;
    final blankAccent = AppTheme.cTextBrand;
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
        builder: (cellContext) {
          controller.registerDialogueCellContext(index, cellContext);
          return GestureDetector(
            onTap: () {
              if (controller.isMergeMode) {
                controller.toggleMergeSelect(index);
                return;
              }
              if (controller.isWordMode && controller.editDialogueIndex != index) {
                ToastUtils.showManageToast(text: '请先保存当前句子的编辑');
                return;
              }
              if (controller.isWordMode && controller.editDialogueIndex == index) {
                controller.audioPlayAndPause();
                return;
              }
              controller.focusOnDialogue(index);
            },
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12.wMin),
                border: Border.all(
                  color: isDropTarget
                      ? AppTheme.cBgBrand
                      : controller.mergeSelectedIndices.contains(index)
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
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                height: 1.0),
                          ),
                        ),
                        SizedBox(width: 10.wMin),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${dialogueModel.startTimeStr} - ${dialogueModel.endTimeStr}',
                                style: TextStyle(
                                  fontSize: 14.wMin,
                                  color: AppTheme.cTextPrimary,
                                ),
                              ),
                              SizedBox(height: 8.wMin),
                              _buildDialogueKaraokeTextWidget(index),
                              SizedBox(height: 8.wMin),
                              buildZHCaptionsWidget(index),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (dialogueModel.isEdit) ...[
                      SizedBox(height: 12.wMin),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10.wMin),
                          border: Border.all(
                              color: Color(0xffFFFFFF).withOpacity(0.15),
                              width: 1.0),
                        ),
                        padding: EdgeInsets.all(12.wMin),
                        child: buildEditDialogueWidget(index),
                      ),
                      SizedBox(height: 12.wMin),
                      TextFormField(
                        controller: controller.zhCaptionsTextFieldList[index],
                        decoration: InputDecoration(
                          hintText: '请输入翻译',
                          hintStyle:
                              TextStyle(fontSize: 16.wMin, color: AppTheme.cTextPrimary),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.wMin)),
                          filled: true,
                          fillColor: const Color(0xffFFFFFF).withOpacity(0.15),
                        ),
                        style:
                            TextStyle(fontSize: 16.wMin, color: AppTheme.cTextPrimary),
                        onChanged: (value) {
                          dialogueModel.zhDialogueStr = value;
                          controller.updateDialogue(index);
                        },
                      ),
                    ],
                    SizedBox(height: 16.wMin),
                    Divider(
                        color: defaultBorder,
                        height: 1.wMin,
                        thickness: 1.wMin),
                    SizedBox(height: 12.wMin),
                    Row(
                      children: [
                        if (controller.isMergeMode)
                          Text(
                            controller.mergeSelectedIndices.contains(index)
                                ? '已选'
                                : '点击选择',
                            style: TextStyle(
                                color: AppTheme.cFeedbackSuccessIcon, fontSize: 12.wMin),
                          ),
                        const Spacer(),
                        if (isWordModeCell) ...[
                          GestureDetector(
                            onTap: () {
                              controller.confirmSaveEditingDialogue(index);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.cFeedbackSuccessText,
                                borderRadius: BorderRadius.circular(8.wMin),
                                // border: Border.all(color: activeAccent, width: 1.wMin),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.wMin, vertical: 6.wMin),
                              child: Text(
                                '保存句子',
                                style: TextStyle(
                                    fontSize: 16.wMin, color: AppTheme.cTextPrimary),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.wMin),
                          GestureDetector(
                            onTap: () {
                              controller.cancelEditingDialogue(index);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.cBgTertiary,
                                borderRadius: BorderRadius.circular(8.wMin),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.wMin, vertical: 6.wMin),
                              child: Text(
                                '取消',
                                style: TextStyle(
                                    fontSize: 16.wMin,
                                    color: AppTheme.cTextSecondary),
                              ),
                            ),
                          ),
                        ]
                        else ...[
                          EditorActionTagWidget(
                            text: '删除',
                            color: AppTheme.cSurfaceError,
                            onTap: () {
                              controller.deleteDialogueModel(index);
                            },
                          ),
                          SizedBox(width: 8.wMin),
                          EditorActionTagWidget(
                            text: '拆分',
                            color: AppTheme.cMorphemeTagSuffix,
                            onTap: () {
                              controller.setActiveDialogueIndex(index);
                              showSplitDialogueDialog(index);
                            },
                          ),
                          SizedBox(width: 8.wMin),
                          EditorActionTagWidget(
                            text: '编辑',
                            color: AppTheme.cSurfaceWarning,
                            onTap: () {
                              controller.setActiveDialogueIndex(index);
                              controller.editDialogueModel(index);
                            },
                          ),
                          SizedBox(width: 8.wMin),
                          EditorActionTagWidget(
                            text: '定位',
                            color: AppTheme.cSurfaceSuccess,
                            onTap: () {
                              controller.focusOnDialogue(index);
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

  Widget buildTimeWidget(int dialogueIndex) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 110.wMin,
          height: 30.wMin,
          child: TextField(
            controller:
                controller.dialogueTimeTextFieldList[dialogueIndex].first,
            decoration: const InputDecoration(
              hintText: '请输入开始时间',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              isCollapsed: true,
            ),
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextLink,
            ),
            onSubmitted: (value) {
              controller.updateDialogueStartTime(dialogueIndex, value);
            },
          ),
        ),
        Text(
          '-',
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextLink,
          ),
        ),
        SizedBox(
          width: 20.wMin,
        ),
        SizedBox(
          width: 110.wMin,
          height: 30.wMin,
          child: TextField(
            controller:
                controller.dialogueTimeTextFieldList[dialogueIndex].last,
            decoration: const InputDecoration(
              hintText: '请输入结束时间',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              isCollapsed: true,
            ),
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextLink,
            ),
            onSubmitted: (value) {
              controller.updateDialogueEndTime(dialogueIndex, value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDialogueKaraokeTextWidget(int dialogueIndex) {


    final dialogueModel = controller.dialogueList[dialogueIndex];
    final isActiveCaption =
        controller.showCaptionDialogueIndex == dialogueIndex;

    final bool isBlankCellByRegex = KaraokeSubtitlesUtils.publicRegexBlank
            .hasMatch(dialogueModel.text ?? '') ||
        KaraokeSubtitlesUtils.publicRegexBlank
            .hasMatch(dialogueModel.kTagText ?? '');

    final bool isPlaying = controller.audioPlayer?.state == PlayerState.playing;
    final int cur = controller.currentTime;
    final int end = dialogueModel.endTime ?? 0;
    final int? nextStart = (dialogueIndex + 1 < controller.dialogueList.length)
        ? controller.dialogueList[dialogueIndex + 1].startTime
        : null;
    final bool isGapBlank = !controller.isWordMode &&
        isPlaying &&
        nextStart != null &&
        nextStart > end &&
        cur >= end &&
        cur < nextStart;

    final bool isBlankCell = isBlankCellByRegex || isGapBlank;

    final bool isPointPlay = (controller.activeDialogueIndex == dialogueIndex ||
            controller.showCaptionDialogueIndex == dialogueIndex) &&
        !isGapBlank;
    final bool isWordModeCell =
        controller.isWordMode && controller.editDialogueIndex == dialogueIndex;
    final bool isActiveStyle = (isWordModeCell || isPointPlay) && !isBlankCell;

    final activeAccent = AppTheme.cSurfaceWarning;

    if (!isActiveCaption ||
        dialogueModel.kTagList == null ||
        dialogueModel.kTagList!.isEmpty) {
      return SelectableText(
        dialogueModel.text ?? '',
        style: TextStyle(
          fontSize: 20.wMin,
          color: AppTheme.cTextPrimary,
        ),
      );
    }

    // 单词模式下：使用与 k 标签块完全相同的时间边界（下一个 kTag 的 startTime）
    // 以保证卡拉 OK 高亮与 k 标签块高亮严格对齐。
    final bool useWordModeHighlight =
        controller.isWordMode && controller.editDialogueIndex == dialogueIndex;
    int wordModeActiveKTagIdx = -1;
    if (useWordModeHighlight) {
      final kList = dialogueModel.kTagList!;
      final cur = controller.currentTime;
      for (int wi = 0; wi < kList.length; wi++) {
        final kStart = kList[wi].startTime ?? 0;
        final int kEnd = (wi + 1 < kList.length)
            ? (kList[wi + 1].startTime ?? (kStart + (kList[wi].duration ?? 0)))
            : (dialogueModel.endTime ?? (kStart + (kList[wi].duration ?? 0)));
        if (cur >= kStart && cur < kEnd) {
          wordModeActiveKTagIdx = wi;
          break;
        }
      }
    }

    final List<TextSpan> spans = [];
    for (var i = 0; i < dialogueModel.kTagList!.length; i++) {
      final k = dialogueModel.kTagList![i];
      final text = (k.text ?? '');
      if (text.isEmpty) continue;

      final bool isPassed = useWordModeHighlight
          ? (wordModeActiveKTagIdx >= 0 && i < wordModeActiveKTagIdx)
          : i < controller.showCaptionKTagIndex;
      final bool isCurrent = useWordModeHighlight
          ? (i == wordModeActiveKTagIdx)
          : (i == controller.showCaptionKTagIndex &&
              controller.showCaptionKTagProgress > 0);

      if ((isPassed || isCurrent) && isActiveStyle && !isBlankCell) {
        spans.add(
          TextSpan(
            text: '$text ',
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

      spans.add(TextSpan(
          text: '$text ',
          style: TextStyle(fontSize: 20.wMin, color: AppTheme.cTextPrimary)));
    }

    return SelectableText.rich(
      TextSpan(
        style: TextStyle(fontSize: 20.wMin, color: AppTheme.cTextPrimary),
        children: spans,
      ),
    );
  }

  Widget buildZHCaptionsWidget(int dialogueIndex) {
    DialogueModel dialogueModel = controller.dialogueList[dialogueIndex];
    if (dialogueModel.zhDialogueStr == null) {
      return const SizedBox.shrink();
    }
    return Text(
      dialogueModel.zhDialogueStr!,
      style: TextStyle(
        fontSize: 18.wMin,
        color: AppTheme.cTextPrimary,
      ),
    );
  }

  // 波形组件
}
