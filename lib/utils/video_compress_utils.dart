import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/media_information.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/stream_information.dart';
import 'package:path/path.dart' as path;

import 'log_utils/error_log_utils.dart';

/// 视频基础信息。
///
/// 只保留当前压缩链路真正需要的字段，避免把底层探测结果原样向外暴露。
class VideoCompressInfo {
  /// 视频总时长。
  final Duration duration;

  /// 视频流宽度。
  final int width;

  /// 视频流高度。
  final int height;

  /// 视频编码名称，例如 `hevc`、`h264`。
  final String codec;

  /// 文件大小，单位字节。
  final int fileSize;

  const VideoCompressInfo({
    required this.duration,
    required this.width,
    required this.height,
    required this.codec,
    required this.fileSize,
  });
}

/// 视频压缩工具。
///
/// 负责读取本地视频信息，并把输入视频统一压缩为：
/// - `mp4`
/// - `H.264`
/// - 最大宽度 `480`
/// - 高度按比例自动适配
class VideoCompressUtils {
  /// 输出最大宽度。
  static const int _maxWidth = 480;

  /// 视频质量参数，数值越大压缩越狠。
  static const int _videoCrf = 28;

  /// 编码预设，平衡速度与体积。
  static const String _videoPreset = 'medium';

  /// 音频码率。
  static const String _audioBitrate = '96k';

  /// FFmpegKit 初始化只需要做一次。
  static Future<void>? _initFuture;

  /// 读取本地视频基础信息。
  ///
  /// 返回值用于时长校验、压缩前后日志记录和结果校验。
  static Future<VideoCompressInfo?> getVideoInfo(File file) async {
    if (!(await file.exists())) return null;

    try {
      await _ensureInitialized();
      final session = await FFprobeKit.getMediaInformation(file.path);
      final MediaInformation? mediaInformation = session.getMediaInformation();
      if (mediaInformation == null) return null;

      final StreamInformation? videoStream = _findVideoStream(mediaInformation);
      final int? width = videoStream?.getWidth();
      final int? height = videoStream?.getHeight();
      final Duration? duration = _parseDuration(mediaInformation.getDuration());
      if (width == null || height == null || width <= 0 || height <= 0 || duration == null) {
        return null;
      }

      return VideoCompressInfo(
        duration: duration,
        width: width,
        height: height,
        codec: videoStream?.getCodec() ?? '',
        fileSize: await file.length(),
      );
    } catch (e, stackTrace) {
      await ErrorLogUtils.to.logError('[VideoCompressUtils] 读取视频信息失败 path:${file.path} error:$e', stackTrace);
      return null;
    }
  }

  /// 把本地视频压缩为 480 宽以内的 MP4。
  ///
  /// 宽度大于 `480` 时会缩到 `480`；
  /// 宽度小于等于 `480` 时不会放大，但仍会统一转码。
  static Future<File?> compressVideoToHevc(File file) async {
    if (!(await file.exists())) return null;

    final Stopwatch stopwatch = Stopwatch()..start();
    final String outputPath = _buildOutputPath(file);
    final File outputFile = File(outputPath);

    try {
      await _ensureInitialized();

      final VideoCompressInfo? inputInfo = await getVideoInfo(file);
      if (inputInfo == null) return null;

      await ErrorLogUtils.to.logInfo(
        '[VideoCompressUtils] start path:${file.path} '
        'size:${inputInfo.fileSize} width:${inputInfo.width} height:${inputInfo.height} '
        'duration:${inputInfo.duration.inMilliseconds} codec:${inputInfo.codec}',
      );

      final List<String> commandArguments = [
        '-y',
        '-hide_banner',
        '-i',
        file.path,
        '-vf',
        'scale=trunc(min($_maxWidth\\,iw)/2)*2:-2',
        ..._buildVideoCodecArguments(),
        '-pix_fmt',
        'yuv420p',
        '-c:a',
        'aac',
        '-b:a',
        _audioBitrate,
        '-movflags',
        '+faststart',
        outputPath,
      ];

      final session = await FFmpegKit.executeWithArguments(commandArguments);
      final ReturnCode? returnCode = await session.getReturnCode();
      final String? sessionOutput = await session.getOutput();
      if (!ReturnCode.isSuccess(returnCode)) {
        await _deleteOutputIfNeeded(outputFile);
        await ErrorLogUtils.to.logError(
          '[VideoCompressUtils] 压缩失败 path:${file.path} '
          'returnCode:${returnCode?.getValue()} output:${_clipLog(sessionOutput)}',
          null,
        );
        return null;
      }

      if (!(await outputFile.exists())) return null;
      if (await outputFile.length() <= 0) {
        await _deleteOutputIfNeeded(outputFile);
        return null;
      }

      final VideoCompressInfo? outputInfo = await getVideoInfo(outputFile);
      if (outputInfo == null || outputInfo.codec.toLowerCase() != _expectedOutputCodec()) {
        await _deleteOutputIfNeeded(outputFile);
        await ErrorLogUtils.to.logError(
          '[VideoCompressUtils] 压缩结果校验失败 path:$outputPath '
          'codec:${outputInfo?.codec} expected:${_expectedOutputCodec()}',
          null,
        );
        return null;
      }

      await ErrorLogUtils.to.logInfo(
        '[VideoCompressUtils] done input:${file.path} output:$outputPath '
        'size:${outputInfo.fileSize} width:${outputInfo.width} height:${outputInfo.height} '
        'duration:${outputInfo.duration.inMilliseconds} codec:${outputInfo.codec} '
        'cost:${stopwatch.elapsed.inMilliseconds}ms',
      );

      return outputFile;
    } catch (e, stackTrace) {
      await _deleteOutputIfNeeded(outputFile);
      await ErrorLogUtils.to.logError('[VideoCompressUtils] 压缩异常 path:${file.path} error:$e', stackTrace);
      return null;
    }
  }

  /// 确保 FFmpegKit 只初始化一次。
  static Future<void> _ensureInitialized() {
    return _initFuture ??= FFmpegKitConfig.init();
  }

  /// 从探测结果里取出第一条视频流。
  static StreamInformation? _findVideoStream(MediaInformation mediaInformation) {
    for (final StreamInformation stream in mediaInformation.getStreams()) {
      if (stream.getType() == 'video') {
        return stream;
      }
    }
    return null;
  }

  /// 把 FFprobe 的秒数字符串转成 `Duration`。
  static Duration? _parseDuration(String? rawDuration) {
    final double? seconds = double.tryParse(rawDuration ?? '');
    if (seconds == null || seconds <= 0) return null;
    return Duration(milliseconds: (seconds * 1000).round());
  }

  /// 构建视频编码参数。
  ///
  /// 全平台统一使用 `H.264`，优先保证项目现有播放器可稳定解码。
  static List<String> _buildVideoCodecArguments() {
    return [
      '-c:v',
      'libx264',
      '-preset',
      _videoPreset,
      '-crf',
      '$_videoCrf',
      '-profile:v',
      'baseline',
      '-level',
      '3.1',
    ];
  }

  /// 返回当前平台期望的输出编码名称。
  static String _expectedOutputCodec() {
    return 'h264';
  }

  /// 构建压缩结果文件路径。
  static String _buildOutputPath(File sourceFile) {
    final String fileName = path.basenameWithoutExtension(sourceFile.path);
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    return path.join(
      Directory.systemTemp.path,
      '${fileName}_${_expectedOutputCodec()}_480_$timestamp.mp4',
    );
  }

  /// 清理失败时残留的输出文件。
  static Future<void> _deleteOutputIfNeeded(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// 截断过长日志，避免错误日志刷得太大。
  static String _clipLog(String? text) {
    final String content = text ?? '';
    if (content.length <= 1200) return content;
    return '${content.substring(0, 1200)}...';
  }
}
