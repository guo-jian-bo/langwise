part of 'manage_audio_subtitle_editor_view.dart';

extension ViewPlayerBarMixin on ManageAudioSubtitleEditorView {
  Widget _buildBottomPlayerBar(BuildContext context) {
    var accent = controller.isWordMode
        ? AppTheme.cSurfaceWarning
        : AppTheme.cFeedbackSuccessText;
    const trackColor = Color(0x14FFFFFF);
    final thumbColor = AppTheme.cTextBrand;
    final waveBg = AppTheme.cBgSecondary;

    return Padding(
      padding: EdgeInsets.all(16.wMin),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cSurfacePrimary,
          // borderRadius: BorderRadius.all(Radius.circular(10.wMin)),
          border: Border(top: BorderSide(color: accent, width: 1.0.wMin)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 70.wMin, vertical: 16.wMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 120.wMin,
              width: double.infinity,
              decoration: BoxDecoration(
                color: waveBg,
                borderRadius: BorderRadius.circular(10.wMin),
              ),
              child: Platform.isWindows
                  ? const SizedBox.shrink()
                  : ScrollbarTheme(
                      data: ScrollbarThemeData(
                        trackColor: WidgetStateProperty.all(trackColor),
                        thumbColor: WidgetStateProperty.all(thumbColor),
                      ),
                      child: StreamBuilder<WaveformProgress>(
                        stream: controller.progressController.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${snapshot.error}',
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          final progress = snapshot.data?.progress ?? 0.0;
                          final waveform = snapshot.data?.waveform;

                          return waveform == null
                              ? Center(
                                  child: Text(
                                    '${(100 * progress).toInt()}%',
                                    style: TextStyle(
                                      fontSize: 26.wMin,
                                      color: AppTheme.cTextPrimary,
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapUp: (details) {
                                    final renderBox = context.findRenderObject()
                                        as RenderBox?;
                                    if (renderBox == null) return;
                                    final local = renderBox
                                        .globalToLocal(details.globalPosition);
                                    final containerWidth = renderBox.size.width;
                                    if (containerWidth <= 0) return;
                                    if (controller.totalDurationTime <= 0)
                                      return;

                                    int displayStartMs = 0;
                                    int displayDurationMs =
                                        waveform.duration.inMilliseconds;
                                    if (controller.isWordMode &&
                                        controller.editDialogueIndex != null) {
                                      final idx = controller.editDialogueIndex!;
                                      if (idx >= 0 &&
                                          idx <
                                              controller.dialogueList.length) {
                                        final d = controller.dialogueList[idx];
                                        final s = d.startTime ?? 0;
                                        final e = d.endTime ?? s;
                                        if (e > s) {
                                          displayStartMs = s;
                                          displayDurationMs = e - s;
                                        }
                                      }
                                    }

                                    final double scrollOffset =
                                        controller.scrollController.hasClients
                                            ? controller.scrollController.offset
                                            : 0.0;
                                    final double contentDx =
                                        scrollOffset + local.dx - 20.wMin;
                                    final double width = controller.allWidth;
                                    if (width <= 0) return;
                                    final ratio =
                                        (contentDx / width).clamp(0.0, 1.0);
                                    final targetMs = displayStartMs +
                                        (ratio * displayDurationMs).toInt();
                                    controller.seekToTime(targetMs,
                                        play: false, scrollWaveform: false);
                                  },
                                  child: waveformWidget(waveform),
                                );
                        },
                      ),
                    ),
            ),
            SizedBox(height: 12.wMin),
            _buildPlaybackControlBar(),
            SizedBox(height: 12.wMin),
            _buildPlaybackActionGroup(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaybackControlBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 240.wMin,
          child: Text(
            "${KaraokeSubtitlesUtils.parseTimeToString(controller.currentTime)} / ${KaraokeSubtitlesUtils.parseTimeToString(controller.totalDurationTime)}",
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: TextStyle(
              fontSize: 15.wMin,
              color: AppTheme.cTextPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                controller.toPrevDialogue();
              },
              child: Text('上一句',
                  style: TextStyle(fontSize: 18.wMin, color: AppTheme.cTextPrimary)),
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
                  size: 26.wMin,
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
              child: Text('下一句',
                  style: TextStyle(fontSize: 18.wMin, color: AppTheme.cTextPrimary)),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left,
                  color: AppTheme.cTextTertiary, size: 22.wMin),
              onPressed: () {
                controller.scrollWaveformByPercent(-0.1);
              },
            ),
            GestureDetector(
              onTap: () {
                controller.shrinkInterface();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cBgQuaternary,
                  borderRadius: BorderRadius.circular(4.wMin),
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
                child: Text(
                  '缩小',
                  style: TextStyle(
                      fontSize: 14.wMin, color: AppTheme.cTextTertiary),
                ),
              ),
            ),
            Text(
              '${(controller.zoomLevel * 100).toInt()}%',
              style:
                  TextStyle(fontSize: 14.wMin, color: AppTheme.cTextTertiary),
            ),
            GestureDetector(
              onTap: () {
                controller.zoomInterface();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cBgQuaternary,
                  borderRadius: BorderRadius.circular(4.wMin),
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
                child: Text(
                  '放大',
                  style: TextStyle(
                      fontSize: 14.wMin, color: AppTheme.cTextTertiary),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right,
                  color: AppTheme.cTextTertiary, size: 22.wMin),
              onPressed: () {
                controller.scrollWaveformByPercent(0.1);
              },
            ),
            GestureDetector(
              onTap: () {
                controller.resetView();
              },
              child: Text('重置',
                  style: TextStyle(
                      fontSize: 14.wMin, color: AppTheme.cTextBrand)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaybackActionGroup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            EditorToolBtnWidget(
              text: '上传音频',
              onTap: () => controller.uploadAudio(),
            ),
            SizedBox(width: 8.wMin),
            EditorToolBtnWidget(
              text: '生成音频',
              onTap: () => controller.generateAiAudio(),
            ),
            SizedBox(width: 8.wMin),
            EditorToolBtnWidget(
              text: '生成字幕',
              onTap: () => controller.generateAudioAssString(),
            ),
            SizedBox(width: 8.wMin),
            EditorToolBtnWidget(
              text: '生成翻译',
              onTap: () => controller.generateTranslateAssString(),
            ),
          ],
        ),
        Row(
          children: [
            EditorToolBtnWidget(
              text: '下载音频',
              onTap: () => controller.downloadAudio(),
            ),
            SizedBox(width: 8.wMin),
            EditorToolBtnWidget(
              text: '保存修改',
              color: AppTheme.cSurfaceError,
              onTap: () => controller.saveSentenceAudio(),
            ),
            SizedBox(width: 8.wMin),
            if (controller.type != 'EN_SONG')
              EditorToolBtnWidget(
                text: controller.publishStatus ? '已发布' : '发布音频',
                color: controller.publishStatus ? AppTheme.cFeedbackSuccessText : AppTheme.cTextBrand,
                onTap: () => controller.publishAudio(),
              ),
            if (controller.type == 'EN_SONG')
              EditorToolBtnWidget(
                text: controller.publishStatus ? '音频已发布' : '发布音频',
                color: controller.publishStatus ? AppTheme.cFeedbackSuccessText : AppTheme.cTextBrand,
                onTap: () => controller.publishAudio(),
              ),
            SizedBox(width: 8.wMin),
            if (controller.type == 'EN_SONG')
              EditorToolBtnWidget(
                text: controller.zmPublishStatus == 1 ? '字幕已发布' : '发布字幕',
                color: controller.zmPublishStatus == 1 ? AppTheme.cFeedbackSuccessText : AppTheme.cTextBrand,
                onTap: () => controller.publishAssString(),
              ),
          ],
        ),
      ],
    );
  }
  Widget buildPromptWidget() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 15.wMin, vertical: 20.wMin),
      padding: EdgeInsets.all(20.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfacePrimary,
        borderRadius: BorderRadius.circular(10.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '音频生成 Prompt',
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cTextPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  controller.resetPrompt();
                },
                child: Container(
                  margin: EdgeInsets.only(right: 8.wMin),
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.wMin, vertical: 6.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cBgBrand,
                    borderRadius: BorderRadius.circular(4.wMin),
                  ),
                  child: Text("重置",
                      style: TextStyle(fontSize: 14.wMin, color: AppTheme.cTextPrimary)),
                ),
              ),
              SizedBox(
                width: 8.wMin,
              ),
              GestureDetector(
                onTap: () {
                  controller.savePrompt();
                },
                child: Container(
                  margin: EdgeInsets.only(right: 8.wMin),
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.wMin, vertical: 6.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cBgBrand,
                    borderRadius: BorderRadius.circular(4.wMin),
                  ),
                  child: Text("保存",
                      style: TextStyle(fontSize: 14.wMin, color: AppTheme.cTextPrimary)),
                ),
              ),
              SizedBox(
                width: 8.wMin,
              ),
              GestureDetector(
                onTap: () {
                  controller.aiGeneratePrompt();
                },
                child: Container(
                  margin: EdgeInsets.only(right: 8.wMin),
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.wMin, vertical: 6.wMin),
                  decoration: BoxDecoration(
                    color: const Color(0xff6D39E4),
                    borderRadius: BorderRadius.circular(4.wMin),
                  ),
                  child: Text("AI生成",
                      style: TextStyle(fontSize: 14.wMin, color: AppTheme.cTextPrimary)),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.wMin,
          ),
          ManageContentInputWidget(
            hintText: '请输入Prompt',
            required: true,
            controller: controller.promptController,
            textInputAction: TextInputAction.newline,
            height: 150.wh,
            maxLines: 500,
            padding: EdgeInsets.symmetric(horizontal: 12.ww, vertical: 12.ww),
          ),
          SizedBox(
            height: 10.wMin,
          ),
          Text(
            '说明：此 Prompt 与文章内容共同决定音频生成效果。对于歌曲，建议包含音乐风格、节奏和乐器的描述。',
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
  Widget buildCaptionWidget() {
    if (controller.showCaptionDialogueIndex == null) {
      return const SizedBox.shrink();
    }

    DialogueModel dialogueModel =
        controller.dialogueList[controller.showCaptionDialogueIndex!];

    List showedList = [];
    List willShowList = [];
    for (var i = 0; i < dialogueModel.kTagList!.length; i++) {
      KTagModel kTagModel = dialogueModel.kTagList![i];
      if (i < controller.showCaptionKTagIndex) {
        showedList.add('${kTagModel.text} ');
      } else if (i == controller.showCaptionKTagIndex &&
          controller.showCaptionKTagProgress > 0) {
        int tatalLength = kTagModel.text!.length;
        int showedLength =
            (tatalLength * controller.showCaptionKTagProgress).toInt();
        showedList.add(kTagModel.text!.substring(0, showedLength));
        willShowList.add('${kTagModel.text!.substring(showedLength)} ');
      } else {
        willShowList.add('${kTagModel.text} ');
      }
    }

    return RichText(
      text: TextSpan(
        children: [
          ...List.generate(showedList.length, (i) {
            return TextSpan(
                text: showedList[i],
                style: TextStyle(fontSize: 20.wMin, color: AppTheme.cBgBrand));
          }),
          ...List.generate(willShowList.length, (i) {
            return TextSpan(
                text: willShowList[i],
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cTextTertiary,
                ));
          }),
        ],
      ),
    );
  }

}
