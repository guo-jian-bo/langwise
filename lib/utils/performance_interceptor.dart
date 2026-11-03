import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:langwise/utils/performance_service.dart';
import 'package:wise_http/wise_http.dart';

/// 性能监控拦截器
///
/// 用于监控所有网络请求的性能，并记录API调用次数和响应时间
class PerformanceInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 添加性能追踪标记
    options.extra['performanceTraceTag'] = '${options.method}:${options.path}';
    options.extra['performanceTraceStart'] = DateTime.now().millisecondsSinceEpoch;

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _recordApiPerformance(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _recordApiPerformance(err.response);
    handler.next(err);
  }

  /// 记录API性能数据
  void _recordApiPerformance(Response? response) {
    if (response == null || !Get.isRegistered<PerformanceService>()) return;

    final RequestOptions options = response.requestOptions;
    final String? traceTag = options.extra['performanceTraceTag'] as String?;
    final int? startTime = options.extra['performanceTraceStart'] as int?;

    if (traceTag != null && startTime != null) {
      final int endTime = DateTime.now().millisecondsSinceEpoch;
      final int duration = endTime - startTime;

      // 构建完整的性能数据
      final Map<String, dynamic> performanceData = {
        'duration': duration,
        'url': options.path,
        'method': options.method,
        'statusCode': response.statusCode,
        'requestSize': _calculateRequestSize(options),
        'responseSize': _calculateResponseSize(response),
        'cacheHit': response.extra['fromCache'] == true,
        'timestamp': endTime,
      };

      // 如果请求时间超过预期，记录警告
      if (duration > 1000) {
        // 超过1秒的请求
        debugPrint('⚠️ 慢速API请求: $traceTag (${duration}ms)');
      }

      // 直接调用性能服务记录API性能数据
      PerformanceService.to.recordApiPerformance('API:$traceTag', performanceData,
          // 预期API响应时间为500ms
          expectedDurationMs: 500);
    }
  }

  /// 计算请求大小（字节）
  int _calculateRequestSize(RequestOptions options) {
    int size = 0;

    // 计算URL大小
    size += options.path.length;

    // 计算请求头大小
    options.headers.forEach((key, value) {
      size += key.length + value.toString().length;
    });

    // 计算请求体大小
    if (options.data != null) {
      if (options.data is String) {
        size += (options.data as String).length;
      } else if (options.data is Map || options.data is List) {
        try {
          size += jsonEncode(options.data).length;
        } catch (_) {
          // 忽略编码错误
        }
      }
    }

    return size;
  }

  /// 计算响应大小（字节）
  int _calculateResponseSize(Response response) {
    int size = 0;

    // 计算响应头大小
    response.headers.forEach((name, values) {
      size += name.length;
      for (final value in values) {
        size += value.length;
      }
    });

    // 计算响应体大小
    if (response.data != null) {
      if (response.data is String) {
        size += (response.data as String).length;
      } else if (response.data is Map || response.data is List) {
        try {
          size += jsonEncode(response.data).length;
        } catch (_) {
          // 忽略编码错误
        }
      }
    }

    return size;
  }
}
