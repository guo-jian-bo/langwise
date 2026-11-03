


import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_player_ex/audio_player_ex.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'permission_utils.dart';

class RecordingServerData{
  String pcmPath = "";
  int sampleRate = 16000;
  int numChannels = 1;

  RecordingServerData({
    required this.pcmPath,
    required this.sampleRate,
    required this.numChannels,
  });
}

/// 录音工具
class RecordingServerUtils{

  factory RecordingServerUtils() => _getInstance();

  static RecordingServerUtils get instance => _getInstance();

  static RecordingServerUtils? _instance;

  static RecordingServerUtils _getInstance() {
    _instance ??= RecordingServerUtils._internal();
    return _instance!;
  }

  RecordingServerUtils._internal(){
    try {
      _audioRecorder = AudioRecorder();
      _listenRecord();
    } catch (e) {
      print('初始化录音器时出错: $e');
    }
  }

  AudioRecorder? _audioRecorder;

  /// 录音文件路径
  String _pcmPath = "";

  int sampleRate = 16000;
  
  int numChannels = 1;

  Timer? timer;
  
  /// 录音结果
  StreamController<RecordingServerData> resultStreamController = StreamController<RecordingServerData>.broadcast();

  /// 录音音量大小订阅
  StreamSubscription<Amplitude>? _recordAmplitudeistener;
  /// 录音音量大小
  StreamController<double> waveAmplitudeStreamController = StreamController<double>.broadcast();

  /// 录音的音频数据流订阅
  StreamSubscription<Uint8List>? _recordAudioStreamSubscription;

  /// 录音文件流
  StreamController<Uint8List> recordFileStreamController = StreamController<Uint8List>.broadcast();

  /// 监听录音
  void _listenRecord(){
     /// 监听录音音量大小
    _recordAmplitudeistener?.cancel();
    _recordAmplitudeistener = _audioRecorder?.onAmplitudeChanged(const Duration(milliseconds: 500)).listen((event){
      waveAmplitudeStreamController.add(event.current);
    });
   
  }

  double _streamGain = 1.8;
  double _limiterHeadroom = 0.97;
  bool _enableStreamGain = true;

  void setStreamGain(double gain, {double limiterHeadroom = 0.97, bool enable = true}) {
    _streamGain = gain;
    _limiterHeadroom = limiterHeadroom;
    _enableStreamGain = enable;
  }

  /// 放大音量
  Uint8List _applyGainAndLimiter(Uint8List data) {
    final out = Uint8List(data.length);
    final inBd = ByteData.view(data.buffer, data.offsetInBytes, data.lengthInBytes);
    final outBd = ByteData.view(out.buffer);
    final int maxVal = (32767 * _limiterHeadroom).floor();
    final int minVal = (-32768 * _limiterHeadroom).ceil();
  
    for (int i = 0; i < data.lengthInBytes; i += 2) {
      int sample = inBd.getInt16(i, Endian.little);
      double scaled = sample * _streamGain;
      int limited = scaled.round();
      if (limited > maxVal) limited = maxVal;
      if (limited < minVal) limited = minVal;
      outBd.setInt16(i, limited, Endian.little);
    }
    return out;
  }

  /// * 开启录音
  Future<void> startRecord({
    required BuildContext context,
    int timerSeconds = 10,
    String? fileName,
    void Function(String pcmPath, int sampleRate, int channels)? onStart,
    void Function(Uint8List data)? onData,
  }) async {

    final bool isMicrophoneGranted = (await PermissionUtils.microphone(context));
    print("---是否有麦克风权限isMicrophoneGranted: $isMicrophoneGranted---");
    if (!isMicrophoneGranted) return;

    // await AssetAudioUtils.playTap(isPlay: !isDemo);
    await SinglePlay.playAsset(assetPath: "audios/on_tap.wav");

    timer?.cancel();

    try {
      await stopARecord(isResult: false);

      // 生成录音文件
      final pcmFile = await _createFile(fileName: fileName);

      // 检查文件创建是否成功
      if (!await pcmFile.exists()) {
        throw Exception('无法创建录音文件');
      }

      // 获取推荐的采样率
      int devSampleRate = _getRecommendedSampleRate();

      final config = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: devSampleRate,
        numChannels: numChannels,
        streamBufferSize: 3200,
      );

      Stream<Uint8List>? stream = await _audioRecorder?.startStream(config);

      if(stream == null) throw Exception('无法创建录音流');

      _recordAudioStreamSubscription = stream.listen((data) {
        try {
          Uint8List processedData = data;
          if (Platform.isIOS && devSampleRate != sampleRate) {
            processedData = _resampleAudioData(data, devSampleRate, sampleRate);
          }
          if (_enableStreamGain) {
            processedData = _applyGainAndLimiter(processedData);
          }
          onData?.call(processedData);
          recordFileStreamController.add(processedData);
          pcmFile.writeAsBytesSync(processedData, mode: FileMode.append);
        } catch (e) {
          debugPrint('文件写入错误: $e');
        }
      });
      

      onStart?.call(_pcmPath, sampleRate, numChannels);

      timer = Timer.periodic(Duration(seconds: timerSeconds), (t) {
        t.cancel();
        stopARecord();
      });
  
  
    } on PlatformException catch (e) {
      print("录音异常e:$e");
    } catch (e) {
      print("无法录音e:$e");
    }
  }

  /// * 停止录音
  /// * [onResult] 录音结果回调
  /// * [isResult] 是否返回录音结果
  Future<String?> stopARecord({
    void Function(String pcmPath, int sampleRate, int channels)? onResult,
    bool isResult = true,
  }) async {
  
    timer?.cancel();
  
    try {
      // 检查录音器是否可用
      if (_audioRecorder == null) {
        print('录音器未初始化，无法停止录音');
        return null;
      }

      // 先取消流订阅，避免在停止录音过程中继续处理数据
      _recordAudioStreamSubscription?.cancel();
      _recordAudioStreamSubscription = null;

      // iOS平台需要额外等待，确保资源完全释放
      if (Platform.isIOS) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // 尝试停止录音，如果失败则捕获异常
      String? res;
      try {
        
        res = await _audioRecorder?.stop();
        
      } catch (e) {
        print('停止录音时出错: $e');
        // 即使停止失败，也继续处理结果
      }

      debugPrint("录音文件路径:$res");

      // iOS平台需要额外等待，确保资源完全释放
      if (Platform.isIOS) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      if (ObjectUtil.isEmpty(res) && isResult) {
        // 停止录音后返回音频路径
        onResult?.call(_pcmPath, sampleRate, numChannels);
        resultStreamController.add(
          RecordingServerData(
            pcmPath: _pcmPath,
            sampleRate: sampleRate,
            numChannels: numChannels,
          ),
        );
      }
      return res ?? '';
    } catch (e) {
      print('停止录音时出错: $e');
      return null;
    }
    
  }

  int _getRecommendedSampleRate() {
    if (Platform.isIOS) {
      // iOS: 使用硬件支持的采样率，避免崩溃
      return 44100; // iOS 硬件通常支持44.1kHz
    } else {
      // Android: 可以直接使用16kHz
      return 16000;
    }
  }

  Future<File> _createFile({String? fileName}) async {
    var tempDir = await getTemporaryDirectory();

    String fileNameStr = fileName ?? 'eval_audio';

    final String pcmPath = '${tempDir.path}/$fileNameStr.pcm';

    var outputPcmFile = File(pcmPath);
    if (await outputPcmFile.exists()) {
      debugPrint("pcm文件存在，先删除文件");
      await outputPcmFile.delete();
    }
    await outputPcmFile.create();

    _pcmPath = pcmPath;
    debugPrint('_pcmPath ==> $_pcmPath');
    return outputPcmFile;
  }

  /// 实时重采样音频数据
  /// [data] 原始音频数据
  /// [sourceSampleRate] 源采样率
  /// [targetSampleRate] 目标采样率
  Uint8List _resampleAudioData(Uint8List data, int sourceSampleRate, int targetSampleRate) {
    // 如果采样率相同，直接返回原始数据
    if (sourceSampleRate == targetSampleRate) {
      return data;
    }
    
    try {
      // 将字节数据转换为16位整数样本
      Int16List samples = Int16List(data.length ~/ 2);
      for (int i = 0; i < samples.length; i++) {
        samples[i] = data[i * 2] | (data[i * 2 + 1] << 8);
      }
      
      // 计算重采样后的样本数量
      double ratio = targetSampleRate / sourceSampleRate;
      int newLength = (samples.length * ratio).round();
      Int16List newSamples = Int16List(newLength);
      
      // 线性插值重采样
      for (int i = 0; i < newLength; i++) {
        double srcPos = i / ratio;
        int srcPosInt = srcPos.floor();
        double frac = srcPos - srcPosInt;
        
        if (srcPosInt >= samples.length - 1) {
          newSamples[i] = samples[samples.length - 1];
        } else {
          // 线性插值
          int sample1 = samples[srcPosInt];
          int sample2 = samples[srcPosInt + 1];
          newSamples[i] = (sample1 + (sample2 - sample1) * frac).round();
        }
      }
      
      // 将16位整数样本转换回字节数据
      Uint8List newData = Uint8List(newSamples.length * 2);
      for (int i = 0; i < newSamples.length; i++) {
        newData[i * 2] = newSamples[i] & 0xFF;
        newData[i * 2 + 1] = (newSamples[i] >> 8) & 0xFF;
      }
    
      return newData;
    } catch (e) {
      return data;
    }
  }

  

  void dispose(){
    timer?.cancel();
    timer = null;
    resultStreamController.close();
    _recordAmplitudeistener?.cancel();
    _recordAmplitudeistener = null;
    _recordAudioStreamSubscription?.cancel();
    _recordAudioStreamSubscription = null;
    recordFileStreamController.close();
    waveAmplitudeStreamController.close();
    try {
      _audioRecorder?.dispose();
    } catch (e) {
      print('释放录音器资源时出错: $e');
    }
    _audioRecorder = null;
    _instance = null;
  }

}
