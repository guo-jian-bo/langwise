part of 'manage_audio_subtitle_editor_view.dart';

extension ViewPanelsMixin on ManageAudioSubtitleEditorView {
  Widget _buildFloatingActionGroup(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        EditorSidebarBtnWidget(
          text: '预览',
          color: AppTheme.cMorphemeTagRoot,
          onTap: () {
            if (controller.isPlaying) {
              controller.audioInit();
            }
            final contentId = controller.audioModel?.contentId;
            final contentType = controller.type;
            if (contentId == null || contentType == null) {
              ToastUtils.showManageToast(text: '暂无内容信息');
              return;
            }
            ElementsPageUtils.jumpElementsPage(
              contentId: contentId,
              contentType: contentType,
              semanticId: null,
              styleId: null,
              dialect: null,
              isManagement: true,
              contents: [
                {"contentId": contentId, "contentType": contentType},
              ],
            );
          },
        ),
        SizedBox(height: 10.wMin),
        if (controller.type == 'EN_SONG' || controller.type == 'EN_REVEAL') ...[
          EditorSidebarBtnWidget(
            text: '曲风Prompt',
            color: AppTheme.cEditorPromptAction,
            onTap: () => ViewDialogsMixin(this).showPromptDialog(),
          ),
          SizedBox(height: 10.wMin),
        ],
        EditorSidebarBtnWidget(
          text: '添加句子',
          color: AppTheme.cMorphemeTagPrefix,
          onTap: () => ViewDialogsMixin(this).showAddDialogueDialog(),
        ),
        SizedBox(height: 10.wMin),
        if (!controller.isMergeMode)
          EditorSidebarBtnWidget(
            text: '多选合并',
            color: AppTheme.cMorphemeTagCombiningForm,
            onTap: () {
              controller.toggleMergeMode();
              ToastUtils.showManageToast(text: '已进入合并模式：点击句子进行选择');
            },
          )
        else
          IntrinsicWidth(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                EditorSidebarBtnWidget(
                  text: '合并(${controller.mergeSelectedIndices.length})',
                  color: (controller.mergeSelectedIndices.isNotEmpty &&
                          controller.canMergeSelected)
                      ? AppTheme.cMorphemeTagCombiningForm
                      : AppTheme.cBgTertiary,
                  width: 90.wMin,
                  onTap: () {
                    final canMerge =
                        controller.mergeSelectedIndices.isNotEmpty &&
                            controller.canMergeSelected;
                    if (!canMerge) return;
                    controller.mergeSelectedDialogues();
                  },
                ),
                SizedBox(width: 10.wMin),
                EditorSidebarBtnWidget(
                  text: '取消',
                  color: AppTheme.cBgTertiary,
                  width: 90.wMin,
                  onTap: () => controller.toggleMergeMode(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget buildHeadWidget() {
    return SizedBox(
      height: 100.wMin,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: AppTheme.cBorderSecondary,
              height: 1,
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(left: 30.wMin, top: 20.wMin, right: 30.wMin),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 80.wMin,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.audioList?.length ?? 0,
                      itemBuilder: (context, index) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildAudioCard(index),
                            SizedBox(width: 30.wMin),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 20.wMin),
                SelectableText(
                  'ID: ${controller.audioModel?.contentId}',
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextPrimary,
                  ),
                ),
                SizedBox(width: 10.wMin),
                SelectableText(
                  'AudioID: ${controller.audioModel?.uid}',
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioCard(int index) {
    return GestureDetector(
      onTap: () {
        if (controller.currentAudioIndex == index) {
          return;
        }
        controller.switchAudio(index);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: controller.currentAudioIndex == index
                  ? AppTheme.cBgBrand
                  : Colors.transparent,
              width: 1.0,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${controller.audioList![index].name ?? ''} (${controller.audioList![index].accent ?? ''})',
              style: TextStyle(
                fontSize: 18.wMin,
                color: controller.currentAudioIndex == index
                    ? AppTheme.cBgBrand
                    : AppTheme.cTextPrimary,
              ),
            ),
            SizedBox(height: 10.wMin),
            Row(
              children: [
                Row(
                  children: [
                    Icon(
                      controller.audioList![index].published ?? false
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      color: controller.audioList![index].published ?? false
                          ? AppTheme.cFeedbackSuccessIcon
                          : AppTheme.cTextDisabled,
                      size: 16.wMin,
                    ),
                    SizedBox(width: 4.wMin),
                    Text(
                      '音频',
                      style: TextStyle(
                          color: controller.audioList![index].published ?? false
                              ? AppTheme.cFeedbackSuccessIcon
                              : AppTheme.cTextDisabled,
                          fontSize: 12.wMin),
                    ),
                  ],
                ),
                SizedBox(width: 20.wMin),
                Row(
                  children: [
                    Icon(
                      controller.audioList![index].assPublished == 1
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      color: controller.audioList![index].assPublished == 1
                          ? AppTheme.cFeedbackSuccessIcon
                          : AppTheme.cTextDisabled,
                      size: 16.wMin,
                    ),
                    SizedBox(width: 4.wMin),
                    Text(
                      '字幕',
                      style: TextStyle(
                          color: controller.audioList![index].assPublished == 1
                              ? AppTheme.cFeedbackSuccessIcon
                              : AppTheme.cTextDisabled,
                          fontSize: 12.wMin),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20.wMin),
          ],
        ),
      ),
    );
  }
  Widget toolsWidget() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            controller.toPrevDialogue();
          },
          child: Text(
            '上一句',
            style: TextStyle(fontSize: 18.wMin, color: AppTheme.cTextPrimary),
          ),
        ),
        SizedBox(width: 8.wMin),
        IconButton(
          icon: Container(
            width: 40.wMin,
            height: 40.wMin,
            decoration: BoxDecoration(
              color: AppTheme.cBgBrand.withOpacity(0.20),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              controller.audioPlayer?.state == PlayerState.playing
                  ? Icons.pause
                  : Icons.play_arrow,
              color: AppTheme.cTextBrand,
              size: 36.wMin,
            ),
          ),
          onPressed: () {
            controller.audioPlayAndPause();
          },
        ),
        SizedBox(width: 8.wMin),
        GestureDetector(
          onTap: () {
            controller.toNextDialogue();
          },
          child: Text(
            '下一句',
            style: TextStyle(fontSize: 18.wMin, color: AppTheme.cTextPrimary),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.stop,
            color: AppTheme.cTextTertiary,
            size: 24.wMin,
          ),
          onPressed: () {
            controller.audioInit();
          },
        ),
        Text(
          "${KaraokeSubtitlesUtils.formatTime(controller.currentTime)} / ${KaraokeSubtitlesUtils.formatTime(controller.totalDurationTime)}",
          style: TextStyle(
            fontSize: 16.wMin,
            color: AppTheme.cTextTertiary,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            controller.checkSentenceError();
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.10),
              borderRadius: BorderRadius.circular(5.wMin),
            ),
            padding:
                EdgeInsets.symmetric(horizontal: 15.wMin, vertical: 8.wMin),
            child: Text(
              '句子错误校验',
              style: TextStyle(
                fontSize: 12.wMin,
                color: AppTheme.cTextPrimary,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 20.wMin,
        ),
        GestureDetector(
          onTap: () {
            controller.resetView();
          },
          child: Text(
            '重置视图',
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextTertiary,
            ),
          ),
        ),
        SizedBox(
          width: 10.wMin,
        ),
        IconButton(
          icon: Icon(
            Icons.remove_circle_outline,
            color: AppTheme.cTextTertiary,
            size: 24.wMin,
          ),
          onPressed: () {
            controller.shrinkInterface();
          },
        ),
        IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: AppTheme.cTextTertiary,
            size: 22.wMin,
          ),
          onPressed: () {
            controller.scrollWaveformByPercent(-0.1);
          },
        ),
        Text(
          '${(controller.zoomLevel * 100).toInt()}%',
          style: TextStyle(
            fontSize: 16.wMin,
            color: AppTheme.cTextTertiary,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.chevron_right,
            color: AppTheme.cTextTertiary,
            size: 22.wMin,
          ),
          onPressed: () {
            controller.scrollWaveformByPercent(0.1);
          },
        ),
        IconButton(
          icon: Icon(
            Icons.add_circle_outline,
            color: AppTheme.cTextTertiary,
            size: 24.wMin,
          ),
          onPressed: () async {
            controller.zoomInterface();
          },
        ),
      ],
    );
  }

}
