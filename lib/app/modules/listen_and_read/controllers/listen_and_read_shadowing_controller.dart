
import 'dart:async';
import 'dart:io';

import 'package:audio_player_ex/audio_player_ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../../../common/configs/sheng_tong_config.dart';
import '../../../../common/entities/entities.dart';
import '../../../../common/entities/third_party_account_entity.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../common/values/values.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/utils.dart';
import '../models/reading_ass_model.dart';
import 'listen_and_read_controller.dart';

class ListenAndReadShadowingController extends GetxController {
  final ListenAndReadController listenAndReadController = Get.find<ListenAndReadController>();

  AudioPlaybackUtils get audioPlayerUtils => listenAndReadController.audioPlayerUtils;



  final AudioPlayerEx audioPlayerExShadowing = AudioPlayerEx();

  final List<String> modeList = ["全文模式", "单句模式"];

  /// 模式索引
  final RxInt titleModeSwitchIndex = 0.obs;

  /// 单句模式下 翻译的显示
  final Rx<LangPreference> singleSentenceTranslate = LangPreference.bilingual.obs;

  /// 第三方账号（声通）
  ThirdPartyAccountEntityList? thirdPartyAccount;

  /// 当前展开的段落索引
  final RxInt currentExpandParagraphIndex = 0.obs;
  
  /// 当前展开的句子索引
  final RxInt currentExpandSentenceIndex = 0.obs;

  /// 单句 当前正在录音的句子
  ReadingAssSentenceModel? currentRecordingSentenceModel;

  final MicrophoneController microphoneController = MicrophoneController();
  
  StreamSubscription<ShengTongResponseModel>? websocketStream;

  /// 全文模式的分数
  final Rx<int> fullTextScore = (-1).obs;

  /// 全文模式的录音路径
  final RxString fullTextRecordPcmPath = "".obs;

  /// 临时wav文件路径
  String tempWavFilePath = "";

  /// 录音的采样率
  int evalSampleRate = 16000;

  /// 录音的通道数
  int evalNumChannels = 1;

  @override
  void onInit(){
    super.onInit();

    if(Get.find<ConfigController>().userSetting.value.expandLang == LangPreference.bilingual){
      singleSentenceTranslate.value = LangPreference.bilingual;
    } else {
      singleSentenceTranslate.value = LangPreference.original;
    }

    initAudioListener();
    initEvel();
  }

  void initAudioListener(){
    audioPlayerUtils.pauseResumeStream.listen((event) async{
      if(event){
        if(audioPlayerExShadowing.isPlaying){
          await audioPlayerExShadowing.stop();
        }
        
        if(microphoneController.type == MicrophoneEnum.recording){
          await RecordingServerUtils.instance.stopARecord(isResult: false);
          OralEvaluationHttpService.instance.stopThisTimeSend();
          microphoneController.setType(MicrophoneEnum.defaultType);
        }
      }
    });
  }

  Future<void> initEvel() async{
    try {
      thirdPartyAccount = await Get.find<ConfigController>().getThirdPartyAccountByCode(ThirdPartyAccountEnum.stkouyu);
      if(thirdPartyAccount == null) {
        ToastUtils.showToast(text: "获取评测配置失败，请稍后重试");
        return;
      }

      String? appkey = thirdPartyAccount?.app?.appId;
      String? secretkey = thirdPartyAccount?.app?.secretKey;
      int? userid = UserStore.to.userInfo.value.userId;

      if(appkey == null || secretkey == null || userid == null){
        ToastUtils.showToast(text: "获取评测配置失败，请稍后重试");
        return;
      }
      await switchMode(0, init: true);
      
    } finally{
      
    }
  }
  

  /// 单句模式处理评测结果
  void handleSingleSentenceEvaluationResult(ShengTongResponseModel event){
    if(currentRecordingSentenceModel == null) return;
    if(event.result == null) return;

    List<SentenceEvalResultModel> wordList = [];

    ReadingAssSentenceModel sentenceModel = currentRecordingSentenceModel!;

    sentenceModel.evaluationScore = event.result?.overall;

    List<ReadingAssWordModel> words = sentenceModel.words;
    for(int i = 0; i < words.length; i++){
      wordList.add(SentenceEvalResultModel(word: words[i].ass.text));
    }

    wordList = SentenceEvaluationFun.settingData( 
      wordList, 
      event, 
      ShengTongConfig.passScore,
    );

    for(int i = 0; i < words.length; i++){
      if(wordList.length <= i) break;
      words[i].evaluationStatus = wordList[i].type;
    }

    listenAndReadController.readingAssTextList.refresh();
  }

  /// 全文模式处理评测结果
  void handleFullTextEvaluationResult(ShengTongResponseModel event){
    if(event.result == null) return;

    fullTextScore.value = event.result?.overall??0;

    List<SentenceEvalResultModel> wordList = [];

    List<ReadingAssParagraphModel> readingAssTextList = listenAndReadController.readingAssTextList;

    List<ReadingAssWordModel> localAllWords = [];

    for(int i = 0; i < readingAssTextList.length; i++){
      for(int j = 0; j < readingAssTextList[i].sentences.length; j++){
        localAllWords.addAll(readingAssTextList[i].sentences[j].words);
      }
    }

    for(int i = 0; i < localAllWords.length; i++){
      wordList.add(SentenceEvalResultModel(word: localAllWords[i].ass.text));
    }
    if(wordList.isEmpty) return;

    if(event.eof == 1){
      for(int i = 0; i < localAllWords.length; i++){
        if(localAllWords[i].isFullTextEvaluationStatus != null) continue;
        localAllWords[i].isFullTextEvaluationStatus = EvelResultScoreEnum.miss;
      }
    }else{
      wordList = SentenceEvaluationFun.settingDataParagraph(
        wordList, 
        event, 
        ShengTongConfig.passScore,
      );

      for(int i = 0; i < localAllWords.length; i++){
        if(wordList.length <= i) break;
        localAllWords[i].isFullTextEvaluationStatus = wordList[i].type;
      }
    }

    
    listenAndReadController.readingAssTextList.refresh();


  }

  /// 切换模式
  Future<void> switchMode(int index, {bool init = false}) async{
    titleModeSwitchIndex.value = index;

    String? appkey = thirdPartyAccount?.app?.appId;
    String? secretkey = thirdPartyAccount?.app?.secretKey;
    int? userid = UserStore.to.userInfo.value.userId;

    if(appkey == null || secretkey == null || userid == null){
      ToastUtils.showToast(text: "获取评测配置失败，请稍后重试");
      return;
    }

    if(index == 0){
      OralEvaluationHttpService.instance.initOralEvaluation(
        appkey: appkey, 
        secretkey: secretkey, 
        userid: userid.toString(), 
        wordCoreType: ShengTongConfig.wordCoreType, 
        url: ShengTongConfig.shengtongWsUrl, 
        websocketCoreType: ShengTongConfig.paraCoreType, 
        wsUrl: ShengTongConfig.shengtongWsUrl,
      );
    }else{
      OralEvaluationHttpService.instance.initOralEvaluation(
        appkey: appkey, 
        secretkey: secretkey, 
        userid: userid.toString(), 
        wordCoreType: ShengTongConfig.wordCoreType, 
        url: ShengTongConfig.shengtongWsUrl, 
        websocketCoreType: ShengTongConfig.sentCoreType, 
        wsUrl: ShengTongConfig.shengtongWsUrl,
      );
    }
    if(!init){
      Future.delayed(Duration.zero, () async{
        await audioPlayerUtils.stop();
        await audioPlayerUtils.seek(Duration.zero);
        stopRecord();
      });
    }

    try {
      ToastUtils.showLoading();
       await OralEvaluationHttpService.instance.connectWebSocket();
      OralEvaluationHttpService.instance.sendInitData();
      websocketStream?.cancel();
      websocketStream = OralEvaluationHttpService.instance.websocketStreamController?.stream.listen((event) {
        if(titleModeSwitchIndex.value == 1){
          // 单句模式
          handleSingleSentenceEvaluationResult(event);
        }else if(titleModeSwitchIndex.value == 0){
          // 全文模式
          handleFullTextEvaluationResult(event);
        }
      });

    } finally{
      ToastUtils.hideLoading();
    }

   


    
  }


  /// 单句模式下显示隐藏翻译
  void singleSentenceChangeTranslation(){
    if(singleSentenceTranslate.value == LangPreference.bilingual){
      singleSentenceTranslate.value = LangPreference.original;
    }else{
      singleSentenceTranslate.value = LangPreference.bilingual;
    }
  }


  /// 切换句子
  Future<void> switchSentence(int paragraphIndex, int sentenceIndex) async{
    if(currentExpandSentenceIndex.value == sentenceIndex && currentExpandParagraphIndex.value == paragraphIndex){
      return;
    }

    await audioPlayerUtils.stop();
    await stopRecord();

    currentExpandParagraphIndex.value = paragraphIndex;
    currentExpandSentenceIndex.value = sentenceIndex;
    
    
  }

  /// 取消全文评测的结果
  void cancelFullTextEvaluationResult() {
    fullTextRecordPcmPath.value = "";
    for(int i = 0; i < listenAndReadController.readingAssTextList.length; i++){
      listenAndReadController.readingAssTextList[i].evaluationScore = null;
      for(int j = 0; j < listenAndReadController.readingAssTextList[i].sentences.length; j++){
        for (var element in listenAndReadController.readingAssTextList[i].sentences[j].words) {
          element.isFullTextEvaluationStatus = null;
        }
      }
    }
    listenAndReadController.readingAssTextList.refresh();
  }

  /// 取消这一句的评测结果
  void cancelSentenceEvaluationResult(ReadingAssSentenceModel sentenceModel) {
    sentenceModel.evaluationScore = null;
    sentenceModel.recordFilePcmPath = null;
    for (var element in sentenceModel.words) {
      element.evaluationStatus = null;
    }
    listenAndReadController.readingAssTextList.refresh();
  }



  /// 播放这一句
  Future<void> playSentence(ReadingAssSentenceModel sentenceModel) async {
    if(sentenceModel.words.isEmpty) return;
    await audioPlayerUtils.stop();
    await stopRecord();
    await listenAndReadController.playSentence(sentenceModel);
    
  }

  /// 播放录音
  Future<void> playbackAudio(String? recordFilePath) async {
    if(recordFilePath == null || recordFilePath == "") return;
    await audioPlayerUtils.stop();
    await stopRecord();

    // 创建临时wav文件
    var tempDir = await getTemporaryDirectory();
    tempWavFilePath = "${tempDir.path}/article_evaluation_temporary.wav";
    File tempWavFile = File(tempWavFilePath);
    if (await tempWavFile.exists()) {
      await tempWavFile.delete();
    }
    await tempWavFile.create();

    WavFileWriter wavFileWriter = WavFileWriter(tempWavFile, evalSampleRate, evalNumChannels, 16);
    await wavFileWriter.initialize();
    await wavFileWriter.appendAudioData(await File(recordFilePath).readAsBytes());
    await wavFileWriter.close();

    // 需要 pcm 转 wav 才能播放
    audioPlayerExShadowing.playFromFile(filePath: tempWavFilePath);
    
  }



  /// 开启录音失败回调
  Future<void> onRecordFailure() async{
    ToastUtils.showToast(text: "录音失败，请检查麦克风是否可用");
    await RecordingServerUtils.instance.stopARecord(isResult: false);
    OralEvaluationHttpService.instance.stopThisTimeSend();
    microphoneController.setType(MicrophoneEnum.defaultType);
  }

  /// 停止录音
  Future<void> stopRecord() async{
    
    listenAndReadController.cancelAssHighlight();
    listenAndReadController.cancelSentenceHighlight();
    await audioPlayerExShadowing.stop();
    await RecordingServerUtils.instance.stopARecord(isResult: false);
    OralEvaluationHttpService.instance.stopThisTimeSend();
    microphoneController.setType(MicrophoneEnum.defaultType);
  }


  /// 开始录音
  Future<void> onRecord(BuildContext context, ReadingAssSentenceModel sentenceModel) async {
    currentRecordingSentenceModel = sentenceModel;
    
    if(microphoneController.type == MicrophoneEnum.recording){
      // 正在录音 停止录音
      await RecordingServerUtils.instance.stopARecord();
      OralEvaluationHttpService.instance.stopThisTimeSend();
      microphoneController.setType(MicrophoneEnum.defaultType);

      return;
    }

    await audioPlayerExShadowing.stop();
    await audioPlayerUtils.stop();
    listenAndReadController.cancelAssHighlight();
    listenAndReadController.cancelSentenceHighlight();
    cancelSentenceEvaluationResult(sentenceModel);
    

    int sentenceDuration = sentenceModel.words.last.ass.endTime - sentenceModel.words.first.ass.startTime;
    int recordTime = (sentenceDuration * 3) ~/ 1000;
    if(recordTime <= 10) recordTime = 10;
    
    await RecordingServerUtils.instance.startRecord(
      context: context,
      timerSeconds: recordTime,
      fileName: "evaluation_${sentenceModel.id}",
      onStart: (pcmPath, sampleRate, channels) {
        evalSampleRate = sampleRate;
        evalNumChannels = channels;
        microphoneController.setType(MicrophoneEnum.recording);
        sentenceModel.recordFilePcmPath = pcmPath;
        OralEvaluationHttpService.instance.sendStartOralData(
          word: assembleSentence(sentenceModel),
          sampleRate: sampleRate,
          channel: channels,
          dictDialect: getDictDialect(),
          age: UserStore.to.userInfo.value.memberAge ?? 12,
        );
      },
      onData: (data) {
        OralEvaluationHttpService.instance.sendData(data);
      },
    );
  }

  /// 播放整篇文章
  Future<void> playArticle() async {
    await audioPlayerUtils.stop();
    await stopRecord();
    await audioPlayerUtils.seek(Duration.zero);
    await audioPlayerUtils.resume();
    
  }

  /// 全文模式录音
  Future<void> playbackArticle(BuildContext context) async {
    if(listenAndReadController.readingAssTextList.isEmpty) return;

    if(microphoneController.type == MicrophoneEnum.recording){
      // 正在录音 停止录音
      await RecordingServerUtils.instance.stopARecord();
      OralEvaluationHttpService.instance.stopThisTimeSend();
      microphoneController.setType(MicrophoneEnum.defaultType);

      return;
    }

    await audioPlayerExShadowing.stop();
    await audioPlayerUtils.stop();
    listenAndReadController.cancelAssHighlight();
    listenAndReadController.cancelSentenceHighlight();
    cancelFullTextEvaluationResult();

    await RecordingServerUtils.instance.startRecord(
      context: context,
      timerSeconds: 300,
      fileName: "article_evaluation",
      onStart: (pcmPath, sampleRate, channels) {
        evalSampleRate = sampleRate;
        evalNumChannels = channels;
        microphoneController.setType(MicrophoneEnum.recording);
        fullTextRecordPcmPath.value = pcmPath;
        OralEvaluationHttpService.instance.sendStartOralData(
          word: assembleArticle(),
          sampleRate: sampleRate,
          channel: channels,
          dictDialect: getDictDialect(),
          age: UserStore.to.userInfo.value.memberAge ?? 12,
        );
      },
      onData: (data) {
        OralEvaluationHttpService.instance.sendData(data);
      },
    );

  }


  /// 组装全文为文本
  String assembleArticle(){
    String article = "";
    for(int i = 0; i < listenAndReadController.readingAssTextList.length; i++){
      for(int j = 0; j < listenAndReadController.readingAssTextList[i].sentences.length; j++){
        article += assembleSentence(listenAndReadController.readingAssTextList[i].sentences[j]);
      }
    }
    return article;
  }

  /// 组装句子为文本
  String assembleSentence(ReadingAssSentenceModel sentenceModel){
    String sentence = "";
    for(int i = 0; i < sentenceModel.words.length; i++){
      if(i == 0) {
        sentence += " ";
      }
      sentence += sentenceModel.words[i].ass.leftSpace;
      sentence += sentenceModel.words[i].ass.text;
      sentence += sentenceModel.words[i].ass.rightSpace;
    }
    return sentence;
  }

  /// 获取评测方言
  String getDictDialect(){
    String? national = UserStore.to.userInfo.value.config?.national;
    if(national == null) return "";
    String dictDialect = LanguageServiceCode.getEvelDctDialect(national);
    return dictDialect;
  }



  @override
  void onClose(){
    super.onClose();
    try {
      OralEvaluationHttpService.instance.disposeWebSocket();
      RecordingServerUtils.instance.dispose();
      audioPlayerExShadowing.dispose();
      websocketStream?.cancel();
      if(fullTextRecordPcmPath.isNotEmpty){
        File file = File(fullTextRecordPcmPath.value);
        if(file.existsSync()){
          file.deleteSync();
        }
      }
      if(tempWavFilePath.isNotEmpty){
        File file = File(tempWavFilePath);
        if(file.existsSync()){
          file.deleteSync();
        }
      }
    } catch (_) {
      
    }
    
  }


}
