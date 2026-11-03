part of 'manage_audio_subtitle_editor_view.dart';

extension ViewDialogsMixin on ManageAudioSubtitleEditorView {
  Future<void> showSplitDialogueDialog(int dialogueIndex) async {
    final available = controller.getAvailableSplitPunctuation(dialogueIndex);
    final selected = <String>[];

    await AskDialog.showCustom<void>(
      context: Get.context!,
      title: '拆分句子',
      width: 720,
      showTopClose: false,
      barrierDismissible: true,
      actions: [
        AskDialogAction(
          text: '取消',
          color: AppTheme.cBgTertiary,
          fontColor: AppTheme.cTextSecondary,
          onTap: () => Get.back(),
        ),
        AskDialogAction(
          text: '确认拆分',
          color: AppTheme.cMorphemeTagSuffix,
          onTap: () async {
            if (selected.isEmpty) return;
            await controller.splitDialogueModelByPunctuation(
                dialogueIndex, selected);
            Get.back();
          },
        ),
      ],
      child: StatefulBuilder(
        builder: (context, setState) {
          final preview =
              controller.previewSplitDialogueModel(dialogueIndex, selected);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('当前句子',
                  style: TextStyle(
                      fontSize: 14.wMin, color: AppTheme.cTextSecondary)),
              SizedBox(height: 10.wMin),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.wMin),
                decoration: BoxDecoration(
                  color: AppTheme.cBgTertiary,
                  borderRadius: BorderRadius.circular(12.wMin),
                ),
                child: Text(
                  controller.dialogueList[dialogueIndex].text ?? '',
                  style: TextStyle(
                      fontSize: 14.wMin,
                      color: AppTheme.cTextPrimary,
                      height: 1.4),
                ),
              ),
              SizedBox(height: 16.wMin),
              Text('选择分割标点',
                  style: TextStyle(
                      fontSize: 14.wMin, color: AppTheme.cTextSecondary)),
              SizedBox(height: 10.wMin),
              if (available.isEmpty)
                Text('该句子中没有可用的标点符号',
                    style: TextStyle(
                        fontSize: 13.wMin, color: AppTheme.cTextDisabled))
              else
                Wrap(
                  spacing: 10.wMin,
                  runSpacing: 10.wMin,
                  children: available.map((p) {
                    final isOn = selected.contains(p);
                    final Color c = AppTheme.cMorphemeTagSuffix;
                    return TapScaleWidget(
                      sclae: 1.03,
                      onTap: () {
                        setState(() {
                          if (isOn) {
                            selected.remove(p);
                          } else {
                            selected.add(p);
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.wMin, vertical: 10.wMin),
                        decoration: BoxDecoration(
                          color:
                              isOn ? c.withOpacity(0.12) : AppTheme.cBgTertiary,
                          borderRadius: BorderRadius.circular(12.wMin),
                          border: Border.all(
                              color: isOn ? c : AppTheme.cBorderPrimary,
                              width: 1.wMin),
                        ),
                        child: Text(
                          p,
                          style: TextStyle(
                              fontSize: 16.wMin,
                              color: isOn ? c : AppTheme.cTextPrimary),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              SizedBox(height: 16.wMin),
              Text('预览效果',
                  style: TextStyle(
                      fontSize: 14.wMin, color: AppTheme.cTextSecondary)),
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
                    ? Text('请选择标点以预览拆分效果',
                        style: TextStyle(
                            fontSize: 13.wMin, color: AppTheme.cTextDisabled))
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: preview.length,
                        separatorBuilder: (_, __) => SizedBox(height: 8.wMin),
                        itemBuilder: (context, i) {
                          final d = preview[i];
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.wMin, vertical: 10.wMin),
                            decoration: BoxDecoration(
                              color: AppTheme.cMorphemeTagSuffix.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12.wMin),
                              border: Border.all(
                                  color:
                                      AppTheme.cMorphemeTagSuffix.withOpacity(0.25),
                                  width: 1.wMin),
                            ),
                            child: Text(
                              '${KaraokeSubtitlesUtils.parseTimeToString(d.startTime ?? 0)} → ${d.text ?? ''}',
                              style: TextStyle(
                                  fontSize: 13.wMin,
                                  color: AppTheme.cTextPrimary,
                                  height: 1.35),
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
  Future<void> showAddDialogueDialog() async {
    final int? idx = controller.activeDialogueIndex ??
        controller.showCaptionDialogueIndex ??
        controller.editDialogueIndex;
    if (idx == null || idx < 0 || idx >= controller.dialogueList.length) {
      ToastUtils.showManageToast(text: '请先选择一句');
      return;
    }

    final input = TextEditingController();
    await AskDialog.showCustom<void>(
      context: Get.context!,
      title: '添加句子',
      width: 720,
      showTopClose: false,
      barrierDismissible: true,
      actions: [
        AskDialogAction(
          text: '取消',
          color: AppTheme.cBgTertiary,
          fontColor: AppTheme.cTextSecondary,
          onTap: () => Get.back(),
        ),
        AskDialogAction(
          text: '添加到当前句前面',
          color: AppTheme.cMorphemeTagPrefix,
          onTap: () {
            controller.insertDialogueBefore(idx, input.text);
            Get.back();
          },
        ),
        AskDialogAction(
          text: '添加到当前句后面',
          color: AppTheme.cTextBrand,
          onTap: () {
            controller.insertDialogueAfter(idx, input.text);
            Get.back();
          },
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('当前句子',
              style: TextStyle(
                  fontSize: 14.wMin, color: AppTheme.cTextSecondary)),
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
              children: [
                Text(
                  '${KaraokeSubtitlesUtils.parseTimeToString(controller.dialogueList[idx].startTime ?? 0)} - '
                  '${KaraokeSubtitlesUtils.parseTimeToString(controller.dialogueList[idx].endTime ?? 0)}',
                  style: TextStyle(
                      fontSize: 12.wMin,
                      color: AppTheme.cTextSecondary,
                      height: 1.3),
                ),
                SizedBox(height: 6.wMin),
                Text(
                  controller.dialogueList[idx].text ?? '',
                  style: TextStyle(
                      fontSize: 14.wMin,
                      color: AppTheme.cTextPrimary,
                      height: 1.4),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.wMin),
          TextFormField(
            controller: input,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '输入句子文本（单词以空格分隔）。',
              hintStyle:
                  TextStyle(fontSize: 14.wMin, color: AppTheme.cTextDisabled),
              filled: true,
              fillColor: AppTheme.cBgTertiary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.wMin),
                borderSide:
                    BorderSide(color: AppTheme.cBorderPrimary, width: 1.wMin),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.wMin),
                borderSide:
                    BorderSide(color: AppTheme.cBorderPrimary, width: 1.wMin),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.wMin),
                borderSide:
                    BorderSide(color: AppTheme.cBorderPrimary, width: 1.wMin),
              ),
            ),
            style: TextStyle(
                fontSize: 14.wMin, color: AppTheme.cTextPrimary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Future<void> showPromptDialog() async {
    await showCupertinoDialog<void>(
      context: Get.context!,
      barrierDismissible: true,
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        final dialogWidth = screenSize.width * 0.8;
        final dialogHeight = screenSize.height * 0.8;
        bool aiGenerated = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return Material(
              color: AppTheme.cOverlayBackground,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.wMin),
                  child: Container(
                    width: dialogWidth,
                    height: dialogHeight,
                    padding: EdgeInsets.all(24.wMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.wMin),
                      color: AppTheme.cBgSecondary,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '音频Prompt',
                            style: TextStyle(
                              fontSize: 20.wMin,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cTextPrimary,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.wMin),
                        Expanded(
                          child: TextFormField(
                            controller: controller.promptController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText:
                                  'Generate an educational audio drama with clear articulation, steady pacing.',
                              hintStyle: TextStyle(
                                  fontSize: 18.wMin,
                                  color: AppTheme.cTextDisabled),
                              filled: true,
                              fillColor: AppTheme.cBgTertiary,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.wMin),
                                borderSide: BorderSide(
                                    color: AppTheme.cBorderPrimary,
                                    width: 1.wMin),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.wMin),
                                borderSide: BorderSide(
                                    color: AppTheme.cBorderPrimary,
                                    width: 1.wMin),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.wMin),
                                borderSide: BorderSide(
                                    color: AppTheme.cBorderPrimary,
                                    width: 1.wMin),
                              ),
                            ),
                            style: TextStyle(
                                fontSize: 18.wMin,
                                color: AppTheme.cTextPrimary,
                                height: 1.4),
                          ),
                        ),
                        SizedBox(height: 20.wMin),
                        Row(
                          spacing: 16.wMin,
                          children: [
                            Expanded(
                              child: ButtonWidget(
                                text: '关闭',
                                height: 48.wMin,
                                fontColor: AppTheme.cTextSecondary,
                                fontSize: 16.wMin,
                                color: AppTheme.cBgTertiary,
                                borderRadius: 12.wMin,
                                sclae: 1.03,
                                onTap: () => Get.back(),
                              ),
                            ),
                            if (!aiGenerated)
                              Expanded(
                                child: ButtonWidget(
                                  text: 'AI生成',
                                  height: 48.wMin,
                                  fontSize: 16.wMin,
                                  color: const Color(0xff6D39E4),
                                  borderRadius: 12.wMin,
                                  sclae: 1.03,
                                  onTap: () async {
                                    await controller.aiGeneratePrompt();
                                    setState(() => aiGenerated = true);
                                  },
                                ),
                              ),
                            if (aiGenerated)
                              Expanded(
                                child: ButtonWidget(
                                  text: '重置',
                                  height: 48.wMin,
                                  fontSize: 16.wMin,
                                  color: AppTheme.cBgBrand,
                                  borderRadius: 12.wMin,
                                  sclae: 1.03,
                                  onTap: () {
                                    controller.resetPrompt();
                                    setState(() => aiGenerated = false);
                                  },
                                ),
                              ),
                            Expanded(
                              child: ButtonWidget(
                                text: '保存',
                                height: 48.wMin,
                                fontSize: 16.wMin,
                                color: AppTheme.cBgBrand,
                                borderRadius: 12.wMin,
                                sclae: 1.03,
                                onTap: () {
                                  controller.savePrompt();

                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
