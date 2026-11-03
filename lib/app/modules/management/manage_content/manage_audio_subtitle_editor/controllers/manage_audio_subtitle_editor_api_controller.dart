part of 'manage_audio_subtitle_editor_controller.dart';

extension AudioEditorApiMethods on ManageAudioSubtitleEditorController {
  void updateSentenceAudio({needRefresh = false, bool showToast = false}) async {
    if (type == 'EN_SONG' || type == 'EN_REVEAL') {
      if (promptController.text.isEmpty) {
        ToastUtils.showManageToast(text: '请输入Prompt');
        return;
      }
    }
    try {
      ToastUtils.showLoading();

      String assStr = '';
      for (var i = 0; i < dialogueList.length; i++) {
        assStr += dialogueList[i].dialogueStr;
      }
      if (assStr.endsWith('\n')) assStr = assStr.substring(0, assStr.length - 1);

      String zhassStr = '';
      for (var i = 0; i < dialogueList.length; i++) {
        if (dialogueList[i].zhDialogueAss == null) continue;
        zhassStr += dialogueList[i].zhDialogueAss!;
      }
      if (zhassStr.endsWith('\n')) zhassStr = zhassStr.substring(0, zhassStr.length - 1);

      final String content = dialogueList
          .map((item) => (item.text ?? '').trim())
          .where((item) => item.isNotEmpty)
          .join('\n');

      Map<String, dynamic> data = {
        "uid": audioModel!.uid,
        "fileKey": audioModel!.fileKey,
        "duration": audioModel!.duration,
        "size": audioModel!.size,
        "content": content,
        "ass": assStr,
        "translate": zhassStr.isEmpty ? null : [{"lang": "zh", "text": zhassStr}],
        "contentId": audioModel!.contentId,
        "accentId": audioModel!.accentId,
        "type": audioModel!.type,
      };

      if (type == 'EN_SONG' || type == 'EN_REVEAL') {
        data['prompt'] = promptController.text;
      }

      final ResponseEntity? res = await ManageSelectQuziKnowledge.updateSentenceAudio(parameters: {}, data: data);
      if (res == null) return;

      hasUnsavedChanges = false;
      if (type == 'EN_SONG') {
        zmPublishStatus = 0;
      } else {
        publishStatus = false;
      }
      update();
      if (showToast) ToastUtils.showManageToast(text: '保存成功');
      if (needRefresh) switchAudio(currentAudioIndex!);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void saveSentenceAudio() async {
    updateSentenceAudio(needRefresh: true, showToast: true);
  }

  void uploadAudio() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );
    if (result == null) return;
    File file = File(result.files.single.path!);
    await audioPlayer?.setSource(DeviceFileSource(file.path));

    OssUpdateResponseEntity? record = await OssUploadFileUtils.uploadManageFile(
      filePath: file.path,
      fileModule: OssFileManageModule.enAudio,
      fileType: OssFileManageType.track,
    );
    if (record == null) return;

    Duration? duration = await audioPlayer?.getDuration();
    double durationStr = duration != null ? double.parse((duration.inMilliseconds / 1000).toStringAsFixed(2)) : 0;
    audioModel!.fileKey = record.key;
    audioModel!.duration = durationStr;
    audioModel!.size = file.lengthSync();

    ToastUtils.showManageToast(text: '音频上传成功');
    updateSentenceAudio(needRefresh: true);
  }

  void generateAiAudio() async {
    audioInit();
    if (publishStatus) {
      final ask = await AskDialog.showUserAsk(
        context: Get.context!,
        content: "该音频已发布，确认需要重新生成吗？",
        define: "继续生成",
        showCancel: true,
      );
      if (ask == false) return;
    }

    try {
      ToastUtils.showLoading();
      int contentId = audioModel!.contentId ?? 0;
      Map<String, dynamic> data = {};
      if (audioModel!.uid != null) data['uid'] = audioModel!.uid;
      data['contentId'] = contentId;
      data['accentId'] = audioModel!.accentId;
      data['contentType'] = audioModel!.type;
      if (type == 'EN_SONG' || type == 'EN_REVEAL') {
        if (promptController.text.isEmpty) {
          ToastUtils.showManageToast(text: '请输入Prompt');
          return;
        }
        data['prompt'] = promptController.text;
      }

      final ResponseEntity? res = await ManageSelectQuziKnowledge.generateAiAudio(parameters: {}, data: data);
      if (res == null) return;

      if (type == 'EN_SONG' || type == 'EN_TEXT') {
        ToastUtils.showManageToast(text: '正在重新生成,预计需要2分钟左右完成');
        Get.back();
      } else if (type == 'EN_REVEAL') {
        var s = await SubscribeRequest.updateRevealReviewStatus(collectionId: collectionId!, contentId: contentId);
        if (s?.code == 200) ToastUtils.showManageToast(text: s?.data.toString() ?? '审核完成');
        final ask = await AskDialog.showUserAsk(
          context: Get.context!,
          title: "温馨提示",
          content: "音频正在生成中",
          showLastCountdown: false,
          showCancel: false,
        );
        if (ask) initAudioData();
      } else {
        final ask = await AskDialog.showUserAsk(
          context: Get.context!,
          title: "温馨提示",
          content: "音频正在生成中",
          showLastCountdown: type == "EN_REVEAL" ? false : true,
          showCancel: false,
        );
        if (ask) initAudioData();
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void generateAudioAssString() async {
    if (audioModel!.uid == null) {
      ToastUtils.showManageToast(text: '请先生成AI音频');
      return;
    }

    if (publishStatus) {
      final ask = await AskDialog.showUserAsk(
        context: Get.context!,
        content: "确认要重新生成字幕吗？",
        define: "重新生成",
        showCancel: true,
      );
      if (ask == false) return;
    }

    try {
      ToastUtils.showLoading();
      final ResponseEntity? res = await ManageSelectQuziKnowledge.generateAudioAssString(audioModel!.uid!, parameters: {}, data: {});
      if (res == null) return;
      switchAudio(currentAudioIndex!);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void publishAudio() async {
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "此操作会刷新界面，您确定要进行此操作？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) return;

    try {
      ToastUtils.showLoading();
      final ResponseEntity? res = await ManageSelectQuziKnowledge.publishAudio(audioModel!.uid!, parameters: {}, data: {"type": audioModel!.type});
      if (res == null) return;
      if (Get.isRegistered<ManageQuizListController>()) {
        Get.find<ManageQuizListController>().getLessonQuizList();
      }
      initAllData();
      initAudioData();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void publishAssString() async {
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "此操作会刷新界面，您确定要进行此操作？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) return;

    try {
      ToastUtils.showLoading();
      final ResponseEntity? res = await ManageSelectQuziKnowledge.publishAssString(audioModel!.uid!, parameters: {}, data: {});
      if (res == null) return;
      if (Get.isRegistered<ManageQuizListController>()) {
        Get.find<ManageQuizListController>().getLessonQuizList();
      }
      initAllData();
      initAudioData();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void downloadAudio() async {
    String? path = await getTempDirPath();
    if (path == null) return;
    path += Platform.pathSeparator + audioModel!.uid!.toString() + ".mp3";
    WiseHttp().download(
      audioModel!.url!,
      path,
      cancelToken: CancelToken(),
      onReceiveProgress: (count, total) {
        if (count >= total) ToastUtils.showManageToast(text: '下载完成');
      },
    );
  }

  Future<String?> getTempDirPath() async {
    if (Platform.isWindows || Platform.isMacOS) {
      return FilePicker.getDirectoryPath();
    } else {
      return (await getTemporaryDirectory()).path + Platform.pathSeparator + "app";
    }
  }

  void deleteAudio() async {
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "您确定要进行删除音频操作？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) return;

    try {
      ToastUtils.showLoading();
      final ResponseEntity? res = await ManageSelectQuziKnowledge.deleteAudio(audioModel!.uid!, parameters: {}, data: {});
      if (res == null) return;
      ToastUtils.showManageToast(text: '删除成功');
      audioList!.removeAt(currentAudioIndex!);
      currentAudioIndex = currentAudioIndex! - 1;
      switchAudio(currentAudioIndex!);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void generateTranslateAssString() async {
    if (!canRunEditorTasks || _isGeneratingTranslate || audioModel?.uid == null) {
      return;
    }
    _isGeneratingTranslate = true;
    try {
      ToastUtils.showLoading();
      final ResponseEntity? res = await ManageSelectQuziKnowledge.generateTranslateAssString(audioModel!.uid!, parameters: {}, data: {});
      if (res == null || !canRunEditorTasks) return;
      ToastUtils.showManageToast(text: '正在生成翻译字幕,预计需要1分钟左右完成');
      // 不立即重新初始化音频数据，避免暂停当前播放
      // 用户可以手动刷新或下次进入时自动获取最新数据
    } finally {
      _isGeneratingTranslate = false;
      ToastUtils.hideLoading();
    }
  }

  void optimizeAss() async {
    try {
      ToastUtils.showLoading();
      final ResponseEntity? res = await ManageSelectQuziKnowledge.optimizeAss(audioModel!.uid!, parameters: {}, data: {});
      if (res == null) return;
      ToastUtils.showManageToast(text: '正在优化字幕,预计需要5分钟左右完成');
      updateSentenceAudio(needRefresh: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void savePrompt() async {
    log('message');
    if (promptController.text.isEmpty) {
      ToastUtils.showManageToast(text: '请输入Prompt');
      return;
    }
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "您确定要进行保存Prompt操作？",
      cancel: '取消',
      define: "确认",
    );
    Get.back();
    if (!askRes) return;
    updateSentenceAudio(showToast: true);
  }

  void resetPrompt() {
    promptController.text = audioModel!.prompt!;
    update();
  }

  Future<void> aiGeneratePrompt() async {
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "您确定要使用AI生成Prompt吗？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) return;

    try {
      ToastUtils.showLoading();
      final ResponseEntity? res = await ManageSelectQuziKnowledge.aiGeneratePrompt(parameters: {
        "contentId": audioModel!.contentId,
        "contentType": type,
      });
      if (res?.data == null) return;
      Map<String, dynamic> data = res?.data;
      if (data['prompt'] != null) {
        ToastUtils.showManageToast(text: 'AI生成Prompt成功');
        promptController.text = data['prompt'];
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }
}
