part of 'manage_audio_subtitle_editor_view.dart';

extension ViewKTagListMixin on ManageAudioSubtitleEditorView {
  Widget buildEditDialogueWidget(int dialogueIndex) {
    DialogueModel dialogueModel = controller.dialogueList[dialogueIndex];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 15.wMin,
        ),
        Row(
          children: [
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
              onPressed: () {
                controller.addKTagModel(dialogueIndex);
              },
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
        SizedBox(
          height: 10.wMin,
        ),
        buildEditKTagsWidget(dialogueIndex),
        SizedBox(
          height: 25.wMin,
        ),
        Text(
          '带K标签的文本',
          style: TextStyle(
            fontSize: 16.wMin,
            color: AppTheme.cTextTertiary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 15.wMin,
        ),
        Text(
          dialogueModel.kTagText!,
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget buildEditKTagsWidget(int dialogueIndex) {
    DialogueModel dialogueModel = controller.dialogueList[dialogueIndex];
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        controller.endEditingCurrentKTag();
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
        itemCount: dialogueModel.kTagList!.length,
        itemBuilder: (context, index) {
          return DragTarget<KTagModel>(
            builder: (context, candidateData, rejectedData) {
              return buildEditKTagWidget(
                dialogueIndex,
                index,
                isDropTarget: candidateData.isNotEmpty,
              );
            },
            onAcceptWithDetails: (details) {
              controller.swapKTagModel(dialogueIndex, details.data, index);
            },
          );
        },
      ),
    );
  }

  Widget buildEditKTagWidget(int dialogueIndex, int tagIndex,
      {bool isDropTarget = false, bool enableDragHandle = true}) {
    KTagModel kTagModel =
        controller.dialogueList[dialogueIndex].kTagList![tagIndex];

    final int start = kTagModel.startTime ?? 0;
    final int end;
    final list = controller.dialogueList[dialogueIndex].kTagList;
    if (list != null && tagIndex + 1 < list.length) {
      end =
          (list[tagIndex + 1].startTime ?? (start + (kTagModel.duration ?? 0)))
              .clamp(0, controller.totalDurationTime);
    } else {
      final dEnd = controller.dialogueList[dialogueIndex].endTime;
      end = (dEnd ?? (start + (kTagModel.duration ?? 0)))
          .clamp(0, controller.totalDurationTime);
    }
    final bool isActiveByTime = controller.isWordMode &&
        controller.editDialogueIndex == dialogueIndex &&
        controller.currentTime >= start &&
        controller.currentTime < end;
    final bool highlight = isDropTarget || isActiveByTime;
    final bool isEditing = controller.isWordMode && kTagModel.isEdit;
    final bool isPlaying = controller.audioPlayer?.state == PlayerState.playing;
    final bool isActivePlaying = isPlaying && isActiveByTime;
    final bool isDesktopPlatform = kIsWeb ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;

    void endEditingAndUnfocus() {
      controller.endEditingCurrentKTag();
      FocusManager.instance.primaryFocus?.unfocus();
    }

    void onTapPlayOrPauseCurrentKTag() {
      if (isActivePlaying) {
        controller.audioPlayAndPause();
        return;
      }
      endEditingAndUnfocus();
      controller.playKTagModel(dialogueIndex, tagIndex);
    }

    return GestureDetector(
      onTap: onTapPlayOrPauseCurrentKTag,
      child: Container(
        key: Key('kTagWidget$dialogueIndex-$tagIndex'),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.wMin),
          color: highlight
              ? AppTheme.cSurfaceWarning.withOpacity(0.2)
              : const Color(0xffFFFFFF).withOpacity(0.05),
          border: Border.all(
            color: highlight
                ? AppTheme.cSurfaceWarning.withOpacity(0.6)
                : const Color(0xffFFFFFF).withOpacity(0.15),
            width: 1.wMin,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 6.wMin),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
          if (enableDragHandle)
            (isDesktopPlatform
                ? Draggable<KTagModel>(
                    data: kTagModel,
                    feedback: Material(
                      color: Colors.transparent,
                      child: ConstrainedBox(
                        constraints: BoxConstraints.tightFor(
                          width: 220.wMin,
                          height: 60.wMin,
                        ),
                        child: buildEditKTagWidget(
                          dialogueIndex,
                          tagIndex,
                          enableDragHandle: false,
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.grab,
                        child: Container(
                          color: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.wMin, vertical: 8.wMin),
                          child: Icon(
                            Icons.drag_indicator,
                            color: AppTheme.cTextTertiary,
                            size: 18.wMin,
                          ),
                        ),
                      ),
                    ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.grab,
                      child: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.wMin, vertical: 8.wMin),
                        child: Icon(
                          Icons.drag_indicator,
                          color: AppTheme.cTextTertiary,
                          size: 18.wMin,
                        ),
                      ),
                    ),
                  )
                : LongPressDraggable<KTagModel>(
                    data: kTagModel,
                    feedback: Material(
                      color: Colors.transparent,
                      child: ConstrainedBox(
                        constraints: BoxConstraints.tightFor(
                          width: 220.wMin,
                          height: 60.wMin,
                        ),
                        child: buildEditKTagWidget(
                          dialogueIndex,
                          tagIndex,
                          enableDragHandle: false,
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.grab,
                        child: Container(
                          color: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.wMin, vertical: 8.wMin),
                          child: Icon(
                            Icons.drag_indicator,
                            color: AppTheme.cTextTertiary,
                            size: 18.wMin,
                          ),
                        ),
                      ),
                    ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.grab,
                      child: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.wMin, vertical: 8.wMin),
                        child: Icon(
                          Icons.drag_indicator,
                          color: AppTheme.cTextTertiary,
                          size: 18.wMin,
                        ),
                      ),
                    ),
                  ))
          else
            Container(
              color: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 8.wMin),
              child: MouseRegion(
                cursor: SystemMouseCursors.basic,
                child: Icon(
                  Icons.drag_indicator,
                  color: AppTheme.cTextTertiary,
                  size: 18.wMin,
                ),
              ),
            ),
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
          SizedBox(
            width: 6.wMin,
          ),
          Expanded(
            child: GestureDetector(
              onTap: onTapPlayOrPauseCurrentKTag,
              onDoubleTap: () {
                if (!controller.isWordMode) return;
                controller.beginEditingKTag(dialogueIndex, tagIndex);
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
                    ? EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin)
                    : EdgeInsets.zero,
                child: TextField(
                  controller: controller.kContentTextFieldList[dialogueIndex]
                      [tagIndex],
                  focusNode: controller.kContentFocusNodeList[dialogueIndex]
                      [tagIndex],
                  readOnly: !kTagModel.isEdit,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: AppTheme.cTextPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    kTagModel.text = value;
                    kTagModel.kTagText =
                        '{\\k${(kTagModel.duration! / 10).toInt()}}$value';
                    controller.updateDialogue(dialogueIndex);
                  },
                  onSubmitted: (_) {
                    endEditingAndUnfocus();
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            width: 6.wMin,
          ),
          Text(
            '${kTagModel.duration}ms',
            style: TextStyle(
              fontSize: 12.wMin,
              color: AppTheme.cTextTertiary,
            ),
          ),
          SizedBox(
            width: 6.wMin,
          ),
          GestureDetector(
            onTap: () {
              endEditingAndUnfocus();
              controller.deleteKTagModel(dialogueIndex, tagIndex);
            },
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
