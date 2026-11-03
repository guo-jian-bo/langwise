import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/media_information.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/stream_information.dart';
import 'package:path/path.dart' as path;

import 'log_utils/error_log_utils.dart';

/// 图片基础信息。
///
/// 只保留图片压缩链路真正需要的字段，避免把 FFprobe 原始结果直接暴露给上层。
class ImageCompressInfo {
  /// 图片宽度。
  final int width;

  /// 图片高度。
  final int height;

  /// 图片编码名称，例如 `jpeg`、`png`、`webp`。
  final String codec;

  /// 文件大小，单位字节。
  final int fileSize;

  const ImageCompressInfo({
    required this.width,
    required this.height,
    required this.codec,
    required this.fileSize,
  });
}

/// 图片压缩工具。
///
/// 负责把本地图片统一压缩为：
/// - `webp`
/// - 最大宽度 `1080`
/// - 高度按比例自动适配
/// - 小图不放大
class ImageCompressUtils {
  /// 单图成品默认输出宽度。
  static const int _defaultMaxWidth = 1080;

  /// 单图成品默认质量。
  static const int _defaultQuality = 90;

  /// FFmpegKit 初始化只需要做一次。
  static Future<void>? _initFuture;

  /// 读取本地图片基础信息。
  ///
  /// 返回值用于尺寸计算、压缩前后日志记录和结果校验。
  static Future<ImageCompressInfo?> getImageInfo(File file) async {
    if (!(await file.exists())) return null;

    try {
      await _ensureInitialized();
      final session = await FFprobeKit.getMediaInformation(file.path);
      final MediaInformation? mediaInformation = session.getMediaInformation();
      if (mediaInformation == null) return null;

      final StreamInformation? imageStream = _findImageStream(mediaInformation);
      final int? width = imageStream?.getWidth();
      final int? height = imageStream?.getHeight();
      if (width == null || height == null || width <= 0 || height <= 0) {
        return null;
      }

      return ImageCompressInfo(
        width: width,
        height: height,
        codec: imageStream?.getCodec() ?? '',
        fileSize: await file.length(),
      );
    } catch (e, stackTrace) {
      await ErrorLogUtils.to.logError('[ImageCompressUtils] 读取图片信息失败 path:${file.path} error:$e', stackTrace);
      return null;
    }
  }

  /// 把本地图片压缩为 `webp` 文件。
  ///
  /// 宽度大于 `targetWidth` 时缩到目标宽度；
  /// 宽度小于等于 `targetWidth` 时保持原始尺寸，不做放大。
  static Future<File?> compressImageToWebp(
    File file, {
    int targetWidth = _defaultMaxWidth,
    int quality = _defaultQuality,
  }) async {
    if (!(await file.exists())) return null;

    final Stopwatch stopwatch = Stopwatch()..start();
    final int normalizedWidth = targetWidth > 0 ? targetWidth : _defaultMaxWidth;
    final int normalizedQuality = quality.clamp(1, 100).toInt();
    final String outputPath = _buildOutputPath(file, normalizedWidth);
    final File outputFile = File(outputPath);
    File? preparedInputFile;

    try {
      await _ensureInitialized();
      preparedInputFile = await _prepareCompressionInput(file);
      if (preparedInputFile == null) return null;

      final ImageCompressInfo? inputInfo = await getImageInfo(preparedInputFile);
      if (inputInfo == null) return null;

      final _ImageOutputSize outputSize = _calculateOutputSize(
        inputWidth: inputInfo.width,
        inputHeight: inputInfo.height,
        maxWidth: normalizedWidth,
      );
      final String scaleFilter = _buildScaleFilter(normalizedWidth);

      await ErrorLogUtils.to.logInfo(
        '[ImageCompressUtils] start path:${file.path} '
        'preparedPath:${preparedInputFile.path} '
        'size:${inputInfo.fileSize} width:${inputInfo.width} height:${inputInfo.height} '
        'codec:${inputInfo.codec} targetWidth:${outputSize.width} targetHeight:${outputSize.height} '
        'filter:$scaleFilter '
        'quality:$normalizedQuality',
      );

      final List<String> commandArguments = [
        '-y',
        '-hide_banner',
        '-i',
        preparedInputFile.path,
        '-vf',
        scaleFilter,
        '-frames:v',
        '1',
        '-vcodec',
        'libwebp',
        // 当前项目内置的 FFmpeg 不支持 `-lossless` 这类 WebP 专有参数，
        // 这里退回到兼容性更好的质量参数，优先保证四端都能稳定输出。
        '-quality',
        '$normalizedQuality',
        outputPath,
      ];

      final session = await FFmpegKit.executeWithArguments(commandArguments);
      final ReturnCode? returnCode = await session.getReturnCode();
      final String? sessionOutput = await session.getOutput();
      if (!ReturnCode.isSuccess(returnCode)) {
        await _deleteOutputIfNeeded(outputFile);
        await ErrorLogUtils.to.logError(
          '[ImageCompressUtils] 压缩失败 path:${file.path} '
          'returnCode:${returnCode?.getValue()} output:${_clipLog(sessionOutput)}',
          null,
        );
        return null;
      }

      if (!(await outputFile.exists())) {
        await ErrorLogUtils.to.logError('[ImageCompressUtils] 输出文件不存在 path:$outputPath', null);
        return null;
      }
      if (await outputFile.length() <= 0) {
        await _deleteOutputIfNeeded(outputFile);
        await ErrorLogUtils.to.logError('[ImageCompressUtils] 输出文件大小异常 path:$outputPath', null);
        return null;
      }

      final ImageCompressInfo? outputInfo = await getImageInfo(outputFile);
      if (outputInfo == null) {
        await _deleteOutputIfNeeded(outputFile);
        await ErrorLogUtils.to.logError('[ImageCompressUtils] 压缩结果读取失败 path:$outputPath', null);
        return null;
      }
      if (outputInfo.codec.toLowerCase() != 'webp') {
        await _deleteOutputIfNeeded(outputFile);
        await ErrorLogUtils.to.logError(
          '[ImageCompressUtils] 压缩结果校验失败 path:$outputPath codec:${outputInfo.codec}',
          null,
        );
        return null;
      }

      await ErrorLogUtils.to.logInfo(
        '[ImageCompressUtils] done input:${file.path} output:$outputPath '
        'size:${outputInfo.fileSize} width:${outputInfo.width} height:${outputInfo.height} '
        'codec:${outputInfo.codec} cost:${stopwatch.elapsed.inMilliseconds}ms',
      );

      return outputFile;
    } catch (e, stackTrace) {
      await _deleteOutputIfNeeded(outputFile);
      await ErrorLogUtils.to.logError('[ImageCompressUtils] 压缩异常 path:${file.path} error:$e', stackTrace);
      return null;
    } finally {
      await _deletePreparedInputIfNeeded(preparedInputFile, originalFile: file);
    }
  }

  /// 确保 FFmpegKit 只初始化一次。
  static Future<void> _ensureInitialized() {
    return _initFuture ??= FFmpegKitConfig.init();
  }

  /// 从探测结果里取出第一条可用图片流。
  static StreamInformation? _findImageStream(MediaInformation mediaInformation) {
    for (final StreamInformation stream in mediaInformation.getStreams()) {
      final int? width = stream.getWidth();
      final int? height = stream.getHeight();
      if (stream.getType() == 'video' && width != null && height != null && width > 0 && height > 0) {
        return stream;
      }
    }
    return null;
  }

  /// 计算输出宽高。
  ///
  /// 小于等于目标宽度的图片保持原始尺寸，不做放大。
  static _ImageOutputSize _calculateOutputSize({
    required int inputWidth,
    required int inputHeight,
    required int maxWidth,
  }) {
    if (inputWidth <= maxWidth) {
      return _ImageOutputSize(width: inputWidth, height: inputHeight);
    }
    final int outputHeight = (inputHeight * maxWidth / inputWidth).round();
    return _ImageOutputSize(
      width: maxWidth,
      height: outputHeight > 0 ? outputHeight : 1,
    );
  }

  /// 构建按目标宽度缩放的滤镜表达式。
  ///
  /// 只约束最大宽度，高度交给 FFmpeg 按原始比例自动推导，
  /// 并把采样纵横比重置为 1，避免移动端图片出现拉伸。
  static String _buildScaleFilter(int maxWidth) {
    return 'scale=min($maxWidth\\,iw):-2,setsar=1';
  }

  /// 为压缩准备可稳定解码的输入文件。
  ///
  /// 所有 HEIC/HEIF 输入都会先转成临时 PNG，再继续统一压缩链路。
  /// 这样可以把 HEIC 的解码差异隔离在前置步骤里，避免直接转 WebP
  /// 时受平台实现差异影响。
  static Future<File?> _prepareCompressionInput(File sourceFile) async {
    if (!_isHeicFile(sourceFile.path)) {
      return sourceFile;
    }
    if (Platform.isMacOS) {
      return _convertHeicToPngOnMacOS(sourceFile);
    }
    return _convertHeicToPngWithFfmpeg(sourceFile);
  }

  /// 判断是否为 HEIC/HEIF 文件。
  static bool _isHeicFile(String filePath) {
    final String ext = path.extension(filePath).toLowerCase();
    return ext == '.heic' || ext == '.heif';
  }

  /// 在 macOS 下把 HEIC/HEIF 先转换成 PNG。
  static Future<File?> _convertHeicToPngOnMacOS(File sourceFile) async {
    final String fileName = path.basenameWithoutExtension(sourceFile.path);
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    final String outputPath = path.join(
      Directory.systemTemp.path,
      '${fileName}_heic_decode_$timestamp.png',
    );
    final ProcessResult result = await Process.run(
      'sips',
      ['-s', 'format', 'png', sourceFile.path, '--out', outputPath],
    );
    final File outputFile = File(outputPath);
    if (result.exitCode != 0 || !(await outputFile.exists()) || await outputFile.length() <= 0) {
      await _deleteOutputIfNeeded(outputFile);
      await ErrorLogUtils.to.logError(
        '[ImageCompressUtils] HEIC 预处理失败 path:${sourceFile.path} '
        'exitCode:${result.exitCode} stderr:${_clipLog(result.stderr?.toString())}',
        null,
      );
      return null;
    }
    await ErrorLogUtils.to.logInfo(
      '[ImageCompressUtils] HEIC 预处理完成 source:${sourceFile.path} output:$outputPath decoder:sips',
    );
    return outputFile;
  }

  /// 在非 macOS 平台下把 HEIC/HEIF 先转换成 PNG。
  ///
  /// 这里仍然使用 FFmpeg，但把 HEIC 解码与最终 WebP 压缩拆成两步，
  /// 避免同一条命令里同时承载格式解码和最终编码时更难定位兼容性问题。
  static Future<File?> _convertHeicToPngWithFfmpeg(File sourceFile) async {
    final String outputPath = _buildPreparedPngPath(sourceFile);
    final File outputFile = File(outputPath);
    final List<String> commandArguments = [
      '-y',
      '-hide_banner',
      '-i',
      sourceFile.path,
      '-frames:v',
      '1',
      '-pix_fmt',
      'rgba',
      outputPath,
    ];
    final session = await FFmpegKit.executeWithArguments(commandArguments);
    final ReturnCode? returnCode = await session.getReturnCode();
    final String? sessionOutput = await session.getOutput();
    if (!ReturnCode.isSuccess(returnCode) || !(await outputFile.exists()) || await outputFile.length() <= 0) {
      await _deleteOutputIfNeeded(outputFile);
      await ErrorLogUtils.to.logError(
        '[ImageCompressUtils] HEIC 预处理失败 path:${sourceFile.path} '
        'decoder:ffmpeg returnCode:${returnCode?.getValue()} output:${_clipLog(sessionOutput)}',
        null,
      );
      return null;
    }
    await ErrorLogUtils.to.logInfo(
      '[ImageCompressUtils] HEIC 预处理完成 source:${sourceFile.path} output:$outputPath decoder:ffmpeg',
    );
    return outputFile;
  }

  /// 构建 HEIC 预处理阶段的临时 PNG 路径。
  static String _buildPreparedPngPath(File sourceFile) {
    final String fileName = path.basenameWithoutExtension(sourceFile.path);
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    return path.join(
      Directory.systemTemp.path,
      '${fileName}_heic_decode_$timestamp.png',
    );
  }

  /// 构建压缩结果文件路径。
  static String _buildOutputPath(File sourceFile, int targetWidth) {
    final String fileName = path.basenameWithoutExtension(sourceFile.path);
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    return path.join(
      Directory.systemTemp.path,
      '${fileName}_webp_${targetWidth}_$timestamp.webp',
    );
  }

  /// 清理失败时残留的输出文件。
  static Future<void> _deleteOutputIfNeeded(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// 清理压缩前的临时输入文件。
  static Future<void> _deletePreparedInputIfNeeded(File? file, {required File originalFile}) async {
    if (file == null) return;
    if (file.path == originalFile.path) return;
    await _deleteOutputIfNeeded(file);
  }

  /// 截断过长日志，避免错误日志刷得太大。
  static String _clipLog(String? text) {
    final String content = text ?? '';
    if (content.length <= 1200) return content;
    return '${content.substring(0, 1200)}...';
  }
}

/// 图片输出尺寸。
///
/// 单独抽成小对象，避免宽高在压缩主流程里散落成两个裸值。
class _ImageOutputSize {
  final int width;
  final int height;

  const _ImageOutputSize({
    required this.width,
    required this.height,
  });
}
