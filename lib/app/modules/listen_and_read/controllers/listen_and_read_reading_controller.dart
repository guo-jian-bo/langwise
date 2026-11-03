
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/play_record_utils/play_record_utils.dart';
import '../../../../utils/utils.dart';
import '../models/reading_ass_model.dart';
import 'listen_and_read_controller.dart';

class ListenAndReadReadingController extends GetxController with WidgetsBindingObserver {
  final ListenAndReadController listenAndReadController = Get.find<ListenAndReadController>();

  AudioPlaybackUtils get audioPlayerUtils => listenAndReadController.audioPlayerUtils;

  /// 用于检测锁屏：inactive后紧接着paused表示锁屏
  bool _wasInactive = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }
  




  /// 悬浮选中单词
  Future<void> hoverSelectWord(ReadingAssSentenceModel sentence, ReadingAssWordModel word, BuildContext context) async {
    bool isPlaying = audioPlayerUtils.isPlaying;

    await audioPlayerUtils.pause();
    listenAndReadController.cancelAssHighlight();
    listenAndReadController.cancelSentenceHighlight();

    for (int i = 0; i < sentence.words.length; i++) {
      sentence.words[i].isHighlight = false;
    }

    word.isHighlight = true;
    listenAndReadController.readingAssTextList.refresh();

    await getSentenceWordAss(sentence);

    bool wordContentisNull = word.wordInfo?.imageUrl == null && word.wordInfo?.contentPosList == null && word.wordInfo?.pronunciations == null;

    if (sentence.wordsInfo == null || word.wordInfo == null || wordContentisNull) {
      word.isHighlight = false;
      listenAndReadController.readingAssTextList.refresh();
      if(isPlaying){
        audioPlayerUtils.resume();
      }
      ToastUtils.showToast(text: "词库正在努力扩充中~", type: ToastType.warning);
      return;
    }

    bool isToDetail = await SimpleDictionaryDialog.show(
      context: context,
      wordInfo: word.wordInfo!,
    );

    hoverCancelSelectWord(word);

    if(isToDetail) return;

    if(isPlaying){
      audioPlayerUtils.resume();
    }
  }

  /// 获取句子中单词的解析
  Future<void> getSentenceWordAss(ReadingAssSentenceModel sentence) async {
    if (sentence.wordsInfo != null) return;
    String sentenceText = "";

    for (int i = 0; i < sentence.words.length; i++) {
      sentenceText += sentence.words[i].ass.leftSpace;
      sentenceText += sentence.words[i].ass.text;
    }

    if (sentenceText.isEmpty) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "sentence": sentenceText,
      };
      SentenceParsingWordsEntity? model = await ListenAndReadRequest.getSentenceWordAss(reqData);
      if (model == null) return;
      List<SentenceParsingWordsEntityList?> list = model.list ?? [];
      if (list.isEmpty) return;

      List<SentenceParsingWordsEntityList> wordInfoList = [];
      for (int i = 0; i < sentence.words.length; i++) {
        if (i >= list.length) break;
        sentence.words[i].wordInfo = list[i];
        wordInfoList.add(list[i]!);
      }
      sentence.wordsInfo = wordInfoList;

      List<ReadingAssWordModel> words = sentence.words;
      for (int i = 0; i < words.length; i++) {
        if (i >= list.length) break;
        words[i].wordInfo = list[i];
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 悬浮取消选中单词
  Future<void> hoverCancelSelectWord(ReadingAssWordModel word) async {
    await Future.delayed(const Duration(milliseconds: 100));
    word.isHighlight = false;
    listenAndReadController.readingAssTextList.refresh();
  }



  /// 跳转至mv播放页面
  Future<void> jumpToMvPlayPage() async{
    try {
      ToastUtils.showLoading();
      int contentId = listenAndReadController.currentContentId.value;
      if(contentId == -1) return;
      String? contentType = listenAndReadController.currentSong?.contentType;
      if (contentType == null) return;

      int milliseconds = (await audioPlayerUtils.getCurrentPosition()).inMilliseconds;

      if(Platform.isWindows){
        await audioPlayerUtils.stop();
      }

      await PlayRecordManager.instance.stopTracking(source: 'listen_and_read');

      await JumpPageUtils.jumpSongMv(
        contents: listenAndReadController.contents,
        contentId: contentId,
        contentType: contentType,
        isReplaceRoute: true,
        milliseconds: milliseconds,
        type: PlayRecordPageType.fromValue(listenAndReadController.type),
        typeId: listenAndReadController.typeId,
      );
    } finally {
      ToastUtils.hideLoading();
    }
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    print('[ApplicationController] 生命周期变化: $state');
    
    if (state == AppLifecycleState.resumed) {
      print('APP从后台返回到前台');
      _wasInactive = false;
    } else if (state == AppLifecycleState.paused) {
      print('APP进入后台');
      // 锁屏检测：inactive后紧接着paused表示锁屏
      if (_wasInactive) {
        // onLockScreen();
      }
      _wasInactive = false;
    } else if (state == AppLifecycleState.inactive) {
      print('APP进入inactive状态（如锁屏、来电等）');
      _wasInactive = true;
    } else if (state == AppLifecycleState.detached) {
      print('APP进入detached状态');
      _wasInactive = false;
    }
  }


  /// 锁屏
  void onLockScreen() {
    print('APP进入锁屏状态');
    if (!Platform.isAndroid && !Platform.isIOS) return;
    jumpToMvPlayPage();
  }


  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
  
}
