import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import '../common/entities/entities.dart';
import '../common/enum/enum.dart';


/// 口语评测
class OralEvaluationHttpService {

  String appkey = "";
  String secretkey = "";
  String userid = ""; //自定义，必填
  // --------- 以上参数 必须抽离出去 由服务端下发 ----------------

  String wordCoreType = "";

  String url = "";

  String websocketCoreType = "";

  String wsUrl = "";

  factory OralEvaluationHttpService() => _getInstance();

  static OralEvaluationHttpService get instance => _getInstance();

  static OralEvaluationHttpService? _instance;

  static OralEvaluationHttpService _getInstance() {
    _instance ??= OralEvaluationHttpService._internal();
    return _instance!;
  }

  OralEvaluationHttpService._internal(){
    _dio = Dio();
  }

  // 创建dio实例
  Dio? _dio;

  WebSocketChannel? _webSocketChannel;

  /// 重连计数器
  static int _reconnectAttempts = 0;
  /// 最大重连次数
  static const int _maxReconnectAttempts = 5;

  StreamController<ShengTongResponseModel>? websocketStreamController;

  /// 初始化评测参数
  void initOralEvaluation({
    required String appkey,
    required String secretkey,
    required String userid,
    required String wordCoreType,
    required String url,
    required String websocketCoreType,
    required String wsUrl,
  }){
    this.appkey = appkey;
    this.secretkey = secretkey;
    this.userid = userid;
    this.wordCoreType = wordCoreType;
    this.url = url;
    this.websocketCoreType = websocketCoreType;
    this.wsUrl = wsUrl;
  }
  
  /// 连接websocket
  Future<void> connectWebSocket() async{
    await disposeWebSocket();
    Uri uri = Uri.parse(wsUrl + websocketCoreType);
    websocketStreamController ??= StreamController<ShengTongResponseModel>.broadcast();
    _webSocketChannel = IOWebSocketChannel.connect(
      uri,
      pingInterval: const Duration(seconds: 10),
    );

    try{
      await _webSocketChannel?.ready;
      print("WebSocket -------------  连接成功");
    } on SocketException catch (e) {
      print("WebSocket -------------  连接失败 $e");
      return;
    } on WebSocketChannelException catch (e) {
      // print(Uri.parse(wsUrl + sentCoreType));
      print("WebSocket -------------  连接失败 $e");
      return;
    }

    _reconnectAttempts = 0; // 重置重连计数器

    _webSocketChannel?.stream.listen(
      (message) {
        print(message);
        websocketStreamController?.add(ShengTongResponseModel.fromJson(jsonDecode(message)));
      }, 
      onError: (error) => _scheduleReconnect(), 
      onDone: () => print("连接关闭"),
    );

  }

  /// 发送数据
  void sendData(dynamic data){
    _webSocketChannel?.sink.add(data);
  }

  void sendInitData(){
    final timeInt = DateTime.now().millisecondsSinceEpoch;
    final timeStr = timeInt.toString();

    var connectstr = utf8.encode(appkey + timeStr + secretkey);
    final connectsig = sha1.convert(connectstr).toString();

    Map<String, dynamic> reqParams = {
      "cmd": "connect",
      "param": {
        "sdk": {
            "version": 16777472,
            "source": 4,
            "protocol": 1
        },
        "app": {
            "applicationId": appkey,
            "sig": connectsig,                 // 初始化校验码
            "timestamp": timeStr          // 初始化时间戳
        }
      }
    };
    _webSocketChannel?.sink.add(jsonEncode(reqParams));
  }

  /// 发送开始评测数据
  /// 评测code dictDialect 评测的音频文件方言 en_br就是我们的UK en_us就是我们的US
  void sendStartOralData({
    required String word,
    required int sampleRate,
    required int channel,
    required String dictDialect,
    required int age,
    // required List<QuizModelOptions> optionList,
  }){
    final reqParams = getWebSocketReqParams(
      word: word,
      sampleRate: sampleRate,
      channel: channel,
      audioType: "wav",
      dictDialect: dictDialect,
      agegroup: getAgegroup(age),
      coreType: websocketCoreType,
      // optionList: optionList,
    );
    _webSocketChannel?.sink.add(jsonEncode(reqParams));
  }

  /// 重连
  void _scheduleReconnect() {
    
    if (_reconnectAttempts >= _maxReconnectAttempts) return;
    _webSocketChannel = null;
    websocketStreamController?.close();
    websocketStreamController = null;
    
    _reconnectAttempts++;
    print("WebSocket -------------  尝试重连 ($_reconnectAttempts/$_maxReconnectAttempts)...");

    Future.delayed(const Duration(seconds: 3), () async{
      await connectWebSocket();
      sendInitData();
    });
  }

  /// websocket 结束本次发送
  void stopThisTimeSend(){
    var params = {"cmd": "stop"};
    try {
      _webSocketChannel?.sink.add(jsonEncode(params));
    } catch (e) {
      print(e);
    }
  }


  /// * 开始评测
  /// * [word] 评测的单词
  /// * [phonetic] 评测的单词的音标
  /// * [audioFilePath] 评测的音频文件路径
  /// * [sampleRate] 评测的音频文件采样率
  /// * [channel] 评测的音频文件通道数
  /// * [audioType] 评测的音频文件类型
  /// * [dictDialect] 评测的音频文件方言 en_br就是我们的UK en_us就是我们的US
  /// * [age] 评测的音频文件年龄
  Future<ShengTongResponseModel?> evaluate({
    required String word,
    required String phonetic,
    required String audioFilePath,
    required int sampleRate,
    int channel = 1,
    String audioType = "wav",
    String dictDialect = "en_us",
    int age = 3,
  }) async {
    final reqParams = getReqParams(
      word: word,
      phonetic: phonetic,
      sampleRate: sampleRate,
      channel: channel,
      audioType: audioType,
      dictDialect: dictDialect,
      agegroup: getAgegroup(age),
      coreType: wordCoreType,
    );

    print(reqParams);

    File reqFile = File(audioFilePath);
    if (!await reqFile.exists()) {
      return null;
    }
    
    // 创建FormData
    final formData = FormData.fromMap({
      'text': jsonEncode(reqParams),
      'audio': await MultipartFile.fromFile(
        audioFilePath,
        contentType: DioMediaType('audio', 'wav'),
      ),
    });
    
    // 设置请求头
    final options = Options(headers: {'Request-Index': '0'});
    
    try {
      // 发送请求
      final response = await _dio?.post(
        url + wordCoreType,
        data: formData,
        options: options,
      );

      if(response?.statusCode != 200) return null;
      if(response?.data == null) return null;

      ShengTongResponseModel shengTongResponseModel = ShengTongResponseModel.fromJson(response?.data);

      print(json.encode(shengTongResponseModel.toJson()));

      return shengTongResponseModel;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// 根据年龄获取agegroup参数
  /// 年龄段支持可选值：1、2、3
  /// 1：3-6 years old
  /// 2：6-12 years old
  /// 3：>12 years old
  int getAgegroup(int age) {
    if (age < 6) {
      return 1;
    } else if (age < 12) {
      return 2;
    } else {
      return 3;
    }
  }


  /// 获取websocket需要的参数
  Map<String, dynamic> getWebSocketReqParams({
    required String word,
    required int channel,
    required String audioType,
    required int sampleRate,
    required String dictDialect,
    required int agegroup,
    required String coreType,
    // required List<QuizModelOptions> optionList,
  }){

    // Map<String, List<String>> pron = {};
    // for(int i = 0; i < optionList.length; i++){
    //   if(optionList[i].text == null) continue;
    //   if(optionList[i].altText == null) continue;
    //   pron[optionList[i].text!] = [optionList[i].altText!];
    // }


    final timeInt = DateTime.now().millisecondsSinceEpoch;
    final timeStr = timeInt.toString();

    final startstr = utf8.encode(appkey + timeStr + userid + secretkey);
    final startsig = sha1.convert(startstr).toString();
    return {
      "cmd": "start",
      "param": {
        "app": {
          "userId": userid,
          "applicationId": appkey,
          "timestamp": timeStr,
          "sig": startsig,
        },
        "audio": {
          "audioType": audioType,
          "channel": channel,
          "sampleBytes": 2, //2表示16bit。
          "sampleRate": sampleRate,
        },
        "request": {
          "coreType": coreType,
          "agegroup": agegroup,
          "phoneme_output": 1,
          "dict_type": "IPA88",
          "realtime_feedback": 1,
          "dict_dialect": dictDialect, // en_br就是我们的UK
          "refText": word,
          "attachAudioUrl": 1,
          "blend_phoneme": 1,
          "blend_phonics": 1,
          "readtype_diagnosis": 1, //显示重复读、漏读
          "paragraph_need_word_score": 1, //段落 是否含单词维度。可选值：1、0，0为关闭、1为开启
          "enable_digit_by_digit_read": 1, //允许数字拆分成单个数字读，默认为0，可选值：0、1，0表示关闭，1表示开启
          "sentence_need_word_stress": 1, //显示单词重(zhòng)读音节
          "tokenId": "684683b47872855f6c000001",
          // "customized_pron": {
          //   "type": "IPA88",
          //   "pron": pron,
          // },
        }
      }
    };
  }


  /// 获取评测需要的参数
  Map<String, dynamic> getReqParams({
    required String word,
    required String phonetic,
    required int channel,
    required String audioType,
    required int sampleRate,
    required String dictDialect,
    required int agegroup,
    required String coreType,
  }) {
    final timeInt = DateTime.now().millisecondsSinceEpoch;
    final timeStr = timeInt.toString();

    var connectstr = utf8.encode(appkey + timeStr + secretkey);
    final connectsig = sha1.convert(connectstr).toString();

    final startstr = utf8.encode(appkey + timeStr + userid + secretkey);
    final startsig = sha1.convert(startstr).toString();
    return {
      "connect": {
        "cmd": "connect",
        "param": {
          "sdk": {"version": 16777472, "source": 9, "protocol": 2},
          "app": {
            "applicationId": appkey,
            "sig": connectsig,
            "timestamp": timeStr
          }
        }
      },
      "start": {
        "cmd": "start",
        "param": {
          "app": {
            "userId": userid,
            "applicationId": appkey,
            "timestamp": timeStr,
            "sig": startsig,
          },
          "audio": {
            "audioType": audioType,
            "channel": channel,
            "sampleBytes": 2, //2表示16bit。
            "sampleRate": sampleRate,
          },
          "request": {
            "coreType": coreType,
            "agegroup": agegroup,
            "phoneme_output": 1,
            "dict_type": "IPA88",
            "dict_dialect": dictDialect, // en_br就是我们的UK
            "refText": word,
            "attachAudioUrl": 1,
            "blend_phoneme": 1,
            "blend_phonics": 1,
            "customized_pron": {
              "type": "IPA88",
              "pron": {
                word: [
                  phonetic, //"ˈruːlər"
                ],
              },
            },
            "tokenId": "684683b47872855f6c000001"
          }
        }
      }
    };
  }




  Future<void> disposeWebSocket() async{
    try {
      await websocketStreamController?.close();
      websocketStreamController = null;
      await _webSocketChannel?.sink.close(status.normalClosure);
      _webSocketChannel = null;
    } catch (e) {
      print(e);
    }
  }

}


class SentenceEvalResultModel{
  String word;

  /// [EvelResultScoreEnum]
  String? type;

  /// 有没有评分
  bool isScored = false;

  /// 分数
  int? score;

  ShengTongResponseModelResultWords? wordData;

  SentenceEvalResultModel? standardData;

  SentenceEvalResultModel({
    required this.word,
    this.type,
  });
}


class SentenceEvaluationFun{

  /// * 组装数据
  /// * wordList 原始数据
  /// * sentence 句子文本 
  /// * 评测的结果
  static List<SentenceEvalResultModel> settingData(
    List<SentenceEvalResultModel> wordList,
    ShengTongResponseModel? data,
    double passScore,
  ){

    // 复制原始单词列表
    List<SentenceEvalResultModel> respList = [];
    for (var word in wordList) {
      respList.add(SentenceEvalResultModel(
        word: word.word,
      ));
    }
    
    String sentence = data?.refText??"";
    
    // 获取评测结果中的单词列表
    List<ShengTongResponseModelResultWords?> resultWords = data?.result?.words ?? [];
    
    /// 已经使用的单词
    List<int> usedWords = [];

    // 处理评测结果
    for (int i = 0; i < resultWords.length; i++) {
      if (resultWords[i] == null) continue;
      
      // 获取单词部分信息
      List<ShengTongResponseModelResultWordsWordParts?> wordParts = resultWords[i]?.wordParts ?? [];
      if (wordParts.isEmpty) continue;
      
      // 合并所有word_parts组成完整单词
      String completeWord = "";
      int? beginIndex;
      int? endIndex;
      
      // 从所有word_parts中提取完整单词和索引范围
      for (var part in wordParts) {
        if (part == null || part.thePart == null) continue;
        completeWord += part.thePart!;
        
        // 记录第一个部分的beginIndex
        beginIndex ??= part.beginIndex;
        // 更新最后一个部分的endIndex
        endIndex = part.endIndex;
      }
      
      // 如果无法构建完整单词，尝试使用API返回的word字段
      if (completeWord.isEmpty && resultWords[i]?.word != null) {
        completeWord = resultWords[i]!.word!;
      }
      
      // 如果仍然无法获取单词，则跳过
      if (completeWord.isEmpty) continue;
      
      // 从句子中提取单词（如果beginIndex和endIndex有效）
      String extractedWord = "";
      if (beginIndex != null && endIndex != null && sentence.isNotEmpty) {
        if (beginIndex >= 0 && endIndex < sentence.length) {
          extractedWord = sentence.substring(beginIndex, endIndex + 1);
        }
      }
      
      
      
      // 在原始单词列表中查找匹配的单词
      int wordIndex = -1;
      
      // 尝试多种匹配策略
      for (int j = 0; j < respList.length; j++) {
        String originalWord = respList[j].word.trim().toLowerCase();
        
        // 策略1: 使用从句子中提取的单词进行精确匹配
        if (extractedWord.isNotEmpty) {
          String extracted = extractedWord.trim().toLowerCase();
          if (originalWord == extracted && !usedWords.contains(j)) {
            wordIndex = j;
            usedWords.add(j);
            break;
          }
        }
        
        // 策略2: 使用合并后的单词进行精确匹配
        String evalWord = completeWord.trim().toLowerCase();
        if (originalWord == evalWord && !usedWords.contains(j)) {
          wordIndex = j;
          usedWords.add(j);
          break;
        }
        
      }
      
      // 如果找到对应单词，更新其评测结果
      if (wordIndex >= 0 && wordIndex < respList.length) {
        //如果是字母
        bool containsLetter = RegExp(r'[a-zA-Z]').hasMatch(extractedWord);
        respList[wordIndex].type = EvelResultScoreEnum.getJudgmentStr(
          resultWords[i]?.scores?.pronunciation?.toDouble(), 
          passScore, 
          containsLetter ? resultWords[i]?.readType : 0,
        );

        
        respList[wordIndex].score = resultWords[i]?.scores?.overall;
        respList[wordIndex].isScored = true;
        respList[wordIndex].wordData = resultWords[i];
      }
    }
    
    return respList;
  }



  /// 组装数据-段落
  static List<SentenceEvalResultModel> settingDataParagraph(
    List<SentenceEvalResultModel> wordList,
    ShengTongResponseModel? data,
    double passScore,
  ){
    // 复制原始单词列表（保持与输入列表相同的长度和顺序）
    List<SentenceEvalResultModel> respList = [];
    for (var word in wordList) {
      respList.add(SentenceEvalResultModel(
        word: word.word,
        type: word.type,
      ));
    }
    
    String refText = data?.refText ?? "";
    
    // 获取评测结果中的句子列表
    List<ShengTongResponseModelResultSentences?> sentences = data?.result?.sentences ?? [];
    
    /// 已经使用的单词索引
    List<int> usedWords = [];
    
    // 遍历所有句子
    for (var sentence in sentences) {
      if (sentence == null) continue;
      
      // 获取句子中的单词详情
      List<ShengTongResponseModelResultSentencesDetails>? details = sentence.details;
      if (details == null || details.isEmpty) continue;
      
      // 遍历句子中的每个单词
      for (var detail in details) {
        // 跳过未读的单词（skipped == 1 表示未读）
        if (detail.skipped != 0) continue;
        
        // 获取单词部分信息
        List<ShengTongResponseModelResultWordsWordParts?> wordParts = detail.wordParts ?? [];
        
        // 合并所有word_parts组成完整单词
        String completeWord = "";
        int? beginIndex;
        int? endIndex;
        
        // 从所有word_parts中提取完整单词和索引范围
        for (var part in wordParts) {
          if (part == null || part.thePart == null) continue;
          completeWord += part.thePart!;
          
          // 记录第一个部分的beginIndex
          beginIndex ??= part.beginIndex;
          // 更新最后一个部分的endIndex
          endIndex = part.endIndex;
        }
        
        // 如果无法构建完整单词，尝试使用API返回的word字段
        if (completeWord.isEmpty && detail.word != null) {
          completeWord = detail.word!;
        }
        
        // 如果仍然无法获取单词，则跳过
        if (completeWord.isEmpty) {
          print("未匹配 ${detail.word}");
          continue;
        }
        
        // 从句子中提取单词（如果beginIndex和endIndex有效）
        String extractedWord = "";
        if (beginIndex != null && endIndex != null && refText.isNotEmpty) {
          if (beginIndex >= 0 && endIndex < refText.length) {
            extractedWord = refText.substring(beginIndex, endIndex + 1);
          }
        }
        
        // 在原始单词列表中查找匹配的单词
        int wordIndex = -1;
        
        // 尝试多种匹配策略
        for (int j = 0; j < wordList.length; j++) {
          if (usedWords.contains(j)) continue;
          
          String originalWord = wordList[j].word.trim().toLowerCase();
          
          // 策略1: 使用从句子中提取的单词进行精确匹配
          if (extractedWord.isNotEmpty) {
            String extracted = extractedWord.trim().toLowerCase();
            if (originalWord == extracted) {
              wordIndex = j;
              usedWords.add(j);
              break;
            }
          }
          
          // 策略2: 使用合并后的单词进行精确匹配
          String evalWord = completeWord.trim().toLowerCase();
          if (originalWord == evalWord) {
            wordIndex = j;
            usedWords.add(j);
            break;
          }
        }
        
        // 如果找到对应单词，直接更新对应位置的结果（保持索引对应关系）
        if (wordIndex >= 0 && wordIndex < respList.length) {
          // 如果是字母
          bool containsLetter = RegExp(r'[a-zA-Z]').hasMatch(extractedWord.isNotEmpty ? extractedWord : completeWord);
          
          respList[wordIndex].type = EvelResultScoreEnum.getJudgmentStr(
            detail.overall?.toDouble(), 
            passScore, 
            containsLetter ? detail.readType : 0,
          );
          
          respList[wordIndex].score = detail.overall;
          respList[wordIndex].isScored = true;
          
          // 将 ShengTongResponseModelResultSentencesDetails 转换为 ShengTongResponseModelResultWords
          respList[wordIndex].wordData = ShengTongResponseModelResultWords(
            word: detail.word,
            charType: detail.charType,
            readType: detail.readType,
            wordParts: detail.wordParts,
            scores: ShengTongResponseModelResultWordsScores(
              overall: detail.overall,
              pronunciation: detail.overall,
            ),
          );
        }else{
          print("未匹配 ${detail.word}");

        }
      }
    }
    
        
    // 找到连续3个isScored = true的最后一个单词下标
    int lastScoredIndex = -1;
    
    // 如果最后一个单词isScored=true，直接使用最后一个下标
    if (respList.isNotEmpty && respList.last.isScored) {
      lastScoredIndex = respList.length - 1;
    } else {
      // 否则找连续3个isScored = true的最后一个下标
      int consecutiveCount = 0;
      for (int i = respList.length - 1; i >= 0; i--) {
        if (respList[i].isScored) {
          consecutiveCount++;
          if (consecutiveCount >= 3) {
            lastScoredIndex = i + 2; // 连续3个的最后一个下标
            break;
          }
        } else {
          consecutiveCount = 0;
        }
      }
    }
    
    // 给lastScoredIndex之前未赋值的单词赋值为漏读
    if (lastScoredIndex > 0) {
      for (int i = 0; i < lastScoredIndex; i++) {
        if (!respList[i].isScored) {
          respList[i].isScored = true;
          respList[i].type = EvelResultScoreEnum.miss;
        }
      }
    }
    
    return respList;
  }

}




// {
//   "refText": "Student A: Hi! What's your name?Student B: My name is Sarah. What's your name?Student A: I'm Alex. Nice to meet you, Sarah.How old are you?Student B: I'm thirteen years old. And you?Student A: I'm twelve. What grade are you in?Student B: I'm in Grade 7. How about you?Student A: I'm in Grade 6.",
//   "applicationId": "1755676414000573",
//   "tokenId": "684683b47872855f6c000001",
//   "params": {
//     "app": {
//       "timestamp": "1765850656108",
//       "applicationId": "1755676414000573",
//       "sig": "5303eddb5a3234f3b5ddd82843506f67a4d50efb",
//       "userId": "27"
//     },
//     "audio": {
//       "audioType": "wav",
//       "sampleBytes": 2,
//       "sampleRate": 16000,
//       "channel": 1
//     },
//     "request": {
//       "refText": "Student A: Hi! What's your name?Student B: My name is Sarah. What's your name?Student A: I'm Alex. Nice to meet you, Sarah.How old are you?Student B: I'm thirteen years old. And you?Student A: I'm twelve. What grade are you in?Student B: I'm in Grade 7. How about you?Student A: I'm in Grade 6.",
//       "readtype_diagnosis": 1,
//       "dict_dialect": "en_us",
//       "tokenId": "684683b47872855f6c000001",
//       "paragraph_need_word_score": 1,
//       "sentence_need_word_stress": 1,
//       "realtime_feedback": 1,
//       "blend_phonics": 1,
//       "agegroup": 1,
//       "dict_type": "IPA88",
//       "blend_phoneme": 1,
//       "attachAudioUrl": 1,
//       "coreType": "para.eval",
//       "phoneme_output": 1
//     }
//   },
//   "audioUrl": "records.stkouyu.com/6940be215cc905200000504a",
//   "recordId": "6940be215cc905200000504a",
//   "dtLastResponse": "2025-12-16 10:04:20:395",
//   "result": {
//     "rhythm": 0,
//     "duration": "2.300",
//     "speed": 0,
//     "numeric_duration": 2.3,
//     "pronunciation": 0,
//     "fluency": 0,
//     "kernel_version": "7.9.2",
//     "warning": [
//       {
//         "message": "No valid audio detected!",
//         "code": 1001
//       }
//     ],
//     "resource_version": "5.9.0",
//     "overall": 0,
//     "sentences": [
//       {
//         "end": 0,
//         "beginIndex": 0,
//         "start": 0,
//         "sentence": "Student A: Hi!",
//         "overall": 0,
//         "details": [
//           {
//             "word": "Student",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "Student",
//                 "endIndex": 6,
//                 "beginIndex": 0,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "A:",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "A",
//                 "endIndex": 8,
//                 "beginIndex": 8,
//                 "charType": 0
//               },
//               {
//                 "part": ":",
//                 "endIndex": 9,
//                 "beginIndex": 9,
//                 "charType": 1
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "Hi!",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "Hi",
//                 "endIndex": 12,
//                 "beginIndex": 11,
//                 "charType": 0
//               },
//               {
//                 "part": "!",
//                 "endIndex": 13,
//                 "beginIndex": 13,
//                 "charType": 1
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           }
//         ],
//         "endIndex": 12
//       },
//       {
//         "end": 0,
//         "beginIndex": 15,
//         "start": 0,
//         "sentence": "What's your name?",
//         "overall": 0,
//         "details": [
//           {
//             "word": "What's",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "What's",
//                 "endIndex": 20,
//                 "beginIndex": 15,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "your",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "your",
//                 "endIndex": 25,
//                 "beginIndex": 22,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "name?",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "name",
//                 "endIndex": 30,
//                 "beginIndex": 27,
//                 "charType": 0
//               },
//               {
//                 "part": "?",
//                 "endIndex": 31,
//                 "beginIndex": 31,
//                 "charType": 1
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           }
//         ],
//         "endIndex": 30
//       },
//       {
//         "end": 0,
//         "beginIndex": 32,
//         "start": 0,
//         "sentence": "Student B: My name is Sarah.",
//         "overall": 0,
//         "details": [
//           {
//             "word": "Student",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "Student",
//                 "endIndex": 38,
//                 "beginIndex": 32,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "B:",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "B",
//                 "endIndex": 40,
//                 "beginIndex": 40,
//                 "charType": 0
//               },
//               {
//                 "part": ":",
//                 "endIndex": 41,
//                 "beginIndex": 41,
//                 "charType": 1
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "My",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "My",
//                 "endIndex": 44,
//                 "beginIndex": 43,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "name",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "name",
//                 "endIndex": 49,
//                 "beginIndex": 46,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "is",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "is",
//                 "endIndex": 52,
//                 "beginIndex": 51,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "Sarah.",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "Sarah",
//                 "endIndex": 58,
//                 "beginIndex": 54,
//                 "charType": 0
//               },
//               {
//                 "part": ".",
//                 "endIndex": 59,
//                 "beginIndex": 59,
//                 "charType": 1
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           }
//         ],
//         "endIndex": 58
//       },
//       {
//         "end": 0,
//         "beginIndex": 61,
//         "start": 0,
//         "sentence": "What's your name?",
//         "overall": 0,
//         "details": [
//           {
//             "word": "What's",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "What's",
//                 "endIndex": 66,
//                 "beginIndex": 61,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "your",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "your",
//                 "endIndex": 71,
//                 "beginIndex": 68,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "name?",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "name",
//                 "endIndex": 76,
//                 "beginIndex": 73,
//                 "charType": 0
//               },
//               {
//                 "part": "?",
//                 "endIndex": 77,
//                 "beginIndex": 77,
//                 "charType": 1
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           }
//         ],
//         "endIndex": 76
//       },
//       {
//         "end": 0,
//         "beginIndex": 78,
//         "start": 0,
//         "sentence": "Student A: I'm Alex.",
//         "overall": 0,
//         "details": [
//           {
//             "word": "Student",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "Student",
//                 "endIndex": 84,
//                 "beginIndex": 78,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "A:",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "A",
//                 "endIndex": 86,
//                 "beginIndex": 86,
//                 "charType": 0
//               },
//               {
//                 "part": ":",
//                 "endIndex": 87,
//                 "beginIndex": 87,
//                 "charType": 1
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "I'm",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "I'm",
//                 "endIndex": 91,
//                 "beginIndex": 89,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "Alex.",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "Alex",
//                 "endIndex": 96,
//                 "beginIndex": 93,
//                 "charType": 0
//               },
//               {
//                 "part": ".",
//                 "endIndex": 97,
//                 "beginIndex": 97,
//                 "charType": 1
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           }
//         ],
//         "endIndex": 96
//       },
//       {
//         "end": 0,
//         "beginIndex": 99,
//         "start": 0,
//         "sentence": "Nice to meet you,",
//         "overall": 0,
//         "details": [
//           {
//             "word": "Nice",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "Nice",
//                 "endIndex": 102,
//                 "beginIndex": 99,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "to",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "to",
//                 "endIndex": 105,
//                 "beginIndex": 104,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "meet",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "meet",
//                 "endIndex": 110,
//                 "beginIndex": 107,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "you,",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "you",
//                 "endIndex": 114,
//                 "beginIndex": 112,
//                 "charType": 0
//               },
//               {
//                 "part": ",",
//                 "endIndex": 115,
//                 "beginIndex": 115,
//                 "charType": 1
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           }
//         ],
//         "endIndex": 114
//       },
//       {
//         "end": 0,
//         "beginIndex": 117,
//         "start": 0,
//         "sentence": "Sarah.",
//         "overall": 0,
//         "details": [
//           {
//             "word": "Sarah.",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "Sarah",
//                 "endIndex": 121,
//                 "beginIndex": 117,
//                 "charType": 0
//               },
//               {
//                 "part": ".",
//                 "endIndex": 122,
//                 "beginIndex": 122,
//                 "charType": 1
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           }
//         ],
//         "endIndex": 121
//       },
//       {
//         "end": 0,
//         "beginIndex": 123,
//         "start": 0,
//         "sentence": "How old are you?",
//         "overall": 0,
//         "details": [
//           {
//             "word": "How",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "How",
//                 "endIndex": 125,
//                 "beginIndex": 123,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "old",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "old",
//                 "endIndex": 129,
//                 "beginIndex": 127,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "are",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "are",
//                 "endIndex": 133,
//                 "beginIndex": 131,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "you?",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "you",
//                 "endIndex": 137,
//                 "beginIndex": 135,
//                 "charType": 0
//               },
//               {
//                 "part": "?",
//                 "endIndex": 138,
//                 "beginIndex": 138,
//                 "charType": 1
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           }
//         ],
//         "endIndex": 137
//       },
//       {
//         "end": 0,
//         "beginIndex": 139,
//         "start": 0,
//         "sentence": "Student B: I'm thirteen years old.",
//         "overall": 0,
//         "details": [
//           {
//             "word": "Student",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "Student",
//                 "endIndex": 145,
//                 "beginIndex": 139,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "B:",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "B",
//                 "endIndex": 147,
//                 "beginIndex": 147,
//                 "charType": 0
//               },
//               {
//                 "part": ":",
//                 "endIndex": 148,
//                 "beginIndex": 148,
//                 "charType": 1
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "I'm",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "I'm",
//                 "endIndex": 152,
//                 "beginIndex": 150,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "thirteen",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "thirteen",
//                 "endIndex": 161,
//                 "beginIndex": 154,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "years",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "years",
//                 "endIndex": 167,
//                 "beginIndex": 163,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "old.",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "old",
//                 "endIndex": 171,
//                 "beginIndex": 169,
//                 "charType": 0
//               },
//               {
//                 "part": ".",
//                 "endIndex": 172,
//                 "beginIndex": 172,
//                 "charType": 1
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           }
//         ],
//         "endIndex": 171
//       },
//       {
//         "end": 0,
//         "beginIndex": 174,
//         "start": 0,
//         "sentence": "And you?",
//         "overall": 0,
//         "details": [
//           {
//             "word": "And",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "And",
//                 "endIndex": 176,
//                 "beginIndex": 174,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "you?",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "you",
//                 "endIndex": 180,
//                 "beginIndex": 178,
//                 "charType": 0
//               },
//               {
//                 "part": "?",
//                 "endIndex": 181,
//                 "beginIndex": 181,
//                 "charType": 1
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           }
//         ],
//         "endIndex": 180
//       },
//       {
//         "end": 0,
//         "beginIndex": 182,
//         "start": 0,
//         "sentence": "Student A: I'm twelve.",
//         "overall": 0,
//         "details": [
//           {
//             "word": "Student",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "Student",
//                 "endIndex": 188,
//                 "beginIndex": 182,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "A:",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "A",
//                 "endIndex": 190,
//                 "beginIndex": 190,
//                 "charType": 0
//               },
//               {
//                 "part": ":",
//                 "endIndex": 191,
//                 "beginIndex": 191,
//                 "charType": 1
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "I'm",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "I'm",
//                 "endIndex": 195,
//                 "beginIndex": 193,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "twelve.",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "twelve",
//                 "endIndex": 202,
//                 "beginIndex": 197,
//                 "charType": 0
//               },
//               {
//                 "part": ".",
//                 "endIndex": 203,
//                 "beginIndex": 203,
//                 "charType": 1
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           }
//         ],
//         "endIndex": 202
//       },
//       {
//         "end": 0,
//         "beginIndex": 205,
//         "start": 0,
//         "sentence": "What grade are you in?",
//         "overall": 0,
//         "details": [
//           {
//             "word": "What",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "What",
//                 "endIndex": 208,
//                 "beginIndex": 205,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "grade",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "grade",
//                 "endIndex": 214,
//                 "beginIndex": 210,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "are",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "are",
//                 "endIndex": 218,
//                 "beginIndex": 216,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "you",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "you",
//                 "endIndex": 222,
//                 "beginIndex": 220,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "in?",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "in",
//                 "endIndex": 225,
//                 "beginIndex": 224,
//                 "charType": 0
//               },
//               {
//                 "part": "?",
//                 "endIndex": 226,
//                 "beginIndex": 226,
//                 "charType": 1
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           }
//         ],
//         "endIndex": 225
//       },
//       {
//         "end": 0,
//         "beginIndex": 227,
//         "start": 0,
//         "sentence": "Student B: I'm in Grade 7.",
//         "overall": 0,
//         "details": [
//           {
//             "word": "Student",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "Student",
//                 "endIndex": 233,
//                 "beginIndex": 227,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "B:",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "B",
//                 "endIndex": 235,
//                 "beginIndex": 235,
//                 "charType": 0
//               },
//               {
//                 "part": ":",
//                 "endIndex": 236,
//                 "beginIndex": 236,
//                 "charType": 1
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "I'm",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "I'm",
//                 "endIndex": 240,
//                 "beginIndex": 238,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "in",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "in",
//                 "endIndex": 243,
//                 "beginIndex": 242,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "Grade",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "Grade",
//                 "endIndex": 249,
//                 "beginIndex": 245,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "7.",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "7",
//                 "endIndex": 251,
//                 "beginIndex": 251,
//                 "charType": 0
//               },
//               {
//                 "part": ".",
//                 "endIndex": 252,
//                 "beginIndex": 252,
//                 "charType": 1
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           }
//         ],
//         "endIndex": 251
//       },
//       {
//         "end": 0,
//         "beginIndex": 254,
//         "start": 0,
//         "sentence": "How about you?",
//         "overall": 0,
//         "details": [
//           {
//             "word": "How",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "How",
//                 "endIndex": 256,
//                 "beginIndex": 254,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "about",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "about",
//                 "endIndex": 262,
//                 "beginIndex": 258,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "you?",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "you",
//                 "endIndex": 266,
//                 "beginIndex": 264,
//                 "charType": 0
//               },
//               {
//                 "part": "?",
//                 "endIndex": 267,
//                 "beginIndex": 267,
//                 "charType": 1
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           }
//         ],
//         "endIndex": 266
//       },
//       {
//         "end": 0,
//         "beginIndex": 268,
//         "start": 0,
//         "sentence": "Student A: I'm in Grade 6.",
//         "overall": 0,
//         "details": [
//           {
//             "word": "Student",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "Student",
//                 "endIndex": 274,
//                 "beginIndex": 268,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "A:",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "A",
//                 "endIndex": 276,
//                 "beginIndex": 276,
//                 "charType": 0
//               },
//               {
//                 "part": ":",
//                 "endIndex": 277,
//                 "beginIndex": 277,
//                 "charType": 1
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "I'm",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "I'm",
//                 "endIndex": 281,
//                 "beginIndex": 279,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "in",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "in",
//                 "endIndex": 284,
//                 "beginIndex": 283,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "Grade",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "Grade",
//                 "endIndex": 290,
//                 "beginIndex": 286,
//                 "charType": 0
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           },
//           {
//             "word": "6.",
//             "end": 0,
//             "word_parts": [
//               {
//                 "part": "6",
//                 "endIndex": 292,
//                 "beginIndex": 292,
//                 "charType": 0
//               },
//               {
//                 "part": ".",
//                 "endIndex": 293,
//                 "beginIndex": 293,
//                 "charType": 1
//               }
//             ],
//             "charType": 0,
//             "readType": 3,
//             "overall": 0,
//             "start": 0,
//             "prominence": 0
//           }
//         ],
//         "endIndex": 292
//       }
//     ],
//     "integrity": 0
//   },
//   "eof": 0
// }












// {
//   "recordId": "68c676cccb0c6e200001a2ac",
//   "eof": 1,
//   "errId": null,
//   "error": null,
//   "tokenId": "684683b47872855f6c000001",
//   "audioUrl": "records.stkouyu.com/68c676cccb0c6e200001a2ac",
//   "refText": "The boy is walking.",
//   "dtLastResponse": "2025-09-14 16:03:29:536",
//   "result": {
//     "resource_version": "5.4.7",
//     "stress": null,
//     "pause_count": 2,
//     "fluency": 87,
//     "warning": [
//       {
//         "message": "Audio noisy!",
//         "code": 1004
//       }
//     ],
//     "words": [
//       {
//         "charType": 0,
//         "readType": 4, // 代表多读
//         "scores": {
//           "overall": 93,
//           "pronunciation": 93
//         },
//         "word": "boy"
//       },
//       {
//         "charType": 0,
//         "pause": {
//           "type": 1,
//           "duration": 19
//         },
//         "readType": 3, //代表漏读
//         "phonemes": [
//           {
//             "pronunciation": 0,
//             "span": {
//               "end": 223,
//               "start": 220
//             },
//             "phoneme": "ð",
//             "stress_mark": 0
//           },
//           {
//             "pronunciation": 61,
//             "span": {
//               "end": 229,
//               "start": 223
//             },
//             "phoneme": "ə",
//             "stress_mark": 0
//           }
//         ],
//         "span": {
//           "end": 229,
//           "start": 220
//         },
//         "phonics": [
//           {
//             "overall": 0,
//             "spell": "Th",
//             "phoneme": [
//               "ð"
//             ]
//           },
//           {
//             "overall": 61,
//             "spell": "e",
//             "phoneme": [
//               "ə"
//             ]
//           }
//         ],
//         "scores": {
//           "overall": 21,
//           "stress": [
//             {
//               "ref_stress": 1,
//               "stress": 0,
//               "overall": 31,
//               "spell": "The",
//               "phoneme_offset": 0,
//               "phonetic": "ðə"
//             }
//           ],
//           "pronunciation": 21
//         },
//         "word_parts": [
//           {
//             "charType": 0,
//             "part": "The",
//             "beginIndex": 0, // 代表单词字符串的起始位置
//             "endIndex": 2 // 代表单词字符串的结束位置
//           }
//         ],
//         "word": "The"
//       },
//       {
//         "charType": 0, 
//         "pause": {
//           "type": 1,
//           "duration": 44
//         },
//         "readType": 0,//代表正常
//         "phonemes": [
//           {
//             "pronunciation": 80,
//             "span": {
//               "end": 253,
//               "start": 248
//             },
//             "phoneme": "b",
//             "stress_mark": 0
//           },
//           {
//             "pronunciation": 98,
//             "span": {
//               "end": 280,
//               "start": 253
//             },
//             "phoneme": "ɔɪ",
//             "stress_mark": 0
//           }
//         ],
//         "span": {
//           "end": 280,
//           "start": 248
//         },
//         "phonics": [
//           {
//             "overall": 80,
//             "spell": "b",
//             "phoneme": [
//               "b"
//             ]
//           },
//           {
//             "overall": 98,
//             "spell": "oy",
//             "phoneme": [
//               "ɔɪ"
//             ]
//           }
//         ],
//         "scores": {
//           "overall": 93,
//           "stress": [
//             {
//               "ref_stress": 1,
//               "stress": 1,
//               "overall": 89,
//               "spell": "boy",
//               "phoneme_offset": 0,
//               "phonetic": "bɔɪ"
//             }
//           ],
//           "pronunciation": 93
//         },
//         "word_parts": [
//           {
//             "charType": 0,
//             "part": "boy",
//             "beginIndex": 4,
//             "endIndex": 6
//           }
//         ],
//         "word": "boy"
//       },
//       {
//         "charType": 0,
//         "pause": {
//           "type": 0,
//           "duration": 0
//         },
//         "readType": 3,
//         "phonemes": [
//           {
//             "pronunciation": 0,
//             "span": {
//               "end": 327,
//               "start": 324
//             },
//             "phoneme": "ɪ",
//             "stress_mark": 0
//           },
//           {
//             "pronunciation": 0,
//             "span": {
//               "end": 330,
//               "start": 327
//             },
//             "phoneme": "z",
//             "stress_mark": 0
//           }
//         ],
//         "span": {
//           "end": 330,
//           "start": 324
//         },
//         "phonics": [
//           {
//             "overall": 0,
//             "spell": "i",
//             "phoneme": [
//               "ɪ"
//             ]
//           },
//           {
//             "overall": 0,
//             "spell": "s",
//             "phoneme": [
//               "z"
//             ]
//           }
//         ],
//         "scores": {
//           "overall": 0,
//           "stress": [
//             {
//               "ref_stress": 1,
//               "stress": 0,
//               "overall": 0,
//               "spell": "is",
//               "phoneme_offset": 0,
//               "phonetic": "ɪz"
//             }
//           ],
//           "pronunciation": 0
//         },
//         "word_parts": [
//           {
//             "charType": 0,
//             "part": "is",
//             "beginIndex": 8,
//             "endIndex": 9
//           }
//         ],
//         "word": "is"
//       },
//       {
//         "charType": 0,
//         "pause": {
//           "type": 0,
//           "duration": 0
//         },
//         "readType": 0,
//         "phonemes": [
//           {
//             "pronunciation": 63,
//             "span": {
//               "end": 337,
//               "start": 330
//             },
//             "phoneme": "w",
//             "stress_mark": 1
//           },
//           {
//             "pronunciation": 100,
//             "span": {
//               "end": 347,
//               "start": 337
//             },
//             "phoneme": "ɔː",
//             "stress_mark": 0
//           },
//           {
//             "pronunciation": 100,
//             "span": {
//               "end": 361,
//               "start": 347
//             },
//             "phoneme": "k",
//             "stress_mark": 0
//           },
//           {
//             "pronunciation": 72,
//             "span": {
//               "end": 365,
//               "start": 361
//             },
//             "phoneme": "ɪ",
//             "stress_mark": 0
//           },
//           {
//             "pronunciation": 0,
//             "span": {
//               "end": 368,
//               "start": 365
//             },
//             "phoneme": "ŋ",
//             "stress_mark": 0
//           }
//         ],
//         "span": {
//           "end": 368,
//           "start": 330
//         },
//         "phonics": [
//           {
//             "overall": 63,
//             "spell": "w",
//             "phoneme": [
//               "w"
//             ]
//           },
//           {
//             "overall": 100,
//             "spell": "al",
//             "phoneme": [
//               "ɔː"
//             ]
//           },
//           {
//             "overall": 100,
//             "spell": "k",
//             "phoneme": [
//               "k"
//             ]
//           },
//           {
//             "overall": 72,
//             "spell": "i",
//             "phoneme": [
//               "ɪ"
//             ]
//           },
//           {
//             "overall": 0,
//             "spell": "ng",
//             "phoneme": [
//               "ŋ"
//             ]
//           }
//         ],
//         "scores": {
//           "overall": 72,
//           "stress": [
//             {
//               "ref_stress": 1,
//               "stress": 1,
//               "overall": 82,
//               "spell": "wal",
//               "phoneme_offset": 0,
//               "phonetic": "wɔː"
//             },
//             {
//               "ref_stress": 0,
//               "stress": 0,
//               "overall": 57,
//               "spell": "king",
//               "phoneme_offset": 2,
//               "phonetic": "kɪŋ"
//             }
//           ],
//           "pronunciation": 72
//         },
//         "word_parts": [
//           {
//             "charType": 0,
//             "part": "walking",
//             "beginIndex": 11,
//             "endIndex": 17
//           },
//           {
//             "charType": 1,
//             "part": ".",
//             "beginIndex": 18,
//             "endIndex": 18
//           }
//         ],
//         "word": "walking."
//       }
//     ],
//     "duration": "4.800",
//     "numeric_duration": 4.8,
//     "overall": 50,
//     "kernel_version": "7.7.3",
//     "pronunciation": 83,
//     "integrity": 75,
//     "speed": 150
//   },
//   "params": {
//     "audio": {
//       "audioType": "wav",
//       "sampleBytes": 2,
//       "sampleRate": 16000,
//       "channel": 1
//     },
//     "app": {
//       "userId": "TimelyWise",
//       "timestamp": "1757837004635",
//       "applicationId": "1755676414000573",
//       "sig": "38766f19ae2939d5e2c4c17a3370bcde9917194c"
//     },
//     "request": {
//       "attachAudioUrl": 1,
//       "dict_type": "IPA88",
//       "coreType": "sent.eval",
//       "tokenId": "684683b47872855f6c000001",
//       "refText": "The boy is walking."
//     }
//   },
//   "applicationId": "1755676414000573"
// }