import 'permission_utils.dart';
import 'dart:io';

import 'package:path/path.dart' as path_util;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:langwise/utils/common_util.dart';
import 'package:uuid/uuid.dart';

class FileUtils {
  static final Map<String, bool> _authorizedDirs = {};

  // 检查目录权限
  static Future<bool> checkDirAccess(String dirPath) async {
    bool granted = _authorizedDirs[dirPath] ?? false;
    if (!granted) {
      granted = await PermissionUtils.directory(dirPath);
      _authorizedDirs[dirPath] = granted;
    }
    return granted;
  }

  /// 清理指定前缀的临时图片文件
  ///
  /// [prefix] 文件名前缀，默认为CommonUtil.langwise
  /// [extension] 文件扩展名，默认为'.jpg'
  /// [onlyInTempDir] 是否仅清理临时目录，默认为true
  ///
  /// 返回被清理的文件数量
  static Future<int> cleanupTempImages({
    String? prefix,
    bool onlyInTempDir = true,
  }) async {
    try {
      final String filePrefix = prefix ?? CommonUtil.langwise;
      final Directory tempDir = await getTemporaryDirectory();
      final Directory dir = Directory(tempDir.path);

      if (!await dir.exists()) {
        if (kDebugMode) {
          print('[FileUtils] 临时目录不存在');
        }
        return 0;
      }

      // 获取目录中的所有文件
      final List<FileSystemEntity> files = dir.listSync();

      int count = 0;

      // 筛选并删除匹配前缀和扩展名的文件
      for (final file in files) {
        if (file is File) {
          final String fileName = path_util.basename(file.path);
          if (fileName.startsWith(filePrefix)) {
            try {
              await file.delete();
              count++;
              if (kDebugMode) {
                print('[FileUtils] 已删除临时文件: ${file.path}');
              }
            } catch (e) {
              if (kDebugMode) {
                print('[FileUtils] 删除文件失败: ${file.path}, 错误: $e');
              }
            }
          }
        }
      }

      if (kDebugMode && count > 0) {
        print('[FileUtils] 共清理 $count 个临时文件');
      }

      return count;
    } catch (e) {
      if (kDebugMode) {
        print('[FileUtils] 清理临时文件时出错: $e');
      }
      return 0;
    }
  }

  /// 清理裁剪后的图片临时文件
  ///
  /// 清理带有"langwise_left"和"langwise_right"前缀的临时裁剪图片
  /// 返回被清理的文件数量
  static Future<int> cleanupCroppedImages() async {
    final String prefix = CommonUtil.langwise;
    int total = 0;

    // 清理左侧图片
    total += await cleanupTempImages(prefix: '${prefix}_left');

    // 清理右侧图片
    total += await cleanupTempImages(prefix: '${prefix}_right');

    return total;
  }

  /// 根据模式删除临时文件
  ///
  /// [pattern] 文件名匹配模式，支持简单的通配符
  /// 例如："langwise_*.jpg"将匹配所有以"langwise_"开头，".jpg"结尾的文件
  static Future<int> deleteFilesByPattern(String pattern) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final List<FileSystemEntity> files = tempDir.listSync();

      final RegExp regExp = _patternToRegExp(pattern);
      int count = 0;

      for (final file in files) {
        if (file is File) {
          final String fileName = path_util.basename(file.path);
          if (regExp.hasMatch(fileName)) {
            try {
              await file.delete();
              count++;
            } catch (e) {
              if (kDebugMode) {
                print('[FileUtils] 删除文件 $fileName 失败: $e');
              }
            }
          }
        }
      }

      return count;
    } catch (e) {
      if (kDebugMode) {
        print('[FileUtils] 按模式删除文件时出错: $e');
      }
      return 0;
    }
  }

  /// 将简单的通配符模式转换为RegExp
  static RegExp _patternToRegExp(String pattern) {
    String regexPattern = pattern.replaceAll('.', r'\.').replaceAll('*', r'.*').replaceAll('?', r'.');
    return RegExp('^$regexPattern\$');
  }

  /// 清洗路径/文件名片段，跨平台合法化
  /// 替换非法字符、去除结尾空格与句点、规范空白；空返回 `untitled`
  /// 最大长度 100 字符
  static String sanitizePathSegment(String input) {
    String s = input.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_');
    s = s.trim();
    s = s.replaceAll(RegExp(r'[\. ]+$'), '');
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    if (s.isEmpty) return 'untitled';
    const int maxLen = 100;
    return s.length > maxLen ? s.substring(0, maxLen) : s;
  }

  /// 保存图像数据到临时文件
  ///
  /// [imageData] 要保存的图像数据字节
  /// [prefix] 文件名前缀，默认为CommonUtil.langwise
  /// [suffix] 文件名后缀/标识，例如'left'或'right'
  /// [extension] 文件扩展名，默认为'.jpg'
  /// [uuid] 可选的UUID，如果不提供则自动生成
  ///
  /// 返回保存的文件对象和文件路径
  static Future<FileSaveResult> saveTempImage({
    required Uint8List imageData,
    String? prefix,
    required String suffix,
    String extension = '.jpg',
    String? uuid,
  }) async {
    try {
      // 获取临时目录
      final tempDir = await getTemporaryDirectory();

      // 生成或使用提供的UUID
      final String fileUuid = uuid ?? const Uuid().v6();

      // 构建文件名 (例如: langwise_left_123456.jpg)
      final String filePrefix = prefix ?? CommonUtil.langwise;
      final String fileName = '${filePrefix}_${suffix}_$fileUuid$extension';

      // 创建完整的文件路径
      final String filePath = path_util.join(tempDir.path, fileName);
      final File tempFile = File(filePath);

      // 写入文件数据
      await tempFile.writeAsBytes(imageData);

      if (kDebugMode) {
        print('[FileUtils] 已保存临时图片: $filePath, 大小: ${imageData.length} 字节');
      }

      return FileSaveResult(
        file: tempFile,
        path: filePath,
        fileName: fileName,
        uuid: fileUuid,
      );
    } catch (e) {
      if (kDebugMode) {
        print('[FileUtils] 保存临时图片失败: $e');
      }
      rethrow; // 重新抛出异常，让调用方处理
    }
  }
}

/// 临时文件管理工具类
/// 负责处理应用产生的临时文件，特别是图片处理过程中的临时文件
/// 文件保存结果类
class FileSaveResult {
  /// 保存的文件对象
  final File file;

  /// 完整的文件路径
  final String path;

  /// 文件名
  final String fileName;

  /// 用于生成文件名的UUID
  final String uuid;

  FileSaveResult({
    required this.file,
    required this.path,
    required this.fileName,
    required this.uuid,
  });
}
