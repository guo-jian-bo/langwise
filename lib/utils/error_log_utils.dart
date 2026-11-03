import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 错误日志工具类
/// 用于收集错误和崩溃信息，写入文件
/// 在下次启动时检查、上报并清除日志
class ErrorLogUtils {
  static const String _errorLogFileName = 'langwise_log.json';
  static final ErrorLogUtils _instance = ErrorLogUtils._internal();
  // 最大日志文件大小：10MB（按字节）
  static const int _maxLogBytes = 10 * 1024 * 1024;
  
  // 单例模式
  factory ErrorLogUtils() => _instance;
  
  ErrorLogUtils._internal();
  
  // 获取单例实例
  static ErrorLogUtils get to => _instance;

  /// 获取日志文件的大小（字节）
  Future<int> getLogFileSize() async {
    final file = await getLogFile();
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  /// 记录错误信息到文件
  /// [error] 错误对象
  /// [stackTrace] 堆栈跟踪
  Future<void> logError(dynamic error, StackTrace? stackTrace) async {
    if (kDebugMode) {
      print('记录错误: $error');
      if (stackTrace != null) print(stackTrace);
    }

    try {
      final errorInfo = {
        'type': 'error',
        'time': DateFormatUtil.formatStr(DateTime.now().toLocal(), newPattern: "yyyy-MM-dd HH:mm:ss"),
        'err': toSingleLineJsonSafe(error),
        'platform': Platform.operatingSystem,
        'version': await _getAppVersion(),
        'route': Get.currentRoute,
      };

      if (stackTrace != null) {
        errorInfo['stack'] = toSingleLineJsonSafe(stackTrace);
      }

      final file = await getLogFile();

      UmengUtils.error(jsonEncode(errorInfo));

      await _enqueueLineRaf(file, jsonEncode(errorInfo));
    } catch (e) {
      if (kDebugMode) {
        print('记录错误日志失败: $e');
      }
    }
  }

  /// 记录普通信息到文件
  /// [message] 普通信息
  Future<void> logInfo(Object message) async {
    if(UserStore.to.userInfo.value.recordLog == 0) return;
    try {
      final info = {
        'type': 'info',
        "userId": UserStore.to.userInfo.value.userId,
        'time': DateFormatUtil.formatStr(DateTime.now().toLocal(), newPattern: "yyyy-MM-dd HH:mm:ss"),
        'platform': Platform.operatingSystem,
        'version': await _getAppVersion(),
        'info': toSingleLineJsonSafe(message),
      };

      final file = await getLogFile();
      await _enqueueLineRaf(file, jsonEncode(info));
    } catch (e) {
      if (kDebugMode) {
        print('记录普通信息日志失败: $e');
      }
    }
  }
  

  
  /// 清除错误日志
  Future<void> clearErrorLogs() async {
    try {
      final file = await getLogFile();
      if (await file.exists()) {
        await file.delete();
      }
      await _sink?.flush();
      await _sink?.close();
      _sink = null;
    } catch (e) {
      if (kDebugMode) {
        print('清除错误日志失败: $e');
      }
    }
  }
  
  /// 获取错误日志文件
  Future<File> getLogFile() async {
    Directory? dir;
    if (Platform.isAndroid) {
      dir = await getApplicationDocumentsDirectory();
    } else if (Platform.isIOS) {
      dir = await getApplicationSupportDirectory();
    } else if (Platform.isWindows) {
      dir = await getApplicationSupportDirectory();
    } else if (Platform.isMacOS) {
      dir = await getApplicationSupportDirectory();
    } else {
      // 其他平台回退到临时目录
      dir = await getTemporaryDirectory();
    }
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }
    
    File file = File('${dir.path}/$_errorLogFileName');
    if((!await file.exists())){
      await file.create();
    }
    return file;
  }
  
  /// 获取应用版本
  Future<String> _getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      return 'unknown';
    }
  }

  // 文件追加的轻量队列（不使用IOSink，避免StreamSink绑定问题）
  final List<String> _pendingLines2 = [];
  bool _drainBusy2 = false;

  Future<void> _enqueueLineRaf(File file, String line) async {
    _pendingLines2.add(line);
    if (_drainBusy2) return;
    _drainBusy2 = true;
    Future(() async {
      try {
        if (_pendingLines2.isEmpty) return;
        final toWrite = StringBuffer();
        while (_pendingLines2.isNotEmpty) {
          toWrite.writeln(_pendingLines2.removeAt(0));
        }
        await file.writeAsString(toWrite.toString(), mode: FileMode.append);
        _scheduleRotation(file);
      } finally {
        _drainBusy2 = false;
      }
    });
  }

  String toSingleLineJsonSafe(Object input) {
    try {
      if (input is String) {
        final s = input.trim();
        final decoded = jsonDecode(s);
        return jsonEncode(decoded); // 压成紧凑单行 JSON，内部换行转义为 \n
      }
      return jsonEncode(input); // Map/List/其他对象直接单行 JSON
    } catch (_) {
      // 非 JSON 文本：移除换行/制表，并折叠空白
      final s = input.toString();
      final withoutBreaks = s.replaceAll(RegExp(r'(\r\n|\r|\n|\t)+'), ' ');
      return withoutBreaks.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
    }
  }
  
  IOSink? _sink;
  bool _rotationBusy = false;
  DateTime _lastRotation = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _rotationDebounce = Duration(seconds: 1);
  static const int _rotationSlackBytes = 512 * 1024;


  void _scheduleRotation(File file) {
    if (_rotationBusy) return;
    final now = DateTime.now();
    if (now.difference(_lastRotation) < _rotationDebounce) return;
    _rotationBusy = true;
    _lastRotation = now;
    Future(() async {
      try {
        await _rotateIfNeeded(file);
      } finally {
        _rotationBusy = false;
      }
    });
  }

  Future<void> _rotateIfNeeded(File file) async {
    try {
      final length = await file.length();
      // 只在超过 10MB + slack 时旋转，降低频率
      if (length <= _maxLogBytes + _rotationSlackBytes) return;

      // 保留最后 10MB 的完整行（按字节查找换行）
      final raf = await file.open();
      final start = length - _maxLogBytes;
      await raf.setPosition(start);
      final bytes = await raf.read(_maxLogBytes);
      await raf.close();

      // 查找第一个换行符（\n, 10）
      final newlineIndex = bytes.indexOf(10);
      final slice = (newlineIndex >= 0 && newlineIndex + 1 < bytes.length)
          ? bytes.sublist(newlineIndex + 1)
          : bytes;

      // 覆写为尾部字节，避免整段UTF-8解码
      await file.writeAsBytes(slice, mode: FileMode.write);

      // 重新建立 sink，继续追加写入
      await _sink?.close();
      _sink = file.openWrite(mode: FileMode.append, encoding: utf8);
    } catch (e) {
      if (kDebugMode) {
        print('日志旋转失败: $e');
      }
    }
  }
}