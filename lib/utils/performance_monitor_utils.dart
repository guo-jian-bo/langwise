/// PerformanceMonitorUtils - Flutter应用性能监控工具
///
/// 功能与优点：
/// 1. **精确FPS计算**：使用Flutter引擎FrameTiming数据进行精确的帧率计算
///    - 基于SchedulerBinding.instance.addTimingsCallback直接获取帧数据
///    - 考虑多帧批处理场景，精确计算帧间隔
///    - 自动适应发布模式和调试模式的不同更新频率
///
/// 2. **响应式监控**：使用GetX响应式变量实现实时数据更新
///    - 提供公共Rx变量访问器，支持UI直接响应数据变化
///    - 无需额外的定时器或轮询机制
///    - 支持使用Obx组件自动响应性能指标变化
///
/// 3. **全面性能监控**：同时监控多个性能指标
///    - FPS监控：实时跟踪应用帧率，及时发现渲染性能问题
///    - 卡顿检测：自动检测并记录UI线程和光栅线程的卡顿事件
///    - 内存监控：集成MemoryUtils进行内存使用跟踪
///    - API调用跟踪：记录网络请求频率
///    - 构建频率监控：跟踪组件构建频率，发现过度重建问题
///
/// 4. **性能告警机制**：
///    - 可配置的阈值系统：为各性能指标设置警告和严重告警阈值
///    - 自定义告警处理器：支持注册外部处理函数响应性能问题
///    - 自动告警日志：在性能指标超过阈值时自动记录日志
///
/// 5. **性能历史记录**：
///    - 时间序列数据：保存指定时间范围内的性能指标历史
///    - 数据分析：支持查询和分析历史性能数据
///    - 可配置的采样率和历史长度
///
/// 6. **易于集成**：
///    - 单例模式实现，方便全局访问
///    - 提供简洁的API接口，易于使用
///    - 支持与GetX状态管理框架无缝集成
///    - 可与性能监控组件直接配合使用

import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'memory_utils.dart';

/// FPS计算器 - 基于FrameTiming精确计算帧率
///
/// 使用Flutter引擎提供的帧计时数据计算精确的FPS值
/// 参考: https://gist.github.com/yrom/ac4f30b26ee02ce3bd3a1d260bb9ffb4
/// https://yrom.net/blog/2019/08/01/how-to-get-fps-in-flutter-app-codes/
/// https://pub.dev/packages/performance_fps
class FpsCalculator {
  FpsCalculator({this.maxFrames = 100})
      : lastFrames = ListQueue<FrameTiming>(maxFrames),
        frameInterval = const Duration(microseconds: Duration.microsecondsPerSecond ~/ 60); // 60fps的帧间隔

  /// 最大帧数记录
  final int maxFrames;

  /// 帧间隔（默认60fps）
  final Duration frameInterval;

  /// 帧数据队列
  final ListQueue<FrameTiming> lastFrames;

  /// 开始监听帧率
  void start() {
    lastFrames.clear();
    SchedulerBinding.instance.addTimingsCallback(_onReportTimings);
  }

  /// 停止监听
  void stop() {
    SchedulerBinding.instance.removeTimingsCallback(_onReportTimings);
  }

  void _onReportTimings(List<FrameTiming> timings) {
    // 添加新帧（保持时间顺序）
    for (final timing in timings) {
      lastFrames.addFirst(timing);
    }

    // 移除多余帧
    while (lastFrames.length > maxFrames) {
      lastFrames.removeLast();
    }
  }

  /// 获取当前FPS（精确计算逻辑）
  ///
  /// 多帧批处理场景说明：
  /// Flutter引擎在报告帧计时数据时会批量处理，而不是逐帧实时报告：
  /// - 在发布模式下：大约每秒批量报告一次帧数据
  /// - 在调试/性能分析模式下：大约每100毫秒批量报告一次
  ///
  /// 如果不考虑批处理特性，简单地计算“帧数÷时间”会导致FPS计算不准确，因为：
  /// 1. 帧可能不是均匀分布的
  /// 2. 批量报告的帧可能跨越不同的时间段
  /// 3. 某些帧可能耗时较长，占用了多个标准帧间隔
  ///
  /// 下面的实现通过以下方式解决这个问题：
  /// 1. 将时间相近的帧分组
  /// 2. 计算每帧的“成本计数”（耗时与标准帧间隔的比值）
  /// 3. 使用公式：帧数 * 60 / 成本计数
  ///
  /// 这种处理方式能够：
  /// - 更准确地反映实际渲染性能
  /// - 正确处理不规则的帧报告间隔
  /// - 考虑到每帧的实际耗时（而不仅仅是帧数）
  double get fps {
    var lastFramesSet = <FrameTiming>[];
    for (FrameTiming timing in lastFrames) {
      if (lastFramesSet.isEmpty) {
        lastFramesSet.add(timing);
      } else {
        var lastStart = lastFramesSet.last.timestampInMicroseconds(FramePhase.buildStart);
        if (lastStart - timing.timestampInMicroseconds(FramePhase.rasterFinish) >
            (frameInterval.inMicroseconds * 2)) {
          // 不同组的帧
          break;
        }
        lastFramesSet.add(timing);
      }
    }

    var frameCount = lastFramesSet.length;
    if (frameCount == 0) return 0;

    var costCount = lastFramesSet.map((t) {
      return (t.totalSpan.inMicroseconds ~/ frameInterval.inMicroseconds) + 1;
    }).fold(0, (a, b) => a + b);

    return costCount > 0 ? frameCount * 60 / costCount : 0;
  }

  /// 获取卡顿帧数
  int getJankFrames() {
    return lastFrames.where((frame) => frame.totalSpan.inMilliseconds > 16.67).length;
  }
}

/// 性能监控工具类 (PerformanceMonitorUtils)
///
/// 提供全链路应用性能监控、分析和优化功能，包括：
///
/// 1. **实时性能指标监控**
///    - FPS监控：实时跟踪应用帧率，及时发现渲染性能问题
///    - 卡顿检测：自动检测并记录UI线程和光栅线程的卡顿事件
///    - 内存监控：集成MemoryUtils进行内存使用跟踪
///    - API调用跟踪：记录网络请求频率
///    - 构建频率监控：跟踪组件构建频率，发现过度重建问题
///
/// 2. **性能告警机制**
///    - 可配置的阈值系统：为各性能指标设置警告和严重告警阈值
///    - 自定义告警处理器：支持注册外部处理函数响应性能问题
///    - 自动告警日志：在性能指标超过阈值时自动记录日志
///
/// 3. **性能历史记录**
///    - 时间序列数据：保存指定时间范围内的性能指标历史
///    - 数据分析：支持查询和分析历史性能数据
///    - 可配置的采样率和历史长度
///
/// 4. **操作性能跟踪**
///    - 精确计时：使用Stopwatch进行高精度计时
///    - 预期耗时检测：自动检测操作是否超过预期耗时
///    - 性能跟踪日志：自动记录关键操作的性能数据
///
/// 5. **性能监控组件**
///    - PerformanceConsole：开发模式下的浮动性能监控控制台
///    - PerformanceTrackedWidget：用于跟踪和优化单个组件的性能
///
/// 使用示例：
/// ```dart
/// // 在应用初始化时启动性能监控
/// void initPerformanceMonitoring() {
///   // 仅在调试模式下启用
///   if (kDebugMode) {
///     PerformanceMonitorUtils.instance.startMonitoring(
///       includeMemory: true,    // 监控内存
///       includeRender: true,    // 监控渲染性能
///       includeBuilds: true,    // 监控构建频率
///       historyLength: 60,      // 保存60秒的历史数据
///       sampleRate: 1,          // 每秒采样一次
///     );
///
///     // 添加内存告警处理
///     PerformanceMonitorUtils.instance.addAlertHandler('memory', (value) {
///       Get.snackbar('内存警告', '当前内存使用: ${value.toStringAsFixed(1)}MB');
///     });
///
///     // 设置自定义阈值
///     PerformanceMonitorUtils.instance.setThreshold(
///       'fps',
///       warnThreshold: 45.0,    // 低于45FPS时警告
///       alertThreshold: 30.0,   // 低于30FPS时告警
///     );
///   }
/// }
///
/// // 在应用根组件中添加性能控制台
/// @override
/// Widget build(BuildContext context) {
///   return PerformanceConsole(
///     enabled: kDebugMode,  // 仅在调试模式显示
///     child: GetMaterialApp(
///       // 应用配置
///     ),
///   );
/// }
///
/// // 跟踪关键操作性能
/// void loadData() async {
///   // 开始计时
///   final stopwatch = PerformanceMonitorUtils.instance.startTrace('数据加载');
///
///   // 执行操作
///   final response = await apiClient.fetchData();
///
///   // 结束计时并检查是否超过预期
///   PerformanceMonitorUtils.instance.endTrace(
///     '数据加载',
///     stopwatch,
///     expectedDurationMs: 500  // 预期在500ms内完成
///   );
/// }
///
/// // 使用性能跟踪组件包装复杂UI
/// Widget build(BuildContext context) {
///   return PerformanceTrackedWidget(
///     tag: '表格组件',       // 组件标识
///     trackBuilds: true,      // 跟踪构建次数
///     repaintBoundary: true,  // 添加重绘边界
///     child: DataTableWidget(
///       // 表格配置
///     ),
///   );
/// }
/// ```
class PerformanceMonitorUtils {
  static final PerformanceMonitorUtils _instance = PerformanceMonitorUtils._();

  static PerformanceMonitorUtils get instance => _instance;

  /// FPS计算器
  final FpsCalculator _fpsCalculator = FpsCalculator();

  // 性能监控数据
  final RxDouble _fps = 0.0.obs;
  final RxInt _jankCount = 0.obs;
  final RxDouble _memoryMB = 0.0.obs;
  final RxInt _buildsPerSecond = 0.obs;
  final Map<String, double> _customMetrics = {};

  // 历史数据
  final List<Map<String, dynamic>> _alertHistory = [];
  final Map<String, List<Map<String, dynamic>>> _customMetricsHistory = {};

  // 监控配置
  bool _monitorMemory = true;

  // 告警处理器
  final Map<String, Function(dynamic)> _alertHandlers = {};

  // 监控状态
  bool _isMonitoring = false;

  // 阈值配置
  final Map<String, Map<String, double>> _thresholds = {
    'fps': {'warn': 55, 'alert': 30},
    'jank': {'warn': 5, 'alert': 20},
    'memory': {'warn': 150, 'alert': 300},
    'apiCall': {'warn': 50, 'alert': 100},
    'builds': {'warn': 60, 'alert': 120},
  };

  // 默认配置参数
  int _historyLength = 60; // 历史记录长度

  PerformanceMonitorUtils._();

  /// 获取当前性能监控点
  Map<String, dynamic> getPerformanceSnapshot() {
    return {
      'fps': _fps.value,
      'jank': _jankCount.value,
      'memory': _memoryMB.value,
      'builds': _buildsPerSecond.value,
    };
  }

  /// 响应式 FPS 变量
  RxDouble get fps => _fps;

  /// 响应式卡顿计数变量
  RxInt get jankCount => _jankCount;

  /// 响应式内存使用变量 (MB)
  RxDouble get memoryMB => _memoryMB;

  /// 响应式构建频率变量
  RxInt get buildsPerSecond => _buildsPerSecond;

  /// 启动性能监控
  ///
  /// [includeMemory] 是否包含内存监控
  /// [includeRender] 是否包含渲染性能监控
  /// [includeBuilds] 是否监控构建频率
  /// [historyLength] 历史记录长度
  /// [sampleRate] 采样频率(毫秒)
  void startMonitoring({
    bool includeMemory = true,
    bool includeRender = true,
    bool includeBuilds = true,
    int historyLength = 60,
    int sampleRate = 1000,
  }) {
    if (_isMonitoring) return;
    _isMonitoring = true;

    // 设置监控配置
    _monitorMemory = includeMemory;
    _historyLength = historyLength;

    // 已移除其他监控标志变量

    // 启动子系统监控
    if (includeMemory) {
      MemoryUtils.instance.startMemoryMonitoring(intervalMilliseconds: sampleRate);
    }

    // 设置监听器
    _setupListeners();

    // 设置卡顿检测
    _setupJankDetection();

    // 设置构建频率跟踪
    if (includeBuilds) {
      _setupBuildTracking();
    }
  }

  /// 停止性能监控
  void stopMonitoring() {
    _isMonitoring = false;
    // 停止FPS计算
    _fpsCalculator.stop();

    // 停止子系统监控
    if (_monitorMemory) {
      MemoryUtils.instance.stopMemoryMonitoring();
    }
  }

  /// 设置指标告警阈值
  ///
  /// [metric] 指标名称: 'fps', 'jank', 'memory', 'apiCall', 'builds'
  /// [warnThreshold] 警告阈值
  /// [alertThreshold] 严重告警阈值
  void setThreshold(String metric, {double? warnThreshold, double? alertThreshold}) {
    if (!_thresholds.containsKey(metric)) {
      // debugPrint('未知的性能指标: $metric');
      return;
    }

    if (warnThreshold != null) {
      _thresholds[metric]!['warn'] = warnThreshold;
    }

    if (alertThreshold != null) {
      _thresholds[metric]!['alert'] = alertThreshold;
    }

    // debugPrint('已设置 $metric 阈值: 警告=$warnThreshold, 严重=$alertThreshold');
  }

  /// 添加告警处理器
  ///
  /// [metric] 指标名称
  /// [handler] 处理函数，接收指标当前值
  void addAlertHandler(String metric, Function(dynamic) handler) {
    _alertHandlers[metric] = handler;
  }

  /// 移除告警处理器
  void removeAlertHandler(String metric) {
    _alertHandlers.remove(metric);
  }

  /// 设置性能数据采样监听器
  void _setupListeners() {
    // 监听内存使用变化
    MemoryUtils.instance.listenToMemoryUsage((memoryMB) {
      _memoryMB.value = memoryMB;
    });

    // 监听内存压力
    MemoryUtils.instance.addMemoryPressureListener((level) {
      if (level == MemoryPressureLevel.critical) {
        // debugPrint('⚠️ 检测到内存压力严重!');
        _triggerAlert('memory', _memoryMB.value);
      }
    });
  }

  /// 设置卡顿检测
  void _setupJankDetection() {
    // 启动精确FPS计算
    _fpsCalculator.start();

    // 根据构建模式确定更新间隔
    // 发布模式：约每秒一次
    // 调试/性能分析模式：约每100毫秒一次
    const updateInterval = kReleaseMode
        ? Duration(milliseconds: 1000) // 发布模式
        : Duration(milliseconds: 150); // 调试/性能分析模式

    debugPrint('FPS监控更新间隔: ${updateInterval.inMilliseconds}ms (${kReleaseMode ? "发布" : "调试"}模式)');

    // 定期更新FPS值
    Timer.periodic(updateInterval, (_) {
      final currentFps = _fpsCalculator.fps;
      _fps.value = currentFps;

      // 检查FPS是否过低（可能存在卡顿）
      if (currentFps < 45 && currentFps > 0) {
        _checkMetricAlert('fps', currentFps, isLowerWorse: true);
      }
    });

    // 保留原有卡顿检测逻辑
    // SchedulerBinding.instance.addTimingsCallback((List<FrameTiming> timings) {
    //   // print("监听帧回调timings: ${timings.length}");
    //
    //   for (final timing in timings) {
    //     // 计算总帧时间（从vsync信号到光栅化完成）
    //     final totalFrameMs = (timing.totalSpan.inMicroseconds / 1000).toDouble();
    //
    //     // 获取UI线程耗时（构建时间）
    //     final buildTimeMs = (timing.buildDuration.inMicroseconds / 1000).toDouble();
    //
    //     // 获取光栅线程耗时（渲染时间）
    //     final rasterTimeMs = (timing.rasterDuration.inMicroseconds / 1000).toDouble();
    //
    //     // 16.67ms是60FPS的帧预算
    //     if (totalFrameMs > 16.67) {
    //       // 计算超出预算的时间
    //       final overBudgetMs = totalFrameMs - 16.67;
    //
    //       // 如果超出50%以上，认为是卡顿
    //       if (overBudgetMs > 8.33) {
    //         _jankCount.value++;
    //
    //         // 判断卡顿来源（UI线程或光栅线程）
    //         String jankSource = "未知";
    //         if (buildTimeMs > 16.67) {
    //           jankSource = "UI线程";
    //         } else if (rasterTimeMs > 16.67) {
    //           jankSource = "光栅线程";
    //         }
    //
    //         // 记录严重卡顿
    //         if (totalFrameMs > 100) {
    //           // debugPrint('⚠️ 检测到严重卡顿($jankSource): 总耗时=${totalFrameMs.toStringAsFixed(1)}ms, ' +
    //           //     'UI=${buildTimeMs.toStringAsFixed(1)}ms, 渲染=${rasterTimeMs.toStringAsFixed(1)}ms');
    //           // _triggerAlert('jank', totalFrameMs);
    //         }
    //       }
    //     }
    //   }
    // });
  }

  /// 设置构建频率跟踪
  void _setupBuildTracking() {
    int buildCount = 0;

    // 周期性重置计数
    Timer.periodic(const Duration(seconds: 1), (_) {
      _buildsPerSecond.value = buildCount;
      buildCount = 0;
    });

    if (kDebugMode) {
      debugPrintBuildScope = false;

      // 替换Flutter的调试打印函数来捕获构建事件
      final originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null && message.contains('built')) {
          buildCount++;
        }
        originalDebugPrint(message, wrapWidth: wrapWidth);
      };
      return;
    }

    SchedulerBinding.instance.addTimingsCallback((timings) {
      buildCount += timings.length;
    });
  }

  /// 检查指标是否达到告警条件
  ///
  /// [metric] 指标名称
  /// [value] 当前值
  /// [isLowerWorse] 值越低越差（如FPS）
  void _checkMetricAlert(String metric, double value, {bool isLowerWorse = false}) {
    if (!_thresholds.containsKey(metric)) return;

    final thresholds = _thresholds[metric]!;
    final alertThreshold = thresholds['alert'];
    final warnThreshold = thresholds['warn'];

    if (alertThreshold == null || warnThreshold == null) return;

    bool isAlert = false;
    bool isWarning = false;

    if (isLowerWorse) {
      isAlert = value <= alertThreshold;
      isWarning = !isAlert && value <= warnThreshold;
    } else {
      isAlert = value >= alertThreshold;
      isWarning = !isAlert && value >= warnThreshold;
    }

    if (isAlert) {
      _triggerAlert(metric, value);
    } else if (isWarning) {
      _triggerWarning(metric, value);
    }
  }

  /// 触发告警
  void _triggerAlert(String metric, dynamic value) {
    // debugPrint('🚨 性能指标告警: $metric = $value');

    // 调用告警处理器
    if (_alertHandlers.containsKey(metric)) {
      _alertHandlers[metric]!(value);
    }
  }

  /// 触发警告
  void _triggerWarning(String metric, dynamic value) {
    // debugPrint('⚠️ 性能指标警告: $metric = $value');
  }

  /// 记录自定义指标
  ///
  /// [tag] 指标标识
  /// [value] 指标值
  /// [extraData] 附加数据
  void recordCustomMetric(String tag, double value, {Map<String, dynamic>? extraData}) {
    // 记录当前值
    _customMetrics[tag] = value;

    // 添加到历史记录
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    if (!_customMetricsHistory.containsKey(tag)) {
      _customMetricsHistory[tag] = [];
    }

    final Map<String, dynamic> record = {
      'timestamp': timestamp,
      'value': value,
    };

    if (extraData != null) {
      record['extraData'] = extraData;
    }

    _customMetricsHistory[tag]!.add(record);

    // 清理旧记录
    if (_customMetricsHistory[tag]!.length > _historyLength) {
      _customMetricsHistory[tag]!.removeAt(0);
    }

    // 触发告警检查
    if (_thresholds.containsKey(tag)) {
      _checkMetricAlert(tag, value);
    }
  }

  /// 记录性能告警
  ///
  /// [tag] 指标标识
  /// [actualValue] 实际值
  /// [expectedValue] 预期值
  /// [alertType] 告警类型
  void recordPerformanceAlert(String tag, double actualValue, {double? expectedValue, String? alertType}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // 创建告警记录
    final Map<String, dynamic> alertRecord = {
      'timestamp': timestamp,
      'tag': tag,
      'actualValue': actualValue,
      'type': alertType ?? 'performance',
    };

    if (expectedValue != null) {
      alertRecord['expectedValue'] = expectedValue;
      alertRecord['deviation'] = ((actualValue - expectedValue) / expectedValue * 100).abs();
    }

    // 添加到告警历史
    _alertHistory.add(alertRecord);

    // 清理旧记录
    if (_alertHistory.length > _historyLength) {
      _alertHistory.removeAt(0);
    }

    // 触发告警处理
    if (_alertHandlers.containsKey(alertType ?? 'performance')) {
      final handler = _alertHandlers[alertType ?? 'performance'];
      if (handler != null) {
        handler(alertRecord);
      }
    }

    // 输出警告日志
    // debugPrint('⚠️ 性能告警: $tag, 实际值: $actualValue${expectedValue != null ? ", 预期值: $expectedValue" : ""}');
  }

  /// 开始性能追踪（用于特定操作的性能分析）
  ///
  /// [tag] 追踪标签，用于识别不同的追踪
  Stopwatch startTrace(String tag) {
    // debugPrint('📊 开始性能追踪: $tag');
    final stopwatch = Stopwatch()..start();
    return stopwatch;
  }

  /// 结束性能追踪
  ///
  /// [tag] 追踪标签
  /// [stopwatch] 开始时返回的计时器
  /// [expectedDurationMs] 预期耗时（毫秒），超过则警告
  void endTrace(String tag, Stopwatch stopwatch, {int? expectedDurationMs}) {
    final durationMs = stopwatch.elapsedMilliseconds;
    stopwatch.stop();

    // final message = '📊 性能追踪 [$tag] 耗时: ${durationMs}ms';

    if (expectedDurationMs != null && durationMs > expectedDurationMs) {
      // debugPrint('⚠️ $message (超出预期 ${durationMs - expectedDurationMs}ms)');
    } else {
      // debugPrint(message);
    }
  }
}
