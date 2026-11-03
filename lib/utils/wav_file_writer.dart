import 'dart:typed_data';

import 'dart:io';

class WavHeader {
  
  static List<int> generateHeader(int dataLength, int sampleRate, int numChannels, int bitsPerSample) {
    final byteRate = sampleRate * numChannels * 2;
    final blockAlign = numChannels * 2;
    
    final header = Uint8List(44);
    final buffer = ByteData.view(header.buffer);
    
    // RIFF chunk
    buffer.setUint8(0, 0x52); // 'R'
    buffer.setUint8(1, 0x49); // 'I'
    buffer.setUint8(2, 0x46); // 'F'
    buffer.setUint8(3, 0x46); // 'F'
    
    // 文件总大小 - 8 (44 + dataLength - 8)
    buffer.setUint32(4, 36 + dataLength, Endian.little);
    
    // WAVE格式
    buffer.setUint8(8, 0x57); // 'W'
    buffer.setUint8(9, 0x41); // 'A'
    buffer.setUint8(10, 0x56); // 'V'
    buffer.setUint8(11, 0x45); // 'E'
    
    // fmt chunk
    buffer.setUint8(12, 0x66); // 'f'
    buffer.setUint8(13, 0x6D); // 'm'
    buffer.setUint8(14, 0x74); // 't'
    buffer.setUint8(15, 0x20); // ' '
    
    buffer.setUint32(16, 16, Endian.little); // fmt chunk大小
    buffer.setUint16(20, 1, Endian.little); // 音频格式（PCM）
    buffer.setUint16(22, numChannels, Endian.little); // 声道数
    buffer.setUint32(24, sampleRate, Endian.little); // 采样率
    buffer.setUint32(28, byteRate, Endian.little); // 字节率
    buffer.setUint16(32, blockAlign, Endian.little); // 块对齐
    buffer.setUint16(34, bitsPerSample, Endian.little); // 位深度
    
    // data chunk
    buffer.setUint8(36, 0x64); // 'd'
    buffer.setUint8(37, 0x61); // 'a'
    buffer.setUint8(38, 0x74); // 't'
    buffer.setUint8(39, 0x61); // 'a'
    buffer.setUint32(40, dataLength, Endian.little); // 数据大小
    
    return header;
  }
}


class WavFileWriter {
  final File file;
  final int sampleRate;
  final int numChannels;
  final int bitsPerSample;
  
  int _dataLength = 0;
  RandomAccessFile? _raf;
  
  WavFileWriter(this.file, this.sampleRate, this.numChannels, this.bitsPerSample);
  
  // 初始化文件并写入头部
  Future<void> initialize() async {
    _raf = await file.open(mode: FileMode.write);
    // 写入初始头部（数据长度为0）
    final header = WavHeader.generateHeader(0, sampleRate, numChannels, bitsPerSample);
    await _raf!.writeFrom(header);
    _dataLength = 0;
  }
  
  // 追加音频数据
  Future<void> appendAudioData(Uint8List audioData) async {
    if (_raf == null) {
      throw StateError('必须先调用 initialize()');
    }
    
    // 写入音频数据
    await _raf!.writeFrom(audioData);
    _dataLength += audioData.length;
    
    // 更新头部中的文件大小和数据大小
    await _updateHeader();
  }
  
  // 更新WAV文件头部
  Future<void> _updateHeader() async {
    if (_raf == null) return;
    
    final header = WavHeader.generateHeader(_dataLength, sampleRate, numChannels, bitsPerSample);
    await _raf!.setPosition(0);
    await _raf!.writeFrom(header);
    // 回到文件末尾以便继续写入
    await _raf!.setPosition(44 + _dataLength);
  }
  
  // 关闭文件
  Future<void> close() async {
    await _updateHeader(); // 最后更新一次头部
    await _raf?.close();
    _raf = null;
  }
}