import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'error_log_utils.dart';

/// Android 原生错误桥接工具。
///
/// 用于在 Flutter 启动后读取 Android 侧提前落盘的原生错误，
/// 再统一转写到现有的 [ErrorLogUtils] 中，方便和 Dart 日志一起查看。
class NativeErrorBridge {
  static const MethodChannel _channel = MethodChannel('native_error_bridge');

  /// 消费 Android 原生待上报错误。
  ///
  /// 这里只在 Android 平台执行：
  /// 1. 通过 MethodChannel 向原生读取待消费日志
  /// 2. 逐条解析原生返回的数据
  /// 3. 转写到 [ErrorLogUtils]，统一进入现有日志体系
  static Future<void> consumePendingErrors() async {
    if (!Platform.isAndroid) return;
    try {
      final String? raw = await _channel.invokeMethod<String>('consumePendingNativeErrors');
      final List<dynamic> list = raw == null || raw.isEmpty || raw == '[]' ? <dynamic>[] : jsonDecode(raw);
      await ErrorLogUtils.to.logInfo('[NativeErrorBridge] 读取到原生待消费错误 ${list.length} 条');
      if (list.isEmpty) return;
      for (final item in list) {
        try {
          if (item is! Map) continue;
          // 保留原生侧的关键上下文，便于后续排查来源和线程信息。
          final type = '${item['type'] ?? 'native_error'}';
          final tag = '${item['tag'] ?? 'unknown'}';
          final message = '${item['message'] ?? ''}';
          final time = '${item['time'] ?? ''}';
          final thread = '${item['thread'] ?? ''}';
          await ErrorLogUtils.to.logError(
            '[native][$type][$tag] $message time:$time thread:$thread',
            null,
          );
        } catch (_) {}
      }
    } catch (_) {}
  }
}
